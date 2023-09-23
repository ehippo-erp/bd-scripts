--------------------------------------------------------
--  DDL for Package PACK_PAGO_MASIVO_PROV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_PAGO_MASIVO_PROV" AS

    TYPE datarecord_formato IS RECORD (
        rotulo    VARCHAR2(100),
        indcabdet VARCHAR2(1),
        column01  VARCHAR2(500 CHAR),
        column02  VARCHAR2(500 CHAR),
        column03  VARCHAR2(500 CHAR),
        column04  VARCHAR2(500 CHAR),
        column05  VARCHAR2(500 CHAR),
        column06  VARCHAR2(500 CHAR),
        column07  VARCHAR2(500 CHAR),
        column08  VARCHAR2(500 CHAR),
        column09  VARCHAR2(500 CHAR),
        column10  VARCHAR2(500 CHAR)
    );
    TYPE datatable_fomato IS
        TABLE OF datarecord_formato;
    TYPE datarecord_reporte IS RECORD (
        id_cia  cliente.id_cia%TYPE,
        codcli  cliente.codcli%TYPE,
        razonc  cliente.razonc%TYPE,
        despago m_pago.descri%TYPE,
        tipcta  VARCHAR2(10 CHAR),
        nrocta  cliente_bancos.cuenta%TYPE,
        codmon  cliente_bancos.tipmon%TYPE,
        impneto prov103.pagomn%TYPE
    );
    TYPE datatable_reporte IS
        TABLE OF datarecord_reporte;
    TYPE datarecord_prov103 IS RECORD (
        id_cia  prov100.id_cia%TYPE,
        tdocum  prov100.tipdoc%TYPE,
        docume  prov100.docume%TYPE,
        femisi  prov100.femisi%TYPE,
        codcli  prov100.codcli%TYPE,
        razonc  cliente.razonc%TYPE,
        dident  cliente.dident%TYPE,
        tident  cliente.tident%TYPE,
        codmon  prov100.tipmon%TYPE,
        tipcan  prov103.tipcan%TYPE,
        tipcta  cliente_bancos.tipcta%TYPE,
        nrocta  cliente_bancos.cuenta%TYPE,
        despago m_pago.descri%TYPE,
        nrodni  cliente_tpersona.nrodni%TYPE,
        impor01 prov103.impor01%TYPE,
        pagomn  prov103.pagomn%TYPE,
        pagome  prov103.pagome%TYPE,
        netomn  prov103.pagomn%TYPE,
        netome  prov103.pagome%TYPE
    );
    TYPE datatable_prov103 IS
        TABLE OF datarecord_prov103;
    TYPE datarecord_detalle IS RECORD (
        codper    VARCHAR2(20 CHAR),
        checksum  INTEGER,
        nroctasum VARCHAR2(100 CHAR),
        monpag    planilla_resumen.totnet%TYPE
    );
    TYPE datatable_detalle IS
        TABLE OF datarecord_detalle;
    FUNCTION sp_genera_txt (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_codban    NUMBER,
        pin_codmon    VARCHAR2
    ) RETURN datatable_fomato
        PIPELINED;

    FUNCTION sp_reporte (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_codban    NUMBER,
        pin_codmon    VARCHAR2
    ) RETURN datatable_reporte
        PIPELINED;

    FUNCTION sp_detalle (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_codban    NUMBER,
        pin_codmon    VARCHAR2
    ) RETURN datatable_detalle
        PIPELINED;

    FUNCTION sp_prov103 (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_codban    NUMBER,
        pin_codmon    VARCHAR2
    ) RETURN datatable_prov103
        PIPELINED;

--select * from pack_pago_masivo_prov.sp_genera_txt(66,'53',2023,8,1,2,'PEN')
--
--select * from pack_pago_masivo_prov.sp_reporte(66,'53',2022,8,1,2,'PEN')
--
--select * from pack_pago_masivo_prov.sp_prov103(66,'53',2022,8,1,2,'PEN')

END;

/
