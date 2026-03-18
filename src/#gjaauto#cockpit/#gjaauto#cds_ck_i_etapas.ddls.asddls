@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Cockpit: Etapas'

@Metadata.ignorePropagatedAnnotations: true

define view entity /GJAAUTO/CDS_CK_I_Etapas
  as select from /gjaauto/cktb003 as etapa

  association           to parent /GJAAUTO/CDS_CK_I_Operacoes   as _Operacao
    on  $projection.auto  = _Operacao.auto
    and $projection.opera = _Operacao.opera

  composition [0..*] of           /GJAAUTO/CDS_CK_I_MAPEMENTOS  as _Mapeamentos
  composition [0..*] of           /GJAAUTO/CDS_CK_I_LoopTables  as _LoopTables
  composition [0..*] of           /GJAAUTO/CDS_CK_I_Atribuicoes as _Atribuicoes

  association           to        /GJAAUTO/CDS_CK_I_Automacoes  as _Automacao
    on $projection.auto = _Automacao.auto

{
  key etapa.auto,
  key etapa.opera,
  key etapa.etapa,

      etapa.descr,
      etapa.tpeta,
      etapa.rotin,
      etapa.mapea,
      etapa.keyfieldname,
      etapa.commit_after,
      etapa.after,

      _Operacao,
      _Mapeamentos,
      _LoopTables,
      _Atribuicoes,
      _Automacao
}
