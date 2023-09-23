--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_CUENTA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_CUENTA" BEFORE
    UPDATE ON "USR_TSI_SUITE".pcuentas
    FOR EACH ROW
BEGIN
    :new.factua := current_date;
    IF ( :new.situac IS NULL ) THEN
        :new.situac := 'A';
    END IF;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_CUENTA" ENABLE;
