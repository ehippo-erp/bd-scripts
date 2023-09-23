--------------------------------------------------------
--  DDL for Trigger DESPUES_ELIMINAR_MODULO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_MODULO" AFTER
    DELETE ON "USR_TSI_SUITE".modulos
    FOR EACH ROW
BEGIN
    DELETE FROM accesos
    WHERE
        codmod = :old.codmod;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_MODULO" ENABLE;
