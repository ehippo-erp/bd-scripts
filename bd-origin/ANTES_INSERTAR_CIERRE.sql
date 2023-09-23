--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_CIERRE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_CIERRE" BEFORE
    INSERT ON "USR_TSI_SUITE".cierre
    FOR EACH ROW
BEGIN
    :new.fcreac := current_date;
    :new.factua := current_date;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_CIERRE" ENABLE;
