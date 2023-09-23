--------------------------------------------------------
--  DDL for Trigger ANTES_ELIMINAR_KARDEX
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_KARDEX" BEFORE
    DELETE ON "USR_TSI_SUITE".kardex
    FOR EACH ROW
DECLARE
    v_ingreso  NUMERIC(11, 4);
    v_salida   NUMERIC(11, 4);
    v_royoing  NUMERIC(11, 4);
    v_royosal  NUMERIC(11, 4);
    v_fecing   TIMESTAMP;
    v_fecsal   TIMESTAMP;
    v_consto   NUMBER;
    v_atipinv  NUMBER;
    v_cant     NUMBER;
BEGIN
    v_consto := 0;
    BEGIN
        SELECT
            consto
        INTO v_consto
        FROM
            articulos
        WHERE
                id_cia = :old.id_cia
            AND tipinv = :old.tipinv
            AND codart = :old.codart;

    EXCEPTION
        WHEN no_data_found THEN
            v_consto := NULL;
    END;

    IF ( v_consto IS NULL ) THEN
        v_consto := 0;
    END IF;
    IF ( v_consto > 0 ) THEN
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
                articulos_almacen
            WHERE
                    id_cia = :old.id_cia
                AND tipinv = :old.tipinv
                AND codart = :old.codart
                AND codalm = :old.codalm
                AND periodo = :old.periodo;

        EXCEPTION
            WHEN no_data_found THEN
                v_atipinv := NULL;
                v_ingreso := 0;
                v_salida := 0;
        END;

        IF ( v_salida IS NULL ) THEN
            v_salida := 0;
        END IF;
        IF ( v_ingreso IS NULL ) THEN
            v_ingreso := 0;
        END IF;
        IF ( upper(:old.id) = 'S' ) THEN
            v_salida := v_salida - :old.cantid;
        END IF;

        IF ( upper(:old.id) = 'I' ) THEN
            v_ingreso := v_ingreso - :old.cantid;
        END IF;

        IF ( v_atipinv IS NULL ) THEN
            v_cant := 0;
        ELSE
            v_cant := 1;
        END IF;

        IF ( v_cant = 0 ) THEN
            INSERT INTO articulos_almacen (id_cia,
                tipinv,
                codart,
                codalm,
                periodo,
                ingreso,
                salida
            ) VALUES (
                :old.Id_Cia,
                :old.tipinv,
                :old.codart,
                :old.codalm,
                :old.periodo,
                v_ingreso,
                v_salida
            );

        ELSE
            UPDATE articulos_almacen
            SET
                ingreso = v_ingreso,
                salida = v_salida
            WHERE
                    id_cia = :old.id_cia
                AND tipinv = :old.tipinv
                AND codart = :old.codart
                AND codalm = :old.codalm
                AND periodo = :old.periodo;

        END IF;

        IF (
            ( :old.codadd01 <> '' ) AND ( :old.codadd02 <> '' )
        ) THEN
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
                    articulos_almacen_codadd
                WHERE
                        id_cia = :old.id_cia
                    AND tipinv = :old.tipinv
                    AND codart = :old.codart
                    AND codadd01 = :old.codadd01
                    AND codadd02 = :old.codadd02
                    AND codalm = :old.codalm
                    AND periodo = :old.periodo;

            EXCEPTION
                WHEN no_data_found THEN
                    v_atipinv := NULL;
                    v_ingreso := 0;
                    v_salida := 0;
            END;

            IF ( v_atipinv IS NULL ) THEN
                v_cant := 0;
            ELSE
                v_cant := 1;
            END IF;

            IF ( v_cant = 0 ) THEN
                INSERT INTO articulos_almacen_codadd (
                    id_cia,
                    tipinv,
                    codart,
                    codadd01,
                    codadd02,
                    codalm,
                    periodo,
                    ingreso,
                    salida
                ) VALUES (
                    :old.id_cia,
                    :old.tipinv,
                    :old.codart,
                    :old.codadd01,
                    :old.codadd02,
                    :old.codalm,
                    :old.periodo,
                    v_ingreso,
                    v_salida
                );

            ELSE
                UPDATE articulos_almacen_codadd
                SET
                    ingreso = v_ingreso,
                    salida = v_salida
                WHERE
                        id_cia = :old.id_cia
                    AND tipinv = :old.tipinv
                    AND codart = :old.codart
                    AND codadd01 = :old.codadd01
                    AND codadd02 = :old.codadd02
                    AND codalm = :old.codalm
                    AND periodo = :old.periodo;

            END IF; --- (V_CANT=0)	

        END IF; ---((:OLD.CODADD01<>'')AND(:OLD.CODADD02<>''))

    END IF;-- (V_CONSTO>0) 

    IF (
        ( :old.etiqueta IS NOT NULL ) AND (LENGTH(TRIM( :old.etiqueta)) > 0) )
    THEN

    /* SOLO POR INGRESO  1 VES */
        IF ( :old.id = 'I' ) THEN
            DELETE FROM kardex000
            WHERE
                    id_cia = :old.id_cia
                AND etiqueta = :old.etiqueta
                AND locali = :old.locali;

        END IF;

        v_ingreso := NULL;
        v_salida := NULL;
        v_royoing := NULL;
        v_royosal := NULL;
        v_fecing := NULL;
        v_fecsal := NULL;
        BEGIN
            SELECT
                ingreso,
                salida,
                royoing,
                royosal
            INTO
                v_ingreso,
                v_salida,
                v_royoing,
                v_royosal
            FROM
                kardex001
            WHERE
                    id_cia = :old.id_cia
                AND tipinv = :old.tipinv
                AND codart = :old.codart
                AND codalm = :old.codalm
                AND etiqueta = :old.etiqueta;

        EXCEPTION
            WHEN no_data_found THEN
                v_ingreso := NULL;
                v_salida := NULL;
                v_royoing := NULL;
                v_royosal := NULL;
        END;

        IF ( v_salida IS NULL ) THEN
            v_salida := 0;
        END IF;
        IF ( v_ingreso IS NULL ) THEN
            v_ingreso := 0;
        END IF;
        IF ( v_royosal IS NULL ) THEN
            v_royosal := 0;
        END IF;
        IF ( v_royoing IS NULL ) THEN
            v_royoing := 0;
        END IF;
        IF ( upper(:old.id) = 'S' ) THEN
            v_salida := v_salida - :old.cantid;
            v_royosal := v_royosal - :old.royos;
