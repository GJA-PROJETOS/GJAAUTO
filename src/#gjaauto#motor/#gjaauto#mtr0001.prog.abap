*╔════════════════════════════════════════════════════════════════════╗*
*║Descrição: Relatório Ordens de Venda x Logística                    ║*
*╠════════════════════════════════════════════════════════════════════╣*
*║Autor: Mike Morais da Silva                                         ║*
*║Solicitante:                                                        ║*
*║Data: 06/11/2025                                                    ║*
*╚════════════════════════════════════════════════════════════════════╝*
*│                     HISTÓRICO DE MUDANÇAS                          │*
*╞════╤══════════╤═════════╤══════════╤══════════╤════════════════════╡*
*│NÚM.│   DATA   │  AUTOR  │ REQUEST  │ CHAMADO  │ DESCRIÇÂO          │*
*╞════╪══════════╪═════════╪══════════╪══════════╪════════════════════╡*
*│0001│06/11/2025│MIKESILVA│----------│----------│Criação do relátorio│*
*╘════╧══════════╧═════════╧══════════╧══════════╧════════════════════╛*
REPORT /gjaauto/mtr0001.
*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*
*┃DEFINIÇÕES GLOBAIS DE DADOS - INÍCIO                                ┃*
*┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*
*┌────────────────────────────────────────────────────────────────────┐*
*│ TABELAS                                                            │*
*└────────────────────────────────────────────────────────────────────┘*
TABLES:
  /gjaauto/mttb001,  " Motor: Cabeçalho de automação
  /gjaauto/mttb002,  " Logs das automações
  /gjaauto/mttb003.  " Etapas de automação
*┌────────────────────────────────────────────────────────────────────┐*
*│ REFERÊNCIAS                                                        │*
*└────────────────────────────────────────────────────────────────────┘*
DATA:
  go_alv_tree               TYPE REF TO cl_salv_tree,
  go_alv_tree_functions     TYPE REF TO cl_salv_functions_tree,
  go_alv_tree_settings      TYPE REF TO cl_salv_tree_settings,
  go_alv_tree_events        TYPE REF TO cl_salv_events_tree,
  go_alv_tree_columns       TYPE REF TO cl_salv_columns_tree,
  go_alv_tree_column        TYPE REF TO cl_salv_column_tree,
  go_alv_tree_columns_table TYPE REF TO cl_salv_columns_tree.

*┌────────────────────────────────────────────────────────────────────┐*
*│ TYPES                                                              │*
*└────────────────────────────────────────────────────────────────────┘*
TYPES:
  BEGIN OF ty_s_alv_tree_output,

    auto           TYPE /gjaauto/cke_automacao,     " Automação
    opera	         TYPE /gjaauto/cke_operaracao,    " Operação
    chave	         TYPE /gjaauto/mte_chave,         " Chave da Automação
    credat         TYPE /gjaauto/mte_data_criacao,  " Data Criação
    cretim         TYPE /gjaauto/mte_hora_criacao,  " Hora Criação
    crenam         TYPE /gjaauto/mte_user_criacao,  " Nome Usuário
    status         TYPE /gjaauto/mte_status,        " Status da Automação
    status_desc    TYPE string,                     " Descrição do Status da Automação
    etapa	         TYPE /gjaauto/cke_etapa,         " Etapa do Fluxo
    item           TYPE /gjaauto/cke_sequencia,     " Sequência
    type           TYPE char50,                     " Ctg.mens.: S sucesso, E erro, W aviso, I inform., A cancel.
    message	       TYPE bapi_msg,                   " Texto da Mensagem
    id             TYPE symsgid,                    " Classe da Mensagem
    number_msg     TYPE symsgno,                    " Num. Mensagem
    no             TYPE balognr,                    " Num. Log
    msg_no         TYPE balmnr,                     " Num. Sequencial Interno da Mensagem
    message_v1     TYPE symsgv,                     " Variável Mensagens
    message_v2     TYPE symsgv,                     " Variável Mensagens
    message_v3     TYPE symsgv,                     " Variável Mensagens
    message_v4     TYPE symsgv,                     " Variável Mensagens
    parameter_name TYPE bapi_param,                 " Nome do Parâmetro
    row_param	     TYPE bapi_line,                  " Linha do Parâmetro
    field	         TYPE bapi_fld,                   " Campo do Parâmetro
    system_log     TYPE bapilogsys,                 " Sistema de Origem da Mensagem

  END OF ty_s_alv_tree_output,

  BEGIN OF ty_icon,
    code TYPE salv_de_tree_image,
    desc TYPE char50,
  END OF ty_icon.

