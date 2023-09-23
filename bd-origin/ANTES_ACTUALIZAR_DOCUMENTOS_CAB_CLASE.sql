--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_DOCUMENTOS_CAB_CLASE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_DOCUMENTOS_CAB_CLASE" BEFORE
    INSERT ON "USR_TSI_SUITE".documentos_cab_clase
    FOR EACH ROW
BEGIN
    :new.factua := current_date;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_DOCUMENTOS_CAB_CLASE" ENABLE;
