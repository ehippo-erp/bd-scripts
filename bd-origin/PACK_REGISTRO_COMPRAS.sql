--------------------------------------------------------
--  DDL for Package PACK_REGISTRO_COMPRAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_REGISTRO_COMPRAS" AS
    FUNCTION existe_registros_relacionados_prov101 (
        pin_id_cia IN NUMBER,
        pin_tipo   IN NUMBER,
        pin_docume IN NUMBER
    ) RETURN VARCHAR2;

    PROCEDURE sp_descontabilizar (
        pin_id_cia  IN NUMBER,
        pin_tipo    IN NUMBER,
        pin_docume  IN NUMBER,
        pin_estado  OUT NUMBER,
        pin_mensaje OUT VARCHAR2
    );

END pack_registro_compras;

/
