--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_TPROYECTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_TPROYECTO" BEFORE
    UPDATE ON "USR_TSI_SUITE".tproyecto
    FOR EACH ROW
BEGIN
    :new.factua := current_date;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_TPROYECTO" ENABLE;