*┌────────────────────────────────────────────────────────────────────┐*
*│ TABELAS INTERNAS                                                   │*
*└────────────────────────────────────────────────────────────────────┘*
DATA:
  gt_mttb001    TYPE TABLE OF /gjaauto/mttb001,
  gt_mttb002    TYPE TABLE OF /gjaauto/mttb002,
  gt_mttb003    TYPE TABLE OF /gjaauto/mttb003,
  gt_cktb003    TYPE TABLE OF /gjaauto/cktb003,
  gt_alv_output TYPE TABLE OF ty_s_alv_tree_output.

*┌────────────────────────────────────────────────────────────────────┐*
*│ VARIABLES                                                          │*
*└────────────────────────────────────────────────────────────────────┘*
DATA:
  gv_icon_aguardando_auto TYPE ty_icon,
  gv_icon_executando      TYPE ty_icon,
  gv_icon_completo        TYPE ty_icon,
  gv_icon_erro            TYPE ty_icon,
  gv_icon_atencao         TYPE ty_icon,
  gv_icon_pausado         TYPE ty_icon,
  gv_icon_estornado       TYPE ty_icon,
  gv_icon_cancelado       TYPE ty_icon,
  gv_icon_fila            TYPE ty_icon,
  gv_icon_manual          TYPE ty_icon,
  gv_icon_info            TYPE ty_icon,
  gv_icon_exec            TYPE ty_icon,
  gv_icon_success         TYPE ty_icon,
  gv_icon_cancel          TYPE ty_icon,
  gv_icon_error           TYPE ty_icon,
  gv_icon_wait            TYPE ty_icon,
  gv_icon_warning         TYPE ty_icon.


*┌────────────────────────────────────────────────────────────────────┐*
*│ OUTROS DADOS GLOBAIS                                               │*
*└────────────────────────────────────────────────────────────────────┘*
*╔════════════════════════════════════════════════════════════════════╗*
*║DEFINIÇÕES GLOBAIS DE DADOS - FIM                                   ║*
*╚════════════════════════════════════════════════════════════════════╝*

*██████████████████████████████████████████████████████████████████████*

*╔════════════════════════════════════════════════════════════════════╗*
*║TELA DE SELEÇÃO - INÍCIO                                            ║*
*╚════════════════════════════════════════════════════════════════════╝*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_chave   FOR /gjaauto/mttb001-chave DEFAULT '251103IN100000000016',   " Chave da Automação
                  s_credat  FOR /gjaauto/mttb001-credat,  " Data Criação
                  s_crenam  FOR /gjaauto/mttb001-crenam,  " Nome Usuário
                  s_status  FOR /gjaauto/mttb001-status.  " Status da Automação
SELECTION-SCREEN END OF BLOCK b1.
*╔════════════════════════════════════════════════════════════════════╗*
*║TELA DE SELEÇÃO - FIM                                               ║*
*╚════════════════════════════════════════════════════════════════════╝*

*██████████████████████████████████████████████████████████████████████*

*╔════════════════════════════════════════════════════════════════════╗*
*║EVENTOS - INÍCIO                                                    ║*
*╚════════════════════════════════════════════════════════════════════╝*

*┌────────────────────────────────────────────────────────────────────┐*
*│ INITIALIZATON - Eventos                                            │*
*└────────────────────────────────────────────────────────────────────┘*
*┌────────────────────────────────────────────────────────────────────┐*
*│ START-OF-SELECTION - Eventos                                       │*
*└────────────────────────────────────────────────────────────────────┘*
START-OF-SELECTION.
  PERFORM f_fetch_data.
  PERFORM f_display_alv_tree.
