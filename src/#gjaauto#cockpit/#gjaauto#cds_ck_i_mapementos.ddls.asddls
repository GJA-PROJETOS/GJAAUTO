@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Cockpit: Mapeamento Rotinas(Função/BAPI)'

@Metadata.ignorePropagatedAnnotations: true

define view entity /GJAAUTO/CDS_CK_I_MAPEMENTOS
  as select from /gjaauto/cktb004

  association to parent /GJAAUTO/CDS_CK_I_Etapas     as _Etapas
    on  $projection.Auto  = _Etapas.auto
    and $projection.Opera = _Etapas.opera
    and $projection.Etapa = _Etapas.etapa

  association to        /GJAAUTO/CDS_CK_I_Automacoes as _Automacao
    on $projection.Auto = _Automacao.auto

{
  key auto          as Auto,
  key opera         as Opera,
  key etapa         as Etapa,
  key seqnr         as Seqnr,

      paramnat,
      paramtyp,
      tabname,
      param,
      param_from,
      tabname_from,
      paramval,
      paramopt,
      zeroleft,

      _Etapas,
      _Automacao
}
