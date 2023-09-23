--------------------------------------------------------
--  DDL for Package PACK_HR_FUNCION_PLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_FUNCION_PLANILLA" AS
    TYPE datarecord_funcion_planilla IS RECORD (
        id_cia    funcion_planilla.id_cia%TYPE,
        codfun    funcion_planilla.codfun%TYPE,
        nombre    funcion_planilla.nombre%TYPE,
        nomfun    funcion_planilla.nomfun%TYPE,
        tipfun    funcion_planilla.tipfun%TYPE,
        destipfun VARCHAR2(1000 CHAR),
        nummes    funcion_planilla.nummes%TYPE,
        pactual   funcion_planilla.pactual%TYPE,
        mactual   funcion_planilla.mactual%TYPE,
        observ    funcion_planilla.observ%TYPE,
        fcreac    funcion_planilla.fcreac%TYPE,
        factua    funcion_planilla.factua%TYPE,
        ucreac    funcion_planilla.ucreac%TYPE,
        uactua    funcion_planilla.uactua%TYPE
    );
    TYPE datatable_funcion_planilla IS
        TABLE OF datarecord_funcion_planilla;
    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codfun INTEGER,
        pin_nombre VARCHAR2
    ) RETURN datatable_funcion_planilla
        PIPELINED;

    TYPE array_tipfun IS
        VARRAY(15) OF VARCHAR2(200) NOT NULL;
    ka_tipfun array_tipfun := array_tipfun('CONTADOR', 'ACUMULADO', 'MAXIMO', 'MINIMO', 'PRIMERO',
                                          'ULTIMO', 'PROMEDIO', 'ULTIMO NORMAL', 'SIN DEFINIR', 'NO DEFINIDO',
                                          'RENTA DE QUINTA', 'ACUMULADO PRIMER SEMESTRE DEL AÑO', 'ACUMULADO SEGUNDO SEMESTRE DEL AÑO A'
                                          , 'ACUMULADO SEGUNDO SEMESTRE DEL AÑO B', 'ACUMULADO POR SEMESTRE');
    TYPE datarecord_tipofuncion IS RECORD (
        id_cia    NUMBER,
        tipfun    NUMBER,
        destipfun VARCHAR2(80)
    );
    TYPE datatable_tipofuncion IS
        TABLE OF datarecord_tipofuncion;
    FUNCTION sp_buscar_tipofuncion (
        pin_id_cia NUMBER,
        pin_tipfun NUMBER
    ) RETURN datatable_tipofuncion
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
