" ╔════════════════════════════════════════════════════════════════════╗
" ║DOWNLOAD e UPLOAD DE CONFIGURAÇÕES DO COCKPIT                       ║
" ╠════════════════════════════════════════════════════════════════════╣
" ║Autor: Igor O. Bittencourt Moreira                                  ║
" ║Data: 01/02/2025                                                    ║
" ╚════════════════════════════════════════════════════════════════════╝
" │                     HISTÓRICO DE MUDANÇAS                          │
" ╞════╤══════════╤═════════╤══════════╤══════════╤════════════════════╡
" │NÚM.│   DATA   │  AUTOR  │ REQUEST  │ CHAMADO  │ DESCRIÇÂO          │
" ╞════╪══════════╪═════════╪══════════╪══════════╪════════════════════╡
" │0001│01/02/2025│IBMOREIRA│DS4K916358│XXXXXXXXXX│ Criação            │
" ╘════╧══════════╧═════════╧══════════╧══════════╧════════════════════╛
REPORT /gjaauto/ckr0001.

SELECTION-SCREEN BEGIN OF BLOCK b001 WITH FRAME TITLE TEXT-001.
  PARAMETERS p_auto  TYPE /gjaauto/cke_automacao MATCHCODE OBJECT /gjaauto/ck_automacao OBLIGATORY.
  PARAMETERS p_opera TYPE /gjaauto/cke_operaracao MATCHCODE OBJECT /gjaauto/ck_operacao OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b001.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK b002 WITH FRAME TITLE TEXT-002.
  PARAMETERS: download RADIOBUTTON GROUP opt1 DEFAULT 'X',
              upload   RADIOBUTTON GROUP opt1.
SELECTION-SCREEN END OF BLOCK b002.

START-OF-SELECTION.
  IF download = abap_true.
    PERFORM f_download.
  ELSE.
    PERFORM f_upload.
  ENDIF.

  " ----------------------------------------------------------------------
  " TYPES
  " ----------------------------------------------------------------------
  TYPES: BEGIN OF ty_json_data,
           cktb001 TYPE /gjaauto/cktb001,
           cktb002 TYPE /gjaauto/cktb002,
           cktb003 TYPE STANDARD TABLE OF /gjaauto/cktb003 WITH EMPTY KEY,
           cktb004 TYPE STANDARD TABLE OF /gjaauto/cktb004 WITH EMPTY KEY,
           cktb005 TYPE STANDARD TABLE OF /gjaauto/cktb005 WITH EMPTY KEY,
           cktb006 TYPE STANDARD TABLE OF /gjaauto/cktb006 WITH EMPTY KEY,
           cktb007 TYPE STANDARD TABLE OF /gjaauto/cktb007 WITH EMPTY KEY,
           cktb008 TYPE STANDARD TABLE OF /gjaauto/cktb007 WITH EMPTY KEY,
           cktb401 TYPE STANDARD TABLE OF /gjaauto/cktb401 WITH EMPTY KEY,
         END OF ty_json_data.

  " ----------------------------------------------------------------------
  " DOWNLOAD
  " ----------------------------------------------------------------------
FORM f_download.

  DATA: gs_json_data TYPE ty_json_data,
        lv_json      TYPE string,
        lt_file      TYPE STANDARD TABLE OF string,
        lv_filename  TYPE string,
        lv_path      TYPE string,
        lv_fullpath  TYPE string,
        lv_user_act  TYPE i.

  " =========================
  " Popup salvar arquivo
  " =========================
  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      default_extension = 'json'
      default_file_name = |{ p_auto }{ p_opera }.json|
      file_filter       = 'JSON (*.json)|*.json|'
    CHANGING
      filename          = lv_filename
      path              = lv_path
      fullpath          = lv_fullpath
      user_action       = lv_user_act ).

  IF lv_user_act <> cl_gui_frontend_services=>action_ok.
    MESSAGE 'Download cancelado.' TYPE 'S'.
    RETURN.
  ENDIF.

  " Buscar dados (mantém seu código existente)
  SELECT SINGLE * FROM /gjaauto/cktb001
    INTO @gs_json_data-cktb001
    WHERE auto = @p_auto.

  IF sy-subrc <> 0.
    MESSAGE 'Automação não encontrada' TYPE 'E'.
  ENDIF.

  SELECT SINGLE * FROM /gjaauto/cktb002
    INTO @gs_json_data-cktb002
    WHERE auto  = @p_auto
      AND opera = @p_opera.

  IF sy-subrc <> 0.
    MESSAGE 'Operação não encontrada' TYPE 'E'.
  ENDIF.

  SELECT * FROM /gjaauto/cktb003 INTO TABLE @gs_json_data-cktb003
    WHERE auto = @p_auto AND opera = @p_opera.

  SELECT * FROM /gjaauto/cktb004 INTO TABLE @gs_json_data-cktb004
    WHERE auto = @p_auto AND opera = @p_opera.

  SELECT * FROM /gjaauto/cktb005 INTO TABLE @gs_json_data-cktb005
    WHERE auto = @p_auto AND opera = @p_opera.

  SELECT * FROM /gjaauto/cktb006 INTO TABLE @gs_json_data-cktb006
    WHERE auto = @p_auto AND opera = @p_opera.

  SELECT * FROM /gjaauto/cktb007 INTO TABLE @gs_json_data-cktb007
    WHERE auto = @p_auto AND opera = @p_opera.

  SELECT * FROM /gjaauto/cktb008 INTO TABLE @gs_json_data-cktb008
    WHERE auto = @p_auto AND opera = @p_opera.

  SELECT * FROM /gjaauto/cktb401 INTO TABLE @gs_json_data-cktb401
    WHERE auto = @p_auto AND opera = @p_opera.

  lv_json = /ui2/cl_json=>serialize(
    data = gs_json_data ).
