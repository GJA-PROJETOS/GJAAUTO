*&---------------------------------------------------------------------*
*& Include          /GJAAUTO/CKM0001C03
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          /GJAAUTO/CKM0001C01
*&---------------------------------------------------------------------*
CLASS cl_alv_tree_mapea_event_hdlr DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS on_link_click                   " LINK_CLICK
      FOR EVENT if_salv_events_tree~link_click
      OF cl_salv_events_tree
      IMPORTING columnname
                node_key.
ENDCLASS.                    "cl_event_handler DEFINITION

CLASS cl_alv_tree_mapea_event_hdlr IMPLEMENTATION.
  METHOD on_link_click.

    CHECK node_key IS NOT INITIAL.

    DATA: lo_nodes TYPE REF TO cl_salv_nodes,
          lo_node  TYPE REF TO cl_salv_node.

    DATA lv_qtd TYPE i VALUE 0.

    FIELD-SYMBOLS: <fs_conteudo> TYPE ty_alv_tree_mapea_outtab.

    lo_nodes = alv_tree_mapea->get_nodes( ).
    lo_node  = lo_nodes->get_node( node_key ).
    IF lo_node IS BOUND.
      DATA(data_row) = lo_node->get_data_row( ).

      ASSIGN data_row->* TO <fs_conteudo>.

      CHECK <fs_conteudo>-param IS NOT INITIAL.

      "Salva o mapeamento atual
      IF gw_cktb004-auto IS NOT INITIAL
     AND gw_cktb004-opera IS NOT INITIAL
     AND gw_cktb004-etapa IS NOT INITIAL.

        "Verifica se existe mapeamento
        READ TABLE gt_cktb004 TRANSPORTING NO FIELDS WITH KEY tabname = gw_cktb004-tabname
                                                              param   = gw_cktb004-param.
        IF sy-subrc EQ 0.
          "Atualiza tabela
          MODIFY TABLE gt_cktb004 FROM gw_cktb004.
        ELSEIF ( gw_cktb004-param_from IS NOT INITIAL "Salva o mapeamento se tiver configuração, para não sujar as tabelas
            AND gw_cktb004-tabname_from IS NOT INITIAL )
            OR gw_cktb004-paramval IS NOT INITIAL.
          APPEND gw_cktb004 TO gt_cktb004.
        ENDIF.
        CLEAR gw_cktb004.
      ENDIF.

      READ TABLE gt_cktb004 INTO gw_cktb004 WITH KEY auto    = gw_cktb003-auto
                                                     opera   = gw_cktb003-opera
                                                     etapa   = gw_cktb003-etapa
                                                     tabname = <fs_conteudo>-tabname
                                                     param   = <fs_conteudo>-param.
      "Novo mapeamento
      IF sy-subrc NE 0.

        gw_cktb004-auto = gw_cktb003-auto.
        gw_cktb004-opera = gw_cktb003-opera.
        gw_cktb004-etapa = gw_cktb003-etapa.

        lv_qtd = REDUCE i( INIT x = 0
                           FOR <linha> IN gt_cktb004 WHERE ( auto = gw_cktb003-auto
                                                         AND opera = gw_cktb003-opera
                                                         AND etapa = gw_cktb003-etapa
                                                           )
                           NEXT x = x + 1 ).

        gw_cktb004-seqnr = lv_qtd + 1.
        gw_cktb004-paramnat = <fs_conteudo>-paramnat.
        gw_cktb004-tabname = <fs_conteudo>-tabname.
        gw_cktb004-param   = <fs_conteudo>-param.
        gw_cktb004-paramtyp = <fs_conteudo>-paramtyp.

      ENDIF.

      CALL SCREEN 9000.

    ENDIF.
  ENDMETHOD.                    "on_link_click
ENDCLASS.                    "cl_event_handler IMPLEMENTATION
