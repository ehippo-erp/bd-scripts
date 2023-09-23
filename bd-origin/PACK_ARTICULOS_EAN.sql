--------------------------------------------------------
--  DDL for Package PACK_ARTICULOS_EAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ARTICULOS_EAN" AS
    TYPE datarecord_articulos_ean IS RECORD (
        id_cia  articulos_ean.id_cia%TYPE,
        tipinv  articulos_ean.tipinv%TYPE,
        dtipinv t_inventario.dtipinv%TYPE,
        codart  articulos_ean.codart%TYPE,
        desart  articulos.descri%TYPE,
        item    articulos_ean.item%TYPE,
        ean     articulos_ean.ean%TYPE,
        ucreac  articulos_ean.ucreac%TYPE,
        uactua  articulos_ean.uactua%TYPE,
        fcreac  articulos_ean.fcreac%TYPE,
        factua  articulos_ean.factua%TYPE
    );
    TYPE datatable_articulos_ean IS
        TABLE OF datarecord_articulos_ean;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2,
        pin_item   NUMBER
    ) RETURN datatable_articulos_ean
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2,
        pin_item   NUMBER
    ) RETURN datatable_articulos_ean
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