*    pretty_name = /ui2/cl_json=>pretty_mode-camel_case ). esta transformando campos campo_campo em campoCampo.

  SPLIT lv_json AT cl_abap_char_utilities=>newline INTO TABLE lt_file.

  cl_gui_frontend_services=>gui_download(
    EXPORTING
      filename = lv_fullpath
      filetype = 'ASC'
    CHANGING
      data_tab = lt_file ).

  MESSAGE 'Arquivo JSON gerado com sucesso.' TYPE 'S'.

ENDFORM.


" ----------------------------------------------------------------------
" UPLOAD
" ----------------------------------------------------------------------
FORM f_upload.

  DATA: gs_json_data TYPE ty_json_data,
        lt_file      TYPE STANDARD TABLE OF string,
        lv_json      TYPE string,
        lt_files     TYPE filetable,
        lv_rc        TYPE i,
        lv_fullpath  TYPE string,
        lv_answer    TYPE c LENGTH 1.

  " =========================
  " Popup abrir arquivo
  " =========================
  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      default_extension = 'json'
      file_filter       = 'JSON (*.json)|*.json|'
    CHANGING
      file_table        = lt_files
      rc                = lv_rc ).

  IF lv_rc = 0.
    MESSAGE 'Upload cancelado.' TYPE 'S'.
    RETURN.
  ENDIF.

  READ TABLE lt_files INDEX 1 INTO lv_fullpath.

  " Upload do arquivo
  cl_gui_frontend_services=>gui_upload(
    EXPORTING
      filename = lv_fullpath
      filetype = 'ASC'
    CHANGING
      data_tab = lt_file ).

  CONCATENATE LINES OF lt_file INTO lv_json
              SEPARATED BY cl_abap_char_utilities=>newline.

  /ui2/cl_json=>deserialize(
    EXPORTING
      json = lv_json
    CHANGING
      data = gs_json_data ).


  " ----------------------------------------------------------------------
  " Verificar se já existe configuração
  " ----------------------------------------------------------------------
  DATA(lv_exist_001) = abap_false.
  DATA(lv_exist_002) = abap_false.

  SELECT SINGLE COUNT( * ) FROM /gjaauto/cktb001
    WHERE auto = @p_auto.
  IF sy-subrc = 0.
    lv_exist_001 = abap_true.
  ENDIF.

  SELECT SINGLE COUNT( * ) FROM /gjaauto/cktb002
    WHERE auto  = @p_auto
      AND opera = @p_opera.
  IF sy-subrc = 0.
    lv_exist_002 = abap_true.
  ENDIF.

  IF lv_exist_001 = abap_true OR lv_exist_002 = abap_true.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar       = 'Confirmação'
        text_question  = 'Já existe configuração para essa automação. Deseja apagar todas as configurações existentes?'
        text_button_1  = 'Sim'
        icon_button_1  = 'ICON_OKAY'
        text_button_2  = 'Não'
        icon_button_2  = 'ICON_CANCEL'
        default_button = '2'
      IMPORTING
        answer         = lv_answer.

    IF lv_answer <> '1'.
      MESSAGE 'Upload cancelado pelo usuário.' TYPE 'S'.
      RETURN.
    ENDIF.

    " ----------------------------------------------------------------------
    " Apagar dados existentes (ordem correta por dependência)
    " ----------------------------------------------------------------------
    DELETE FROM /gjaauto/cktb401 WHERE auto = p_auto AND opera = p_opera.
    DELETE FROM /gjaauto/cktb008 WHERE auto = p_auto AND opera = p_opera.
    DELETE FROM /gjaauto/cktb007 WHERE auto = p_auto AND opera = p_opera.
    DELETE FROM /gjaauto/cktb006 WHERE auto = p_auto AND opera = p_opera.
    DELETE FROM /gjaauto/cktb005 WHERE auto = p_auto AND opera = p_opera.
    DELETE FROM /gjaauto/cktb004 WHERE auto = p_auto AND opera = p_opera.
    DELETE FROM /gjaauto/cktb003 WHERE auto = p_auto AND opera = p_opera.
    DELETE FROM /gjaauto/cktb002 WHERE auto = p_auto AND opera = p_opera.
    DELETE FROM /gjaauto/cktb001 WHERE auto = p_auto.

  ENDIF.

  " ----------------------------------------------------------------------
  " Inserir novos dados
  " ----------------------------------------------------------------------
  INSERT /gjaauto/cktb001 FROM gs_json_data-cktb001.
  INSERT /gjaauto/cktb002 FROM gs_json_data-cktb002.
  INSERT /gjaauto/cktb003 FROM TABLE gs_json_data-cktb003.
  INSERT /gjaauto/cktb004 FROM TABLE gs_json_data-cktb004.
  INSERT /gjaauto/cktb005 FROM TABLE gs_json_data-cktb005.
  INSERT /gjaauto/cktb006 FROM TABLE gs_json_data-cktb006.
  INSERT /gjaauto/cktb007 FROM TABLE gs_json_data-cktb007.
  INSERT /gjaauto/cktb008 FROM TABLE gs_json_data-cktb008.
  INSERT /gjaauto/cktb401 FROM TABLE gs_json_data-cktb401.

  COMMIT WORK.

  MESSAGE 'Upload realizado com sucesso.' TYPE 'S'.
ENDFORM.
