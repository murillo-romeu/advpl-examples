#INCLUDE "MSOLE.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} RIMPSA
Romaneio personalizado Pituta.

@author Murillo Romeu - murillo.romeu@totvs.com.br
@since 01/07/2014
/*/
//--------------------------------------------------------------
User Function RIMPSA(lAuto)
	Local cPerg		:= 'RPROMA'
	Local oDlg
	Local aArea		:= GetArea()
	DEFAULT lAuto	:= .F.

	CriaSx1(cPerg)

	If !lAuto
		Pergunte(cPerg,.T.)

		//Tela inicial para gercao do relatorio
		DEFINE MSDIALOG oDlg TITLE OemToAnsi("SOLICITAÇÃO AO ARMAZÉM - PROLUMINAS") FROM 000,000 TO 200,400 PIXEL
			@005,005 TO 095,195 OF oDlg PIXEL
			@010,020 Say " Este programa ira gerar o relatório de SOLICITAÇÂO"	OF oDlg PIXEL
			@018,020 Say " AO ARMAZÉM de acordo com os parâmetros informados."	OF oDlg PIXEL
	
			DEFINE SBUTTON FROM 070, 030 TYPE 1 ACTION (MsAguarde({|| RIMPSA01() }, 'Processando...', "Aguarde enquanto o arquivo é gerado", .T.),oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM 070, 070 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM 070, 110 TYPE 5 ACTION (Pergunte(cPerg,.T.)) ENABLE OF oDlg

		ACTIVATE DIALOG oDlg CENTERED
	Else
		MV_PAR01 := SCP->CP_NUM
		RIMPSA01()
	EndIf
	RestArea(aArea)
Return

//--------------------------------------------------------------
/*/{Protheus.doc} PRelInvPP
Inicia a impressao do relatorio.

@author Murillo Romeu - murillo.romeu@totvs.com.br
@since 26/06/2014
/*/
//--------------------------------------------------------------
Static Function RIMPSA01

	Local cRel			:= ''
	Local cTime			:= Time()
	Private cPath 		:= ""
	Private oPrn    	:= nil
	Private lPRIMA 		:= .T.
	Private nFimPg		:= 780
	Private nDirPg		:= 575
	Private nTextIni	:= 020
	Private nEspaco		:= 010
	Private nEspaco2	:= 020
	Private nPagina		:= 0
	Private oFont06		:= TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)
	Private oFont06N 	:= TFont():New("Courier New",06,06,,.T.,,,,.T.,.F.)
	Private oFont08	 	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	Private oFont08N 	:= TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)
	Private oFont09	 	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
	Private oFont09N 	:= TFont():New("Courier New",09,09,,.T.,,,,.T.,.F.)
	Private oFont10	 	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	Private oFont10N	:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
	Private oFont11	 	:= TFont():New("Courier New",11,11,,.F.,,,,.T.,.F.)
	Private oFont11N 	:= TFont():New("Courier New",11,11,,.T.,,,,.T.,.F.)
	Private oFont12  	:= TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)
	Private oFont12N 	:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)
	Private oFont14	 	:= TFont():New("Courier New",14,14,,.F.,,,,.T.,.F.)
	Private oFont14N 	:= TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)
	Private oFont16	 	:= TFont():New("Courier New",16,16,,.F.,,,,.T.,.F.)
	Private oFont16N 	:= TFont():New("Courier New",16,16,,.T.,,,,.T.,.F.)
	Private oFont16NI 	:= TFont():New("Courier New",16,16,,.T.,,,,.T.,.T.)
	Private oFont18	 	:= TFont():New("Courier New",18,18,,.F.,,,,.T.,.F.)
	Private oFont18N 	:= TFont():New("Courier New",18,18,,.T.,,,,.T.,.F.)
	Private oFont20	 	:= TFont():New("Courier New",20,20,,.F.,,,,.T.,.F.)
	Private oFont20N 	:= TFont():New("Courier New",20,20,,.T.,,,,.T.,.F.)

	wnrel := FunName()

	cPath := cGetFile(,'Selecione o Local Para Salvar o Relatorio',1,,.F.,nOR(GETF_LOCALHARD,GETF_LOCALFLOPPY,GETF_RETDIRECTORY ),.F.,.T.)

	If AllTrim(cPath) == ''
		Return()
	EndIf

	//dbSelectArea('DTX')
	//DTX->(dbSetOrder(1))
	//DTX->(dbGoTop())
	//If !DTX->(dbSeek(xFilial('DTX') + MV_PAR01))
	//	Alert('Manifesto informado não foi localizado!')
	//	Return()
	//EndIf

	cHora := SUBSTR(cTime, 1, 2) // Resultado: 10
	cMinutos := SUBSTR(cTime, 4, 2) // Resultado: 37
	cSegundos := SUBSTR(cTime, 7, 2) // Resultado: 17

	cRel := DToS(Date())+cHora+cMinutos+cSegundos

	//Inicio do lay-out / impressao
	lPreview := .T.
	lAdjustToLegacy := .F.
	lDisableSetup  := .T.

	oPrn := FWMSPrinter():New(cRel+".rel",6,lAdjustToLegacy,,lDisableSetup)

	//Abre tela de Definicoes de Impressora
	//Define o tamanho do papel
	oPrn:SetResolution(72)
	oPrn:SetPortrait()
	oPrn:SetPaperSize(9)
	oPrn:SetMargin(00,00,00,00)
	oPrn:cPathPDF := cPath

	RIMPSA02()

	oPrn:EndPage()
	oPrn:Preview()

Return()

//--------------------------------------------------------------
/*/{Protheus.doc} RIMPSA02
Tratamento do spool.

