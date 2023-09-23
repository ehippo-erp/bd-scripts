--------------------------------------------------------
--  DDL for Package PACK_HR_PLANILLA_CONCEPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PLANILLA_CONCEPTO" AS
    TYPE r_errores IS RECORD (
        valor    VARCHAR2(1000),
        deserror VARCHAR2(1000)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    TYPE datarecord_json IS RECORD (
        codcon concepto.codcon%TYPE,
        valcon planilla_concepto.valcon%TYPE
    );
    TYPE datatable_json IS
        TABLE OF datarecord_json;
    TYPE datarecord_obtener IS RECORD (
        id_cia planilla_concepto.id_cia%TYPE,
        numpla planilla_concepto.numpla%TYPE,
        codper planilla_concepto.codper%TYPE,
        codcon planilla_concepto.codcon%TYPE,
        valcon planilla_concepto.valcon%TYPE
    );
    TYPE datatable_obtener IS
        TABLE OF datarecord_obtener;
    TYPE datarecord_planilla_concepto IS RECORD (
        id_cia  planilla_concepto.id_cia%TYPE,
        numpla  planilla_concepto.numpla%TYPE,
        codper  planilla_concepto.codper%TYPE,
        nomper  VARCHAR2(500),
        codcon  planilla_concepto.codcon%TYPE,
        abrevi  concepto.abrevi%TYPE,
        nomcon  concepto.nombre%TYPE,
        ingdes  concepto.ingdes%TYPE,
        dingdes VARCHAR2(500),
        fijvar  concepto.fijvar%TYPE,
        dfijvar VARCHAR2(500),
        idliq   concepto.idliq%TYPE,
        didliq  VARCHAR2(500),
        valcon  planilla_concepto.valcon%TYPE,
        ucreac  planilla_concepto.ucreac%TYPE,
        uactua  planilla_concepto.uactua%TYPE,
        fcreac  planilla_concepto.fcreac%TYPE,
        factua  planilla_concepto.factua%TYPE
    );
    TYPE datatable_planilla_concepto IS
        TABLE OF datarecord_planilla_concepto;
    TYPE datarecord_planilla_concepto_personal IS RECORD (
        id_cia  planilla_concepto.id_cia%TYPE,
        numpla  planilla_concepto.numpla%TYPE,
        codper  planilla_concepto.codper%TYPE,
        nomper  VARCHAR2(500),
        codafp  personal.codafp%TYPE,
        desafp  afp.nombre%TYPE,
        finicio personal_periodolaboral.finicio%TYPE,
        ffinal  personal_periodolaboral.ffinal%TYPE,
        ucreac  personal.ucreac%TYPE,
        uactua  personal.uactua%TYPE,
        fcreac  personal.fcreac%TYPE,
        factua  personal.factua%TYPE
    );
    TYPE datatable_planilla_concepto_personal IS
        TABLE OF datarecord_planilla_concepto_personal;
    FUNCTION sp_buscar_personal (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_planilla_concepto_personal
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2,
        pin_ingdes VARCHAR2,
        pin_fijvar VARCHAR2,
        pin_idliq  VARCHAR2,
        pin_codcon VARCHAR2
    ) RETURN datatable_planilla_concepto
        PIPELINED;

    FUNCTION sp_json (
        pin_json VARCHAR2
    ) RETURN datatable_json
        PIPELINED;

    FUNCTION sp_valida_objeto (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR,
        pin_datos  CLOB
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_prevalida_objeto (
        pin_id_cia   NUMBER,
        pin_numpla   NUMBER,
        pin_personal VARCHAR2,-- Lista de Personal 12456421,4564231366,456465
        pin_concepto VARCHAR2 -- Lista de Conceptos 001,545,202,024,102,120
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2,
        pin_codcon VARCHAR2
    ) RETURN datatable_obtener
        PIPELINED;

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_codper  IN VARCHAR2,
        pin_datos   IN CLOB, -- Json en una Fila
        pin_opcdml  IN INTEGER,
        pin_coduser IN VARCHAR2
    );

    PROCEDURE sp_elimina (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_coduser IN VARCHAR2
    );

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
