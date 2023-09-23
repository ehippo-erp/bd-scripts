--------------------------------------------------------
--  DDL for Package PACK_HR_FUNCTION_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_FUNCTION_GENERAL" AS
    TYPE datarecord_periodo_rango IS RECORD (
        pdesde NUMBER,
        phasta NUMBER
    );
    TYPE datatable_periodo_rango IS
        TABLE OF datarecord_periodo_rango;
    TYPE datarecord_fun_ymd_fechas IS RECORD (
        anio INTEGER,
        mes  INTEGER,
        dia  INTEGER
    );
    TYPE datatable_fun_ymd_fechas IS
        TABLE OF datarecord_fun_ymd_fechas;

--    select * from pack_hr_function_general.sp_periodo_rango(2022,01,2,'S');
    FUNCTION sp_periodo_rango (
        pin_periodo         IN NUMBER,
        pin_mes             IN NUMBER,
        pin_acum            IN NUMBER,
        pin_incluye_periodo IN VARCHAR2,
        pin_incluye_mes     IN VARCHAR2
    ) RETURN datatable_periodo_rango
        PIPELINED;

    TYPE datarecord_meses_completos IS RECORD (
        enero      NUMBER(15, 4),
        febrero    NUMBER(15, 4),
        marzo      NUMBER(15, 4),
        abril      NUMBER(15, 4),
        mayo       NUMBER(15, 4),
        junio      NUMBER(15, 4),
        julio      NUMBER(15, 4),
        agosto     NUMBER(15, 4),
        septiembre NUMBER(15, 4),
        octubre    NUMBER(15, 4),
        noviembre  NUMBER(15, 4),
        diciembre  NUMBER(15, 4)
    );
    TYPE datatable_meses_completos IS
        TABLE OF datarecord_meses_completos;
    FUNCTION sp_meses_completos_gratificacion (
        pin_id_cia  NUMBER,
        pin_periodo INTEGER,
        pin_fdesde  DATE,
        pin_fhasta  DATE,
        pin_mesgra  INTEGER
    ) RETURN datatable_meses_completos
        PIPELINED;

    FUNCTION sp_fun_ymd_fechas (
        fechainicial DATE,
        fechafinal   DATE
    ) RETURN datatable_fun_ymd_fechas
        PIPELINED;

END;

/
