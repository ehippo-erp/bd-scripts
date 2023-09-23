--------------------------------------------------------
--  DDL for Package PACK_CF_COMPANIA_BANCO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CF_COMPANIA_BANCO" AS
    TYPE datarecord_compania_banco IS RECORD (
        id_cia NUMBER,
        codban NUMBER,
        desban e_financiera.descri%TYPE,
        tipcta NUMBER,
        descta e_financiera_tipo.descri%TYPE,
        codmon VARCHAR2(5 CHAR),
        nrocta compania_banco.nrocta%TYPE,
        observ compania_banco.observ%TYPE,
        ucreac VARCHAR2(10 CHAR),
        uactua VARCHAR2(10 CHAR),
        fcreac TIMESTAMP,
        factua TIMESTAMP
    );
    TYPE datatable_compania_banco IS
        TABLE OF datarecord_compania_banco;
    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_codban IN NUMBER,
        pin_tipcta IN NUMBER,
        pin_codmon VARCHAR2
    ) RETURN datatable_compania_banco
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER
    ) RETURN datatable_compania_banco
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
