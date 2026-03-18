*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /GJAAUTO/CKTB002................................*
DATA:  BEGIN OF STATUS_/GJAAUTO/CKTB002              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/GJAAUTO/CKTB002              .
CONTROLS: TCTRL_/GJAAUTO/CKTB002
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */GJAAUTO/CKTB002              .
TABLES: /GJAAUTO/CKTB002               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
