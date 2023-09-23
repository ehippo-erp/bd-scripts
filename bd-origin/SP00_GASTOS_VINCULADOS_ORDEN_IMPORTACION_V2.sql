--------------------------------------------------------
--  DDL for Function SP00_GASTOS_VINCULADOS_ORDEN_IMPORTACION_V2
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP00_GASTOS_VINCULADOS_ORDEN_IMPORTACION_V2" (
    pin_id_cia  IN  NUMBER,
    pin_tipdoc  IN  NUMBER,
    pin_series  IN  VARCHAR2,
    pin_numdoc  IN  NUMBER
) RETURN tbl_gastos_vinculados_orden_importacion_v2
    PIPELINED
AS

    rgastos_vinculados  rec_gastos_vinculados_orden_importacion_v2 := rec_gastos_vinculados_orden_importacion_v2(NULL, NULL, NULL,
    NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL,
                                           NULL);
    CURSOR cur_gastos_vinculados IS
    SELECT
        m.swgasoper,
        r.libro,
        r.asiento,
        m.tdocum,
        m.serie                        AS nserie,
        m.numero,
        m.fdocum                       AS femisi,
        m.moneda,
        m.tcambio01 / m.tcambio02      AS tipcam,
        m.codigo                       AS codcli,
        m.razon,
        m.concep,
        CASE
            WHEN t.signo IS NULL THEN
                CAST(1 AS FLOAT)
            ELSE
                t.signo
        END AS signo,
        SUM(m.impor01 *
            CASE
                WHEN t.signo IS NULL THEN
                    CAST(1 AS FLOAT)
                ELSE
                    t.signo
            END
        ) AS tgeneral1,
        SUM(m.impor02 *
            CASE
                WHEN t.signo IS NULL THEN
                    CAST(1 AS FLOAT)
                ELSE
                    t.signo
            END
        ) AS tgeneral2
    FROM
        documentos_cab        d
        LEFT OUTER JOIN movimientos_relacion  r ON r.id_cia = pin_id_cia
                                                  AND r.numint = d.numint
        LEFT OUTER JOIN movimientos           m ON m.id_cia = pin_id_cia
                                         AND m.periodo = r.periodo
                                         AND m.mes = r.mes
                                         AND m.libro = r.libro
                                         AND m.asiento = r.asiento
                                         AND m.item = r.item
                                         AND m.sitem = r.sitem
--                                         AND
--                                   /*     (:WCTAGASTOS CONTAINING M.CUENTA) AND*/ NVL(m.swgasoper, 0) < 2 /* 2011-06-06 - NO SE INCLUYEN LOS SWGASOPER=2 (NO INCLUIDOS) */
        LEFT OUTER JOIN tdocume               t ON t.id_cia = pin_id_cia
                                     AND ( t.codigo = m.tdocum )
    WHERE
            d.id_cia = pin_id_cia
        AND d.tipdoc = pin_tipdoc
        AND d.series = pin_series
        AND d.numdoc = pin_numdoc
        and NVL(m.swgasoper, 0) < 2

    GROUP BY
        m.swgasoper,
        r.libro,
        r.asiento,
        m.tdocum,
        m.serie,
        m.numero,
        m.fdocum,
        m.moneda,
        m.tcambio01,
        m.tcambio02,
        m.codigo,
        m.razon,
        m.concep,
        t.signo
    ORDER BY
        m.swgasoper,
        m.fdocum;

    v_ctagastos         VARCHAR2(300);
    v_numint            INTEGER;
    v_cuenta            VARCHAR2(16);
    v_vstrg             VARCHAR2(150);
    v_tipcam            NUMERIC(10, 6);
BEGIN
/* EJEMPLO DE USO
  SELECT * FROM TABLE(SP00_GASTOS_VINCULADOS_ORDEN_IMPORTACION_V2(5,103,'111',2008090001))
  SELECT * FROM TABLE(SP00_GASTOS_VINCULADOS_ORDEN_IMPORTACION_V2(5,115,'111',2008090001))
*/
    BEGIN
        SELECT
            cuenta,
            vstrg
        INTO
            v_cuenta,
            v_vstrg
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 215 /* CONSTANTE FIJA PARA CTA GASTO */;

    EXCEPTION
        WHEN no_data_found THEN
            v_cuenta := NULL;
            v_vstrg := NULL;
    END;

    IF ( v_cuenta IS NULL ) THEN
        v_cuenta := '';
    END IF;
    IF ( v_vstrg IS NULL ) THEN
        v_vstrg := '';
    END IF;
    v_ctagastos := v_cuenta || v_vstrg;
    FOR registro IN cur_gastos_vinculados LOOP
        rgastos_vinculados.swgasoper := registro.swgasoper;
        rgastos_vinculados.libro := registro.libro;
        rgastos_vinculados.asiento := registro.asiento;
        rgastos_vinculados.tdocum := registro.tdocum;
        rgastos_vinculados.nserie := registro.nserie;
        rgastos_vinculados.numero := registro.numero;
        rgastos_vinculados.femisi := registro.femisi;
        rgastos_vinculados.moneda := registro.moneda;
        rgastos_vinculados.tipcam := registro.tipcam;
        rgastos_vinculados.codcli := registro.codcli;
        rgastos_vinculados.razon := registro.razon;
        rgastos_vinculados.concep := registro.concep;
        rgastos_vinculados.signo := registro.signo;
        rgastos_vinculados.tgeneral1 := registro.tgeneral1;
        rgastos_vinculados.tgeneral2 := registro.tgeneral2;
        rgastos_vinculados.tgeneral3 := 0.00;
        IF (
            ( rgastos_vinculados.moneda <> 'PEN' ) AND ( rgastos_vinculados.moneda <> 'USD' )
        ) THEN
            rgastos_vinculados.tgeneral3 := rgastos_vinculados.tgeneral2;
            BEGIN
                SELECT
                    venta
                INTO v_tipcam
                FROM
                    tcambio
                WHERE
                        id_cia = pin_id_cia
                    AND moneda = 'USD'
                    AND fecha = CAST(rgastos_vinculados.femisi AS DATE);

            EXCEPTION
                WHEN no_data_found THEN
                    v_tipcam := NULL;
            END;

            IF ( v_tipcam IS NULL ) THEN
                v_tipcam := 0.0;
            END IF;
            rgastos_vinculados.tgeneral2 := rgastos_vinculados.tgeneral1 / v_tipcam;
        END IF;

        PIPE ROW ( rgastos_vinculados );
    END LOOP;

END sp00_gastos_vinculados_orden_importacion_v2;

/
