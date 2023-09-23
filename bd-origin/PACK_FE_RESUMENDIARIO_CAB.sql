--------------------------------------------------------
--  DDL for Package PACK_FE_RESUMENDIARIO_CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_FE_RESUMENDIARIO_CAB" AS
    TYPE datarecord_fe_resumendiario_cab IS RECORD (
        id_cia     fe_resumendiario_cab.id_cia%TYPE,
        idres      fe_resumendiario_cab.idres%TYPE,
        tipo       fe_resumendiario_cab.tipo%TYPE,
        destipo VARCHAR2(500),
        fgenera    fe_resumendiario_cab.fgenera%TYPE,
        femisi     fe_resumendiario_cab.femisi%TYPE,
        tipmon     fe_resumendiario_cab.tipmon%TYPE,
        estado     fe_resumendiario_cab.estado%TYPE,
        desest     VARCHAR2(500),
        ticket_old BLOB,
        xml        BLOB,
        cdr        BLOB,
        ticketbck  VARCHAR2(500),
        ticket     VARCHAR2(500)
    );
    TYPE t_fe_resumendiario_cab IS
        TABLE OF datarecord_fe_resumendiario_cab;
    TYPE datarecord_documentos_pendientes IS RECORD (
        numint  documentos_cab.numint%TYPE,
        desdoc  documentos_tipo.descri%TYPE,
        situac  documentos_cab.situac%TYPE,
        tipdoc  documentos_cab.tipdoc%TYPE,
        codsuc  documentos_cab.codsuc%TYPE,
        femisi  documentos_cab.femisi%TYPE,
        codcli  documentos_cab.codcli%TYPE,
        razonc  documentos_cab.razonc%TYPE,
        series  documentos_cab.series%TYPE,
        numdoc  documentos_cab.numdoc%TYPE,
        monafe  documentos_cab.monafe%TYPE,
        monina  documentos_cab.monina%TYPE,
        monigv  documentos_cab.monigv%TYPE,
        acuenta documentos_cab.acuenta%TYPE,
        tipmon  documentos_cab.tipmon%TYPE,
        preven  documentos_cab.preven%TYPE,
        gentxt  VARCHAR2(20),
        estado  documentos_cab_envio_sunat.estado%TYPE
    );
    TYPE datatable_documentos_pendientes IS
        TABLE OF datarecord_documentos_pendientes;
    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_idres  IN NUMBER
    ) RETURN t_fe_resumendiario_cab
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia    IN NUMBER,
        pin_estado    IN VARCHAR2,
        pin_tipo      IN NUMBER,
        pin_fgdesde   IN DATE,
        pin_fghasta   IN DATE,
        pin_fedesde   IN DATE,
        pin_fehasta   IN DATE,
        pin_fgentodos IN VARCHAR2,
        pin_femitodos IN VARCHAR2
    ) RETURN t_fe_resumendiario_cab
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_documentos_pendientes (
        pin_id_cia    NUMBER,
        pin_femisi    DATE,
        pin_cadestado NUMBER,
        pin_tipdoc    NUMBER
    ) RETURN datatable_documentos_pendientes
        PIPELINED;

END;

/
