--------------------------------------------------------
--  DDL for Package Body PACK_REPORTES_COMERCIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_REPORTES_COMERCIAL" AS

    FUNCTION sp_rventas (
        pin_id_cia  NUMBER,
        pin_tipdoc  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_fdesde  DATE,
        pin_fhasta  DATE,
        pin_codsuc  NUMBER,
        pin_lugemi  NUMBER,
        pin_codmot  NUMBER,
        pin_codven  NUMBER,
        pin_codcli  VARCHAR2
    ) RETURN datatable_rventas
        PIPELINED
    AS
        v_table datatable_rventas;
    BEGIN
        IF (
            (
                pin_fdesde IS NULL
                AND pin_fhasta IS NULL
            )
            AND pin_periodo IS NOT NULL
        ) THEN
            SELECT DISTINCT
                c.tipdoc,
                c.series                                                                                                                                           AS
                serie,
                c.numdoc,
                c.femisi,
                nvl(c.fecter, c.femisi)                                                                                                                            AS
                fecter,
                c.destin,
                c.situac,
                c.numint                                                                                                                                           AS
                numint,
                c.codmot,
                cl.tident,
                cl.dident,
                c.codcli,
                c.ruc,
                c.razonc,
                c.tipmon,
                c.tipcam,
                c.facpro,
                c.ffacpro,
                NULL,
                NULL,
                NULL,
                NULL,
                decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN',(c.totbru + c.seguro + c.gasadu + c.flete),(c.totbru + c.seguro + c.gasadu +
                c.flete) * c.tipcam)) AS totbru,
                decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN', nvl(c.descue, 0), nvl(c.descue, 0) * c.tipcam))                                                   AS
                descue,
                decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN', nvl(c.monafe, 0), nvl(c.monafe, 0) * c.tipcam))                                                   AS
                monafe,
                decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN', nvl(c.monexo, 0), nvl(c.monexo, 0) * c.tipcam))                                                   AS
                monexo,
                decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN',(c.monina + c.seguro + c.gasadu + c.flete),(c.monina + c.seguro + c.gasadu +
                c.flete) * c.tipcam)) AS monina,
                decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN', nvl(c.monigv, 0), nvl(c.monigv, 0) * c.tipcam))                                                   AS
                monigv,
                CAST(
                    CASE
                        WHEN ( c.destin = 2
                             AND c.monina > 0
                             AND cl.codtpe = 3 ) THEN
                            decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN',(c.monina + c.seguro + c.gasadu + c.flete),(c.monina + c.
                            seguro + c.gasadu + c.flete) * c.tipcam))
                        ELSE
                            0
                    END
                AS NUMERIC(16, 2))                                                                                                                                 AS
                totexo,
                decode(c.situac, 'J', 0,
                       CASE
                           WHEN(mt16.valor IS NULL)
                               OR(upper(mt16.valor) <> 'S') THEN
                               decode(c.tipmon, 'PEN', nvl(c.preven, 0), nvl(c.preven, 0) * c.tipcam)
                           ELSE
                               0
                       END
                )                                                                                                                                                  AS
                preven,
                decode(c.tipmon, 'PEN', nvl(c.seguro, 0), nvl(c.seguro, 0) * c.tipcam)                                                                             AS
                seguro,
                decode(c.tipmon, 'PEN', nvl(c.gasadu, 0), nvl(c.gasadu, 0) * c.tipcam)                                                                             AS
                gasadu,
                decode(c.tipmon, 'PEN', nvl(c.flete, 0), nvl(c.flete, 0) * c.tipcam)                                                                               AS
                flete,
                decode(c.situac, 'J', 0, CAST(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                            nvl(c.preven, 0)
                        ELSE
                            nvl(c.preven, 0) *
                            CASE
                                WHEN(c.tipcam > 0.0) THEN
                                        c.tipcam
                                ELSE
                                    CAST(1.0 AS NUMBER)
                            END
                    END
                AS NUMERIC(16, 2)))                                                                                                                                AS
                prevensol,
                decode(c.situac, 'J', 0, CAST(
                    CASE
                        WHEN c.tipmon = 'USD' THEN
                            nvl(c.preven, 0)
                        ELSE
                            nvl(c.preven, 0) /
                            CASE
                                WHEN(c.tipcam > 0.0) THEN
                                        c.tipcam
                                ELSE
                                    CAST(1.0 AS NUMBER)
                            END
                    END
                AS NUMERIC(16, 2)))                                                                                                                                AS
                prevendol,
                s.dessit,
                s.alias                                                                                                                                            AS
                aliassit,
                s.permis                                                                                                                                           AS
                permisit,
                d.descri                                                                                                                                           AS
                desser,
                d2.descri                                                                                                                                          AS
                desdoc,
                d2.signo                                                                                                                                           AS
                signo,
                s2.codsuc,
                s2.sucursal,
                nvl(c.monisc, 0)                                                                                                                                   AS
                monisc,
                nvl(c.monotr, 0)                                                                                                                                   AS
                monotr,
                dcr.numint                                                                                                                                         AS
                numintdcr,
                dcr.tipdoc                                                                                                                                         AS
                tipdocdcr,
                dcr.series                                                                                                                                         AS
                seriesdcr,
                dcr.numdoc                                                                                                                                         AS
                numdocdcr,
                dcr.femisi                                                                                                                                         AS
                femisidcr,
                df.descri                                                                                                                                          AS
                factdestipdoc,
                mo.simbolo
            BULK COLLECT
            INTO v_table
            FROM
                documentos_cab            c
                LEFT OUTER JOIN tmoneda                   mo ON mo.id_cia = c.id_cia
                                              AND mo.codmon = 'PEN'
                LEFT OUTER JOIN motivos_clase             mc ON mc.id_cia = c.id_cia
                                                    AND mc.tipdoc = c.tipdoc
                                                    AND mc.id = c.id
                                                    AND mc.codmot = c.codmot
                                                    AND mc.codigo = 4
                LEFT OUTER JOIN motivos_clase             mt16 ON mt16.id_cia = c.id_cia
                                                      AND mt16.codmot = c.codmot
                                                      AND mt16.id = c.id
                                                      AND mt16.tipdoc = c.tipdoc
                                                      AND mt16.codigo = 16
                LEFT OUTER JOIN situacion                 s ON s.id_cia = c.id_cia
                                               AND s.tipdoc = c.tipdoc
                                               AND s.situac = c.situac
                LEFT OUTER JOIN documentos                d ON d.id_cia = c.id_cia
                                                AND d.codigo = c.tipdoc
                                                AND d.series = c.series
                LEFT OUTER JOIN sucursal                  s2 ON s2.id_cia = c.id_cia
                                               AND s2.codsuc = c.codsuc
                LEFT OUTER JOIN tdoccobranza              d2 ON d2.id_cia = c.id_cia
                                                   AND d2.tipdoc = c.tipdoc
                LEFT OUTER JOIN cliente                   cl ON cl.id_cia = c.id_cia
                                              AND cl.codcli = c.codcli
                LEFT OUTER JOIN cliente_clase             c22 ON c22.id_cia = c.id_cia
                                                     AND c22.tipcli = 'A'
                                                     AND c22.codcli = c.codcli
                                                     AND c22.clase = 22
                                                     AND NOT ( c22.codigo = 'ND' )
                LEFT OUTER JOIN documentos_cab_referencia dcr ON dcr.id_cia = c.id_cia
                                                                 AND dcr.numint = c.numint
                                                                 AND dcr.tipdoc IN ( 1, 3, 7, 8 )
                LEFT OUTER JOIN documentos                df ON df.id_cia = dcr.id_cia
                                                 AND df.codigo = dcr.tipdoc
                                                 AND df.series = dcr.series
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numdoc > 0
                AND c.situac IN ( 'F', 'C', 'J' )
                AND ( ( pin_tipdoc = - 1
                        AND c.tipdoc IN ( 1, 3, 7, 8 ) )
                      OR ( c.tipdoc = pin_tipdoc ) )
                AND ( pin_codsuc IS NULL
                      OR pin_codsuc = - 1
                      OR c.codsuc = pin_codsuc )
                AND ( pin_lugemi IS NULL
                      OR pin_lugemi = - 1
                      OR c.lugemi = pin_lugemi )
                AND ( pin_codmot IS NULL
                      OR pin_codmot = - 1
                      OR c.codmot = pin_codmot )
                AND ( pin_codven IS NULL
                      OR pin_codven = - 1
                      OR c.codven = pin_codven )
                AND ( EXTRACT(YEAR FROM c.femisi) = pin_periodo )
                AND ( pin_mes = - 1
                      OR pin_mes IS NULL
                      OR EXTRACT(MONTH FROM c.femisi) = pin_mes )
            ORDER BY
                c.tipdoc,
                c.series,
                c.numdoc,
                c.femisi;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSIF (
            (
                pin_periodo IS NULL
                AND pin_mes IS NULL
            )
            AND (
                pin_fdesde IS NOT NULL
                AND pin_fhasta IS NOT NULL
            )
        ) THEN
            SELECT DISTINCT
                c.tipdoc,
                c.series                                                                                                                                           AS
                serie,
                c.numdoc,
                c.femisi,
                nvl(c.fecter, c.femisi)                                                                                                                            AS
                fecter,
                c.destin,
                c.situac,
                c.numint                                                                                                                                           AS
                numint,
                c.codmot,
                cl.tident,
                cl.dident,
                c.codcli,
                c.ruc,
                c.razonc,
                c.tipmon,
                c.tipcam,
                c.facpro,
                c.ffacpro,
                NULL,
                NULL,
                NULL,
                NULL,
                decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN',(c.totbru + c.seguro + c.gasadu + c.flete),(c.totbru + c.seguro + c.gasadu +
                c.flete) * c.tipcam)) AS totbru,
                decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN', nvl(c.descue, 0), nvl(c.descue, 0) * c.tipcam))                                                   AS
                descue,
                decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN', nvl(c.monafe, 0), nvl(c.monafe, 0) * c.tipcam)) AS monafe,
                decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN', nvl(c.monexo, 0), nvl(c.monexo, 0) * c.tipcam))                                                   AS
                monexo,
                decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN',(c.monina + c.seguro + c.gasadu + c.flete),(c.monina + c.seguro +
                        c.gasadu + c.flete) * c.tipcam)) AS monina,
                decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN', nvl(c.monigv, 0), nvl(c.monigv, 0) * c.tipcam))                                                   AS
                monigv,
