--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_DOCUMENTOS_MATERIALES
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_MATERIALES" BEFORE
    INSERT ON "USR_TSI_SUITE".documentos_materiales
    FOR EACH ROW
DECLARE
    v_numsec NUMBER;
BEGIN
    :new.fcreac := current_date;
    IF ( ( :new.swimporta IS NULL ) OR ( upper(:new.swimporta) <> 'S' ) ) THEN
        :new.swimporta := 'N';
    END IF;

    IF ( ( :new.numsec IS NULL ) OR ( :new.numsec <= 0 ) ) THEN
        BEGIN
            SELECT
                trunc((MAX(numsec) / 1))
            INTO v_numsec
            FROM
                documentos_materiales
            WHERE
                    id_cia = :new.id_cia
                AND numint = :new.numint
                AND numite = :new.numite;

        EXCEPTION
            WHEN no_data_found THEN
                v_numsec := 0;
        END;

        :new.numsec := v_numsec + 1;
    END IF;

    IF ( ( :new.positi IS NULL ) OR ( :new.positi < 1 ) ) THEN
        BEGIN
            SELECT
                trunc((MAX(positi) / 1)) + 1
            INTO :new.positi
            FROM
                documentos_det
            WHERE
                    id_cia = :new.id_cia
                AND numint = :new.numint;

        EXCEPTION
            WHEN no_data_found THEN
                :new.positi := 0;
        END;
    END IF;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_MATERIALES" ENABLE;
