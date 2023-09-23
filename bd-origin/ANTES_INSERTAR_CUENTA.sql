--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_CUENTA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_CUENTA" BEFORE
    INSERT ON "USR_TSI_SUITE".pcuentas
    FOR EACH ROW
BEGIN
    :new.fcreac := current_date;
    :new.factua := current_date;
    IF ( :new.situac IS NULL ) THEN
        :new.situac := 'A';
    END IF;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_CUENTA" ENABLE;
