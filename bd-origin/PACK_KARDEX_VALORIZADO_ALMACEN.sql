--------------------------------------------------------
--  DDL for Package PACK_KARDEX_VALORIZADO_ALMACEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_KARDEX_VALORIZADO_ALMACEN" AS
    TYPE datarecord_kardex_valorizado IS RECORD (
        id_cia      NUMBER,
        tipinv      INTEGER,
        dtipinv     VARCHAR2(50),
        codfam      VARCHAR2(20),
        desfam      VARCHAR2(70),
        codlin      VARCHAR2(20),
        deslin      VARCHAR2(70),
        codart      VARCHAR2(40),
        desart      VARCHAR2(100),
        codunisunat VARCHAR2(10),
        id          VARCHAR2(1),
        tipope      VARCHAR2(50 CHAR), --TIPO DE OPERACION
        desmot      VARCHAR2(50 CHAR),
        abrmot      VARCHAR2(6),
        numint      NUMBER,
        numite      NUMBER,
        tipdoc      VARCHAR2(20), --TIPO 
        series      VARCHAR2(5),
        numdoc      NUMBER,
        femisi      DATE,
        codalm      NUMBER,
        desalm      VARCHAR2(50),
        abralm      VARCHAR2(10),
        desmon      VARCHAR2(50),
        simbolo     VARCHAR2(3),
        stockini    NUMBER(18, 2),
        cosuniini   NUMBER(18, 2),
        costotini   NUMBER(18, 2),
        caning      NUMBER(18, 2),
        cosuniing   NUMBER(18, 2),
        costoting   NUMBER(18, 2),
        cansal      NUMBER(18, 2),
        cosunisal   NUMBER(18, 2),
        costotsal   NUMBER(18, 2),
        stockfinal  NUMBER(18, 2),
        cosunifin   NUMBER(18, 2),
        costotfin   NUMBER(18, 2),
        ctatinv     VARCHAR2(16),
        desctatinv  VARCHAR2(50),
        codadd01    VARCHAR2(10),
        dcodadd01   VARCHAR2(100),
        codadd02    VARCHAR2(10),
        dcodadd02   VARCHAR2(100),
        mc46        VARCHAR2(1 CHAR)
    );
    TYPE datatable_kardex_valorizado IS
        TABLE OF datarecord_kardex_valorizado;
    FUNCTION sp_ingreso_salida (
        pin_id_cia   INTEGER,
        pin_tipinv   INTEGER,
        pin_codalm   NUMBER,
        pin_codart   VARCHAR2,
        pin_anio     INTEGER,
        pin_mes      INTEGER,
        pin_moneda   VARCHAR2,
        pin_codadd01 VARCHAR2,
        pin_codadd02 VARCHAR2
    ) RETURN datatable_kardex_valorizado
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia   INTEGER,
        pin_tipinv   INTEGER,
        pin_codalm   INTEGER,
        pin_codart   VARCHAR2,
        pin_anio     INTEGER,
        pin_mes      INTEGER,
        pin_moneda   VARCHAR2,
        pin_codadd01 VARCHAR2,
        pin_codadd02 VARCHAR2
    ) RETURN datatable_kardex_valorizado
        PIPELINED;

--SELECT * FROM pack_kardex_valorizado_almacen.sp_ingreso_salida(66,1,1,NULL,2022,12,'PEN',NULL,NULL);
--
--SELECT * FROM pack_kardex_valorizado_almacen.sp_buscar(66,1,1,NULL,2022,12,'PEN',NULL,NULL);

END;

/
