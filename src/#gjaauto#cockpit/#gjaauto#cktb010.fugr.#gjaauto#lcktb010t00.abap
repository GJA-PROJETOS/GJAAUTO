*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /GJAAUTO/CKTB010................................*
DATA:  BEGIN OF STATUS_/GJAAUTO/CKTB010              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/GJAAUTO/CKTB010              .
CONTROLS: TCTRL_/GJAAUTO/CKTB010
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */GJAAUTO/CKTB010              .
TABLES: /GJAAUTO/CKTB010               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
