--------------------------------------------------------
--  DDL for Package PACK_IMPORT_MASIVA_ETIQUETAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_IMPORT_MASIVA_ETIQUETAS" AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */

    TYPE r_errores IS RECORD (
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    TYPE datarecord_campos_etiqueta IS RECORD (
        tipinv      articulos.tipinv%TYPE,
        codart      articulos.codart%TYPE,
        desart      articulos.descri%TYPE,
        etiquetas   kardex000.etiqueta%TYPE,
        lote        kardex001.lote%TYPE,
        motor       kardex001.nrocarrete%TYPE,
        chasis      kardex001.acabado%TYPE,
        empalme     kardex001.empalme%TYPE,
        dam         kardex000.dam%TYPE,
        dam_item    kardex000.dam_item%TYPE,
        placa       kardex000.placa%TYPE,
        combinacion kardex001.combina%TYPE,
        ancho       kardex001.ancho%TYPE,
        largo       kardex001.largo%TYPE,
        diseno      kardex001.diseno%TYPE,
        fvenci      kardex001.fvenci%TYPE,
        fmanuf      kardex001.fmanuf%TYPE
    );
    TYPE datatable_campos_etiqueta IS
        TABLE OF datarecord_campos_etiqueta;
    FUNCTION valida_objeto (
        pin_id_cia IN NUMBER,
        --pin_series IN VARCHAR2,
        --pin_numdoc IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED;

    PROCEDURE actualiza_campos_etiqueta (
        pin_id_cia IN NUMBER,
        --pin_series IN VARCHAR2,
        --pin_numdoc IN NUMBER,
        pin_datos  IN CLOB
    );

    FUNCTION mostrar_campos_etiqueta (
        pin_id_cia IN NUMBER,
        pin_series IN VARCHAR2,
        pin_numdoc IN NUMBER
    ) RETURN datatable_campos_etiqueta
        PIPELINED;

END pack_import_masiva_etiquetas;

/
