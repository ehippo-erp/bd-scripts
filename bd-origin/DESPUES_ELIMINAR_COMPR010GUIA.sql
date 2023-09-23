--------------------------------------------------------
--  DDL for Trigger DESPUES_ELIMINAR_COMPR010GUIA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_COMPR010GUIA" AFTER
    DELETE ON "USR_TSI_SUITE".compr010guia
    FOR EACH ROW
BEGIN
    UPDATE documentos_cab
    SET
        facpro = NULL,
        ffacpro = NULL
    WHERE
            id_cia = :old.id_cia
        AND numint = :old.numint;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_COMPR010GUIA" ENABLE;
