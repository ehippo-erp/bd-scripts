--------------------------------------------------------
--  DDL for Procedure SP_COSTO_PROMEDIO_ARTICULO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_COSTO_PROMEDIO_ARTICULO" (
    pin_id_cia   IN NUMBER,
    pin_periodo  IN NUMBER,
    pin_tipinv   IN NUMBER,
    pin_codart   IN VARCHAR2,
    pout_mensaje OUT VARCHAR2
) AS

    CURSOR rec_kardex (
        v_id_cia  NUMBER,
        v_periodo NUMBER,
        v_tipinv  NUMBER,
        v_codart  VARCHAR2
    ) IS
    SELECT
        k.id_cia,
        CASE
            WHEN mc49.valor IS NULL THEN
                k.codmot
            ELSE
                CAST(mc49.valor AS INTEGER)
        END        AS worden,
        k.locali   AS locali,
        k.tipinv   AS tipinv,
        k.codart   AS codart,
        k.codalm   AS codalm,
        k.etiqueta AS etiqueta,
        k.periodo  AS periodo,
        k.id       AS id,
        k.femisi   AS femisi,
        k.costot01 AS costot01,
        k.costot02 AS costot02,
        k.cantid   AS cantid,
        m.cospro   AS cospro,
        m.costea   AS costea,
        CASE
            WHEN k.id = 'S' THEN
                - 1
            ELSE
                1
        END        AS factor,
        k.codmot   AS codmot,
        m.desmot   AS desmot,
        k.numint   AS numint,
        k.numite   AS numite,
        mc22.valor AS swdevprod,
        mc32.valor AS swhercosori,
        mc36.valor AS swmotdevventa
    FROM
             kardex k
        INNER JOIN motivos       m ON m.id_cia = k.id_cia
                                AND m.tipdoc = k.tipdoc
                                AND m.id = k.id
                                AND m.codmot = k.codmot
        LEFT OUTER JOIN motivos_clase mc22 ON mc22.id_cia = k.id_cia
                                              AND mc22.tipdoc = k.tipdoc
                                              AND mc22.id = k.id
                                              AND mc22.codmot = k.codmot
                                              AND mc22.codigo = 22  /* 22- DEVOLUCION DE PRODUCCION */
        LEFT OUTER JOIN motivos_clase mc32 ON mc32.id_cia = k.id_cia
                                              AND mc32.tipdoc = k.tipdoc
                                              AND mc32.id = k.id
                                              AND mc32.codmot = k.codmot
                                              AND mc32.codigo = 32  /* 32- HEREDA COSTO UNITARIO POR RELACION DE ITEM */
        LEFT OUTER JOIN motivos_clase mc36 ON mc36.id_cia = k.id_cia
                                              AND mc36.tipdoc = k.tipdoc
                                              AND mc36.id = k.id
                                              AND mc36.codmot = k.codmot
                                              AND mc36.codigo = 36  /* 36- ORDEN DE DEVOLUCION */
        LEFT OUTER JOIN motivos_clase mc49 ON mc49.id_cia = k.id_cia
                                              AND mc49.tipdoc = k.tipdoc
                                              AND mc49.id = k.id
                                              AND mc49.codmot = k.codmot
                                              AND mc49.codigo = 49  /* 49- ORDEN PARA PROCESO DE COSTEO */
    WHERE
            k.id_cia = v_id_cia
        AND k.periodo = v_periodo
        AND k.tipinv = v_tipinv
        AND k.codart = v_codart
        AND length(TRIM(k.codadd01)) IS NULL
        AND length(TRIM(k.codadd02)) IS NULL
    ORDER BY
        k.codart,
        k.femisi,
        k.id,
        worden,
        k.locali;

    v_aux          NUMBER;
    v_cantid       NUMBER(16, 4);
    v_costot01     NUMBER(16, 2);
    v_costot02     NUMBER(16, 2);
    ac_cantid      NUMBER(16, 4);
    ac_costot01    NUMBER(16, 2);
    ac_costot02    NUMBER(16, 2);
    kk_cantid      NUMBER(16, 4);
    kk_costot01    NUMBER(16, 2);
    kk_costot02    NUMBER(16, 2);
    kk_locali      NUMBER(16);
    k0_cantid      NUMBER(16, 4);
    k0_costot01    NUMBER(16, 2);
    k0_costot02    NUMBER(16, 2);
    k0_locali      NUMBER(16);
    v_mensaje      VARCHAR2(4000) := '';
    v_pout_mensaje VARCHAR2(4000) := '';
    v_update       VARCHAR2(1 CHAR) := 'N';
