--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_MATERIALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_MATERIALES" AS
--    TYPE datatable_documentos_materiales IS
--        TABLE OF documentos_materiales%rowtype;
    TYPE datarecord_documentos_materiales IS RECORD (
        id_cia          NUMBER(38),
        numint          NUMBER(38),
        numite          NUMBER(38),
        numsec          NUMBER(38),
        tipinv          NUMBER(38),
        codart          VARCHAR2(40),
        codalm          NUMBER(38),
        cantid          NUMBER(16, 5),
        preuni          NUMBER(16, 5),
        pordes1         NUMBER(9, 5),
        pordes2         NUMBER(9, 5),
        pordes3         NUMBER(9, 5),
        pordes4         NUMBER(9, 5),
        largo           NUMBER(9, 3),
        ancho           NUMBER(9, 3),
        altura          NUMBER(9, 3),
        etapa           NUMBER(38),
        etapauso        NUMBER(38),
        observ          VARCHAR2(1000),
        stockref        NUMBER(16, 5),
        fstockref       TIMESTAMP(6),
        situac          CHAR(1),
        usuari          VARCHAR2(10),
        fcreac          TIMESTAMP(6),
        factua          TIMESTAMP(6),
        codprv          VARCHAR2(20),
        positi          NUMBER(38),
        pedido          NUMBER(16, 5),
        cant_ojo        NUMBER(38),
        cant_ojo_gcable NUMBER(38),
        codadd01        VARCHAR2(10),
        codadd02        VARCHAR2(10),
        swimporta       VARCHAR2(1),
        pcosto          NUMBER(16, 5),
        cpordes1        NUMBER(9, 5),
        cpordes2        NUMBER(9, 5),
        cpordes3        NUMBER(9, 5),
        cpordes4        NUMBER(9, 5),
        swcompr         VARCHAR2(1),
        stock           NUMERIC(16, 5),
        fstock          DATE
    );
    TYPE datatable_documentos_materiales IS
        TABLE OF datarecord_documentos_materiales;
    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER,
        pin_numite IN NUMBER,
        pin_numsec IN NUMBER
    ) RETURN datatable_documentos_materiales
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER,
        pin_numite IN NUMBER,
        pin_numsec IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_codart IN VARCHAR2,
        pin_codalm IN NUMBER
    ) RETURN datatable_documentos_materiales
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
