--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_PCUENTAS_CLASE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_PCUENTAS_CLASE" BEFORE
    INSERT ON "USR_TSI_SUITE".pcuentas_clase
    FOR EACH ROW
DECLARE
    v_conteo   INTEGER := 0;
    v_vreal    CHAR(1);
    v_vstrg    CHAR(1);
    v_vchar    CHAR(1);
    v_vdate    CHAR(1);
    v_vtime    CHAR(1);
    v_ventero  CHAR(1);
BEGIN
    :new.codusercrea := :new.coduseractu;
    :new.fcreac := current_date;
    :new.factua := current_date;
    IF ( ( :new.cuenta IS NULL ) OR ( :new.cuenta = '' ) OR ( :new.clase IS NULL ) OR ( :new.clase = 0 ) ) THEN
        RAISE pkg_exceptionuser.ex_registro_key_null;
    END IF;

    BEGIN
        SELECT
            COUNT(0),
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero
        INTO
            v_conteo,
            v_vreal,
            v_vstrg,
            v_vchar,
            v_vdate,
            v_vtime,
            v_ventero
        FROM
            clase_pcuentas
        WHERE
                id_cia = :new.id_cia
            AND clase = :new.clase
        GROUP BY
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := NULL;
            v_vreal := NULL;
            v_vstrg := NULL;
            v_vchar := NULL;
            v_vdate := NULL;
            v_vtime := NULL;
            v_ventero := NULL;
    END;

    IF ( v_conteo IS NULL ) THEN
        v_conteo := 0;
    END IF;
    IF ( v_conteo = 0 ) THEN
        RAISE pkg_exceptionuser.ex_clase_pcuentas_no_existe;
    END IF;
    --VERIFICA CUANDO NO TENGA OTRA OPCION 
    IF (
                        ( upper(v_vreal) <> 'S' ) AND ( upper(v_vstrg) <> 'S' )
                    AND ( upper(v_vchar) <> 'S' )
                AND ( upper(v_vdate) <> 'S' )
            AND ( upper(v_vtime) <> 'S' )
        AND ( upper(v_ventero) <> 'S' )
    ) THEN
        v_conteo := 0;
        BEGIN
            SELECT
                COUNT(0)
            INTO v_conteo
            FROM
                clase_pcuentas_codigo
            WHERE
                    id_cia = :new.id_cia
                AND clase = :new.clase
                AND codigo = :new.codigo;

        EXCEPTION
            WHEN no_data_found THEN
                v_conteo := NULL;
        END;

        IF ( v_conteo IS NULL ) THEN
            v_conteo := 0;
            IF ( v_conteo = 0 ) THEN
                RAISE pkg_exceptionuser.ex_clase_pcuentas_codigo_no_existe;
            END IF;
        END IF;

    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_registro_key_null THEN
        raise_application_error(pkg_exceptionuser.registro_key_null, ' El registro tiene campos clave en blanco o nulo');
    WHEN pkg_exceptionuser.ex_clase_pcuentas_no_existe THEN
        raise_application_error(pkg_exceptionuser.clase_pcuentas_no_existe, 'La clase '
                                                                            || :new.clase
                                                                            || ' no existe en clase_pcuentas');
    WHEN pkg_exceptionuser.ex_clase_pcuentas_codigo_no_existe THEN
        raise_application_error(pkg_exceptionuser.clase_pcuentas_codigo_no_existe, 'El código '
                                                                                   || :new.codigo
                                                                                   || ' de Clase '
                                                                                   || :new.clase
                                                                                   || ' no existe');
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_PCUENTAS_CLASE" ENABLE;