/*            V_FECSAL = CURRENT_TIMESTAMP; */
        ELSE
            IF ( upper(:old.id) = 'I' ) THEN
                v_ingreso := v_ingreso - :old.cantid;
                v_royoing := v_royoing - :old.royos;
/*         V_FECING  = CURRENT_TIMESTAMP; */
            END IF;
        END IF;

        IF ( NOT (
                ( :old.id = 'I' ) AND ( :old.tipdoc = 111 )
            AND ( :old.codmot = 5 )
        ) ) THEN
            UPDATE kardex001
            SET
                ingreso = v_ingreso,
                salida = v_salida,
                royoing = v_royoing,
                royosal = v_royosal,
                swacti = (
                    CASE
                        WHEN ( ( :old.id = 'I' )
                               AND ( ( v_ingreso - v_salida ) <= cantid_ori ) )
                             OR ( ( :old.id = 'S' ) ) THEN
                            0
                        ELSE
                            swacti
                    END
                )/*2015-01-20 PARA QUE LLEVE CONTROL ETIQUETAS FINALIZADAS*/
            WHERE
                    id_cia = :old.id_cia
                AND tipinv = :old.tipinv
                AND codart = :old.codart
                AND codalm = :old.codalm
                AND etiqueta = :old.etiqueta;

        END IF;

    END IF;

END;

/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_KARDEX" ENABLE;
