@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Cockpit: Dados das Operações'

@Metadata.ignorePropagatedAnnotations: true

define view entity /GJAAUTO/CDS_CK_I_DADOS
  as select from /gjaauto/cktb005

  association to parent /GJAAUTO/CDS_CK_I_Operacoes  as _Operacao
    on  $projection.Auto  = _Operacao.auto
    and $projection.Opera = _Operacao.opera

  association to        /GJAAUTO/CDS_CK_I_Automacoes as _Automacao
    on $projection.Auto = _Automacao.auto

{
  key auto       as Auto,
  key opera      as Opera,
  key name       as Name,

      reftypname as Reftypname,
      reftype    as Reftype,
      etapa_born as EtapaBorn,
      datanatu   as Datanatu,

      _Operacao,
      _Automacao
}
