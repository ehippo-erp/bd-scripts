--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_DOCUMENTOS_CAB_CLASE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_CAB_CLASE" BEFORE
    INSERT ON "USR_TSI_SUITE".documentos_cab_clase
    FOR EACH ROW
BEGIN
    :new.fcreac := current_date;
    :new.codusercrea := :new.coduseractu;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_CAB_CLASE" ENABLE;
