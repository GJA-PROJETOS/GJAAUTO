FUNCTION /gjaauto/mtf005.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(IV_AUTO) TYPE  /GJAAUTO/CKE_AUTOMACAO
*"     REFERENCE(IV_OPERA) TYPE  /GJAAUTO/CKE_OPERARACAO
*"     REFERENCE(IV_CHAVE) TYPE  /GJAAUTO/MTE_CHAVE
*"  TABLES
*"      IT_DATA TYPE  /GJAAUTO/MTTT001
*"  EXCEPTIONS
*"      DATA_MAPPING_NOT_FOUND
*"      NUMBER_RANGE_NOT_FOUND
*"      DATA_WITH_ERROR
*"----------------------------------------------------------------------


  CONSTANTS c_dados_inicial TYPE c LENGTH 2 VALUE 'I'.

  " Field-symbols dinâmicos para acesso às estruturas/tabelas
  FIELD-SYMBOLS: <fs_table> TYPE STANDARD TABLE,
                 <fs_line>  TYPE any,
                 <fs_chave> TYPE any.

  " Recupera mapeamentos de estrutura/tabela para automação/operação
  SELECT *
    FROM /gjaauto/cktb005
    INTO TABLE @DATA(lt_mapeamento)
    WHERE auto     = @iv_auto
      AND opera    = @iv_opera
      AND datanatu = @c_dados_inicial.

  IF sy-subrc <> 0.
    RAISE number_range_not_found.
  ENDIF.

  LOOP AT it_data INTO DATA(ls_data).

    " Verifica se há mapeamento para o nome informado
    READ TABLE lt_mapeamento INTO DATA(ls_mapeamento)
      WITH KEY name = ls_data-name.
    IF sy-subrc <> 0.
      RAISE data_mapping_not_found.
    ENDIF.

    " Verifica o tipo de referência: tabela ou estrutura
    CASE ls_mapeamento-reftype.

      WHEN 'T'. " Tabela
        ASSIGN ls_data-data->* TO <fs_table>.
        LOOP AT <fs_table> ASSIGNING <fs_line>.
          ASSIGN COMPONENT 'CHAVE' OF STRUCTURE <fs_line> TO <fs_chave>.
          IF sy-subrc <> 0.
            ROLLBACK WORK.
            RAISE data_with_error.
          ENDIF.
          <fs_chave> = iv_chave.
          INSERT (ls_mapeamento-reftypname) FROM <fs_line>.
        ENDLOOP.

      WHEN 'S'. " Estrutura
        ASSIGN ls_data-data->* TO <fs_line>.
        ASSIGN COMPONENT 'CHAVE' OF STRUCTURE <fs_line> TO <fs_chave>.
        IF sy-subrc <> 0.
          ROLLBACK WORK.
          RAISE data_with_error.
        ENDIF.
        <fs_chave> = iv_chave.
        INSERT (ls_mapeamento-reftypname) FROM <fs_line>.

    ENDCASE.

  ENDLOOP.

  COMMIT WORK AND WAIT.

ENDFUNCTION.
