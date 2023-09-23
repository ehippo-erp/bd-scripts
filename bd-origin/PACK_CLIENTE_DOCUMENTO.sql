--------------------------------------------------------
--  DDL for Package PACK_CLIENTE_DOCUMENTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLIENTE_DOCUMENTO" AS
    TYPE datarecord_cliente_documento IS RECORD (
        id_cia  cliente_documento.id_cia%TYPE,
        codcli  cliente_documento.codcli%TYPE,
        razonc  cliente.razonc%TYPE,
        item    cliente_documento.item%TYPE,
        desdoc  cliente_documento.desdoc%TYPE,
        archivo cliente_documento.archivo%TYPE,
        formato cliente_documento.formato%TYPE,
        ucreac  cliente_documento.ucreac%TYPE,
        uactua  cliente_documento.uactua%TYPE,
        fcreac  cliente_documento.factua%TYPE,
        factua  cliente_documento.factua%TYPE
    );
    TYPE datatable_cliente_documento IS
        TABLE OF datarecord_cliente_documento;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codcli VARCHAR2,
        pin_item   NUMBER
    ) RETURN datatable_cliente_documento
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codcli VARCHAR2,
        pin_item   NUMBER
    ) RETURN datatable_cliente_documento
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_archivo IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
