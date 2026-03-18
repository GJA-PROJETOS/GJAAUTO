*&---------------------------------------------------------------------*
*& Report /GJAAUTO/EXECUTA_JOB
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /GJAAUTO/EXECUTA_JOB.

DATA: v_taskname(6)   TYPE n VALUE '1',
      v_group         TYPE rzlli_apcl.

  "Executa função que gera documentos no SAP.
  CALL FUNCTION '/GJAAUTO/MTF006'
    STARTING NEW TASK sy-uzeit
*    PERFORMING f_retorno_funcao ON END OF TASK
      EXPORTING
        iv_auto        = 'IN'
        iv_opera       = '100'
        iv_chave       = '250930IN100000000006'
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      resource_failure      = 3.

  BREAK-POINT.
