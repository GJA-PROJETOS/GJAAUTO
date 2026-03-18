CLASS /gjaauto/clmt0001 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_mapped_variables,
        etapa         TYPE /gjaauto/cke_etapa,
        vartype       TYPE char1,
        obj_para      TYPE parameter,
        obj_para_real TYPE c LENGTH 60,
      END OF ty_mapped_variables.
    TYPES tt_code             TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    TYPES tt_mapped_variables TYPE STANDARD TABLE OF ty_mapped_variables WITH DEFAULT KEY.

    CONSTANTS c_status_executando TYPE /gjaauto/mte_status VALUE 'E' ##NO_TEXT.
    CONSTANTS true                TYPE boolean             VALUE abap_true ##NO_TEXT.
    CONSTANTS false               TYPE boolean             VALUE abap_false ##NO_TEXT.

    METHODS constructor
      IMPORTING  iv_chave TYPE /gjaauto/mte_chave DEFAULT '251024IN100000000006'
      EXCEPTIONS auto_not_found.

    METHODS factory
      RETURNING VALUE(et_code) TYPE tt_code.

  PRIVATE SECTION.
    DATA gv_chave             TYPE /gjaauto/mte_chave.
    DATA gv_auto              TYPE /gjaauto/cke_automacao.
    DATA gv_opera             TYPE /gjaauto/cke_operaracao.
    DATA gv_has_return        TYPE boolean.
    DATA gt_code              TYPE tt_code.
    DATA gw_header            TYPE /gjaauto/mttb001.
    DATA gt_etapas            TYPE TABLE OF /gjaauto/cktb003.
    DATA gt_etapas_exec       TYPE TABLE OF /gjaauto/mttb003.
    DATA gt_mapeamentos       TYPE TABLE OF /gjaauto/cktb004.
    DATA gt_dados             TYPE TABLE OF /gjaauto/cktb005.
    DATA gt_loop_tables       TYPE TABLE OF /gjaauto/cktb006.
    DATA gt_atribuicao        TYPE TABLE OF /gjaauto/cktb007.
    DATA gt_regras_etapa      TYPE TABLE OF /gjaauto/cktb008.
    DATA gt_etapa_dependentes TYPE TABLE OF /gjaauto/cktb401.

    METHODS load_auto_data
      EXCEPTIONS dados_not_found
                 mapeamento_not_found
                 etapa_not_found.

    METHODS codegen_init_data_definition.
    METHODS replace_last_comma_with_dot.
    METHODS codegen_select_initial_data.

    METHODS get_paramval
      IMPORTING is_mapeamento      TYPE /gjaauto/cktb004
      RETURNING VALUE(rv_paramval) TYPE seovalue.

    METHODS codegen_etapa
      IMPORTING  iw_etapa TYPE /gjaauto/cktb003
      EXCEPTIONS function_not_found.

    METHODS codegen_before_call_funtion
      IMPORTING iw_etapa            TYPE /gjaauto/cktb003
                it_export_parameter TYPE /gjaauto/mttt002
                it_import_parameter TYPE /gjaauto/mttt003
                it_tables_parameter TYPE /gjaauto/mttt004
      EXPORTING et_mapped_variables TYPE tt_mapped_variables.

    METHODS codegen_call_function
      IMPORTING iw_etapa            TYPE /gjaauto/cktb003
                it_mapped_variables TYPE tt_mapped_variables.

    METHODS codegen_after_call_function
      IMPORTING iw_etapa TYPE /gjaauto/cktb003.

ENDCLASS.


