--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_COMPANIAS_GLOSA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_COMPANIAS_GLOSA" BEFORE
    INSERT ON "USR_TSI_SUITE"."COMPANIAS_GLOSA"
    FOR EACH ROW
BEGIN
    :new.fcreac := current_date;
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_COMPANIAS_GLOSA" ENABLE;
