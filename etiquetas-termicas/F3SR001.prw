/*/{Protheus.doc} F3SR001
Impressão de etiquetas do pedido de venda
@type function
@version 1.0
@author Murillo Romeu - murillosi@gmail.com
@since 28/04/2021
/*/
User Function F3SR001()
	Local lRet      := .T.
	Local _aAreaC5  := SC5->(GetArea())
	Local _aAreaC6  := SC6->(GetArea())
	Local _aAreaB1  := SB1->(GetArea())
	Private aColsEx := {}
	Private oGrid


	If !MsgBox("Deseja fazer impressao de etiquetas do pedido selecionado? (" + SC5->C5_NUM + ")","Ponto de Entrada:MT410BRW","YESNO")
		Return(lRet)
	EndIf

	SB1->(dbSetOrder(1))	//B1_FILIAL+B1_COD
	SC6->(dbSetOrder(1))	//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	SC6->(dbGoTop())
	If(SC6->(dbSeek(SC5->(C5_FILIAL+C5_NUM))))
		While !SC6->(EOF()) .AND. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
			SB1->(dbGoTop())
			SB1->(dbSeek(xFilial("SB1") + SC6->C6_PRODUTO))
			aAdd(aColsEx, {SC6->C6_PRODUTO, SC6->C6_QTDVEN , SB1->B1_DESC, SB1->B1_CODBAR, .F.})
			SC6->(dbSkip())
		EndDo
	EndIf

	RestArea(_aAreaC5)
	RestArea(_aAreaC6)
	RestArea(_aAreaB1)

	Interface()

Return(lRet)

