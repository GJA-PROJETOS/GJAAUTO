@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Cockpit: Loop Tables'

@Metadata.ignorePropagatedAnnotations: true

define view entity /GJAAUTO/CDS_CK_I_LoopTables
  as select from /gjaauto/cktb006

  association to parent /GJAAUTO/CDS_CK_I_Etapas as _Etapa
    on  $projection.Auto  = _Etapa.auto
    and $projection.Opera = _Etapa.opera
    and $projection.Etapa = _Etapa.etapa

  association to        /GJAAUTO/CDS_CK_I_Automacoes as _Automacao
    on $projection.Auto = _Automacao.auto
{
  key auto    as Auto,
  key opera   as Opera,
  key etapa   as Etapa,
  key reftype as Reftype,
  key param   as Param,

      param_from as ParamFrom,

      _Etapa,
      _Automacao
}
