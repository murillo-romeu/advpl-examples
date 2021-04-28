#include "REPORT.CH"
#include "PROTHEUS.CH"    
#include "TOPCONN.CH"    

/*/{Protheus.doc} F3SR002
Listagem de clientes
Modelo de relatório simples, utilizando apenas uma consulta SQL, e uma seção
@type function
@version 1.0
@author Murillo Romeu - murillosi@gmail.com
@since 28/04/2021
/*/
User Function F3SR002
	Local cPergPar	:= 'F3SR002'
	Local oReport
  Local aPergs    := {}

  Local cCodDe    := Space(6)
  Local cCodAte   := Space(6)
	
  aAdd(aPergs, {1, "Cliente De",  cCodDe,  "", ".T.", "SA1", ".T.", 80,  .F.})
  aAdd(aPergs, {1, "Cliente Até", cCodAte, "", ".T.", "SA1", ".T.", 80,  .T.})

  If !ParamBox(aPergs, 'Informe os parâmetros para impressão do relatório.')
    Return()
  EndIf

	oReport := fReport(cPergPar)
	oReport:PrintDialog()

Return   

/*/{Protheus.doc} fReport
Preparação do relatório
@type function
@version 1.0
@author Murillo Romeu - murillosi@gmail.com
@since 28/04/2021
@param cPergPar, character, nome do relatorio
/*/
Static Function fReport(cPergPar)

	Local oReport
	Local oSection1
	Local cAlias1   := GetNextAlias()
	Private aOrd 	  := {'Código + Loja','Nome Fantasia','Razão Social','CNPJ'}
	
	//Definição do relatório
	DEFINE REPORT oReport ;
	NAME 'F3SR002' ;
	TITLE 'Listagem de Clientes';
	PARAMETER cPergPar ;
	ACTION {|oReport| f003( oReport,cAlias1)} ; 
	DESCRIPTION 'Listagem de Clientes'

	//Impressão formato paisagem
	oReport:SetLandScape() 		//oReport:SetPortrait()
	
	//Secao 1
	DEFINE SECTION oSection1 OF oReport TITLE 'Listagem de Clientes' TABLES 'SA1' ORDERS aOrd

	//Campos da secao 1
	DEFINE CELL NAME 'A1_COD'	    OF oSection1 ALIAS 'SA1'
	DEFINE CELL NAME 'A1_LOJA'	  OF oSection1 ALIAS 'SA1'
	DEFINE CELL NAME 'A1_NOME'		OF oSection1 ALIAS 'SA1'
	DEFINE CELL NAME 'A1_NREDUZ'	OF oSection1 ALIAS 'SA1'
	DEFINE CELL NAME 'A1_CGC'	    OF oSection1 ALIAS 'SA1'
	
	TRFunction():New(oSection1:Count('A1_COD'),NIL,'COUNT')
	oSection1:SetTotalInLine(.T.)
	
Return oReport   

/*/{Protheus.doc} f003
Processamento do relatório
@type function
@version 1.0
@author Murillo Romeu - murillo@sysconsulting.com.br - murillosi@gmail.com
@since 28/04/2021
@param oReport, object, param_description
@param cAlias1, character, param_description
@return return_type, return_description
/*/
Static Function f003(oReport,cAlias1)

	Local oSection1 := oReport:Section(1)	//Objeto secao 1 do relatorio (Produto)   
	Local cQuery	:= ""					//Filtros variáveis da query  
	Local nOrdem	:= oSection1:GetOrder()
	Local cOrdem 	:= '' 

	//	Private aOrd 	  := {'Código + Loja','Nome Fantasia','Razão Social','CNPJ'}

	Do Case
		Case nOrdem == 1  // Código + Loja
		     cOrdem := '%SA1.A1_COD,SA1.A1_LOJA%'
		Case nOrdem == 2  // Nome Fantasia
		     cOrdem := '%SA1.A1_NREDUZ%'
		Case nOrdem == 3  // Razão Social
		     cOrdem := '%SA1.A1_NOME%'
		Case nOrdem == 4  // CNPJ
		     cOrdem := '%SA1.A1_CGC%'
	EndCase
	
	//Secao 1
	//Monta filtros da query
	cQuery := ""
	cQuery += "	SA1.A1_COD BETWEEN !MV01! AND !MV02! "
	
	//Ajusta query
	cQuery := StrTran(cQuery,'!MV01!' ,ValToSql(MV_PAR01))
	cQuery := StrTran(cQuery,'!MV02!' ,ValToSql(MV_PAR02))

	cQuery := "%" + cQuery + "%"

	//Cria query
	Begin Report Query oSection1
		BeginSQL Alias cAlias1  
	
			SELECT SA1.A1_COD, 
				SA1.A1_LOJA,
				SA1.A1_NOME, 
				SA1.A1_NREDUZ, 
				SA1.A1_CGC
			FROM %Table:SA1% SA1
			WHERE SA1.%NotDel% 
				AND %exp:cQuery%
			ORDER BY %exp:cOrdem% 
		EndSql			
	End Report Query oSection1 
	
	//Efetua impressão   
	oSection1:Print()  

Return(.T.)