*┌────────────────────────────────────────────────────────────────────┐*
*│ END-OF-SELECTION - Eventos                                         │*
*└────────────────────────────────────────────────────────────────────┘*
*╔════════════════════════════════════════════════════════════════════╗*
*║EVENTOS - FIM                                                       ║*
*╚════════════════════════════════════════════════════════════════════╝*

*██████████████████████████████████████████████████████████████████████*

*╔════════════════════════════════════════════════════════════════════╗*
*║SUBROTINAS - INÍCIO                                                 ║*
*╚════════════════════════════════════════════════════════════════════╝*
*┌────────────────────────────────────────────────────────────────────┐*
*│ F_FETCH_DATA - Busca dados
*└────────────────────────────────────────────────────────────────────┘*
FORM f_fetch_data.

  SELECT *
    FROM /gjaauto/mttb001
    INTO TABLE gt_mttb001
  WHERE chave  IN s_chave
    AND credat IN s_credat
    AND crenam IN s_crenam
    AND status IN s_status
  ORDER BY PRIMARY KEY.

  SELECT *
    FROM /gjaauto/mttb003
    INTO TABLE gt_mttb003
    FOR ALL ENTRIES IN gt_mttb001
  WHERE chave = gt_mttb001-chave
  ORDER BY PRIMARY KEY.

  SELECT *
    FROM /gjaauto/mttb002
    INTO TABLE gt_mttb002
    FOR ALL ENTRIES IN gt_mttb003
  WHERE chave = gt_mttb003-chave
  ORDER BY PRIMARY KEY.

  SELECT *
  FROM /gjaauto/cktb003
    INTO TABLE gt_cktb003.

ENDFORM.
*┌────────────────────────────────────────────────────────────────────────┐*
*│ F_BUILD_ICON - Modifica texto do icon                                 │*
*└────────────────────────────────────────────────────────────────────────┘*
FORM f_build_icon.

  PERFORM create_icon USING 'Aguardando Automação'                   'ICON_LIGHT_OUT'           '@EB@' CHANGING gv_icon_aguardando_auto.
  PERFORM create_icon USING 'Executando'                             'ICON_GREEN_LIGHT'         '@08@' CHANGING gv_icon_executando.
  PERFORM create_icon USING 'Completo'                               'ICON_RELEASE'             '@5Y@' CHANGING gv_icon_completo.
  PERFORM create_icon USING 'Erro (Processamento ou Validação)'      'ICON_RED_LIGHT'           '@0A@' CHANGING gv_icon_erro.
  PERFORM create_icon USING 'Atenção: Validação apresenta mensagens' 'ICON_YELLOW_LIGHT'        '@09@' CHANGING gv_icon_atencao.
  PERFORM create_icon USING 'Pausado'                                'ICON_TIME_INA'            '@9R@' CHANGING gv_icon_pausado.
  PERFORM create_icon USING 'Estornado'                              'ICON_DEFECT'              '@F1@' CHANGING gv_icon_estornado.
  PERFORM create_icon USING 'Cancelado'                              'ICON_CANCEL'              '@NR@' CHANGING gv_icon_cancelado.
  PERFORM create_icon USING 'Fila'                                   'ICON_PPE_VNODE'           '@N4@' CHANGING gv_icon_fila.
  PERFORM create_icon USING 'Manual'                                 'ICON_GIS_PAN'             '@NK@' CHANGING gv_icon_manual.
  PERFORM create_icon USING 'Informação'                             'ICON_INFORMATION'         '@0S@' CHANGING gv_icon_info.


  PERFORM create_icon USING 'Executando'                             'ICON_ACTIVITY'            '@9Y@' CHANGING gv_icon_exec.
  PERFORM create_icon USING 'Sucesso'                                'ICON_LED_GREEN'           '@5B@' CHANGING gv_icon_success.
  PERFORM create_icon USING 'Cancelado'                              'ICON_CANCEL'              '@5C@' CHANGING gv_icon_cancel.
  PERFORM create_icon USING 'Erro'                                   'ICON_LED_RED'             '@0W@' CHANGING gv_icon_error.
  PERFORM create_icon USING 'Aguardando'                             'ICON_LED_INACTIVE'        '@BZ@' CHANGING gv_icon_wait.
  PERFORM create_icon USING 'Alerta'                                 'ICON_LED_YELLOW'          '@5D@' CHANGING gv_icon_warning.

