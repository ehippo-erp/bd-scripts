--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_ENT_DEV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_ENT_DEV" AS
    TYPE datarecord_detalle_saldo IS RECORD (
        numint     NUMBER,
        numite     NUMBER,
        positi     NUMBER,
        tipinv     NUMBER,
        codart     VARCHAR2(40),
        desart     VARCHAR2(100),
        codadd01   VARCHAR2(20),
        codadd02   VARCHAR2(20),
        codund     VARCHAR2(5),
        codalm     NUMBER,
        observ     VARCHAR2(3000 CHAR),
        largo      NUMERIC(9, 3),
        ancho      NUMERIC(9, 3),
        etiqueta   VARCHAR2(100),
        lote       VARCHAR2(20),
        nrocarrete VARCHAR2(15),
        codcli     VARCHAR2(20),
        tara       NUMERIC(16, 5),
        royos      NUMERIC(16, 5),
        ubica      VARCHAR2(10),
        combina    VARCHAR2(20),
        empalme    VARCHAR2(20),
        diseno     VARCHAR2(20),
        acabado    VARCHAR2(20),
        chasis     VARCHAR2(20 CHAR),
        motor      VARCHAR2(20 CHAR),
        fvenci     DATE,
        valporisc  NUMERIC(12, 6),
        tipisc     VARCHAR2(2),
        cantid     NUMERIC(16, 5),
        preuni     NUMERIC(16, 5),
        pordes1    NUMERIC(16, 5),
        pordes2    NUMERIC(16, 5),
        pordes3    NUMERIC(16, 5),
        pordes4    NUMERIC(16, 5),
        modpre     VARCHAR2(1),
        stock      NUMERIC(16, 5)
    );
    TYPE datatable_detalle_saldo IS
        TABLE OF datarecord_detalle_saldo;
    TYPE datarecord_entrega IS RECORD (
        id_cia documentos_det.id_cia%TYPE,
        numint documentos_det.numint%TYPE,
        numite documentos_det.numite%TYPE,
        entreg documentos_det.cantid%TYPE
    );
    TYPE datatable_entrega IS
        TABLE OF datarecord_entrega;
    TYPE datarecord_saldo_documentos_det IS RECORD (
        id_cia   documentos_det.id_cia%TYPE,
        tipdoc   documentos_det.tipdoc%TYPE,
        numint   documentos_det.numint%TYPE,
        numite   documentos_det.numite%TYPE,
        tipinv   documentos_det.tipinv%TYPE,
        codart   documentos_det.codart%TYPE,
        monafe   documentos_det.monafe%TYPE,
        monina   documentos_det.monina%TYPE,
        monigv   documentos_det.monigv%TYPE,
        cantidad documentos_det.cantid%TYPE,
        entrega  documentos_det.cantid%TYPE,
        saldo    documentos_det.cantid%TYPE
    );
    TYPE datatable_saldo_documentos_det IS
        TABLE OF datarecord_saldo_documentos_det;
    PROCEDURE sp_eliminar (
        pin_id_cia    IN NUMBER,
        pin_orinumint IN NUMBER,
        pin_coduser   IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    );

    PROCEDURE sp_generar (
        pin_id_cia    IN NUMBER,
        pin_orinumint IN NUMBER,
        pin_coduser   IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    );

    FUNCTION sp_detalle_entrega (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_entrega
        PIPELINED;

    FUNCTION sp_detalle_saldo (
        pin_id_cia  NUMBER,
        pin_numints VARCHAR2
    ) RETURN datatable_detalle_saldo
        PIPELINED;

    FUNCTION sp_detalle_saldo_total (
        pin_id_cia  NUMBER,
        pin_numints VARCHAR2
    ) RETURN datatable_detalle_saldo
        PIPELINED;

    FUNCTION sp_saldo_documentos_det (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_saldo_documentos_det
        PIPELINED;

END;

/
