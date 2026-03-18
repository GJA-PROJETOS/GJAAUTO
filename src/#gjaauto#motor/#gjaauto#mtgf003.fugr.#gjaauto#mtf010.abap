FUNCTION /gjaauto/mtf010.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_EBELN) TYPE  EBELN
*"  EXPORTING
*"     REFERENCE(EV_MOTIVO) TYPE  /GJAAUTO/MTE_AGUARDANDO
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  SELECT SINGLE frgrl FROM ekko
    INTO @DATA(lv_frgrl)
    WHERE ebeln = @iv_EBELN.

  IF sy-subrc <> 0.
    APPEND VALUE bapiret2( type    = 'E'
                           message = |Pedido n°{ iv_ebeln } não encontrada.| ) TO return.
  ELSEIF lv_frgrl <> space.
    APPEND VALUE bapiret2( type    = 'W'
                           message = |Pedido de compra não aprovado.| ) TO return.
    ev_motivo = 'PO'.
  ELSE.
    CLEAR ev_motivo.
  ENDIF.
ENDFUNCTION.
