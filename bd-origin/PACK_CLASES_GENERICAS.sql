--------------------------------------------------------
--  DDL for Package PACK_CLASES_GENERICAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLASES_GENERICAS" AS
    TYPE datarecord_clase_articulos_alternativo IS RECORD (
        id_cia  clase_articulos_alternativo.id_cia%TYPE,
        clase   clase_articulos_alternativo.clase%TYPE,
        descri  clase_articulos_alternativo.descri%TYPE,
        vreal   clase_articulos_alternativo.vreal%TYPE,
        vstrg   clase_articulos_alternativo.vstrg%TYPE,
        vchar   clase_articulos_alternativo.vchar%TYPE,
        vdate   clase_articulos_alternativo.vdate%TYPE,
        vtime   clase_articulos_alternativo.vtime%TYPE,
        ventero clase_articulos_alternativo.ventero%TYPE,
        swacti  clase_articulos_alternativo.swacti%TYPE,
        obliga  clase_articulos_alternativo.obliga%TYPE,
        ucreac  clase_articulos_alternativo.codusercrea%TYPE,
        uactua  clase_articulos_alternativo.coduseractu%TYPE,
        fcreac  clase_articulos_alternativo.fcreac%TYPE,
        factua  clase_articulos_alternativo.factua%TYPE
    );
    TYPE datatable_clase_articulos_alternativo IS
        TABLE OF datarecord_clase_articulos_alternativo;
    TYPE datarecord_clase_tdoccobranza IS RECORD (
        id_cia   clase_tdoccobranza.id_cia%TYPE,
        tipdoc   clase_tdoccobranza.tipdoc%TYPE,
        clase    clase_tdoccobranza.clase%TYPE,
        desclase clase_tdoccobranza.descri%TYPE,
        vreal    clase_tdoccobranza.vreal%TYPE,
        vstrg    clase_tdoccobranza.vstrg%TYPE,
        vchar    clase_tdoccobranza.vchar%TYPE,
        vdate    clase_tdoccobranza.vdate%TYPE,
        vtime    clase_tdoccobranza.vtime%TYPE,
        ventero  clase_tdoccobranza.ventero%TYPE,
        swacti   clase_tdoccobranza.swacti%TYPE,
--        obliga   clase_tdoccobranza.obliga%TYPE,
        ucreac   clase_tdoccobranza.codusercrea%TYPE,
        uactua   clase_tdoccobranza.coduseractu%TYPE,
        fcreac   clase_tdoccobranza.fcreac%TYPE,
        factua   clase_tdoccobranza.factua%TYPE
    );
    TYPE datatable_clase_tdoccobranza IS
        TABLE OF datarecord_clase_tdoccobranza;
    TYPE datarecord_clases_tdocume IS RECORD (
        id_cia   clases_tdocume.id_cia%TYPE,
        clase    clases_tdocume.clase%TYPE,
        desclase clases_tdocume.descri%TYPE,
        vreal    clases_tdocume.vreal%TYPE,
        vstrg    clases_tdocume.vstrg%TYPE,
        vchar    clases_tdocume.vchar%TYPE,
        vdate    clases_tdocume.vdate%TYPE,
        vtime    clases_tdocume.vtime%TYPE,
        ventero  clases_tdocume.ventero%TYPE,
        swacti   clases_tdocume.swacti%TYPE,
--        obliga   clases_tdocume.obliga%TYPE,
        ucreac   clases_tdocume.codusercrea%TYPE,
        uactua   clases_tdocume.coduseractu%TYPE,
        fcreac   clases_tdocume.fcreac%TYPE,
        factua   clases_tdocume.factua%TYPE
    );
    TYPE datatable_clases_tdocume IS
        TABLE OF datarecord_clases_tdocume;
    FUNCTION sp_obtener_clase_articulos_alternativo (
        pin_id_cia NUMBER,
        pin_clase  NUMBER
    ) RETURN datatable_clase_articulos_alternativo
        PIPELINED;

    FUNCTION sp_buscar_clase_articulos_alternativo (
        pin_id_cia   NUMBER,
        pin_desclase VARCHAR2
    ) RETURN datatable_clase_articulos_alternativo
        PIPELINED;

    PROCEDURE sp_save_clase_articulos_alternativo (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_obtener_clase_tdoccobranza (
        pin_id_cia NUMBER,
        pin_tipdoc NUMBER,
        pin_clase  NUMBER
    ) RETURN datatable_clase_tdoccobranza
        PIPELINED;

    FUNCTION sp_buscar_clase_tdoccobranza (
        pin_id_cia   NUMBER,
        pin_tipdoc   NUMBER,
        pin_desclase VARCHAR2
    ) RETURN datatable_clase_tdoccobranza
        PIPELINED;

    PROCEDURE sp_save_clase_tdoccobranza (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_obtener_clases_tdocume (
        pin_id_cia NUMBER,
        pin_clase  NUMBER
    ) RETURN datatable_clases_tdocume
        PIPELINED;

    FUNCTION sp_buscar_clases_tdocume (
        pin_id_cia   NUMBER,
        pin_desclase VARCHAR2
    ) RETURN datatable_clases_tdocume
        PIPELINED;

    PROCEDURE sp_save_clases_tdocume (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
