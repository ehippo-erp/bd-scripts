--------------------------------------------------------
--  DDL for Package PACK_HR_ASIENTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_ASIENTO" AS
    TYPE datarecord_asiento IS RECORD (
        codper    personal.codper%TYPE,
        codcon    concepto.codcon%TYPE,
        nomcon    concepto.nombre%TYPE,
        cuenta    pcuentas.cuenta%TYPE,
        codcco    personal_ccosto.codcco%TYPE,
        prcdis    personal_ccosto.prcdis%TYPE,
        totcon    NUMBER(16, 4),
        dh        pcuentas.dh%TYPE,
        importemn NUMBER(16, 4),
        importeme NUMBER(16, 4),
        debemn    NUMBER(16, 4),
        debeme    NUMBER(16, 4),
        habermn   NUMBER(16, 4),
        haberme   NUMBER(16, 4)
    );
    TYPE datatable_asiento IS
        TABLE OF datarecord_asiento;
    TYPE datarecord_reporte_pdf IS RECORD (
        id_cia    personal.id_cia%TYPE,
        rotulo    VARCHAR2(200 CHAR),
        codper    VARCHAR2(20 CHAR),
        nomper    VARCHAR2(500 CHAR),
        codcon    VARCHAR2(5 CHAR),
        nomcon    VARCHAR2(200 CHAR),
        cuenta    VARCHAR2(20 CHAR),
        ctacco    VARCHAR2(20 CHAR),
        subcco    VARCHAR2(20 CHAR),
        codcco    VARCHAR2(20 CHAR),
        prcdis    NUMERIC(15, 4),
        dh        pcuentas.dh%TYPE,
        totcon    NUMERIC(15, 4),
        tipcam    NUMERIC(9, 2),
        importemn NUMBER(16, 4),
        importeme NUMBER(16, 4),
        debemn    NUMBER(16, 4),
        debeme    NUMBER(16, 4),
        habermn   NUMBER(16, 4),
        haberme   NUMBER(16, 4)
    );
    TYPE datatable_reporte_pdf IS
        TABLE OF datarecord_reporte_pdf;
    TYPE datarecord_reporte_excel IS RECORD (
        id_cia    personal.id_cia%TYPE,
        rotulo    VARCHAR2(200 CHAR),
        cuenta    VARCHAR2(20 CHAR),
        dh        pcuentas.dh%TYPE,
        concepto  VARCHAR2(75 CHAR),
        codmon    VARCHAR2(5 CHAR),
        importe   NUMERIC(15, 4),
        codcco    VARCHAR2(20 CHAR), -- CENTRO DE COSTO
        subcco    VARCHAR2(20 CHAR), -- SUB CENTRO DE COSTO
        proyect   VARCHAR2(16 CHAR),
        codcli    VARCHAR2(20 CHAR), -- CODIGO DEL CLIENTE
        razonc    VARCHAR2(75 CHAR), --  RAZONSOCIAL
        tident    VARCHAR2(2 CHAR), -- TIPO DE IDENTIDAD
        nrodoc    VARCHAR2(16 CHAR), -- NUMERO DE DOCUMENTO 
        tipdoc    VARCHAR2(2 CHAR),
        serie     VARCHAR2(5 CHAR),
        numdoc    VARCHAR2(20 CHAR),
        femisi    DATE,
        ctaalt    VARCHAR2(20 CHAR), -- CUENTA CONTABLE ALTERNATIVA
        tiprelcxp INTEGER, -- TIPO - RELACION CON CXP
        docrelcxp INTEGER -- DOCUME - RELACION CON CXP
    );
    TYPE datatable_reporte_excel IS
        TABLE OF datarecord_reporte_excel;
    FUNCTION sp_genera (
        pin_id_cia  NUMBER,
        pin_tiptra  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipcam  NUMBER,
        pin_opc     INTEGER
    ) RETURN datatable_asiento
        PIPELINED;

    FUNCTION sp_genera_cuenta41 (
        pin_id_cia  NUMBER,
        pin_tiptra  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipcam  NUMBER,
        pin_opc     INTEGER
    ) RETURN datatable_asiento
        PIPELINED;

    FUNCTION sp_reporte_pdf_auxiliar (
        pin_id_cia  NUMBER,
        pin_tiptra  VARCHAR2,
        pin_periodo SMALLINT,
        pin_mes     SMALLINT
    ) RETURN datatable_reporte_pdf
        PIPELINED;

    FUNCTION sp_reporte_pdf (
        pin_id_cia  NUMBER,
        pin_tiptra  VARCHAR2,
        pin_periodo SMALLINT,
        pin_mes     SMALLINT
    ) RETURN datatable_reporte_pdf
        PIPELINED;

    FUNCTION sp_reporte_excel (
        pin_id_cia  NUMBER,
        pin_tiptra  VARCHAR2,
        pin_periodo SMALLINT,
        pin_mes     SMALLINT,
        pin_opc     INTEGER
    ) RETURN datatable_reporte_excel
        PIPELINED;

--SELECT * FROM pack_hr_asiento.sp_reporte_excel(25,'E',2023,04,0);
--
--SELECT 
--SUM(CASE WHEN dh = 'D' THEN importe ELSE 0 END) AS debe,
--SUM(CASE WHEN dh = 'H' THEN importe ELSE 0 END) AS haber
--FROM pack_hr_asiento.sp_reporte_excel(25,'E',2023,06,2);

END;

/
