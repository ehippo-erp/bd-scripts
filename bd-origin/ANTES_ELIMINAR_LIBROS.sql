--------------------------------------------------------
--  DDL for Trigger ANTES_ELIMINAR_LIBROS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_LIBROS" BEFORE
    DELETE ON "USR_TSI_SUITE".libros
    FOR EACH ROW
DECLARE
    v_conteo NUMBER;
BEGIN
    BEGIN
        SELECT
            COUNT(0)
        INTO v_conteo
        FROM
            asiendet
        WHERE
                id_cia = :old.id_cia
            AND periodo = :old.anno
            AND mes = :old.mes
            AND libro = :old.codlib;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := NULL;
    END;

    IF ( v_conteo IS NULL ) THEN
        v_conteo := 0;
    END IF;
    IF ( v_conteo > 0 ) THEN
        RAISE pkg_exceptionuser.ex_tiene_movimientos;
    END IF;
EXCEPTION
    WHEN pkg_exceptionuser.ex_tiene_movimientos THEN
        raise_application_error(pkg_exceptionuser.tiene_movimientos, 'Libro :'
                                                                     || :old.codlib
                                                                     || ' Periodo : '
                                                                     || :old.anno
                                                                     || '-'
                                                                     || :old.mes
                                                                     || ' tiene movimientos');
END;

/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_LIBROS" ENABLE;
