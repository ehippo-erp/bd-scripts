--------------------------------------------------------
--  DDL for Package Body PACK_ARTICULOS_COSTO_REPOSICION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ARTICULOS_COSTO_REPOSICION" AS

    PROCEDURE sp_procesar (
        pin_id_cia  IN INTEGER,
        pin_tipinv  IN INTEGER,
        pin_codart  IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_femisi   DATE;
        v_cantid   NUMBER(16, 5);
        v_costot01 NUMBER(16, 2);
        v_costot02 NUMBER(16, 2);
        v_cosuni01 NUMBER(16, 2);
        v_cosuni02 NUMBER(16, 2);
    BEGIN
        FOR i IN (
            SELECT DISTINCT
                id_cia,
                tipinv,
                codart,
                codadd01,
                codadd02,
                MAX(femisi) AS femisi,
                MAX(locali) AS locali
            FROM
                kardex
            WHERE
                    id_cia = pin_id_cia
                AND ( nvl(pin_tipinv, - 1) = - 1
                      OR tipinv = pin_tipinv )
                AND ( pin_codart IS NULL
                      OR codart = pin_codart )
                AND tipdoc = 103
                AND id = 'I'
                AND codmot IN ( 1, 28 )
                AND costot01 > 0
            GROUP BY
                id_cia,
                tipinv,
                codart,
                codadd01,
                codadd02
        ) LOOP
            SELECT
                femisi,
                cantid,
                costot01,
                costot02
            INTO
                v_femisi,
                v_cantid,
                v_costot01,
                v_costot02
            FROM
                kardex
            WHERE
                    id_cia = i.id_cia
                AND locali = i.locali;

            v_cosuni01 := 0;
            v_cosuni02 := 0;
            IF
                v_costot01 <> 0
                AND v_cantid <> 0
            THEN
                v_cosuni01 := v_costot01 / v_cantid;
            END IF;

            IF
                v_costot02 <> 0
                AND v_cantid <> 0
            THEN
                v_cosuni02 := v_costot02 / v_cantid;
            END IF;

            MERGE INTO articulos_costo_reposicion acr
            USING dual ddd ON ( acr.id_cia = i.id_cia
                                AND acr.tipinv = i.tipinv
                                AND acr.codart = i.codart
                                AND nvl(acr.codadd01, ' ') = nvl(i.codadd01, ' ')
                                AND nvl(acr.codadd02, ' ') = nvl(i.codadd02, ' ') )
            WHEN MATCHED THEN UPDATE
            SET cosuni01 = v_cosuni01,
                cosuni02 = v_cosuni02,
                fcompra = v_femisi,
                factua = current_timestamp
            WHERE
                    id_cia = i.id_cia
                AND tipinv = i.tipinv
                AND codart = i.codart
                AND nvl(codadd01, ' ') = nvl(i.codadd01, ' ')
                AND nvl(codadd02, ' ') = nvl(i.codadd02, ' ')
            WHEN NOT MATCHED THEN
            INSERT (
                id_cia,
                tipinv,
                codart,
                codadd01,
                codadd02,
                cosuni01,
                cosuni02,
                fcompra,
                fcreac,
                factua )
            VALUES
                ( i.id_cia,
                  i.tipinv,
                  i.codart,
                nvl(i.codadd01, ' '),
                nvl(i.codadd02, ' '),
                  v_cosuni01,
                  v_cosuni02,
                  v_femisi,
                  current_timestamp,
                  current_timestamp );

        END LOOP;

        FOR i IN (
            SELECT DISTINCT
                k.id_cia,
                k.tipinv,
                k.codart,
                k.codadd01,
                k.codadd02,
                MAX(k.femisi) AS femisi,
                MAX(k.locali) AS locali
            FROM
                kardex k
            WHERE
                    k.id_cia = pin_id_cia
                AND ( nvl(pin_tipinv, - 1) = - 1
                      OR k.tipinv = pin_tipinv )
                AND ( pin_codart IS NULL
                      OR k.codart = pin_codart )
                AND k.tipdoc = 111
                AND k.id = 'I'
                AND k.codmot IN ( 5 )
                AND k.costot01 > 0
                AND NOT EXISTS (
                    SELECT
                        arc.*
                    FROM
                        articulos_costo_reposicion acr
                    WHERE
                            acr.id_cia = k.id_cia
                        AND acr.tipinv = k.tipinv
                        AND acr.codart = k.codart
--                        AND nvl(acr.codadd01, ' ') = ' '
--                        AND nvl(acr.codadd02, ' ') = ' '
                )
            GROUP BY
                id_cia,
                tipinv,
                codart,
                codadd01,
                codadd02
        ) LOOP
            SELECT
                femisi,
                cantid,
                costot01,
                costot02
            INTO
                v_femisi,
                v_cantid,
                v_costot01,
                v_costot02
            FROM
                kardex
            WHERE
                    id_cia = i.id_cia
                AND locali = i.locali;

            v_cosuni01 := 0;
            v_cosuni02 := 0;
            IF
                v_costot01 <> 0
                AND v_cantid <> 0
            THEN
                v_cosuni01 := v_costot01 / v_cantid;
            END IF;

            IF
                v_costot02 <> 0
                AND v_cantid <> 0
            THEN
                v_cosuni02 := v_costot02 / v_cantid;
            END IF;

            MERGE INTO articulos_costo_reposicion acr
            USING dual ddd ON ( acr.id_cia = i.id_cia
                                AND acr.tipinv = i.tipinv
                                AND acr.codart = i.codart
                                AND nvl(acr.codadd01, ' ') = nvl(i.codadd01, ' ')
                                AND nvl(acr.codadd02, ' ') = nvl(i.codadd02, ' ') )
            WHEN MATCHED THEN UPDATE
            SET cosuni01 = v_cosuni01,
                cosuni02 = v_cosuni02,
                fcompra = v_femisi,
                factua = current_timestamp
            WHERE
                    id_cia = i.id_cia
                AND tipinv = i.tipinv
                AND codart = i.codart
                AND nvl(codadd01, ' ') = nvl(i.codadd01, ' ')
                AND nvl(codadd02, ' ') = nvl(i.codadd02, ' ')
            WHEN NOT MATCHED THEN
            INSERT (
                id_cia,
                tipinv,
                codart,
                codadd01,
                codadd02,
                cosuni01,
                cosuni02,
                fcompra,
                fcreac,
                factua )
            VALUES
                ( i.id_cia,
                  i.tipinv,
                  i.codart,
                nvl(i.codadd01, ' '),
                nvl(i.codadd02, ' '),
                  v_cosuni01,
                  v_cosuni02,
                  v_femisi,
                  current_timestamp,
                  current_timestamp );

        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_procesar;

    PROCEDURE sp_actualizar (
        pin_id_cia   IN INTEGER,
        pin_tipinv   IN INTEGER,
        pin_codart   IN VARCHAR2,
        pin_codadd01 IN VARCHAR2,
        pin_codadd02 IN VARCHAR2,
        pin_cantid   IN NUMBER,
        pin_costot01 IN NUMBER,
        pin_costot02 IN NUMBER,
        pin_femisi   IN DATE,
        pin_mensaje  OUT VARCHAR2
    ) AS
        v_compra DATE;
    BEGIN
        BEGIN
            SELECT
                acr.fcompra
            INTO v_compra
            FROM
                articulos_costo_reposicion acr
            WHERE
                    acr.id_cia = pin_id_cia
                AND acr.tipinv = pin_tipinv
                AND acr.codart = pin_codart
                AND nvl(acr.codadd01, ' ') = nvl(pin_codadd01, ' ')
                AND nvl(acr.codadd02, ' ') = nvl(pin_codadd02, ' ');

            IF pin_femisi - v_compra > 0 THEN

            -- ACTUALIZANDO COSTO DE REPOSICION
                UPDATE articulos_costo_reposicion
                SET
                    cosuni01 = round((pin_costot01 / pin_cantid), 2),
                    cosuni02 = round((pin_costot02 / pin_cantid), 2),
                    fcompra = pin_femisi,
                    factua = current_timestamp
                WHERE
                        id_cia = pin_id_cia
                    AND tipinv = pin_tipinv
                    AND codart = pin_codart
                    AND nvl(codadd01, ' ') = nvl(pin_codadd01, ' ')
                    AND nvl(codadd02, ' ') = nvl(pin_codadd02, ' ');

                COMMIT;
            END IF;

        EXCEPTION
            WHEN no_data_found THEN -- SI NO EXISTE EL ARTICULO
                INSERT INTO articulos_costo_reposicion VALUES (
                    pin_id_cia,
                    pin_tipinv,
                    pin_codart,
                    nvl(pin_codadd01, ' '),
                    nvl(pin_codadd02, ' '),
                    round((pin_costot01 / pin_cantid), 2),
                    round((pin_costot02 / pin_cantid), 2),
                    pin_femisi,
                    current_timestamp,
                    current_timestamp
                );

            WHEN OTHERS THEN
                NULL;
        END;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_actualizar;

END;

/
