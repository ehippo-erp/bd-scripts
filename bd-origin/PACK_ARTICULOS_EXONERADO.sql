--------------------------------------------------------
--  DDL for Package PACK_ARTICULOS_EXONERADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ARTICULOS_EXONERADO" AS
    TYPE datarecord_articulos_exonerado IS RECORD (
        id_cia    articulos_exonerado.id_cia%TYPE,
        codsuc    articulos_exonerado.codsuc%TYPE,
        tipinv    articulos_exonerado.tipinv%TYPE,
        codart    articulos_exonerado.codart%TYPE,
        descodsuc sucursal.sucursal%TYPE,
        destipinv t_inventario.dtipinv%TYPE,
        descodart articulos.descri%TYPE
    );
    TYPE datatable_articulos_exonerado IS
        TABLE OF datarecord_articulos_exonerado;
    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_codart IN VARCHAR2
    ) RETURN datatable_articulos_exonerado
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_codart IN VARCHAR2
    ) RETURN datatable_articulos_exonerado
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
