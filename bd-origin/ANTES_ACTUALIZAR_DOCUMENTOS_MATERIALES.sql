--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_DOCUMENTOS_MATERIALES
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_DOCUMENTOS_MATERIALES" BEFORE
    UPDATE ON "USR_TSI_SUITE".documentos_materiales
    FOR EACH ROW
DECLARE
    v_numsec NUMBER;
BEGIN
    :new.factua := current_date;
    IF ( ( :new.swimporta IS NULL ) OR ( upper(:new.swimporta) <> 'S' ) ) THEN
        :new.swimporta := 'N';
    END IF;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_DOCUMENTOS_MATERIALES" ENABLE;