@author Murillo Romeu - murillo.romeu@totvs.com.br
@since 26/06/2014
/*/
//--------------------------------------------------------------
Static Function RIMPSA02

	RIMPSA03()

	//Descarrega o Spool de impressao
	Ms_Flush()

Return()

//--------------------------------------------------------------
/*/{Protheus.doc} RelInvPPB
Impressão dos dados do relatorio.

@author Murillo Romeu - murillo.romeu@totvs.com.br
@since 26/06/2014
/*/
//--------------------------------------------------------------
Static Function RIMPSA03
	Local cQry 			:= ""
	Local cProduto		:= ""
	Local nLinPadrao	:= 140
	Local nLin 			:= nLinPadrao
	Local nCol01 		:= 000//ok
	Local nCol02 		:= 050//ok
	Local nCol03 		:= 200//ok
	Local nCol04 		:= 250//ok
	Local nCol05 		:= 275//ok
	Local nCol06	 	:= 300//ok
	Local nCol07 		:= 350//ok
	Local nCol08 		:= 375//ok
	Local nCol09 		:= 420//ok
	Local nCol10 		:= 475//ok
	Local nCnt			:= 0
	Local nIniLin		:= nLinPadrao-7
	Local cRemete		:= ''
	Local cDestino		:= ''
	Local cMunicipio	:= ''
	Local nTPeso		:= 0
	Local nTQuant		:= 0
	Local nTValor		:= 0

	cQry := ""
	cQry += " SELECT DTC.DTC_DOC, "
//	cQry := ChangeQuery(cQry)
//	TCQUERY cQry Alias 'TMP1' New

	//Verifica se foram encontrados dados
/*	If TMP1->(Eof())
		MsgAlert('Não foram encontrados dados para os parametros informados.')
		TMP1->(dbCloseArea())
		Return()
	EndIf
  */;
	nLin := 1000

	//Immpressao dos dados do relatorio
//	While !TMP1->(Eof())

	//	cRemete := AllTrim(Posicione('SA1',1,xFilial('SA1') + TMP1->(DTC_CLIREM+DTC_LOJREM),'A1_NREDUZ'))
//		cDestino := AllTrim(Posicione('SA1',1,xFilial('SA1') + TMP1->(DTC_CLIDES+DTC_LOJDES),'A1_NREDUZ'))
  //		cMunicipio := AllTrim(AllTrim(Posicione('SA1',1,xFilial('SA1') + TMP1->(DTC_CLIDES+DTC_LOJDES),'A1_MUN')))


		If nLin >= nFimPg
			XCabec()

			nLin := nLinPadrao
			
			oPrn:Line(nIniLin,010,nIniLin,580)
			
			oPrn:Say(nLin,nTextIni+nCol01,'Código'			,oFont09N)
	  		oPrn:Say(nLin,nTextIni+nCol02,'Produto'			,oFont09N)
			oPrn:Say(nLin,nTextIni+nCol03,'Qtd.1aUM'		,oFont09N)
			oPrn:Say(nLin,nTextIni+nCol04,'1aUM'	  		,oFont09N)
			oPrn:Say(nLin,nTextIni+nCol05,'Arm.'			,oFont09N)
			oPrn:Say(nLin,nTextIni+nCol06,'Qtd.2aUM'		,oFont09N)
			oPrn:Say(nLin,nTextIni+nCol07,'2aUM'			,oFont09N)
			oPrn:Say(nLin,nTextIni+nCol08,'Endereco'		,oFont09N)
			oPrn:Say(nLin,nTextIni+nCol09,'Dt/Hr Aprov.'	,oFont09N)
			oPrn:Say(nLin,nTextIni+nCol10,'Aprovador'		,oFont09N)

			nLin += nEspaco
			oPrn:Line(nLin ,010,nLin ,580)
			nLin += nEspaco
		EndIf