--                CAST(
--                    CASE
--                        WHEN(c.destin = 2
--                             AND c.monina > 0)
--                            OR(cl.codtpe <> 3
--                               AND c22.codigo = 'S') THEN
--                            decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN',(c.monina + c.seguro + c.gasadu + c.flete),(c.monina + c.
--                            seguro + c.gasadu + c.flete) * c.tipcam))
--                        ELSE
--                            0
--                    END
--                AS NUMERIC(16, 2))                                                                                                                                 AS
--                totexo,
                CAST(
                    CASE
                        WHEN ( c.destin = 2
                             AND c.monina > 0
                             AND cl.codtpe = 3 ) THEN
                            decode(c.situac, 'J', 0, decode(c.tipmon, 'PEN',(c.monina + c.seguro + c.gasadu + c.flete),(c.monina + c.
                            seguro + c.gasadu + c.flete) * c.tipcam))
                        ELSE
                            0
                    END
                AS NUMERIC(16, 2))                                                                                                                                 AS
                totexo,
                decode(c.situac, 'J', 0,
                       CASE
                           WHEN(mt16.valor IS NULL)
                               OR(upper(mt16.valor) <> 'S') THEN
                               decode(c.tipmon, 'PEN', nvl(c.preven, 0), nvl(c.preven, 0) * c.tipcam)
                           ELSE
                               0
                       END
                )                                                                                                                                                  AS
                preven,
                decode(c.tipmon, 'PEN', nvl(c.seguro, 0), nvl(c.seguro, 0) * c.tipcam)                                                                             AS
                seguro,
                decode(c.tipmon, 'PEN', nvl(c.gasadu, 0), nvl(c.gasadu, 0) * c.tipcam)                                                                             AS
                gasadu,
                decode(c.tipmon, 'PEN', nvl(c.flete, 0), nvl(c.flete, 0) * c.tipcam)                                                                               AS
                flete,
                decode(c.situac, 'J', 0, CAST(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                            nvl(c.preven, 0)
                        ELSE
                            nvl(c.preven, 0) *
                            CASE
                                WHEN(c.tipcam > 0.0) THEN
                                        c.tipcam
                                ELSE
                                    CAST(1.0 AS NUMBER)
                            END
                    END
                AS NUMERIC(16, 2)))                                                                                                                                AS
                prevensol,
                decode(c.situac, 'J', 0, CAST(
                    CASE
                        WHEN c.tipmon = 'USD' THEN
                            nvl(c.preven, 0)
                        ELSE
                            nvl(c.preven, 0) /
                            CASE
                                WHEN(c.tipcam > 0.0) THEN
                                        c.tipcam
                                ELSE
                                    CAST(1.0 AS NUMBER)
                            END
                    END
                AS NUMERIC(16, 2)))                                                                                                                                AS
                prevendol,
                s.dessit,
                s.alias                                                                                                                                            AS
                aliassit,
                s.permis                                                                                                                                           AS
                permisit,
                d.descri                                                                                                                                           AS
                desser,
                d2.descri                                                                                                                                          AS
                desdoc,
                d2.signo                                                                                                                                           AS
                signo,
                s2.codsuc,
                s2.sucursal,
                nvl(c.monisc, 0)                                                                                                                                   AS
                monisc,
                nvl(c.monotr, 0)                                                                                                                                   AS
                monotr,
                dcr.numint                                                                                                                                         AS
                numintdcr,
                dcr.tipdoc                                                                                                                                         AS
                tipdocdcr,
                dcr.series                                                                                                                                         AS
                seriesdcr,
                dcr.numdoc                                                                                                                                         AS
                numdocdcr,
                dcr.femisi                                                                                                                                         AS
                femisidcr,
                df.descri                                                                                                                                          AS
                factdestipdoc,
                mo.simbolo
            BULK COLLECT
            INTO v_table
            FROM
                documentos_cab            c
                LEFT OUTER JOIN tmoneda                   mo ON mo.id_cia = c.id_cia
                                              AND mo.codmon = 'PEN'
                LEFT OUTER JOIN motivos_clase             mc ON mc.id_cia = c.id_cia
                                                    AND ( mc.tipdoc = c.tipdoc )
                                                    AND ( mc.id = c.id )
                                                    AND ( mc.codmot = c.codmot )
                                                    AND ( mc.codigo = 4 )
                LEFT OUTER JOIN motivos_clase             mt16 ON mt16.id_cia = c.id_cia
                                                      AND ( mt16.codmot = c.codmot )
                                                      AND ( mt16.id = c.id )
                                                      AND ( mt16.tipdoc = c.tipdoc )
                                                      AND ( mt16.codigo = 16 )
                LEFT OUTER JOIN situacion                 s ON s.id_cia = c.id_cia
                                               AND ( s.tipdoc = c.tipdoc )
                                               AND ( s.situac = c.situac )
                LEFT OUTER JOIN documentos                d ON d.id_cia = c.id_cia
                                                AND ( d.codigo = c.tipdoc )
                                                AND ( d.series = c.series )
                LEFT OUTER JOIN sucursal                  s2 ON s2.id_cia = c.id_cia
                                               AND ( s2.codsuc = c.codsuc )
                LEFT OUTER JOIN tdoccobranza              d2 ON d2.id_cia = c.id_cia
                                                   AND ( d2.tipdoc = c.tipdoc )
                LEFT OUTER JOIN cliente                   cl ON cl.id_cia = c.id_cia
                                              AND ( cl.codcli = c.codcli )
                LEFT OUTER JOIN cliente_clase             c22 ON c22.id_cia = c.id_cia
                                                     AND c22.tipcli = 'A'
                                                     AND c22.codcli = c.codcli
                                                     AND c22.clase = 22
                                                     AND NOT ( c22.codigo = 'ND' )
                LEFT OUTER JOIN documentos_cab_referencia dcr ON dcr.id_cia = c.id_cia
                                                                 AND ( dcr.numint = c.numint )
                                                                 AND dcr.tipdoc IN ( 1, 3, 7, 8 )
                LEFT OUTER JOIN documentos                df ON df.id_cia = dcr.id_cia
                                                 AND df.codigo = dcr.tipdoc
                                                 AND df.series = dcr.series
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numdoc > 0
                AND c.situac IN ( 'F', 'C', 'J' )
                AND ( ( pin_tipdoc = - 1
                        AND c.tipdoc IN ( 1, 3, 7, 8 ) )
                      OR ( c.tipdoc = pin_tipdoc ) )
                AND ( pin_codsuc IS NULL
                      OR pin_codsuc = - 1
                      OR c.codsuc = pin_codsuc )
                AND ( pin_lugemi IS NULL
                      OR pin_lugemi = - 1
                      OR c.lugemi = pin_lugemi )
                AND ( pin_codmot IS NULL
                      OR pin_codmot = - 1
                      OR c.codmot = pin_codmot )
                AND ( pin_codven IS NULL
                      OR pin_codven = - 1
                      OR c.codven = pin_codven )
                AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
            ORDER BY
                c.tipdoc,
                c.series,
                c.numdoc,
                c.femisi;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        END IF;
    END sp_rventas;

END;

/
