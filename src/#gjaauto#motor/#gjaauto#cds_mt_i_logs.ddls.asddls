@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Motor: Logs das automações'
@Metadata.ignorePropagatedAnnotations: true
define view entity /GJAAUTO/CDS_MT_I_Logs as select from /gjaauto/mttb002
  association to parent /GJAAUTO/CDS_MT_I_EtapasAuto as _EtapaAuto
    on  $projection.Auto  = _EtapaAuto.Auto
    and $projection.Opera = _EtapaAuto.Opera
    and $projection.Chave = _EtapaAuto.Chave
    and $projection.Etapa = _EtapaAuto.Etapa
{
    key auto as Auto,
    key opera as Opera,
    key credat as Credat,
    key cretim as Cretim,
    key chave as Chave,
    key etapa as Etapa,
    key item as Item,
    type as Type,
    id as Id,
    number_msg as NumberMsg,
    message as Message,
    log_no as LogNo,
    log_msg_no as LogMsgNo,
    message_v1 as MessageV1,
    message_v2 as MessageV2,
    message_v3 as MessageV3,
    message_v4 as MessageV4,
    parameter_name as ParameterName,
    row_param as RowParam,
    field as Field,
    system_log as SystemLog,
    
    _EtapaAuto
}
