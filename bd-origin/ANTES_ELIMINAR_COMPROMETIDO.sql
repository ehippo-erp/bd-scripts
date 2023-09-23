--------------------------------------------------------
--  DDL for Trigger ANTES_ELIMINAR_COMPROMETIDO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_COMPROMETIDO" BEFORE
    DELETE ON "USR_TSI_SUITE".comprometido
    FOR EACH ROW
DECLARE
    v_ingreso   NUMERIC(11, 4) := 0;
    v_salida    NUMERIC(11, 4) := 0;
    v_cant      NUMBER := 0;
    v_codadd01  VARCHAR2(10) := '';
    v_codadd02  VARCHAR2(10) := '';
BEGIN
    v_codadd01 := :old.codadd01;
    v_codadd02 := :old.codadd02;
    v_cant := :old.cantid;
    IF ( :old.codadd01 IS NULL ) THEN
        v_codadd01 := ' ';
    END IF;
    IF ( :old.codadd02 IS NULL ) THEN
        v_codadd02 := ' ';
    END IF;
    IF ( :old.cantid IS NULL ) THEN
        v_cant := 0;
    END IF;
    BEGIN
        SELECT
            ingreso,
            salida
        INTO
            v_ingreso,
            v_salida
        FROM
            comprometido_almacen
        WHERE
                id_cia = :old.id_cia
            AND tipinv = :old.tipinv
            AND codart = :old.codart
            AND codadd01 = v_codadd01
            AND codadd02 = v_codadd02
            AND codalm = :old.codalm;

    EXCEPTION
        WHEN no_data_found THEN
            v_ingreso := NULL;
            v_salida := NULL;
    END;

    IF ( v_salida IS NULL ) THEN
        v_salida := 0;
    END IF;
    IF ( v_ingreso IS NULL ) THEN
        v_ingreso := 0;
    END IF;
    IF ( upper(:old.id) = 'S' ) THEN
        v_salida := v_salida - v_cant;
    ELSE
        v_ingreso := v_ingreso - v_cant;
    END IF;

    UPDATE comprometido_almacen
    SET
        ingreso = v_ingreso,
        salida = v_salida
    WHERE
            id_cia = :old.id_cia
        AND tipinv = :old.tipinv
        AND codart = :old.codart
        AND codadd01 = v_codadd01
        AND codadd02 = v_codadd02
        AND codalm = :old.codalm;

END;

/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_COMPROMETIDO" ENABLE;
