FUNCTION /gjaauto/mtf001.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(IV_AUTO) TYPE  /GJAAUTO/CKE_AUTOMACAO
*"     REFERENCE(IV_OPERA) TYPE  /GJAAUTO/CKE_OPERARACAO
*"  EXPORTING
*"     VALUE(EV_CHAVE) TYPE  /GJAAUTO/MTE_CHAVE
*"  TABLES
*"      IT_DATA TYPE  /GJAAUTO/MTTT001
*"  EXCEPTIONS
*"      ERROR_SAVING_INITIAL_DATA
*"----------------------------------------------------------------------

*┌────────────────────────────────────────────────────────────────────┐*
*│ Geração do número único (chave primária)                           │*
*└────────────────────────────────────────────────────────────────────┘*
  CALL FUNCTION '/GJAAUTO/MTF004'
    EXPORTING
      iv_auto  = iv_auto
      iv_opera = iv_opera
    IMPORTING
      ev_chave = ev_chave.

*┌────────────────────────────────────────────────────────────────────┐*
*│ Responsável por salvar os dados iniciais nas tabelas específicas   │*
*│ definidas pelas regras de mapeamento.                              │*
*└────────────────────────────────────────────────────────────────────┘*
  CALL FUNCTION '/GJAAUTO/MTF005'
    EXPORTING
      iv_auto  = iv_auto
      iv_opera = iv_opera
      iv_chave = ev_chave
    TABLES
      it_data  = it_data
    EXCEPTIONS
      OTHERS   = 1.

  IF sy-subrc NE 0.
    RAISE error_saving_initial_data.
  ENDIF.

*┌────────────────────────────────────────────────────────────────────┐*
*│ Geração do Header da automação                                     │*
*└────────────────────────────────────────────────────────────────────┘*
  CALL FUNCTION '/GJAAUTO/MTF002'
    EXPORTING
      iv_auto  = iv_auto
      iv_opera = iv_opera
      iv_chave = ev_chave.


ENDFUNCTION.
