*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /GJAAUTO/CKTB001................................*
DATA:  BEGIN OF STATUS_/GJAAUTO/CKTB001              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/GJAAUTO/CKTB001              .
CONTROLS: TCTRL_/GJAAUTO/CKTB001
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */GJAAUTO/CKTB001              .
TABLES: /GJAAUTO/CKTB001               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
