--------------------------------------------------------
--  DDL for Procedure SP_ENVIAR_KARDEX
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ENVIAR_KARDEX" (
    pin_id_cia  IN  NUMBER,
    pin_numint  IN  NUMBER
) AS

    v_f349       VARCHAR2(20) := '';
    v_tipdoc     INTEGER := 0;
    v_id         VARCHAR2(1) := '';
    v_almdes1    SMALLINT := 0;
    v_almdes2    SMALLINT := 0;
    v_costea     VARCHAR2(1) := '';
    v_costocero  VARCHAR2(20) := '';
    v_clase6     SMALLINT := 0;
    v_conteo     SMALLINT := 0;
    v_costot01   NUMERIC(16, 2) := 0;
    v_costot02   NUMERIC(16, 2) := 0;
    v_cantid2    NUMERIC(16, 4);
    v_sid        VARCHAR2(1) := '';
    scodalm      INTEGER := 0;
    v_clase55    VARCHAR(10) := '';
    v_codalm     INTEGER := 0;
BEGIN
    DELETE FROM kardex
    WHERE
            id_cia = pin_id_cia
        AND numint = pin_numint;

    BEGIN
        SELECT
            vstrg
        INTO v_f349
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 349; /*349-Obliga asignar ubicación en guias de ingreso*/

    EXCEPTION
        WHEN no_data_found THEN
            v_f349 := NULL;
    END;

    IF ( v_f349 IS NULL ) THEN
        v_f349 := 'N';
    END IF;
    BEGIN
        SELECT
            c.tipdoc,
            c.id,
            c.almdes     AS almdes1,
            (
                CASE
                    WHEN m6.valor = '' THEN
                        0
                    ELSE
                        CAST(m6.valor AS SMALLINT)
                END
            ) AS almdes2,
            m.costea,
            m47.valor    AS costocero,
            m6.codigo    AS clase6,
            m55.valor    AS clase55
        INTO
            v_tipdoc,
            v_id,
            v_almdes1,
            v_almdes2,
            v_costea,
            v_costocero,
            v_clase6,
            v_clase55
        FROM
            documentos_cab  c
            LEFT OUTER JOIN motivos         m ON m.id_cia = c.id_cia
                                         AND m.tipdoc = c.tipdoc
                                         AND m.id = c.id
                                         AND m.codmot = c.codmot
            LEFT OUTER JOIN motivos_clase   m6 ON m6.id_cia = c.id_cia
                                                AND m6.tipdoc = c.tipdoc
                                                AND m6.id = c.id
                                                AND m6.codmot = c.codmot
                                                AND m6.codigo = 6
            LEFT OUTER JOIN motivos_clase   m47 ON m47.id_cia = c.id_cia
                                                 AND m47.tipdoc = c.tipdoc
                                                 AND m47.id = c.id
                                                 AND m47.codmot = c.codmot
                                                 AND m47.codigo = 47
            LEFT OUTER JOIN motivos_clase   m55 ON m55.id_cia = c.id_cia
                                                 AND m55.tipdoc = c.tipdoc
                                                 AND m55.id = c.id
                                                 AND m55.codmot = c.codmot
                                                 AND m55.codigo = 55
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint;

    EXCEPTION
        WHEN no_data_found THEN
            v_tipdoc := NULL;
            v_id := NULL;
            v_almdes1 := NULL;
            v_almdes2 := NULL;
            v_costea := NULL;
            v_costocero := NULL;
            v_clase6 := NULL;
            v_clase55 := NULL;
    END;

    IF v_tipdoc IS NULL THEN
        v_tipdoc := 0;
    END IF;
    IF v_id IS NULL THEN
        v_id := '';
    END IF;
    IF v_almdes1 IS NULL THEN
        v_almdes1 := 0;
    END IF;
    IF v_almdes2 IS NULL THEN
        v_almdes2 := 0;
    END IF;
    IF v_costea IS NULL THEN
        v_costea := '';
    END IF;
    IF v_costocero IS NULL THEN
        v_costocero := '';
    END IF;
    IF v_clase6 IS NULL THEN
        v_clase6 := 0;
    END IF;
    IF (
            ( v_tipdoc = 103 ) AND ( v_id = 'I' )
        AND ( v_f349 = 'S' )
    ) THEN
        BEGIN
            SELECT
                SUM(
                    CASE
                        WHEN(al.codigo IS NULL) THEN
                            1
                        ELSE
                            0
                    END
                ) AS sw
            INTO v_conteo
            FROM
                documentos_det     d
                LEFT OUTER JOIN almacen_ubicacion  al ON al.id_cia = pin_id_cia
                                                        AND al.tipinv = d.tipinv
                                                        AND al.codalm = d.codalm
                                                        AND al.codigo = d.ubica
            WHERE
                    d.id_cia = pin_id_cia
                AND d.numint = pin_numint
                AND d.etiqueta <> '';

        EXCEPTION
            WHEN no_data_found THEN
                v_conteo := NULL;
        END;

        IF ( v_conteo IS NULL ) THEN
            v_conteo := 0;
        END IF;
        IF ( v_conteo > 0 ) THEN
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;
    END IF;

    FOR i IN (
        SELECT
            - 1                                                                             AS locali,
            d.tipdoc,
            d.numint,
            d.numite,
            ( EXTRACT(YEAR FROM c.femisi) * 100 ) + EXTRACT(MONTH FROM c.femisi)            AS periodo,
            c.codmot,
            c.femisi,
            d.tipinv,
            d.codart,
            (
                CASE
                    WHEN a.coduni <> d.codund
                         AND ca1.vreal IS NOT NULL THEN
                        ca1.vreal
                    ELSE
                        1
                END
                * d.cantid ) AS cantid,
            CAST(
                CASE
                    WHEN c.tipmon = 'PEN' THEN
                        1.00
                    ELSE
                        c.tipcam
                END
            AS DOUBLE PRECISION) * ( d.monafe + d.monina + d.monexo ) AS costot01,
            ( d.monafe + d.monina + d.monexo ) / CAST(
                CASE
                    WHEN c.tipmon = 'PEN' THEN
                        c.tipcam
                    ELSE
                        1.00
                END
            AS DOUBLE PRECISION) AS costot02,
            d.codalm,
            c.tipcam,
            d.opronumdoc                                                                    AS opnumdoc,
            d.optipinv,
            d.nrotramo                                                                      AS optramo,
            d.etiqueta,
            c.codcli,
            d.royos,
            d.ubica,
            d.swacti,
            d.codadd01,
            d.codadd02,
            d.numintpre,
            d.numitepre
        FROM
            documentos_det               d
            LEFT JOIN articulos                    a ON a.id_cia = d.id_cia
                                     AND a.tipinv = d.tipinv
                                     AND a.codart = d.codart
            LEFT OUTER JOIN documentos_cab               c ON c.id_cia = d.id_cia
                                                AND c.numint = d.numint
            LEFT OUTER JOIN articulos_clase_alternativo  ca1 ON ca1.id_cia = d.id_cia
                                                               AND ca1.tipinv = d.tipinv
                                                               AND ca1.codart = d.codart
                                                               AND ca1.clase =
                CASE
                    WHEN d.tipdoc IN (
                        1,
                        3,
                        7,
                        8,
                        100,
                        101,
                        102,
                        210
                    ) THEN
                        1
                    ELSE
                        CASE
                            WHEN ( c.tipdoc = 103
                                   AND c.codmot IN (
                                1,
                                28
                            )
                                   AND c.id = 'I' ) THEN
                                2
                            ELSE
                                0
                        END
                END
                                                               AND ca1.codigo = d.codund
        WHERE
                d.id_cia = pin_id_cia
            AND ( d.numint = pin_numint )
            AND ( (
                CASE
                    WHEN a.coduni <> d.codund
                         AND ca1.vreal IS NOT NULL THEN
                        ca1.vreal
                    ELSE
                        1
                END
                * d.cantid ) <> 0 )
            AND ( trunc(a.consto) >= 0 )
    ) LOOP
        v_costot01 := i.costot01;
        v_costot02 := i.costot02;
        IF ( trim(v_costocero) = 'S' ) THEN
            v_costot01 := 0;
            v_costot02 := 0;
        ELSE
            IF (
                ( v_costea = 'S' ) AND ( i.cantid <> 0 )
            ) THEN
                IF (
                    ( i.codadd01 <> '' ) AND ( i.codadd02 <> '' )
                ) THEN
                    BEGIN
                        SELECT
                            costo01,
                            costo02,
                            cantid
                        INTO
                            v_costot01,
                            v_costot02,
                            v_cantid2
                        FROM
                            articulos_costo_codadd
                        WHERE
                                id_cia = pin_id_cia
                            AND tipinv = i.tipinv
                            AND codart = i.codart
                            AND codadd01 = i.codadd01
                            AND codadd02 = i.codadd02
                            AND periodo BETWEEN EXTRACT(YEAR FROM current_date) * 100 AND i.periodo
                            AND cantid <> 0
                            AND costo01 <> 0
                        ORDER BY
                            periodo DESC
                        FETCH FIRST 1 ROW ONLY;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_costot01 := NULL;
                            v_costot02 := NULL;
                            v_cantid2 := NULL;
                    END;

                    IF v_costot01 IS NULL THEN
                        v_costot01 := 0;
                    END IF;
                    IF v_costot02 IS NULL THEN
                        v_costot02 := 0;
                    END IF;
                    IF v_cantid2 IS NULL THEN
                        v_cantid2 := 0;
                    END IF;
                ELSE
                    BEGIN
                        SELECT
                            costo01,
                            costo02,
                            cantid
                        INTO
                            v_costot01,
                            v_costot02,
                            v_cantid2
                        FROM
                            articulos_costo
                        WHERE
                                id_cia = pin_id_cia
                            AND tipinv = i.tipinv
                            AND codart = i.codart
                            AND periodo BETWEEN EXTRACT(YEAR FROM current_date) * 100 AND i.periodo
                            AND cantid <> 0
                            AND costo01 <> 0
                        ORDER BY
                            periodo DESC
                        FETCH FIRST 1 ROW ONLY;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_costot01 := NULL;
                            v_costot02 := NULL;
                            v_cantid2 := NULL;
                    END;

                    IF v_costot01 IS NULL THEN
                        v_costot01 := 0;
                    END IF;
                    IF v_costot02 IS NULL THEN
                        v_costot02 := 0;
                    END IF;
                    IF v_cantid2 IS NULL THEN
                        v_cantid2 := 0;
                    END IF;
                END IF;
                    ----

                IF (
                        ( v_costot01 <> 0 ) AND ( v_costot02 <> 0 )
                    AND ( v_cantid2 <> 0 )
                ) THEN
                    v_costot01 := ( ( v_costot01 * i.cantid ) / v_cantid2 ); /* AJUSTA A 2 DECIMALES */
                    v_costot02 := ( ( v_costot02 * i.cantid ) / v_cantid2 ); /* AJUSTA A 2 DECIMALES */
                END IF;

            END IF;
        END IF;

        v_codalm := case when 
                        ((v_clase55='S') and (v_almdes1>0) and (v_tipdoc=103) and (v_id='I') ) 
                    then 
                         v_almdes1 
                    else i.codalm 
                   end;

        INSERT INTO kardex (
            id_cia,
            locali,
            id,
            tipdoc,
            numint,
            numite,
            periodo,
            codmot,
            femisi,
            tipinv,
            codart,
            cantid,
            costot01,
            costot02,
            codalm,
            tipcam,
            opnumdoc,
            optipinv,
            optramo,
            etiqueta,
            codcli,
            royos,
            ubica,
            swacti,
            codadd01,
            codadd02,
            numintpre,
            numitepre,
            fcreac,
            factua
        ) VALUES (
            pin_id_cia,
            i.locali,
            v_id,
            i.tipdoc,
            i.numint,
            i.numite,
            i.periodo,
            i.codmot,
            i.femisi,
            i.tipinv,
            i.codart,
            i.cantid,
            v_costot01,
            v_costot02,
            v_codalm,
            i.tipcam,
            i.opnumdoc,
            i.optipinv,
            i.optramo,
            i.etiqueta,
            i.codcli,
            i.royos,
            i.ubica,
            i.swacti,
            i.codadd01,
            i.codadd02,
            i.numintpre,
            i.numitepre,
            current_timestamp,
            current_timestamp
        );

        IF (
            ( v_clase6 = 6 ) AND ( ( v_almdes1 > 0 ) OR ( v_almdes2 > 0 ) )
        ) THEN
            v_sid := ( CASE
                WHEN v_id = 'S' THEN
                    'I'
                ELSE 'S'
            END );
            scodalm := ( CASE
                WHEN v_almdes1 > 0 THEN
                    v_almdes1
                ELSE v_almdes2
            END );
            INSERT INTO kardex (
                id_cia,
                locali,
                id,
                tipdoc,
                numint,
                numite,
                periodo,
                codmot,
                femisi,
                tipinv,
                codart,
                cantid,
                costot01,
                costot02,
                codalm,
                tipcam,
                opnumdoc,
                optipinv,
                optramo,
                etiqueta,
                codcli,
                royos,
                ubica,
                swacti,
                codadd01,
                codadd02,
                numintpre,
                numitepre,
                fcreac,
                factua
            ) VALUES (
                pin_id_cia,
                i.locali,
                v_sid,
                i.tipdoc,
                i.numint,
                i.numite,
                i.periodo,
                i.codmot,
                i.femisi,
                i.tipinv,
                i.codart,
                i.cantid,
                v_costot01,
                v_costot02,
                scodalm,
                i.tipcam,
                i.opnumdoc,
                i.optipinv,
                i.optramo,
                i.etiqueta,
                i.codcli,
                i.royos,
                i.ubica,
                i.swacti,
                i.codadd01,
                i.codadd02,
                i.numintpre,
                i.numitepre,
                current_timestamp,
                current_timestamp
            );

        END IF;

    END LOOP;

EXCEPTION
    WHEN pkg_exceptionuser.ex_error_inesperado THEN
        raise_application_error(pkg_exceptionuser.error_inesperado, ' Tiene que asignar ubicaciones a todos los items.');
END sp_enviar_kardex;

/
