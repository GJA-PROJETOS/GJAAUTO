*╔════════════════════════════════════════════════════════════════════╗*
*║PDEFINIÇÕES GLOBAIS DE DADOS                                        ║*
*╠════════════════════════════════════════════════════════════════════╣*
*║Autor: Igor O. Bittencourt Moreira                                  ║*
*║Data: 13/06/2025                                                    ║*
*╚════════════════════════════════════════════════════════════════════╝*
*│                     HISTÓRICO DE MUDANÇAS                          │*
*╞════╤══════════╤═════════╤══════════╤══════════╤════════════════════╡*
*│NÚM.│   DATA   │  AUTOR  │ REQUEST  │ CHAMADO  │ DESCRIÇÂO          │*
*╞════╪══════════╪═════════╪══════════╪══════════╪════════════════════╡*
*│0001│13/06/2025│IBMOREIRA│DS4K911439│XXXXXXXXXX│ Criação            │*
*╘════╧══════════╧═════════╧══════════╧══════════╧════════════════════╛*
PROGRAM /gjaauto/cockpit.
*┌────────────────────────────────────────────────────────────────────┐*
*│ INCLUDE - Definições                                               │*
*└────────────────────────────────────────────────────────────────────┘*
*┌────────────────────────────────────────────────────────────────────┐*
*│ TYPES                                                              │*
*└────────────────────────────────────────────────────────────────────┘*
TYPES: BEGIN OF ty_alv_tree_outtab,
         auto  TYPE /gjaauto/cke_automacao,
         opera TYPE /gjaauto/cke_operaracao,
         etapa TYPE /gjaauto/cke_etapa,
       END OF ty_alv_tree_outtab.
TYPES: BEGIN OF ty_alv_etapas_outtab,
*    edit_button TYPE icon_d,
         auto  TYPE /gjaauto/cke_automacao,
         opera TYPE /gjaauto/cke_operaracao,
         etapa TYPE /gjaauto/cke_etapa,
         descr TYPE /gjaauto/cke_descricao,
         tpeta TYPE char10,
         rotin TYPE /gjaauto/cke_rotina,
       END OF ty_alv_etapas_outtab.
TYPES: BEGIN OF ty_alv_tree_mapea_outtab,
         paramnat TYPE /gjaauto/cke_natu_parametro,
         paramtyp TYPE /gjaauto/cke_tipo_parametro,
         tabname  TYPE tabname_v,
         param    TYPE /gjaauto/cke_parametro,
         paramopt TYPE seooptionl,
       END OF ty_alv_tree_mapea_outtab.
TYPES: BEGIN OF ty_alv_data_operas_outtab,
*    edit_button     TYPE icon_d,
         datanatu        TYPE c LENGTH 10,
         etapa_born      TYPE c LENGTH 3,
         datatyp         TYPE c LENGTH 7,
         name            TYPE name1,
         tabname         TYPE tabname16,
         reftypname      TYPE reftypname,
         cell_color_code TYPE lvc_col,
         t_color         TYPE lvc_t_scol,
       END OF ty_alv_data_operas_outtab.

" ┌────────────────────────────────────────────────────────────────────┐-
" │ CONSTANTES                                                         │-
" └────────────────────────────────────────────────────────────────────┘-

CONSTANTS c_auto            TYPE scradnum VALUE '9001'.
CONSTANTS c_opera           TYPE scradnum VALUE '9002'.
CONSTANTS c_etapa           TYPE scradnum VALUE '9003'.
CONSTANTS c_create_icon     TYPE icon_d   VALUE '@0Y@'.
CONSTANTS c_edit_icon       TYPE icon_d   VALUE '@0Z@'.
CONSTANTS c_arrow_up_icon   TYPE icon_d   VALUE '@69@'.
CONSTANTS c_arrow_down_icon TYPE icon_d   VALUE '@68@'.

" ┌────────────────────────────────────────────────────────────────────┐-
" │ VARIÁVEIS                                                          │-
" └────────────────────────────────────────────────────────────────────┘-
DATA true                  TYPE boolean                VALUE abap_true.
DATA false                 TYPE boolean                VALUE abap_false.
DATA gv_updated            TYPE boolean                VALUE abap_false.
DATA gv_created            TYPE boolean                VALUE abap_false.
DATA gv_auto_icon          TYPE icon_d                 VALUE '@9Y@'.
DATA gv_screen_number_9000 TYPE scradnum               VALUE '9999'.
DATA gv_screen_number_9003 TYPE scradnum               VALUE '9999'.

" ┌────────────────────────────────────────────────────────────────────┐-
" │ VARIÁVEIS DE TELA                                                  │-
" └────────────────────────────────────────────────────────────────────┘-
DATA gv_etapa_desc         TYPE /gjaauto/cke_descricao.
DATA gv_rotin_loaded       LIKE rs38l-name.
DATA gv_desc               TYPE as4text.
DATA gv_table_desc         TYPE as4text.
DATA gv_param_desc         TYPE as4text.
DATA gv_table_from_desc    TYPE as4text.
DATA gv_param_from_desc    TYPE as4text.

