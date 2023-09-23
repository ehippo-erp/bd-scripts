--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_TLIBRO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_TLIBRO" BEFORE
    INSERT ON "USR_TSI_SUITE".TLIBRO
    FOR EACH ROW
BEGIN
    :new.factua := current_date;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_TLIBRO" ENABLE;
