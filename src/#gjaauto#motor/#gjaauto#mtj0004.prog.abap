*╔════════════════════════════════════════════════════════════════════╗*
*║                     MOTOR DE AUTOMAÇÃO                             ║*
*║ Esse job apaga as automações que ficaram no banco de códigos       ║*
*╠════════════════════════════════════════════════════════════════════╣*
*║Autor: Igor O. Bittencourt Moreira                                  ║*
*║Solicitante: José Alves                                             ║*
*║Data: 12/02/2025                                                    ║*
*╚════════════════════════════════════════════════════════════════════╝*
*│                     HISTÓRICO DE MUDANÇAS                          │*
*╞════╤══════════╤═════════╤══════════╤══════════╤════════════════════╡*
*│NÚM.│   DATA   │  AUTOR  │ REQUEST  │ CHAMADO  │ DESCRIÇÂO          │*
*╞════╪══════════╪═════════╪══════════╪══════════╪════════════════════╡*
*│0001│12/02/2025│IBMOREIRA│DS4K916358│          │Criação do Programa │*
*╘════╧══════════╧═════════╧══════════╧══════════╧════════════════════╛*
REPORT /gjaauto/mtj0004.

DATA vl_date TYPE sy-datum.
DATA duration TYPE psen_duration.

SELECT SINGLE low
  FROM tvarvc
  INTO @DATA(vl_dias)
  WHERE name EQ '/GJAAUTO/AUTO_CLEANUP_DAYS'.

duration-durdd = COND psen_durdd( WHEN sy-subrc EQ 0 THEN vl_dias ELSE 15 ).

CALL FUNCTION 'HR_99S_DATE_ADD_SUB_DURATION'
  EXPORTING
    im_date     = sy-datum
    im_operator = '-'
    im_duration = duration
  IMPORTING
    ex_date     = vl_date.

SELECT chave
  FROM /gjaauto/mttb001
  INTO TABLE @DATA(lt_chaves)
 WHERE credat < @vl_date.

CHECK lt_chaves IS NOT INITIAL.

LOOP AT lt_chaves INTO DATA(vl_chave).
  DATA(vl_report) = CONV progname( |Z{ vl_chave-chave }| ).
  DELETE REPORT vl_report.
ENDLOOP.

COMMIT WORK AND WAIT.