/*/{Protheus.doc} Interface
Interface para listar as etiquetas a serem impressas
@type function
@version 1.0
@author Murillo Romeu - murillosi@gmail.com
@since 28/04/2021
/*/
Static Function Interface()
  Local lRet,cPedido,oButton1,oButton2,oGroup1,oGroup2,oSay1
  Local cTabela   := "Impressão de Códigos de Barras"
  Static oDlg

	//criando a janela no objeto oDlg
	DEFINE MSDIALOG oDlg TITLE "Impressão de Códigos de Barras" FROM 000,000  TO 500,800 COLORS 0,16777215 PIXEL

    @ 004, 004 GROUP oGroup1 TO 032, 394 PROMPT " Programa "    OF oDlg COLOR   0,16777215 PIXEL
    @ 035, 004 GROUP oGroup2 TO 219, 394 PROMPT " Produtos "    OF oDlg COLOR   0,16777215 PIXEL
    @ 015, 009 SAY oSay1 PROMPT cTabela SIZE 375, 007           OF oDlg COLORS  0,16777215 PIXEL
    
		Grid()

		@ 228, 270 BUTTON oButton1 PROMPT ">>>Imprime<<<" SIZE 037, 012 OF oDlg PIXEL ACTION(lRet:=.T.,Confirma())
		@ 228, 310 BUTTON oButton2 PROMPT "Sair"          SIZE 037, 012 OF oDlg PIXEL ACTION(lRet:=.F.,oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED

Return(lRet)

/*/{Protheus.doc} Grid
Grid com os itnes  a serem impressos
@type function
@version 1.0
@author Murillo Romeu - murillosi@gmail.com
@since 28/04/2021
/*/
Static Function Grid()
  Local nX
  Local aFieldFill   := {}
  local aAlterFields := {}
  Local aHeaderEx    := {} 
  Local aFields      := {"C6_PRODUTO", "C6_QTDVEN", "B1_DESC", "B1_CODBAR"}

	// Define Propriedades de aFields
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))	//
	For nX := 1 to Len(aFields)
		If SX3->(dbSeek(aFields[nX]))
			aAdd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
								SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		EndIf
	Next nX

	For nX := 1 to Len(aFields)
		If SX3->(dbSeek(aFields[nX]))
			aAdd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		EndIf
	Next nX

	aAdd(aFieldFill, .F.) //adiciona a coluna delete
	//criar o objeto de MsGetDados
	oGrid := MsNewGetDados():New( 046, 011, 209, 383, GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue",, aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return(Nil)

/*/{Protheus.doc} Confirma
description
@type function
@version 1.0
@author Murillo Romeu - murillo@sysconsulting.com.br - murillosi@gmail.com
@since 28/04/2021
@return return_type, return_description
/*/
Static Function Confirma()
Local aDados      := {}
Local nPosProd  := aScan(oGrid:aHeader ,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
Local nPosQtde  := aScan(oGrid:aHeader ,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
local nPosDesc  := aScan(oGrid:aHeader ,{|x| AllTrim(x[2]) == "B1_DESC"})
local nPosCodB  := aScan(oGrid:aHeader ,{|x| AllTrim(x[2]) == "B1_CODBAR"})

	//POPULANDO O VETOR QUE SERA IMPRESSO.
	For _nX := 1 to Len(oGrid:aCols)
		For _nY := 1 to oGrid:aCols[_nX][nPosQtde]	//C6_QTDVEN
			If(!oGrid:aCols[_nX][Len(oGrid:aHeader) + 1])	//	VERIFICA AS LINHAS DELETADAS
				aAdd(aDados, {ALLTRIM(oGrid:aCols[_nX][nPosProd]), ALLTRIM(oGrid:aCols[_nX][nPosCodB]), ALLTRIM(oGrid:aCols[_nX][nPosDesc])})	//C6_PRODUTO, B1_CODBAR, B1_DESC
			EndIf
		Next _nY
	Next _nX

	ImpArgox(aDados)

Return(Nil)

/*/{Protheus.doc} ImpArgox
Realiza impressão impressora Argox
@type function
@version 1.0
@author Murillo Romeu -  murillosi@gmail.com
@since 28/04/2021
@param aVet, array, dados a serem impressos
/*/
Static Function ImpArgox(aVet)
  Local cPorta  := "LPT1"//porta da impressora
  Local nCount  := 1
  Local cEOL    := "CHR(13)+CHR(10)"
  Local cBuffer	:= ""

	If Empty(cEOL)
    cEOL := CHR(13)+CHR(10)                                                            
	Else
    cEOL := Trim(cEOL)
    cEOL := &cEOL
	Endif

  nHandle := FCREATE("D:\ETIQUETAS.TXT", NIL,NIL, .F.)
	IF FERROR() != 0
		Alert ("Impossivel gravar o arquivo das etiquetas, Erro : "+Alltrim(Str(FERROR())))
		BREAK
	ENDIF

	//IMPRESSAO DOS DADOS DIGITADOS
	For _nX := 1 to Len(aVet)

		If (nCount == 1)    // primeira etiqueta
			cBuffer += "~@"+cEOL
			cBuffer += "N"+cEOL
			cBuffer += 'FK"FORM1"'+cEOL
			cBuffer += 'FS"FORM1"'+cEOL
			cBuffer += 'D6'+cEOL
			cBuffer += 'ZB'+cEOL
			cBuffer += 'R0,0'+cEOL
			cBuffer += 'S4'+cEOL
			cBuffer += 'A0030,0016,0,1,1,1,N,"'+SubStr(aVet[_nX][03],1,24)+'"'+cEOL
			cBuffer	+= 'A0030,0032,0,1,1,1,N,"COD. PRODUTO: '+aVet[_nX][01]+'"'+cEOL
			cBuffer += 'B0030,0048,0,1,2,2,70,B,"'+aVet[_nX][02]+'"'+cEOL

		ElseIf (nCount == 2)  // segunda etiqueta
			cBuffer += 'A0300,0016,0,1,1,1,N,"'+SubStr(aVet[_nX][03],1,24)+'"'+cEOL
			cBuffer	+= 'A0300,0032,0,1,1,1,N,"COD. PRODUTO: '+aVet[_nX][01]+'"'+cEOL
			cBuffer += 'B0300,0048,0,1,2,2,70,B,"'+aVet[_nX][02]+'"'+cEOL
		Else                  // terceira etiqueta
			cBuffer += 'A0560,0016,0,1,1,1,N,"'+SubStr(aVet[_nX][03],1,24)+'"'+cEOL
			cBuffer	+= 'A0560,0032,0,1,1,1,N,"COD. PRODUTO: '+aVet[_nX][01]+'"'+cEOL
			cBuffer += 'B0560,0048,0,1,2,2,70,B,"'+aVet[_nX][02]+'"'+cEOL
			nCount := 0

			cBuffer += 'FE'+cEOL
			cBuffer += 'FR"FORM1"'+cEOL
			cBuffer += 'P1'+cEOL
			cBuffer	+= cEOL+cEOL
		EndIf

		nCount := nCount + 1
  Next nX
	
	//veirificacao da quantidade de etiquetas para terminar a estrutura de comandos
  If(nCount == 2 .OR. nCount == 3)
      cBuffer += 'FE'+cEOL
      cBuffer += 'FR"FORM1"'+cEOL
      cBuffer += 'P1'+cEOL
      cBuffer	+= cEOL+cEOL
  EndIf
	
  If FWRITE(nHandle, cBuffer, Len(cBuffer)) < Len(cBuffer)
        Alert("Erro na gravacao do Arquivo de Etiquetas - Escrita de Buffer")
        Return(nil)
  EndIf
	
	FClose(nHandle)

	ShellExecute( "Open", "C:\Windows\System32\cmd.exe", "/k copy etiquetas.txt LPT1 ", "D:\", 0)

Return(Nil)

