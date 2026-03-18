@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Automações'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
    serviceQuality: #X,
    sizeCategory:  #S,
    dataClass:     #MIXED
}
define root view entity /GJAAUTO/CDS_I_Automacoes
  as select from /gjaauto/cktb001 as automacoes

  composition [0..*] of /GJAAUTO/CDS_I_Operacoes as _Operacoes
{
  key automacoes.auto,
      automacoes.descr,
      automacoes.icon_fiori,

      _Operacoes
}
