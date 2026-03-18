FUNCTION /gjaauto/mtf002.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(IV_AUTO) TYPE  /GJAAUTO/CKE_AUTOMACAO
*"     REFERENCE(IV_OPERA) TYPE  /GJAAUTO/CKE_OPERARACAO
*"     REFERENCE(IV_CHAVE) TYPE  /GJAAUTO/MTE_CHAVE
*"----------------------------------------------------------------------

  DATA: wa_mttb001 TYPE /gjaauto/mttb001.

  wa_mttb001-auto   = iv_auto.
  wa_mttb001-opera  = iv_opera.
  wa_mttb001-chave  = iv_chave.
  wa_mttb001-credat = sy-datum.
  wa_mttb001-cretim = sy-uzeit.
  wa_mttb001-crenam = sy-uname.
  wa_mttb001-status = '0'.

  insert /gjaauto/mttb001 from wa_mttb001.

  COMMIT WORK AND WAIT.
ENDFUNCTION.
