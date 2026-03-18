*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃SUBROTINAS Para o cl_salv_table                                     ┃*
*┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*

*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃F_SET_COLUMN_WIDTH - Define a largura da coluna                     ┃*
*┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩*
*│ -> ENTRADAS                                                        │*
*│    -> P_COLUMN_NAME               "NOME DA COLUNA                  │*
*│    -> P_SIZE                      "LARGURA                         │*
*│    -> P_SALV_TABLE                "OBJECTO DO CL_SALV_TABLE        │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_set_column_width USING p_column_name TYPE lvc_fname
                              p_size        TYPE lvc_outlen
                              p_salv_table  TYPE REF TO cl_salv_table.
  alv_columns = p_salv_table->get_columns( ).
  TRY.
      alv_column = alv_columns->get_column( p_column_name ).
      IF alv_column IS NOT INITIAL.
        alv_column->set_output_length( p_size ).
      ENDIF.
    CATCH cx_salv_not_found.
  ENDTRY.
ENDFORM.                    " F_SET_COLUMN_WIDTH

*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃F_SET_TOOLBAR_VISIBILITY - Ativa ou desativa a toolbar              ┃*
*┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩*
*│ -> ENTRADAS                                                        │*
*│    -> P_SHOW_TOOLBAR               "ABAP_TRUE ou ABAP_FALSE        │*
*│    -> P_SALV_TABLE                 "OBJETO DO CL_SALV_TABLE        │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_set_toolbar_visibility USING p_show_toolbar TYPE abap_bool
                                    p_salv_table   TYPE REF TO cl_salv_table.

  DATA(lo_functions) = p_salv_table->get_functions( ).
  lo_functions->set_all( p_show_toolbar ).

ENDFORM.                    " F_SET_TOOLBAR_VISIBILITY


*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃F_SET_COLUMN_POSITION - Define a posiçao da coluna                  ┃*
*┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩*
*│ -> ENTRADAS                                                        │*
*│    -> P_COLUMN_NAME               "NOME DA COLUNA                  │*
*│    -> P_POSITION                  "POSIÇÃO                         │*
*│    -> P_SALV_TABLE                "OBJECTO DO CL_SALV_TABLE        │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_set_column_position USING p_column_name TYPE lvc_fname
                                  p_position    TYPE i
                                  p_salv_table  TYPE REF TO cl_salv_table.
  alv_columns = p_salv_table->get_columns( ).
  alv_columns->set_column_position( columnname = p_column_name
                                    position   = p_position ).
ENDFORM.

*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃F_SET_COLUMNS_OPTIMIZE - Otimiza a largurda das colunas             ┃*
*┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩*
*│ -> ENTRADAS                                                        │*
*│    -> P_COLUMN_NAME               "NOME DA COLUNA                  │*
*│    -> P_SALV_TABLE                "OBJECTO DO CL_SALV_TABLE        │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_set_columns_optimize USING p_salv_table  TYPE REF TO cl_salv_table.
  alv_columns = p_salv_table->get_columns( ).
  alv_columns->set_optimize( abap_true ).
ENDFORM.

*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃F_SET_COLUMN_TEXT - Define o texto da coluna                        ┃*
*┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩*
*│ -> ENTRADAS                                                        │*
*│    -> P_COLUMN_NAME               "NOME DA COLUNA                  │*
*│    -> P_SHORT_TEXT                "TEXTO PEQUENO                   │*
*│    -> P_MEDIUM_TEXT               "TEXTO MÉDIO                     │*
*│    -> P_LONG_TEXT                 "TEXTO LONGO                     │*
*│    -> P_SALV_TABLE                "OBJECTO DO CL_SALV_TABLE        │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_set_column_text USING p_column_name TYPE lvc_fname
                              p_short_text  TYPE scrtext_s
                              p_medium_text TYPE scrtext_m
                              p_long_text   TYPE scrtext_l
                              p_salv_table  TYPE REF TO cl_salv_table.
  alv_columns = p_salv_table->get_columns( ).
  TRY.
      alv_column = alv_columns->get_column( p_column_name ).
      IF alv_column IS NOT INITIAL.
        alv_column->set_short_text( p_short_text ).
        alv_column->set_medium_text( p_medium_text ).
        alv_column->set_long_text( p_long_text ).
      ENDIF.
    CATCH cx_salv_not_found.
  ENDTRY.
