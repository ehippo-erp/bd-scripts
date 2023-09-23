--------------------------------------------------------
--  DDL for Package PACK_MATERIALES_ESTANDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_MATERIALES_ESTANDAR" AS
--    TYPE datatable_materiales_estandar IS
--        TABLE OF materiales_estandar%rowtype;

    TYPE datarecord_materiales_estandar IS RECORD (
        id_cia          materiales_estandar.id_cia%TYPE,
        tipinvpro       materiales_estandar.tipinvpro%TYPE,
        dtipinvpro      t_inventario.dtipinv%TYPE,
        codartpro       materiales_estandar.codartpro%TYPE,
        desartpro       articulos.descri%TYPE,
        codclase        materiales_estandar.codclase%TYPE,
        codadd01pro     materiales_estandar.codadd01pro%TYPE,
        codadd02pro     materiales_estandar.codadd02pro%TYPE,
        item            materiales_estandar.item%TYPE,
        tipinvstd       materiales_estandar.tipinvstd%TYPE,
        dtipinvstd      t_inventario.dtipinv%TYPE,
        codartstd       materiales_estandar.codartstd%TYPE,
        desartstd       articulos.descri%TYPE,
        etapa           materiales_estandar.etapa%TYPE,
        etapauso        materiales_estandar.etapauso%TYPE,
        acabado         materiales_estandar.acabado%TYPE,
        largo           materiales_estandar.largo%TYPE,
        ancho           materiales_estandar.ancho%TYPE,
        factor          materiales_estandar.factor%TYPE,
        cantid          materiales_estandar.cantid%TYPE,
        glosa           materiales_estandar.glosa%TYPE,
        codaux          materiales_estandar.codaux%TYPE,
        swacti          materiales_estandar.swacti%TYPE,
        fcreac          materiales_estandar.fcreac%TYPE,
        factua          materiales_estandar.factua%TYPE,
        usuari          materiales_estandar.usuari%TYPE,
        cant_ojo        materiales_estandar.cant_ojo%TYPE,
        cant_ojo_gcable materiales_estandar.cant_ojo_gcable%TYPE,
        codadd01std     materiales_estandar.codadd01std%TYPE,
        codadd02std     materiales_estandar.codadd02std%TYPE,
        stock           NUMERIC(16, 5),
        fstock          DATE
    );
    TYPE datatable_materiales_estandar IS
        TABLE OF datarecord_materiales_estandar;
    FUNCTION sp_obtener (
        pin_id_cia      IN NUMBER,
        pin_tipinvpro   IN NUMBER,
        pin_codartpro   IN VARCHAR2,
        pin_codclase    IN VARCHAR2,
        pin_codadd01pro IN VARCHAR2,
        pin_codadd02pro IN VARCHAR2,
        pin_item        IN NUMBER
    ) RETURN datatable_materiales_estandar
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia      IN NUMBER,
        pin_tipinvpro   IN NUMBER,
        pin_codartpro   IN VARCHAR2,
        pin_codclase    IN VARCHAR2,
        pin_codadd01pro IN VARCHAR2,
        pin_codadd02pro IN VARCHAR2,
        pin_item        IN NUMBER,
        pin_tipinvstd   IN NUMBER,
        pin_codartstd   IN VARCHAR2,
        pin_etapa       IN NUMBER,
        pin_swacti      IN VARCHAR2
    ) RETURN datatable_materiales_estandar
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
