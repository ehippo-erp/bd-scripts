--------------------------------------------------------
--  DDL for Trigger DESPUES_INSERTAR_ARTICULOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_INSERTAR_ARTICULOS" AFTER
    INSERT ON "USR_TSI_SUITE".articulos
    FOR EACH ROW
DECLARE
    v_conteo INTEGER;
BEGIN
/* INSERTA LAS CLASES OBLIGATORIAS */
    INSERT INTO articulos_clase (
        id_cia,
        tipinv,
        codart,
        clase,
        codigo,
        situac
    )
        SELECT
            :new.id_cia,
            c.tipinv,
            :new.codart,
            c.clase,
            'ND',
            c.situac
        FROM
            clase c
        WHERE
                c.id_cia = :new.id_cia
            AND c.tipinv = :new.tipinv
            AND upper(c.obliga) = 'S'
            AND NOT ( EXISTS (
                SELECT
                    a2.clase
                FROM
                    articulos_clase a2
                WHERE
                        a2.id_cia = :new.id_cia
                    AND a2.tipinv = c.tipinv
                    AND a2.codart = :new.codart
                    AND a2.clase = c.clase
            ) );

    v_conteo := 0;
    BEGIN
        SELECT
            COUNT(0)
        INTO v_conteo
        FROM
            clase_codigo
        WHERE
                id_cia = :new.id_cia
            AND tipinv = :new.tipinv
            AND clase = 9
            AND codigo = '1';

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := NULL;
    END;

    IF ( v_conteo IS NULL ) THEN
        v_conteo := 0;
    END IF;
    IF ( v_conteo = 0 ) THEN
        RAISE pkg_exceptionuser.ex_clase_codigo_1_9_no_existe;
    END IF;
    BEGIN
/* INSERTA CLASE DE ARTICULO ACTIVO */
        SELECT
            COUNT(0)
        INTO v_conteo
        FROM
            articulos_clase
        WHERE
                id_cia = :new.id_cia
            AND tipinv = :new.tipinv
            AND codart = :new.codart
            AND clase = 9;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := NULL;
    END;

    IF ( ( v_conteo = NULL ) OR ( v_conteo = 0 ) ) THEN
        INSERT INTO articulos_clase (
            id_cia,
            tipinv,
            codart,
            clase,
            codigo,
            situac
        ) VALUES (
            :new.id_cia,
            :new.tipinv,
            :new.codart,
            9,
            '1',
            'S'
        );

    ELSE
        UPDATE articulos_clase
        SET
            codigo = '1',
            situac = 'S'
        WHERE
                id_cia = :new.id_cia
            AND tipinv = :new.tipinv
            AND codart = :new.codart
            AND clase = 9;

    END IF;
/* INSERTA LAS CLASES GLOBALES OBLIGATORIAS */

    INSERT INTO articulos_clase_global (
        id_cia,
        tipinv,
        codart,
        clase,
        codigo,
        situac
    )
        SELECT
            :new.id_cia,
            :new.tipinv,
            :new.codart,
            c.clase,
            'ND',
            c.situac
        FROM
            clase_global c
        WHERE
                id_cia = :new.id_cia
            AND upper(c.obliga) = 'S'
            AND NOT ( EXISTS (
                SELECT
                    a2.clase
                FROM
                    articulos_clase_global a2
                WHERE
                        a2.id_cia = :new.id_cia
                    AND a2.tipinv = :new.tipinv
                    AND a2.codart = :new.codart
                    AND a2.clase = c.clase
            ) );

    IF :new.tipinv = 100 THEN
        INSERT INTO articulo_especificacion
            ( SELECT
                :new.id_cia,
                :new.tipinv,
                :new.codart,
                e.codesp,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL
            FROM
                especificaciones e
            WHERE
                e.id_cia = :new.id_cia
                AND tipinv = :new.tipinv
                AND e.swacti = 'S'
            );

    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_clase_codigo_1_9_no_existe THEN
        raise_application_error(pkg_exceptionuser.clase_codigo_1_9_no_existe, ' Código con valor 1 no existe en Clase_Codigo con valor 9');
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_INSERTAR_ARTICULOS" ENABLE;