CLASS /gjaauto/clmt0001 IMPLEMENTATION.
  METHOD constructor.
    gv_chave = iv_chave.

    SELECT SINGLE * FROM /gjaauto/mttb001
      WHERE chave = @gv_chave
      INTO @DATA(lw_header).

    IF sy-subrc = 0.
      gw_header = lw_header.
      gv_auto  = gv_chave+6(2).
      gv_opera = CONV numc3( gv_chave+8(3) ).
    ELSE.
      RAISE auto_not_found.
    ENDIF.
  ENDMETHOD.

  METHOD load_auto_data.
    SELECT * FROM /gjaauto/cktb003
      INTO TABLE @DATA(lt_etapas)
      WHERE auto  = @gv_auto
        AND opera = @gv_opera
      ORDER BY etapa.

    IF sy-subrc = 0.
      gt_etapas = lt_etapas.
    ELSE.
      RAISE etapa_not_found.
    ENDIF.

    SELECT * FROM /gjaauto/cktb004
      INTO TABLE @DATA(lt_mapeamentos)
      WHERE auto  = @gv_auto
        AND opera = @gv_opera.

    IF sy-subrc = 0.
      gt_mapeamentos = lt_mapeamentos.
    ELSE.
      RAISE mapeamento_not_found.
    ENDIF.

    SELECT * FROM /gjaauto/cktb005
      INTO TABLE @DATA(lt_dados)
      WHERE auto  = @gv_auto
        AND opera = @gv_opera.

    IF sy-subrc = 0.
      gt_dados = lt_dados.
    ELSE.
      RAISE dados_not_found.
    ENDIF.

    SELECT * FROM /gjaauto/mttb003
      INTO TABLE gt_etapas_exec
      WHERE auto  = gv_auto
        AND opera = gv_opera
        AND chave = gv_chave.

    SELECT * FROM /gjaauto/cktb006
      INTO TABLE gt_loop_tables
      WHERE auto  = gv_auto
        AND opera = gv_opera.

    SELECT * FROM /gjaauto/cktb007
      INTO TABLE gt_atribuicao
      WHERE auto  = gv_auto
        AND opera = gv_opera.

    SELECT * FROM /gjaauto/cktb008
      INTO TABLE gt_regras_etapa
      WHERE auto  = gv_auto
        AND opera = gv_opera.

    " ---------------------------------------------------------------------
    " TABELAS DE REGRAS                           -
    " ---------------------------------------------------------------------
    SELECT * FROM /gjaauto/cktb401
      INTO TABLE gt_etapa_dependentes
      WHERE auto  = gv_auto
        AND opera = gv_opera.
  ENDMETHOD.

  METHOD codegen_init_data_definition.
    APPEND '"Declaração das variaveis' TO gt_code.
    APPEND 'DATA:' TO gt_code.
    APPEND 'gw_logs type /GJAAUTO/MTTB002,' TO gt_code.
    APPEND 'gw_etapa type /GJAAUTO/MTTB003,' TO gt_code.
    APPEND 'has_error type boolean,' TO gt_code.
    APPEND 'has_wait type boolean,' TO gt_code.
    APPEND 'lx_root TYPE REF TO cx_root,' TO gt_code.
    LOOP AT gt_dados INTO DATA(lw_entidade) WHERE datanatu <> 'I' AND datanatu <> 'V' AND etapa_born IS INITIAL.

      CONDENSE lw_entidade-reftypname.

      DATA(lv_line) = SWITCH string(
                        lw_entidade-reftype
                        WHEN 'T'
                        THEN |lt_{ lw_entidade-name } TYPE TABLE OF { lw_entidade-reftypname }|
                        ELSE |lw_{ lw_entidade-name } TYPE { lw_entidade-reftypname }| ).

      APPEND |{ lv_line },| TO gt_code.
    ENDLOOP.
    replace_last_comma_with_dot( ).
    APPEND |DATA(lv_item) = 0.| TO gt_code.
    APPEND |SELECT SINGLE *| TO gt_code.
    APPEND |FROM /GJAAUTO/MTTB001 | TO gt_code.
    APPEND |INTO @data(gw_auto)| TO gt_code.
    APPEND |WHERE AUTO EQ '{ gv_chave+6(2) }' | TO gt_code.
    APPEND |AND OPERA EQ '{ gv_chave+8(3) }' | TO gt_code.
    APPEND |AND chave EQ '{ gv_chave }'.| TO gt_code.
    APPEND |SELECT *| TO gt_code.
    APPEND |FROM /GJAAUTO/MTTB003 | TO gt_code.
    APPEND |INTO TABLE @data(gt_etapas)| TO gt_code.
    APPEND |WHERE AUTO EQ '{ gv_chave+6(2) }' | TO gt_code.
    APPEND |AND OPERA EQ '{ gv_chave+8(3) }' | TO gt_code.
    APPEND |AND chave EQ '{ gv_chave }'.| TO gt_code.
  ENDMETHOD.

  METHOD replace_last_comma_with_dot.
    FIELD-SYMBOLS <lv_line> TYPE string.

    " Pega o índice da última linha
    DATA(lv_last_index) = lines( gt_code ).

    IF lv_last_index <= 0.
      RETURN.
    ENDIF.

    ASSIGN gt_code[ lv_last_index ] TO <lv_line>.
    IF sy-subrc = 0 AND <lv_line> IS ASSIGNED.
      IF <lv_line> = 'DATA:'.
        DELETE gt_code INDEX lv_last_index.
      ELSE.
        REPLACE ALL OCCURRENCES OF ',' IN <lv_line> WITH '.'.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD codegen_select_initial_data.
    "------------------------------------------------------------
    " Gera instruções SELECT dinâmicas para as entidades iniciais
    "------------------------------------------------------------
    APPEND '"Seleção dos dados iniciais' TO gt_code.
    LOOP AT gt_dados INTO DATA(lw_dados) WHERE datanatu = 'I' OR datanatu = 'V'.

      " Define tipo de SELECT (SINGLE ou *)
      DATA(lv_select) = SWITCH string( lw_dados-reftype
                                       WHEN 'T'
                                       THEN 'SELECT *'
                                       ELSE 'SELECT SINGLE *' ).

      APPEND lv_select TO gt_code.

      " FROM com nome da tabela
      APPEND |FROM { lw_dados-reftypname }| TO gt_code.

      " INTO com data inline, tipo table ou work area
      DATA(lv_into) = SWITCH string(
                        lw_dados-reftype
                        WHEN 'T'
                        THEN |INTO TABLE @DATA(lt_{ lw_dados-name })|
                        ELSE |INTO @DATA(lw_{ lw_dados-name })| ).
      APPEND lv_into TO gt_code.

      " WHERE com chave
      APPEND |WHERE chave = '{ gv_chave }'.| TO gt_code.

      IF lw_dados-reftype = 'T'.
        APPEND |DATA: lw_{ lw_dados-name } type { lw_dados-reftypname }.| TO gt_code.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD codegen_etapa.
    APPEND |"*╔═════════════════════════════════════════════════════════════════════*| TO gt_code.
    APPEND |"*║ INÍCIO ETAPA -> { iw_etapa-etapa ALPHA = OUT }| TO gt_code.
    APPEND |"*╚═════════════════════════════════════════════════════════════════════*| TO gt_code.

    APPEND |READ TABLE gt_etapas INTO gw_etapa WITH KEY etapa = '{ iw_etapa-etapa }'.| TO gt_code.
    APPEND |DATA(lw_etapa{ iw_etapa-etapa }) = VALUE /gjaauto/mttb003( | TO gt_code.
    APPEND |auto = '{ gv_chave+6(2) }'| TO gt_code.
    APPEND |opera = '{ gv_chave+8(3) }'| TO gt_code.
    APPEND |etapa = '{ iw_etapa-etapa }'| TO gt_code.
    APPEND |chave = '{ gv_chave }'| TO gt_code.
    APPEND |credat = sy-datum| TO gt_code.
    APPEND |cretim = sy-uzeit| TO gt_code.
    APPEND |status = '1'| TO gt_code.
    APPEND |crenam = sy-uname| TO gt_code.
    APPEND |).| TO gt_code.
    APPEND |INSERT /gjaauto/mttb003 FROM lw_etapa{ iw_etapa-etapa }.| TO gt_code.

    DATA lt_dokumentation      TYPE TABLE OF funct.
    DATA lt_export_parameter   TYPE TABLE OF rsexp.
    DATA lt_import_parameter   TYPE TABLE OF rsimp.
    DATA lt_changing_parameter TYPE TABLE OF rscha.
    DATA lt_exception_list     TYPE TABLE OF rsexc.
    DATA lt_tables_parameter   TYPE TABLE OF rstbl.

    CALL FUNCTION 'FUNCTION_IMPORT_DOKU'
      EXPORTING  funcname           = CONV rs38l_fnam( iw_etapa-rotin )
                 language           = sy-langu
                 with_enhancements  = 'X'
      TABLES     dokumentation      = lt_dokumentation
                 exception_list     = lt_exception_list
                 export_parameter   = lt_export_parameter
                 import_parameter   = lt_import_parameter
                 changing_parameter = lt_changing_parameter
                 tables_parameter   = lt_tables_parameter
      EXCEPTIONS function_not_found = 1
                 OTHERS             = 2.

    IF sy-subrc <> 0.
      " TODO: Tratar erro de função não encontrada
      RAISE function_not_found.
    ENDIF.

    " Gera declaração das variáveis usadas na etapa
    codegen_before_call_funtion( EXPORTING iw_etapa            = iw_etapa
                                           it_export_parameter = lt_export_parameter
                                           it_import_parameter = lt_import_parameter
                                           it_tables_parameter = lt_tables_parameter
                                 IMPORTING et_mapped_variables = DATA(lt_mapped_variables) ).

    " Gera chamada da função
    codegen_call_function( iw_etapa            = iw_etapa
                           it_mapped_variables = lt_mapped_variables ).

    IF iw_etapa-commit_after = true.
      APPEND 'COMMIT WORK AND WAIT.' TO gt_code.
    ENDIF.

    " Gera código pós chamada da função
    codegen_after_call_function( iw_etapa = iw_etapa ).
  ENDMETHOD.

  METHOD codegen_before_call_funtion.
    " ╔════════════════════════════════════════════════════════════════════╗
    " ║                        DECLARA AS VARIAVEL                         ║
    " ╚════════════════════════════════════════════════════════════════════╝
    APPEND 'DATA:' TO gt_code.
    LOOP AT gt_mapeamentos INTO DATA(lw_map) WHERE etapa = iw_etapa-etapa.
      DATA(lv_parameter) = COND #(
        WHEN lw_map-tabname IS NOT INITIAL
        THEN lw_map-tabname
        ELSE lw_map-param ).
      DATA(is_var) = COND #( WHEN lw_map-tabname IS INITIAL THEN true ELSE false ).
      IF line_exists( et_mapped_variables[ obj_para = lv_parameter ] ).
        CONTINUE.
      ENDIF.

      CASE lw_map-paramnat.
        WHEN 'I'.
          DATA(lv_varname) = COND #( WHEN lw_map-tabname IS INITIAL
                                     THEN |lv_{ lw_map-param }|
                                     ELSE |lw_{ lw_map-tabname }| ).

          IF is_var = false.
            READ TABLE it_import_parameter INTO DATA(lw_imp) WITH KEY parameter = lw_map-tabname.

            DATA(lv_reftype) = COND string( WHEN lw_imp-dbfield IS NOT INITIAL
                                            THEN lw_imp-dbfield
                                            ELSE lw_imp-typ ).

            APPEND |      { lv_varname }{ iw_etapa-etapa } TYPE { lv_reftype },| TO gt_code.

            APPEND VALUE #( etapa         = iw_etapa-etapa
                            vartype       = 'I'
