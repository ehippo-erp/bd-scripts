--------------------------------------------------------
--  DDL for Package PACK_INTEGRIDAD
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_INTEGRIDAD" AS
    PROCEDURE valid_cpago (
        pin_id_cia    IN   INTEGER,
        pin_codpag    IN   INTEGER,
        pout_mensaje  OUT  VARCHAR2
    );

    PROCEDURE valid_documento (
        pin_id_cia    IN   INTEGER,
        pin_tipdoc    IN   INTEGER,
        pin_series    IN   VARCHAR2,
        pout_mensaje  OUT  VARCHAR2
    );

END;

/
