FUNCTION /gjaauto/mtf004.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(IV_AUTO) TYPE  /GJAAUTO/CKE_AUTOMACAO
*"     REFERENCE(IV_OPERA) TYPE  /GJAAUTO/CKE_OPERARACAO
*"  EXPORTING
*"     REFERENCE(EV_CHAVE) TYPE  /GJAAUTO/MTE_CHAVE
*"     REFERENCE(EV_NUMERADOR) TYPE  /GJAAUTO/E_NUMERADOR
*"  EXCEPTIONS
*"      NUMBER_RANGE_NOT_FOUND
*"----------------------------------------------------------------------

  " Número gerado
  DATA: lv_num    TYPE /gjaauto/e_numerador,
        lv_snro   TYPE /gjaauto/cktb002-snro,
        lv_snronr TYPE /gjaauto/cktb002-snronr.

  " Recupera dados da operação para obter intervalo numérico
  SELECT SINGLE snro, snronr
    FROM /gjaauto/cktb002
    INTO (@lv_snro, @lv_snronr)
    WHERE auto  = @iv_auto
      AND opera = @iv_opera.

  IF sy-subrc <> 0.
    RAISE number_range_not_found.
  ELSE.
    " Geração do número único (chave primária)
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        object      = lv_snro
        subobject   = iv_auto
        nr_range_nr = lv_snronr
      IMPORTING
        number      = ev_numerador
      EXCEPTIONS
        OTHERS      = 1.

    CONCATENATE sy-datum+2 iv_auto iv_opera ev_numerador INTO ev_chave.
  ENDIF.
ENDFUNCTION.
