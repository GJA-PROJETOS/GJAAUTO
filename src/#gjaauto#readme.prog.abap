REPORT /gjaauto/readme.

*-----------------------------------------------------------------------
* Padrão de Nomenclatura para Objetos do Projeto GJAAUTO
*-----------------------------------------------------------------------

* Os objetos que fazem parte do GJAAUTO seguirão o padrão abaixo:

* Namespace: /GJAAUTO/ (Já existe e já está definido)

* Tabela:         /GJAAUTO/XXTNNN      - Ex.: /GJAAUTO/CTT001
* Estrutura:      /GJAAUTO/XXSNNN      - Ex.: /GJAAUTO/CTS001
* Elemento:       /GJAAUTO/XXENNN      - Ex.: /GJAAUTO/CTE001
* Domínio:        /GJAAUTO/XXDNNN      - Ex.: /GJAAUTO/CTD001
* Grupo de Função:/GJAAUTO/XXGFNNN     - Ex.: /GJAAUTO/CTGF001
* Função:         /GJAAUTO/XXFNNN      - Ex.: /GJAAUTO/CTF001
* RFC:            /GJAAUTO/XXRFCNNN    - Ex.: /GJAAUTO/CTRFC001
* Programa:       /GJAAUTO/XXNNN       - Ex.: /GJAAUTO/CT001
* Module Pool:    /GJAAUTO/SAPMXXNNN   - Ex.: /GJAAUTO/SAPMCT001
* Enhancement:    /GJAAUTO/XXENHNNN    - Ex.: /GJAAUTO/CTENH001
* Classe/Interface:/GJAAUTO/XXCLNNN    - Ex.: /GJAAUTO/CTCL001
* Smartform:      /GJAAUTO/XXSFNNN     - Ex.: /GJAAUTO/CTSF001

* OBS.:
* XX   - Módulo do Projeto (CT, RT, AT, etc.)
* NNN  - Sequência Numérica

*-----------------------------------------------------------------------
* Objetos fora do escopo GJAAUTO seguirão o padrão abaixo:
*-----------------------------------------------------------------------

* Tabela:          ZXXTNNN       - Ex.: ZMMT001
* Elemento:        ZXXENNN       - Ex.: ZMME001
* Domínio:         ZXXDNNN       - Ex.: ZMMD001
* Grupo de Função: ZXXGFNNN      - Ex.: ZMMGF001
* Função:          ZXXFNNN       - Ex.: ZMMF001
* RFC:             ZXXRFCNNN     - Ex.: ZMMRFC001
* Programa:        ZXXNNN        - Ex.: ZMM001
* Module Pool:     SAPMZXXNNN    - Ex.: SAPMZMM001
* Enhancement:     ZXXENHNNN     - Ex.: ZMMENH001

* OBS.:
* XX   - Módulo SAP padrão (MM, SD, FI, PM, etc.)
* NNN  - Sequência Numérica

*-----------------------------------------------------------------------
* Siglas de Módulos GJAAUTO
*-----------------------------------------------------------------------

* RM - Romaneio
* AM - Armazenagem
* RO - Royalties
* CK - Cockpit
* DM - Dados Mestres
* RE - Relatórios
* GQ - Gestão de Quebras
* GC - Gestão de Contratos
* GI - Gestão de Insumos
* GF - Gestão Fiscal
* CC - Controle de Créditos
* GT - Gestão de Transportes
* GP - Gestão Pecuária
*-----------------------------------------------------------------------

* Numeradores SNRO
*DATA: vl_num TYPE /gjaauto/e_numerador.
*
*CALL FUNCTION 'NUMBER_GET_NEXT'
*  EXPORTING
*    object      = 'ZAUTO' " Objeto do Numerador
*    subobject   = 'IN' " Código da automação
*    nr_range_nr = '01' " sequencial de criaçao da operação
*  IMPORTING
*    number      = vl_num.

*STVARV - Variáveis do produto
