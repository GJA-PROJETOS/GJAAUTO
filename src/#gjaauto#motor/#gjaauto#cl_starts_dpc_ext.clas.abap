CLASS /gjaauto/cl_starts_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM /gjaauto/cl_starts_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /iwbep/if_mgw_appl_srv_runtime~create_deep_entity
        REDEFINITION .
    METHODS /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset
        REDEFINITION .
  PROTECTED SECTION.

    METHODS ga101mass_get_entity
        REDEFINITION .
    METHODS ga101mass_get_entityset
        REDEFINITION .
    METHODS zlg1001_create_create_entity
        REDEFINITION .
    METHODS zlg1001_create_get_entity
        REDEFINITION .
    METHODS ga101start_create_entity
        REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.



CLASS /GJAAUTO/CL_STARTS_DPC_EXT IMPLEMENTATION.


  METHOD zlg1001_create_create_entity.

    DATA ev_chave TYPE  /gjaauto/mte_chave.
    DATA lw_input TYPE /gjaauto/cl_starts_mpc=>ts_lg1001.

    DATA: lw_data TYPE /gjaauto/mts001,
          lt_data TYPE /gjaauto/mttt001.

    DATA: lw_lg1001 TYPE zlg1001,
          lw_lg1002 TYPE zlg1002,
          lt_lg1002 TYPE TABLE OF zlg1002.

    io_data_provider->read_entry_data( IMPORTING es_data = lw_input ).

    SELECT SINGLE lifnr INTO lw_lg1001-vendor FROM lfa1 WHERE stcd1 EQ lw_input-emitcnpj.

    lw_lg1001-doc_date = |{ lw_input-dh_emi(4) }{ lw_input-dh_emi+5(2) }{ lw_input-dh_emi+8(2) }|.

    lw_lg1001-ref_doc_no = lw_input-nct.

    CREATE DATA lw_data-data LIKE lw_lg1001.
    ASSIGN lw_data-data->* TO FIELD-SYMBOL(<ftab>).
    <ftab> = lw_lg1001.
    lw_data-name = 'HEADER'.
    APPEND lw_data TO lt_data.

    lw_lg1002-item = '00010'.
    lw_lg1002-net_price = lw_input-vtprest.
    APPEND lw_lg1002 TO lt_lg1002.

    CREATE DATA lw_data-data LIKE lt_lg1002.
    ASSIGN lw_data-data->* TO <ftab>.
    <ftab> = lt_lg1002.
    lw_data-name = 'ITEMS'.
    APPEND lw_data TO lt_data.

    CALL FUNCTION '/GJAAUTO/MTF001'
      EXPORTING
        iv_auto  = 'LG'
        iv_opera = '100'
      IMPORTING
        ev_chave = ev_chave
      TABLES
        it_data  = lt_data.

    MOVE-CORRESPONDING lw_input TO er_entity.
    er_entity-chave = ev_chave.

  ENDMETHOD.


  METHOD ga101mass_get_entity.
**TRY.
*CALL METHOD SUPER->GA101MASS_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
  ENDMETHOD.


  METHOD ga101mass_get_entityset.
**TRY.
*CALL METHOD SUPER->GA101MASS_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
  ENDMETHOD.


  METHOD zlg1001_create_get_entity.
**TRY.
*CALL METHOD SUPER->ZLG1001_CREATE_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    DATA: lw_data TYPE /gjaauto/mts001,
          lt_data TYPE /gjaauto/mttt001.

    DATA: lw_ga101 TYPE zga101.
    DATA(lv_entityset_name) = io_tech_request_context->get_entity_set_name( ).
    DATA lw_ga101mass_deep_entity TYPE /gjaauto/cl_starts_mpc_ext=>ts_ga101_deep.

    CASE lv_entityset_name.
      WHEN 'GA101Mass'.
        io_data_provider->read_entry_data( IMPORTING es_data = lw_ga101mass_deep_entity ).

        LOOP AT lw_ga101mass_deep_entity-chamadoslist INTO DATA(ls_chamado).
          MOVE-CORRESPONDING ls_chamado TO lw_ga101.
          CREATE DATA lw_data-data LIKE lw_ga101.
          ASSIGN lw_data-data->* TO FIELD-SYMBOL(<ftab>).
          <ftab> = lw_ga101.
          lw_data-name = 'CHAMADO'.
          APPEND lw_data TO lt_data.

          CALL FUNCTION '/GJAAUTO/MTF001'
            EXPORTING
              iv_auto  = 'GA'
              iv_opera = '101'
            TABLES
              it_data  = lt_data.

        ENDLOOP.
        copy_data_to_ref( EXPORTING is_data = lw_ga101mass_deep_entity
                          CHANGING  cr_data = er_deep_entity ).
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.
    DATA deeplist TYPE TABLE OF /gjaauto/cl_starts_mpc_ext=>ts_ga101_deep.
    DATA deep TYPE /gjaauto/cl_starts_mpc_ext=>ts_ga101_deep.

    deep-id = '123123'.
    APPEND VALUE /gjaauto/cl_starts_mpc_ext=>ts_ga101( chamado = '123123' usuario = '12312312' ) TO   deep-chamadoslist .
    APPEND deep TO deeplist.

    me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref(
      EXPORTING
        is_data = deeplist
      CHANGING
        cr_data = er_entityset
    ).
  ENDMETHOD.


  METHOD ga101start_create_entity.
**TRY.
*CALL METHOD SUPER->GA101START_CREATE_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =s
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**    io_data_provider        =
**  IMPORTING
**    er_entity               =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
  ENDMETHOD.
ENDCLASS.
