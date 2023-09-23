--------------------------------------------------------
--  DDL for Trigger ANTES_ELIMINAR_DOCUMENTOS_DET
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_DOCUMENTOS_DET" BEFORE
    DELETE ON "USR_TSI_SUITE".documentos_det
    FOR EACH ROW
BEGIN
    IF ( NOT ( :old.numite IS NULL ) ) THEN
        DELETE FROM documentos_stock
        WHERE
                id_cia = :old.id_cia
            AND numint = :old.numint
            AND numite = :old.numite;

        DELETE FROM documentos_det_clase
        WHERE
                id_cia = :old.id_cia
            AND numint = :old.numint
            AND numite = :old.numite;

        DELETE FROM documentos_det_imagen
        WHERE
                id_cia = :old.id_cia
            AND numint = :old.numint
            AND numite = :old.numite;

        DELETE FROM documentos_det_clieart_clase
        WHERE
                id_cia = :old.id_cia
            AND numint = :old.numint
            AND numite = :old.numite;

        DELETE FROM documentos_esp
        WHERE
                id_cia = :old.id_cia
            AND numint = :old.numint
            AND numitedet = :old.numite;

        DELETE FROM documentos_det_aprobacion
        WHERE
                id_cia = :old.id_cia
            AND numint = :old.numint
            AND numite = :old.numite;

        DELETE FROM documentos_det_relacion
        WHERE
                id_cia = :old.id_cia
            AND numint = :old.numint
            AND numite = :old.numite;

    END IF;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_DOCUMENTOS_DET" ENABLE;
