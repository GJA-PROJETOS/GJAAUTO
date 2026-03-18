*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃SUBROTINAS                                                          ┃*
*┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_SEARCH_CONFIGS - Busca configurações                             │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_search_configs .
  SELECT *
    FROM /gjaauto/cktb001
    INTO TABLE gt_cktb001.

  CHECK sy-subrc IS INITIAL.

  SELECT *
    FROM /gjaauto/cktb002
    INTO TABLE gt_cktb002
     FOR ALL ENTRIES IN gt_cktb001
   WHERE auto EQ gt_cktb001-auto.

  CHECK sy-subrc IS INITIAL.

  SELECT *
    FROM /gjaauto/cktb003
    INTO TABLE gt_cktb003
     FOR ALL ENTRIES IN gt_cktb002
    WHERE auto  EQ gt_cktb002-auto
      AND opera EQ gt_cktb002-opera.

  SORT gt_cktb003 BY auto opera etapa.

ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_BUILD_ALV_TREE - Monta o ALV Tree                                │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_build_alv_tree.

  CHECK alv_tree IS INITIAL.

  CREATE OBJECT cc_alv_tree
    EXPORTING
      container_name              = 'CC_ALV_TREE'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

  TRY.
      cl_salv_tree=>factory(
        EXPORTING
          r_container = cc_alv_tree
*         hide_header = abap_false
        IMPORTING
          r_salv_tree = alv_tree
        CHANGING
          t_table     = gt_alv_tree_out ).
    CATCH cx_salv_no_new_data_allowed cx_salv_error.
      EXIT.
  ENDTRY.

  PERFORM f_build_alv_tree_outtab.

*-- Columns
  alv_tree_columns = alv_tree->get_columns( ).
  alv_tree_columns->set_optimize( 'X' ).
  alv_tree_columns->get_column( 'AUTO' )->set_visible( abap_false ).
  alv_tree_columns->get_column( 'OPERA' )->set_visible( abap_false ).
  alv_tree_columns->get_column( 'ETAPA' )->set_visible( abap_false ).

*-- Settings
  alv_tree_settings = alv_tree->get_tree_settings( ).
  alv_tree_settings->set_hierarchy_header( 'Automações' ).
  alv_tree_settings->set_hierarchy_size( 50 ).

*-- Events
  alv_tree_events = alv_tree->get_event( ).

  SET HANDLER cl_alv_tree_auto_event_handler=>on_link_click FOR alv_tree_events.

  CREATE OBJECT go_custom_events.
  SET HANDLER go_custom_events->on_user_command FOR alv_tree_events.

**-- Toolbar
  alv_tree->set_screen_status(
    report        = sy-repid
    pfstatus      = SWITCH sypfkey( gv_screen_number_9000 WHEN '9002' THEN 'PF-STATUS_9002' ELSE 'PF-STATUS_9000' )
    set_functions = alv_tree->c_functions_none ).

*-- Funtions
  alv_tree_functions = alv_tree->get_functions( ).
  alv_tree_functions->set_all( abap_true ).

  TRY.
      DATA(l_text1) = CONV string( 'Expandir' ).

      alv_tree_functions->add_function(
        name     = 'EXPANDIR'
        icon     = '@DF@'
        text     = l_text1
        tooltip  = l_text1
        position = if_salv_c_function_position=>right_of_salv_functions ).
    CATCH cx_salv_wrong_call cx_salv_existing.
  ENDTRY.


