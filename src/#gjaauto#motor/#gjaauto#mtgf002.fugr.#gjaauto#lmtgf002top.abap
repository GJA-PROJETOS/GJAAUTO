FUNCTION-POOL /gjaauto/mtgf002.             "MESSAGE-ID ..

"Status da automação
CONSTANTS:
  c_aguardando TYPE /gjaauto/mte_status VALUE 0,
  c_executando TYPE /gjaauto/mte_status VALUE 1,
  c_completo   TYPE /gjaauto/mte_status VALUE 2,
  c_erro       TYPE /gjaauto/mte_status VALUE 3,
  c_atencao    TYPE /gjaauto/mte_status VALUE 4,
  c_pausado    TYPE /gjaauto/mte_status VALUE 5,
  c_estornado  TYPE /gjaauto/mte_status VALUE 6,
  c_cancelado  TYPE /gjaauto/mte_status VALUE 7,
  c_fila       TYPE /gjaauto/mte_status VALUE 8.


TYPES:
  BEGIN OF ty_fm_declation_vars,
    parameter        TYPE parameter,
    reftype          TYPE likefield,
    paramnat         TYPE /gjaauto/cke_natu_parametro,
    paramtyp         TYPE /gjaauto/cke_tipo_parametro,
    nome_declarado   TYPE char60,
  END OF ty_fm_declation_vars.

TYPES: ty_stringtab TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
* INCLUDE /GJAAUTO/LMTGF002D...              " Local class definition
