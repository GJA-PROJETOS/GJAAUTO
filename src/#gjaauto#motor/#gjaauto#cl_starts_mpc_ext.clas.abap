CLASS /gjaauto/cl_starts_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM /gjaauto/cl_starts_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ts_ga101_deep,
        chamadoslist TYPE TABLE OF ts_ga101 WITH DEFAULT KEY.
        INCLUDE TYPE /gjaauto/cl_starts_mpc_ext=>ts_ga101mass.
  TYPES END OF  ts_ga101_deep.
protected section.
private section.
ENDCLASS.



CLASS /GJAAUTO/CL_STARTS_MPC_EXT IMPLEMENTATION.
ENDCLASS.