*                            obj_de        = lw_map-tabname_from
                            obj_para      = lv_parameter
*                            obj_de_real   = |lw_{ lw_map-tabname_from }|
                            obj_para_real = lv_varname )
                   TO et_mapped_variables.
*            READ TABLE it_import_parameter INTO lw_imp WITH KEY parameter = |{ lw_map-tabname }X|.
*            IF sy-subrc EQ 0.
*              APPEND |      { lv_varname }{ iw_etapa-etapa }X TYPE { lw_imp-dbfield },| TO gt_code.
*
*              APPEND VALUE #( etapa         = iw_etapa-etapa
*                              vartype       = 'I'
**                              obj_de        = |{ lw_map-tabname_from }X|
*                              obj_para      = |{ lv_parameter }X|
**                              obj_de_real   = |lw_{ lw_map-tabname_from }X|
*                              obj_para_real = |{ lv_varname }X| )
*                     TO et_mapped_variables.
*            ENDIF.

          ELSE.
            IF lw_map-paramval IS NOT INITIAL.

*              APPEND |{ lv_varname } TYPE { lw_imp-dbfield },| TO gt_code."TODO se der exception de tipo usar o CONV

              APPEND VALUE #( etapa         = iw_etapa-etapa
                              vartype       = 'I'
*                              obj_de        = lw_map-param
                              obj_para      = lv_parameter
                              obj_para_real = |{ get_paramval( lw_map ) }| )
                     TO et_mapped_variables.
            ELSE.
              READ TABLE it_import_parameter INTO lw_imp WITH KEY parameter = lw_map-param.

              DATA(lv_vartype) = COND string( WHEN lw_imp-typ IS NOT INITIAL THEN lw_imp-typ ELSE lw_imp-dbfield ).
              APPEND |      lv_{ lv_parameter }{ iw_etapa-etapa } TYPE { lv_vartype },| TO gt_code.

              APPEND VALUE #( etapa         = iw_etapa-etapa
                              vartype       = 'I'
*                              obj_de        = lw_map-tabname_from
                              obj_para      = lv_parameter
