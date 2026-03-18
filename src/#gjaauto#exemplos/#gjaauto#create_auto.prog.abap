*&---------------------------------------------------------------------*
*& Report /gjaauto/create_auto
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /gjaauto/create_auto.

DATA: lw_data TYPE /gjaauto/mts001,
      lt_data TYPE /gjaauto/mttt001.

DATA: lw_in1001 TYPE zin1001,
      lw_1002   TYPE zin1002,
      lt_in1002 TYPE TABLE OF zin1002.


lw_in1001-doc_type = 'UB'.
lw_in1001-purch_org = '0800'.
lw_in1001-pur_group = 'TPA'.
lw_in1001-suppl_plnt = '0801'.

CREATE DATA lw_data-data LIKE lw_in1001.
ASSIGN lw_data-data->* TO FIELD-SYMBOL(<ftab>).
<ftab> = lw_in1001.
lw_data-name = 'HEADER'.
APPEND lw_data TO lt_data.


lw_1002-ITEM = '00010'.
lw_1002-MATERIAL = '000000003000000130'.
lw_1002-PLANT = '0808'.
lw_1002-QUANTITY = '100'.
lw_1002-PO_UNIT = 'KI'."Caixa
APPEND lw_1002 TO lt_in1002.

*lw_1002-ebelp = '00020'.
*lw_1002-menge = '12'.
*lw_1002-matnr = '000000003000000128'.
*APPEND lw_1002 TO lt_in1002.
*
*lw_1002-ebelp = '00030'.
*lw_1002-menge = '8'.
*lw_1002-matnr = '000000003000000129'.
*APPEND lw_1002 TO lt_in1002.

CREATE DATA lw_data-data LIKE lt_in1002.
ASSIGN lw_data-data->* TO <ftab>.
<ftab> = lt_in1002.
lw_data-name = 'ITEMS'.
APPEND lw_data TO lt_data.


CALL FUNCTION '/GJAAUTO/MTF001'
  EXPORTING
    iv_auto  = 'IN'
    iv_opera = '100'
  TABLES
    it_data  = lt_data.
