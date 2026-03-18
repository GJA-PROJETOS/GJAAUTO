@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Motor: Etapas da automação'

@Metadata.ignorePropagatedAnnotations: true

define view entity /GJAAUTO/CDS_MT_I_EtapasAuto
  as select from /gjaauto/mttb003

  association        to parent /GJAAUTO/CDS_MT_I_HeaderAuto as _HeaderAuto on  $projection.Auto  = _HeaderAuto.Auto
                                                                           and $projection.Opera = _HeaderAuto.Opera
                                                                           and $projection.Chave = _HeaderAuto.Chave

  composition [0..*] of /GJAAUTO/CDS_MT_I_Logs              as _Logs

  association [1..1] to /gjaauto/cktb003                    as _Etapa      on  $projection.Auto  = _Etapa.auto
                                                                           and $projection.Opera = _Etapa.opera
                                                                           and $projection.Etapa = _Etapa.etapa
{
  key auto         as Auto,
  key opera        as Opera,
  key chave        as Chave,
  key etapa        as Etapa,

      credat       as Credat,
      cretim       as Cretim,
      crenam       as Crenam,
      status       as Status,
      waitm        as Waitm,
      _Etapa.descr as Etapa_Descr,

      _HeaderAuto,
      _Logs
}
