--------------------------------------------------------
--  DDL for Package PACK_PROCESO_DIARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_PROCESO_DIARIO" AS
    -- CADA SP DEFINIDO DEBE REGISTRAR UN LOG POR EMPRESA EN LOG_PROCESO_DIARIO
    PROCEDURE sp_update_dcta100 (
        pin_id_cia  IN NUMBER,
        pin_currval IN NUMBER
    );

    PROCEDURE sp_update_prov100 (
        pin_id_cia  IN NUMBER,
        pin_currval IN NUMBER
    );

    PROCEDURE sp_merge_licencia_resumen (
        pin_id_cia  IN NUMBER,
        pin_date    IN DATE,
        pin_currval IN NUMBER
    );

    -- AQUI DEBEN DEFINIRSE LOS SP A PROCESAR DIARIAMENTE
    PROCEDURE sp_update (
        pin_id_cia IN NUMBER
    );

END;

/
