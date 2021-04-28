# Impress�o de etiquetas t�rmicas (ARGOX) direto na porta

## Rotina desenvolvida em ADPVPL para impress�o de etiquetas t�rmicas, modelo do fonte para impressora ARGOX.


### Para outras impressoras, utilize os arquivos de exemplos dispon�veis.

Os arquivos de teste para impressoras t�rmicas s�o:

tstAllegro.txt

tstEltron.txt

tstIntermec.txt

tstZebra.txt


Onde:

- tstAllegro � a linguagem de programa��o datamax; 

- tstEltron � a linguagem de programa��o eltron; 

- tstIntermec � a linguagem de programa��o intermec; 

- tstZebra � a linguagem de programa��o zebra. 



Como Usar:

No prompt de comando do MSDOS, caso a impressora esteja na porta LPT1:
```bash
copy tstZebra.txt LPT1
```

caso a impressora n�o esteja na porta seria, pode compartilhar e realizar o mapeamento utilizando o NETUSE