--------------------------------------------------------
--  DDL for Package Body PACK_REPORTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_REPORTES" AS

    FUNCTION sp_registro_ventas_detalle (
        pin_id_cia IN NUMBER,--S
        pin_fdesde IN DATE,--S
        pin_fhasta IN DATE,--S
        pin_codsuc IN NUMBER,--S
        pin_codcli IN VARCHAR2,--S
        pin_codven IN NUMBER,--S
        pin_moneda IN VARCHAR2,--S
        pin_limit  IN NUMBER,--S
        pin_offset IN NUMBER--S
    ) RETURN datatable_registro_ventas_detalle
        PIPELINED
    AS
        v_table datatable_registro_ventas_detalle;
        x       NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO x
        FROM
            documentos_cab;

        SELECT DISTINCT
            c.tipdoc,
            c.series,
            c.numint,
            c.numdoc,
            c.femisi,
            c.codmot,
            c.situac,
            s1.dessit                                                   AS situacdesc,
            c.razonc,
            c.codcpag,
            cv.despag                                                   AS desccpag,
            dt.descri                                                   AS desdoc,
            m.simbolo,
            ( ( c.totbru + c.seguro + c.gasadu + c.flete ) * dc.signo ) AS totbru,
            (
                CASE
                    WHEN ( c.descue IS NULL ) THEN
                        0
                    ELSE
                        c.descue
                END
                * dc.signo )                                                AS descue,
            (
                CASE
                    WHEN ( c.monafe IS NULL ) THEN
                        0
                    ELSE
                        c.monafe
                END
                * dc.signo )                                                AS monafe,
            ( ( c.monina + c.seguro + c.gasadu + c.flete ) * dc.signo ) AS monina,
            (
                CASE
                    WHEN ( coalesce(c.destin, 1) = 2
                           AND c.monina > 0 )
                         AND ( cl.codtpe = 3 )
                         AND ( c.codmot = 4 ) THEN
                        c.monina
                    ELSE
                        c.seguro + c.gasadu + c.flete
                END
                * dc.signo )                                                AS monexpadd,
            (
                CASE
                    WHEN ( coalesce(c.destin, 1) = 2
                           AND c.monina > 0 )
                         OR ( cl.codtpe <> 3
                              AND c22.codigo = 'S' ) THEN
                        CAST(0 AS NUMERIC(10, 2))
                    ELSE
                        c.monina
                END
                * dc.signo )                                                AS moninacab,
            ( (
                CASE
                    WHEN ( coalesce(c.destin, 1) <> 2
                           AND c.monina > 0 )
                         AND ( cl.codtpe <> 3
                               AND c22.codigo = 'S' ) THEN
                        c.monina
                    ELSE
                        CAST(0 AS NUMERIC(10, 2))
                END
                + c.monexo ) * dc.signo )                                   AS monexocab,
            (
                CASE
                    WHEN ( coalesce(c.destin, 1) = 2
                           AND c.monina > 0 )
                         AND ( cl.codtpe = 3 )
                         AND ( c.codmot <> 4 ) THEN
                        c.monina
                    ELSE
                        CAST(0 AS NUMERIC(10, 2))
                END
                * dc.signo )                                                AS monexoexp,
            (
                CASE
                    WHEN ( c.monigv IS NULL ) THEN
                        0
                    ELSE
                        c.monigv
                END
                * dc.signo )                                                AS monigv,
            (
                CASE
                    WHEN ( c.monisc IS NULL ) THEN
                        0
                    ELSE
                        c.monisc
                END
                * dc.signo )                                                AS monisc,
            (
                CASE
                    WHEN ( c.monotr IS NULL ) THEN
                        0
                    ELSE
                        c.monotr
                END
                * dc.signo )                                                AS monotr,
            (
                CASE
                    WHEN ( mt16.valor IS NULL )
                         OR ( upper(mt16.valor) <> 'S' ) THEN
                            CASE
                                WHEN ( c.preven IS NULL ) THEN
                                    0
                                ELSE
                                    c.preven
                            END
                    ELSE
                        0
                END
                * dc.signo )                                                AS preven,
            (
                CASE
                    WHEN c.tipmon = 'PEN' THEN
                            CASE
                                WHEN ( c.preven IS NULL ) THEN
                                    0
                                ELSE
                                    c.preven
                            END
                    ELSE
                        CASE
                            WHEN ( c.preven IS NULL ) THEN
                                    0
                            ELSE
                                c.preven
                        END
                        *
                        CASE
                            WHEN ( c.tipcam > 0 ) THEN
                                    c.tipcam
                            ELSE
                                1
                        END
                END
                * dc.signo )                                                AS prevensol,
            (
                CASE
                    WHEN c.tipmon = 'USD' THEN
                            CASE
                                WHEN ( c.preven IS NULL ) THEN
                                    0
                                ELSE
                                    c.preven
                            END
                    ELSE
                        CASE
                            WHEN ( c.preven IS NULL ) THEN
                                    0
                            ELSE
                                c.preven
                        END
                        /
                        CASE
                            WHEN ( c.tipcam > 0 ) THEN
                                    c.tipcam
                            ELSE
                                1
                        END
                END
                * dc.signo )                                                AS prevendol
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab  c
            LEFT OUTER JOIN documentos      d ON d.id_cia = c.id_cia
                                            AND ( d.codigo = c.tipdoc )
                                            AND ( d.series = c.series )
            LEFT OUTER JOIN documentos_tipo dt ON dt.id_cia = c.id_cia
                                                  AND dt.tipdoc = c.tipdoc
            LEFT OUTER JOIN c_pago          cv ON cv.id_cia = c.id_cia
                                         AND ( cv.codpag = c.codcpag )
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN situacion       s1 ON s1.id_cia = c.id_cia
                                            AND ( s1.tipdoc = c.tipdoc )
                                            AND ( s1.situac = c.situac )
            LEFT OUTER JOIN tdoccobranza    dc ON dc.id_cia = c.id_cia
                                               AND dc.tipdoc = c.tipdoc
            LEFT OUTER JOIN motivos_clase   mt16 ON mt16.id_cia = c.id_cia
                                                  AND ( mt16.codmot = c.codmot )
                                                  AND ( mt16.id = c.id )
                                                  AND ( mt16.tipdoc = c.tipdoc )
                                                  AND ( mt16.codigo = 16 )
            LEFT OUTER JOIN cliente         cl ON cl.id_cia = c.id_cia
                                          AND ( cl.codcli = c.codcli )
            LEFT OUTER JOIN cliente_clase   c22 ON c22.id_cia = c.id_cia
                                                 AND c22.tipcli = 'A'
                                                 AND c22.codcli = c.codcli
                                                 AND c22.clase = 22
                                                 AND NOT ( c22.codigo = 'ND' )
            LEFT OUTER JOIN tmoneda         m ON m.id_cia = c.id_cia
                                         AND m.codmon = c.tipmon
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc IN ( 1, 3, 7, 8, 12 )
            AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
            AND ( c.situac = 'F'
                  OR c.situac = 'C' )
            AND ( ( pin_codsuc IS NULL
                    OR pin_codsuc = - 1 )
                  OR ( c.codsuc = pin_codsuc
                       AND pin_codsuc IS NOT NULL ) )
            AND ( ( pin_codcli IS NULL )
                  OR ( c.codcli = pin_codcli
                       AND c.codcli IS NOT NULL ) )
            AND ( ( pin_codven IS NULL
                    OR pin_codven = - 1 )
                  OR ( c.codven = pin_codven
                       AND pin_codven IS NOT NULL ) )
            AND ( ( pin_moneda IS NULL )
                  OR ( c.tipmon = pin_moneda
                       AND pin_moneda IS NOT NULL ) )
        ORDER BY
            c.femisi DESC
        OFFSET
            CASE
                WHEN pin_offset = - 1 THEN
                    0
                ELSE
                    pin_offset
            END
        ROWS FETCH NEXT
            CASE
                WHEN pin_limit = - 1 THEN
                    x
                ELSE
                    pin_limit
            END
        ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_registro_ventas_detalle;

    FUNCTION sp_registro_ventas_pdf (
        pin_id_cia  IN NUMBER,
        pin_tipdoc  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_fdesde  IN DATE,
        pin_fhasta  IN DATE,
        pin_codsuc  IN NUMBER,
        pin_lugemi  IN NUMBER,
        pin_codmot  IN NUMBER,
        pin_codcli  IN VARCHAR2,
        pin_codven  IN NUMBER
    ) RETURN datatable_registro_ventas_pdf
        PIPELINED
    AS
        v_table datatable_registro_ventas_pdf;
    BEGIN
        SELECT
            c.tipdoc,
            c.series                                     AS serie,
            c.numdoc,
            c.femisi,
            CASE
                WHEN ( c.fecter IS NULL ) THEN
                    c.femisi
                ELSE
                    c.fecter
            END                                          AS fecter,
            c.destin,
            c.situac,
            CASE
                WHEN ( c.numint IS NULL ) THEN
                    0
                ELSE
                    c.numint
            END                                          AS numint,
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
            CASE
                WHEN ( dr1.tipdoc = 1 )
                     OR ( dr1.tipdoc = 3 )
                     OR ( dr1.tipdoc = 7 )
                     OR ( dr1.tipdoc = 8 ) THEN
                    dr1.tipdoc
                ELSE
                    dr2.tipdoc
            END                                          AS tipdocre,
            CASE
                WHEN ( dr1.tipdoc = 1 )
                     OR ( dr1.tipdoc = 3 )
                     OR ( dr1.tipdoc = 7 )
                     OR ( dr1.tipdoc = 8 ) THEN
                    dr1.series
                ELSE
                    dr2.series
            END                                          AS seriere,
            CASE
                WHEN ( dr1.tipdoc = 1 )
                     OR ( dr1.tipdoc = 3 )
                     OR ( dr1.tipdoc = 7 )
                     OR ( dr1.tipdoc = 8 ) THEN
                    dr1.numdoc
                ELSE
                    dr2.numdoc
            END                                          AS numdocre,
            CASE
                WHEN ( dr1.tipdoc = 1 )
                     OR ( dr1.tipdoc = 3 )
                     OR ( dr1.tipdoc = 7 )
                     OR ( dr1.tipdoc = 8 ) THEN
                    dr1.femisi
                ELSE
                    dr2.femisi
            END                                          AS femisire,
            ( c.totbru + c.seguro + c.gasadu + c.flete ) AS totbru,
            CASE
                WHEN ( c.descue IS NULL ) THEN
                    0
                ELSE
                    c.descue
            END                                          AS descue,
            (
                CASE
                    WHEN ( c.monafe IS NULL ) THEN
                        0
                    ELSE
                        c.monafe
                END
            )                                            AS monafe,
            (
                CASE
                    WHEN ( c.monexo IS NULL ) THEN
                        0
                    ELSE
                        c.monexo
                END
            )                                            AS monexo,
            ( c.monina + c.seguro + c.gasadu + c.flete ) AS monina,
            (
                CASE
                    WHEN ( c.monigv IS NULL ) THEN
                        0
                    ELSE
                        c.monigv
                END
            )                                            AS monigv,
            (
                CASE
                    WHEN ( mt16.valor IS NULL )
                         OR ( upper(mt16.valor) <> 's' ) THEN
                        (
                            CASE
                                WHEN ( c.preven IS NULL ) THEN
                                    0
                                ELSE
                                    c.preven
                            END
                        )
                    ELSE
                        0
                END
            )                                            AS preven,
            CASE
                WHEN ( c.seguro IS NULL ) THEN
                    0
                ELSE
                    c.seguro
            END                                          AS seguro,
            CASE
                WHEN ( c.gasadu IS NULL ) THEN
                    0
                ELSE
                    c.gasadu
            END                                          AS gasadu,
            CASE
                WHEN ( c.flete IS NULL ) THEN
                    0
                ELSE
                    c.flete
            END                                          AS flete,
            CAST(
                CASE
                    WHEN c.tipmon = 'PEN' THEN
                            CASE
                                WHEN(c.preven IS NULL) THEN
                                    0.0
                                ELSE
                                    c.preven
                            END
                    ELSE
                        CASE
                            WHEN(c.preven IS NULL) THEN
                                    0.0
                            ELSE
                                c.preven
                        END
                        *
                        CASE
                            WHEN(c.tipcam > 0.0) THEN
                                    c.tipcam
                            ELSE
                                CAST(1.0 AS NUMBER)
                        END
                END
            AS NUMERIC(16,
                 2))                                     AS prevensol,
            CAST(
                CASE
                    WHEN c.tipmon = 'USD' THEN
                            CASE
                                WHEN(c.preven IS NULL) THEN
                                    0.0
                                ELSE
                                    c.preven
                            END
                    ELSE
                        CASE
                            WHEN(c.preven IS NULL) THEN
                                    0.0
                            ELSE
                                c.preven
                        END
                        /
                        CASE
                            WHEN(c.tipcam > 0.0) THEN
                                    c.tipcam
                            ELSE
                                CAST(1.0 AS NUMBER)
                        END
                END
            AS NUMERIC(16,
                 2))                                     AS prevendol,
            s.dessit,
            s.alias                                      AS aliassit,
            s.permis                                     AS permisit,
            d.descri                                     AS desser,
            d2.descri                                    AS desdoc,
            d2.signo                                     AS signo,
            s2.codsuc,
            s2.sucursal,
            (
                CASE
                    WHEN ( c.monisc IS NULL ) THEN
                        0
                    ELSE
                        c.monisc
                END
            )                                            AS monisc,
            (
                CASE
                    WHEN ( c.monotr IS NULL ) THEN
                        0
                    ELSE
                        c.monotr
                END
            )                                            AS monotr,
            dcr.numint                                   AS numintdcr,
            dcr.tipdoc                                   AS tipdocdcr,
            dcr.series                                   AS seriesdcr,
            dcr.numdoc                                   AS numdocdcr,
            dcr.femisi                                   AS femisidcr,
            df.descri                                    AS factdestipdoc,
            mo.simbolo
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab            c
            LEFT OUTER JOIN tmoneda                   mo ON mo.id_cia = c.id_cia
                                          AND mo.codmon = 'PEN'
            LEFT OUTER JOIN documentos_relacion       cr1 ON cr1.id_cia = c.id_cia
                                                       AND ( NOT ( cr1.tipdoc IN ( 1, 3 ) ) )
                                                       AND ( cr1.numint = c.numint )
            LEFT OUTER JOIN documentos_cab            dr1 ON dr1.id_cia = cr1.id_cia
                                                  AND ( dr1.numint = cr1.numintre )
                                                  AND ( dr1.tipdoc IN ( 1, 3, 7, 8 ) )
            LEFT OUTER JOIN documentos_relacion       cr2 ON cr2.id_cia = cr1.id_cia
                                                       AND ( NOT ( cr2.tipdoc IN ( 1, 3 ) ) )
                                                       AND ( cr2.numint = cr1.numintre )
            LEFT OUTER JOIN documentos_cab            dr2 ON dr2.id_cia = cr2.id_cia
                                                  AND ( dr2.numint = cr2.numintre )
                                                  AND ( dr2.tipdoc IN ( 1, 3, 7, 8 ) )
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
                    AND c.tipdoc IN ( 1, 3, 7, 8, 12 ) )
                  OR ( c.tipdoc = pin_tipdoc ) )
            AND ( ( ( pin_fdesde IS NOT NULL
                      AND pin_fhasta IS NOT NULL
                      AND ( pin_periodo IS NULL
                            OR pin_mes = 0 )
                      AND ( pin_mes IS NULL
                            OR pin_periodo = 0 ) )
                    AND c.femisi BETWEEN pin_fdesde AND pin_fhasta )
                  OR ( ( pin_mes IS NOT NULL
                         AND pin_periodo IS NOT NULL
                         AND pin_fdesde IS NULL
                         AND pin_fhasta IS NULL )
                       AND ( EXTRACT(MONTH FROM c.femisi) = pin_mes
                             OR pin_mes = - 1 )
                       AND ( EXTRACT(YEAR FROM c.femisi) = pin_periodo
                             OR pin_periodo = - 1 ) ) )
            AND ( ( mc.valor IS NULL
                    OR mc.valor IN ( 'S', 's' ) ) )
            AND ( ( pin_codsuc IS NULL
                    OR pin_codsuc = - 1 )
                  OR ( c.codsuc = pin_codsuc
                       AND pin_codsuc IS NOT NULL ) )
            AND ( ( pin_lugemi IS NULL
                    OR pin_lugemi = - 1 )
                  OR ( c.lugemi = pin_lugemi
                       AND pin_lugemi IS NOT NULL ) )
            AND ( ( pin_tipdoc IS NOT NULL
                    AND pin_tipdoc > - 1
                    AND c.tipdoc = pin_tipdoc
                    AND pin_codmot IS NOT NULL
                    AND pin_codmot > - 1
                    AND c.codmot = pin_codmot )
                  OR ( ( pin_tipdoc IS NULL
                         OR pin_tipdoc = - 1
                         OR c.tipdoc = pin_tipdoc )
                       AND ( pin_codmot IS NULL
                             OR pin_codmot = - 1 ) ) )
            AND ( ( pin_codcli IS NULL )
                  OR ( c.codcli = pin_codcli
                       AND c.codcli IS NOT NULL ) )
            AND ( ( pin_codven IS NULL
                    OR pin_codven = - 1 )
                  OR ( c.codven = pin_codven
                       AND pin_codven IS NOT NULL ) )
        ORDER BY
            c.tipdoc,
            c.series,
            c.numdoc,
            c.femisi DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_registro_ventas_pdf;

    FUNCTION sp_registro_ventas_resumen (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_codven IN NUMBER,
        pin_moneda IN VARCHAR2
    ) RETURN datatable_registro_ventas_resumen
        PIPELINED
    AS
        v_table datatable_registro_ventas_resumen;
    BEGIN
        IF (
            pin_moneda IS NOT NULL
            AND pin_moneda = 'PEN'
        ) THEN
            SELECT
                c.tipdoc,
                c.series        AS serie,
                dt.descri       AS desdoc,
                m.simbolo,
                COUNT(c.numint) AS cantidaddocs,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.acuenta IS NULL) THEN
                                        0
                                    ELSE
                                        c.acuenta
                                END
                        ELSE
                            CASE
                                WHEN(c.acuenta IS NULL) THEN
                                        0
                                ELSE
                                    c.acuenta
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                )               AS acuenta,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.totbru IS NULL) THEN
                                        0
                                    ELSE
                                        c.totbru
                                END
                        ELSE
                            CASE
                                WHEN(c.totbru IS NULL) THEN
                                        0
                                ELSE
                                    c.totbru
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                )               AS totbru,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.descue IS NULL) THEN
                                        0
                                    ELSE
                                        c.descue
                                END
                        ELSE
                            CASE
                                WHEN(c.descue IS NULL) THEN
                                        0
                                ELSE
                                    c.descue
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                )               AS descue,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.monafe IS NULL) THEN
                                        0
                                    ELSE
                                        c.monafe
                                END
                        ELSE
                            CASE
                                WHEN(c.monafe IS NULL) THEN
                                        0
                                ELSE
                                    c.monafe
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                    * dc.signo)     AS monafe,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.monexo IS NULL) THEN
                                        0
                                    ELSE
                                        c.monexo
                                END
                        ELSE
                            CASE
                                WHEN(c.monexo IS NULL) THEN
                                        0
                                ELSE
                                    c.monexo
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                    * dc.signo)     AS monexo,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN((c.monina + c.seguro + c.gasadu + c.flete) IS NULL) THEN
                                        0
                                    ELSE
                                        c.monina
                                END
                        ELSE
                            CASE
                                WHEN(c.monina IS NULL) THEN
                                        0
                                ELSE
                                    (c.monina + c.seguro + c.gasadu + c.flete)
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                    * dc.signo)     AS monina,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.monigv IS NULL) THEN
                                        0
                                    ELSE
                                        c.monigv
                                END
                        ELSE
                            CASE
                                WHEN(c.monigv IS NULL) THEN
                                        0
                                ELSE
                                    c.monigv
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                    * dc.signo)     AS monigv,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.monisc IS NULL) THEN
                                        0
                                    ELSE
                                        c.monisc
                                END
                        ELSE
                            CASE
                                WHEN(c.monisc IS NULL) THEN
                                        0
                                ELSE
                                    c.monisc
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                    * dc.signo)     AS monisc,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.monotr IS NULL) THEN
                                        0
                                    ELSE
                                        c.monotr
                                END
                        ELSE
                            CASE
                                WHEN(c.monotr IS NULL) THEN
                                        0
                                ELSE
                                    c.monotr
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                    * dc.signo)     AS monotr,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.preven IS NULL) THEN
                                        0
                                    ELSE
                                        c.preven
                                END
                        ELSE
                            CASE
                                WHEN(c.preven IS NULL) THEN
                                        0
                                ELSE
                                    c.preven
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                    * dc.signo)     AS preven
            BULK COLLECT
            INTO v_table
            FROM
                documentos_cab  c
                LEFT OUTER JOIN documentos      d ON d.id_cia = c.id_cia
                                                AND ( d.codigo = c.tipdoc )
                                                AND ( d.series = c.series )
                LEFT OUTER JOIN documentos_tipo dt ON dt.id_cia = c.id_cia
                                                      AND dt.tipdoc = c.tipdoc
                LEFT OUTER JOIN tdoccobranza    dc ON dc.id_cia = c.id_cia
                                                   AND dc.tipdoc = c.tipdoc
                LEFT OUTER JOIN motivos_clase   mt16 ON mt16.id_cia = c.id_cia
                                                      AND ( mt16.codmot = c.codmot )
                                                      AND ( mt16.id = c.id )
                                                      AND ( mt16.tipdoc = c.tipdoc )
                                                      AND ( mt16.codigo = 16 )
                LEFT OUTER JOIN cliente         cl ON cl.id_cia = c.id_cia
                                              AND ( cl.codcli = c.codcli )
                LEFT OUTER JOIN cliente_clase   c22 ON c22.id_cia = c.id_cia
                                                     AND c22.tipcli = 'A'
                                                     AND c22.codcli = c.codcli
                                                     AND c22.clase = 22
                                                     AND NOT ( c22.codigo = 'ND' )
                LEFT OUTER JOIN tmoneda         m ON m.id_cia = c.id_cia
                                             AND m.codmon = pin_moneda
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc IN ( 1, 3, 7, 8, 12 )
                AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                AND ( c.situac = 'F'
                      OR c.situac = 'C' )
                AND ( ( pin_codsuc IS NULL
                        OR pin_codsuc = - 1 )
                      OR ( c.codsuc = pin_codsuc
                           AND pin_codsuc IS NOT NULL ) )
                AND ( ( pin_codcli IS NULL )
                      OR ( c.codcli = pin_codcli
                           AND c.codcli IS NOT NULL ) )
                AND ( ( pin_codven IS NULL
                        OR pin_codven = - 1 )
                      OR ( c.codven = pin_codven
                           AND pin_codven IS NOT NULL ) )
            GROUP BY
                c.tipdoc,
                c.series,
                dt.descri,
                m.simbolo;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSIF (
            pin_moneda IS NOT NULL
            AND pin_moneda = 'USD'
        ) THEN
            SELECT
                c.tipdoc,
                c.series        AS serie,
                dt.descri       AS desdoc,
                m.simbolo,
                COUNT(c.numint) AS cantidaddocs,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.acuenta IS NULL) THEN
                                        0
                                    ELSE
                                        c.acuenta
                                END
                        ELSE
                            CASE
                                WHEN(c.acuenta IS NULL) THEN
                                        0
                                ELSE
                                    c.acuenta
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                )               AS acuenta,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.totbru IS NULL) THEN
                                        0
                                    ELSE
                                        c.totbru
                                END
                        ELSE
                            CASE
                                WHEN(c.totbru IS NULL) THEN
                                        0
                                ELSE
                                    c.totbru
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                )               AS totbru,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.descue IS NULL) THEN
                                        0
                                    ELSE
                                        c.descue
                                END
                        ELSE
                            CASE
                                WHEN(c.descue IS NULL) THEN
                                        0
                                ELSE
                                    c.descue
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                )               AS descue,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.monafe IS NULL) THEN
                                        0
                                    ELSE
                                        c.monafe
                                END
                        ELSE
                            CASE
                                WHEN(c.monafe IS NULL) THEN
                                        0
                                ELSE
                                    c.monafe
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                    * dc.signo)     AS monafe,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.monexo IS NULL) THEN
                                        0
                                    ELSE
                                        c.monexo
                                END
                        ELSE
                            CASE
                                WHEN(c.monexo IS NULL) THEN
                                        0
                                ELSE
                                    c.monexo
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                    * dc.signo)     AS monexo,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN((c.monina + c.seguro + c.gasadu + c.flete) IS NULL) THEN
                                        0
                                    ELSE
                                        c.monina
                                END
                        ELSE
                            CASE
                                WHEN(c.monina IS NULL) THEN
                                        0
                                ELSE
                                    (c.monina + c.seguro + c.gasadu + c.flete)
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                    * dc.signo)     AS monina,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.monigv IS NULL) THEN
                                        0
                                    ELSE
                                        c.monigv
                                END
                        ELSE
                            CASE
                                WHEN(c.monigv IS NULL) THEN
                                        0
                                ELSE
                                    c.monigv
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                    * dc.signo)     AS monigv,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.monisc IS NULL) THEN
                                        0
                                    ELSE
                                        c.monisc
                                END
                        ELSE
                            CASE
                                WHEN(c.monisc IS NULL) THEN
                                        0
                                ELSE
                                    c.monisc
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                    * dc.signo)     AS monisc,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.monotr IS NULL) THEN
                                        0
                                    ELSE
                                        c.monotr
                                END
                        ELSE
                            CASE
                                WHEN(c.monotr IS NULL) THEN
                                        0
                                ELSE
                                    c.monotr
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                    * dc.signo)     AS monotr,
                SUM(
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                                CASE
                                    WHEN(c.preven IS NULL) THEN
                                        0
                                    ELSE
                                        c.preven
                                END
                        ELSE
                            CASE
                                WHEN(c.preven IS NULL) THEN
                                        0
                                ELSE
                                    c.preven
                            END
                            *
                            CASE
                                WHEN(c.tipcam > 0) THEN
                                        c.tipcam
                                ELSE
                                    1
                            END
                    END
                    * dc.signo)     AS preven
            BULK COLLECT
            INTO v_table
            FROM
                documentos_cab  c
                LEFT OUTER JOIN documentos      d ON d.id_cia = c.id_cia
                                                AND ( d.codigo = c.tipdoc )
                                                AND ( d.series = c.series )
                LEFT OUTER JOIN documentos_tipo dt ON dt.id_cia = c.id_cia
                                                      AND dt.tipdoc = c.tipdoc
                LEFT OUTER JOIN tdoccobranza    dc ON dc.id_cia = c.id_cia
                                                   AND dc.tipdoc = c.tipdoc
                LEFT OUTER JOIN motivos_clase   mt16 ON mt16.id_cia = c.id_cia
                                                      AND ( mt16.codmot = c.codmot )
                                                      AND ( mt16.id = c.id )
                                                      AND ( mt16.tipdoc = c.tipdoc )
                                                      AND ( mt16.codigo = 16 )
                LEFT OUTER JOIN cliente         cl ON cl.id_cia = c.id_cia
                                              AND ( cl.codcli = c.codcli )
                LEFT OUTER JOIN cliente_clase   c22 ON c22.id_cia = c.id_cia
                                                     AND c22.tipcli = 'A'
                                                     AND c22.codcli = c.codcli
                                                     AND c22.clase = 22
                                                     AND NOT ( c22.codigo = 'ND' )
                LEFT OUTER JOIN tmoneda         m ON m.id_cia = c.id_cia
                                             AND m.codmon = pin_moneda
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc IN ( 1, 3, 7, 8, 12 )
                AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                AND ( c.situac = 'F'
                      OR c.situac = 'C' )
                AND ( ( pin_codsuc IS NULL
                        OR pin_codsuc = - 1 )
                      OR ( c.codsuc = pin_codsuc
                           AND pin_codsuc IS NOT NULL ) )
                AND ( ( pin_codcli IS NULL )
                      OR ( c.codcli = pin_codcli
                           AND c.codcli IS NOT NULL ) )
                AND ( ( pin_codven IS NULL
                        OR pin_codven = - 1 )
                      OR ( c.codven = pin_codven
                           AND pin_codven IS NOT NULL ) )
            GROUP BY
                c.tipdoc,
                c.series,
                dt.descri,
                m.simbolo;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        END IF;
    END sp_registro_ventas_resumen;

    FUNCTION fn_acta_entrega (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER,
        pin_numite IN NUMBER
    ) RETURN datatable_fn_acta_entrega
        PIPELINED
    AS
        v_table datatable_fn_acta_entrega;
    BEGIN
        SELECT
            dc.razonc                             AS clienterazonc,
            dc.ruc                                AS clienteruc,
            k.dam,
            k.placa,
            k.dam_item,
            (
                SELECT
                    descri
                FROM
                    clase_codigo
                WHERE
                        id_cia = ac.id_cia
                    AND tipinv = ac.tipinv
                    AND clase = ac.clase
                    AND codigo = ac.codigo
            )                                     AS clase02,
            (
                SELECT
                    descri
                FROM
                    clase_codigo
                WHERE
                        id_cia = ac3.id_cia
                    AND tipinv = ac3.tipinv
                    AND clase = ac3.clase
                    AND codigo = ac3.codigo
            )                                     AS clase03,
            (
                SELECT
                    descri
                FROM
                    clase_codigo
                WHERE
                        id_cia = ac4.id_cia
                    AND tipinv = ac4.tipinv
                    AND clase = ac4.clase
                    AND codigo = ac4.codigo
            )                                     AS clase04,
            (
                SELECT
                    descri
                FROM
                    clase_codigo
                WHERE
                        id_cia = ac12.id_cia
                    AND tipinv = ac12.tipinv
                    AND clase = ac12.clase
                    AND codigo = ac12.codigo
            )                                     AS clase12,
            ae11.ventero,
            ae13.vstrg,
               /* SELECT
                    vdate
                FROM
                    articulo_especificacion
                WHERE
                        id_cia = ae11.id_cia
                    AND tipinv = ae11.tipinv
                    AND clase = ae11.clase
                    AND codigo = ae11.codigo
            )         AS especificacion11,
            (
                SELECT
                    vstrg
                FROM
                    articulo_especificacion
                WHERE
                        id_cia = ae13.id_cia
                    AND tipinv = ae13.tipinv
                    AND clase = ae13.clase
                    AND codigo = ae13.codigo
            )         AS especificacion13,*/
            dc.femisi,
            TO_NUMBER(to_char(dc.femisi, 'YYYY')) AS periodo,
            TO_NUMBER(to_char(dc.femisi, 'MM'))   AS idmes,
            d.id_cia,
            d.numint,
            d.numite,
            d.tipdoc,
            d.series,
            d.tipinv,
            d.codart,
            d.situac,
            d.codalm,
            d.cantid,
            d.canref,
            d.canped,
            d.saldo,
            d.pordes1,
            d.pordes2,
            d.pordes3,
            d.pordes4,
            d.preuni,
            d.cosuni,
            d.observ,
            d.fcreac,
            d.factua,
            d.usuari,
            d.importe_bruto,
            d.importe,
            d.opnumdoc,
            d.opcargo,
            d.opnumite,
            d.optipinv,
            d.codund,
            d.largo,
            d.ancho,
            d.altura,
            d.porigv,
            d.monafe,
            d.monina,
            d.monigv,
            d.optramo,
            d.etiqueta,
            d.piezas,
            d.opronumdoc,
            d.numguia,
            d.fecguia,
            d.numfact,
            d.fecfact,
            d.lote,
            d.fecfabr,
            d.nrocarrete,
            d.nrotramo,
            d.tottramo,
            d.norma,
            d.etiqueta2,
            d.codcli,
            d.tara,
            d.royos,
            d.positi,
            d.codadd01,
            d.codadd02,
            d.ubica,
            d.opnumsec,
            d.combina,
            d.empalme,
            d.swacti,
            d.diseno,
            d.acabado,
            d.fvenci,
            d.seguro,
            d.flete,
            d.fmanuf,
            d.monisc,
            d.valporisc,
            d.tipisc,
            d.monotr,
            d.monexo,
            d.numintpre,
            d.numitepre,
            d.montgr,
            d.tipafec,
            d.costot01,
            d.costot02,
            d.cargamin,
            d.dam,
            d.dam_item,
            d.chasis,
            d.motor,
            d.monicbper
        BULK COLLECT
        INTO v_table
        FROM
            documentos_det          d
            LEFT OUTER JOIN documentos_cab          dc ON dc.id_cia = d.id_cia
                                                 AND dc.numint = d.numint
            LEFT OUTER JOIN kardex000               k ON k.id_cia = d.id_cia
                                           AND k.etiqueta = d.etiqueta
            LEFT OUTER JOIN articulos               a ON a.id_cia = d.id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
            LEFT OUTER JOIN articulos_clase         ac ON ac.id_cia = a.id_cia
                                                  AND ac.tipinv = a.tipinv
                                                  AND ac.codart = a.codart
                                                  AND ac.clase = 2
            LEFT OUTER JOIN articulos_clase         ac3 ON ac3.id_cia = a.id_cia
                                                   AND ac3.tipinv = a.tipinv
                                                   AND ac3.codart = a.codart
                                                   AND ac3.clase = 3
            LEFT OUTER JOIN articulos_clase         ac4 ON ac4.id_cia = a.id_cia
                                                   AND ac4.tipinv = a.tipinv
                                                   AND ac4.codart = a.codart
                                                   AND ac4.clase = 4
            LEFT OUTER JOIN articulos_clase         ac12 ON ac12.id_cia = a.id_cia
                                                    AND ac12.tipinv = a.tipinv
                                                    AND ac12.codart = a.codart
                                                    AND ac12.clase = 12
            LEFT OUTER JOIN articulo_especificacion ae11 ON ae11.id_cia = a.id_cia
                                                            AND ae11.tipinv = a.tipinv
                                                            AND ae11.codart = a.codart
                                                            AND ae11.codesp = 11
            LEFT OUTER JOIN articulo_especificacion ae13 ON ae13.id_cia = a.id_cia
                                                            AND ae13.tipinv = a.tipinv
                                                            AND ae13.codart = a.codart
                                                            AND ae13.codesp = 13
        WHERE
                d.id_cia = pin_id_cia
            AND d.numint = pin_numint
            AND d.numite = pin_numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END fn_acta_entrega;

END;

/
