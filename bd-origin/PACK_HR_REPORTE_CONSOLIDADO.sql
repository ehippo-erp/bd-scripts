--------------------------------------------------------
--  DDL for Package PACK_HR_REPORTE_CONSOLIDADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_REPORTE_CONSOLIDADO" AS
    TYPE datarecord_reporte IS RECORD (
        codper           personal.codper%TYPE,
        nomper           VARCHAR2(1000),
        bol_ingreso      NUMBER,
        bol_decuento     NUMBER,
        bol_aportacion   NUMBER,
        bol_neto_pagar   NUMBER,
        neto_sistema     NUMBER,
        neto_haber       NUMBER,
        codafp           VARCHAR2(5 CHAR),
        ingreso_noafecto NUMBER,
        renta_asegurada  NUMBER,
        consistencia_importe           VARCHAR2(50 CHAR),
        consistencia_haber           VARCHAR2(50 CHAR),
        consistencia_afp_net           VARCHAR2(50 CHAR)
    );
    TYPE datatable_reporte IS
        TABLE OF datarecord_reporte;
    TYPE datarecord_ingreso_noafecto IS RECORD (
        id_cia personal.id_cia%TYPE,
        codper personal.codper%TYPE,
        valcon personal_concepto.valcon%TYPE
    );
    TYPE datatable_ingreso_noafecto IS
        TABLE OF datarecord_ingreso_noafecto;
    FUNCTION sp_reporte (
        pin_id_cia   NUMBER,
        pin_codban NUMBER,
        pin_numpla   NUMBER
    ) RETURN datatable_reporte
        PIPELINED;

    FUNCTION sp_ingreso_noafecto (
        pin_id_cia NUMBER,
        pin_numpla NUMBER
    ) RETURN datatable_ingreso_noafecto
        PIPELINED;

END;

/
