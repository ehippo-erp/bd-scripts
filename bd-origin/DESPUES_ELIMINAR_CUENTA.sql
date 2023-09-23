--------------------------------------------------------
--  DDL for Trigger DESPUES_ELIMINAR_CUENTA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_CUENTA" AFTER
    DELETE ON "USR_TSI_SUITE".pcuentas
    FOR EACH ROW
BEGIN
    DELETE FROM ganaperdidet d
    WHERE
            d.id_cia = :old.id_cia
        AND d.cuenta = :old.cuenta;

    DELETE FROM pcuentas_clase pc
    WHERE
            pc.id_cia = :old.id_cia
        AND pc.cuenta = :old.cuenta;

    DELETE FROM cuentas_cchica cc
    WHERE
            cc.id_cia = :old.id_cia
        AND cc.cuenta = :old.cuenta;

    DELETE FROM bgeneraldet bg
    WHERE
            bg.id_cia = :old.id_cia
        AND bg.cuenta = :old.cuenta;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_CUENTA" ENABLE;
