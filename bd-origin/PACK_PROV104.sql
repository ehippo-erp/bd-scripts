--------------------------------------------------------
--  DDL for Package PACK_PROV104
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_PROV104" AS
    TYPE datatable_prov104 IS
        TABLE OF prov104%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER
    ) RETURN datatable_prov104
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER
    ) RETURN datatable_prov104
        PIPELINED;

    FUNCTION sp_buscar_deposito (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER
    ) RETURN datatable_prov104
        PIPELINED;

--    PROCEDURE sp_save (
--        pin_id_cia  IN NUMBER,
--        pin_datos   IN VARCHAR2,
--        pin_opcdml  INTEGER,
--        pin_mensaje OUT VARCHAR2
--    );

END;

/