//		nTPeso	+= TMP1->DT6_PESO
	  //	nTQuant	+= TMP1->DT6_QTDVOL
  //		nTValor	+= TMP1->DT6_VALMER

  //		oPrn:Say(nLin,nTextIni+nCol01-10,AllTrim(SubStr(TMP1->DTC_DOC,3,10))			,oFont12)
//		oPrn:Say(nLin,nTextIni+nCol02,TMP1->DTC_NUMNFC									,oFont12)
 //		oPrn:Say(nLin,nTextIni+nCol03,SubStr(TMP1->X5_DESCRI,1,7)						,oFont12)
  //		oPrn:Say(nLin,nTextIni+nCol04-2,Transform(TMP1->DT6_PESO,'@E 99,999.99')		,oFont11)
//		oPrn:Say(nLin,nTextIni+nCol05,AllTrim(Transform(TMP1->DT6_QTDVOL,'@E 9999'))	,oFont12)
 //		oPrn:Say(nLin,nTextIni+nCol06,Transform(TMP1->DT6_VALMER,'@E 999,999.99')		,oFont12)
  //		oPrn:Say(nLin,nTextIni+nCol07,AllTrim(UPPER(SubStr(cRemete,1,11)))				,oFont12)
//		oPrn:Say(nLin,nTextIni+nCol08,AllTrim(UPPER(SubStr(cDestino,1,13)))				,oFont12)
 //		oPrn:Say(nLin,nTextIni+nCol09,AllTrim(AllTrim(Posicione('SA1',1,xFilial('SA1') + TMP1->(DTC_CLIDES+DTC_LOJDES),'A1_EST')))	,oFont12)
  //		oPrn:Say(nLin,nTextIni+nCol10,AllTrim(UPPER(SubStr(cMunicipio,1,16)))			,oFont12)

	//	If Len(cRemete) > 13 .or. Len(cDestino) > 13 .or. Len(cMunicipio) > 16
//			nLin += nEspaco
 //			oPrn:Say(nLin,nTextIni+nCol07,AllTrim(UPPER(SubStr(cRemete,12,11)))			,oFont12)
  //			oPrn:Say(nLin,nTextIni+nCol08,AllTrim(UPPER(SubStr(cDestino,14,13)))		,oFont12)
//			oPrn:Say(nLin,nTextIni+nCol10,AllTrim(UPPER(SubStr(cMunicipio,17,16)))		,oFont12)
 //		EndIf

		nLin += 1
		oPrn:Line(nLin ,010,nLin ,580)
		nLin += nEspaco
		If nLin >= nFimPg
			
			oPrn:Line(nIniLin,(nTextIni+nCol02)-02,nLin-nEspaco,(nTextIni+nCol02)-02)
			oPrn:Line(nIniLin,(nTextIni+nCol03)-02,nLin-nEspaco,(nTextIni+nCol03)-02)
			oPrn:Line(nIniLin,(nTextIni+nCol04)-02,nLin-nEspaco,(nTextIni+nCol04)-02)
			oPrn:Line(nIniLin,(nTextIni+nCol05)-02,nLin-nEspaco,(nTextIni+nCol05)-02)
			oPrn:Line(nIniLin,(nTextIni+nCol06)-02,nLin-nEspaco,(nTextIni+nCol06)-02)
			oPrn:Line(nIniLin,(nTextIni+nCol07)-02,nLin-nEspaco,(nTextIni+nCol07)-02)
			oPrn:Line(nIniLin,(nTextIni+nCol08)-02,nLin-nEspaco,(nTextIni+nCol08)-02)
			oPrn:Line(nIniLin,(nTextIni+nCol09)-02,nLin-nEspaco,(nTextIni+nCol09)-02)
			oPrn:Line(nIniLin,(nTextIni+nCol10)-02,nLin-nEspaco,(nTextIni+nCol10)-02)
		EndIf


  //		TMP1->(dbSkip())