ENDFORM.
FORM create_icon USING lv_desc lv_icon lv_code CHANGING lv_new_icon TYPE ty_icon.
  lv_new_icon-code = lv_code.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = lv_icon "Nome do icone -> ICONS
      info   = lv_desc "descrição do icone
    IMPORTING
      result = lv_new_icon-code.

ENDFORM.
*┌────────────────────────────────────────────────────────────────────────┐*
*│ F_DISPLAY_ALV - Inicializa o ALV TREE                                  │*
*└────────────────────────────────────────────────────────────────────────┘*
FORM f_display_alv_tree.
  DATA message TYPE REF TO cx_salv_msg.

  TRY.
      cl_salv_tree=>factory(
        IMPORTING
          r_salv_tree = go_alv_tree
        CHANGING
          t_table     = gt_alv_output ).

    CATCH cx_salv_msg INTO message.
      " Tratamento de erro
  ENDTRY.

  PERFORM f_build_icon.
  PERFORM f_build_alv_tree_output.
  PERFORM f_layout_settings.
  go_alv_tree->display( ).

ENDFORM.
*┌────────────────────────────────────────────────────────────────────┐*
*│ F_LAYOUT_SETTINGS - Configurações de layout do ALV                 │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_layout_settings.
  " Configurações gerais
  go_alv_tree_settings = go_alv_tree->get_tree_settings( ).
  go_alv_tree_settings->set_hierarchy_size_in_pixel( abap_true ).
  go_alv_tree_settings->set_hierarchy_size( 100 ).
  go_alv_tree_columns = go_alv_tree->get_columns( ).
  go_alv_tree_columns->set_optimize( abap_false ).

  PERFORM set_column_width_and_title USING 'CRENAM' 'Usuário' 'Usuário' 'Usuário' 15.
  PERFORM set_column_width_and_title USING 'CREDAT' 'Data' 'Data' 'Data de criação' 10.
  PERFORM set_column_width_and_title USING 'CRETIM' 'Hora' 'Hora' 'Hora' 10.
  PERFORM set_column_width_and_title USING 'STATUS' 'Status' 'Status' 'Status' 10.
  PERFORM set_column_width_and_title USING 'TYPE' 'Etapa' 'Etapa' 'Etapa' 50.

*  PERFORM set_column_icon USING 'TYPE'.

  PERFORM f_hide_client_column.

  " Configurações de funções
  go_alv_tree_functions = go_alv_tree->get_functions( ).
  go_alv_tree_functions->set_help( abap_false ).

ENDFORM.
*┌────────────────────────────────────────────────────────────────────────┐*
*│ F_BUILD_ALV_TREE_OUTPUT - Constrói a hierarquia de saída do ALV TREE   │*
*└────────────────────────────────────────────────────────────────────────┘*
FORM f_build_alv_tree_output.
  DATA:
    header_nodekey TYPE lvc_nkey,
    body_nodekey   TYPE lvc_nkey.

  LOOP AT gt_mttb001 INTO DATA(lw_tb001).
    PERFORM add_add_node_header USING lw_tb001 CHANGING header_nodekey.

    LOOP AT gt_mttb003 INTO DATA(lw_tb003) WHERE chave = lw_tb001-chave.
      PERFORM add_add_node_body USING lw_tb003 header_nodekey CHANGING body_nodekey.

      LOOP AT gt_mttb002 INTO DATA(lw_tb002) WHERE chave = lw_tb003-chave.
        PERFORM add_add_node_log USING lw_tb002 body_nodekey.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.
