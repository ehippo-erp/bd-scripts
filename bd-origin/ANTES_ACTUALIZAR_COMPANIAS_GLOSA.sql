--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_COMPANIAS_GLOSA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_COMPANIAS_GLOSA" BEFORE
    UPDATE ON "USR_TSI_SUITE"."COMPANIAS_GLOSA"
    FOR EACH ROW
BEGIN
    :new.factua := current_date;
END;

/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_COMPANIAS_GLOSA" ENABLE;
