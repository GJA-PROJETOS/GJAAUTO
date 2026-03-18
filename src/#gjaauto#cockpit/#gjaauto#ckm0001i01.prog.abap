*&---------------------------------------------------------------------*
*& Include          /GJAAUTO/CKM0001I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  PERFORM f_add_buttons_pai.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.
  PERFORM f_add_buttons_pai.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9002 INPUT.
  PERFORM f_add_buttons_pai.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9003  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9003 INPUT.
  CASE sy-ucomm.
    WHEN 'PREVIOUS_ETAPA'.
      DATA(lv_index) = sy-tabix.
      LOOP AT gt_cktb003 INTO gw_cktb003
           WHERE auto = gw_cktb003-auto
             AND opera = gw_cktb003-opera
             AND etapa < gw_cktb003-etapa.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        CLEAR gw_cktb004.
      ENDIF.

    WHEN 'NEXT_ETAPA'.
      LOOP AT gt_cktb003 INTO gw_cktb003
           WHERE auto = gw_cktb003-auto
             AND opera = gw_cktb003-opera
             AND etapa > gw_cktb003-etapa.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        CLEAR gw_cktb004.
      ENDIF.

    WHEN 'OK' OR 'SAVE'.
      PERFORM f_salva_mapeamento.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9004  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9004 INPUT.
  CASE sy-ucomm.
    WHEN 'ORIGIN'.
      PERFORM f_load_param_from.
    WHEN 'OK' OR 'SAVE'.
      PERFORM f_salva_mapeamento.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.

MODULE user_command_9100 INPUT.
  DATA has_error TYPE boolean.
  CASE sy-ucomm.
    WHEN 'SET_DATANATU'.
      IF gw_cktb005-datanatu EQ 'I' OR gw_cktb005-datanatu EQ 'V'.
        gw_cktb005-etapa_born = 0.
        IF gw_cktb005-datanatu EQ 'V'.
          gw_cktb005-reftype = 'S'.
        ENDIF.
      ELSE.
        IF gw_cktb005-etapa_born = 0.
          CLEAR gw_cktb005-etapa_born.
        ENDIF.
      ENDIF.
    WHEN 'VERIFICAR'.
      PERFORM f_validade_cktb005 CHANGING has_error.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'OK'.
      PERFORM f_validade_cktb005 CHANGING has_error.

      CHECK has_error IS INITIAL.

      TRANSLATE gw_cktb005-name  TO UPPER CASE.
      TRANSLATE gw_cktb005-reftypname  TO UPPER CASE.


      " Verifica se o registro já existe
      SELECT SINGLE *
        FROM /gjaauto/cktb005
        INTO @DATA(wl_cktb005_temp)
       WHERE auto  = @gw_cktb005-auto
         AND opera = @gw_cktb005-opera
         AND name  = @gw_cktb005-name.

      IF sy-subrc = 0.
        IF wl_cktb005_temp-etapa_born <> gw_cktb005-etapa_born
        OR wl_cktb005_temp-datanatu   <> gw_cktb005-datanatu
        OR wl_cktb005_temp-reftype    <> gw_cktb005-reftype
        OR wl_cktb005_temp-name       <> gw_cktb005-name
        OR wl_cktb005_temp-reftypname <> gw_cktb005-reftypname.

          " Registro já existe, faz update (sem alterar campos chave)
          UPDATE /gjaauto/cktb005 FROM gw_cktb005.
          IF sy-subrc = 0.
            COMMIT WORK AND WAIT.
            MESSAGE 'Registro atualizado com sucesso.' TYPE 'S'.

            " Atualiza a tabela interna
            MODIFY gt_cktb005 FROM gw_cktb005
            TRANSPORTING reftypname reftype etapa_born datanatu
            WHERE mandt = sy-mandt
              AND auto  = gw_cktb005-auto
              AND opera = gw_cktb005-opera
              AND name = gw_cktb005-name.

          ENDIF.
        ENDIF.
      ELSE.
        IF gw_cktb005-datanatu = 'V'.
          READ TABLE gt_cktb005 TRANSPORTING NO FIELDS WITH KEY datanatu = 'V'.
          IF sy-subrc IS INITIAL.
            MESSAGE 'Tabela de variáveis já cadastrada' TYPE 'S'.
          ENDIF.
        ENDIF.

        " Registro não existe, faz insert
        INSERT /gjaauto/cktb005 FROM gw_cktb005.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
          MESSAGE 'Registro criado com sucesso.' TYPE 'S'.

          " Atualiza a tabela interna
          APPEND gw_cktb005 TO gt_cktb005.
        ENDIF.
      ENDIF.

      CLEAR gw_cktb005.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
