--------------------------------------------------------
--  DDL for Package PACK_CERTIFICADOCAL_DET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CERTIFICADOCAL_DET" AS
--    TYPE datatable_certificadocal_det IS
--        TABLE OF certificadocal_det%rowtype;

    TYPE datarecord_certificadocal_det IS RECORD (
        id_cia   NUMBER(38),
        numint   NUMBER(38),
        numite   NUMBER(38),
        opnumint NUMBER(38),
        opnumite NUMBER(38),
        periodo  NUMBER(38),
        agrupa   NUMBER(38),
        numero   NUMBER(38),
        xml      BLOB,
        ucreac   VARCHAR2(10),
        fcreac   TIMESTAMP(6),
        uactua   VARCHAR2(10),
        factua   TIMESTAMP(6),
        uimpri   VARCHAR2(10),
        fimpri   TIMESTAMP(6),
        etiqueta VARCHAR2(100),
        tipinv   documentos_det.tipinv%TYPE,
        codart   documentos_det.codart%TYPE,
        articulo articulos.descri%TYPE,
        cantid   documentos_det.cantid%TYPE,
        largo    documentos_det.largo%TYPE
    );
    TYPE datatable_certificadocal_det IS
        TABLE OF datarecord_certificadocal_det;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_certificadocal_det
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_certificadocal_det
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_xml     IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