//	EndDo

	//Totalizadores
 //	TMP1->(dbCloseArea())

	oPrn:Line(nIniLin,(nTextIni+nCol02)-02,nLin-nEspaco,(nTextIni+nCol02)-02)
	oPrn:Line(nIniLin,(nTextIni+nCol03)-02,nLin-nEspaco,(nTextIni+nCol03)-02)
	oPrn:Line(nIniLin,(nTextIni+nCol04)-02,nLin-nEspaco,(nTextIni+nCol04)-02)
	oPrn:Line(nIniLin,(nTextIni+nCol05)-02,nLin-nEspaco,(nTextIni+nCol05)-02)
	oPrn:Line(nIniLin,(nTextIni+nCol06)-02,nLin-nEspaco,(nTextIni+nCol06)-02)
	oPrn:Line(nIniLin,(nTextIni+nCol07)-02,nLin-nEspaco,(nTextIni+nCol07)-02)
	oPrn:Line(nIniLin,(nTextIni+nCol08)-02,nLin-nEspaco,(nTextIni+nCol08)-02)
	oPrn:Line(nIniLin,(nTextIni+nCol09)-02,nLin-nEspaco,(nTextIni+nCol09)-02)
	oPrn:Line(nIniLin,(nTextIni+nCol10)-02,nLin-nEspaco,(nTextIni+nCol10)-02)

//	oPrn:Say(nLin,nTextIni+nCol03,'Total'								,oFont12N)
   //	oPrn:Say(nLin,nTextIni+nCol04-2,Transform(nTPeso,'@E 99,999.99')	,oFont11N)
//	oPrn:Say(nLin,nTextIni+nCol05-3,AllTrim(Transform(nTQuant,'@E 9999'))	,oFont12N)
 //	oPrn:Say(nLin,nTextIni+nCol06,Transform(nTValor,'@E 999,999.99')	,oFont12N)
	nLin += 3
//	oPrn:Line(nLin ,010,nLin ,580)
 //	oPrn:Line(nIniLin,(nTextIni+nCol03)-05,nLin,(nTextIni+nCol03)-05)
  //	oPrn:Line(nIniLin,(nTextIni+nCol04)-05,nLin,(nTextIni+nCol04)-05)
//	oPrn:Line(nIniLin,(nTextIni+nCol05)-05,nLin,(nTextIni+nCol05)-05)
//	oPrn:Line(nIniLin,(nTextIni+nCol06)-05,nLin,(nTextIni+nCol06)-05)
//	oPrn:Line(nIniLin,(nTextIni+nCol07)-05,nLin,(nTextIni+nCol07)-05)

   //	dbSelectArea('DTY')
	//DTY->(dbSetOrder(2))//DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
//	DTY->(dbGoTop())

//	If DTY->(dbSeek(xFilial('DTY') + DTX->DTX_FILORI + DTX->DTX_VIAGEM))
 //		cRecFrete := DTY->DTY_NUMCTC
 //	Else
  //		cRecFrete := ''
//	EndIf

//	dbSelectArea('DA3')
 //	DA3->(dbSetOrder(1))//DA3_FILIAL+DA3_COD
 //	DA3->(dbGoTop())

//	If DA3->(dbSeek(xFilial('DA3') + DTX->DTX_CODVEI))
//		cProprietario := Posicione('SA2',1,xFilial('SA2') + DA3->DA3_CODFOR + DA3->DA3_LOJFOR,'A2_NOME')
//		cCNPJProp := Posicione('SA2',1,xFilial('SA2') + DA3->DA3_CODFOR + DA3->DA3_LOJFOR,'A2_CGC')
//	Else
//		cProprietario := ''
//		cCNPJProp := ''
 //	EndIf
