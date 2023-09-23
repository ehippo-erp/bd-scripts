--------------------------------------------------------
--  DDL for Procedure SP_DELETE_MOVIMIENTOS_POR_ASIENTO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_DELETE_MOVIMIENTOS_POR_ASIENTO" (
    pin_id_cia    IN   INTEGER,
    pin_periodo   IN   INTEGER,
    pin_mes       IN   INTEGER,
    pin_libro     IN   VARCHAR2,
    pin_asiento   IN   INTEGER
) AS
BEGIN
    DELETE FROM movimientos
    WHERE
        id_cia = pin_id_cia
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND libro = pin_libro
        AND asiento = pin_asiento;

    COMMIT;
END;

/
