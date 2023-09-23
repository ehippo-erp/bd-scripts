--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_MOVIMIENTOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_MOVIMIENTOS" BEFORE
    UPDATE ON "USR_TSI_SUITE".movimientos
    FOR EACH ROW
DECLARE
    wconteo INTEGER;
BEGIN

    IF ( ( :new.libro IS NULL ) OR ( :new.libro = '' ) OR ( :new.libro = ' ' ) OR ( :new.libro = '  ' ) OR ( length(:new.libro) <
    2 ) ) THEN
        RAISE pkg_exceptionuser.ex_libro_en_blanco;
    END IF;

    -- ACTUALIZADO '20/02/2023' POR PROBLEMAS EN TAGA* REPORTE DE ANALITICA
    IF ( :new.tdocum IS NULL ) THEN
        :new.tdocum := ' ';
    END IF;

    IF ( :new.serie IS NULL ) THEN
        :new.serie := ' ';
    END IF;

    wconteo := 0;
    /*SELECT
        COUNT(0)
    INTO wconteo
    FROM
        movimientos_relacion
    WHERE ID_CIA = :old.ID_CIA
            AND periodo = :old.periodo
        AND mes = :old.mes
        AND libro = :old.libro
        AND asiento = :old.asiento
        AND item = :old.item
        AND sitem = :old.sitem;

    IF ( wconteo IS NULL ) THEN
        wconteo := 0;
    END IF;
    IF ( wconteo > 0 ) THEN
        RAISE pkg_exceptionuser.EX_movimiento_relacionado;
    END IF;
*/
    EXCEPTION
    WHEN pkg_exceptionuser.ex_libro_en_blanco THEN
        raise_application_error(pkg_exceptionuser.libro_en_blanco, ' El libro esta en blanco o es incorrecto');
    WHEN pkg_exceptionuser.EX_movimiento_relacionado THEN
        raise_application_error(pkg_exceptionuser.movimiento_relacionado, ' Ya existe movimiento relacionado ');        

END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_MOVIMIENTOS" ENABLE;
