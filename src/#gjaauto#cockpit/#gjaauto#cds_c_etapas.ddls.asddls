@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Projection View Etapas'

@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true

@UI.headerInfo: { typeName: 'Etapa',
                  typeNamePlural: 'Etapas',
                  title: { type: #STANDARD, value: 'Etapa' } }

define view entity /GJAAUTO/CDS_C_ETAPAS
  as projection on /GJAAUTO/CDS_I_Etapas

{
      //      @Search.defaultSearchElement: true
      //      @UI.facet: [ { id: 'Auto',
      //                     purpose: #STANDARD,
      //                     type: #IDENTIFICATION_REFERENCE,
      //                     label: 'Automação',
      //                     position: 10 } ]
      //      @UI.identification: [ { position: 10, label: 'Automação' } ]
      //      @UI.lineItem: [ { position: 10, label: 'Automação', importance: #HIGH } ]
      @UI.hidden: true
  key auto  as Auto,

      //      @Search.defaultSearchElement: true
      //      @UI.facet: [ { id: 'Operacao',
      //                     purpose: #STANDARD,
      //                     type: #IDENTIFICATION_REFERENCE,
      //                     label: 'Operação',
      //                     position: 20 } ]
      //      @UI.identification: [ { position: 20, label: 'Operação' } ]
      //      @UI.lineItem: [ { position: 20, label: 'Operação', importance: #HIGH } ]
      @UI.hidden: true
  key opera as Opera,

      @Search.defaultSearchElement: true
      @UI.facet: [ { id: 'Etapa',
                     purpose: #STANDARD,
                     type: #IDENTIFICATION_REFERENCE,
                     label: 'Etapa',
                     position: 10 } ]
      @UI.identification: [ { position: 10, label: 'Etapa' } ]
      @UI.lineItem: [ { position: 10, label: 'Etapa', importance: #HIGH } ]
  key etapa as Etapa,

      @UI.identification: [ { position: 20, label: 'Descrição da Etapa' } ]
      @UI.lineItem: [ { position: 20, label: 'Descrição da Etapa', importance: #HIGH } ]
      descr as DescricaoEtapa,

      @UI.identification: [ { position: 30, label: 'Tipo da Etapa' } ]
      @UI.lineItem: [ { position: 30, label: 'Tipo da Etapa', importance: #HIGH } ]
      tpeta as TippEtapa,

      @UI.identification: [ { position: 40, label: 'Rotina' } ]
      @UI.lineItem: [ { position: 40, label: 'Rotina', importance: #HIGH } ]
      rotin as Rotin,

      /* Associations */
      _Operacao  : redirected to parent /GJAAUTO/CDS_C_OPERACOES,
      _Automacao : redirected to /GJAAUTO/CDS_C_AUTOMACOES
}
