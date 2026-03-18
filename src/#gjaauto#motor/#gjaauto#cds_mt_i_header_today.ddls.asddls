@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Motor: Automações HOJE'
@Metadata.ignorePropagatedAnnotations: true
define view entity /GJAAUTO/CDS_MT_I_HEADER_TODAY as select from /GJAAUTO/CDS_MT_I_HeaderAuto
{
    key Auto,
    key Opera,
    key Chave,
    Credat,
    Cretim,
    Crenam,
    Status,
    DescrAuto,
    DescrOpera
} where Credat = $session.system_date
