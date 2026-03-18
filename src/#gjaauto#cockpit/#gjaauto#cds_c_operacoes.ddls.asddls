@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Projection View Operações'

@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true

@UI.headerInfo: { typeName: 'Operação',
                  typeNamePlural: 'Operações',
                  title: { type: #STANDARD, label: 'Operação', value: 'Opera' } }

define view entity /GJAAUTO/CDS_C_OPERACOES
  as projection on /GJAAUTO/CDS_I_Operacoes

{
      //      @Search.defaultSearchElement: true
      //      @UI.facet: [ { id: 'Auto',
      //                     purpose: #STANDARD,
      //                     type: #IDENTIFICATION_REFERENCE,
      //                     label: 'Automação',
      //                     position: 10 } ]
      //      //@UI.identification: [ { position: 10, label: 'Automação' } ]
      //      //      @UI.lineItem: [ { position: 10, label: 'Automação', importance: #HIGH } ]
      //      @UI.hidden: true
  key auto   as Auto,

      @Search.defaultSearchElement: true
      @UI.facet: [ { id: 'Opera',
                     purpose: #STANDARD,
                     type: #IDENTIFICATION_REFERENCE,
                     label: 'Operação',
                     position: 10 } ]
      @UI.identification: [ { position: 10, label: 'Operação' } ]
      @UI.lineItem: [ { position: 10, label: 'Operação', importance: #HIGH } ]
  key opera  as Opera,

      @UI.identification: [ { position: 20, label: 'Descrição' } ]
      @UI.lineItem: [ { position: 20, label: 'Descrição da Operação', importance: #HIGH } ]
      descr  as DescricaoOpera,

      @UI.identification: [ { position: 30, label: 'Objeto de númeração' } ]
      @UI.lineItem: [ { position: 30, label: 'Objeto de númeração', importance: #HIGH } ]
      snro   as Snro,
      
      @UI.identification: [ { position: 40, label: 'Nº do intervalo de numeração' } ]
      @UI.lineItem: [ { position: 50, label: 'Nº do intervalo de numeração', importance: #HIGH } ]
      snronr as SnroNr,

      /* Associations */
      @UI.hidden: true
      _Automacao : redirected to parent /GJAAUTO/CDS_C_AUTOMACOES,
      @UI.facet: [
      {
      id: 'Etapas',
      purpose: #STANDARD,
      type: #LINEITEM_REFERENCE,
      label: 'Etapas',
      targetElement: '_Etapas',
      position: 60
      }
      ]
      _Etapas    : redirected to composition child /GJAAUTO/CDS_C_ETAPAS
}