BEGIN

--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    sp_costo_promedio_articulo(66,202304,1,'Alsasol500mlG', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

--    PASO 1: ELIMINAMOS DATOS DE ARTICULOS_COSTO DEL PERIODO ACTUAL
    DELETE FROM articulos_costo
    WHERE
            id_cia = pin_id_cia
        AND periodo = pin_periodo
        AND tipinv = pin_tipinv
        AND codart = pin_codart;

    COMMIT;

--    PASO 2: INSERTAMOS REGISTROS DE ARTICULOS_COSTO DEL PERIODO ANTERIOR AL PERIODO ACTUAL
    BEGIN
        INSERT INTO articulos_costo
            SELECT
                a.id_cia,
                a.tipinv,
                a.codart,
                pin_periodo,
                a.costo01,
                a.costo02,
                a.cantid
            FROM
                articulos_costo a
            WHERE
                    a.id_cia = pin_id_cia
                AND a.tipinv = pin_tipinv
                AND a.codart = pin_codart
                AND a.periodo = pin_periodo - 1;

        COMMIT;
    END;

    BEGIN
        INSERT INTO articulos_costo
            SELECT DISTINCT
                a.id_cia,
                a.tipinv,
                a.codart,
                a.periodo,
                0.0,
                0.0,
                0.0
            FROM
                kardex a
            WHERE
                    a.id_cia = pin_id_cia
                AND a.tipinv = pin_tipinv
                AND a.codart = pin_codart
                AND a.periodo = pin_periodo
                AND length(TRIM(a.codadd01)) IS NULL
                AND length(TRIM(a.codadd02)) IS NULL
                AND NOT EXISTS (
                    SELECT
                        c.id_cia,
                        c.tipinv,
                        c.codart,
                        c.periodo,
                        0.0,
                        0.0,
                        0.0
                    FROM
                        articulos_costo c
                    WHERE
                            c.id_cia = a.id_cia
                        AND c.tipinv = a.tipinv
                        AND c.codart = a.codart
                        AND c.periodo = a.periodo
                );

        COMMIT;
    END;
   /* 1 - COSTO PROMEDIO
      2 - COSTO MIXTO   */

--    PASO3: OBTENEMOS DATOS DEL KARDEX DEL PERIODO ACTUAL
    FOR kkk IN rec_kardex(pin_id_cia, pin_periodo, pin_tipinv, pin_codart) LOOP
        v_costot01 := 0.0;
        v_costot02 := 0.0;
        v_cantid := 0.0;
        BEGIN
            BEGIN
                SELECT
                    costo01,
                    costo02,
                    cantid
                INTO
                    ac_costot01,
                    ac_costot02,
                    ac_cantid
                FROM
                    articulos_costo
                WHERE
                        id_cia = kkk.id_cia
                    AND periodo = kkk.periodo
                    AND tipinv = kkk.tipinv
                    AND codart = kkk.codart;

            EXCEPTION
                WHEN no_data_found THEN
                    ac_costot01 := 0;
                    ac_costot02 := 0;
                    ac_cantid := 0;
            END;
        END;

        --------------------------------------------------------------------------- SI SE COSTEA --------------------------------------------------------------
        v_cantid := ac_cantid + ( kkk.cantid * kkk.factor );
        v_update := 'N';
        IF -- LOS ARTICULOS DEL TIPO INVENTARIO 99, SE COSTEAN EN 0
            kkk.costea = 'S'
            AND kkk.tipinv = 99
        THEN -- REDUNDANCIA
            v_update := 'S';
            v_costot01 := 0;
            v_costot02 := 0;
            IF
                v_update = 'S'
                AND kkk.costea = 'S' -- REDUNDANCIA 
            THEN
                UPDATE kardex k
                SET
                    k.costot01 = v_costot01,
                    k.costot02 = v_costot02
                WHERE
                        k.id_cia = kkk.id_cia
                    AND k.locali = kkk.locali;

                COMMIT;
            END IF;

        ELSIF -- SOLO SI AL INICIO DEL PERIODO, NO HAY COSTO PROMEDIO DE ESE ARTICULO Y ES MOTIVO DEVOLUCION
            kkk.costea = 'S'
            AND ac_cantid = 0
            AND kkk.id = 'I'
            AND kkk.swmotdevventa = 'S'
        THEN
            BEGIN
                SELECT
                    k.costot01,
                    k.costot02,
                    k.cantid
                INTO
                    kk_costot01,
                    kk_costot02,
                    kk_cantid
                FROM
                    kardex k
                WHERE
                        k.id_cia = kkk.id_cia
                    AND k.tipinv = kkk.tipinv
                    AND k.codart = kkk.codart
                    AND k.femisi <= kkk.femisi
                    AND k.numint <> kkk.numint
                    AND k.costot01 <> 0
                ORDER BY
                    k.femisi DESC,
                    k.id ASC,
                    k.locali ASC
                FETCH NEXT 1 ROWS ONLY;

                v_update := 'S';
                v_costot01 := round((kk_costot01 / kk_cantid) * kkk.cantid, 2);
                v_costot02 := round((kk_costot02 / kk_cantid) * kkk.cantid, 2);
            EXCEPTION
                WHEN no_data_found THEN
                    v_update := 'N';
            END;

            IF
                v_update = 'S'
                AND kkk.costea = 'S' -- REDUNDANCIA 
            THEN
                UPDATE kardex k
                SET
                    k.costot01 = v_costot01,
                    k.costot02 = v_costot02
                WHERE
                        k.id_cia = kkk.id_cia
                    AND k.locali = kkk.locali;

                COMMIT;
            END IF;

        --------------------------------------------------------------------------- SI SE COSTEA --------------------------------------------------------------
        ELSIF -- SI EN EL MOMENTO DEL CALCULO ( NO CANTIDAD NI COSTO PROMEDIO DE ESE ARTICULO ) Y NO ES MOTIVO DEVOLUCION
        -- BUSCAR UN COSTO PROMEDIO ANTERIOR ( HISTORICO Y SE LE ASIGNA ESE VALOR )
        -- ENCASO NO EXISTA, NO SE ACTUALIZARA EL COSTO PROMEDIO ( Y PRODRIA GENERAR INCOSISTENCIAS ) 
        -- ( PARA EVITAR ESTO EL ARTICULO DEBE TENER UN RECORD HISTORICO EN ARTICULOS COSTO )
        -- FINALMENTE, SI SE BUSCA HEREDAR EL COSTO DE ORIGEN, CONFIGURAR COMO MOTIVO DE DEVOLUCION MT-36
            kkk.costea = 'S'
            AND ac_cantid = 0
            AND kkk.id = 'I'
        THEN
            BEGIN
                SELECT
                    k.costo01,
                    k.costo02,
                    k.cantid
                INTO
                    kk_costot01,
                    kk_costot02,
                    kk_cantid
                FROM
                    articulos_costo k
                WHERE
                        k.id_cia = kkk.id_cia
                    AND k.tipinv = kkk.tipinv
                    AND k.codart = kkk.codart
                    AND k.periodo <= kkk.periodo
                    AND k.costo01 <> 0
                    AND k.cantid <> 0
                ORDER BY
                    k.periodo DESC
                FETCH NEXT 1 ROWS ONLY;

                v_update := 'S';
                v_costot01 := round((kk_costot01 / kk_cantid) * kkk.cantid, 2);
                v_costot02 := round((kk_costot02 / kk_cantid) * kkk.cantid, 2);
            EXCEPTION
                WHEN no_data_found THEN
                    v_update := 'N';
            END;
        ELSIF
            kkk.costea = 'S'
            AND ac_cantid > 0
        THEN
            IF  -- SOLO PARA LOS INGRESOS QUE HEREDEN SU COSTO ORIGEN
                kkk.id = 'I'
                AND kkk.swhercosori = 'S'
            THEN
                SELECT
                    nvl(sp_busca_relacion_kardex(kkk.id_cia, kkk.numint, kkk.numite),
                        0)
                INTO kk_locali
                FROM
                    dual;

                IF kk_locali = 0 THEN -- NO EXISTE RELACION
                    BEGIN
                        SELECT
                            k0.cantid,
                            k0.costot01,
                            k0.costot02,
                            k0.locali
                        INTO
                            k0_cantid,
                            k0_costot01,
                            k0_costot02,
                            k0_locali
                        FROM
                            kardex000 k0
                        WHERE
                                k0.id_cia = kkk.id_cia
                            AND k0.tipinv = kkk.tipinv
                            AND k0.codart = kkk.codart
                            AND k0.etiqueta = kkk.etiqueta;

                        BEGIN
                            SELECT
                                k.cantid,
                                k.costot01,
                                k.costot02
                            INTO
                                kk_costot01,
                                kk_costot02,
                                kk_cantid
                            FROM
                                kardex k
                            WHERE
                                    k.id_cia = pin_id_cia
                                AND k.locali = k0_locali;

                            v_update := 'S';
                            v_costot01 := round((kk_costot01 / kk_cantid) * kkk.cantid, 2);
                            v_costot02 := round((kk_costot02 / kk_cantid) * kkk.cantid, 2);
                        EXCEPTION
                            WHEN no_data_found THEN
                                v_update := 'N';
                        END;

                    EXCEPTION
                        WHEN no_data_found THEN
                            BEGIN
                                SELECT
                                    CAST((d.monafe + d.monina) * CAST((
                                        CASE
                                            WHEN c.tipmon = 'PEN' THEN
                                                1.0
                                            ELSE
                                                c.tipcam
                                        END
                                    ) AS NUMERIC(16, 2)) AS NUMERIC(16,
                                         2)),
                                    CAST((d.monafe + d.monina) / CAST((
                                        CASE
                                            WHEN c.tipmon = 'PEN' THEN
                                                c.tipcam
                                            ELSE
                                                1.0
                                        END
                                    ) AS NUMERIC(16, 2)) AS NUMERIC(16,
                                         2)),
                                    d.cantid
                                INTO
                                    kk_costot01,
                                    kk_costot02,
                                    kk_cantid
                                FROM
                                    kardex         k
                                    LEFT OUTER JOIN documentos_cab c ON c.id_cia = k.id_cia
                                                                        AND c.numint = k.numint
                                    LEFT OUTER JOIN documentos_det d ON d.id_cia = k.id_cia
                                                                        AND d.numint = k.numint
                                                                        AND d.numite = k.numite
                                WHERE
                                        k.id_cia = kkk.id_cia
                                    AND k.locali = kkk.locali;

                                v_update := 'S';
                                v_costot01 := round((kk_costot01 / kk_cantid) * kkk.cantid, 2);
                                v_costot02 := round((kk_costot02 / kk_cantid) * kkk.cantid, 2);
                            EXCEPTION
                                WHEN no_data_found THEN
                                    v_update := 'N';
                            END;
                    END;

                ELSE -- SI EXISTE RELACION, UTILIZAMOS EL LOCALI
                    BEGIN
                        SELECT
                            k.cantid,
                            k.costot01,
                            k.costot02
                        INTO
                            kk_costot01,
                            kk_costot02,
                            kk_cantid
                        FROM
                            kardex k
                        WHERE
                                k.id_cia = pin_id_cia
                            AND k.locali = kk_locali
                            AND k.costot01 <> 0; -- COSTO DEBE SER DIFERENTE DE CERO
                        v_update := 'S';
                        v_costot01 := round((kk_costot01 / kk_cantid) * kkk.cantid, 2);
                        v_costot02 := round((kk_costot02 / kk_cantid) * kkk.cantid, 2);
                    EXCEPTION
                        WHEN no_data_found THEN
                            -- CONDICIONAL - MOTIVO DE ORDEN DE DEVOLUCION ( INGRESO ) - SOLO SI EL COSTO ES 0
                            IF
                                kkk.id = 'I'
                                AND kkk.swmotdevventa = 'S'
                            THEN
                                BEGIN
                                    SELECT
                                        k.costot01,
                                        k.costot02,
                                        k.cantid
                                    INTO
                                        kk_costot01,
                                        kk_costot02,
                                        kk_cantid
                                    FROM
                                        kardex k
                                    WHERE
                                            k.id_cia = kkk.id_cia
                                        AND k.tipinv = kkk.tipinv
                                        AND k.codart = kkk.codart
                                        AND k.femisi <= kkk.femisi
                                        AND k.numint <> kkk.numint
                                        AND k.costot01 <> 0
                                    ORDER BY
                                        k.femisi DESC,
                                        k.id ASC,
                                        k.locali ASC
                                    FETCH NEXT 1 ROWS ONLY;

                                    v_update := 'S';
                                    v_costot01 := round((kk_costot01 / kk_cantid) * kkk.cantid, 2);
                                    v_costot02 := round((kk_costot02 / kk_cantid) * kkk.cantid, 2);
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        v_update := 'N';
                                END;

                            ELSE
                                v_update := 'N';
                            END IF;
                    END;
                END IF;

            -- SI NO HEREDA COSTO DE ORIGEN
            -- SI EL INGRESO ES POR ORDEN DE DEVOLUCION, O EL INGRESO ES SIN COSTO
            ELSIF (
                kkk.id = 'I'
                AND kkk.swmotdevventa = 'S'
            ) OR (
                kkk.id = 'I'
                AND kkk.costot01 = 0
            ) THEN
                BEGIN
                    SELECT
                        k.costot01,
                        k.costot02,
                        k.cantid
                    INTO
                        kk_costot01,
                        kk_costot02,
                        kk_cantid
                    FROM
                        kardex k
                    WHERE
                            k.id_cia = kkk.id_cia
                        AND k.tipinv = kkk.tipinv
                        AND k.codart = kkk.codart
                        AND k.femisi <= kkk.femisi
                        AND k.numint <> kkk.numint
                        AND k.costot01 <> 0
                    ORDER BY
                        k.femisi DESC,
                        k.id ASC,
                        k.locali ASC
                    FETCH NEXT 1 ROWS ONLY;

                    v_update := 'S';
                    v_costot01 := round((kk_costot01 / kk_cantid) * kkk.cantid, 2);
                    v_costot02 := round((kk_costot02 / kk_cantid) * kkk.cantid, 2);
                EXCEPTION
                    WHEN no_data_found THEN
                        v_update := 'N';
                END;
            ELSE -- PARA TODOS LOS DEMAS CASOS - CONSIDERAMOS LOS COSTOS UNITARIO DEL ARTICULOS_COSTO
                v_update := 'S';
                v_costot01 := round((ac_costot01 / ac_cantid) * kkk.cantid, 2);
                v_costot02 := round((ac_costot02 / ac_cantid) * kkk.cantid, 2);
            END IF;

            -- SOLO SI ES POSIBLE DE ACTUALIZAR
            IF
                v_update = 'S'
                AND kkk.costea = 'S' -- REDUNDANCIA 
            THEN
                dbms_output.put_line('COSTEA : '
                                     || v_costot01
                                     || ' - '
                                     || v_costot02);
                UPDATE kardex k
                SET
                    k.costot01 = v_costot01,
                    k.costot02 = v_costot02
                WHERE
                        k.id_cia = kkk.id_cia
                    AND k.locali = kkk.locali;

                COMMIT;
            END IF;

        ELSE
        --------------------------------------------------------------------------- NO SE COSTEA --------------------------------------------------------------
        -- SI NO SE COSTEA, NO REALIZAMOS NINGUNA ACTUALIZACION, SOLO GUARDAMOS LOS COSTOS
            v_costot01 := kkk.costot01;
            v_costot02 := kkk.costot02;
        END IF;

        -- FINALMENTE ACUMULAMOS LOS COSTOS*
        UPDATE articulos_costo
        SET
            costo01 = costo01 + ( v_costot01 * kkk.factor ),
            costo02 = costo02 + ( v_costot02 * kkk.factor ),
            cantid = v_cantid
        WHERE
                id_cia = kkk.id_cia
            AND periodo = kkk.periodo
            AND tipinv = kkk.tipinv
            AND codart = kkk.codart;

        COMMIT;
    END LOOP;

    COMMIT;

    -- PROCESAMOS EL ARTICULOS ALMACEN
    sp_articulos_almacen(pin_id_cia, pin_periodo, pin_tipinv, v_mensaje);
    SELECT
        JSON_OBJECT(
            'status' VALUE 1.0,
            'message' VALUE 'El proceso se realizó satisfactoriamente'
        )
    INTO pout_mensaje
    FROM
        dual;

EXCEPTION
    WHEN pkg_exceptionuser.ex_error_inesperado THEN
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.1,
                'message' VALUE v_pout_mensaje
            )
        INTO pout_mensaje
        FROM
            dual;

    WHEN OTHERS THEN
        pout_mensaje := 'mensaje : '
                        || sqlerrm
                        || ' codigo :'
                        || sqlcode;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.2,
                'message' VALUE pout_mensaje
            )
        INTO pout_mensaje
        FROM
            dual;

END sp_costo_promedio_articulo;

/
