--------------------------------------------------------
--  DDL for Package PACK_PROV113
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_PROV113" AS
    TYPE datarecord_prov113 IS RECORD (
        id_cia       NUMBER(38),
        libro        VARCHAR2(3),
        periodo      NUMBER(38),
        mes          NUMBER(38),
        secuencia    NUMBER(38),
        item         NUMBER(38),
        tipo         NUMBER(38),
        docu         NUMBER(38),
        tipcan       NUMBER(38),
        cuenta       VARCHAR2(16),
        dh           CHAR(1),
        tipmon       VARCHAR2(5),
        doccan       VARCHAR2(20),
        docume       VARCHAR2(25),
        tipcam       NUMBER(16, 6),
        amorti       NUMBER(16, 2),
        tcamb01      NUMBER(16, 6),
        tcamb02      NUMBER(16, 6),
        impor01      NUMBER(16, 2),
        impor02      NUMBER(16, 2),
        pagomn       NUMBER(16, 2),
        pagome       NUMBER(16, 2),
        situac       CHAR(1),
        numbco       VARCHAR2(16),
        deposito     NUMBER(16, 5),
        swchksepaga  VARCHAR2(1),
        swchkretiene VARCHAR2(1),
        concep       VARCHAR2(75),
        retcodcli    VARCHAR2(20),
        retserie     VARCHAR2(5),
        retnumero    NUMBER(38),
        swchkajuscen VARCHAR2(1),
        refere01     VARCHAR2(25),
        refere02     VARCHAR2(25),
        doc_importe  prov100.importe%TYPE,
        doc_moneda   prov100.tipmon%TYPE,
        doc_saldo    prov100.saldo%TYPE,
        doc_femisi   prov100.femisi%TYPE,
        doc_fvenci   prov100.fvenci%TYPE,
        doc_serie    prov100.serie%TYPE,
        doc_numero   prov100.numero%TYPE,
        doc_docume   prov100.docume%TYPE,
        doc_codcli   prov100.codcli%TYPE,
        doc_razonc   cliente.razonc%TYPE
    );
    TYPE datatable_prov113 IS
        TABLE OF datarecord_prov113;
    FUNCTION sp_buscar (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER
    ) RETURN datatable_prov113
        PIPELINED;

    FUNCTION sp_buscar_deposito (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER
    ) RETURN datatable_prov113
        PIPELINED;

END;

/
