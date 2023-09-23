--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_CIERRE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_CIERRE" BEFORE
    UPDATE ON "USR_TSI_SUITE".cierre
    FOR EACH ROW
BEGIN
    :new.factua := current_date;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_CIERRE" ENABLE;
