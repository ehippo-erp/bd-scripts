--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_ARTICULOS_CLASE_ALTERNATIVO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_ARTICULOS_CLASE_ALTERNATIVO" BEFORE
    UPDATE ON "USR_TSI_SUITE".articulos_clase_alternativo
    FOR EACH ROW
DECLARE
    v_conteo   NUMBER;
    v_tipdoc   NUMBER;
    v_vreal    VARCHAR2(1);
    v_vstrg    VARCHAR2(1);
    v_vchar    VARCHAR2(1);
    v_vdate    VARCHAR2(1);
    v_vtime    VARCHAR2(1);
    v_ventero  VARCHAR2(1);
BEGIN
    :new.factua := current_date;
    IF ( ( :new.tipinv IS NULL ) OR ( :new.tipinv = 0 ) OR ( :new.codart IS NULL ) OR ( ( length(:new.codart) = 0 ) ) OR ( :new.clase
    IS NULL ) OR ( :new.clase = 0 ) OR ( :new.codigo IS NULL ) OR ( ( length(:new.codigo) = 0 ) ) ) THEN
        RAISE pkg_exceptionuser.ex_registro_key_null;
    END IF;

    v_conteo := 0;
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
            clase_articulos_alternativo
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
    END;

    IF ( v_conteo IS NULL ) THEN
        v_conteo := 0;
    END IF;
    IF ( v_conteo = 0 ) THEN
        RAISE pkg_exceptionuser.ex_clase_articulos_alternativo_no_existe;
    END IF;
    v_conteo := 0;
    IF ( ( :new.tipinv <> :old.tipinv ) OR ( :new.codart <> :old.codart ) OR ( :new.clase <> :old.clase ) OR 
    ( :new.codigo <> :old.codigo ) ) THEN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_conteo
            FROM
                articulos_clase_alternativo
            WHERE
                    id_cia = :new.id_cia
                AND tipinv = :new.tipinv
                AND codart = :new.codart
                AND clase = :new.clase
                AND codigo = :new.codigo;

        EXCEPTION
            WHEN no_data_found THEN
                v_conteo := NULL;
        END;

        IF ( v_conteo IS NULL ) THEN
            v_conteo := 0;
        END IF;
        IF ( v_conteo = 0 ) THEN
            RAISE pkg_exceptionuser.ex_registro_duplicado;
        END IF;
    END IF;

    IF ( ( :new.swacti IS NULL ) OR ( length(:new.swacti) = 0 ) OR ( upper(:new.swacti) <> 'S' ) ) THEN
        :new.swacti := 'N';
    END IF;

    :new.swacti := upper(:new.swacti);
EXCEPTION
    WHEN pkg_exceptionuser.ex_registro_key_null THEN
        raise_application_error(pkg_exceptionuser.registro_key_null, ' El registro tiene campos clave en blanco o nulo');
    WHEN pkg_exceptionuser.ex_clase_articulos_alternativo_no_existe THEN
        raise_application_error(pkg_exceptionuser.clase_articulos_alternativo_no_existe, ' El código clase no existe ');
    WHEN pkg_exceptionuser.ex_registro_duplicado THEN
        raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe ');
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_ARTICULOS_CLASE_ALTERNATIVO" ENABLE;
