@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Operações'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }

define view entity /GJAAUTO/CDS_I_Operacoes
  as select from /gjaauto/cktb002 as operacao

  association           to parent /GJAAUTO/CDS_I_Automacoes as _Automacao on $projection.auto = _Automacao.auto
  composition [0..*] of           /GJAAUTO/CDS_I_Etapas     as _Etapas

{
  key operacao.auto,
  key operacao.opera,

      operacao.descr,
      operacao.snro,
      operacao.snronr,

      _Automacao,
      _Etapas
}
