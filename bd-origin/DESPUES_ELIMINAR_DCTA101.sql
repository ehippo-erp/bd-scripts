--------------------------------------------------------
--  DDL for Trigger DESPUES_ELIMINAR_DCTA101
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_DCTA101" AFTER
    INSERT ON "USR_TSI_SUITE".dcta101
    FOR EACH ROW
BEGIN
    IF ( :old.numint IS NOT NULL ) THEN
        sp_actualiza_saldo_dcta100(:old.id_cia,:old.numint);
    END IF;
END;

/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_DCTA101" ENABLE;
