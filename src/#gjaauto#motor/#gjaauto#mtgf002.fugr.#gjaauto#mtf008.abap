FUNCTION /GJAAUTO/MTF008.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(IV_CHAVE) TYPE  /GJAAUTO/MTE_CHAVE
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

  DATA: lt_code           TYPE TABLE OF string,
        lt_code_formatted TYPE TABLE OF string.

  " Seleciona header da automacao
  SELECT SINGLE * FROM /gjaauto/mttb001
    INTO @DATA(lw_mttb001)
    WHERE auto  = @iv_chave+6(2)
      AND opera = @iv_chave+8(3)
      AND chave = @iv_chave.
*     AND (
*            status EQ @c_aguardando OR
*            status EQ @c_fila
*         )

  IF sy-subrc <> 0.
    RAISE NOT_FOUND.
  ENDIF.

  " Define status como em execucao
  lw_mttb001-status = c_executando.
  UPDATE /gjaauto/mttb001 FROM lw_mttb001.
  COMMIT WORK AND WAIT.

ENDFUNCTION.
