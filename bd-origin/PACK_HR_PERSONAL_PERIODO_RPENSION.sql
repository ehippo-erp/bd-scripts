--------------------------------------------------------
--  DDL for Package PACK_HR_PERSONAL_PERIODO_RPENSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PERSONAL_PERIODO_RPENSION" AS
    TYPE datarecord_personal_periodo_rpension IS RECORD (
        id_cia   personal_periodo_rpension.id_cia%TYPE,
        codper   personal_periodo_rpension.codper%TYPE,
        id_prpen personal_periodo_rpension.id_prpen%TYPE,
        codafp   personal_periodo_rpension.codafp%TYPE,
        desafp   afp.nombre%TYPE,
        finicio  personal_periodo_rpension.finicio%TYPE,
        ffinal   personal_periodo_rpension.ffinal%TYPE,
        ucreac   personal_periodo_rpension.ucreac%TYPE,
        uactua   personal_periodo_rpension.uactua%TYPE,
        fcreac   personal_periodo_rpension.fcreac%TYPE,
        factua   personal_periodo_rpension.factua%TYPE
    );
    TYPE datatable_personal_periodo_rpension IS
        TABLE OF datarecord_personal_periodo_rpension;
    TYPE datarecord_regimenpension IS RECORD (
        id_cia    personal.id_cia%TYPE,
        codper    personal.codper%TYPE,
        nomper    VARCHAR2(500),
        codafp    afp.codafp%TYPE,
        situac    personal.situac%TYPE,
        finicio   personal_periodolaboral.finicio%TYPE,
        ffinal    personal_periodolaboral.ffinal%TYPE,
        diatratot NUMBER,
        diatrames NUMBER
    );
    TYPE datatable_regimenpension IS
        TABLE OF datarecord_regimenpension;
    FUNCTION sp_regimenpension (
        pin_id_cia NUMBER,
        pin_tiptra VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_regimenpension
        PIPELINED;

    FUNCTION sp_obtener (
        pin_id_cia   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codafp   IN VARCHAR,
        pin_id_prpen IN NUMBER
    ) RETURN datatable_personal_periodo_rpension
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codper IN VARCHAR2,
        pin_codafp IN VARCHAR2
    ) RETURN datatable_personal_periodo_rpension
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
