*&---------------------------------------------------------------------*
*& Include          /GJAAUTO/CKM0001C02
*&---------------------------------------------------------------------*

CLASS cl_alv_etapas_opera_events DEFINITION.
  PUBLIC SECTION.
    METHODS: on_link_click FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.                    "lcl_handle_events DEFINITION
DATA: event_handler TYPE REF TO cl_alv_etapas_opera_events.
CLASS cl_alv_etapas_opera_events IMPLEMENTATION.
  METHOD on_link_click.
    READ TABLE gt_alv_etapas_out INTO DATA(lw_alv_etapas_out) INDEX row.
    READ TABLE gt_cktb003 INTO gw_cktb003 WITH KEY etapa = lw_alv_etapas_out-etapa
                                                    auto = lw_alv_etapas_out-auto
                                                   opera = lw_alv_etapas_out-opera.
    CASE column.
      WHEN 'ETAPA'.
        gv_screen_number_9000 = c_etapa.
        CALL SCREEN 9000.
      WHEN 'EDIT_BUTTON'.
        CALL SCREEN 9101 STARTING AT 5 5.
          PERFORM f_build_alv_etapas.
    ENDCASE.
  ENDMETHOD.                    "on_link_click
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION
