CLASS lhc_cds_i_automacoes DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR /gjaauto/cds_i_automacoes RESULT result.

ENDCLASS.

CLASS lhc_cds_i_automacoes IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.