ENDFORM.

*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃F_SET_COLUMN_VISIBLE - Define se uma coluna e visivel               ┃*
*┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩*
*│ -> ENTRADAS                                                        │*
*│    -> P_COLUMN_NAME               "NOME DA COLUNA                  │*
*│    -> P_VALUE                     "Valor                           │*
*│    -> P_SALV_TABLE                "OBJECTO DO CL_SALV_TABLE        │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_set_column_visible USING p_column_name TYPE lvc_fname
                                p_value       TYPE sap_bool
                                p_salv_table  TYPE REF TO cl_salv_table.
  alv_columns = p_salv_table->get_columns( ).
  TRY.
      alv_column = alv_columns->get_column( p_column_name ).
      IF alv_column IS NOT INITIAL.
        alv_column->set_visible( p_value ).
      ENDIF.
    CATCH cx_salv_not_found.
  ENDTRY.
ENDFORM.

*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃F_SET_COLUMN_TYPE - Define a coluna como hotspot                    ┃*
*┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩*
*│ -> ENTRADAS                                                        │*
*│    -> P_COLUMN_NAME               "NOME DA COLUNA                  │*
*│    -> P_SALV_TABLE                "OBJECTO DO CL_SALV_TABLE        │*
*│    -> P_COLUMN_TYPE               "TIPO DA COLUNA                  │*
*├────────────────────────────────────────────────────────────────────┤*
*│  0 = TEXT                                                          │*
*│  5 = PONTO ATIVO                                                   │*
*│  4 = LINK                                                     	  │*
*│  1 = CAMPO DE SELEÇÃO                                              │*
*│  2 = BOTÃO                                                         │*
*│  3 = DROP-DOWN                                                     │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_set_column_type USING p_column_name TYPE lvc_fname
                             p_column_type TYPE salv_de_celltype
                             p_salv_table  TYPE REF TO cl_salv_table.

  CHECK p_salv_table IS BOUND.

  DATA: alv_column_table  TYPE REF TO cl_salv_column_table.

  alv_columns = p_salv_table->get_columns( ).

  TRY.
      alv_column_table ?= alv_columns->get_column( p_column_name ).
      alv_column_table->set_cell_type( p_column_type ).
    CATCH cx_salv_not_found cx_sy_move_cast_error.
      " Coluna não encontrada ou erro de casting
  ENDTRY.

  " Verifica se handler já foi criado
  IF event_handler IS INITIAL.
    CREATE OBJECT event_handler.

    DATA(events) = p_salv_table->get_event( ).
    SET HANDLER event_handler->on_link_click FOR events.
  ENDIF.

ENDFORM.

*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃F_SET_COLUMN_DROPDOWN - Define a coluna como dropdown               ┃*
*┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩*
*│ -> ENTRADAS                                                        │*
*│    -> P_COLUMN_NAME               "NOME DA COLUNA                  │*
*│    -> P_SALV_TABLE                "OBJECTO DO CL_SALV_TABLE        │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_set_column_dropdown USING p_column_name TYPE lvc_fname
                                p_salv_table  TYPE REF TO cl_salv_table.

  DATA: alv_column_table  TYPE REF TO cl_salv_column_table.

** fill the value in column T_RESDROP of the T_DISP table
*  DATA: ls_dropdown LIKE salv_s_int4_column.
*  ls_dropdown-columnname = 'REASON'.    " Your column on which dropdown is requried
*  ls_dropdown-value      = l_handle.
*  APPEND ls_dropdown TO lwa_disp-t_resdrop.
*


  alv_columns = p_salv_table->get_columns( ).

  TRY.
      alv_column_table ?= alv_columns->get_column( p_column_name ).
      alv_column_table->set_cell_type( if_salv_c_cell_type=>dropdown ).
      alv_column_table->set_dropdown_entry( 1 ).
    CATCH cx_salv_not_found cx_sy_move_cast_error.
      " Coluna não encontrada ou erro de casting
  ENDTRY.