*-- Expande node dos tipos de auto
*  alv_tree->get_nodes( )->collapse_all( ).
*  LOOP AT alv_tree->get_nodes( )->get_all_nodes( ) INTO DATA(lw_node).
*    TRY.
*        IF lw_node-node->get_parent( )->get_parent( ) IS BOUND.
*          CONTINUE.
*        ENDIF.
*      CATCH cx_salv_msg.
*        lw_node-node->expand( ).
*    ENDTRY.
*  ENDLOOP.

  alv_tree->display( ).
ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_BUILD_ALV_TREE_OUTTAB - Monta dados de saida para o ALV Tree     │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_build_alv_tree_outtab.
  DATA: l_auto_key  TYPE lvc_nkey,
        l_opera_key TYPE lvc_nkey,
        l_etapa_key TYPE lvc_nkey,
        lw_outtab   TYPE ty_alv_tree_outtab.

  LOOP AT gt_cktb001 INTO DATA(lw_auto).
    CLEAR lw_outtab.
    lw_outtab-auto = lw_auto-auto.
    PERFORM f_add_auto_node USING lw_auto CHANGING l_auto_key.

    READ TABLE gt_cktb002 TRANSPORTING NO FIELDS WITH KEY auto = lw_auto-auto.
    IF sy-subrc NE 0.
      APPEND lw_outtab TO gt_alv_tree_out.
      CONTINUE.
    ENDIF.

    LOOP AT gt_cktb002 INTO DATA(lw_opera) WHERE auto = lw_auto-auto.
      lw_outtab-opera = lw_opera-opera.

      READ TABLE gt_cktb003 TRANSPORTING NO FIELDS WITH KEY auto = lw_auto-auto opera = lw_opera-opera.
      IF sy-subrc NE 0.
        PERFORM f_add_opera_node USING lw_opera-opera lw_opera-descr l_auto_key lw_outtab abap_true CHANGING l_opera_key.
        APPEND abap_true TO gt_alv_tree_out.
        CONTINUE.
      ENDIF.

      PERFORM f_add_opera_node USING lw_opera-opera lw_opera-descr l_auto_key lw_outtab abap_false CHANGING l_opera_key.

      LOOP AT gt_cktb003 INTO DATA(lw_etapa) WHERE auto = lw_opera-auto AND opera = lw_opera-opera.
        lw_outtab-etapa = lw_etapa-etapa.
        PERFORM f_add_etapa_node USING lw_etapa-etapa lw_etapa-descr l_opera_key lw_outtab CHANGING l_etapa_key.
        APPEND abap_true TO gt_alv_tree_out.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.
ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_ADD_AUTO_NODE - Adiciona nó de automação ao ALV Tree             │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_add_auto_node USING lw_auto TYPE /gjaauto/cktb001 CHANGING p_key.
  DATA: nodes TYPE REF TO cl_salv_nodes,
        node  TYPE REF TO cl_salv_node,
        item  TYPE REF TO cl_salv_item.

  nodes = alv_tree->get_nodes( ).
  TRY.
      node = nodes->add_node( related_node = '' data_row = VALUE ty_alv_tree_outtab( auto = lw_auto-auto ) expander = abap_true relationship = cl_gui_column_tree=>relat_last_child ).
      node->set_text( |{ lw_auto-auto } { lw_auto-descr }| ).
      p_key = node->get_key( ).
      item = node->get_hierarchy_item( ).
      item->set_icon( |{ lw_auto-icon }| ).
      item->set_type( if_salv_c_item_type=>link ).
    CATCH cx_salv_msg.
  ENDTRY.
ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_ADD_OPERA_NODE - Adiciona nó de operação ao ALV Tree             │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_add_opera_node USING p_id p_descr p_parent_key w_itab TYPE ty_alv_tree_outtab is_initial CHANGING p_key.
  DATA: node TYPE REF TO cl_salv_node,
        item TYPE REF TO cl_salv_item.
  TRY.
      node = alv_tree->get_nodes( )->add_node( related_node = p_parent_key data_row = w_itab relationship = cl_gui_column_tree=>relat_last_child ).
      node->set_text( |{ p_id } { p_descr }| ).
      IF is_initial = abap_true.
        node->set_collapsed_icon( '@5F@' ).
      ELSE.
        node->set_expanded_icon( '@9X@' ).
      ENDIF.
      node->set_expander( abap_false ).
      p_key = node->get_key( ).
      item = node->get_hierarchy_item( ).
      item->set_type( if_salv_c_item_type=>link ).
    CATCH cx_salv_msg.
  ENDTRY.
ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_ADD_ETAPA_NODE - Adiciona nó de etapa ao ALV Tree                │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_add_etapa_node USING p_id p_descr p_parent_key w_itab TYPE ty_alv_tree_outtab CHANGING p_key.
  DATA: node TYPE REF TO cl_salv_node,
        item TYPE REF TO cl_salv_item.
  TRY.
      node = alv_tree->get_nodes( )->add_node( related_node = p_parent_key data_row = w_itab relationship = cl_gui_column_tree=>relat_last_child ).
      node->set_text( |{ p_id } { p_descr }| ).
      node->set_collapsed_icon( '@9Y@' ).
      node->set_expander( abap_false ).
      p_key = node->get_key( ).
      item = node->get_hierarchy_item( ).
      item->set_type( if_salv_c_item_type=>link ).
    CATCH cx_salv_msg.
  ENDTRY.
ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_BUILD_ALV_ETAPAS - Monta o ALV das etapas                        │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_build_alv_etapas.

  DATA: lw_outtab TYPE ty_alv_etapas_outtab,
        lt_dd07v  TYPE TABLE OF dd07v.

  IF alv IS BOUND.
    CALL METHOD alv->close_screen( ).
    CLEAR alv.
  ENDIF.

  IF cc_alv IS BOUND.
    CALL METHOD cc_alv->free( ).
    CLEAR cc_alv.
  ENDIF.

  IF event_handler IS BOUND.
    FREE event_handler.
  ENDIF.


  CLEAR gt_alv_etapas_out.

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname   = '/GJAAUTO/CKD_TIPO_ETAPA'
      text      = 'X'
    TABLES
      dd07v_tab = lt_dd07v.

  LOOP AT gt_cktb003 INTO DATA(lw_cktb003) WHERE auto  EQ gw_cktb002-auto
                                             AND opera EQ gw_cktb002-opera.
    CLEAR lw_outtab.
    MOVE-CORRESPONDING lw_cktb003 TO lw_outtab.

    READ TABLE lt_dd07v INTO DATA(wl_dd07v) WITH KEY domvalue_l = lw_cktb003-tpeta.
    lw_outtab-tpeta = wl_dd07v-ddtext.
*    lw_outtab-edit_button = c_edit_icon.
    APPEND lw_outtab TO gt_alv_etapas_out.
  ENDLOOP.

  CHECK gt_alv_etapas_out IS NOT INITIAL.

  SORT gt_alv_etapas_out BY etapa.

  CREATE OBJECT cc_alv
    EXPORTING
      container_name              = 'CC_ALV_ETAPAS'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

  cl_salv_table=>factory(
    EXPORTING
      r_container  = cc_alv
    IMPORTING
      r_salv_table = alv
    CHANGING
      t_table      = gt_alv_etapas_out ).

