--------------------------------------------------------
--  DDL for Trigger ANTES_ELIMINAR_MOVIMIENTOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_MOVIMIENTOS" BEFORE
    DELETE ON "USR_TSI_SUITE".movimientos
    FOR EACH ROW
DECLARE
    wconteo NUMBER;
BEGIN
    wconteo := 0;
    BEGIN
        SELECT
            COUNT(0)
        INTO wconteo
        FROM
            movimientos_relacion
        WHERE
                id_cia = :old.id_cia
            AND periodo = :old.periodo
            AND mes = :old.mes
            AND libro = :old.libro
            AND asiento = :old.asiento
            AND item = :old.item
            AND sitem = :old.sitem;

    EXCEPTION
        WHEN no_data_found THEN
            wconteo := NULL;
    END;

    IF ( wconteo IS NULL ) THEN
        wconteo := 0;
    END IF;
    IF ( wconteo > 0 ) THEN
        RAISE pkg_exceptionuser.ex_movimiento_relacionado;
    END IF;
EXCEPTION
    WHEN pkg_exceptionuser.ex_movimiento_relacionado THEN
        raise_application_error(pkg_exceptionuser.movimiento_relacionado, ' Ya existe movimiento relacionado en :'||'libro ' ||:old.libro||' asiento '||:old.asiento||' item  '||:old.item);
END;

/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_MOVIMIENTOS" ENABLE;
