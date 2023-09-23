--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_COMPROMETIDO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_COMPROMETIDO" BEFORE
    INSERT ON "USR_TSI_SUITE".comprometido
    FOR EACH ROW
DECLARE
    v_ingreso        NUMERIC(11, 4) := 0;
    v_salida         NUMERIC(11, 4) := 0;
    v_cant           NUMBER := 0;
    v_atipinv        NUMBER;
    v_namegenerador  VARCHAR2(60);
    v_count NUMBER;
BEGIN
    v_namegenerador := upper('GEN_COMPROMETIDO_')
                       || :new.id_cia;
    BEGIN
        SELECT
            COUNT(0)
        INTO v_count
        FROM
            user_sequences
        WHERE
            upper(sequence_name) = v_namegenerador;

    EXCEPTION
        WHEN no_data_found THEN
            v_count := 0;
    END;

    IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
        RAISE pkg_exceptionuser.ex_generador_no_existe;
    END IF;

    IF ( :new.codadd01 IS NULL ) THEN
        :new.codadd01 := ' ';
    END IF;

    IF ( :new.codadd02 IS NULL ) THEN
        :new.codadd02 := ' ';
    END IF;

    IF ( :new.cantid IS NULL ) THEN
        :new.cantid := 0;
    END IF;

    IF ( ( :new.locali IS NULL ) OR ( :new.locali < 1 ) ) THEN
        EXECUTE IMMEDIATE 'select '
                          || v_namegenerador
                          || '.NEXTVAL FROM DUAL'
        INTO v_count;
        :new.locali := v_count;
    END IF;

    BEGIN
        SELECT
            tipinv,
            ingreso,
            salida
        INTO
            v_atipinv,
            v_ingreso,
            v_salida
        FROM
            comprometido_almacen
        WHERE
                id_cia = :new.id_cia
            AND tipinv = :new.tipinv
            AND codart = :new.codart
            AND codadd01 = :new.codadd01
            AND codadd02 = :new.codadd02
            AND codalm = :new.codalm;

    EXCEPTION
        WHEN no_data_found THEN
            v_atipinv := NULL;
            v_ingreso := NULL;
            v_salida := NULL;
    END;

    IF ( v_atipinv IS NULL ) THEN
        v_cant := 0;
    ELSE
        v_cant := 1;
    END IF;

    IF ( v_salida IS NULL ) THEN
        v_salida := 0;
    END IF;
    IF ( v_ingreso IS NULL ) THEN
        v_ingreso := 0;
    END IF;
    IF ( upper(:new.id) = 'S' ) THEN
        v_salida := v_salida + :new.cantid;
    ELSE
        v_ingreso := v_ingreso + :new.cantid;
    END IF;

    IF ( v_cant = 0 ) THEN
        INSERT INTO comprometido_almacen (
            id_cia,
            tipinv,
            codart,
            codadd01,
            codadd02,
            codalm,
            ingreso,
            salida
        ) VALUES (
            :new.id_cia,
            :new.tipinv,
            :new.codart,
            :new.codadd01,
            :new.codadd02,
            :new.codalm,
            v_ingreso,
            v_salida
        );

    ELSE
        UPDATE comprometido_almacen
        SET
            ingreso = v_ingreso,
            salida = v_salida
        WHERE
                id_cia = :new.id_cia
            AND tipinv = :new.tipinv
            AND codart = :new.codart
            AND codadd01 = :new.codadd01
            AND codadd02 = :new.codadd02
            AND codalm = :new.codalm;

    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_generador_no_existe THEN
        raise_application_error(pkg_exceptionuser.generador_no_existe, 'Generador ['
                                                                       || v_namegenerador
                                                                       || '] no existe');
END;

/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_COMPROMETIDO" ENABLE;
