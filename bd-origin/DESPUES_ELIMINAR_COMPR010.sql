--------------------------------------------------------
--  DDL for Trigger DESPUES_ELIMINAR_COMPR010
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_COMPR010" AFTER
    DELETE ON "USR_TSI_SUITE".compr010
    FOR EACH ROW
BEGIN
    DELETE FROM prov100
    WHERE
            id_cia = :old.id_cia
        AND tipo = :old.tipo
        AND docu = :old.docume;

    IF (
        ( :old.impdetrac > 0 ) AND ( :old.swafeccion = 2 )
    ) THEN
        IF ( :old.tdocum <> '02' ) THEN
            DELETE FROM prov100
            WHERE
                    id_cia = :old.id_cia
                AND tipo = 200
                AND docu = :old.docume;

        END IF;

    END IF;

    DELETE FROM compr010guia
    WHERE
            id_cia = :old.id_cia
        AND tipo = :old.tipo
        AND docume = :old.docume;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_COMPR010" ENABLE;
