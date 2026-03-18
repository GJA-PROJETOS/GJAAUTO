*&---------------------------------------------------------------------*
*& Include          /GJAAUTO/CKM0001C01
*&---------------------------------------------------------------------*
CLASS cl_alv_tree_auto_event_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS on_link_click                   " LINK_CLICK
      FOR EVENT if_salv_events_tree~link_click
      OF cl_salv_events_tree
      IMPORTING columnname
                node_key.

    CLASS-METHODS on_user_command FOR EVENT added_function OF cl_salv_events
      IMPORTING e_salv_function.

ENDCLASS.                    "cl_event_handler DEFINITION

CLASS cl_alv_tree_auto_event_handler IMPLEMENTATION.
  METHOD on_link_click.

    CHECK node_key IS NOT INITIAL.

    CLEAR: gw_cktb001,
           gw_cktb002,
           gw_cktb003,
           gt_cktb004.

    DATA: lo_nodes TYPE REF TO cl_salv_nodes,
          lo_node  TYPE REF TO cl_salv_node.

    FIELD-SYMBOLS: <fs_conteudo> TYPE ty_alv_tree_outtab.

    lo_nodes = alv_tree->get_nodes( ).
    lo_node  = lo_nodes->get_node( node_key ).
    IF lo_node IS BOUND.
      DATA(data_row) = lo_node->get_data_row( ).

      ASSIGN data_row->* TO <fs_conteudo>.

      IF <fs_conteudo>-etapa IS NOT INITIAL." Exibe a tela de detalhes da etapa
        CLEAR gw_cktb004.
        gv_screen_number_9000 = c_etapa.
        READ TABLE gt_cktb003 INTO gw_cktb003 WITH KEY etapa = <fs_conteudo>-etapa
                                                        auto = <fs_conteudo>-auto
                                                       opera = <fs_conteudo>-opera.

        SELECT *
          FROM /gjaauto/cktb004
          INTO TABLE gt_cktb004
         WHERE auto = <fs_conteudo>-auto
           AND opera = <fs_conteudo>-opera
           AND etapa = <fs_conteudo>-etapa.

        SELECT *
          FROM /gjaauto/cktb005
          INTO TABLE gt_cktb005
         WHERE auto = <fs_conteudo>-auto
           AND opera = <fs_conteudo>-opera.

      ELSEIF <fs_conteudo>-opera IS NOT INITIAL." Exibe a tela de detalhes da operação
        gv_screen_number_9000 = c_opera.
        READ TABLE gt_cktb002 INTO gw_cktb002 WITH KEY opera = <fs_conteudo>-opera
                                                        auto = <fs_conteudo>-auto.
      ELSEIF <fs_conteudo>-auto IS NOT INITIAL." Exibe a tela de detalhes da automação
        gv_screen_number_9000 = c_auto.
        READ TABLE gt_cktb001 INTO gw_cktb001 WITH KEY auto = <fs_conteudo>-auto.
      ENDIF.

      CALL SCREEN 9000.

    ENDIF.
  ENDMETHOD.                    "on_link_click

  METHOD on_user_command.
    BREAK-POINT.
  ENDMETHOD.
ENDCLASS.                    "cl_event_handler IMPLEMENTATION
