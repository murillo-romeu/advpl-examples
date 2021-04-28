# Impressão de etiquetas térmicas (ARGOX) direto na porta

## Rotina desenvolvida em ADPVPL para impressão de etiquetas térmicas, modelo do fonte para impressora ARGOX.


### Para outras impressoras, utilize os arquivos de exemplos disponíveis.

Os arquivos de teste para impressoras térmicas são:

tstAllegro.txt

tstEltron.txt

tstIntermec.txt

tstZebra.txt


Onde:

- tstAllegro é a linguagem de programação datamax; 

- tstEltron é a linguagem de programação eltron; 

- tstIntermec é a linguagem de programação intermec; 

- tstZebra é a linguagem de programação zebra. 



Como Usar:

No prompt de comando do MSDOS, caso a impressora esteja na porta LPT1:
```bash
copy tstZebra.txt LPT1
```

caso a impressora não esteja na porta seria, pode compartilhar e realizar o mapeamento utilizando o NETUSE