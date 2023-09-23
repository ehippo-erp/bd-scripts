--------------------------------------------------------
--  DDL for Package PACK_HR_PLANILLA_HABER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PLANILLA_HABER" AS
    TYPE datarecord_planilla_haber IS RECORD (
        id_cia      planilla_concepto.id_cia%TYPE,
        numpla      planilla_concepto.numpla%TYPE,
        id_planilla VARCHAR2(100),
        codper      planilla_concepto.codper%TYPE,
        apepat      personal.apepat%TYPE,
        apemat      personal.apemat%TYPE,
        nombre      personal.nombre%TYPE,
        nomper      VARCHAR2(500),
        coddoc      VARCHAR2(20),
        desdoc      VARCHAR2(500),
        nrodoc      VARCHAR2(500),
        codban      e_financiera.codigo%TYPE,
        desban      e_financiera.descri%TYPE,
        tipcta      e_financiera_tipo.tipcta%TYPE,
        descta      e_financiera_tipo.descri%TYPE,
        codmon      VARCHAR2(5 CHAR),
        desmon      VARCHAR2(20 CHAR),
        nrocta      VARCHAR2(100 CHAR),
        forpag      personal.forpag%TYPE,
        despag      VARCHAR2(100 CHAR),
        monpag      planilla_resumen.totnet%TYPE,
        situac      VARCHAR2(1 CHAR)
    );
    TYPE datatable_planilla_haber IS
        TABLE OF datarecord_planilla_haber;
    TYPE datarecord_genera_txt IS RECORD (
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
    TYPE datatable_genera_txt IS
        TABLE OF datarecord_genera_txt;
    TYPE datarecord_detalle IS RECORD (
        codper    VARCHAR2(20 CHAR),
        checksum  INTEGER,
        nroctasum VARCHAR2(100 CHAR),
        monpag    planilla_resumen.totnet%TYPE
    );
    TYPE datatable_detalle IS
        TABLE OF datarecord_detalle;
    TYPE r_errores IS RECORD (
        orden    NUMBER,
        concepto VARCHAR2(250),
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    TYPE datarecord_tipopago IS RECORD (
        id_cia INTEGER,
        tippag VARCHAR2(1 CHAR),
        despag VARCHAR2(100 CHAR)
    );
    TYPE datatable_tipopago IS
        TABLE OF datarecord_tipopago;
    FUNCTION sp_tipopago (
        pin_id_cia INTEGER
    ) RETURN datatable_tipopago
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_tippla  IN VARCHAR2,
        pin_empobr  IN VARCHAR2,
        pin_tippag  IN VARCHAR2,
        pin_codmon  IN VARCHAR2,
        pin_codban  IN NUMBER,
        pin_inccci  IN VARCHAR2
    ) RETURN datatable_planilla_haber
        PIPELINED;
        
--SELECT * FROM pack_hr_planilla_haber.sp_buscar
--(129,2023,6,'N','E','M','PEN',11,'S')

    FUNCTION sp_detalle (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_tippla  IN VARCHAR2,
        pin_empobr  IN VARCHAR2,
        pin_tippag  IN VARCHAR2,
        pin_codmon  IN VARCHAR2,
        pin_codban  IN NUMBER,
        pin_inccci  IN VARCHAR2
    ) RETURN datatable_detalle
        PIPELINED;

    FUNCTION sp_valida_objeto (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_tippla  IN VARCHAR2,
        pin_empobr  IN VARCHAR2,
        pin_tippag  IN VARCHAR2,
        pin_codmon  IN VARCHAR2,
        pin_codban  IN NUMBER,
        pin_inccci  IN VARCHAR2
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_genera_txt (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_tippla  IN VARCHAR2,
        pin_empobr  IN VARCHAR2,
        pin_tippag  IN VARCHAR2,
        pin_codmon  IN VARCHAR2,
        pin_codban  IN NUMBER,
        pin_inccci  IN VARCHAR2,
        pin_datos   IN VARCHAR2
    ) RETURN datatable_genera_txt
        PIPELINED;

END;

/
