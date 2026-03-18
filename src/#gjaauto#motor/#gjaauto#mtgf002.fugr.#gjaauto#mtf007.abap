FUNCTION /gjaauto/mtf007.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"----------------------------------------------------------------------
  DATA: lt_code     TYPE TABLE OF string,
        lv_program  TYPE progname VALUE 'Z_DYNAMIC_PROGRAM',
        vl_event(5) TYPE c VALUE 'TESTE',
        vl_err_flow TYPE flag.

  REFRESH lt_code.

* Cabeçalho do programa
  APPEND 'REPORT Z_DYNAMIC_PROGRAM.' TO lt_code.

* Rotina principal (poderia ser direto WRITE, mas mantive compatível com seu PERFORM)
  APPEND '  BREAK-POINT.' TO lt_code.

* Insere o programa no repositório ABAP
  INSERT REPORT lv_program FROM lt_code.

  IF sy-subrc = 0.
    WRITE: / 'Programa gerado com sucesso:', lv_program.

    " Agora executa via SUBMIT (poderia chamar o FORM também com PERFORM ... IN PROGRAM)
    SUBMIT (lv_program) AND RETURN.

  ELSE.
    WRITE: / 'Erro ao inserir programa:', sy-subrc.
  ENDIF.

ENDFUNCTION.


*  DATA: lt_code     TYPE TABLE OF string,
*        lv_program  TYPE progname,
*        vl_event(5) TYPE c VALUE 'TESTE',
*        vl_err_flow TYPE flag.
*
*  REFRESH lt_code.
*
*  lv_program = 'Z
*
** Cabeçalho do programa
*  APPEND 'REPORT Z_DYNAMIC_PROGRAM.' TO lt_code.
*
** Rotina principal (poderia ser direto WRITE, mas mantive compatível com seu PERFORM)
*  APPEND '  BREAK-POINT.' TO lt_code.
*
** Insere o programa no repositório ABAP
*  INSERT REPORT lv_program FROM lt_code.
*
*  IF sy-subrc = 0.
*    WRITE: / 'Programa gerado com sucesso:', lv_program.
*
*    " Agora executa via SUBMIT (poderia chamar o FORM também com PERFORM ... IN PROGRAM)
*    SUBMIT (lv_program) AND RETURN.
*
*  ELSE.
*    WRITE: / 'Erro ao inserir programa:', sy-subrc.
*  ENDIF.
