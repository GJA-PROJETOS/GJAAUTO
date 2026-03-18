*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /GJAAUTO/CKTB003................................*
DATA:  BEGIN OF STATUS_/GJAAUTO/CKTB003              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/GJAAUTO/CKTB003              .
CONTROLS: TCTRL_/GJAAUTO/CKTB003
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */GJAAUTO/CKTB003              .
TABLES: /GJAAUTO/CKTB003               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
