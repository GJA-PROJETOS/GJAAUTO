CLASS /gjaauto/cl_main_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM /gjaauto/cl_main_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ts_functionimportdoku_deep,
        changing      TYPE TABLE OF ts_changingparameter WITH DEFAULT KEY,
        dokumentation TYPE TABLE OF ts_dokumentation WITH DEFAULT KEY,
        exception     TYPE TABLE OF ts_exceptionlist WITH DEFAULT KEY,
        export        TYPE TABLE OF ts_exportparameter WITH DEFAULT KEY,
        import        TYPE TABLE OF ts_importparameter WITH DEFAULT KEY,
        tables        TYPE TABLE OF ts_tablesparameter WITH DEFAULT KEY.
        INCLUDE TYPE /gjaauto/cl_main_mpc=>ts_functionimportdoku.
  TYPES END OF  ts_functionimportdoku_deep.
    TYPES:
tt_functionimportdoku_deep TYPE STANDARD TABLE OF ts_functionimportdoku_deep .


    TYPES:
      BEGIN OF ts_parameterdoku_deep,
        items          TYPE TABLE OF /gjaauto/cl_main_mpc=>ts_parameterdokuitem WITH DEFAULT KEY,
        fixvaluesitems TYPE TABLE OF /gjaauto/cl_main_mpc=>ts_fixvalueitems WITH DEFAULT KEY.
        INCLUDE TYPE /gjaauto/cl_main_mpc=>ts_parameterdoku.
  TYPES END OF  ts_parameterdoku_deep.
    TYPES:
        tt_parameterdoku_deep TYPE STANDARD TABLE OF ts_parameterdoku_deep.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.



CLASS /GJAAUTO/CL_MAIN_MPC_EXT IMPLEMENTATION.
ENDCLASS.