ENDFORM.
*┌────────────────────────────────────────────────────────────────────┐*
*│ F_HIDE_CLIENT_COLUMN - Oculta a coluna de mandante (MANDT)         │*
*└────────────────────────────────────────────────────────────────────┘*
FORM f_hide_client_column.
  DATA not_found TYPE REF TO cx_salv_not_found.

  TRY.
      " Oculta colunas técnicas
      go_alv_tree_columns->get_column( 'AUTO' )->set_visible( abap_false ).
      go_alv_tree_columns->get_column( 'OPERA' )->set_visible( abap_false ).
      go_alv_tree_columns->get_column( 'CHAVE' )->set_visible( abap_false ).
      go_alv_tree_columns->get_column( 'ETAPA' )->set_visible( abap_false ).
      go_alv_tree_columns->get_column( 'NUMBER_MSG' )->set_visible( abap_false ).
      go_alv_tree_columns->get_column( 'STATUS' )->set_visible( abap_false ).
    CATCH cx_salv_not_found INTO not_found.
      " Tratamento de erro
  ENDTRY.
ENDFORM.
*┌────────────────────────────────────────────────────────────────────┐*
*│ SET_COLUMN_WIDTH_AND_TITLE - Define a largura e titulo da coluna   │*
*└────────────────────────────────────────────────────────────────────┘*
FORM set_column_width_and_title USING p_column_name  TYPE lvc_fname
                                      p_column_title_s
                                      p_column_title_m
                                      p_column_title_l
                                      p_size         TYPE lvc_outlen.
  TRY.
      DATA(alv_column) = go_alv_tree_columns->get_column( p_column_name ).
      IF alv_column IS NOT INITIAL.
        alv_column->set_short_text( p_column_title_s ).
        alv_column->set_medium_text( p_column_title_m ).
        alv_column->set_long_text( p_column_title_l ).
        alv_column->set_output_length( p_size ).
      ENDIF.
    CATCH cx_salv_not_found.
  ENDTRY.
ENDFORM.
*┌────────────────────────────────────────────────────────────────────┐*
*│ SET_COLUMN_WIDTH_AND_TITLE - Define a largura e titulo da coluna   │*
*└────────────────────────────────────────────────────────────────────┘*
FORM set_column_icon USING p_column_name TYPE lvc_fname.
  DATA: lo_icon     TYPE REF TO cl_salv_column_table.

  CALL METHOD go_alv_tree->get_columns " GET all cols OF TABLE
    RECEIVING
      value = go_alv_tree_columns_table.

*  lo_icon      TYPE REF TO cl_salv_column_table,
  TRY.
      DATA(lo_col_icon) = go_alv_tree_columns_table->get_column( p_column_name ).

      IF lo_col_icon IS NOT INITIAL.
        TRY.

            lo_icon ?= lo_col_icon.

            CALL METHOD lo_icon->set_icon
              EXPORTING
                value = if_salv_c_bool_sap=>true.

            CALL METHOD lo_icon->set_long_text
              EXPORTING
                value = 'TYPE'.


          CATCH cx_salv_not_found .

        ENDTRY.
      ENDIF.
    CATCH cx_salv_not_found.
  ENDTRY.
