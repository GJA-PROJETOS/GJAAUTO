*&---------------------------------------------------------------------*
*& Report /gjaauto/mtj0003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /gjaauto/mtj0003.

PARAMETERS: p_source TYPE string LOWER CASE OBLIGATORY, " Ex: /usr/sap/interfaces/in
            p_target TYPE string LOWER CASE OBLIGATORY. " Ex: /usr/sap/interfaces/processed

DATA: lt_files TYPE TABLE OF epsfili,
      ls_file  TYPE epsfili,
      lv_line  TYPE string,
      lv_fullpath_source TYPE string,
      lv_fullpath_target TYPE string.

" Listar arquivos no diretório de origem
CALL FUNCTION 'EPS2_GET_DIRECTORY_LISTING'
  EXPORTING
    directory        = p_source
  TABLES
    file_list        = lt_files
  EXCEPTIONS
    invalid_eps_subdir = 1
    others             = 2.

IF sy-subrc <> 0.
  MESSAGE 'Erro ao acessar o diretório de origem.' TYPE 'E'.
ENDIF.

LOOP AT lt_files INTO ls_file.
  IF ls_file-name CP '*.xml'.

    CONCATENATE p_source ls_file-name INTO lv_fullpath_source SEPARATED BY '/'.
    CONCATENATE p_target ls_file-name INTO lv_fullpath_target SEPARATED BY '/'.

    " Abrir para leitura
    OPEN DATASET lv_fullpath_source FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc <> 0.
      MESSAGE |Erro ao abrir o arquivo { lv_fullpath_source }| TYPE 'E'.
    ENDIF.

    WHILE sy-subrc = 0.
      READ DATASET lv_fullpath_source INTO lv_line.
      IF sy-subrc = 0.
        " Processamento do conteúdo XML (parser pode ser incluído aqui)
      ENDIF.
    ENDWHILE.

    CLOSE DATASET lv_fullpath_source.

    " Copiar conteúdo para destino
    OPEN DATASET lv_fullpath_target FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc <> 0.
      MESSAGE |Erro ao criar o arquivo destino { lv_fullpath_target }| TYPE 'E'.
    ENDIF.

    " Reabrir para reler o original
    OPEN DATASET lv_fullpath_source FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    WHILE sy-subrc = 0.
      READ DATASET lv_fullpath_source INTO lv_line.
      IF sy-subrc = 0.
        TRANSFER lv_line TO lv_fullpath_target.
      ENDIF.
    ENDWHILE.

    CLOSE DATASET lv_fullpath_source.
    CLOSE DATASET lv_fullpath_target.

    " Remover arquivo original
    DELETE DATASET lv_fullpath_source.
    IF sy-subrc <> 0.
      MESSAGE |Erro ao deletar { lv_fullpath_source } após mover.| TYPE 'W'.
    ENDIF.

  ENDIF.
ENDLOOP.
