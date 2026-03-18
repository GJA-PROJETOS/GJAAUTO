*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /GJAAUTO/CKTB009................................*
DATA:  BEGIN OF STATUS_/GJAAUTO/CKTB009              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/GJAAUTO/CKTB009              .
CONTROLS: TCTRL_/GJAAUTO/CKTB009
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */GJAAUTO/CKTB009              .
TABLES: /GJAAUTO/CKTB009               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
