@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Motor: Cabeçalho da automação'

@Metadata.ignorePropagatedAnnotations: true

define root view entity /GJAAUTO/CDS_MT_I_HeaderAuto
  as select from /gjaauto/mttb001

  composition [0..*] of /GJAAUTO/CDS_MT_I_EtapasAuto as _EtapasExecutadas
  association [1..1] to /gjaauto/cktb001             as _Auto   on  $projection.Auto = _Auto.auto
  association [1..1] to /gjaauto/cktb002             as _Opera  on  $projection.Auto  = _Opera.auto
                                                                and $projection.Opera = _Opera.opera

{
  key auto         as Auto,
  key opera        as Opera,
  key chave        as Chave,

      credat       as Credat,
      cretim       as Cretim,
      crenam       as Crenam,
      status       as Status,
      _Auto.descr  as DescrAuto,
      _Opera.descr as DescrOpera,
      _EtapasExecutadas
}
