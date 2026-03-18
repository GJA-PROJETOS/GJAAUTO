*&---------------------------------------------------------------------*
*& Include          /GJAAUTO/COCKPIT_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'PF-STATUS-9000'.
  SET TITLEBAR 'TITLEBAR-9000'.

  DATA vl_window_width TYPE  i.
  DATA alv1     TYPE REF TO cl_salv_table.
  DATA alv2     TYPE REF TO cl_salv_table.

  CHECK go_docking IS NOT BOUND.

* Criação de do Objeto docking que vai a tela chamada como referencia.
  CREATE OBJECT go_docking
    EXPORTING
*     parent                      =     " Parent container
      repid                       = sy-repid
      " Report to Which This Docking Control is Linked
      dynnr                       = sy-dynnr
      " Screen to Which This Docking Control is Linked
      extension                   = cl_gui_docking_container=>ws_maximizebox
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

  CALL FUNCTION 'NAVIGATION_GET_WINDOW_WIDTH'
    EXPORTING
      uname        = sy-uname
    IMPORTING
      window_width = vl_window_width.

*  CREATE OBJECT go_container
*    EXPORTING
*      container_name = 'CC_MAIN'.

  CREATE OBJECT go_splitter
    EXPORTING
      width   = vl_window_width
      parent  = go_docking
      rows    = 1
      columns = 2.

  go_splitter->get_height( IMPORTING height = vl_window_width ).

  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_cont_left.

  go_splitter->set_column_width(
    EXPORTING
      id    = 1
      width = CONV i( vl_window_width * '0.2' )
  ).

  go_splitter->set_column_width(
    EXPORTING
      id    = 2
      width = CONV i( vl_window_width * '0.8' )
  ).

  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = go_cont_right.

  go_cont_right->set_width( vl_window_width MOD 3 ).

  SELECT *
    FROM /gjaauto/cktb001
    INTO TABLE @DATA(tbck001).

  cl_salv_table=>factory(
    EXPORTING
      r_container  = go_cont_left
    IMPORTING
      r_salv_table = alv1
    CHANGING
      t_table      = tbck001 ).

  SELECT *
    FROM /gjaauto/cktb002
    INTO TABLE @DATA(tbck002).

  cl_salv_table=>factory(
    EXPORTING
      r_container  = go_cont_right
    IMPORTING
      r_salv_table = alv2
    CHANGING
      t_table      = tbck002 ).

  alv1->display( ).
  alv2->display( ).

ENDMODULE.