*                              obj_de_real   = COND #( WHEN lw_map-tabname_from CS 'gw_' OR lw_map-tabname_from CS 'lw_' THEN lw_map-tabname_from ELSE |lw_{ lw_map-tabname_from }| )
                              obj_para_real = |lv_{ lv_parameter }| )
                     TO et_mapped_variables.

            ENDIF.
          ENDIF.

        WHEN 'E'.

          lv_varname = |lw_{ lw_map-tabname_from }|.

          IF is_var = false.
            READ TABLE it_export_parameter INTO DATA(lw_exp) WITH KEY parameter = lw_map-tabname.

            lv_reftype = COND string( WHEN lw_exp-dbfield IS NOT INITIAL
                                      THEN lw_exp-dbfield
                                      ELSE lw_exp-typ ).

            APPEND |{ lv_varname } TYPE { lv_reftype },| TO gt_code.

            APPEND VALUE #( vartype       = 'E'
                            obj_para      = lw_map-tabname_from
                            obj_para_real = lv_varname )
                   TO et_mapped_variables.

          ENDIF.
        WHEN 'T'.
          READ TABLE it_tables_parameter INTO DATA(lw_tab) WITH KEY parameter = lw_map-tabname.
          lv_reftype = COND string( WHEN lw_tab-dbstruct IS NOT INITIAL
                                    THEN lw_tab-dbstruct
                                    ELSE lw_tab-typ ).
          APPEND |lt_{ lw_map-tabname }{ iw_etapa-etapa } TYPE table of { lv_reftype },| TO gt_code.
          APPEND |lw_{ lw_map-tabname }{ iw_etapa-etapa } TYPE { lv_reftype },| TO gt_code.

          APPEND VALUE #( etapa         = iw_etapa-etapa
                          vartype       = 'T'
                          obj_para      = lv_parameter
                          obj_para_real = |lt_{ lw_map-tabname }| )
                 TO et_mapped_variables.
        WHEN OTHERS.

      ENDCASE.
    ENDLOOP.

    LOOP AT gt_dados INTO DATA(lw_dado) WHERE etapa_born = iw_etapa-etapa AND datanatu = 'EX'.
      IF lw_dado-reftype = 'T'.
        APPEND |lt_{ lw_dado-name }{ iw_etapa-etapa } TYPE TABLE OF { lw_dado-reftypname },| TO gt_code.
        APPEND |lw_{ lw_dado-name }{ iw_etapa-etapa } TYPE { lw_dado-reftypname },| TO gt_code.
      ELSE.
        APPEND |lw_{ lw_dado-name }{ iw_etapa-etapa } TYPE { lw_dado-reftypname },| TO gt_code.
      ENDIF.
    ENDLOOP.

    IF iw_etapa-after = 'R'.
      APPEND |      lt_return{ iw_etapa-etapa } TYPE TABLE OF bapiret2,| TO gt_code.
      APPEND |      lw_return{ iw_etapa-etapa } TYPE bapiret2,| TO gt_code.
    ENDIF.

    replace_last_comma_with_dot( ).
    " ╔════════════════════════════════════════════════════════════════════╗
    " ║                         ALIMENTAR VARIAVEIS                        ║
    " ╚════════════════════════════════════════════════════════════════════╝

    LOOP AT et_mapped_variables INTO DATA(lw_var).

      CASE lw_var-vartype.
        WHEN 'I'.
          IF lw_var-obj_para_real(1) = 'l'.
            APPEND |CLEAR { lw_var-obj_para_real }{ iw_etapa-etapa }.| TO gt_code.
          ENDIF.
          LOOP AT gt_mapeamentos INTO lw_map WHERE etapa = iw_etapa-etapa AND paramnat = 'I' AND ( tabname = lw_var-obj_para OR param = lw_var-obj_para ).
            IF lw_map-paramval IS NOT INITIAL.
              IF lw_map-tabname IS INITIAL.
                "BREAK-POINT. " CODIGO NAO FAZ SENTIDO
                "APPEND |{ lw_map-param }{ iw_etapa-etapa } = { get_paramval( lw_map ) }.| TO gt_code. Desativado pq esta criando variavel para valor fixo(lw_map-paramval)
              ELSE.
                APPEND |{ lw_var-obj_para_real }{ iw_etapa-etapa }-{ lw_map-param } = { get_paramval( lw_map ) }.| TO gt_code.
                IF lw_map-zeroleft = 'S'.
                  APPEND |CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'| TO gt_code.
                  APPEND |  EXPORTING| TO gt_code.
                  APPEND |      input  = { lw_var-obj_para_real }{ iw_etapa-etapa }-{ lw_map-param }| TO gt_code.
                  APPEND |  IMPORTING| TO gt_code.
                  APPEND |      output = { lw_var-obj_para_real }{ iw_etapa-etapa }-{ lw_map-param }.| TO gt_code.
                ELSEIF lw_map-zeroleft = 'N'.
                  APPEND |CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'| TO gt_code.
                  APPEND |  EXPORTING| TO gt_code.
                  APPEND |      input  = { lw_var-obj_para_real }{ iw_etapa-etapa }-{ lw_map-param }| TO gt_code.
                  APPEND |  IMPORTING| TO gt_code.
                  APPEND |      output = { lw_var-obj_para_real }{ iw_etapa-etapa }-{ lw_map-param }.| TO gt_code.
                ENDIF.
              ENDIF.
            ELSE.
              IF lw_map-tabname IS INITIAL.
                READ TABLE gt_dados INTO lw_dado WITH KEY name = lw_map-tabname_from.
                IF sy-subrc <> 0 AND lw_map-tabname_from CS 'gw_'.
                  APPEND |{ lw_var-obj_para_real }{ iw_etapa-etapa } = { lw_map-tabname_from }-{ lw_map-param_from }.| TO gt_code.
                ELSEIF lw_dado-etapa_born IS INITIAL.
                  APPEND |{ lw_var-obj_para_real }{ iw_etapa-etapa } = lw_{ lw_map-tabname_from }-{ lw_map-param_from }.| TO gt_code.
                ELSE.
                  APPEND |{ lw_var-obj_para_real }{ iw_etapa-etapa } = lw_{ lw_map-tabname_from }{ lw_dado-etapa_born }-{ lw_map-param_from }.| TO gt_code.
                ENDIF.
                IF lw_map-zeroleft = 'S'.
                  APPEND |CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'| TO gt_code.
                  APPEND |  EXPORTING| TO gt_code.
                  APPEND |      input  = { lw_var-obj_para_real }{ iw_etapa-etapa }| TO gt_code.
                  APPEND |  IMPORTING| TO gt_code.
                  APPEND |      output = { lw_var-obj_para_real }{ iw_etapa-etapa }.| TO gt_code.
                ELSEIF lw_map-zeroleft = 'N'.
                  APPEND |CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'| TO gt_code.
                  APPEND |  EXPORTING| TO gt_code.
                  APPEND |      input  = { lw_var-obj_para_real }{ iw_etapa-etapa }| TO gt_code.
                  APPEND |  IMPORTING| TO gt_code.
                  APPEND |      output = { lw_var-obj_para_real }{ iw_etapa-etapa }.| TO gt_code.
                ENDIF.
              ELSE.
                READ TABLE gt_dados INTO lw_dado WITH KEY name = lw_map-tabname_from.
                IF lw_dado-etapa_born IS INITIAL.
                  APPEND |{ lw_var-obj_para_real }{ iw_etapa-etapa }-{ lw_map-param } = lw_{ lw_map-tabname_from }-{ lw_map-param_from }.| TO gt_code.
                ELSE.
                  APPEND |{ lw_var-obj_para_real }{ iw_etapa-etapa }-{ lw_map-param } = lw_{ lw_map-tabname_from }{ lw_dado-etapa_born }-{ lw_map-param_from }.| TO gt_code.
                ENDIF.
                IF lw_map-zeroleft = 'S'.
                  APPEND |CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'| TO gt_code.
                  APPEND |  EXPORTING| TO gt_code.
                  APPEND |      input  = { lw_var-obj_para_real }{ iw_etapa-etapa }-{ lw_map-param }| TO gt_code.
                  APPEND |  IMPORTING| TO gt_code.
                  APPEND |      output = { lw_var-obj_para_real }{ iw_etapa-etapa }-{ lw_map-param }.| TO gt_code.
                ELSEIF lw_map-zeroleft = 'N'.
                  APPEND |CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'| TO gt_code.
                  APPEND |  EXPORTING| TO gt_code.
                  APPEND |      input  = { lw_var-obj_para_real }{ iw_etapa-etapa }-{ lw_map-param }| TO gt_code.
                  APPEND |  IMPORTING| TO gt_code.
                  APPEND |      output = { lw_var-obj_para_real }{ iw_etapa-etapa }-{ lw_map-param }.| TO gt_code.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        WHEN 'E'.

        WHEN 'T'.
          APPEND |lv_item = 0.| TO gt_code.
          READ TABLE gt_loop_tables INTO DATA(lw_compl) WITH KEY etapa = iw_etapa-etapa
                                                                 param = lw_var-obj_para.
          IF sy-subrc <> 0.
            CONTINUE.
            BREAK ibmoreira. " TODO - ERRO DE MAPEAMENTO
          ENDIF.
          CLEAR lw_dado.
          READ TABLE gt_dados INTO lw_dado WITH KEY name = lw_compl-param_from.
          IF lw_dado-etapa_born IS INITIAL.
            APPEND |LOOP AT lt_{ lw_compl-param_from } INTO lw_{ lw_compl-param_from }.| TO gt_code.
          ELSE.
            APPEND |LOOP AT lt_{ lw_compl-param_from }{ lw_dado-etapa_born } INTO lw_{ lw_compl-param_from }{ lw_dado-etapa_born }.| TO gt_code.
          ENDIF.
          LOOP AT gt_mapeamentos INTO lw_map WHERE etapa = iw_etapa-etapa AND paramnat = 'T' AND tabname = lw_var-obj_para.
            IF lw_map-param_from = 'ITEM'.
              APPEND |ADD 10 TO lv_item.| TO gt_code.
              APPEND |lw_{ lw_map-tabname }{ iw_etapa-etapa }-{ lw_map-param } = lv_item.| TO gt_code.
            ELSE.
              IF lw_map-paramval IS NOT INITIAL.
                APPEND |lw_{ lw_map-tabname }{ iw_etapa-etapa }-{ lw_map-param } = { get_paramval( lw_map ) }.| TO gt_code.
              ELSE.
                READ TABLE gt_dados INTO lw_dado WITH KEY name = lw_map-tabname_from.
                IF lw_dado-etapa_born IS INITIAL.
                  APPEND |lw_{ lw_map-tabname }{ iw_etapa-etapa }-{ lw_map-param } = lw_{ lw_map-tabname_from }-{ lw_map-param_from }.| TO gt_code.
                ELSE.
                  APPEND |lw_{ lw_map-tabname }{ iw_etapa-etapa }-{ lw_map-param } = lw_{ lw_map-tabname_from }{ lw_dado-etapa_born }-{ lw_map-param_from }.| TO gt_code.
                ENDIF.
              ENDIF.
              IF lw_map-zeroleft = 'S'.
                APPEND |CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'| TO gt_code.
                APPEND |  EXPORTING| TO gt_code.
                APPEND |      input  = lw_{ lw_map-tabname }{ iw_etapa-etapa }-{ lw_map-param }| TO gt_code.
                APPEND |  IMPORTING| TO gt_code.
                APPEND |      output = lw_{ lw_map-tabname }{ iw_etapa-etapa }-{ lw_map-param }.| TO gt_code.
              ELSEIF lw_map-zeroleft = 'N'.
                APPEND |CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'| TO gt_code.
                APPEND |  EXPORTING| TO gt_code.
                APPEND |      input  = lw_{ lw_map-tabname }{ iw_etapa-etapa }-{ lw_map-param }| TO gt_code.
                APPEND |  IMPORTING| TO gt_code.
                APPEND |      output = lw_{ lw_map-tabname }{ iw_etapa-etapa }-{ lw_map-param }.| TO gt_code.
              ENDIF.
            ENDIF.
          ENDLOOP.
          APPEND |APPEND lw_{ lw_map-tabname }{ iw_etapa-etapa } TO lt_{ lw_map-tabname }{ iw_etapa-etapa }.| TO gt_code.
          APPEND |ENDLOOP.| TO gt_code.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
