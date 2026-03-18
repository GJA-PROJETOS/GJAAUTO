@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Cockpit: Operações'

@Metadata.ignorePropagatedAnnotations: true

define view entity /GJAAUTO/CDS_CK_I_Operacoes
  as select from /gjaauto/cktb002 as operacao

  association           to parent /GJAAUTO/CDS_CK_I_Automacoes as _Automacao on $projection.auto = _Automacao.auto
  composition [0..*] of           /GJAAUTO/CDS_CK_I_Etapas     as _Etapas
  composition [0..*] of           /GJAAUTO/CDS_CK_I_DADOS      as _Dados
{
  key operacao.auto,
  key operacao.opera,

      operacao.descr,
      operacao.snro,
      operacao.snronr,

      _Automacao,
      _Etapas,
      _Dados
}
