--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_TANALITICA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_TANALITICA" BEFORE
    UPDATE ON "USR_TSI_SUITE".tanalitica
    FOR EACH ROW
BEGIN
    :new.factua := current_date;
    IF ( ( :new.swacti IS NULL ) OR ( upper(:new.swacti) <> 'S' ) ) THEN
        :new.swacti := 'N';
    END IF;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_TANALITICA" ENABLE;