*            APPEND VALUE #( parameter      = lv_parameter
*                            reftype        = lw_map-reftype
*                            paramnat       = 'I'
*                            paramtyp       = lw_map-paramtyp
*                            nome_declarado = COND #( WHEN lw_map-tabname IS INITIAL THEN |lw_{ lw_map-param }| ELSE |lt_{ lw_map-param }| )
*                            data_origin    = lv_parameter ) TO et_declare_vars.
*    LOOP AT it_export_parameter INTO DATA(lw_exp).
*
*      IF line_exists( et_declare_vars[ parameter = lw_exp-paramname ] ).
*        CONTINUE.
*      ENDIF.
*
*      APPEND VALUE #( parameter      = lw_exp-paramname
*                      reftype        = lw_exp-reftype
*                      paramnat       = 'I'
*                      paramtyp       = lw_exp-paramtype
*                      nome_declarado = COND #( WHEN lw_map-tabname IS INITIAL THEN |lw_{ lw_exp-paramname }| ELSE |lt_{ lw_exp-paramname }| )
*                      data_origin    = lv_parameter ) TO et_declare_vars.
  ENDMETHOD.

  METHOD codegen_call_function.
    APPEND |has_error = abap_false.| TO gt_code.
    APPEND |TRY.| TO gt_code.
    APPEND |CALL FUNCTION '{ iw_etapa-rotin }'| TO gt_code.

    IF line_exists( it_mapped_variables[ etapa   = iw_etapa-etapa
                                         vartype = 'I' ] ) OR line_exists( gt_atribuicao[ etapa      = iw_etapa-etapa
                                                                                          param_natu = 'I' ] ).
      APPEND 'EXPORTING' TO gt_code.
      LOOP AT it_mapped_variables INTO DATA(lw_vars) WHERE vartype = 'I'.
        IF lw_vars-obj_para_real(1) EQ |'|.
          APPEND |{ lw_vars-obj_para } = { lw_vars-obj_para_real }| TO gt_code.
        ELSE.
          APPEND |{ lw_vars-obj_para } = { lw_vars-obj_para_real }{ iw_etapa-etapa }| TO gt_code.
        ENDIF.
      ENDLOOP.
      LOOP AT gt_atribuicao INTO DATA(lw_compl) WHERE etapa = iw_etapa-etapa AND reftype = 'S' AND param_natu = 'I'.
        READ TABLE gt_dados INTO DATA(lw_dado) WITH KEY name = lw_compl-param_from.
        IF lw_dado-etapa_born IS INITIAL.
          APPEND |{ lw_compl-param } = lw_{ lw_dado-name }| TO gt_code.
        ELSE.
          APPEND |{ lw_compl-param } = lw_{ lw_dado-name }{ lw_dado-etapa_born }| TO gt_code.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF line_exists( gt_mapeamentos[ etapa    = iw_etapa-etapa
                                    paramnat = 'E' ] ) OR line_exists( gt_atribuicao[ etapa      = iw_etapa-etapa
                                                                                      param_natu = 'E' ] ).
      APPEND 'IMPORTING' TO gt_code.
      LOOP AT gt_mapeamentos INTO DATA(lw_map) WHERE etapa = iw_etapa-etapa AND paramnat = 'E'.
        DATA(lv_base) = COND string(
          WHEN lw_map-tabname_from CS 'GW_'
          THEN lw_map-tabname_from
          ELSE |lw_{ lw_map-tabname_from }| ).
        CASE lw_map-paramtyp.
          WHEN 'V'.
            APPEND |{ lw_map-param } = { lv_base }-{ lw_map-param_from }|
                   TO gt_code.
          WHEN 'S'.
            APPEND |{ lw_map-tabname } = { lv_base }|
                   TO gt_code.
          WHEN 'T'.
            DATA(lv_table) = COND string(
              WHEN lw_map-tabname_from CS 'GW_'
              THEN lw_map-tabname_from
              ELSE |lt_{ lw_map-tabname_from }| ).
            APPEND |{ lw_map-tabname } = { lv_table }|
                   TO gt_code.
        ENDCASE.
      ENDLOOP.
      LOOP AT gt_atribuicao INTO lw_compl WHERE etapa = iw_etapa-etapa AND reftype = 'S' AND param_natu = 'E'.
        READ TABLE gt_dados INTO lw_dado WITH KEY name = lw_compl-param_from.
        IF sy-subrc <> 0 AND lw_compl-param_from CS 'gw_'.
          APPEND |{ lw_compl-param } = { lw_dado-name }| TO gt_code.
        ELSEIF lw_dado-etapa_born IS INITIAL.
          APPEND |{ lw_compl-param } = lw_{ lw_dado-name }| TO gt_code.
        ELSE.
          APPEND |{ lw_compl-param } = lw_{ lw_dado-name }{ lw_dado-etapa_born }| TO gt_code.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF line_exists( it_mapped_variables[ etapa   = iw_etapa-etapa
                                         vartype = 'T' ] ) OR iw_etapa-after = 'R' OR line_exists(
                                             gt_atribuicao[ etapa      = iw_etapa-etapa
                                                            param_natu = 'T' ] ).
      APPEND 'TABLES' TO gt_code.
      LOOP AT it_mapped_variables INTO lw_vars WHERE vartype = 'T'.
        APPEND |{ lw_vars-obj_para } = { lw_vars-obj_para_real }{ iw_etapa-etapa }| TO gt_code.
      ENDLOOP.
      LOOP AT gt_atribuicao INTO lw_compl WHERE etapa = iw_etapa-etapa AND reftype = 'T' AND param_natu = 'T'.
        READ TABLE gt_dados INTO lw_dado WITH KEY name = lw_compl-param_from.
        IF sy-subrc <> 0 AND lw_compl-param_from CS 'gw_'.
          APPEND |{ lw_compl-param } = { lw_dado-name }| TO gt_code.
        ELSEIF lw_dado-etapa_born IS INITIAL.
          APPEND |{ lw_compl-param } = lt_{ lw_dado-name }| TO gt_code.
        ELSE.
          APPEND |{ lw_compl-param } = lt_{ lw_dado-name }{ lw_dado-etapa_born }| TO gt_code.
        ENDIF.
      ENDLOOP.
      IF iw_etapa-after = 'R'.
        APPEND |return = lt_return{ iw_etapa-etapa }| TO gt_code.
      ENDIF.
    ENDIF.
    APPEND '.' TO gt_code.
    APPEND |CATCH cx_root INTO lx_root.| TO gt_code.
    CASE iw_etapa-after.
      WHEN 'R'. " Tratamento da tabela return
        APPEND |  APPEND VALUE #( type = 'E' message = lx_root->get_text( ) ) TO lt_return{ iw_etapa-etapa }.| TO gt_code.
      WHEN abap_false.
        APPEND |    CLEAR gw_logs.| TO gt_code.
        APPEND |    gw_logs-auto  = '{ gv_chave+6(2) }' .| TO gt_code.
        APPEND |    gw_logs-opera = '{ gv_chave+8(3) }'.| TO gt_code.
        APPEND |    gw_logs-credat = sy-datum.| TO gt_code.
        APPEND |    gw_logs-cretim = sy-uzeit.| TO gt_code.
        APPEND |    gw_logs-chave = '{ gv_chave }'.| TO gt_code.
        APPEND |    gw_logs-etapa = '{ iw_etapa-etapa }'.| TO gt_code.
        APPEND |    gw_logs-message = lx_root->get_text( ).| TO gt_code.
        APPEND |    gw_logs-type = 'E'.| TO gt_code.
        APPEND |    INSERT /gjaauto/mttb002 FROM gw_logs.| TO gt_code.
      WHEN OTHERS.
        " Lógica padrão ou nenhuma ação
    ENDCASE.
    APPEND |  has_error = abap_true.| TO gt_code.
    APPEND |ENDTRY.| TO gt_code.
  ENDMETHOD.

  METHOD codegen_after_call_function.
    CASE iw_etapa-after.
      WHEN 'R'. " Tratamento da tabela return
        APPEND |IF gw_etapa-WAITM is initial.| TO gt_code.
        APPEND |  lv_item = 0.| TO gt_code.
        APPEND |  LOOP AT lt_return{ iw_etapa-etapa } INTO lw_return{ iw_etapa-etapa }.| TO gt_code.
        APPEND |    ADD 1 TO lv_item.| TO gt_code.
        APPEND |    CLEAR gw_logs.| TO gt_code.
        APPEND |    MOVE-CORRESPONDING lw_return{ iw_etapa-etapa } TO gw_logs.| TO gt_code.
        APPEND |    gw_logs-auto  = '{ gv_chave+6(2) }' .| TO gt_code.
        APPEND |    gw_logs-opera = '{ gv_chave+8(3) }'.| TO gt_code.
        APPEND |    gw_logs-credat = sy-datum.| TO gt_code.
        APPEND |    gw_logs-cretim = sy-uzeit.| TO gt_code.
        APPEND |    gw_logs-chave = '{ gv_chave }'.| TO gt_code.
        APPEND |    gw_logs-etapa = '{ iw_etapa-etapa }'.| TO gt_code.
        APPEND |    gw_logs-item  = lv_item.| TO gt_code.
        APPEND |    gw_logs-number_msg = lw_return{ iw_etapa-etapa }-number.| TO gt_code.
        APPEND |    gw_logs-parameter_name = lw_return{ iw_etapa-etapa }-parameter.| TO gt_code.
        APPEND |    gw_logs-row_param = lw_return{ iw_etapa-etapa }-row.| TO gt_code.
        APPEND |    gw_logs-system_log = lw_return{ iw_etapa-etapa }-system.| TO gt_code.
        APPEND |    INSERT /gjaauto/mttb002 FROM gw_logs.| TO gt_code.
        APPEND |    IF lw_return{ iw_etapa-etapa }-type = 'E' or lw_return{ iw_etapa-etapa }-type = 'A'.| TO gt_code.
        APPEND |        has_error = abap_true.| TO gt_code.
        APPEND |    ENDIF.| TO gt_code.
        APPEND |  ENDLOOP.| TO gt_code.
        APPEND |ENDIF.| TO gt_code.
      WHEN OTHERS.
        " Lógica padrão ou nenhuma ação
    ENDCASE.

    APPEND |IF has_error = abap_true.| TO gt_code.
    APPEND |    UPDATE /GJAAUTO/MTTB001 SET status = '3'| TO gt_code.
    APPEND |     WHERE AUTO  eq '{ gv_chave+6(2) }'| TO gt_code.
    APPEND |       and OPERA eq '{ gv_chave+8(3) }'| TO gt_code.
    APPEND |       and CHAVE eq '{ gv_chave }'.| TO gt_code.

    APPEND |    UPDATE /GJAAUTO/MTTB003 SET status = '3'| TO gt_code.
    APPEND |     WHERE AUTO  eq '{ gv_chave+6(2) }'| TO gt_code.
    APPEND |       and OPERA eq '{ gv_chave+8(3) }'| TO gt_code.
    APPEND |       and CHAVE eq '{ gv_chave }'| TO gt_code.
    APPEND |       and ETAPA eq '{ iw_etapa-etapa }'.| TO gt_code.
    APPEND |    COMMIT WORK AND WAIT.| TO gt_code.
    APPEND |    EXIT. | TO gt_code.
    APPEND |ELSE. | TO gt_code.
    IF line_exists( gt_mapeamentos[ etapa        = iw_etapa-etapa
                                    tabname_from = 'VARIAVEIS' ] ).
      READ TABLE gt_dados INTO DATA(lw_dado_var) WITH KEY name = 'VARIAVEIS'.
      APPEND | SELECT COUNT(*) from { lw_dado_var-reftypname } where chave eq '{ gv_chave }'.| TO gt_code.
      APPEND | IF sy-subrc eq 0.| TO gt_code.
      APPEND |   MODIFY { lw_dado_var-reftypname } FROM lw_variaveis.| TO gt_code.
      APPEND | ELSE.| TO gt_code.
      APPEND |   lw_variaveis-chave = '{ gv_chave }'.| TO gt_code.
      APPEND |   INSERT { lw_dado_var-reftypname } FROM lw_variaveis.| TO gt_code.
      APPEND | ENDIF.| TO gt_code.
    ENDIF.

    APPEND |    IF gw_etapa-WAITM is not initial.| TO gt_code.
    APPEND |     UPDATE /GJAAUTO/MTTB001 SET status = '0'| TO gt_code.
    APPEND |      WHERE AUTO  EQ '{ gv_chave+6(2) }'| TO gt_code.
    APPEND |        AND OPERA EQ '{ gv_chave+8(3) }'| TO gt_code.
    APPEND |        AND CHAVE EQ '{ gv_chave }'.| TO gt_code.
    APPEND |     UPDATE /GJAAUTO/MTTB003 SET status = '4' WAITM = gw_etapa-WAITM| TO gt_code.
    APPEND |      WHERE AUTO  EQ '{ gv_chave+6(2) }'| TO gt_code.
    APPEND |        AND OPERA EQ '{ gv_chave+8(3) }'| TO gt_code.
    APPEND |        AND CHAVE EQ '{ gv_chave }'| TO gt_code.
    APPEND |        AND ETAPA EQ '{ iw_etapa-etapa }'.| TO gt_code.
    APPEND |     SELECT SINGLE * | TO gt_code.
    APPEND |       INTO gw_logs | TO gt_code.
    APPEND |       FROM /gjaauto/mttb002 | TO gt_code.
    APPEND |      WHERE AUTO  EQ '{ gv_chave+6(2) }'| TO gt_code.
    APPEND |        AND OPERA EQ '{ gv_chave+8(3) }'| TO gt_code.
    APPEND |        AND CHAVE EQ '{ gv_chave }'| TO gt_code.
    APPEND |        AND TYPE  EQ 'W'| TO gt_code.
    APPEND |        AND ETAPA EQ '{ iw_etapa-etapa }'.| TO gt_code.
    APPEND |    IF sy-subrc eq 0.| TO gt_code.
    APPEND |     DELETE FROM /GJAAUTO/MTTB002| TO gt_code.
    APPEND |      WHERE AUTO  EQ '{ gv_chave+6(2) }'| TO gt_code.
    APPEND |        AND OPERA EQ '{ gv_chave+8(3) }'| TO gt_code.
    APPEND |        AND CHAVE EQ '{ gv_chave }'| TO gt_code.
    APPEND |        AND type  EQ 'W'| TO gt_code.
    APPEND |        AND ETAPA EQ '{ iw_etapa-etapa }'.| TO gt_code.
    APPEND |    ENDIF.| TO gt_code.
    APPEND |    CLEAR gw_logs.| TO gt_code.
    APPEND |    gw_logs-auto  = '{ gv_chave+6(2) }' .| TO gt_code.
    APPEND |    gw_logs-opera = '{ gv_chave+8(3) }'.| TO gt_code.
    APPEND |    gw_logs-credat = sy-datum.| TO gt_code.
    APPEND |    gw_logs-cretim = sy-uzeit.| TO gt_code.
    APPEND |    gw_logs-chave = '{ gv_chave }'.| TO gt_code.
    APPEND |    gw_logs-etapa = '{ iw_etapa-etapa }'.| TO gt_code.
    APPEND |    gw_logs-type = 'W'.| TO gt_code.
    APPEND |    SELECT SINGLE WAITT FROM /GJAAUTO/CKTB009 INTO gw_logs-MESSAGE WHERE WAITM EQ gw_etapa-WAITM.| TO gt_code.
    APPEND |    INSERT /gjaauto/mttb002 FROM gw_logs.| TO gt_code.
    APPEND |     COMMIT WORK AND WAIT.| TO gt_code.
    APPEND |     EXIT.| TO gt_code.
    APPEND |    ELSE.| TO gt_code.
    APPEND |     UPDATE /GJAAUTO/MTTB003 SET status = '2'| TO gt_code.
    APPEND |      WHERE AUTO  EQ '{ gv_chave+6(2) }'| TO gt_code.
    APPEND |        AND OPERA EQ '{ gv_chave+8(3) }'| TO gt_code.
    APPEND |        AND CHAVE EQ '{ gv_chave }'| TO gt_code.
    APPEND |        AND ETAPA EQ '{ iw_etapa-etapa }'.| TO gt_code.
    APPEND |     COMMIT WORK AND WAIT.| TO gt_code.
    APPEND |    ENDIF.| TO gt_code.
    APPEND |ENDIF.| TO gt_code.
    APPEND |*┌─────────────────────────────────────────────────────────────────────*| TO gt_code.
    APPEND |*│ FIM ETAPA -> { iw_etapa-etapa ALPHA = OUT }| TO gt_code.
    APPEND |*└─────────────────────────────────────────────────────────────────────*| TO gt_code.
  ENDMETHOD.

  METHOD factory.
    APPEND |REPORT Z{ gv_chave }.| TO gt_code.

    " Carrega configuração da automação
    load_auto_data( ).

    " Declara as variveis globais
    codegen_init_data_definition( ).

    " Seleciona dados iniciais
    codegen_select_initial_data( ).

    " Gera código para cada etapa
    LOOP AT gt_etapas INTO DATA(lw_etapa).

      READ TABLE gt_etapas_exec INTO DATA(lw_etapa_exec) WITH KEY etapa = lw_etapa-etapa.

      IF     ( lw_etapa_exec-status = 2 OR lw_etapa_exec-status = 5 ) " Pula etapas já executadas ou ignoradas
         AND xsdbool( line_exists( gt_regras_etapa[ etapa     = lw_etapa-etapa " Regra de forçar execução da etapa
                                                    exec_rule = 01 ] ) ) = false
         AND xsdbool(  line_exists( gt_etapa_dependentes[ etapa_required = lw_etapa-etapa ] )  ) = false. " Regra de forçar execução da etapa caso haja dependente
        CONTINUE.
      ENDIF.

      SELECT COUNT(*) FROM /gjaauto/mttb002
        WHERE auto  = gv_chave+6(2)
          AND opera = gv_chave+8(3)
          AND chave = gv_chave
          AND etapa = lw_etapa-etapa.
      IF sy-subrc = 0.
        DELETE FROM /gjaauto/mttb002
         WHERE auto  = gv_chave+6(2)
           AND opera = gv_chave+8(3)
           AND chave = gv_chave
           AND etapa = lw_etapa-etapa.
      ENDIF.

      " Constroi o codigo da etapa
      codegen_etapa( iw_etapa = lw_etapa ).

    ENDLOOP.

    APPEND | UPDATE /gjaauto/mttb001 SET status = '2' | TO gt_code.
    APPEND |  WHERE auto = '{ gv_chave+6(2) }'| TO gt_code.
    APPEND |    AND opera = '{ gv_chave+8(3) }'| TO gt_code.
    APPEND |    AND chave = '{ gv_chave }'.| TO gt_code.
    APPEND | COMMIT WORK AND WAIT. | TO gt_code.

    CALL FUNCTION 'PRETTY_PRINTER'
      EXPORTING inctoo = 'X'
      TABLES    ntext  = gt_code
                otext  = gt_code.

    et_code = gt_code.
  ENDMETHOD.

  METHOD get_paramval.
    DATA(lv_raw_value) = is_mapeamento-paramval.

    "----------------------------------------------------------------------
    " Regra 1: Identificar e tratar Expression (${...})
    "----------------------------------------------------------------------
    IF lv_raw_value CP '${*}'.

      " Remove delimitadores ${ e }
      rv_paramval = substring( val = lv_raw_value
                               off = 2
                               len = strlen( lv_raw_value ) - 3 ).
    ELSE.

      " Valor literal deve ser retornado entre aspas
      rv_paramval = |'{ lv_raw_value }'|.

    ENDIF.

    CONDENSE rv_paramval.
  ENDMETHOD.
ENDCLASS.