*  PERFORM f_set_column_width USING 'ICON' 1 alv.
*  PERFORM f_set_column_position USING 'ICON' 2 alv.
*  PERFORM f_set_column_text USING 'AUTO' 'Auto' 'Automação' 'Cód. Automação' alv.

  PERFORM f_set_columns_optimize   USING alv.
  PERFORM f_set_column_width       USING 'DESCR' 30 alv.
  PERFORM f_set_column_width       USING 'ROTIN' 23 alv.
  PERFORM f_set_column_width       USING 'TPETA' 9 alv.
  PERFORM f_set_column_text        USING 'ETAPA' 'Etapa' 'Etapa' 'Etapa do fluxo' alv.
  PERFORM f_set_column_visible     USING 'AUTO' abap_false alv.
  PERFORM f_set_column_visible     USING 'OPERA' abap_false alv.
  PERFORM f_set_column_type        USING 'ETAPA' 2 alv.
  PERFORM f_set_column_text        USING 'TPETA' 'Tipo' 'TipoEtapa' 'Tipo da etapa' alv.
  PERFORM f_set_column_type        USING 'EDIT_BUTTON' 2 alv.
  PERFORM f_set_toolbar_visibility USING abap_false alv.
  alv->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).
*  PERFORM f_set_column_dropdown USING 'TPETA' alv.


  alv->display( ).

ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_BUILD_ALV_TREE_MAPEA - Monta o ALV TREE dos mapeamentos de cada etapa
*└────────────────────────────────────────────────────────────────────┘*
FORM f_build_alv_tree_mapea.
  FIELD-SYMBOLS: <fs_conteudo> TYPE ty_alv_tree_mapea_outtab.


  DATA: nodes TYPE REF TO cl_salv_nodes,
        node  TYPE REF TO cl_salv_node,
        item  TYPE REF TO cl_salv_item.

  DATA: l_exception_key TYPE lvc_nkey,
        l_export_key    TYPE lvc_nkey,
        l_import_key    TYPE lvc_nkey,
        l_changing_key  TYPE lvc_nkey,
        l_tables_key    TYPE lvc_nkey.

  DATA: lw_rsexp TYPE rsexp,
        lw_rsimp TYPE rsimp,
        lw_rscha TYPE rscha,
        lw_rstbl TYPE rstbl.

  " Libera ALV anterior corretamente
  IF alv_tree_mapea IS BOUND.
    CALL METHOD alv_tree_mapea->close_screen( ).
    FREE alv_tree_mapea.
  ENDIF.

  IF cc_alv_tree_mapea IS BOUND.
    CALL METHOD cc_alv_tree_mapea->free.
    FREE cc_alv_tree_mapea.
  ENDIF.


  gv_rotin_loaded = gw_cktb003-rotin.

  CALL FUNCTION 'FUNCTION_IMPORT_DOKU'
    EXPORTING
      funcname           = gv_rotin_loaded
      language           = sy-langu
      with_enhancements  = 'X'
    TABLES
      dokumentation      = gt_dokumentation
      exception_list     = gt_exception_list
      export_parameter   = gt_export_parameter
      import_parameter   = gt_import_parameter
      changing_parameter = gt_changing_parameter
      tables_parameter   = gt_tables_parameter
    EXCEPTIONS
      error_message      = 1
      function_not_found = 2
      invalid_name       = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  CLEAR: gt_alv_tree_mapea_outtab.

  CREATE OBJECT cc_alv_tree_mapea
    EXPORTING
      container_name              = 'CC_ALV_TREE_MAPEA'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

  TRY.
      cl_salv_tree=>factory(
        EXPORTING
          r_container = cc_alv_tree_mapea
          hide_header = abap_true
        IMPORTING
          r_salv_tree = alv_tree_mapea
        CHANGING
          t_table     = gt_alv_tree_mapea_outtab ).
    CATCH cx_salv_no_new_data_allowed cx_salv_error.
      EXIT.
  ENDTRY.

  nodes = alv_tree_mapea->get_nodes( ).
  IF gt_import_parameter IS NOT INITIAL.
    SORT gt_import_parameter BY parameter.
    PERFORM f_add_natureza_param_node USING 'I' 'Importar' '@CF@' CHANGING l_import_key.
    LOOP AT gt_import_parameter INTO lw_rsimp.
      PERFORM f_add_imp_param_node USING 'I' l_import_key lw_rsexp lw_rsimp lw_rscha lw_rstbl.
    ENDLOOP.
  ENDIF.
  IF gt_export_parameter IS NOT INITIAL.
    SORT gt_export_parameter BY parameter.
    PERFORM f_add_natureza_param_node USING 'E' 'Exportar' '@CG@' CHANGING l_export_key.
    LOOP AT gt_export_parameter INTO lw_rsexp.
      PERFORM f_add_imp_param_node USING 'E' l_export_key lw_rsexp lw_rsimp lw_rscha lw_rstbl.
    ENDLOOP.
  ENDIF.
  IF gt_changing_parameter IS NOT INITIAL.
    SORT gt_changing_parameter BY parameter.
    PERFORM f_add_natureza_param_node USING 'C' 'Changing' '@PE@' CHANGING l_changing_key.
    LOOP AT gt_changing_parameter INTO lw_rscha.
      PERFORM f_add_imp_param_node USING 'C' l_changing_key lw_rsexp lw_rsimp lw_rscha lw_rstbl.
    ENDLOOP.
  ENDIF.
  IF gt_tables_parameter IS NOT INITIAL.
    SORT gt_tables_parameter BY parameter.
    PERFORM f_add_natureza_param_node USING 'T' 'Tables' '@PE@' CHANGING l_tables_key.
    LOOP AT gt_tables_parameter INTO lw_rstbl.
      PERFORM f_add_imp_param_node USING 'T' l_tables_key lw_rsexp lw_rsimp lw_rscha lw_rstbl.
    ENDLOOP.
  ENDIF.

  IF gt_alv_tree_mapea_outtab IS INITIAL.
    EXIT.
  ENDIF.