ENDFORM.
*┌────────────────────────────────────────────────────────────────────┐*
*│ ADD_ADD_NODE_HEADER - Adiciona node cabeçalho à árvore             │*
*└────────────────────────────────────────────────────────────────────┘*
FORM add_add_node_header USING lw_tb001 TYPE /gjaauto/mttb001 CHANGING header_nodekey.
  DATA:
    lo_node     TYPE REF TO cl_salv_node,
    status_icon TYPE salv_de_tree_image VALUE IS INITIAL.

  PERFORM return_status_icon USING lw_tb001-status CHANGING status_icon.

  DATA(lw_outtab) = VALUE ty_s_alv_tree_output(
    auto   = lw_tb001-auto
    opera  = lw_tb001-opera
    chave  = lw_tb001-chave
    credat = lw_tb001-credat
    cretim = lw_tb001-cretim
    crenam = lw_tb001-crenam
    status = lw_tb001-status
    status_desc  = SWITCH #( lw_tb001-status
                       WHEN 0 THEN 'Aguardando AUTO'
                       WHEN 1 THEN 'Executando'
                       WHEN 2 THEN 'Completo'
                       WHEN 3 THEN 'Erro (Processamento ou Validação)'
                       WHEN 4 THEN 'Atenção: Validação apresenta mensagens'
                       WHEN 5 THEN 'Pausado'
                       WHEN 6 THEN 'Estornado'
                       WHEN 7 THEN 'Cancelado'
                       WHEN 8 THEN 'Fila'
                       WHEN 9 THEN 'Manual'
                       ELSE lw_tb001-status ) ).

  " Adiciona nó à árvore
  TRY.
      lo_node = go_alv_tree->get_nodes( )->add_node(
        related_node = ''
        data_row     = lw_outtab
        expander     = abap_true
        relationship = cl_gui_column_tree=>relat_last_child ).

      lo_node->set_expander( abap_false ).
      lo_node->set_collapsed_icon( status_icon ).
      lo_node->set_expanded_icon( status_icon ).
      lo_node->set_text( |{ lw_tb001-chave ALPHA = OUT }ㅤㅤ| ).

      header_nodekey = lo_node->get_key( ).

    CATCH cx_salv_msg.
      " Tratamento de erro: nó não pôde ser adicionado
  ENDTRY.
ENDFORM.
*┌────────────────────────────────────────────────────────────────────┐*
*│ ADD_ADD_NODE_BODY - Adiciona node de etapas à árvore               │*
*└────────────────────────────────────────────────────────────────────┘*
FORM add_add_node_body USING  lw_tb003        TYPE /gjaauto/mttb003
                              header_nodekey  TYPE lvc_nkey
                              CHANGING body_nodekey.
  DATA:
    lo_node     TYPE REF TO cl_salv_node.

  DATA(lv_icon) = SWITCH ty_icon( lw_tb003-status
        WHEN 0 THEN gv_icon_wait
        WHEN 1 THEN gv_icon_exec
        WHEN 2 THEN gv_icon_success
        WHEN 3 THEN gv_icon_error
        WHEN 4 THEN gv_icon_warning
        WHEN 5 THEN gv_icon_pausado
        WHEN 6 THEN gv_icon_estornado
        WHEN 7 THEN gv_icon_cancelado
        WHEN 8 THEN gv_icon_fila
        WHEN 9 THEN gv_icon_manual ).

  READ TABLE gt_cktb003 INTO DATA(lw_cktb003) WITH KEY auto  = lw_tb003-auto
        opera = lw_tb003-opera
        etapa = lw_tb003-etapa.

  DATA(lw_outtab) = VALUE ty_s_alv_tree_output(
   auto         = lw_tb003-auto
   opera        = lw_tb003-opera
   chave        = lw_tb003-chave
   etapa        = lw_tb003-etapa
   credat       = lw_tb003-credat
   cretim       = lw_tb003-cretim
   crenam       = lw_tb003-crenam
   status       = lw_tb003-status
   status_desc  = lw_cktb003-descr ).

  " Adiciona nó à árvore
  TRY.
      lo_node = go_alv_tree->get_nodes( )->add_node(
        related_node = COND #( WHEN header_nodekey IS INITIAL
                               THEN ''
                               ELSE header_nodekey )
        data_row     = lw_outtab
        expander     = abap_true
        relationship = cl_gui_column_tree=>relat_last_child ).

      lo_node->set_expander( abap_false ).
      lo_node->set_collapsed_icon( lv_icon-code ).
      lo_node->set_expanded_icon( lv_icon-code ).

      DATA(desc) =  SWITCH #( lw_tb003-status
        WHEN 0 THEN 'Aguardando AUTO'
        WHEN 1 THEN 'Executando'
        WHEN 2 THEN 'Completo'
        WHEN 3 THEN 'Erro (Processamento ou Validação)'
        WHEN 4 THEN 'Atenção: Validação apresenta mensagens'
        WHEN 5 THEN 'Pausado'
        WHEN 6 THEN 'Estornado'
        WHEN 7 THEN 'Cancelado'
        WHEN 8 THEN 'Fila'
        WHEN 9 THEN 'Manual'
        ELSE lw_tb003-status ).

      lo_node->set_text( |{ lw_tb003-etapa ALPHA = OUT } - { desc } - { lw_cktb003-descr }| ).

      body_nodekey = lo_node->get_key( ).

    CATCH cx_salv_msg.
      " Tratamento de erro: nó não pôde ser adicionado
  ENDTRY.
