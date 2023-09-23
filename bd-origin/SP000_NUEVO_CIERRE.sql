--------------------------------------------------------
--  DDL for Procedure SP000_NUEVO_CIERRE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_NUEVO_CIERRE" (
    pin_id_cia   IN  NUMBER,
    pin_sistema  IN  NUMBER,
    pin_periodo  IN  NUMBER,
    pin_usuario  IN  VARCHAR2
) AS
    v_conteo NUMBER := 0;
BEGIN
    FOR nmes IN 0..12 LOOP
        BEGIN
            SELECT
                COUNT(cierre)
            INTO v_conteo
            FROM
                cierre
            WHERE
                    id_cia = pin_id_cia
                AND sistema = pin_sistema
                AND periodo = pin_periodo
                AND mes = nmes;

        EXCEPTION
            WHEN no_data_found THEN
                v_conteo := NULL;
        END;

        IF ( ( v_conteo IS NULL ) OR ( v_conteo = 0 ) ) THEN
            INSERT INTO cierre (
                id_cia,
                sistema,
                periodo,
                mes,
                cierre,
                usuario
            ) VALUES (
                pin_id_cia,
                pin_sistema,
                pin_periodo,
                nmes,
                0,
                pin_usuario
            );

        END IF;

    END LOOP;

    COMMIT;
END sp000_nuevo_cierre;

/
