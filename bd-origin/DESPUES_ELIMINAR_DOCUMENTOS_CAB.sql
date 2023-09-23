--------------------------------------------------------
--  DDL for Trigger DESPUES_ELIMINAR_DOCUMENTOS_CAB
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_DOCUMENTOS_CAB" AFTER
    DELETE ON "USR_TSI_SUITE".documentos_cab
    FOR EACH ROW
BEGIN
    DELETE FROM documentos_cab_contacto
    WHERE
            id_cia = :old.id_cia
        AND numint = :old.numint;

    DELETE FROM documentos_cab_almacen
    WHERE
            id_cia = :old.id_cia
        AND numint = :old.numint;

    DELETE FROM documentos_cab_clase
    WHERE
            id_cia = :old.id_cia
        AND numint = :old.numint;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_DOCUMENTOS_CAB" ENABLE;
