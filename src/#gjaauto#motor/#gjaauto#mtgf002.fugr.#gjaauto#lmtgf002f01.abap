*----------------------------------------------------------------------*
***INCLUDE /GJAAUTO/LMTGF002F01.
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
* FORM: replace_last_comma_with_dot
* Objetivo: Substitui a vírgula final por ponto na última linha
*           de uma tabela interna de strings.
*---------------------------------------------------------------------*
FORM replace_last_comma_with_dot
  TABLES ct_code.

  FIELD-SYMBOLS <lv_line> TYPE string.

  " Pega o índice da última linha
  DATA(lv_last_index) = lines( ct_code ).

  IF lv_last_index > 0.
    READ TABLE ct_code ASSIGNING <lv_line> INDEX lv_last_index.
    IF sy-subrc = 0 AND <lv_line> IS ASSIGNED.
      REPLACE ALL OCCURRENCES OF ',' IN <lv_line> WITH '.'.
    ENDIF.
  ENDIF.

ENDFORM.
