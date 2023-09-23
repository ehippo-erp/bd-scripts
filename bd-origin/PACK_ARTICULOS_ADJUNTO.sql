--------------------------------------------------------
--  DDL for Package PACK_ARTICULOS_ADJUNTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ARTICULOS_ADJUNTO" AS
    TYPE datarecord_articulos_adjunto IS RECORD (
        id_cia  articulos_adjunto.id_cia%TYPE,
        tipinv  articulos_adjunto.tipinv%TYPE,
        dtipinv t_inventario.dtipinv%TYPE,
        codart  articulos_adjunto.codart%TYPE,
        desart  articulos.descri%TYPE,
        item    articulos_adjunto.item%TYPE,
        nombre  articulos_adjunto.nombre%TYPE,
        formato articulos_adjunto.formato%TYPE,
        archivo articulos_adjunto.archivo%TYPE,
        observ  articulos_adjunto.observ%TYPE,
        ucreac  articulos_adjunto.ucreac%TYPE,
        uactua  articulos_adjunto.uactua%TYPE,
        fcreac  articulos_adjunto.factua%TYPE,
        factua  articulos_adjunto.factua%TYPE
    );
    TYPE datatable_articulos_adjunto IS
        TABLE OF datarecord_articulos_adjunto;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2,
        pin_item   NUMBER
    ) RETURN datatable_articulos_adjunto
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2,
        pin_desart VARCHAR2,
        pin_nombre VARCHAR2
    ) RETURN datatable_articulos_adjunto
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_archivo IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