*
*  DATA events    TYPE REF TO cl_salv_events_table.
*
*  events = alv->get_event( ).
*  CREATE OBJECT event_handler.
*  SET HANDLER event_handler->on_link_click FOR events.

ENDFORM.

*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃F_SET_COLUMN_CELL_COLOR Define a cor da celula de uma coluna na ALV ┃*
*┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩*
*│ -> ENTRADAS                                                        │*
*│    -> P_SALV_TABLE               "OBJETO DO CL_SALV_TABLE          │*
*│    -> P_OUTTAB                   "TABELA INTERNA COM CAMPOS        │*
*│    -> P_COLUMN_NAME              "NOME DA COLUNA PARA APLICAR COR  │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_set_column_cell_color USING p_column_name  TYPE lvc_fname
                                   p_outtab       TYPE STANDARD TABLE
                                   p_salv_table   TYPE REF TO cl_salv_table.

  FIELD-SYMBOLS: <fs_outtab>     TYPE any,
                 <fs_color>      TYPE lvc_t_scol,
                 <fs_color_code> TYPE i.

  DATA: wa_color TYPE lvc_s_scol.

  LOOP AT p_outtab ASSIGNING <fs_outtab>.
    ASSIGN COMPONENT 'T_COLOR' OF STRUCTURE <fs_outtab> TO <fs_color>.
    ASSIGN COMPONENT 'CELL_COLOR_CODE' OF STRUCTURE <fs_outtab> TO <fs_color_code>.
    IF sy-subrc = 0.
*      CLEAR <fs_color>[].
      wa_color-fname        = p_column_name.
      wa_color-color-col    = <fs_color_code>.
      wa_color-color-int    = 0.
      wa_color-color-inv    = 0.
      APPEND wa_color TO <fs_color>.
    ENDIF.
  ENDLOOP.

  DATA(lo_columns) = p_salv_table->get_columns( ).
  lo_columns->set_color_column( 'T_COLOR' ).

  PERFORM f_set_column_visible      USING 'CELL_COLOR_CODE' abap_false p_salv_table.

ENDFORM.                    " F_SET_ROW_COLOR

*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃F_FREE_ALV_TREE - Libera o ALV Tree e o container customizado       ┃*
*┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩*
*│ -> ENTRADAS                                                        │*
*│    -> P_ALV_TREE                 "OBJETO DO CL_GUI_ALV_TREE        │*
*│    -> P_CC_ALV_TREE              "OBJETO DO CL_GUI_CUSTOM_CONTAINER│*
*└────────────────────────────────────────────────────────────────────┘*
FORM free_alv_tree
  USING    p_alv_tree     TYPE REF TO cl_salv_tree
           p_cc_alv_tree  TYPE REF TO cl_gui_custom_container.

  IF p_alv_tree IS BOUND.
    CALL METHOD p_alv_tree->close_screen( ).
    FREE p_alv_tree.
  ENDIF.

  IF p_cc_alv_tree IS BOUND.
    CALL METHOD p_cc_alv_tree->free.
    FREE p_cc_alv_tree.
  ENDIF.

ENDFORM.

*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃F_GET_SELECTED_ROW - Retorna linha selecionada no ALV               ┃*
*┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩*
*│ -> ENTRADAS                                                        │*
*│    -> P_ALV_TREE                 "OBJETO DO CL_GUI_ALV_TREE        │*
*│ <- SAIDAS                                                          │*
*│    <- P_INDEX                    "LINHA SELECIONADA                │*
*└────────────────────────────────────────────────────────────────────┘*
FORM get_selected_row
  USING    p_alv          TYPE REF TO cl_salv_table
  CHANGING p_index TYPE int4.


  DATA: lr_selections TYPE REF TO cl_salv_selections.
  DATA: lt_rows   TYPE salv_t_row.

  IF p_alv IS BOUND.

    lr_selections = p_alv->get_selections( ).
    lt_rows = lr_selections->get_selected_rows( ).
    READ TABLE lt_rows INTO p_index INDEX 1.

  ENDIF.

ENDFORM.
