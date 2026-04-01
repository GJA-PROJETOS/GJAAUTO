"======================================================================
" Classe de extensão OData DPC para automação
" Responsável pelo processamento de entidades OData do serviço /gjaauto/
" Refatorado seguindo princípios Clean Core e ABAP 7.5+
"======================================================================
CLASS /gjaauto/cl_main_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM /gjaauto/cl_main_dpc
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS /iwbep/if_mgw_appl_srv_runtime~get_expanded_entity   REDEFINITION.
    METHODS /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset REDEFINITION.

  PROTECTED SECTION.
    METHODS execautomacao_create_entity    REDEFINITION.
    METHODS importparameters_get_entityset REDEFINITION.
    METHODS keysautomacao_get_entityset    REDEFINITION.

  PRIVATE SECTION.

    TYPES:
      "----------------------------------------------------------------------
      " Tipos locais para modularização
      "----------------------------------------------------------------------
      BEGIN OF ty_domain_info,
        domname   TYPE dd01l-domname,
        decimals  TYPE dd01l-decimals,
        leng      TYPE dd01l-leng,
        datatype  TYPE dd01l-datatype,
        valexi    TYPE dd01l-valexi,
        entitytab TYPE dd01l-entitytab,
      END OF ty_domain_info .

    "----------------------------------------------------------------------
    " Constantes para legibilidade e manutenção
    "----------------------------------------------------------------------
    CONSTANTS gc_job_name TYPE tbtcjob-jobname VALUE '/GJAAUTO/EXEC_AUTO' ##NO_TEXT.
    CONSTANTS gc_tipo_tabela TYPE trobjtype VALUE 'TABL' ##NO_TEXT.
    CONSTANTS gc_tipo_dominio TYPE trobjtype VALUE 'DOMA' ##NO_TEXT.
    CONSTANTS gc_tipo_elemento_de_dados TYPE trobjtype VALUE 'DTEL' ##NO_TEXT.
    CONSTANTS gc_lang_english TYPE sylangu VALUE 'E' ##NO_TEXT.

    "----------------------------------------------------------------------
    " Métodos auxiliares para eliminar redundância
    "----------------------------------------------------------------------
    " Obtém descrição do elemento de dados priorizando idioma do usuário
    METHODS get_data_element_description
      IMPORTING
        !iv_rollname   TYPE rollname
      RETURNING
        VALUE(rv_desc) TYPE as4text .
    " Obtém descrição do domínio priorizando idioma do usuário
    METHODS get_domain_description
      IMPORTING
        !iv_domname    TYPE domname
      RETURNING
        VALUE(rv_desc) TYPE as4text .
    " Processa valores fixos de domínio e adiciona à estrutura
    METHODS process_domain_fixed_values
      IMPORTING
        !iv_domname        TYPE domname
        !iv_param          TYPE string
        !iv_fieldname      TYPE fieldname OPTIONAL
      CHANGING
        !ct_fixvaluesitems TYPE /gjaauto/cl_main_mpc=>tt_fixvalueitems .
    " Processa valores de tabela de verificação (check table)
    METHODS process_check_table_values
      IMPORTING
        !iv_field1         TYPE fieldname
        !iv_field2         TYPE fieldname
        !iv_table          TYPE tabname
        !iv_param          TYPE string
      CHANGING
        !ct_fixvaluesitems TYPE /gjaauto/cl_main_mpc=>tt_fixvalueitems .
    " Processa documentação de Function Module
    METHODS process_function_import_doku
      IMPORTING
        !iv_funcname     TYPE rs38l_fnam
        !iv_language     TYPE sylangu
      RETURNING
        VALUE(rs_result) TYPE /gjaauto/cl_main_mpc_ext=>ts_functionimportdoku_deep .
    " Processa documentação de parâmetro tipo tabela
    METHODS process_param_table_type
      IMPORTING
        !iv_param        TYPE string
        !iv_datatype     TYPE string
      RETURNING
        VALUE(rs_result) TYPE /gjaauto/cl_main_mpc_ext=>ts_parameterdoku_deep .
    " Processa documentação de parâmetro tipo variável (Domínio/DTEL)
    METHODS process_param_variable_type
      IMPORTING
        !iv_param        TYPE string
        !iv_datatype     TYPE string
        !iv_object_type  TYPE trobjtype
      RETURNING
        VALUE(rs_result) TYPE /gjaauto/cl_main_mpc_ext=>ts_parameterdoku_deep .