ENDFORM.
*┌────────────────────────────────────────────────────────────────────┐*
*│ ADD_ADD_NODE_LOG - Adiciona node de logs à árvore                  │*
*└────────────────────────────────────────────────────────────────────┘*
FORM add_add_node_log USING lw_tb002      TYPE /gjaauto/mttb002
                            body_nodekey  TYPE lvc_nkey.
  DATA:
    lo_node TYPE REF TO cl_salv_node.

  DATA(lv_icon) =  SWITCH ty_icon( lw_tb002-type
   WHEN 'S' THEN gv_icon_success
   WHEN 'E' THEN gv_icon_error
   WHEN 'W' THEN gv_icon_warning
   WHEN 'I' THEN gv_icon_info
   WHEN 'A' THEN gv_icon_cancel
   ).


  DATA(lw_outtab) = VALUE ty_s_alv_tree_output(
   auto            = lw_tb002-auto
   opera           = lw_tb002-opera
   chave           = lw_tb002-chave
   etapa           = lw_tb002-etapa
   item            = lw_tb002-item
   id              = lw_tb002-id
   number_msg      = lw_tb002-number_msg
   message         = lw_tb002-message
   no              = lw_tb002-log_no
   msg_no          = lw_tb002-log_msg_no
   message_v1      = lw_tb002-message_v1
   message_v2      = lw_tb002-message_v2
   message_v3      = lw_tb002-message_v3
   message_v4      = lw_tb002-message_v4
   parameter_name  = lw_tb002-parameter_name
   row_param       = lw_tb002-row_param
   field           = lw_tb002-field
   system_log      = lw_tb002-system_log
   type            = lv_icon-desc
                        ).

  " Adiciona nó à árvore
  TRY.
      lo_node = go_alv_tree->get_nodes( )->add_node(
        related_node = COND #( WHEN body_nodekey IS INITIAL
                               THEN ''
                               ELSE body_nodekey )
        data_row     = lw_outtab
        expander     = abap_true
        relationship = cl_gui_column_tree=>relat_last_child ).

      lo_node->set_expander( abap_false ).
      lo_node->set_collapsed_icon( lv_icon-code ).
      lo_node->set_expanded_icon( lv_icon-code ).
      lo_node->set_text( |{ lw_tb002-etapa ALPHA = OUT }ㅤ- { lw_tb002-message }ㅤ| ).

    CATCH cx_salv_msg.
      " Tratamento de erro: nó não pôde ser adicionado
  ENDTRY.
ENDFORM.
*┌────────────────────────────────────────────────────────────────────┐*
*│ RETURN_STATUS_ICON - Retorna icone conforme status do processo     │*
*└────────────────────────────────────────────────────────────────────┘*
FORM return_status_icon USING status CHANGING status_icon TYPE salv_de_tree_image.
  status_icon = CONV salv_de_tree_image(
                SWITCH #( status
                          WHEN 0 THEN gv_icon_aguardando_auto-code
                          WHEN 1 THEN gv_icon_executando-code
                          WHEN 2 THEN gv_icon_completo-code
                          WHEN 3 THEN gv_icon_erro-code
                          WHEN 4 THEN gv_icon_atencao-code
                          WHEN 5 THEN gv_icon_pausado-code
                          WHEN 6 THEN gv_icon_estornado-code
                          WHEN 7 THEN gv_icon_cancelado-code
                          WHEN 8 THEN gv_icon_fila-code
                          WHEN 9 THEN gv_icon_manual-code )
                          ).
ENDFORM.
