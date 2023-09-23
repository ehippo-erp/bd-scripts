--------------------------------------------------------
--  DDL for Package PACK_TRAZABILIDAD
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_TRAZABILIDAD" IS
    TYPE datarecord IS RECORD (
        indice NUMBER,
        id_cia NUMBER,
        numint NUMBER,
        tipdoc NUMBER,
        series VARCHAR2(5),
        numdoc NUMBER,
        femisi DATE,
        codmot NUMBER,
        situac CHAR
    );
    TYPE datatable IS
        TABLE OF datarecord;
    TYPE datarecord_documento_origen IS RECORD (
        indice NUMBER,
        id_cia NUMBER,
        numint NUMBER,
        tipdoc NUMBER,
        series VARCHAR2(5),
        numdoc NUMBER,
        femisi DATE,
        codmot NUMBER,
        situac CHAR,
        tipcam documentos_cab.tipcam%TYPE,
        porigv documentos_cab.porigv%TYPE
    );
    TYPE datatable_documento_origen IS
        TABLE OF datarecord_documento_origen;
    FUNCTION sp_trazabilidad_ordpro (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_trazabilidad_fin (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_trazabilidad_finv2 (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable_documento_origen
        PIPELINED;
--105/127
    FUNCTION sp_trazabilidad_ini (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_trazabilidad (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_trazabilidadv2 (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_saca_documento_origen (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable_documento_origen
        PIPELINED;

    FUNCTION sp_saca_documento_origen2 (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable_documento_origen
        PIPELINED;

    TYPE record_tipdoc IS RECORD (
        id_cia NUMBER,
        numint NUMBER,
        tipdoc NUMBER,
        series VARCHAR2(5),
        numdoc NUMBER,
        femisi DATE,
        codmot NUMBER,
        situac CHAR
    );
    TYPE table_tipdoc IS
        TABLE OF record_tipdoc;
    FUNCTION sp_trazabilidad_tipdoc (
        pid_cia NUMBER,
        pnumint NUMBER,
        ptipdoc NUMBER
    ) RETURN table_tipdoc
        PIPELINED;

END pack_trazabilidad;

/
