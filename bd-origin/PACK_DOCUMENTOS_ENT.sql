--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_ENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_ENT" AS

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

    FUNCTION sp_detalle_entrega (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_entrega
        PIPELINED;

    FUNCTION sp_saldo_documentos_det (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_saldo_documentos_det
        PIPELINED;

END;

/