MODULE user_command_9101 INPUT.
  CASE sy-ucomm.
    WHEN 'VERIFICAR'.
      PERFORM f_validade_cktb003 CHANGING has_error.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'OK'.
      PERFORM f_validade_cktb003 CHANGING has_error.

      CHECK has_error IS INITIAL.

      " Verifica se o registro já existe
      SELECT SINGLE *
        FROM /gjaauto/cktb003
        INTO @DATA(wl_cktb003_temp)
       WHERE auto  = @gw_cktb003-auto
         AND opera = @gw_cktb003-opera
         AND etapa = @gw_cktb003-etapa.

      IF sy-subrc = 0.
        IF wl_cktb003_temp-descr        <> gw_cktb003-descr
        OR wl_cktb003_temp-tpeta        <> gw_cktb003-tpeta
        OR wl_cktb003_temp-rotin        <> gw_cktb003-rotin
        OR wl_cktb003_temp-commit_after <> gw_cktb003-commit_after
        OR wl_cktb003_temp-after        <> gw_cktb003-after
        OR wl_cktb003_temp-mapea        <> gw_cktb003-mapea.

          " Registro já existe, faz update
          UPDATE /gjaauto/cktb003
             SET descr        = @gw_cktb003-descr,
                 tpeta        = @gw_cktb003-tpeta,
                 rotin        = @gw_cktb003-rotin,
                 mapea        = @gw_cktb003-mapea,
                 commit_after = @gw_cktb003-commit_after,
                 after        = @gw_cktb003-after
           WHERE auto         = @gw_cktb003-auto
             AND opera        = @gw_cktb003-opera
             AND etapa        = @gw_cktb003-etapa.

          IF sy-subrc = 0.
            COMMIT WORK AND WAIT.
            MESSAGE 'Etapa atualizada com sucesso.' TYPE 'S'.

            " Atualiza a tabela de etapas
            MODIFY gt_cktb003 FROM gw_cktb003
      TRANSPORTING descr tpeta rotin mapea
             WHERE auto = gw_cktb003-auto
               AND opera = gw_cktb003-opera
               AND etapa = gw_cktb003-etapa.

          ENDIF.
        ENDIF.
      ELSE.

        " Registro não existe, faz insert
        INSERT /gjaauto/cktb003 FROM gw_cktb003.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
          MESSAGE 'Etapa criada com sucesso.' TYPE 'S'.

          " Atualiza a tabela de etapas
          APPEND gw_cktb003 TO gt_cktb003.
          CLEAR gw_cktb003.
        ENDIF.
      ENDIF.

      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9102 INPUT.
  CASE sy-ucomm.
    WHEN 'VERIFICAR'.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  HELP_SEARCH_SNRO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_search_snro INPUT.
  DATA: it_return_tab TYPE ddshretval OCCURS 0,
        wa_return     LIKE LINE OF it_return_tab.

  SELECT *
    FROM nriv
    INTO TABLE @DATA(lt_nriv)
   WHERE object EQ @gw_cktb002-snro
     AND subobject EQ @gw_cktb001-auto.

  IF sy-subrc EQ 0.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield    = 'NRRANGENR'
        dynpprog    = sy-repid
        dynpnr      = sy-dynnr
        dynprofield = 'NRIV-NRRANGENR'
        value_org   = 'S'
      TABLES
        value_tab   = lt_nriv
        return_tab  = it_return_tab.

    IF lines( it_return_tab ) > 0.
      READ TABLE it_return_tab INTO wa_return INDEX 1.
      gw_cktb002-snronr = wa_return-fieldval.
    ENDIF.
  ELSE.
    DATA(vl_text) = |Antes de prosseguir, cadastre o intervalo de numeração na transação SNRO: Objeto { gw_cktb002-snro }, utilizando o código de automação '{ gw_cktb001-auto }'.|.
    MESSAGE vl_text TYPE 'I'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9103 INPUT.
  CASE sy-ucomm.
    WHEN 'VERIFICAR'.
      PERFORM f_validade_cktb002 CHANGING has_error.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'OK'.
      PERFORM f_validade_cktb002 CHANGING has_error.

      CHECK has_error IS INITIAL.

      " Verifica se o registro já existe
      SELECT SINGLE *
        FROM /gjaauto/cktb002
        INTO @DATA(wl_cktb002_temp)
       WHERE auto  = @gw_cktb002-auto
         AND opera = @gw_cktb002-opera.

      IF sy-subrc = 0.
        IF wl_cktb002_temp-descr  <> gw_cktb002-descr
        OR wl_cktb002_temp-snro   <> gw_cktb002-snro
        OR wl_cktb002_temp-snronr <> gw_cktb002-snronr.

          gw_cktb002-descr  = wl_cktb002_temp-descr .
          gw_cktb002-snro = wl_cktb002_temp-snro.
          gw_cktb002-snronr = wl_cktb002_temp-snronr.

          " Registro já existe, faz update
          UPDATE /gjaauto/cktb002 FROM gw_cktb002.
          IF sy-subrc = 0.
            COMMIT WORK AND WAIT.
            MESSAGE 'Etapa atualizada com sucesso.' TYPE 'S'.

            " Atualiza a tabela de etapas
            MODIFY gt_cktb002 FROM gw_cktb002
      TRANSPORTING descr snro snronr
             WHERE auto = gw_cktb002-auto
               AND opera = gw_cktb002-opera.

            gv_updated = true."Atualiza o AlvTree

          ENDIF.
        ENDIF.
      ELSE.

        " Registro não existe, faz insert
        INSERT /gjaauto/cktb002 FROM gw_cktb002.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
          MESSAGE 'Operação criada com sucesso.' TYPE 'S'.

          " Atualiza a tabela de etapas
          APPEND gw_cktb002 TO gt_cktb002.

          DATA(l_opera_key) = alv_tree->get_selections( )->get_selected_item( )->get_node( )->get_key( ).
          DATA(lw_outtab) = VALUE ty_alv_tree_outtab(
                auto  = gw_cktb002-auto
                opera = gw_cktb002-opera
                ).
          PERFORM f_add_opera_node USING gw_cktb002-opera gw_cktb002-descr l_opera_key lw_outtab abap_true CHANGING l_opera_key.
          CALL METHOD cc_alv_tree->free.
          CLEAR alv_tree.
          REFRESH gt_alv_tree_out.
        ENDIF.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9104  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9104 INPUT.
  CASE sy-ucomm.
    WHEN 'VERIFICAR'.
      PERFORM f_validade_cktb001 CHANGING has_error.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'OK'.
      PERFORM f_validade_cktb001 CHANGING has_error.

      CHECK has_error IS INITIAL.

      " Verifica se o registro já existe
      SELECT SINGLE *
      FROM /gjaauto/cktb001
      INTO @DATA(wl_cktb001_temp)
            WHERE auto  = @gw_cktb001-auto.

      IF sy-subrc = 0.
        IF wl_cktb001_temp-descr <> gw_cktb001-descr
        OR wl_cktb001_temp-icon <> gw_cktb001-icon
        OR wl_cktb001_temp-icon_fiori <> gw_cktb001-icon_fiori.

          gw_cktb001-descr = wl_cktb001_temp-descr.
          gw_cktb001-icon = wl_cktb001_temp-icon.
          gw_cktb001-icon_fiori = wl_cktb001_temp-icon_fiori.

          " Registro já existe, faz update
          UPDATE /gjaauto/cktb001 FROM gw_cktb001.
          IF sy-subrc = 0.
            COMMIT WORK AND WAIT.
            MESSAGE 'Etapa atualizada com sucesso.' TYPE 'S'.

            " Atualiza a tabela de etapas
            MODIFY gt_cktb001 FROM gw_cktb001
            TRANSPORTING descr icon icon_fiori
            WHERE auto = gw_cktb001-auto.


          ENDIF.
        ENDIF.
      ELSE.

        " Registro não existe, faz insert
        INSERT /gjaauto/cktb001 FROM gw_cktb001.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
          MESSAGE 'Operação criada com sucesso.' TYPE 'S'.

          " Atualiza a tabela de etapas
          APPEND gw_cktb001 TO gt_cktb001.

          PERFORM f_add_auto_node USING gw_cktb001 CHANGING l_opera_key.
          CALL METHOD cc_alv_tree->free.
          CLEAR alv_tree.
          REFRESH gt_alv_tree_out.
        ENDIF.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9005  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9005 INPUT.

ENDMODULE.
