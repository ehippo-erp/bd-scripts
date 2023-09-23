--------------------------------------------------------
--  DDL for Trigger ANTES_ELIMINAR_ARTICULOS_CLASE_ALTERNATIVO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_ARTICULOS_CLASE_ALTERNATIVO" BEFORE
    DELETE ON "USR_TSI_SUITE".articulos_clase_alternativo
    FOR EACH ROW
DECLARE
    v_conteo   NUMBER := 0;
    v_conteo1  NUMBER := 0;
    v_conteo2  NUMBER := 0;
BEGIN
    IF ( ( :old.clase = 1 ) OR ( :old.clase = 2 ) ) THEN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_conteo1
            FROM
                documentos_det
            WHERE
                    id_cia = :old.id_cia
                AND tipinv = :old.tipinv
                AND codart = :old.codart
                AND codund = :old.codigo;

        EXCEPTION
            WHEN no_data_found THEN
                v_conteo1 := NULL;
        END;

        IF ( v_conteo1 IS NULL ) THEN
            v_conteo1 := 0;
        END IF;
        BEGIN
            SELECT
                COUNT(0)
            INTO v_conteo2
            FROM
                listaprecios_codund
            WHERE
                    id_cia = :old.id_cia
                AND tipinv = :old.tipinv
                AND codart = :old.codart
                AND codund = :old.codigo;

        EXCEPTION
            WHEN no_data_found THEN
                v_conteo2 := NULL;
        END;

        IF ( v_conteo2 IS NULL ) THEN
            v_conteo2 := 0;
        END IF;
    END IF;

    v_conteo := v_conteo1 + v_conteo2;
    IF ( v_conteo > 0 ) THEN
        RAISE pkg_exceptionuser.ex_registro_relacionado;
    END IF;
EXCEPTION
    WHEN pkg_exceptionuser.ex_registro_relacionado THEN
        raise_application_error(pkg_exceptionuser.registro_key_null, ' El registro ya esta relacionado');
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_ARTICULOS_CLASE_ALTERNATIVO" ENABLE;
