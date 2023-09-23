--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_TDOCUME
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_TDOCUME" BEFORE
    UPDATE ON "USR_TSI_SUITE".tdocume
    FOR EACH ROW
BEGIN
    :new.factua := current_date;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_TDOCUME" ENABLE;
