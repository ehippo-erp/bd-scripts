--------------------------------------------------------
--  DDL for Package PACK_IMPORT_TSI_ARTICULOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_IMPORT_TSI_ARTICULOS" AS
    TYPE datarecord_buscar IS RECORD (
        tipinv articulos.tipinv%TYPE,
        codart articulos.codart%TYPE,
        descri articulos.descri%TYPE,
        coduni articulos.coduni%TYPE,
        consto articulos.consto%TYPE,
        codprv articulos.codprv%TYPE,
        wglosa articulos.wglosa%TYPE,
        proart articulos.proart%TYPE,
        faccon articulos.faccon%TYPE,
        codbar articulos.codbar%TYPE
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    TYPE r_errores IS RECORD (
        fila     NUMBER,
        columna  VARCHAR2(80),
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_coduni VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED;

    FUNCTION valida_articulo_v2 (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED;

    PROCEDURE importa_articulos_v2 (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    );

END;

/
