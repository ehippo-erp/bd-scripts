--------------------------------------------------------
--  DDL for Package PACK_ARTICULOS_CLASE_ALTERNATIVO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ARTICULOS_CLASE_ALTERNATIVO" AS
    TYPE r_articulos_clase_alternativo IS RECORD (
    
    /*
    ID_CIA      NOT NULL NUMBER(38)   
    TIPINV      NOT NULL NUMBER(38)   
    CODART      NOT NULL VARCHAR2(40) 
    CLASE       NOT NULL NUMBER(38)   
    CODIGO      NOT NULL VARCHAR2(20) 
    VREAL                NUMBER(12,6) 
    VSTRG                VARCHAR2(30) 
    VCHAR                CHAR(1)      
    VDATE                DATE         
    VTIME                TIMESTAMP(6) 
    VENTERO              NUMBER(38)   
    CODUSERCREA          VARCHAR2(10) 
    CODUSERACTU          VARCHAR2(10) 
    FCREAC               TIMESTAMP(6) 
    FACTUA               TIMESTAMP(6) 
    ORDEN                NUMBER(38)   
    SWACTI               CHAR(1)      
    */

        id_cia       articulos_clase_alternativo.id_cia%TYPE,
        tipinv       articulos_clase_alternativo.tipinv%TYPE,
        codart       articulos_clase_alternativo.codart%TYPE,
        clase        articulos_clase_alternativo.clase%TYPE,
        desclase     Clase_Articulos_Alternativo.descri%TYPE,
        codigo       articulos_clase_alternativo.codigo%TYPE,
        descodigo    unidad.desuni%TYPE,
        vreal        articulos_clase_alternativo.vreal%TYPE,
        vstrg        articulos_clase_alternativo.vstrg%TYPE,
        vchar        articulos_clase_alternativo.vchar%TYPE,
        vdate        articulos_clase_alternativo.vdate%TYPE,
        vtime        articulos_clase_alternativo.vtime%TYPE,
        ventero      articulos_clase_alternativo.ventero%TYPE,
        codusercrea  articulos_clase_alternativo.codusercrea%TYPE,
        coduseractu  articulos_clase_alternativo.coduseractu%TYPE,
        fcreac       articulos_clase_alternativo.fcreac%TYPE,
        factua       articulos_clase_alternativo.factua%TYPE,
        orden        articulos_clase_alternativo.orden%TYPE,
        swacti       articulos_clase_alternativo.swacti%TYPE
    );
    TYPE t_articulos_clase_alternativo IS
        TABLE OF r_articulos_clase_alternativo;

    FUNCTION sp_sel_articulos_clase_alternativo (
        pin_id_cia  IN  NUMBER,
        pin_tipinv  IN  NUMBER,
        pin_codart  IN  VARCHAR2
    ) RETURN t_articulos_clase_alternativo
        PIPELINED;

    PROCEDURE sp_save_articulos_clase_alternativo (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

END;

/
