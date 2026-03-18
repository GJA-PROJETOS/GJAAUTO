" ╔════════════════════════════════════════════════════════════════════╗-
" ║                     MOTOR DE AUTOMAÇÃO                             ║-
" ║ Esse programa/job inicia as automações que estão na fila           ║-
" ╠════════════════════════════════════════════════════════════════════╣-
" ║Autor: Igor O. Bittencourt Moreira                                  ║-
" ║Solicitante: José Alves                                             ║-
" ║Data: 28/05/2025                                                    ║-
" ╚════════════════════════════════════════════════════════════════════╝-
" │                     HISTÓRICO DE MUDANÇAS                          │-
" ╞════╤══════════╤═════════╤══════════╤══════════╤════════════════════╡-
" │NÚM.│   DATA   │  AUTOR  │ REQUEST  │ CHAMADO  │ DESCRIÇÂO          │*
" ╞════╪══════════╪═════════╪══════════╪══════════╪════════════════════╡-
" │0001│24/09/2025│IBMOREIRA│DS4K911392│          │Criação do Programa │-
" ╘════╧══════════╧═════════╧══════════╧══════════╧════════════════════╛-
REPORT /gjaauto/mtj0001.

" ---------------------------------------------------------------
" Objetivo:
" Gerenciar a execução de jobs batch do programa /GJAAUTO/MTJ0002,
" limitando a quantidade de execuções simultâneas de acordo com
" parâmetro configurado na TVARVC (/GJAAUTO/JOB_THREADS_MAX).
" ---------------------------------------------------------------

" Constantes
CONSTANTS c_aguardando    TYPE /gjaauto/mte_status VALUE 0.
CONSTANTS c_param_threads TYPE tvarvc-name         VALUE '/GJAAUTO/MAX_JOB_AUTO'.
CONSTANTS c_default_limit TYPE i                   VALUE 5.

" Variáveis
DATA lv_threads_max TYPE i.
DATA lv_threads_run TYPE i.
DATA lv_free_slots  TYPE i.
DATA lv_jobcount    TYPE tbtcjob-jobcount.

DATA lt_priorizada  TYPE TABLE OF /gjaauto/mttb001.

" ---------------------------------------------------------------
" 1. Obter limite de threads a partir da TVARVC
" ---------------------------------------------------------------
SELECT SINGLE low FROM tvarvc
  WHERE name = @c_param_threads
  INTO @DATA(lv_low).

lv_threads_max = COND #( WHEN sy-subrc = 0 THEN CONV i( lv_low ) ELSE c_default_limit ).

" ---------------------------------------------------------------
" 2. Contar jobs em execução com mesmo nome
" ---------------------------------------------------------------
SELECT COUNT(*) INTO @lv_threads_run
  FROM tbtco
  WHERE jobname LIKE '/GJAAUTO/%'
    AND status     = 'R'. " Running

lv_free_slots = lv_threads_max - lv_threads_run.

" Se não houver slots disponíveis, encerrar.
CHECK lv_free_slots > 0.

" ---------------------------------------------------------------
" 3. Buscar registros da fila de automações pendentes
" ---------------------------------------------------------------
SELECT * FROM /gjaauto/mttb001
  INTO TABLE @DATA(lt_fila)
  WHERE status = @c_aguardando
  ORDER BY chadat, chatim.

CHECK lt_fila IS NOT INITIAL.

" ----------------------------------------------------------------------
" Filtrar e priorizar registros:
" 1º - Registros nunca executados (chadat IS INITIAL)
" 2º - Registros já executados mais antigos (chadat + chatim ASC)
" ----------------------------------------------------------------------
"   4.1. Nunca executados
lt_priorizada =
  VALUE #( BASE lt_priorizada
           FOR wa IN lt_fila
           WHERE ( chadat = '00000000' )
           ( wa ) ).

"   4.2. Já executados
DATA(lt_exec) =
  VALUE #( BASE lt_priorizada
           FOR wa IN lt_fila
           WHERE ( chadat <> '00000000' )
           ( wa ) ).

SORT lt_exec BY chadat
                chatim ASCENDING.

"   4.3. Junta na ordem de prioridade
APPEND LINES OF lt_exec TO lt_priorizada.

"   4.4. Limita ao número de vagas
IF lines( lt_priorizada ) > lv_free_slots.
  DELETE lt_priorizada FROM lv_free_slots + 1 TO lines( lt_priorizada ).
ENDIF.

" ---------------------------------------------------------------
" 5. Disparar jobs para cada automação da fila
" ---------------------------------------------------------------
LOOP AT lt_fila INTO DATA(lw_fila).

  DATA(vl_jobname) = CONV btcjob( |/GJAAUTO/{ lw_fila-chave }| ).

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname  = vl_jobname
    IMPORTING
      jobcount = lv_jobcount
    EXCEPTIONS
      OTHERS   = 1.

  IF sy-subrc <> 0.
    " Log ou tratamento de erro pode ser adicionado aqui
    CONTINUE.
  ENDIF.

  SUBMIT /gjaauto/mtj0002
         WITH p_chave = lw_fila-chave
         USER sy-uname
         VIA JOB vl_jobname
         NUMBER lv_jobcount
         AND RETURN.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobname   = vl_jobname
      jobcount  = lv_jobcount
      strtimmed = 'X'
    EXCEPTIONS
      OTHERS    = 1.

ENDLOOP.
