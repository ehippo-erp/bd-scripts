--------------------------------------------------------
--  DDL for Package PACK_COMPR010_DOCORIGEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_COMPR010_DOCORIGEN" AS
    TYPE datarecord_compr010_docorigen IS RECORD (
        tipo    NUMBER,
        docume  NUMBER,
        item    NUMBER,
        codpro  VARCHAR2(20),
        tdocum  VARCHAR2(20),
        serie   VARCHAR2(20),
        numero  VARCHAR2(20),
        importe NUMBER(16, 2),
        femisi  DATE,
        tipcam  NUMBER(16, 4),
        impor01 NUMBER(16, 2),
        impor02 NUMBER(16, 2),
        ucreac VARCHAR2(10),
        uactua VARCHAR2(10),
        fcreac DATE,
        factua DATE
    );
    TYPE datatable_compr010_docorigen IS
        TABLE OF datarecord_compr010_docorigen;

    TYPE datarecord_relacion IS RECORD(
        ruc companias.ruc%TYPE,
        serie compr010.nserie%TYPE,
        numero compr010.numero%TYPE,
        femisi compr010.femisi%TYPE,
        importe compr010.importe%TYPE,
        tdocumori compr010_docorigen.tdocum%TYPE,
        serieori compr010_docorigen.serie%TYPE,
        numeroori  compr010_docorigen.numero%TYPE,
        femisiori compr010_docorigen.femisi%TYPE,
        importeori compr010_docorigen.importe%TYPE
    );
    TYPE datatable_relacion IS
        TABLE OF datarecord_relacion;

    TYPE datarecord_relacion_compras IS RECORD(
        ruc companias.ruc%TYPE,
        serie compr010.nserie%TYPE,
        numero compr010.numero%TYPE,
        femisi compr010.femisi%TYPE,
        importe compr010.importe%TYPE,
        tdocumori compr010_docorigen.tdocum%TYPE,
        serieori compr010_docorigen.serie%TYPE,
        numeroori  compr010_docorigen.numero%TYPE,
        femisiori compr010_docorigen.femisi%TYPE,
        importeori compr010_docorigen.importe%TYPE
    );
    TYPE datatable_relacion_compras IS
        TABLE OF datarecord_relacion_compras;


    FUNCTION sp_obtener(
        pin_id_cia NUMBER,
        pin_tipo NUMBER,
        pin_docume NUMBER,
        pin_item NUMBER
    ) RETURN datatable_compr010_docorigen
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipo NUMBER,
        pin_docume NUMBER,
        pin_item NUMBER,
        pin_tdocum VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_compr010_docorigen
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_relacion(
        pin_id_cia NUMBER,
        pin_periodo NUMBER,
        pin_mes NUMBER
    ) RETURN datatable_relacion
        PIPELINED;

    FUNCTION sp_relacion_compras(
        pin_id_cia NUMBER,
        pin_periodo NUMBER,
        pin_mes NUMBER
    ) RETURN datatable_relacion_compras
        PIPELINED;

END;

/
