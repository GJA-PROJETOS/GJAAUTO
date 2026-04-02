@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Motivos de aguardando'
@Metadata.ignorePropagatedAnnotations: true
define view entity /GJAAUTO/CDS_CK_I_MTV_AGRDND as select from /gjaauto/cktb009
{
    key waitm as Waitm,
    waitt as Waitt
}
