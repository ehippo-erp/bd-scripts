--------------------------------------------------------
--  DDL for Package PACK_KARDEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_KARDEX" AS
    TYPE rec_kardex IS RECORD (
        locali      NUMBER,
        id          VARCHAR2(3),
        tipdoc      NUMBER,
        numint      NUMBER,
        numite      NUMBER,
        periodo     NUMBER,
        codmot      NUMBER,
        femisi      DATE,
        tipinv      NUMBER,
        codart      VARCHAR2(120),
        cantid      NUMBER(16, 2),
        codalm      NUMBER,
        almdes      VARCHAR2(120),
        ingresos    NUMBER(16, 2),
        salidas     NUMBER(16, 2),
        costot01    NUMBER(16, 2),
        tcos01      NUMBER(16, 2),
        costot02    NUMBER(16, 2),
        tcos02      NUMBER(16, 2),
        fobtot01    NUMBER(16, 2),
        fobtot02    NUMBER(16, 2),
        etiqueta    VARCHAR2(120),
        opnumdoc    VARCHAR2(120),
        usuari      VARCHAR2(120),
        numdoc      NUMBER,
        series      VARCHAR2(120),
        codcli      VARCHAR2(120),
        razonc      VARCHAR2(220),
        desmot      VARCHAR2(120),
        dtipinv     VARCHAR2(120),
        desdoc      VARCHAR2(120),
        desart      VARCHAR2(120),
        ordcom      VARCHAR2(120),
        numvale     NUMBER,
        ruc         VARCHAR2(120),
        codadd01    VARCHAR2(120),
        descodadd01 VARCHAR2(120),
        codadd02    VARCHAR2(120),
        descodadd02 VARCHAR2(120),
        ubica       VARCHAR2(120),
        desubica    VARCHAR2(120),
        lote        VARCHAR2(120),
        nrocarrete  VARCHAR2(120),
        ancho       NUMBER(16, 2),
        combina     VARCHAR2(120),
        empalme     VARCHAR2(120),
        diseno      VARCHAR2(120),
        acabado     VARCHAR2(120),
        chasis  documentos_det.chasis%TYPE,
        motor documentos_det.motor%TYPE
    );
    TYPE tbl_kardex IS
        TABLE OF rec_kardex;
    FUNCTION sp_buscar_kardex_por_articulo (
        pin_id_cia     NUMBER,
        pin_tipinv     NUMBER,
        pin_codalm     NUMBER,  -- Todos los almacenes = -1
        pin_codart     VARCHAR2,
        pin_periodo    NUMBER,
        pin_mes        NUMBER,
        pin_lote          VARCHAR2,
        pin_etiqueta  VARCHAR2,
        pin_checktodos VARCHAR2 -- S = Todo el periodo, N = Periodo y mes
    ) RETURN tbl_kardex
        PIPELINED;

END pack_kardex;

/
