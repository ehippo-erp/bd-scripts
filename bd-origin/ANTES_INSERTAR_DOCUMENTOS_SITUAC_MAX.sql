--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_DOCUMENTOS_SITUAC_MAX
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_SITUAC_MAX" BEFORE
    INSERT ON "USR_TSI_SUITE".documentos_situac_max
    FOR EACH ROW
BEGIN
    :new.factua := current_date;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_SITUAC_MAX" ENABLE;
