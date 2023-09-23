--------------------------------------------------------
--  DDL for Package PACK_HR_CONCEPTO_CLASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_CONCEPTO_CLASE" AS
    TYPE datarecord_concepto_clase IS RECORD (
        id_cia       concepto_clase.id_cia%TYPE,
        codcon       concepto_clase.codcon%TYPE,
        clase        concepto_clase.clase%TYPE,
        codigo       concepto_clase.codigo%TYPE,
        descla       clase_concepto.descri%TYPE,
        descodcla    clase_concepto_codigo.descri%TYPE,
        vstrg        concepto_clase.vstrg%TYPE,
        descri       VARCHAR2(100),
        vresult      concepto_clase.vresult%TYPE,
        vposition    concepto_clase.vposition%TYPE,
        desvposition VARCHAR2(100),
        vprefijo     VARCHAR2(100),
        vsufijo      VARCHAR2(100),
        codfor       NUMBER,
        desfor       VARCHAR2(100),
        ucreac       concepto_clase.ucreac%TYPE,
        uactua       concepto_clase.uactua%TYPE,
        fcreac       concepto_clase.fcreac%TYPE,
        factua       concepto_clase.factua%TYPE
    );
    TYPE datatable_concepto_clase IS
        TABLE OF datarecord_concepto_clase;
    TYPE datarecord_test_concepto IS RECORD (
        id_cia concepto_clase.id_cia%TYPE,
        codcon concepto_clase.codcon%TYPE,
        descon concepto.nombre%TYPE,
        rotulo VARCHAR2(100 CHAR),
        valcon NUMBER
    );
    TYPE datatable_test_concepto IS
        TABLE OF datarecord_test_concepto;
    TYPE datarecord_valor_clase_codigo IS RECORD (
        id_cia   concepto_clase.id_cia%TYPE,
        codcon   concepto_clase.codcon%TYPE,
        clase    concepto_clase.clase%TYPE,
        codigo   concepto_clase.codigo%TYPE,
        valor    VARCHAR2(20 CHAR),
        desvalor VARCHAR2(1000 CHAR)
    );
    TYPE datatable_valor_clase_codigo IS
        TABLE OF datarecord_valor_clase_codigo;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2,
        pin_clase  NUMBER,
        pin_codigo VARCHAR2
    ) RETURN datatable_concepto_clase
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2
    ) RETURN datatable_concepto_clase
        PIPELINED;

    FUNCTION sp_test_concepto (
        pin_id_cia    NUMBER,
        pin_codcon    VARCHAR2,
        pin_clase     NUMBER,
        pin_codigo    VARCHAR2,
        pin_vstrg     VARCHAR2,
        pin_vresult   VARCHAR2,
        pin_vposition VARCHAR2,
        pin_vsufijo   VARCHAR2,
        pin_vprefijo  VARCHAR2,
        pin_codfor    NUMBER
    ) RETURN datatable_test_concepto
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    TYPE array_codfor IS
        VARRAY(7) OF VARCHAR2(200) NOT NULL;
    ka_codfor array_codfor := array_codfor('ENTERO', 'DECIMAL (2)', 'DECIMAL (4)', 'DECIMAL (6)', 'PROCENTUAL',
                                          'PROCENTUAL (INV)', 'ND');
    TYPE datarecord_tipoformato IS RECORD (
        id_cia    NUMBER,
        codfor    NUMBER,
        descodfor VARCHAR2(80)
    );
    TYPE datatable_tipoformato IS
        TABLE OF datarecord_tipoformato;
    FUNCTION sp_buscar_tipoformato (
        pin_id_cia NUMBER,
        pin_codfor NUMBER
    ) RETURN datatable_tipoformato
        PIPELINED;

    FUNCTION sp_buscar_valor_clase_codigo (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2,
        pin_clase  NUMBER,
        pin_codigo VARCHAR2
    ) RETURN datatable_valor_clase_codigo
        PIPELINED;

--SELECT * FROM pack_hr_concepto_clase.sp_test_concepto(66,'303',15,'02','401','1','P','*','%',4);
--
--SELECT * FROM pack_hr_concepto_clase.sp_buscar_valor_clase_codigo(66,'303',15,'01');

END;

/
