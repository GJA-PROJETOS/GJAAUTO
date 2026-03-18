@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Etapas'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }

define view entity /GJAAUTO/CDS_I_Etapas
  as select from /gjaauto/cktb003 as etapa

  association to parent /GJAAUTO/CDS_I_Operacoes  as _Operacao
    on  $projection.auto  = _Operacao.auto
    and $projection.opera = _Operacao.opera

  association to        /GJAAUTO/CDS_I_Automacoes as _Automacao
    on $projection.auto = _Automacao.auto

{
  key etapa.auto,
  key etapa.opera,
  key etapa.etapa,

      etapa.descr,
      etapa.tpeta,
      etapa.rotin,
      etapa.mapea,

      _Operacao,
      _Automacao
}
