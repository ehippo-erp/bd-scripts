--------------------------------------------------------
--  DDL for Package PACK_DW_ALERTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DW_ALERTA" AS
    TYPE datarecord_alerta IS RECORD (
        tipdoc    NUMBER,
        desdoc    VARCHAR2(1000 CHAR),
        numpen    INTEGER,
        linkrel   VARCHAR2(1000),
        tipdocrel NUMBER,
        situacrel VARCHAR2(1 CHAR),
        dessitrel VARCHAR2(1000 CHAR),
        fdesderel DATE,
        fhastarel DATE
    );
    TYPE datatable_alerta IS
        TABLE OF datarecord_alerta;
    TYPE datarecord_pendiente_saldo IS RECORD (
        modulo  VARCHAR2(10 CHAR),
        tipmon  VARCHAR2(10 CHAR),
        desdoc  VARCHAR2(1000 CHAR),
        saldo   NUMBER(16, 2),
        linkrel VARCHAR2(1000)
    );
    TYPE datatable_pendiente_saldo IS
        TABLE OF datarecord_pendiente_saldo;
    TYPE datarecord_pendiente_sunat_detalle IS RECORD (
        estado         VARCHAR2(2000 CHAR),
        tipo_documento VARCHAR2(2000 CHAR),
        sucursal       VARCHAR2(2000 CHAR),
        numint         documentos_cab.numint%TYPE,
        serie          documentos_cab.series%TYPE,
        numero         documentos_cab.numdoc%TYPE,
        fecha_emision  VARCHAR2(20 CHAR),
        cliente        documentos_cab.codcli%TYPE,
        razon_social   documentos_cab.razonc%TYPE,
        motivo         motivos.desmot%TYPE,
        situacion      VARCHAR2(2000 CHAR)
    );
    TYPE datatable_pendiente_sunat_detalle IS
        TABLE OF datarecord_pendiente_sunat_detalle;
    TYPE datarecord_pendiente_sunat_reporte IS RECORD (
        estado   VARCHAR2(2000 CHAR),
        tipdoc   documentos_cab.tipdoc%TYPE,
        desdoc   VARCHAR2(2000 CHAR),
        sucursal VARCHAR2(2000 CHAR),
        numint   documentos_cab.numint%TYPE,
        series   documentos_cab.series%TYPE,
        numdoc   documentos_cab.numdoc%TYPE,
        femisi   documentos_cab.femisi%TYPE,
        tident   cliente.tident%TYPE,
        dident   cliente.dident%TYPE,
        codcli   documentos_cab.codcli%TYPE,
        razonc   documentos_cab.razonc%TYPE,
        preven   documentos_cab.preven%TYPE,
        monafe   documentos_cab.monafe%TYPE,
        monina   documentos_cab.monina%TYPE,
        monigv   documentos_cab.monigv%TYPE,
        desmot   motivos.desmot%TYPE,
        dessit   VARCHAR2(2000 CHAR)
    );
    TYPE datatable_pendiente_sunat_reporte IS
        TABLE OF datarecord_pendiente_sunat_reporte;

    -- USADO PARA EL PDF DEL REGISTRO DE VENTAS
    FUNCTION sp_pendiente_sunat_reporte (
        pin_id_cia  IN NUMBER,
        pin_tipdoc  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_fdesde  IN DATE,
        pin_fhasta  IN DATE,
        pin_codsuc  IN NUMBER,
        pin_lugemi  IN NUMBER,
        pin_codmot  IN NUMBER,
        pin_codcli  IN VARCHAR2,
        pin_codven  IN NUMBER
    ) RETURN datatable_pendiente_sunat_reporte
        PIPELINED;

    -- USADO PARA EL TSI REPORTES
    FUNCTION sp_pendiente_sunat_detalle (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipdoc VARCHAR2
    ) RETURN datatable_pendiente_sunat_detalle
        PIPELINED;

    -- USADO PARA LA ALETAR EN EL DASHBOARD
    FUNCTION sp_pendiente_sunat (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipdoc VARCHAR2
    ) RETURN datatable_alerta
        PIPELINED;

    FUNCTION sp_vencimiento_certificado (
        pin_id_cia NUMBER
    ) RETURN datatable_alerta
        PIPELINED;

    FUNCTION sp_pendiente_documentos (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipdoc IN VARCHAR2
    ) RETURN datatable_alerta
        PIPELINED;

    FUNCTION sp_pendiente_saldo (
        pin_id_cia NUMBER
    ) RETURN datatable_pendiente_saldo
        PIPELINED;

--SELECT
--    *
--FROM
--    pack_dw_alerta.sp_vencimiento_certificado ( 66 );
--
--SELECT
--    *
--FROM
--    pack_dw_alerta.sp_pendiente_sunat_detalle(66, NULL, NULL, NULL)
--
--SELECT
--    *
--FROM
--    pack_dw_alerta.sp_pendiente_sunat(66, NULL, NULL, NULL)
--
--SELECT
--    *
--FROM
--    pack_dw_alerta.sp_pendiente_documentos(61, NULL, NULL, NULL);

END;

/
