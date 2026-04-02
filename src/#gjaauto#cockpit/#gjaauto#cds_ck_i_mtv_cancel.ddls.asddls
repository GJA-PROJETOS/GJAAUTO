@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Motivos do cancelamento'
@Metadata.ignorePropagatedAnnotations: true
define view entity /GJAAUTO/CDS_CK_I_MTV_CANCEL as select from /gjaauto/cktb010
{
    key cancelm as Cancelm,
    cancelt as Cancelt
}
