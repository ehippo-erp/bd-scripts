--------------------------------------------------------
--  DDL for Package PACK_HR_CONCEPTO_FUNCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_CONCEPTO_FUNCION" AS
    TYPE datarecord_concepto_funcion IS RECORD (
        id_cia    concepto_funcion.id_cia%TYPE,
        condes    concepto_funcion.condes%TYPE,
        desdes    concepto.nombre%TYPE,
        conori    concepto_funcion.conori%TYPE,
        desori    concepto.nombre%TYPE,
        codfun    concepto_funcion.codfun%TYPE,
        desfun    funcion_planilla.nombre%TYPE,
        nomfun    funcion_planilla.nomfun%TYPE,
        observfun funcion_planilla.observ%TYPE,
        ucreac    concepto_funcion.ucreac%TYPE,
        uactua    concepto_funcion.uactua%TYPE,
        fcreac    concepto_funcion.fcreac%TYPE,
        factua    concepto_funcion.factua%TYPE
    );
    TYPE datatable_concepto_funcion IS
        TABLE OF datarecord_concepto_funcion;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_condes VARCHAR2,
        pin_conori VARCHAR2,
        pin_codfun NUMBER
    ) RETURN datatable_concepto_funcion
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_condes VARCHAR2,
        pin_conori VARCHAR2,
        pin_codfun NUMBER
    ) RETURN datatable_concepto_funcion
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
