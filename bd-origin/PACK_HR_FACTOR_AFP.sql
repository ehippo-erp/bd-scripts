--------------------------------------------------------
--  DDL for Package PACK_HR_FACTOR_AFP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_FACTOR_AFP" AS
    TYPE factorafpdatarecord IS RECORD (
        id_cia factor_afp.id_cia%TYPE,
        anio   factor_afp.anio%TYPE,
        mes    factor_afp.mes%TYPE,
        codafp factor_afp.codafp%TYPE,
        codfac factor_afp.codfac%TYPE,
        valfa1 factor_afp.valfa1%TYPE,
        valfa2 factor_afp.valfa2%TYPE,
        ucreac factor_afp.ucreac%TYPE,
        uactua factor_afp.uactua%TYPE,
        fcreac factor_afp.fcreac%TYPE,
        factua factor_afp.factua%TYPE,
        nomfac factor_planilla.nombre%TYPE,
        nomafp afp.nombre%TYPE
    );
    TYPE factorafpdatatable IS
        TABLE OF factorafpdatarecord;
    TYPE datarecord_factor_afp_periodo IS RECORD (
        id_cia   NUMBER,
        numpla   NUMBER,
        codper   VARCHAR(20),
        codafp   VARCHAR(4),
        nomafp   VARCHAR(40),
        vtcom    NUMERIC(15, 4),
        desvtcom VARCHAR(200),
        wporonp  NUMERIC(15, 4),
        wporfpen NUMERIC(15, 4),
        wporsinv NUMERIC(15, 4),
        wporcom  NUMERIC(15, 4),
        totalpor NUMERIC(15, 4)
    );
    TYPE datatable_factor_afp_periodo IS
        TABLE OF datarecord_factor_afp_periodo;
    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_anio   IN NUMBER,
        pin_mes    IN NUMBER,
        pin_codafp IN VARCHAR2,
        pin_codfac IN VARCHAR2
    ) RETURN factorafpdatatable
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_genera_factor_afp (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_codafp  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_replica_factor_afp (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_codafp  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_clonar (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_factor_afp_periodo (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_factor_afp_periodo
        PIPELINED;

END;

/
