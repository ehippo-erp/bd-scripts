--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_PROV100
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_PROV100" BEFORE
    INSERT ON "USR_TSI_SUITE".prov100
    FOR EACH ROW
DECLARE
    v_item NUMBER;
BEGIN
/* 2014-06-10 - revizado y cambiado por CARLOS en reunion urgente - por problemas en BOYTON */
    IF ( :new.codban IS NULL ) THEN
        :new.codban := 0;
    END IF;

    IF (
            ( :new.tipdoc IS NOT NULL ) AND ( :new.tipdoc <> '' )
        AND ( :new.tipdoc > '0' )
    ) THEN
        IF ( ( :new.cuenta IS NULL ) OR ( :new.cuenta = '' ) ) THEN
            :new.cuenta := sp000_saca_cuenta_tdocume(:new.id_cia, :new.codcli, :new.tipdoc, :new.tipmon);
        END IF;

        IF ( ( :new.dh IS NULL ) OR ( NOT ( ( upper(:new.dh) = 'D' ) OR ( upper(:new.dh) = 'H' ) ) ) ) THEN
            BEGIN
                SELECT
                    dh
                INTO :new.dh
                FROM
                    tdocume
                WHERE
                        id_cia = :new.id_cia
                    AND codigo = :new.tipdoc;

            EXCEPTION
                WHEN no_data_found THEN
                    :new.dh := NULL;
            END;

            IF ( :new.dh IS NULL ) THEN
                :new.dh := 'H';
            END IF;

        END IF;

    END IF;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_PROV100" ENABLE;
