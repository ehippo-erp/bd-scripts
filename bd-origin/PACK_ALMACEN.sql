--------------------------------------------------------
--  DDL for Package PACK_ALMACEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ALMACEN" AS
    TYPE datarecord_ayuda IS RECORD (
        id_cia   almacen.id_cia%TYPE,
        tipinv   almacen.tipinv%TYPE,
        codalm   almacen.codalm%TYPE,
        codsuc   almacen.codsuc%TYPE,
        sucursal VARCHAR2(250),
        descri   almacen.descri%TYPE,
        abrevi   almacen.abrevi%TYPE,
        fcreac   almacen.fcreac%TYPE,
        factua   almacen.factua%TYPE,
        usuari   almacen.usuari%TYPE,
        activo   VARCHAR2(250),
        swterc   VARCHAR2(250),
        ubigeo   almacen.ubigeo%TYPE,
        direcc   almacen.direcc%TYPE,
        consigna VARCHAR2(250)
    );
    TYPE datatable_ayuda IS
        TABLE OF datarecord_ayuda;
    FUNCTION sp_ayuda (
        pin_id_cia INTEGER,
        pin_tipinv INTEGER
    ) RETURN datatable_ayuda
        PIPELINED;

END;

/
