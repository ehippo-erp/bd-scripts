--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_TLIBRO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_TLIBRO" BEFORE
    INSERT ON "USR_TSI_SUITE".TLIBRO
    FOR EACH ROW
BEGIN
    :new.fcreac := current_date;
    :new.factua := current_date;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_TLIBRO" ENABLE;
