FUNCTION /gjaauto/mtf009.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_BANFN) TYPE  BANFN
*"  EXPORTING
*"     REFERENCE(EV_MOTIVO) TYPE  /GJAAUTO/MTE_AGUARDANDO
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  SELECT bnfpo, frgzu FROM eban
    INTO TABLE @DATA(lt_eban)
    WHERE banfn = @iv_banfn.

  IF sy-subrc <> 0.
    APPEND VALUE bapiret2( type    = 'E'
                           message = |Requisição n°{ iv_banfn } não encontrada.| ) TO return.
  ELSEIF line_exists( lt_eban[ frgzu = abap_false ] ).

    APPEND VALUE bapiret2( type    = 'W'
                           message = |Requisição não aprovada.| ) TO return.
    ev_motivo = 'RC'.
  ELSE.
    CLEAR ev_motivo.
  ENDIF.
ENDFUNCTION.
