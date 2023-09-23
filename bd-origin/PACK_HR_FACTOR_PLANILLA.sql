--------------------------------------------------------
--  DDL for Package PACK_HR_FACTOR_PLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_FACTOR_PLANILLA" AS
    TYPE t_factor_planilla IS
        TABLE OF factor_planilla%rowtype;
    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codfac IN INTEGER,
        pin_nombre IN VARCHAR2
    ) RETURN t_factor_planilla
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

--    TYPE t_factor_clase_planilla IS
--        TABLE OF factor_clase_planilla%rowtype;
    TYPE datarecord_buscar_clase IS RECORD (
        id_cia    factor_clase_planilla.id_cia%TYPE,
        codfac    factor_clase_planilla.codfac%TYPE,
        codcla    factor_clase_planilla.codcla%TYPE,
        tipcla    factor_clase_planilla.tipcla%TYPE,
        destipcla VARCHAR2(80),
        tipvar    factor_clase_planilla.tipvar%TYPE,
        destipvar VARCHAR2(80),
        nombre    factor_clase_planilla.nombre%TYPE,
        vreal     factor_clase_planilla.vreal%TYPE,
        vstrg     factor_clase_planilla.vstrg%TYPE,
        vchar     factor_clase_planilla.vchar%TYPE,
        vdate     factor_clase_planilla.vdate%TYPE,
        vtime     factor_clase_planilla.vtime%TYPE,
        ventero   factor_clase_planilla.ventero%TYPE,
        ucreac    factor_clase_planilla.ucreac%TYPE,
        uactua    factor_clase_planilla.uactua%TYPE,
        fcreac    factor_clase_planilla.fcreac%TYPE,
        factua    factor_clase_planilla.factua%TYPE
    );
    TYPE datatable_buscar_clase IS
        TABLE OF datarecord_buscar_clase;
    FUNCTION sp_buscar_clase (
        pin_id_cia IN NUMBER,
        pin_codfac IN VARCHAR2,
        pin_codcla IN VARCHAR2,
        pin_nombre IN VARCHAR2
    ) RETURN datatable_buscar_clase
        PIPELINED;

    PROCEDURE sp_save_clase (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    TYPE array_tipcla IS
        VARRAY(5) OF VARCHAR2(200) NOT NULL;
    ka_tipcla array_tipcla := array_tipcla('Tipo de Trabajador', 'Periodo', 'Logico', 'Concepto', 'ND');
    TYPE datarecord_tipoclase IS RECORD (
        id_cia    NUMBER,
        tipcla    NUMBER,
        destipcla VARCHAR2(80)
    );
    TYPE datatable_tipoclase IS
        TABLE OF datarecord_tipoclase;
    TYPE array_tipvar IS
        VARRAY(6) OF VARCHAR2(300) NOT NULL;
    ka_tipvar array_tipvar := array_tipvar('VREAL', 'VSTRG', 'VCHAR', 'VDATE', 'VTIME',
                                          'VENTERO');
    TYPE datarecord_tipovariable IS RECORD (
        id_cia    NUMBER,
        tipvar    VARCHAR2(1 CHAR),
        destipvar VARCHAR2(80)
    );
    TYPE datatable_tipovariable IS
        TABLE OF datarecord_tipovariable;

--SELECT * FROM  pack_hr_factor_planilla.sp_buscar_tipoclase(66,null) ;
--
--SELECT * FROM  pack_hr_factor_planilla.sp_buscar_tipovariable(66,null) ;

    FUNCTION sp_buscar_tipoclase (
        pin_id_cia NUMBER,
        pin_tipcla NUMBER
    ) RETURN datatable_tipoclase
        PIPELINED;

    FUNCTION sp_buscar_tipovariable (
        pin_id_cia NUMBER,
        pin_tipvar VARCHAR2
    ) RETURN datatable_tipovariable
        PIPELINED;

END;

/