*-- Columns
  alv_tree_columns = alv_tree_mapea->get_columns( ).

  alv_tree_columns->get_column( 'PARAMNAT' )->set_visible( abap_false ).
  alv_tree_columns->get_column( 'PARAMTYP' )->set_visible( abap_false ).
  alv_tree_columns->get_column( 'TABNAME' )->set_visible( abap_false ).
  alv_tree_columns->get_column( 'PARAM' )->set_visible( abap_false ).
  alv_tree_columns->get_column( 'PARAMOPT' )->set_visible( abap_false ).

*-- Settings
  alv_tree_settings = alv_tree_mapea->get_tree_settings( ).
  alv_tree_settings->set_hierarchy_header( 'Mapeamento' ).
  alv_tree_settings->set_hierarchy_size( 50 ).

*-- Events
  alv_tree_events = alv_tree_mapea->get_event( ).
  SET HANDLER cl_alv_tree_mapea_event_hdlr=>on_link_click FOR alv_tree_events.

**-- Funtions
*  alv_tree_functions = alv_tree->get_functions( ).
*  alv_tree_functions->set_all( abap_false ).

*-- Expande node dos tipos de auto
  alv_tree_mapea->get_nodes( )->collapse_all( ).

*  LOOP AT alv_tree_mapea->get_nodes( )->get_all_nodes( ) INTO DATA(lw_node).
*    TRY.
*        DATA(data_row) = lw_node-node->get_data_row( ).
*        ASSIGN data_row->* TO <fs_conteudo>.
*        IF gw_cktb004-param IS NOT INITIAL AND <fs_conteudo>-tabname EQ gw_cktb004-tabname AND <fs_conteudo>-param IS INITIAL.
*          lw_node-node->expand( ).
*        ELSEIF gw_cktb004-param IS INITIAL AND <fs_conteudo>-tabname IS INITIAL AND <fs_conteudo>-param IS INITIAL.
*          lw_node-node->expand( ).
*        ELSE.
*          CONTINUE.
*        ENDIF.
*      CATCH cx_salv_msg.
*    ENDTRY.
*  ENDLOOP.

  alv_tree_mapea->display( ).
ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ f_build_alv_tree_mapea_outtab - Monta dados de saida para o ALV Tree dos Mapeamentos
*└────────────────────────────────────────────────────────────────────┘*
FORM f_build_alv_tree_mapea_outtab.

ENDFORM.
*┌────────────────────────────────────────────────────────────────────┐*
*│ F_ADD_natureza_param_NODE - Adiciona nó de operação ao ALV Tree    │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_add_natureza_param_node USING p_natureza p_descr p_icon CHANGING p_key.
  DATA: nodes TYPE REF TO cl_salv_nodes,
        node  TYPE REF TO cl_salv_node,
        item  TYPE REF TO cl_salv_item.
  TRY.
      nodes = alv_tree_mapea->get_nodes( ).
      node = nodes->add_node(
        related_node = ''
        data_row     = VALUE ty_alv_tree_mapea_outtab( paramnat = p_natureza )
        expander     = abap_true
        relationship = cl_gui_column_tree=>relat_last_child
      ).
      node->set_text( p_descr ).
      p_key = node->get_key( ).
      item = node->get_hierarchy_item( ).
      item->set_icon( p_icon ).
    CATCH cx_salv_msg.
  ENDTRY.
ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_ADD_OPERA_NODE - Adiciona nó de operação ao ALV Tree             │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_add_imp_param_node USING p_natureza
                                p_parent_key
                                lw_rsexp TYPE rsexp
                                lw_rsimp TYPE rsimp
                                lw_rscha TYPE rscha
                                lw_rstbl TYPE rstbl.



  DATA: node TYPE REF TO cl_salv_node,
        item TYPE REF TO cl_salv_item.

  DATA: vl_optional  TYPE abap_bool,
        vl_obj_name  TYPE string,
        vl_parameter TYPE string.

  CASE p_natureza.
    WHEN 'I'." Importar
      vl_obj_name = COND #( WHEN lw_rsimp-dbfield IS NOT INITIAL THEN lw_rsimp-dbfield ELSE lw_rsimp-typ ).
      vl_parameter = lw_rsimp-parameter.
      vl_optional = lw_rsimp-optional.
    WHEN 'E'." Exportar
      vl_obj_name = COND #( WHEN lw_rsexp-dbfield IS NOT INITIAL THEN lw_rsexp-dbfield ELSE lw_rsexp-typ ).
      vl_parameter = lw_rsexp-parameter.
      vl_optional = abap_true.
    WHEN 'C'." Changing
      vl_obj_name = COND #( WHEN lw_rscha-dbfield IS NOT INITIAL THEN lw_rscha-dbfield ELSE lw_rscha-typ ).
      vl_parameter = lw_rscha-parameter.
      vl_optional = lw_rscha-optional.
    WHEN 'T'." Tabelas
      vl_obj_name = COND #( WHEN lw_rstbl-dbstruct IS NOT INITIAL THEN lw_rstbl-dbstruct ELSE lw_rstbl-typ ).
      vl_parameter = lw_rstbl-parameter.
      vl_optional = lw_rstbl-optional.
    WHEN OTHERS.
      BREAK-POINT.
  ENDCASE.

  SELECT SINGLE object
    FROM tadir
    INTO @DATA(vl_type)
   WHERE obj_name EQ @vl_obj_name
     and object IN ('TABL','DTEL','DOMA').