/*
	dbSelectArea('DA4')
	DA4->(dbSetOrder(1))//DA4_FILIAL+DA4_COD
	DA4->(dbGoTop())

	If DA4->(dbSeek(xFilial('DA4') + DTX->DTX_XCODMO))
		cMotorista := DA4->DA4_NOME
	Else
		cMotorista := ''
	EndIf

	nValorOpera := 0
  */
	If nLin+80 >= nFimPg
		XCabec()

		nLin := nLinPadrao

	EndIf

	nLin += nEspaco*2
	oPrn:Say(nLin,nTextIni+nCol01,'Separado por: ____________________________ '	  		,oFont12N)
	oPrn:Say(nLin,nTextIni+nCol04,'Data - Hora: ______/_____/________ - _____:_____'	,oFont12N)

	nLin += nEspaco*2

	oPrn:Say(nLin,nTextIni+nCol01,'Entregue por: ____________________________ '	  		,oFont12N)
	oPrn:Say(nLin,nTextIni+nCol04,'Data - Hora: ______/_____/________ - _____:_____'	,oFont12N)

	nLin += nEspaco*2
	
	oPrn:Say(nLin,nTextIni+nCol01,'Recebido por: ____________________________ '	   		,oFont12N)
	oPrn:Say(nLin,nTextIni+nCol04,'Data - Hora: ______/_____/________ - _____:_____'	,oFont12N)
	
Return()

//--------------------------------------------------------------
/*/{Protheus.doc} XCabec
Montagem do cabecaho do relaorio.

@author Murillo Romeu - murillo.romeu@totvs.com.br
@since 26/06/2014
/*/
//--------------------------------------------------------------
Static Function XCabec()

	Local cBitMap	:= '\logoMail.jpg'

	nPagina++

	If lPRIMA
		oPrn:StartPage()
		lPRIMA := .F.
	Else
		oPrn:EndPage()
		oPrn:StartPage()
	EndIf

	oPrn:Box(010,010,820,580,"-2")
	nLinTex := 020
	oPrn:SayBitmap(nLinTex-5,nLinTex-5,cBitMap,159/3,114/3)
	nLinTex := 023
	oPrn:Say(nLinTex,080,AllTrim(SM0->M0_NOMECOM),oFont16NI)
	nLinTex+=nEspaco
	oPrn:Say(nLinTex,080,'CNPJ: '+AllTrim(Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')) + ' I.E.: ' + AllTrim(SM0->M0_INSC),oFont12N)
	nLinTex+=nEspaco
	oPrn:Say(nLinTex,080,AllTrim(SM0->M0_ENDCOB) + ' - CEP: '+ Transform(SM0->M0_CEPCOB,'@R 99.999-999') + ' - ' + AllTrim(SM0->M0_CIDCOB) + ' - ' + AllTrim(SM0->M0_ESTCOB),oFont12N)
	nLinTex+=nEspaco
	oPrn:Line(nLinTex,010,nLinTex,580)
	nLinTex+=nEspaco
	nLinTex+=nEspaco	
	
	oPrn:Say(nLinTex,210,"SOLICITAÇÃO AO ARMAZÉM",oFont16NI)
	nLinTex+=nEspaco
	nLinTex+=nEspaco
	oPrn:Say(nLinTex,020,'Resquisição Nº: '+'123456',oFont12N)
	nLinTex+=nEspaco+5
	oPrn:Say(nLinTex,020,'Solicitante: ',oFont12N)
	nLinTex+=nEspaco+5
	oPrn:Say(nLinTex,020,'Data: ' +DToC(Date())+ '    Hora: '+Time(),oFont12N)

	
	nLinTex := 810
	oPrn:Line(nLinTex,010,nLinTex,580)
	nLinTex+=07
	oPrn:Say(nLinTex,012, 'Emitido em: '+DToC(Date()) + ' - ' + Time(),oFont08)
	oPrn:Say(nLinTex,250, 'PROLUMINAS',oFont08)
	oPrn:Say(nLinTex,526, 'Página:  '+StrZero(nPagina,3),oFont08)

Return()

Static Function CriaSX1(cGrpPerg)

	Local aHelpPor := {} //help da pergunta

	//Pedido de?
	aHelpPor := {}
	AADD(aHelpPor,"Indique o PEDIDO INICIAL  ")
	AADD(aHelpPor,"a ser utilizado.          ")

	PutSx1(cGrpPerg,"01","Pedido de?","a","a","MV_CH1","C",TamSX3("C5_NUM")[1],0,0,"G","","SC5","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")

	//Pedido ate?
	aHelpPor := {}
	AADD(aHelpPor,"Indique o PEDIDO FINAL   ")
	AADD(aHelpPor,"a ser utilizado.     	")

Return