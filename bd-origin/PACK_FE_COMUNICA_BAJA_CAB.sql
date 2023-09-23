--------------------------------------------------------
--  DDL for Package PACK_FE_COMUNICA_BAJA_CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_FE_COMUNICA_BAJA_CAB" AS
    TYPE t_fe_comunica_baja_cab IS
        TABLE OF fe_comunica_baja_cab%rowtype;

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_idbaj  IN NUMBER
    ) RETURN t_fe_comunica_baja_cab
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia    IN NUMBER,
        pin_estado    IN VARCHAR2,
        pin_tipo      IN NUMBER,
        pin_fgdesde   IN DATE,
        pin_fghasta   IN DATE,
        pin_fedesde   IN DATE,
        pin_fehasta   IN DATE,
        pin_fgentodos IN VARCHAR2,
        pin_femitodos IN VARCHAR2
    ) RETURN t_fe_comunica_baja_cab
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
