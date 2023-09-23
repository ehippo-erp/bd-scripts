--------------------------------------------------------
--  DDL for Trigger DESPUES_ELIMINAR_MOVIMIENTOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_MOVIMIENTOS" AFTER
    DELETE ON "USR_TSI_SUITE".movimientos
    FOR EACH ROW
BEGIN
    DELETE FROM bancos002
    WHERE
            id_cia = :old.id_cia
        AND periodo = :old.periodo
        AND mes = :old.mes
        AND libro = :old.libro
        AND asiento = :old.asiento
        AND item = :old.item
        AND sitem = :old.sitem;

END;

/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_MOVIMIENTOS" ENABLE;
