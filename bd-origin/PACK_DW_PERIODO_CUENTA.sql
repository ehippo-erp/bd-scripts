--------------------------------------------------------
--  DDL for Package PACK_DW_PERIODO_CUENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DW_PERIODO_CUENTA" AS
    TYPE datarecord_reporte IS RECORD (
        id_cia  dcta100.id_cia%TYPE,
        codcli  dcta100.codcli%TYPE,
        razonc  cliente.razonc%TYPE,
        tipven  periodo_cuenta.tipven%TYPE,
        desven  VARCHAR2(100),
        orden   periodo_cuenta.orden%TYPE,
        desran  periodo_cuenta.desran%TYPE,
        importe dcta100.importe%TYPE
    );
    TYPE datatable_reporte IS
        TABLE OF datarecord_reporte;
    TYPE datarecord_reportev2 IS RECORD (
        id_cia       dcta100.id_cia%TYPE,
        codcli       dcta100.codcli%TYPE,
        razonc       cliente.razonc%TYPE,
        orden        periodo_cuenta.orden%TYPE,
        desran       periodo_cuenta.desran%TYPE,
        venc_importe dcta100.importe%TYPE,
        xven_importe dcta100.importe%TYPE
    );
    TYPE datatable_reportev2 IS
        TABLE OF datarecord_reportev2;
    TYPE datarecord_general IS RECORD (
        id_cia dcta100.id_cia%TYPE,
        codcli dcta100.codcli%TYPE,
        razonc cliente.razonc%TYPE,
        venci1 dcta100.importe%TYPE,
        venci2 dcta100.importe%TYPE,
        venci3 dcta100.importe%TYPE,
        venci4 dcta100.importe%TYPE,
        pendt1 dcta100.importe%TYPE,
        pendt2 dcta100.importe%TYPE,
        pendt3 dcta100.importe%TYPE,
        pendt4 dcta100.importe%TYPE,
        ventot dcta100.importe%TYPE,
        pentot dcta100.importe%TYPE,
        sumtot dcta100.importe%TYPE
    );
    TYPE datatable_general IS
        TABLE OF datarecord_general;
    TYPE datarecord_detalle IS RECORD (
        id_cia        dcta100.id_cia%TYPE,
        codcli        dcta100.codcli%TYPE,
        razonc        cliente.razonc%TYPE,
--        tipven        periodo_cuenta.tipven%TYPE,
--        desven        VARCHAR2(100),
--        orden         periodo_cuenta.orden%TYPE,
--        desran        periodo_cuenta.desran%TYPE,
        concepto      VARCHAR2(120),
        tipodocumento VARCHAR2(120),
        serie         prov100.serie%TYPE,
        numdoc        prov100.numero%TYPE,
        usuario       VARCHAR2(100),
        femisi        dcta100.femisi%TYPE,
        fvenci        dcta100.fvenci%TYPE,
        fdiff         NUMBER,
        tipmon        dcta100.tipmon%TYPE,
        tipcam        dcta100.tipcam%TYPE,
        importe       dcta100.importe%TYPE,
        import01      dcta100.importemn%TYPE,
        import02      dcta100.importeme%TYPE,
        saldo         dcta100.saldo%TYPE
    );
    TYPE datatable_detalle IS
        TABLE OF datarecord_detalle;
    FUNCTION sp_reporte (
        pin_id_cia NUMBER,
        pin_cuenta NUMBER,
        pin_tipran NUMBER,
        pin_tipmon VARCHAR2,
        pin_codcli VARCHAR2
    ) RETURN datatable_reporte
        PIPELINED;

    FUNCTION sp_reportev2 (
        pin_id_cia NUMBER,
        pin_cuenta NUMBER,
        pin_tipran NUMBER,
        pin_tipmon VARCHAR2,
        pin_codcli VARCHAR2
    ) RETURN datatable_reportev2
        PIPELINED;

    FUNCTION sp_general (
        pin_id_cia NUMBER,
        pin_cuenta NUMBER,
        pin_tipran NUMBER,
        pin_tipmon VARCHAR2
    ) RETURN datatable_general
        PIPELINED;

    FUNCTION sp_detalle (
        pin_id_cia NUMBER,
        pin_cuenta NUMBER,
        pin_tipran NUMBER,
        pin_tipmon VARCHAR2,
        pin_codcli VARCHAR2,
        pin_tipven NUMBER,
        pin_orden  NUMBER
    ) RETURN datatable_detalle
        PIPELINED;

END;

/
