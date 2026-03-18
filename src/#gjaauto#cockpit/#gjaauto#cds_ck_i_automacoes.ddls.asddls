@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Cockpit: Automações'

@Metadata.ignorePropagatedAnnotations: true

define root view entity /GJAAUTO/CDS_CK_I_Automacoes
  as select from /gjaauto/cktb001 as automacoes

  composition [0..*] of /GJAAUTO/CDS_CK_I_Operacoes as _Operacoes

{
  key automacoes.auto,

      automacoes.descr,
      automacoes.icon_fiori,

      _Operacoes
}
