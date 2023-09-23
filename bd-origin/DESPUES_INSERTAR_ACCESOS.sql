--------------------------------------------------------
--  DDL for Trigger DESPUES_INSERTAR_ACCESOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_INSERTAR_ACCESOS" AFTER
    INSERT ON accesos
    FOR EACH ROW
DECLARE
    v_conteo               NUMBER;
    v_id_cia_empresa_admin NUMBER := 5;
BEGIN
    FOR j IN (
        SELECT
            cia
        FROM
            companias
    ) LOOP
        BEGIN
            SELECT
                COUNT(0)
            INTO v_conteo
            FROM
                permisos
            WHERE
                    id_cia = j.cia
                AND codmod = :new.codmod
                AND codacc = :new.codacc
                AND coduser = 'admin';

        EXCEPTION
            WHEN no_data_found THEN
                v_conteo := NULL;
        END;

        IF ( ( v_conteo IS NULL ) OR ( v_conteo = 0 ) ) THEN
            INSERT INTO permisos (
                id_cia,
                codmod,
                codacc,
                coduser
            ) VALUES (
                j.cia,
                :new.codmod,
                :new.codacc,
                'admin'
            );

        END IF;

    END LOOP;
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_INSERTAR_ACCESOS" ENABLE;
