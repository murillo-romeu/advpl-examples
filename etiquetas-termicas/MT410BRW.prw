/*/{Protheus.doc} MT410BRW
Este ponto de entrada � chamado antes da apresenta��o da mbrowse.
Pedido de venda
@type function
@version 1.0
@author Murillo Romeu - murillosi@gmail.com
@since 28/04/2021
@see https://tdn.totvs.com/display/public/PROT/MT410BRW
@return return_type, return_description
/*/
User Function MT410BRW

  //impress�o de etiqueta do pedido de venda (impressora t�rmica)
	aAdd(aRotina,{ OemToAnsi("Etiquetas"),"U_F3SR001" ,0,9})

Return()
