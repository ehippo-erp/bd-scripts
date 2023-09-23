--------------------------------------------------------
--  DDL for Trigger DESPUES_ELIMINAR_DOCUMENTOS_DET
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_DOCUMENTOS_DET" AFTER
    DELETE ON "USR_TSI_SUITE".documentos_det
    FOR EACH ROW
BEGIN
    DELETE FROM documentos_det_clase
    WHERE
            id_cia = :old.id_cia
        AND numint = :old.numint
        AND numite = :old.numite;

  /* PARA ELIMINAR LOS MOVIMIENTOS CUANDO SE APLICAN LAS FACTURAS DE ANTICIPO*/

    IF ( upper(:old.opcargo) = 'APLI-106' ) THEN
        DELETE FROM dcta106
        WHERE
                id_cia = :old.id_cia
            AND numint = :old.opnumdoc
            AND numintap = :old.numint
            AND refere01 = :old.numite;

    END IF;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_DOCUMENTOS_DET" ENABLE;