*  T  Tabela
*  S  Estrutura
*  V  Variável
  CASE vl_type.
    WHEN 'TABL'."Tabela/Strutura
      vl_type = 'S'.
      SELECT *
        FROM dd03l
        INTO TABLE @DATA(lt_fields)
       WHERE tabname EQ @vl_obj_name.
    WHEN 'DTEL'."Elemento de dados
      vl_type = 'V'.
    WHEN 'DOMA'."Dominio
      vl_type = 'V'.
    WHEN OTHERS.
      IF vl_obj_name CS '-'.
        vl_type = 'V'.
      ELSE.
        BREAK-POINT.
      ENDIF.
  ENDCASE.

  DATA(data_row) =  VALUE ty_alv_tree_mapea_outtab(
      paramnat = p_natureza
      paramtyp = vl_type
      tabname = COND #( WHEN vl_type EQ 'S' THEN  vl_parameter )
      param = COND #( WHEN vl_type NE 'S' THEN  vl_parameter )
      ).

  TRY.
      node = alv_tree_mapea->get_nodes( )->add_node(
      related_node = p_parent_key
      data_row = data_row
      relationship = cl_gui_column_tree=>relat_last_child
      ).

      APPEND data_row TO gt_alv_tree_mapea_outtab.

      item = node->get_hierarchy_item( ).
      item->set_type( if_salv_c_item_type=>link ).

      node->set_text( COND #( WHEN data_row-tabname IS NOT INITIAL THEN data_row-tabname ELSE data_row-param ) ).
      IF data_row-tabname IS NOT INITIAL.
        node->set_collapsed_icon( '@PP@' ).
        node->set_expanded_icon( '@U2@' ).
      ELSE.
        node->set_collapsed_icon( '@AN@' ).
      ENDIF.


      node->set_expander( abap_false ).

      DATA(p_key) = node->get_key( ).
    CATCH cx_salv_msg.
  ENDTRY.

  IF lt_fields IS NOT INITIAL.
    LOOP AT lt_fields INTO DATA(lw_field).
      data_row-paramtyp = 'V'.
      data_row-param = lw_field-fieldname.
      PERFORM f_add_child_param_node USING p_key
                                             lw_field
                                             data_row.
      APPEND data_row TO gt_alv_tree_mapea_outtab.
    ENDLOOP.
  ENDIF.
ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ f_add_child_param_node - Adiciona nó de operação ao ALV Tree         │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_add_child_param_node USING p_parent_key
                                    p_data TYPE dd03l
                                    p_data_row TYPE ty_alv_tree_mapea_outtab.


  DATA: node TYPE REF TO cl_salv_node,
        item TYPE REF TO cl_salv_item.
  TRY.
      node = alv_tree_mapea->get_nodes( )->add_node(
      related_node = p_parent_key
      data_row = p_data_row
      relationship = cl_gui_column_tree=>relat_last_child
      ).
      node->set_text( |{ p_data_row-param }| ).
      node->set_collapsed_icon( '@5F@' ).
      node->set_expander( abap_false ).
*      p_key = node->get_key( ).
      item = node->get_hierarchy_item( ).
      item->set_type( if_salv_c_item_type=>link ).

    CATCH cx_salv_msg.
  ENDTRY.
ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_BUILD_ALV_DATA_OPERA - Monta o ALV dos dados de uma operação     │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_build_alv_data_opera.

  DATA: lw_outtab TYPE ty_alv_data_operas_outtab.

  IF alv_data_operas IS BOUND.
    CALL METHOD alv_data_operas->close_screen( ).
    CLEAR alv_data_operas.
  ENDIF.

  IF cc_alv_data_operas IS BOUND.
    CALL METHOD cc_alv_data_operas->free( ).
    CLEAR cc_alv_data_operas.
  ENDIF.

  CLEAR gt_alv_data_operas_outtab.

  SELECT *
    FROM /gjaauto/cktb005
    INTO TABLE gt_cktb005
   WHERE auto  EQ gw_cktb002-auto
     AND opera EQ gw_cktb002-opera.


  LOOP AT gt_cktb005 INTO DATA(lw_cktb005) WHERE auto  EQ gw_cktb002-auto
                                             AND opera EQ gw_cktb002-opera.
    MOVE-CORRESPONDING lw_cktb005 TO lw_outtab.

    lw_outtab-datanatu = SWITCH string( lw_cktb005-datanatu
                                        WHEN 'I' THEN 'Inicial'
                                        WHEN 'V' THEN 'Variáveis'
                                        WHEN 'D' THEN 'Default'
                                      ).

    lw_outtab-datatyp = SWITCH string( lw_cktb005-reftype
                                    WHEN 'T' THEN 'Tabela'
                                    WHEN 'S' THEN 'Struct'
                                  ).
    IF lw_cktb005-datanatu = 'I' OR lw_cktb005-datanatu = 'V'.
      lw_outtab-cell_color_code = 5.
    ENDIF.

*    lw_outtab-edit_button = c_edit_icon.


    SHIFT lw_outtab-etapa_born LEFT DELETING LEADING '0'.
    lw_outtab-etapa_born = COND #( WHEN lw_outtab-etapa_born IS INITIAL THEN '0' ELSE lw_outtab-etapa_born ).

    APPEND lw_outtab TO gt_alv_data_operas_outtab.
    CLEAR lw_outtab.
  ENDLOOP.

  "Linha de ajuda, para dados obrigatorios
*  lw_outtab-edit_button = c_create_icon.
  lw_outtab-datanatu   = 'Inicial'.
  lw_outtab-datatyp    = 'Struct'.
  lw_outtab-etapa_born = 0.
  lw_outtab-cell_color_code = 6.
  CLEAR lw_outtab-name.
  READ TABLE gt_cktb005 WITH KEY datanatu = 'I' reftype = 'S' TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    lw_outtab-datatyp    = 'Struct'.
    APPEND lw_outtab TO gt_alv_data_operas_outtab.
  ENDIF.
  READ TABLE gt_cktb005 WITH KEY datanatu = 'I' reftype = 'T' TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    lw_outtab-datatyp    = 'Tabela'.
    APPEND lw_outtab TO gt_alv_data_operas_outtab.
  ENDIF.
  READ TABLE gt_cktb005 WITH KEY datanatu = 'V' TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    lw_outtab-datatyp    = 'Struct'.
    lw_outtab-datanatu   = 'Variáveis'.
    APPEND lw_outtab TO gt_alv_data_operas_outtab.
  ENDIF.


  CREATE OBJECT cc_alv_data_operas
    EXPORTING
      container_name              = 'CC_ALV_DATA_OPERAS'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

  cl_salv_table=>factory(
    EXPORTING
      r_container  = cc_alv_data_operas
    IMPORTING
      r_salv_table = alv_data_operas
    CHANGING
      t_table      = gt_alv_data_operas_outtab ).

  PERFORM f_set_columns_optimize    USING alv_data_operas.
  PERFORM f_set_toolbar_visibility  USING abap_false alv_data_operas.
  PERFORM f_set_column_width        USING 'DATANATU' 8 alv_data_operas.
  PERFORM f_set_column_width        USING 'DATATYP' 5 alv_data_operas.
  PERFORM f_set_column_width        USING 'ETAPA_BORN' 4 alv_data_operas.

  PERFORM f_set_column_text         USING 'ETAPA_BORN' 'Start' 'Etapa Start' 'Etapa Start' alv_data_operas.
  PERFORM f_set_column_text         USING 'DATATYP' 'Tipo' 'Tipo Etapa' 'Tipo Etapa' alv_data_operas.
  PERFORM f_set_column_text         USING 'DATANATU' 'Natureza' 'Natureza' 'Natureza' alv_data_operas.

  PERFORM f_set_column_cell_color   USING 'DATANAME' gt_alv_data_operas_outtab alv_data_operas.
  PERFORM f_set_column_cell_color   USING 'DATAALIAS' gt_alv_data_operas_outtab alv_data_operas.

  PERFORM f_set_column_type         USING 'EDIT_BUTTON' 2 alv_data_operas.

  alv_data_operas->display( ).

ENDFORM.
*┌────────────────────────────────────────────────────────────────────┐*
*│ f_search_desc_standard_param - Busca descrição do parâmetro padrão │
*└────────────────────────────────────────────────────────────────────┘*
FORM f_search_desc_standard_param.
  DATA: lt_table_values TYPE vrm_values,
        lt_param_values TYPE vrm_values.

  "Define o nome do parâmetro ou tabela
  DATA(param_name) = COND string(
    WHEN gw_cktb004-tabname IS INITIAL THEN gw_cktb004-param
    ELSE gw_cktb004-tabname
  ).

  DATA data_element_field TYPE tabname. " Defina conforme o tipo comum

  CASE gw_cktb004-paramnat.
    WHEN 'I'. " Import
      READ TABLE gt_import_parameter WITH KEY parameter = param_name INTO DATA(lv_import).
      data_element_field = lv_import-dbfield.
      gw_cktb004-paramopt = lv_import-optional.
      gv_auto_icon = c_arrow_up_icon.
    WHEN 'E'. " Export
      READ TABLE gt_export_parameter WITH KEY parameter = param_name INTO DATA(lv_export).
      data_element_field = lv_export-dbfield.
      gw_cktb004-paramopt = abap_true.

    WHEN 'C'. " Changing
      READ TABLE gt_changing_parameter WITH KEY parameter = param_name INTO DATA(lv_changing).
      data_element_field = lv_changing-dbfield.
      gw_cktb004-paramopt = lv_changing-optional.
    WHEN 'T'. " Tables
      READ TABLE gt_tables_parameter WITH KEY parameter = param_name INTO DATA(lv_table).
      data_element_field = CONV tabname( lv_table-dbstruct ).
      gw_cktb004-paramopt = lv_table-optional.
    WHEN OTHERS.
      BREAK-POINT.
  ENDCASE.

  "Extrai o nome da tabela e o nome do parâmetro, considerando se há hífen
  DATA(table_name) = data_element_field.
  DATA(field_name) = gw_cktb004-param.

  IF table_name IS NOT INITIAL.

    IF table_name CS '-'.
      SPLIT table_name AT '-' INTO TABLE DATA(lt_parts).
      READ TABLE lt_parts INTO table_name INDEX 1.
      READ TABLE lt_parts INTO field_name INDEX 2.
    ENDIF.

    "Busca a descrição da tabela
    SELECT SINGLE ddtext
      INTO @gv_table_desc
      FROM dd02t
      WHERE tabname = @table_name
        AND ddlanguage = @sy-langu.

    IF sy-subrc <> 0.
      CLEAR gv_table_desc.
      RETURN. " termina mais limpo
    ENDIF.

    "Busca o elemento de dados do campo
    SELECT SINGLE rollname
      INTO @DATA(data_element)
      FROM dd03l
      WHERE tabname = @table_name
        AND fieldname = @field_name.

    IF sy-subrc = 0.

      "Busca os textos do elemento de dados
      SELECT SINGLE ddtext, scrtext_s, scrtext_m, scrtext_l
        INTO @DATA(data_element_desc)
        FROM dd04t
        WHERE rollname = @data_element
          AND ddlanguage = @sy-langu.

      gv_param_desc = REDUCE string(
        INIT max = `` len = 0
        FOR val IN VALUE string_table(
          ( CONV string( data_element_desc-ddtext ) )
          ( CONV string( data_element_desc-scrtext_s ) )
          ( CONV string( data_element_desc-scrtext_m ) )
          ( CONV string( data_element_desc-scrtext_l ) )
        )
        NEXT max = COND #( WHEN strlen( val ) > len THEN val ELSE max )
             len = COND #( WHEN strlen( val ) > len THEN strlen( val ) ELSE len )
      ).

    ELSE.
      CLEAR gv_param_desc.
    ENDIF.

  ENDIF.

ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_LOAD_TABLE_FROM_VALUES - Carrega tabela de valores               │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_load_table_from_values.
  DATA: lt_table_values TYPE vrm_values,
        lw_table_value  TYPE vrm_value,
        lv_desc         TYPE as4text.

  SELECT *
    FROM /gjaauto/cktb005
    INTO TABLE @DATA(lt_cktb005)
   WHERE auto  EQ @gw_cktb003-auto
     AND opera EQ @gw_cktb003-opera.

  IF sy-subrc EQ 0.

    CLEAR: lt_table_values, lw_table_value.

    APPEND VALUE vrm_value( key = 'GW_AUTO' text = 'Cabeçalho da automação' ) TO lt_table_values.
    APPEND VALUE vrm_value( key = 'GW_ETAPA' text = 'Etapa atual' ) TO lt_table_values.

    LOOP AT lt_cktb005 INTO DATA(lw_cktb005).
      lw_table_value-key = lw_cktb005-name.

      SELECT *
        FROM dd02t
        INTO TABLE @DATA(lt_dd02t)
       WHERE tabname EQ @lw_cktb005-reftypname.
      READ TABLE lt_dd02t INTO DATA(lw_dd02t) WITH KEY ddlanguage = sy-langu.
      IF sy-subrc = 0.
        lw_table_value-text = lw_dd02t-ddtext.
      ELSE.
        READ TABLE lt_dd02t INTO lw_dd02t WITH KEY ddlanguage = 'E'.
        IF sy-subrc = 0.
          lw_table_value-text = lw_dd02t-ddtext.
        ELSE.
          READ TABLE lt_dd02t INTO lw_dd02t INDEX 1.
          IF sy-subrc = 0.
            lw_table_value-text = lw_dd02t-ddtext.
          ENDIF.
        ENDIF.
      ENDIF.
      APPEND lw_table_value TO lt_table_values.

    ENDLOOP.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = 'GW_CKTB004-TABNAME_FROM'
        values          = lt_table_values
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.

  ENDIF.
ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_LOAD_PARAM_FROM - Carrega parâmetros da tabela selecionada       │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_load_param_from.

  DATA: lt_table_values TYPE vrm_values,
        lw_table_value  TYPE vrm_value,
        lv_desc         TYPE as4text.

  CHECK gw_cktb004-tabname_from IS NOT INITIAL.

  READ TABLE gt_cktb005 INTO DATA(lw_cktb005) WITH KEY name = gw_cktb004-tabname_from.

  IF sy-subrc EQ 0.
    SELECT *
      FROM dd03l
      INTO TABLE @DATA(lt_dd03l)
     WHERE tabname = @lw_cktb005-reftypname.

  ELSE.
    DATA(systemvar) = COND dd03l-tabname( WHEN gw_cktb004-tabname_from = 'GW_ETAPA' THEN '/GJAAUTO/MTTB003' ELSE '/GJAAUTO/MTTB001' ).
    SELECT *
      FROM dd03l
      INTO TABLE lt_dd03l
     WHERE tabname = systemvar.
  ENDIF.

  IF sy-subrc EQ 0.

    CLEAR: lt_table_values, lw_table_value.

    DELETE lt_dd03l WHERE fieldname EQ '.INCLUDE'.

    LOOP AT lt_dd03l INTO DATA(lw_dd03l) WHERE fieldname <> 'MANDT'.
      lw_table_value-key = lw_dd03l-fieldname.

      "Busca o elemento de dados do campo
      SELECT SINGLE rollname
      INTO @DATA(data_element)
            FROM dd03l
            WHERE tabname = @gw_cktb004-tabname_from
            AND fieldname = @lw_dd03l-fieldname.

      IF sy-subrc = 0.

        "Busca os textos do elemento de dados
        SELECT SINGLE ddtext, scrtext_s, scrtext_m, scrtext_l
        INTO @DATA(data_element_desc)
              FROM dd04t
              WHERE rollname = @data_element
              AND ddlanguage = @sy-langu.

        lw_table_value-text = REDUCE string(
        INIT max = `` len = 0
        FOR val IN VALUE string_table(
        ( CONV string( data_element_desc-ddtext ) )
        ( CONV string( data_element_desc-scrtext_s ) )
        ( CONV string( data_element_desc-scrtext_m ) )
        ( CONV string( data_element_desc-scrtext_l ) )
        )
        NEXT max = COND #( WHEN strlen( val ) > len THEN val ELSE max )
        len = COND #( WHEN strlen( val ) > len THEN strlen( val ) ELSE len )
        ).

      ELSE.
        CLEAR lw_table_value-text.
      ENDIF.

      APPEND lw_table_value TO lt_table_values.
    ENDLOOP.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = 'GW_CKTB004-PARAM_FROM'
        values          = lt_table_values
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.

  ENDIF.
ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_VALIDADE_CKTB005 - Valida os dados do CKTB005                    │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_validade_cktb005 CHANGING has_error TYPE boolean.
  has_error = abap_false.

  CASE gw_cktb005-datanatu.
    WHEN 'V'.
      IF line_exists( gt_cktb005[ datanatu = 'V' ] ).
        MESSAGE 'Natureza variável já cadastrado' TYPE 'W' DISPLAY LIKE 'E'.
        has_error = abap_true.
      ENDIF.
    WHEN OTHERS.
      IF gw_cktb005-datanatu IS INITIAL.
        MESSAGE 'Natureza é obrigatória.' TYPE 'W' DISPLAY LIKE 'E'.
        has_error = abap_true.
      ENDIF.
  ENDCASE.

  IF gw_cktb005-reftype IS INITIAL.
    MESSAGE 'Tipo é obrigatório.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.

  IF gw_cktb005-name IS INITIAL.
    MESSAGE 'Apelido é obrigatória.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.

  IF gw_cktb005-reftypname IS INITIAL.
    MESSAGE 'Referencia da tabela é obrigatória.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.

ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_VALIDADE_CKTB003 - Valida os dados do CKTB003                    │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_validade_cktb003 CHANGING has_error TYPE boolean.
  has_error = abap_false.

  IF gw_cktb003-auto IS INITIAL.
    MESSAGE 'Cód. Automação é obrigatório.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.

  IF gw_cktb003-opera IS INITIAL.
    MESSAGE 'Operação é obrigatória.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.

  IF gw_cktb003-etapa IS INITIAL.
    MESSAGE 'Etapa é obrigatória.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ELSE.
*    IF line_exists( gt_cktb003[ auto = gw_cktb003-auto opera = gw_cktb003-opera etapa = gw_cktb003-etapa ] ).
*      DATA(lv_qtd) = condense( |{ gw_cktb003-etapa ALPHA = OUT }| ).
*      MESSAGE |Etapa { lv_qtd } já cadastrada| TYPE 'W' DISPLAY LIKE 'E'.
*      has_error = abap_true.
*    ENDIF.
  ENDIF.

  IF gw_cktb003-descr IS INITIAL.
    MESSAGE 'Descrição é obrigatória.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.

  IF gw_cktb003-tpeta IS INITIAL.
    MESSAGE 'Tipo de etapa é obrigatório.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.

  IF gw_cktb003-rotin IS INITIAL.
    MESSAGE 'Rotina é obrigatória.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.

*  IF gw_cktb003-mapea IS INITIAL.
*    MESSAGE 'Mapeamento é obrigatório.' TYPE 'W' DISPLAY LIKE 'E'.
*    has_error = abap_true.
*  ENDIF.
ENDFORM.

*┌────────────────────────────────────────────────────────────────────┐*
*│ F_SALVA_MAPEAMENTO - Salva o mapeamento                            │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_salva_mapeamento .
  IF gw_cktb004 IS NOT INITIAL.
    READ TABLE gt_cktb004 TRANSPORTING NO FIELDS WITH KEY auto    = gw_cktb002-auto
                                                          opera   = gw_cktb002-opera
                                                          etapa   = gw_cktb003-etapa
                                                          tabname = gw_cktb004-tabname
                                                          param   = gw_cktb004-param.
    IF sy-subrc = 0.
      MODIFY gt_cktb004 FROM gw_cktb004 INDEX sy-tabix.
    ELSE.
      APPEND gw_cktb004 TO gt_cktb004.
    ENDIF.
  ENDIF.

  SORT gt_cktb004 BY auto opera etapa tabname param.

  MODIFY /gjaauto/cktb004 FROM TABLE gt_cktb004.
  COMMIT WORK AND WAIT.

  IF sy-subrc = 0.
    MESSAGE 'Mapeamento salvo com sucesso.' TYPE 'S'.
  ELSE.
    MESSAGE 'Erro ao salvar o mapeamento.' TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_add_buttons_pai
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_add_buttons_pai .
  CASE sy-ucomm.
    WHEN 'NEW_AUTO'.
      CALL SCREEN 9104 STARTING AT 5 5.
    WHEN 'NEW_OPERA'.
      CALL SCREEN 9103 STARTING AT 5 5.
    WHEN 'NEW_ETAPA'.
      CALL SCREEN 9101 STARTING AT 5 5.
    WHEN 'NEW_DATA'.
      CALL SCREEN 9100 STARTING AT 5 5.
    WHEN 'SNRO_EDIT'.
      CALL SCREEN 9102 STARTING AT 5 5.
    WHEN 'EDT_ETAPA'.
      IF gv_screen_number_9000 EQ  '9003'.
        CALL SCREEN 9101 STARTING AT 5 5.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.
*┌────────────────────────────────────────────────────────────────────┐*
*│ F_VALIDADE_CKTB002 - Valida os dados do CKTB002                    │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_validade_cktb002 CHANGING has_error TYPE boolean.
  has_error = abap_false.

  IF gw_cktb002-auto IS INITIAL.
    MESSAGE 'Automação é obrigatório.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.
  IF gw_cktb002-opera IS INITIAL.
    MESSAGE 'Código da Operação é obrigatório.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.
  IF gw_cktb002-descr IS INITIAL.
    MESSAGE 'Código da Operação é obrigatório.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.
  IF gw_cktb002-snro IS INITIAL.
    MESSAGE 'Nome do Objeto de númeração é obrigatório.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.
  IF gw_cktb002-snronr IS INITIAL.
    MESSAGE 'Nº do intervalo de numeração é obrigatório.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_validade_cktb001
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- HAS_ERROR
*&---------------------------------------------------------------------*
FORM f_validade_cktb001  CHANGING has_error TYPE boolean.
  IF gw_cktb001-auto IS INITIAL.
    MESSAGE 'Automação é obrigatório.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.
  IF gw_cktb001-descr IS INITIAL.
    MESSAGE 'Descrição da automação é obrigatória.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.
  IF gw_cktb001-icon IS INITIAL.
    MESSAGE 'Icone SAP é obrigatório.' TYPE 'W' DISPLAY LIKE 'E'.
    has_error = abap_true.
  ENDIF.
ENDFORM.
