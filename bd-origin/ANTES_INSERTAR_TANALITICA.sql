--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_TANALITICA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_TANALITICA" BEFORE
    INSERT ON "USR_TSI_SUITE".tanalitica
    FOR EACH ROW
BEGIN
    :new.fcreac := current_date;
    :new.factua := current_date;
    IF ( ( :new.swacti IS NULL ) OR ( upper(:new.swacti) <> 'S' ) ) THEN
        :new.swacti := 'N';
    END IF;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_TANALITICA" ENABLE;
