REPORT /gjaauto/mtj0002.

DATA motor TYPE REF TO /gjaauto/clmt0001.

DATA: gt_code    TYPE STANDARD TABLE OF string WITH DEFAULT KEY,
      gw_logs    TYPE /gjaauto/mttb002,
      lv_program TYPE progname,
      lv_msg     TYPE string,
      lv_word    TYPE string,
      ls_dir     TYPE trdir,
      lv_line    TYPE i.

PARAMETERS:
  p_chave TYPE /gjaauto/mte_chave OBLIGATORY,
  p_code  TYPE flag AS CHECKBOX.

START-OF-SELECTION.

  CREATE OBJECT motor
    EXPORTING
      iv_chave       = p_chave
    EXCEPTIONS
      auto_not_found = 1
      OTHERS         = 2.

  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        MESSAGE 'Automação não encontrada' TYPE 'W' DISPLAY LIKE 'E'.
      WHEN OTHERS.
        MESSAGE 'Erro ao executar automação' TYPE 'W' DISPLAY LIKE 'E'.
    ENDCASE.
  ENDIF.

  UPDATE /gjaauto/mttb001
  SET status = 1, " Em processamento
      chadat = @sy-datum,
      chatim = @sy-uzeit,
      chanam = @sy-uname
  WHERE chave = @p_chave.

  CALL METHOD motor->factory
    RECEIVING
      et_code = gt_code.

  IF p_code EQ abap_true.
    BREAK-POINT.
  ENDIF.

  lv_program = |Z{ p_chave }|.
  TRANSLATE lv_program TO UPPER CASE.

* Limpa programa antigo
  SELECT SINGLE * FROM trdir INTO ls_dir WHERE name = lv_program.
  IF sy-subrc EQ 0.
    DELETE REPORT lv_program.
    COMMIT WORK AND WAIT.
  ENDIF.

* Insere o programa no repositório ABAP
  INSERT REPORT lv_program FROM gt_code.
  COMMIT WORK AND WAIT.

  SELECT SINGLE * FROM trdir INTO ls_dir WHERE name = lv_program.
  ls_dir-uccheck = 'X'.
  SYNTAX-CHECK FOR gt_code MESSAGE lv_msg LINE lv_line WORD lv_word DIRECTORY ENTRY ls_dir.
  IF sy-subrc = 4.
    gw_logs-auto  = p_chave+6(2).
    gw_logs-opera = p_chave+8(3).
    gw_logs-credat = sy-datum.
    gw_logs-cretim = sy-uzeit.
    gw_logs-chave = p_chave.
    gw_logs-message = lv_msg.
    gw_logs-type = 'E'.
    IF lv_msg IS NOT INITIAL.
      INSERT /gjaauto/mttb002 FROM gw_logs.
    ENDIF.
    gw_logs-message = 'Erro de syntax no programa gerado, Impormar equipo AMS.'.
    INSERT /gjaauto/mttb002 FROM gw_logs.
    UPDATE /gjaauto/mttb001 SET status = '3'
     WHERE auto = p_chave+6(2)
       AND opera = p_chave+8(3)
       AND chave = p_chave.
    MESSAGE lv_msg TYPE 'E'.
  ELSE.
    SUBMIT (lv_program) AND RETURN.
    IF sy-subrc NE 0.
      CLEAR gw_logs.
      gw_logs-auto  = p_chave+6(2).
      gw_logs-opera = p_chave+8(3).
      gw_logs-credat = sy-datum.
      gw_logs-cretim = sy-uzeit.
      gw_logs-chave = p_chave.
      gw_logs-message = cl_abap_submit_handling=>get_error_message( ).
      gw_logs-type = 'E'.
      IF gw_logs-message IS NOT INITIAL.
        INSERT /gjaauto/mttb002 FROM gw_logs.
      ENDIF.
      gw_logs-message = 'Erro na execução da operação'.
      INSERT /gjaauto/mttb002 FROM gw_logs.
    ELSE.
      DELETE REPORT lv_program.
    ENDIF.
  ENDIF.
  COMMIT WORK AND WAIT.
