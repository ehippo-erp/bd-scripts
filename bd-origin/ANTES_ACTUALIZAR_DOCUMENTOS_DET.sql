--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_DOCUMENTOS_DET
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_DOCUMENTOS_DET" BEFORE
    UPDATE ON "USR_TSI_SUITE".documentos_det
    FOR EACH ROW
BEGIN
    :new.factua := current_date;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_DOCUMENTOS_DET" ENABLE;
