@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Projection View Automações'

@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true

@UI.headerInfo: { typeName: 'Automação',
                  typeNamePlural: 'Automações',
                  title: { type: #STANDARD, value: 'Auto' } }

define root view entity /GJAAUTO/CDS_C_AUTOMACOES
  provider contract transactional_query
  as projection on /GJAAUTO/CDS_I_Automacoes

{
      @Search.defaultSearchElement: true
      @UI.facet: [ { id: 'Auto',
                     purpose: #STANDARD,
                     type: #IDENTIFICATION_REFERENCE,
                     label: 'Automação',
                     position: 10 } ]
      @UI.identification: [ { position: 10, label: 'Automação' } ]
      @UI.lineItem: [ { position: 10, label: 'Automação', importance: #HIGH } ]
  key auto  as Auto,

      @UI.identification: [ { position: 20, label: 'Descrição' } ]
      @UI.lineItem: [ { position: 20, label: 'Descrição', importance: #HIGH } ]
      descr as DescricaoAuto,

      @UI.hidden: true
      icon_fiori,

      /* Associations */
      @UI.facet: [
      {
      id: 'Operacoes',
      purpose: #STANDARD,
      type: #LINEITEM_REFERENCE,
      label: 'Operações',
      targetElement: '_Operacoes',
      position: 30
      }
      ]
      _Operacoes : redirected to composition child /GJAAUTO/CDS_C_OPERACOES
}
