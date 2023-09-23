--------------------------------------------------------
--  DDL for Package PACK_HR_PLANILLON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PLANILLON" AS
    TYPE datarecord_prestamo IS RECORD (
        cantid NUMBER
    );
    TYPE datatable_prestamo IS
        TABLE OF datarecord_prestamo;
    TYPE datarecord_planilla_rango IS RECORD (
        cantid NUMBER
    );
    TYPE datatable_planilla_rango IS
        TABLE OF datarecord_planilla_rango;
    TYPE datarecord_planillon IS RECORD (
        id_cia    NUMBER,
        numpla    NUMBER,
        indfec    NUMBER,
        indpre    NUMBER,
        codper    VARCHAR2(25),
        apepat    VARCHAR2(500),
        apemat    VARCHAR2(500),
        nombre    VARCHAR2(500),
        personal  VARCHAR2(500),
        conceptos CLOB
    );
    TYPE datatable_planillon IS
        TABLE OF datarecord_planillon;
    TYPE datarecord_concepto IS RECORD (
        id_cia NUMBER,
        numpla NUMBER,
        codcon VARCHAR2(5),
        abrevi VARCHAR2(15),
        nomcon VARCHAR(50)
    );
    TYPE datatable_concepto IS
        TABLE OF datarecord_concepto;
    TYPE datarecord_buscar_conceptos_personal IS RECORD (
        codcon VARCHAR2(20),
        valcon personal_concepto.valcon%TYPE
    );
    TYPE datatable_buscar_conceptos_personal IS
        TABLE OF datarecord_buscar_conceptos_personal;
    FUNCTION sp_buscar_conceptos_personal (
        pin_id_cia IN NUMBER,
        pin_numpla IN NUMBER,
        pin_codper IN VARCHAR2,
        pin_varfij VARCHAR2
    ) RETURN datatable_buscar_conceptos_personal
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numpla NUMBER
    ) RETURN datatable_planillon
        PIPELINED;

    FUNCTION sp_columnado (
        pin_id_cia NUMBER,
        pin_numpla NUMBER
    ) RETURN datatable_concepto
        PIPELINED;

    FUNCTION sp_prestamo (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_prestamo
        PIPELINED;

    FUNCTION sp_planilla_rango (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_planilla_rango
        PIPELINED;

    PROCEDURE sp_eliminar (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_codper  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

END;

/
