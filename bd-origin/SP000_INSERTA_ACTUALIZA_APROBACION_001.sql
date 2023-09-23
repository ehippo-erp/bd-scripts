--------------------------------------------------------
--  DDL for Procedure SP000_INSERTA_ACTUALIZA_APROBACION_001
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_INSERTA_ACTUALIZA_APROBACION_001" (
    pid_cia   IN  NUMBER,
    pnumint   IN  NUMBER,
    psituac   IN  VARCHAR2,
    pcoduser  IN  VARCHAR2
) IS
    wconteo NUMBER;
BEGIN
    BEGIN
        SELECT
            COUNT(0)
        INTO wconteo
        FROM
            documentos_aprobacion
        WHERE
                id_cia = pid_cia
            AND numint = pnumint;

    EXCEPTION
        WHEN no_data_found THEN
            wconteo := 0;
    END;

    IF ( wconteo IS NULL ) THEN
        wconteo := 0;
    END IF;
    IF ( wconteo = 0 ) THEN
        INSERT INTO documentos_aprobacion (
            id_cia,
            numint,
            situac,
            ucreac,
            uactua
        ) VALUES (
            pid_cia,
            pnumint,
            psituac,
            pcoduser,
            pcoduser
        );

        COMMIT;
    ELSE
        UPDATE documentos_aprobacion
        SET
            situac = psituac,
            uactua = pcoduser
        WHERE
                id_cia = pid_cia
            AND numint = pnumint;

    END IF;

    COMMIT;
END sp000_inserta_actualiza_aprobacion_001;

/
