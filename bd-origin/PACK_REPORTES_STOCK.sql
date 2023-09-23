--------------------------------------------------------
--  DDL for Package PACK_REPORTES_STOCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_REPORTES_STOCK" AS
    TYPE datarecord_etiquetas_familia_linea IS RECORD (
        id_cia     kardex.id_cia%TYPE,
        tipinv     kardex.tipinv%TYPE,
        dtipinv    t_inventario.dtipinv%TYPE,
        codalm     kardex.codalm%TYPE,
        desalm     almacen.descri%TYPE,
        codubi     kardex.ubica%TYPE,
        desubi     ubicacion.desubi%TYPE,
        codart     kardex.codart%TYPE,
        desart     articulos.descri%TYPE,
        codfam     clase_codigo.codigo%TYPE,
        desfam     clase_codigo.descri%TYPE,
        codlin     clase_codigo.codigo%TYPE,
        deslin     clase_codigo.descri%TYPE,
        codadd01   kardex001.codadd01%TYPE,
        dcoddadd01 cliente_articulos_clase.descri%TYPE,
        codadd02   kardex001.codadd02%TYPE,
        dcoddadd02 cliente_articulos_clase.descri%TYPE,
        stock      kardex001.ingreso%TYPE,
        etiquetas  NUMBER,
        codund     articulos.coduni%TYPE,
        ancho      kardex001.ancho%TYPE,
        largo      kardex001.largo%TYPE,
        codcli     kardex001.codcli%TYPE,
        razonc     cliente.razonc%TYPE,
        costot01   articulos_costo_codadd.costo01%TYPE,
        costot02   articulos_costo_codadd.costo02%TYPE,
        fecha        DATE,
        hora       VARCHAR2(20)
    );
    TYPE datatable_etiquetas_familia_linea IS
        TABLE OF datarecord_etiquetas_familia_linea;

--SELECT
--    *
--FROM
--    pack_reportes_stock.sp_etiquetas_familia_linea(66, 1, -1, -1, NULL, NULL,
--                                                   NULL, NULL, 'S');

    FUNCTION sp_etiquetas_familia_linea (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codalm NUMBER,
        pin_ubica  NUMBER,
        pin_codart VARCHAR2,
        pin_codfam VARCHAR2,
        pin_codlin VARCHAR2,
        pin_codprv VARCHAR2,
        pin_solneg VARCHAR2
    ) RETURN datatable_etiquetas_familia_linea
        PIPELINED;

END;

/