" ┌────────────────────────────────────────────────────────────────────┐-
" │ REFERÊNCIAS                                                        │-
" └────────────────────────────────────────────────────────────────────┘-
*CLASS cl_alv_tree_auto_event_handler DEFINITION DEFERRED.
*DATA go_custom_events          TYPE REF TO cl_alv_tree_auto_event_handler.

" Containers
DATA: go_docking    TYPE REF TO cl_gui_docking_container,
      go_container  TYPE REF TO cl_gui_custom_container,
      go_splitter   TYPE REF TO cl_gui_splitter_container,
      go_cont_left  TYPE REF TO cl_gui_container,
      go_cont_right TYPE REF TO cl_gui_container.

" ALV Tree
DATA alv_tree                  TYPE REF TO cl_salv_tree.
DATA alv_tree_functions        TYPE REF TO cl_salv_functions_tree.
DATA alv_tree_settings         TYPE REF TO cl_salv_tree_settings.
DATA alv_tree_events           TYPE REF TO cl_salv_events_tree.
DATA alv_tree_columns          TYPE REF TO cl_salv_columns_tree.
DATA alv_tree_column           TYPE REF TO cl_salv_column_tree.

" ALV Tree Mapeamento Etapas
DATA alv_tree_mapea            TYPE REF TO cl_salv_tree.

" ALV Normal
DATA alv                       TYPE REF TO cl_salv_table.
DATA alv_columns               TYPE REF TO cl_salv_columns_table.
DATA alv_column                TYPE REF TO cl_salv_column.

" ALV dados das operacoes
DATA alv_data_operas           TYPE REF TO cl_salv_table.

" ┌────────────────────────────────────────────────────────────────────┐-
" │ TABELAS INTERNAS                                                   │-
" └────────────────────────────────────────────────────────────────────┘-
DATA gt_alv_tree_out           TYPE TABLE OF ty_alv_tree_outtab.
DATA gt_alv_tree_mapea_outtab  TYPE TABLE OF ty_alv_tree_mapea_outtab.
DATA gt_alv_etapas_out         TYPE TABLE OF ty_alv_etapas_outtab.
DATA gt_alv_data_operas_outtab TYPE TABLE OF ty_alv_data_operas_outtab.
DATA gt_cktb001                TYPE TABLE OF /gjaauto/cktb001. " Config: Automação
DATA gt_cktb002                TYPE TABLE OF /gjaauto/cktb002. " Config: Operações
DATA gt_cktb003                TYPE TABLE OF /gjaauto/cktb003. " Config: Etapas
DATA gt_cktb004                TYPE TABLE OF /gjaauto/cktb004. " Config: Mapeamento Rotinas(Função/BAPI)
DATA gt_cktb005                TYPE TABLE OF /gjaauto/cktb005. " Config: Dados Operação

DATA gt_dokumentation          TYPE TABLE OF funct.
DATA gt_exception_list         TYPE TABLE OF rsexc.
DATA gt_export_parameter       TYPE TABLE OF rsexp.
DATA gt_import_parameter       TYPE TABLE OF rsimp.
DATA gt_changing_parameter     TYPE TABLE OF rscha.
DATA gt_tables_parameter       TYPE TABLE OF rstbl.

*┌────────────────────────────────────────────────────────────────────┐*
*│ ESTRUTURAS / WORK AREA                                             │*
*└────────────────────────────────────────────────────────────────────┘*
DATA gw_cktb001                TYPE /gjaauto/cktb001.
DATA gw_cktb002                TYPE /gjaauto/cktb002.
DATA gw_cktb003                TYPE /gjaauto/cktb003.
DATA gw_cktb004                TYPE /gjaauto/cktb004.
DATA gw_cktb005                TYPE /gjaauto/cktb005.

*┌────────────────────────────────────────────────────────────────────┐*
*│ FIELD-SYMBOLS                                                      │*
*└────────────────────────────────────────────────────────────────────┘*

*┌────────────────────────────────────────────────────────────────────┐*
*│ RANGES                                                             │*
*└────────────────────────────────────────────────────────────────────┘*

" ┌────────────────────────────────────────────────────────────────────┐-
" │ OUTROS DADOS GLOBAIS                                               │-
" └────────────────────────────────────────────────────────────────────┘-
DATA cc_alv_tree               TYPE REF TO cl_gui_custom_container.
DATA cc_alv_tree_mapea         TYPE REF TO cl_gui_custom_container.
DATA cc_alv_data_operas        TYPE REF TO cl_gui_custom_container.
DATA cc_alv                    TYPE REF TO cl_gui_custom_container.

" ┌────────────────────────────────────────────────────────────────────┐-
" │ Classes                                                            │-
" └────────────────────────────────────────────────────────────────────┘-
*INCLUDE /gjaauto/ckm0001c01. " Classe responsavel pelo alv tree das automações
*INCLUDE /gjaauto/ckm0001c02. " Classe responsavel pelas etapas da operação
*INCLUDE /gjaauto/ckm0001c03. " Classe responsavel pelos eventos do alv de mapeamento da etapas
" ╔════════════════════════════════════════════════════════════════════╗-
" ║DEFINIÇÕES GLOBAIS DE DADOS - FIM                                   ║-
" ╚════════════════════════════════════════════════════════════════════╝-
