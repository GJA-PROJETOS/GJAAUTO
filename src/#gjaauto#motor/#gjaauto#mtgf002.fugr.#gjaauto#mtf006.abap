FUNCTION /gjaauto/mtf006.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_AUTO) TYPE  /GJAAUTO/CKE_AUTOMACAO OPTIONAL
*"     VALUE(IV_OPERA) TYPE  /GJAAUTO/CKE_OPERARACAO OPTIONAL
*"     VALUE(IV_CHAVE) TYPE  /GJAAUTO/MTE_CHAVE OPTIONAL
*"----------------------------------------------------------------------
*  FIELD-SYMBOLS: <ls_fm_declation_vars> TYPE ty_fm_declation_vars.
*  DATA:
*    tl_mapea_imp          TYPE TABLE OF /gjaauto/cktb004,
*    tl_mapea_exp          TYPE TABLE OF /gjaauto/cktb004,
*    tl_mapea_tab          TYPE TABLE OF /gjaauto/cktb004,
*    lt_fm_declation_vars  TYPE TABLE OF ty_fm_declation_vars,
*    lt_dokumentation      TYPE TABLE OF funct,
*    lt_export_parameter   TYPE TABLE OF rsexp,
*    lt_import_parameter   TYPE TABLE OF rsimp,
*    lt_changing_parameter TYPE TABLE OF rscha,
*    lt_exception_list      TYPE TABLE OF rsexc,
*    lt_tables_parameter   TYPE TABLE OF rstbl.
*
*  CALL FUNCTION '/GJAAUTO/MTF008'
*    EXPORTING
*      iv_chave  = iv_chave
*    EXCEPTIONS
*      not_found = 1.
*
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*
*  " Seleciona entidades da automacao
*  SELECT * FROM /gjaauto/cktb005
*    INTO TABLE @DATA(tl_entidades)
*    WHERE auto  = @iv_auto
*      AND opera = @iv_opera.
*
*
*
*  "------------------------------------------------------------
*  " Gera declarações DATA dinamicamente com base nas entidades
*  "------------------------------------------------------------
*  APPEND '"Declaração das variaveis' TO lt_code.
*  APPEND 'DATA:' TO lt_code.
*  LOOP AT tl_entidades INTO DATA(lw_entidade) WHERE datanatu <> 'I'.
*
*    DATA(lv_typename) = COND string(
*                          WHEN lw_entidade-reftypname IS INITIAL
*                          THEN lw_entidade-tabname
*                          ELSE lw_entidade-reftypname ).
*
*    CONDENSE  lv_typename.
*
*    DATA(lv_line) = SWITCH string(
*                      lw_entidade-reftype
*                      WHEN 'T' THEN |lt_{ lw_entidade-name } TYPE TABLE OF { lv_typename }|
*                      ELSE         |lw_{ lw_entidade-name } TYPE { lv_typename }|
*                    ).
*
*    APPEND |{ lv_line },| TO lt_code.
*  ENDLOOP.
*
*  " Substituir a vírgula final por ponto na última linha da tabela
*  PERFORM replace_last_comma_with_dot TABLES lt_code.
*
**  DATA(lv_last_index) = lines( lt_code ).
**  IF lv_last_index > 0.
**    DATA(lv_last_line) = lt_code[ lv_last_index ].
**    REPLACE ALL OCCURRENCES OF ',' IN lv_last_line WITH '.'.
**    lt_code[ lv_last_index ] = lv_last_line.
**  ENDIF.
*
*  "------------------------------------------------------------
*  " Gera instruções SELECT dinâmicas para as entidades iniciais
*  "------------------------------------------------------------
*  APPEND '"Seleção dos dados iniciais' TO lt_code.
*  LOOP AT tl_entidades INTO lw_entidade WHERE datanatu = 'I'.
*
*    " Define tipo de SELECT (SINGLE ou *)
*    DATA(lv_select) = SWITCH string( lw_entidade-reftype
*                                     WHEN 'T' THEN 'SELECT *'
*                                     ELSE         'SELECT SINGLE *' ).
*
*    APPEND lv_select TO lt_code.
*
*    " FROM com nome da tabela
*    APPEND |FROM { lw_entidade-tabname }| TO lt_code.
*
*    " INTO com data inline, tipo table ou work area
*    DATA(lv_into) = SWITCH string(
*                      lw_entidade-reftype
*                      WHEN 'T' THEN |INTO TABLE @DATA(lt_{ lw_entidade-name })|
*                      ELSE         |INTO @DATA(lw_{ lw_entidade-name })|
*                    ).
*    APPEND lv_into TO lt_code.
*
*    " WHERE com chave
*    APPEND |WHERE chave = '{ iv_chave }'.| TO lt_code.
*
*  ENDLOOP.
*
*
*  " Seleciona mapeamento
*  SELECT * FROM /gjaauto/cktb003
*    INTO TABLE @DATA(tl_mapeamento_headers)
*   WHERE auto  = @iv_auto
*     AND opera = @iv_opera
*   ORDER BY etapa.
*
*  IF sy-subrc <> 0.
*    RETURN.
*  ENDIF.
*
*  SELECT * FROM /gjaauto/cktb004
*    INTO TABLE @DATA(tl_mapeamento)
*     FOR ALL ENTRIES IN @tl_mapeamento_headers
*   WHERE auto  = @tl_mapeamento_headers-auto
*     AND opera = @tl_mapeamento_headers-opera.
*
*  IF sy-subrc <> 0.
*    RETURN.
*  ENDIF.
*
*  SORT tl_mapeamento BY etapa.
*
*  " TODO: variable is assigned but never used (ABAP cleaner)
*  LOOP AT tl_mapeamento_headers INTO DATA(lw_map_header).
*
*
*    CALL FUNCTION 'FUNCTION_IMPORT_DOKU'
*      EXPORTING
*        funcname           = CONV rs38l_fnam( lw_map_header-rotin )
*        language           = sy-langu
*        with_enhancements  = 'X'
*      TABLES
*        dokumentation      = lt_dokumentation
*        exception_list     = lt_exception_list
*        export_parameter   = lt_export_parameter
*        import_parameter   = lt_import_parameter
*        changing_parameter = lt_changing_parameter
*        tables_parameter   = lt_tables_parameter
*      EXCEPTIONS
*        OTHERS             = 1.
*
*    " Loop sobre os mapeamentos de parâmetros
*    LOOP AT tl_mapeamento INTO DATA(lw_map) WHERE etapa EQ lw_map_header-etapa.
*
*      " Determina o nome do parâmetro considerando tabname prioritariamente
*      DATA(lv_parameter) = CONV char30(
*        COND char30(
*          WHEN lw_map-tabname IS NOT INITIAL THEN lw_map-tabname
*          ELSE lw_map-param
*        )
*      ).
*
*      " Verifica se o parâmetro já foi declarado
*      READ TABLE lt_fm_declation_vars TRANSPORTING NO FIELDS
*        WITH KEY parameter = lv_parameter.
*
*      IF sy-subrc <> 0.
*
*        " Processa conforme a natureza do parâmetro: Exporting, Importing ou Tables
*        CASE lw_map-paramnat.
*
*          WHEN 'E'. " Export Parameter
*            READ TABLE lt_export_parameter INTO DATA(lw_export_parameter)
*              WITH KEY parameter = lv_parameter.
*
*            DATA(lv_reftype) = COND string(
*              WHEN lw_export_parameter-dbfield IS NOT INITIAL THEN lw_export_parameter-dbfield
*              ELSE lw_export_parameter-typ
*            ).
*
*            DATA(lv_paramtyp) = COND string(
*              WHEN lw_map-tabname IS NOT INITIAL THEN 'S'
*              ELSE 'V'
*            ).
*
*            IF lv_paramtyp EQ 'V'.
*              "salvar direto na tabela de variaveis.
*            ELSE.
*              APPEND VALUE #(
*              parameter = lw_map-tabname
*              reftype  = lv_reftype
*              paramnat = lw_map-paramnat
*              paramtyp = lv_paramtyp
*            ) TO lt_fm_declation_vars.
*            ENDIF.
*
*            APPEND lw_map TO tl_mapea_exp.
*
*            READ TABLE lt_export_parameter TRANSPORTING NO FIELDS WITH KEY parameter = |{ lv_parameter }X|.
*            IF sy-subrc EQ 0.
*              APPEND VALUE #(
*              parameter =  |{ lv_parameter }X|
*              reftype  = |{ lv_reftype }X|
*              paramnat = lw_map-paramnat
*              paramtyp = lv_paramtyp
*            ) TO lt_fm_declation_vars.
*            ENDIF.
*          WHEN 'I'. " Import Parameter
*            READ TABLE lt_import_parameter INTO DATA(lw_import_parameter)
*              WITH KEY parameter = lv_parameter.
*
*            lv_reftype = COND string(
*              WHEN lw_import_parameter-dbfield IS NOT INITIAL THEN lw_import_parameter-dbfield
*              ELSE lw_import_parameter-typ
*            ).
*
*            lv_paramtyp = COND string(
*              WHEN lw_map-tabname IS NOT INITIAL THEN 'S'
*              ELSE 'V'
*            ).
*
*            APPEND VALUE #(
*              parameter = lw_map-tabname
*              reftype  = lv_reftype
*              paramnat = lw_map-paramnat
*              paramtyp = lv_paramtyp
*            ) TO lt_fm_declation_vars.
*            APPEND lw_map TO tl_mapea_imp.
*
*            READ TABLE lt_import_parameter TRANSPORTING NO FIELDS WITH KEY parameter = |{ lv_parameter }X|.
*            IF sy-subrc EQ 0.
*              APPEND VALUE #(
*              parameter =  |{ lw_map-tabname }X|
*              reftype  = |{ lv_reftype }X|
*              paramnat = lw_map-paramnat
*              paramtyp = lv_paramtyp
*            ) TO lt_fm_declation_vars.
*            ENDIF.
*          WHEN 'T'. " Tables Parameter
*            READ TABLE lt_tables_parameter INTO DATA(lw_tables_parameter)
*              WITH KEY parameter = lv_parameter.
*
*            APPEND VALUE #(
*              parameter = lw_map-tabname
*              reftype  = lw_tables_parameter-dbstruct
*              paramnat = lw_map-paramnat
*              paramtyp = 'T'
*            ) TO lt_fm_declation_vars.
*            APPEND lw_map TO tl_mapea_tab.
*
*            READ TABLE lt_tables_parameter TRANSPORTING NO FIELDS WITH KEY parameter = |{ lv_parameter }X|.
*            IF sy-subrc EQ 0.
*              APPEND VALUE #(
*              parameter =  |{ lw_map-tabname }X|
*              reftype  = |{ lw_tables_parameter-dbstruct }X|
*              paramnat = lw_map-paramnat
*              paramtyp = 'T'
*            ) TO lt_fm_declation_vars.
*            ENDIF.
*        ENDCASE.
*
*      ENDIF.
*
*    ENDLOOP.
*
*    APPEND 'DATA:' TO lt_code.
*
*    LOOP AT lt_fm_declation_vars ASSIGNING <ls_fm_declation_vars>.
*
*      " Geração do nome declarado com base no tipo do parâmetro
*      <ls_fm_declation_vars>-nome_declarado = |{ SWITCH #(
*        <ls_fm_declation_vars>-paramtyp
*          WHEN 'T' THEN 'lt'
*          WHEN 'S' THEN 'lw'
*          WHEN 'V' THEN 'lv') }_{ <ls_fm_declation_vars>-parameter }|.
*
*      " Criação da linha de declaração de variável
*      APPEND |{ <ls_fm_declation_vars>-nome_declarado } TYPE {
*        SWITCH #(
*          <ls_fm_declation_vars>-paramtyp
*            WHEN 'T' THEN |TABLE OF { <ls_fm_declation_vars>-reftype }|
*            ELSE <ls_fm_declation_vars>-reftype ) },| TO lt_code.
*
*    ENDLOOP.
*
*    PERFORM replace_last_comma_with_dot TABLES lt_code.
*
*    SORT tl_mapeamento BY paramnat tabname.
*
*    LOOP AT tl_mapeamento INTO lw_map WHERE paramnat EQ 'I'.
*      READ TABLE lt_fm_declation_vars INTO DATA(wl_vars) WITH KEY parameter = lw_map-tabname.
*      IF lw_map-paramval IS INITIAL.
*        APPEND |{ wl_vars-nome_declarado }-{ lw_map-param } = lw_{ lw_map-tabname_from }-{ lw_map-param_from }.| TO lt_code.
*      ELSE.
*        APPEND |{ wl_vars-nome_declarado }-{ lw_map-param } = '{ lw_map-param_from }'.| TO lt_code.
*      ENDIF.
*
*      READ TABLE lt_fm_declation_vars TRANSPORTING NO FIELDS WITH KEY parameter = |{ lw_map-tabname }X|.
*      IF sy-subrc EQ 0.
*        APPEND |{ wl_vars-nome_declarado }X-{ lw_map-param } = 'X'.| TO lt_code.
*      ENDIF.
*
*    ENDLOOP.
*
*    LOOP AT lt_fm_declation_vars INTO wl_vars WHERE paramnat EQ 'T'.
*      APPEND |LOOP AT { wl_vars-nome_declarado } INTO lw_{ wl_vars-parameter }.| TO lt_code.
*
*      DATA(lv_length) = strlen( wl_vars-parameter ).
*      SUBTRACT 1 FROM lv_length.
*      IF wl_vars-parameter+lv_length EQ 'X'.
*        lv_parameter = CONV string( wl_vars-parameter ).
*        lv_parameter = lv_parameter(lv_length).
*        DATA(lv_bapiupdate) = abap_true.
*      ELSE.
*        lv_parameter = wl_vars-parameter.
*        lv_bapiupdate = abap_false.
*      ENDIF.
*
*      LOOP AT tl_mapeamento INTO lw_map WHERE tabname EQ lv_parameter.
*        IF lv_bapiupdate EQ abap_true.
*          APPEND |{ wl_vars-nome_declarado }-{ lw_map-param } = 'X'.| TO lt_code.
*        ELSEIF lw_map-paramval IS NOT INITIAL.
*          APPEND |{ wl_vars-nome_declarado }-{ lw_map-param } = '{ lw_map-param_from }'.| TO lt_code.
*        ELSE.
*          APPEND |{ wl_vars-nome_declarado }-{ lw_map-param } = lw_{ lw_map-tabname_from }-{ lw_map-param_from }.| TO lt_code.
*        ENDIF.
**        READ TABLE lt_fm_declation_vars TRANSPORTING NO FIELDS WITH KEY parameter = |{ lw_map-tabname }X|.
**        IF sy-subrc EQ 0.
**          APPEND |{ wl_vars-nome_declarado }X-{ lw_map-param } = 'X'.| TO lt_code.
**        ENDIF.
*      ENDLOOP.
*      APPEND |APPEND lw_{ wl_vars-parameter } TO { wl_vars-nome_declarado }.| TO lt_code.
*      APPEND |ENDLOOP.| TO lt_code.
*    ENDLOOP.
*
*    APPEND |CALL FUNCTION '{ lw_map_header-rotin }'| TO lt_code.
*
*    READ TABLE lt_fm_declation_vars TRANSPORTING NO FIELDS WITH KEY paramnat = 'I'.
*    IF sy-subrc EQ 0.
*      APPEND 'EXPORT' TO lt_code.
*      LOOP AT lt_fm_declation_vars INTO wl_vars WHERE paramnat = 'I'.
*        APPEND |{ wl_vars-parameter } = { wl_vars-nome_declarado }| TO lt_code.
*      ENDLOOP.
*      LOOP AT tl_mapeamento INTO lw_map WHERE paramnat = 'I' AND tabname IS INITIAL.
*        APPEND |{ lw_map-param } = lw_variables-{ lw_map-param }| TO lt_code.
*      ENDLOOP.
*    ENDIF.
*
*    READ TABLE tl_mapeamento TRANSPORTING NO FIELDS WITH KEY paramnat = 'E'.
*    IF sy-subrc EQ 0.
*      APPEND 'IMPORT' TO lt_code.
*      LOOP AT tl_mapeamento INTO lw_map WHERE paramnat = 'E'.
*        IF lw_map-tabname IS INITIAL.
*          APPEND |{ lw_map-param } = lw_variables-{ lw_map-param_from }| TO lt_code.
*        ELSE.
*          BREAK-POINT. "TODO: Implementar pois pode ser que tenha q salvar o resultado, ai vai precisadar de uma linha nova na /GJAAUTO/CKTB005
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*
*    READ TABLE tl_mapeamento TRANSPORTING NO FIELDS WITH KEY paramnat = 'T'.
*    IF sy-subrc EQ 0.
*      APPEND 'TABLES' TO lt_code.
*      LOOP AT lt_fm_declation_vars INTO wl_vars WHERE paramnat = 'T'.
*        APPEND |{ wl_vars-parameter } = { wl_vars-nome_declarado }| TO lt_code.
*      ENDLOOP.
*    ENDIF.
*    APPEND '.' TO lt_code.
*    IF lw_map_header-commit_after EQ abap_true.
*      APPEND 'COMMIT WORK AND WAIT.' TO lt_code.
*    ENDIF.
*
*  ENDLOOP.
*
*  CALL FUNCTION 'PRETTY_PRINTER'
*    EXPORTING
*      inctoo = 'X'
*    TABLES
*      ntext  = lt_code_formatted
*      otext  = lt_code.
*
*  BREAK-POINT.
ENDFUNCTION.


*CALL FUNCTION 'BAPI_PO_CREATE1'
*  EXPORTING
*    poheader                     =
*   POHEADERX                    =
* IMPORTING
*   EXPPURCHASEORDER             =
*   EXPHEADER                    =
*   EXPPOEXPIMPHEADER            =
* TABLES
*   RETURN                       =

.