ENDCLASS.



CLASS /GJAAUTO/CL_MAIN_DPC_EXT IMPLEMENTATION.


  METHOD keysautomacao_get_entityset.
    "----------------------------------------------------------------------
    " Retorna os campos e valores de uma chave de automação dinâmica
    "----------------------------------------------------------------------
    DATA lr_data TYPE REF TO data.
    FIELD-SYMBOLS <ls_data_line> TYPE any.

    " Extrai a chave do filtro OData
    DATA(lv_chave) = it_filter_select_options[ property = 'Chave' ]-select_options[ 1 ]-low.

    " Busca configuração da automação para obter a tabela de referência
    SELECT SINGLE reftypname FROM /gjaauto/cktb005
      INTO @DATA(lv_reftypname)
      WHERE auto  = @lv_chave+6(2)
        AND opera = @lv_chave+8(3)
        AND name  = 'VARIAVEIS'.

    IF sy-subrc <> 0.
      RETURN. " Configuração não encontrada
    ENDIF.

    " Obtém lista de campos da tabela dinâmica
    SELECT fieldname FROM dd03l
      INTO TABLE @DATA(lt_fields)
      WHERE tabname  = @lv_reftypname
        AND as4local = 'A'.

    " Cria estrutura dinâmica e lê os dados
    CREATE DATA lr_data TYPE (lv_reftypname).
    ASSIGN lr_data->* TO <ls_data_line>.

    SELECT SINGLE * FROM (lv_reftypname)
      INTO @<ls_data_line>
      WHERE chave = @lv_chave.

    " Monta o entityset com os campos e valores
    LOOP AT lt_fields INTO DATA(lw_field).
      ASSIGN COMPONENT lw_field-fieldname OF STRUCTURE <ls_data_line>
        TO FIELD-SYMBOL(<lv_field_value>).
      IF sy-subrc = 0.
        APPEND VALUE #(
          chave        = lv_chave
          keyfieldname = lw_field-fieldname
          value        = <lv_field_value> ) TO et_entityset.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD execautomacao_create_entity.
    "----------------------------------------------------------------------
    " Executa automação em background via Job
    "----------------------------------------------------------------------
    DATA lv_jobcount TYPE tbtcjob-jobcount.

    " Lê dados do payload OData
    DATA(ls_input) = VALUE /gjaauto/cl_main_mpc=>ts_execautomacao( ).
    io_data_provider->read_entry_data( IMPORTING es_data = ls_input ).

    IF ls_input-chave IS INITIAL.
      RETURN.
    ELSEIF ls_input-chave EQ 'ALL'.
      SUBMIT /gjaauto/mtj0002.
    ELSE.


      " Abre o Job para execução em background
      CALL FUNCTION 'JOB_OPEN'
        EXPORTING
          jobname  = gc_job_name
        IMPORTING
          jobcount = lv_jobcount
        EXCEPTIONS
          OTHERS   = 1.

      CHECK sy-subrc = 0.

      " Submete o programa de automação
      SUBMIT /gjaauto/mtj0002
        WITH p_chave = ls_input-chave
        USER sy-uname
        VIA JOB gc_job_name
        NUMBER lv_jobcount
        AND RETURN.

      " Fecha e inicia o Job imediatamente
      CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
          jobname   = gc_job_name
          jobcount  = lv_jobcount
          strtimmed = abap_true
        EXCEPTIONS
          OTHERS    = 1.

    ENDIF.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entity.
    "----------------------------------------------------------------------
    " Processa entidades expandidas (deep entity)
    "----------------------------------------------------------------------
    DATA ls_param_doku TYPE /gjaauto/cl_main_mpc_ext=>ts_parameterdoku_deep.

    CASE iv_entity_name.
      WHEN 'FunctionImportDoku'.
        " Processa documentação de Function Module
        DATA(lv_funcname) = CONV rs38l_fnam( it_key_tab[ name = 'Funcname' ]-value ).

        " Obtém idioma com fallback para idioma do sistema
        DATA lv_language TYPE sylangu.
        TRY.
            lv_language = it_key_tab[ name = 'Language' ]-value.
          CATCH cx_sy_itab_line_not_found.
            lv_language = sy-langu.
        ENDTRY.

        DATA(ls_func_doku) = process_function_import_doku(
          iv_funcname = lv_funcname
          iv_language = lv_language ).

        copy_data_to_ref( EXPORTING is_data = ls_func_doku
                          CHANGING  cr_data = er_entity ).

      WHEN 'ParameterDoku'.
        " Processa documentação de parâmetro
        DATA(lv_param)    = it_key_tab[ name = 'Param' ]-value.
        DATA(lv_datatype) = it_key_tab[ name = 'DataType' ]-value.

        REPLACE ALL OCCURRENCES OF '\' IN lv_datatype WITH '/'.

        " Identifica o tipo do objeto no repositório
        SELECT SINGLE object FROM tadir
          INTO @DATA(lv_object_type)
          WHERE obj_name = @lv_datatype
            AND object IN ( @gc_tipo_tabela, @gc_tipo_dominio, @gc_tipo_elemento_de_dados ).

        " Processa conforme tipo (Tabela ou Variável)
        ls_param_doku = COND #(
          WHEN lv_object_type = gc_tipo_tabela
          THEN process_param_table_type( iv_param = lv_param iv_datatype = lv_datatype )
          ELSE process_param_variable_type(
                 iv_param       = lv_param
                 iv_datatype    = lv_datatype
                 iv_object_type = lv_object_type ) ).

        " Completa campos de identificação
        ls_param_doku-param    = lv_param.
        ls_param_doku-datatype = lv_datatype.

        copy_data_to_ref( EXPORTING is_data = ls_param_doku
                          CHANGING  cr_data = er_entity ).

      WHEN OTHERS.
        " Entidade não suportada - ignora silenciosamente
    ENDCASE.
  ENDMETHOD.


  METHOD importparameters_get_entityset.
    "----------------------------------------------------------------------
    " Método mantido para compatibilidade - sem implementação necessária
    "----------------------------------------------------------------------
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.
    "----------------------------------------------------------------------
    " Método mantido para compatibilidade - sem implementação necessária
    "----------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_data_element_description.
    "----------------------------------------------------------------------
    " Obtém descrição do elemento de dados com fallback de idioma
    " Prioridade: Idioma usuário > Inglês > Primeiro disponível
    "----------------------------------------------------------------------
    IF iv_rollname IS INITIAL.
      RETURN.
    ENDIF.

    SELECT ddlanguage, ddtext, reptext, scrtext_l, scrtext_m, scrtext_s
      FROM dd04t
      INTO TABLE @DATA(lt_dd04t)
      WHERE rollname = @iv_rollname.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " Seleciona registro conforme prioridade de idioma
    DATA(lw_desc) = VALUE #(
      lt_dd04t[ ddlanguage = sy-langu ] OPTIONAL ).

    IF lw_desc IS INITIAL.
      lw_desc = VALUE #( lt_dd04t[ ddlanguage = gc_lang_english ] OPTIONAL ).
    ENDIF.

    IF lw_desc IS INITIAL.
      lw_desc = VALUE #( lt_dd04t[ 1 ] OPTIONAL ).
    ENDIF.

    " Retorna primeira descrição disponível
    rv_desc = COND #(
      WHEN lw_desc-ddtext IS NOT INITIAL    THEN lw_desc-ddtext
      WHEN lw_desc-reptext IS NOT INITIAL   THEN lw_desc-reptext
      WHEN lw_desc-scrtext_l IS NOT INITIAL THEN lw_desc-scrtext_l
      WHEN lw_desc-scrtext_m IS NOT INITIAL THEN lw_desc-scrtext_m
      WHEN lw_desc-scrtext_s IS NOT INITIAL THEN lw_desc-scrtext_s ).
  ENDMETHOD.


  METHOD get_domain_description.
    "----------------------------------------------------------------------
    " Obtém descrição do domínio com fallback de idioma
    "----------------------------------------------------------------------
    IF iv_domname IS INITIAL.
      RETURN.
    ENDIF.

    SELECT ddlanguage, ddtext FROM dd01t
      INTO TABLE @DATA(lt_dd01t)
      WHERE domname = @iv_domname.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " Prioridade: Idioma usuário > Inglês > Primeiro
    rv_desc = COND #(
      WHEN line_exists( lt_dd01t[ ddlanguage = sy-langu ] )
        THEN lt_dd01t[ ddlanguage = sy-langu ]-ddtext
      WHEN line_exists( lt_dd01t[ ddlanguage = gc_lang_english ] )
        THEN lt_dd01t[ ddlanguage = gc_lang_english ]-ddtext
      ELSE lt_dd01t[ 1 ]-ddtext ).
  ENDMETHOD.


  METHOD process_domain_fixed_values.
    "----------------------------------------------------------------------
    " Processa valores fixos de domínio e adiciona à tabela de resultados
    "----------------------------------------------------------------------
    DATA lt_domvalues TYPE STANDARD TABLE OF dd07v.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname   = iv_domname
        text      = abap_true
        langu     = sy-langu
      TABLES
        dd07v_tab = lt_domvalues
      EXCEPTIONS
        OTHERS    = 1.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " Adiciona valores fixos usando expressão FOR
    ct_fixvaluesitems = VALUE #( BASE ct_fixvaluesitems
      FOR lw_domval IN lt_domvalues
      ( text      = lw_domval-ddtext
        param     = iv_param
        value     = lw_domval-domvalue_l
        valpos    = lw_domval-valpos
        fieldname = iv_fieldname ) ).
  ENDMETHOD.


  METHOD process_check_table_values.
    "----------------------------------------------------------------------
    " Processa valores de tabela de verificação dinâmica
    "----------------------------------------------------------------------
    DATA lr_data TYPE REF TO data.
    FIELD-SYMBOLS <lt_table> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_line>  TYPE any.
    FIELD-SYMBOLS <lv_value> TYPE any.

    " Cria tabela dinâmica baseada na check table
    CREATE DATA lr_data TYPE STANDARD TABLE OF (iv_table).
    ASSIGN lr_data->* TO <lt_table>.
    DATA(lv_fieldname) = iv_field1.

    TRY.
        " Seleciona apenas o campo necessário
        SELECT (lv_fieldname)
          FROM (iv_table)
          INTO CORRESPONDING FIELDS OF TABLE @<lt_table>.

      CATCH cx_sy_dynamic_osql_semantics.
        TRY.
            lv_fieldname = iv_field2.
            " Seleciona apenas o campo necessário
            SELECT (lv_fieldname)
              FROM (iv_table)
              INTO CORRESPONDING FIELDS OF TABLE @<lt_table>.

          CATCH cx_sy_dynamic_osql_semantics.
            RETURN.
        ENDTRY.

    ENDTRY.

    " Processa valores e adiciona ao resultado
    DATA(lv_index) = 0.
    LOOP AT <lt_table> ASSIGNING <ls_line>.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_line> TO <lv_value>.
      IF sy-subrc = 0.
        lv_index += 1.
        APPEND VALUE /gjaauto/cl_main_mpc=>ts_fixvalueitems( param     = iv_param
                                                             value     = <lv_value>
                                                             valpos    = lv_index
                                                             fieldname = iv_field1 ) TO ct_fixvaluesitems.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD process_function_import_doku.
    "----------------------------------------------------------------------
    " Obtém documentação completa de um Function Module
    "----------------------------------------------------------------------
    DATA: lt_dokumentation      TYPE TABLE OF funct,
          lt_exception_list     TYPE TABLE OF rsexc,
          lt_export_parameter   TYPE TABLE OF rsexp,
          lt_import_parameter   TYPE TABLE OF rsimp,
          lt_changing_parameter TYPE TABLE OF rscha,
          lt_tables_parameter   TYPE TABLE OF rstbl.

    CALL FUNCTION 'FUNCTION_IMPORT_DOKU'
      EXPORTING
        funcname           = iv_funcname
        language           = iv_language
        with_enhancements  = abap_true
      TABLES
        dokumentation      = lt_dokumentation
        exception_list     = lt_exception_list
        export_parameter   = lt_export_parameter
        import_parameter   = lt_import_parameter
        changing_parameter = lt_changing_parameter
        tables_parameter   = lt_tables_parameter.

    " Monta estrutura de retorno
    rs_result = VALUE #(
      funcname      = iv_funcname
      language      = iv_language
      changing      = lt_changing_parameter
      dokumentation = lt_dokumentation
      exception     = lt_exception_list
      export        = lt_export_parameter
      import        = lt_import_parameter
      tables        = lt_tables_parameter ).
  ENDMETHOD.


  METHOD process_param_table_type.
    "----------------------------------------------------------------------
    " Processa documentação para parâmetro do tipo tabela
    "----------------------------------------------------------------------
    rs_result-paramtyp = 'T'.

    " Obtém campos da tabela
    SELECT fieldname, rollname, domname, decimals, leng, datatype, shlporigin, checktable
      FROM dd03l
      INTO TABLE @DATA(lt_fields)
      WHERE tabname = @iv_datatype.

    " Processa cada campo da tabela
    LOOP AT lt_fields INTO DATA(lw_field).
      " Obtém descrição do elemento de dados
      DATA(lv_desc) = get_data_element_description( lw_field-rollname ).

      " Adiciona item de documentação
      APPEND VALUE /gjaauto/cl_main_mpc=>ts_parameterdokuitem(
                       desc      = lv_desc
                       decimals  = |{ lw_field-decimals alpha = out }|
                       leng      = |{ lw_field-leng alpha = out }|
                       datatype  = lw_field-datatype
                       fixvalue  = xsdbool( lw_field-shlporigin = 'F' OR lw_field-shlporigin = 'P' )
                       fieldname = lw_field-fieldname
                       param     = iv_param ) TO rs_result-items.

      " Processa valores fixos conforme origem
      CASE lw_field-shlporigin.
        WHEN 'F'. " Valores fixos do domínio
          process_domain_fixed_values( EXPORTING iv_domname        = lw_field-domname
                                                 iv_param          = iv_param
                                                 iv_fieldname      = lw_field-fieldname
                                       CHANGING  ct_fixvaluesitems = rs_result-fixvaluesitems ).

        WHEN 'P'. " Tabela de verificação
          process_check_table_values( EXPORTING iv_field1         = lw_field-fieldname
                                                iv_field2         = lw_field-rollname
                                                iv_table          = lw_field-checktable
                                                iv_param          = iv_param
                                      CHANGING  ct_fixvaluesitems = rs_result-fixvaluesitems ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD process_param_variable_type.
    "----------------------------------------------------------------------
    " Processa documentação para parâmetro do tipo variável (Domínio/DTEL)
    "----------------------------------------------------------------------
    DATA lw_domain_info TYPE ty_domain_info.

    rs_result-paramtyp = 'V'.

    " Obtém informações do domínio conforme tipo do objeto
    CASE iv_object_type.
      WHEN gc_tipo_dominio. " Domínio direto
        SELECT SINGLE domname, decimals, leng, datatype, valexi, entitytab
          FROM dd01l
          INTO @lw_domain_info
          WHERE domname = @iv_datatype.

      WHEN gc_tipo_elemento_de_dados. " Elemento de dados - obtém domínio associado
        SELECT SINGLE d~domname,
                      d~decimals,
                      d~leng,
                      d~datatype,
                      d~valexi,
                      d~entitytab
          FROM dd04l AS e
                 INNER JOIN
                   dd01l AS d ON d~domname = e~domname
          INTO @lw_domain_info
          WHERE e~rollname = @iv_datatype.

        IF sy-subrc <> 0.
          RETURN. " Elemento de dados não encontrado
        ENDIF.

      WHEN OTHERS.
        RETURN.
    ENDCASE.

    " Obtém descrição do domínio
    DATA(lv_desc) = get_domain_description( lw_domain_info-domname ).

    " Adiciona item de documentação
    APPEND VALUE /gjaauto/cl_main_mpc=>ts_parameterdokuitem(
                     desc      = lv_desc
                     decimals  = lw_domain_info-decimals
                     leng      = lw_domain_info-leng
                     datatype  = lw_domain_info-datatype
                     fixvalue  = xsdbool(    lw_domain_info-entitytab IS NOT INITIAL
                                          OR lw_domain_info-valexi    IS NOT INITIAL )
                     fieldname = CONV #( iv_param )
                     param     = iv_param ) TO rs_result-items.

    " Processa valores fixos se existirem
    IF lw_domain_info-valexi IS NOT INITIAL.
      process_domain_fixed_values( EXPORTING iv_domname        = lw_domain_info-domname
                                             iv_param          = iv_param
                                   CHANGING  ct_fixvaluesitems = rs_result-fixvaluesitems ).

    ELSEIF lw_domain_info-entitytab IS NOT INITIAL.
      process_check_table_values( EXPORTING iv_table          = lw_domain_info-entitytab
                                            iv_field1         = CONV #( iv_param )
                                            iv_field2         = ''
                                            iv_param          = iv_param
                                  CHANGING  ct_fixvaluesitems = rs_result-fixvaluesitems ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
