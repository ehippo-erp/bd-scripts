--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_RELACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_RELACION" AS
    TYPE datarecord_detalle_relacion IS RECORD (
        id_cia NUMBER,
        seriesre  VARCHAR(5),
        numdocre  INTEGER,
        tipdocre  INTEGER,
        numintre  INTEGER,
        numitere  INTEGER,
        tipinv    INTEGER,
        dtipinv     VARCHAR2(100),
        codart    VARCHAR(40),
        desart    VARCHAR(100),
        coduni    VARCHAR(3),
        pedido    NUMERIC(16, 5),
        cantid    NUMERIC(16, 5),
        cantidalt NUMERIC(16, 5),
        preuni    NUMERIC(16, 5),
        pordes1   NUMERIC(16, 5),
        pordes2   NUMERIC(16, 5),
        pordes3   NUMERIC(16, 5),
        pordes4   NUMERIC(16, 5),
        codadd01  VARCHAR(10),
        dcodadd01 VARCHAR(50),
        codadd02  VARCHAR(10),
        dcodadd02 VARCHAR(50)
    );
    TYPE datatable_detalle_relacion IS
        TABLE OF datarecord_detalle_relacion;
    FUNCTION sp_detalle_relacion (
        pin_id_cia  NUMBER,
        pin_numints VARCHAR2
    ) RETURN datatable_detalle_relacion
        PIPELINED;

END;

/
