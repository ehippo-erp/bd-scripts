--------------------------------------------------------
--  DDL for Trigger DESPUES_ELIMINAR_TLIBRO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_TLIBRO" AFTER
    DELETE ON "USR_TSI_SUITE".tlibro
    FOR EACH ROW
BEGIN
    DELETE FROM tlibros_clase
    WHERE
            id_cia = :old.id_cia
        AND codlib = :old.codlib;

    DELETE FROM libros
    WHERE
            id_cia = :old.id_cia
        AND codlib = :old.codlib;

END;

/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_TLIBRO" ENABLE;
