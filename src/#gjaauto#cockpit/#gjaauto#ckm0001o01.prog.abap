*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃PROCESS BEFORE OUTPUT                                               ┃*
*┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*
MODULE status_9000 OUTPUT.

  DATA(vl_pf_status) = SWITCH string( gv_screen_number_9000
                                        WHEN '9001' THEN 'PF-STATUS_9001'
                                        WHEN '9002' THEN 'PF-STATUS_9002'
                                        WHEN '9003' THEN 'PF-STATUS_9003'
                                        WHEN '9004' THEN 'PF-STATUS_9004'
                                        ELSE 'PF-STATUS_9000'
                                      ).

  SET PF-STATUS vl_pf_status.
  SET TITLEBAR 'TITLEBAR_9000'.
  PERFORM f_search_configs.

  PERFORM f_build_alv_tree.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  gv_auto_icon = |{ gw_cktb001-icon }|.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9002 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9002 OUTPUT.

  READ TABLE gt_cktb001 INTO gw_cktb001 WITH KEY auto = gw_cktb002-auto.
  gv_auto_icon = |{ gw_cktb001-icon }|.

  PERFORM f_build_alv_etapas.
  PERFORM f_build_alv_data_opera.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9003 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9003 OUTPUT.
  READ TABLE gt_cktb001 INTO gw_cktb001 WITH KEY auto = gw_cktb003-auto.
  READ TABLE gt_cktb002 INTO gw_cktb002 WITH KEY auto = gw_cktb003-auto opera = gw_cktb003-opera.
  gv_auto_icon = |{ gw_cktb001-icon }|.

  IF gw_cktb003-rotin NE gv_rotin_loaded.
    PERFORM f_build_alv_tree_mapea.
  ENDIF.

  IF gw_cktb004-param IS NOT INITIAL.
    gv_screen_number_9003 = '9004'.
  ELSE.
    gv_screen_number_9003 = '9999'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9004 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9004 OUTPUT.

* select *
*   from /gjaauto/cktb004
*   into TABLE gt_cktb004
*   WHERE

  PERFORM f_search_desc_standard_param.
  PERFORM f_load_table_from_values.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9100 OUTPUT.
  SET PF-STATUS 'PF-STATUS_9100'.
  SET TITLEBAR 'TITLEBAR_9100'.

  DATA: lt_dd07v TYPE TABLE OF dd07v.
  DATA: lt_vrm_values TYPE TABLE OF vrm_value.
  DATA: lw_vrm_value TYPE vrm_value.

  CLEAR: lt_vrm_values, lt_dd07v.

  gw_cktb005-auto       = gw_cktb002-auto.
  gw_cktb005-opera      = gw_cktb002-opera.

  lw_vrm_value-key = 0.
  lw_vrm_value-text = 'Etapa Seed'.
  APPEND lw_vrm_value TO lt_vrm_values.
  LOOP AT gt_cktb003 INTO DATA(lw_cktb003).
    lw_vrm_value-key = lw_cktb003-etapa.
    lw_vrm_value-text = lw_cktb003-descr.
    APPEND lw_vrm_value TO lt_vrm_values.
  ENDLOOP.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'GW_CKTB005-ETAPA_BORN'
      values          = lt_vrm_values
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.


  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname   = '/GJAAUTO/CKD_NATUREZA_DATA'
      text      = 'X'
    TABLES
      dd07v_tab = lt_dd07v.


  CLEAR lt_vrm_values.
  LOOP AT lt_dd07v INTO DATA(lw_dd07v).
    lw_vrm_value-key = lw_dd07v-domvalue_l.
    lw_vrm_value-text = lw_dd07v-ddtext.
    APPEND lw_vrm_value TO lt_vrm_values.
  ENDLOOP.

  IF line_exists( gt_cktb005[ datanatu = 'V' ] ).
    DELETE lt_vrm_values WHERE key EQ 'V'.
  ENDIF.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'GW_CKTB005-DATANATU'
      values          = lt_vrm_values
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.


  IF gw_cktb005-datanatu IS INITIAL.
    IF line_exists( gt_cktb005[ datanatu = 'I' ] ).
      IF line_exists( gt_cktb005[ datanatu = 'V' ] ).
        gw_cktb005-datanatu = abap_false.
      ELSE.
        gw_cktb005-datanatu = 'V'.
        gw_cktb005-reftype = 'S'.
      ENDIF.
    ELSE.
      gw_cktb005-datanatu = 'I'.
      gw_cktb005-reftype = 'S'.
    ENDIF.
  ENDIF.

  LOOP AT SCREEN.
    IF screen-name = 'GW_CKTB005-ETAPA_BORN' .
      IF gw_cktb005-datanatu EQ 'I' OR gw_cktb005-datanatu EQ 'V'.
        screen-input = 0.
      ELSE.
        screen-input = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF screen-name = 'GW_CKTB005-REFTYPE'.
      IF gw_cktb005-datanatu EQ 'V'.
        screen-input = 0.
      ELSE.
        screen-input = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9101 OUTPUT.
  SET PF-STATUS 'PF-STATUS_9100'.
  SET TITLEBAR 'TITLEBAR_9101'.

  IF gw_cktb003-auto IS INITIAL.
    gw_cktb003-auto  = gw_cktb002-auto.
    gw_cktb003-opera = gw_cktb002-opera.

    gw_cktb003-etapa = REDUCE i( INIT x = 10
                      FOR <linha> IN gt_cktb003 WHERE ( auto = gw_cktb003-auto
                                                    AND opera = gw_cktb003-opera
                                                      )
                      NEXT x = x + 10 ).

    gw_cktb003-tpeta = 'A'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9102 OUTPUT.
  SET PF-STATUS 'PF-STATUS_9100'.

  IF gw_cktb002-snro IS INITIAL.
    gw_cktb002-snro = |ZAUTO{ gw_cktb002-auto }|.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9103 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9103 OUTPUT.
  SET PF-STATUS 'PF-STATUS_9100'.
  SET TITLEBAR 'TITLEBAR_9103'.
  CLEAR: gw_cktb001, gw_cktb002.
  TRY.
      DATA(lo_node) = alv_tree->get_selections( )->get_selected_item( )->get_node( ).
      DATA(outtab) = lo_node->get_data_row( ).
      FIELD-SYMBOLS: <lfs_outtab> TYPE ty_alv_tree_outtab.
      ASSIGN outtab->* TO <lfs_outtab>.
      IF <lfs_outtab> IS ASSIGNED.
        READ TABLE gt_cktb001 INTO gw_cktb001 WITH KEY auto = <lfs_outtab>-auto.
        IF sy-subrc EQ 0.
          gw_cktb002-auto = gw_cktb001-auto.
        ELSE.
          BREAK-POINT.
        ENDIF.
      ENDIF.
    CATCH    cx_sy_ref_is_initial.
      MESSAGE 'Selecione uma Automação primeiro' TYPE 'W'.
  ENDTRY.

  gw_cktb002-snro = 'ZGJAAUTO'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9104 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9104 OUTPUT.
  SET PF-STATUS 'PF-STATUS_9100'.
  SET TITLEBAR 'TITLEBAR_9104'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9005 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9005 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
