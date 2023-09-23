--------------------------------------------------------
--  DDL for Package PACK_ESTRUCTURAS_CERTIFICADO_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ESTRUCTURAS_CERTIFICADO_XML" AS
    TYPE t_estructuras_certificado_xml IS
        TABLE OF estructuras_certificado_xml%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_item   NUMBER
    ) RETURN t_estructuras_certificado_xml
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_item   NUMBER,
        pin_descri VARCHAR2
    ) RETURN t_estructuras_certificado_xml
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_xml IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
