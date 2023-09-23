--------------------------------------------------------
--  DDL for Package Body PACK_REPORTE_PUNTO_VENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_REPORTE_PUNTO_VENTA" AS

    FUNCTION sp_cuadre_caja (
        pin_id_cia    IN  NUMBER,
        pin_codsuc    IN  NUMBER,
        pin_pnumcaja  IN  NUMBER,
        pin_fecha     IN  DATE
    ) RETURN t_cuadre_caja
        PIPELINED
    AS

        v_table       r_cuadre_caja := r_cuadre_caja(NULL, NULL, NULL, NULL, NULL,
              NULL, NULL);
        v_f119        VARCHAR2(30);
        v_f140        VARCHAR2(30);
        CURSOR cur_total_ingreso_otros IS
        SELECT
            1                                             AS flag,
            1                                             AS orden,
            'I'                                           AS id,
            CAST('TOTAL INGRESOS' AS VARCHAR2(50))        AS despago,
            CAST(nvl(SUM(nvl((
                CASE
                    WHEN((d4.tipmon = 'PEN')
                         AND(d4.tipdep NOT IN(
                        103/*COMPRA DE DOLARES*/
                    ))) THEN
                        d4.impor01
                    ELSE
                        0
                END
            ), 0)), 0) + nvl(SUM(nvl((
                CASE
                    WHEN d5.tipmon = 'PEN' THEN
                        d5.impor01
                    ELSE
                        0
                END
            ), 0)), 0) AS NUMERIC(16, 2)) AS importemn,
            CAST(nvl(SUM(nvl((
                CASE
                    WHEN d4.tipmon = 'USD' THEN
                        d4.impor02
                    ELSE
                        0
                END
            ), 0)), 0) + nvl(SUM(nvl((
                CASE
                    WHEN d5.tipmon = 'USD' THEN
                        d5.impor02
                    ELSE
                        0
                END
            ), 0)), 0) AS NUMERIC(16, 2)) AS importeme,
            CAST('' AS CHAR(1))                           AS swcomven
        FROM
            dcta102  d2
            LEFT OUTER JOIN dcta104  d4 ON d4.id_cia = d2.id_cia
                                          AND d4.libro = d2.libro
                                          AND d4.periodo = d2.periodo
                                          AND d4.mes = d2.mes
                                          AND d4.secuencia = d2.secuencia
            LEFT OUTER JOIN dcta105  d5 ON d5.id_cia = d2.id_cia
                                          AND d5.libro = d2.libro
                                          AND d5.periodo = d2.periodo
                                          AND d5.mes = d2.mes
                                          AND d5.secuencia = d2.secuencia
        WHERE
                d2.id_cia = pin_id_cia
            AND d2.libro IN (
                v_f119,/*Planilla de cobranza Tienda -68*/
                v_f140/*Planilla de canje de cheques Tienda 71*/
            )
            AND d2.codsuc = pin_codsuc
            AND d2.situac = 'B'
            AND ( ( ( d4.situac = 'B' )
                    AND ( d4.tipdep IN (
                8,/*EFECTIVO*/
                9,/*EFECTIVO CAJA*/
                12,/*REDONDEO_F*/
                13,/*REDONDEO_C*/
                103,/*COMPRA DE DOLARES*/
                107,/*ANTICIPO CAJA*/
                999/*VUELTO*/
            ) ) )
                  OR ( d5.situac = 'B' ) )
            AND ( ( ( pin_pnumcaja = - 1 )
                    AND d2.femisi = pin_fecha )
                  OR ( d2.numcaja = pin_pnumcaja ) );

        CURSOR cur_total_ingreso_tarjetas IS
        SELECT
            1                                             AS flag,
            1                                             AS orden,
            'I'                                           AS id,
            CAST('TOTAL INGRESOS' AS VARCHAR2(50))        AS despago,
            CAST(nvl(SUM(nvl((
                CASE
                    WHEN((d4.tipmon = 'PEN')
                         AND(d4.tipdep NOT IN(
                        103/*COMPRA DE DOLARES*/
                    ))) THEN
                        d4.impor01
                    ELSE
                        0
                END
            ), 0)), 0) + nvl(SUM(nvl((
                CASE
                    WHEN d5.tipmon = 'PEN' THEN
                        d5.impor01
                    ELSE
                        0
                END
            ), 0)), 0) AS NUMERIC(16, 2)) AS importemn,
            CAST(nvl(SUM(nvl((
                CASE
                    WHEN d4.tipmon = 'USD' THEN
                        d4.impor02
                    ELSE
                        0
                END
            ), 0)), 0) + nvl(SUM(nvl((
                CASE
                    WHEN d5.tipmon = 'USD' THEN
                        d5.impor02
                    ELSE
                        0
                END
            ), 0)), 0) AS NUMERIC(16, 2)) AS importeme,
            CAST('' AS CHAR(1))                           AS swcomven
        FROM
            dcta102       d2
            LEFT OUTER JOIN dcta104       d4 ON d4.id_cia = d2.id_cia
                                          AND d4.libro = d2.libro
                                          AND d4.periodo = d2.periodo
                                          AND d4.mes = d2.mes
                                          AND d4.secuencia = d2.secuencia
            LEFT OUTER JOIN dcta105       d5 ON d5.id_cia = d2.id_cia
                                          AND d5.libro = d2.libro
                                          AND d5.periodo = d2.periodo
                                          AND d5.mes = d2.mes
                                          AND d5.secuencia = d2.secuencia
            INNER JOIN m_pago        m ON m.id_cia = d4.id_cia
                                   AND m.codigo = d4.tipdep
            INNER JOIN m_pago_clase  mc ON mc.id_cia = m.id_cia
                                          AND mc.codmpago = m.codigo
                                          AND mc.clase = 7 /*tarjeta de credito*/
        WHERE
                d2.id_cia = pin_id_cia
            AND d2.libro IN (
                v_f119,/*Planilla de cobranza Tienda -68*/
                v_f140/*Planilla de canje de cheques Tienda 71*/
            )
            AND d2.codsuc = pin_codsuc
            AND d2.situac = 'B'
            AND ( ( d4.situac = 'B' )
                  OR ( d5.situac = 'B' ) )
            AND ( ( ( pin_pnumcaja = - 1 )
                    AND d2.femisi = pin_fecha )
                  OR ( d2.numcaja = pin_pnumcaja ) );



  --{ RESTA DE LA TARJETA DE CREDITO }

        CURSOR cur_resta_tarjetas IS
        SELECT
            1                          AS flag,
            2                          AS orden,
            'I'                        AS id,
            m.descri                   AS despago,
            CAST(nvl(SUM(abs(nvl(
                CASE
                    WHEN d4.tipmon = 'PEN' THEN
                        (d4.impor01)
                    ELSE
                        0
                END, 0))), 0) * - 1 AS NUMERIC(16, 2)) AS importemn,
            CAST(nvl(SUM(abs(nvl(
                CASE
                    WHEN d4.tipmon = 'USD' THEN
                        (d4.impor02)
                    ELSE
                        0
                END, 0))), 0) * - 1 AS NUMERIC(16, 2)) AS importeme,
            CAST('' AS CHAR(1))        AS swcomven
        FROM
            dcta102       d2
            LEFT OUTER JOIN dcta104       d4 ON d4.id_cia = d2.id_cia
                                          AND d4.libro = d2.libro
                                          AND d4.periodo = d2.periodo
                                          AND d4.mes = d2.mes
                                          AND d4.secuencia = d2.secuencia
            INNER JOIN m_pago        m ON m.id_cia = d4.id_cia
                                   AND m.codigo = d4.tipdep
            INNER JOIN m_pago_clase  mc ON mc.id_cia = m.id_cia
                                          AND mc.codmpago = m.codigo
                                          AND mc.clase = 7 /*tarjeta de credito*/
        WHERE
                d2.id_cia = pin_id_cia
            AND d2.libro IN (
                v_f119/*Planilla de cobranza Tienda -68*/
            )
            AND d2.codsuc = pin_codsuc
            AND d2.situac = 'B'
            AND d4.situac = 'B'
            AND ( ( ( pin_pnumcaja = - 1 )
                    AND d2.femisi = pin_fecha )
                  OR ( d2.numcaja = pin_pnumcaja ) )
        GROUP BY
            m.descri;

        CURSOR cur_resta_cheques_anticipocaja IS
        SELECT
            1                          AS flag,
            2                          AS orden,
            'I'                        AS id,
            'TARJETA'                  AS despago,
            CAST(nvl(SUM(abs(nvl(
                CASE
                    WHEN d4.tipmon = 'PEN' THEN
                        (d4.impor01)
                    ELSE
                        0
                END, 0))), 0) * - 1 AS NUMERIC(16, 2)) AS importemn,
            CAST(nvl(SUM(abs(nvl(
                CASE
                    WHEN d4.tipmon = 'USD' THEN
                        (d4.impor02)
                    ELSE
                        0
                END, 0))), 0) * - 1 AS NUMERIC(16, 2)) AS importeme,
            CAST('' AS CHAR(1))        AS swcomven
        FROM
            dcta102  d2
            LEFT OUTER JOIN dcta104  d4 ON d4.id_cia = d2.id_cia
                                          AND d4.libro = d2.libro
                                          AND d4.periodo = d2.periodo
                                          AND d4.mes = d2.mes
                                          AND d4.secuencia = d2.secuencia
            LEFT OUTER JOIN m_pago   m ON m.id_cia = d4.id_cia
                                        AND m.codigo = d4.tipdep
        WHERE
                d2.id_cia = pin_id_cia
            AND d2.libro IN (
                v_f119/*Planilla de cobranza Tienda -68*/
            )
            AND d2.codsuc = pin_codsuc
            AND d4.tipdep IN (
                7,/*CHEQUES*/
                107/*ANTICIPO CAJA*/
            )
            AND d2.situac = 'B'
            AND d4.situac = 'B'
            AND ( ( ( pin_pnumcaja = - 1 )
                    AND d2.femisi = pin_fecha )
                  OR ( d2.numcaja = pin_pnumcaja ) )
        GROUP BY
            m.descri;

        CURSOR cur_resta_de_cheques IS
        SELECT
            1                                     AS flag,
            2                                     AS orden,
            'I'                                   AS id,
            CAST('CHEQUES' AS VARCHAR(50))        AS despago,
            CAST(nvl(SUM(abs(nvl(
                CASE
                    WHEN d5.tipmon = 'PEN' THEN
                        (d5.impor01)
                    ELSE
                        0
                END, 0))), 0) * - 1 AS NUMERIC(16, 2)) AS importemn,
            CAST(nvl(SUM(abs(nvl(
                CASE
                    WHEN d5.tipmon = 'USD' THEN
                        (d5.impor02)
                    ELSE
                        0
                END, 0))), 0) * - 1 AS NUMERIC(16, 2)) AS importeme,
            CAST('' AS CHAR(1))                   AS swcomven
        FROM
            dcta102  d2
            LEFT OUTER JOIN dcta105  d5 ON d5.id_cia = d2.id_cia
                                          AND d5.libro = d2.libro
                                          AND d5.periodo = d2.periodo
                                          AND d5.mes = d2.mes
                                          AND d5.secuencia = d2.secuencia
        WHERE
                d2.id_cia = pin_id_cia
            AND d2.libro IN (
                v_f119/*Planilla de cobranza Tienda -68*/
            )
            AND d2.codsuc = pin_codsuc
            AND d2.situac = 'B'
            AND d5.situac = 'B'
            AND ( ( ( pin_pnumcaja = - 1 )
                    AND d2.femisi = pin_fecha )
                  OR ( d2.numcaja = pin_pnumcaja ) );	

  /* RESTA DE VUELTO Y  OPERACIÓN SEGUN TIPO DE REDONDEO */

        CURSOR cur_vuelto_operacion_segun_tipo_de_redondeo IS
        SELECT
            2                          AS flag,
            3                          AS orden,
            'I'                        AS id,
            m.descri                   AS despago,
            CAST(nvl(SUM(nvl(
                CASE
                    WHEN d4.tipmon = 'PEN' THEN
                        (
                            CASE
                                WHEN mc.vchar = 'S' THEN
                                    d4.impor01 * - 1
                                ELSE
                                    d4.impor01
                            END
                        )
                    ELSE
                        0
                END, 0)), 0) AS NUMERIC(16, 2)) AS importemn,
            CAST(nvl(SUM(nvl(
                CASE
                    WHEN d4.tipmon = 'USD' THEN
                        (
                            CASE
                                WHEN mc.vchar = 'S' THEN
                                    d4.impor01 * - 1
                                ELSE
                                    d4.impor01
                            END
                        )
                    ELSE
                        0
                END, 0)), 0) AS NUMERIC(16, 2)) AS importeme,
            CAST('' AS CHAR(1))        AS swcomven
        FROM
            dcta102       d2
            LEFT OUTER JOIN dcta104       d4 ON d4.id_cia = d2.id_cia
                                          AND d4.libro = d2.libro
                                          AND d4.periodo = d2.periodo
                                          AND d4.mes = d2.mes
                                          AND d4.secuencia = d2.secuencia
            LEFT OUTER JOIN m_pago        m ON m.id_cia = d4.id_cia
                                        AND m.codigo = d4.tipdep
            LEFT OUTER JOIN m_pago_clase  mc ON mc.id_cia = m.id_cia
                                               AND mc.codmpago = m.codigo
                                               AND mc.clase = 3/*Invertir signo en reportes de caja*/
        WHERE
                d2.id_cia = pin_id_cia
            AND d2.libro IN (
                v_f119
            )
            AND d2.codsuc = pin_codsuc
            AND d4.tipdep IN (
                12,/*REDONDEO_F*/
                13,/*REDONDEO_C*/
                103/*COMPRA DE DOLARES*/
            )
            AND d2.situac = 'B'
            AND d4.situac = 'B'
            AND ( ( ( pin_pnumcaja = - 1 )
                    AND d2.femisi = pin_fecha )
                  OR ( d2.numcaja = pin_pnumcaja ) )
        GROUP BY
            m.descri,
            mc.vchar;

 /* RESTA COMPRA DE DOLARES */

        CURSOR cur_resta_compra_de_dolares IS
        SELECT
            2                                               AS flag,
            4                                               AS orden,
            'I'                                             AS id,
            CAST('COMPRA DE DOLARES' AS VARCHAR(50))        AS despago,
            CAST(nvl(SUM(nvl(
                CASE
                    WHEN a.moneda = 'PEN' THEN
                        a.impor01
                    ELSE
                        0
                END, 0) * d.signo), 0) AS NUMERIC(16, 2)) AS importemn,
            CAST(nvl(SUM(nvl(
                CASE
                    WHEN a.moneda = 'USD' THEN
                        a.impor02
                    ELSE
                        0
                END, 0) * d.signo), 0) AS NUMERIC(16, 2)) AS importeme,
            mc.vchar                                        AS swcomven   /* Campo para llevar el control de compra y venta*/
        FROM
                 compr010 a
            INNER JOIN tdocume         d ON d.id_cia = a.id_cia
                                    AND d.codigo = a.tdocum
            LEFT OUTER JOIN tdocume_clases  dc ON dc.id_cia = a.id_cia
                                                 AND dc.tipdoc = a.tdocum
                                                 AND dc.moneda = ''
                                                 AND dc.clase = 1
            LEFT OUTER JOIN m_pago          mp ON mp.id_cia = a.id_cia
                                         AND mp.codigo = (
                CASE
                    WHEN (
                        SELECT
                            sp000_valida_datos_numericos(dc.codigo)
                        FROM
                            dual
                    ) = 1 THEN
                        CAST(dc.codigo AS SMALLINT)
                    ELSE
                        0
                END
            )
            LEFT OUTER JOIN m_pago_clase    mc ON mc.id_cia = mp.id_cia
                                               AND mc.codmpago = mp.codigo
                                               AND mc.clase = 4/*Compra/Venta de dólares*/
        WHERE
                a.id_cia = pin_id_cia
            AND ( a.tipcaja IN (
                604
            ) )
            AND a.situac <> 9
            AND a.codsuc = pin_codsuc
            AND a.motivo = 'C'
            AND ( ( ( pin_pnumcaja = - 1 )
                    AND a.FEMISI = pin_fecha )
                  OR ( a.doccaja = pin_pnumcaja ) )
        GROUP BY
            mp.descri,
            mc.vchar;

        CURSOR cur_resta_venta_de_dolares IS
        SELECT
            2                       AS flag,
            5                       AS orden,
            'I'                     AS id,
            ( 'VENTA DE DOLARES' )  AS despago,
            ( nvl(SUM(nvl(
                CASE
                    WHEN a.moneda = 'PEN' THEN
                        a.impor01
                    ELSE
                        0
                END, 0) * d.signo), 0) ) AS importemn,
            ( nvl(SUM(nvl(
                CASE
                    WHEN a.moneda = 'USD' THEN
                        a.impor02
                    ELSE
                        0
                END, 0) * d.signo), 0) ) AS importeme,
            mc.vchar                AS swcomven   /*Campo para llevar el control de compra y venta */
        FROM
                 compr010 a
            INNER JOIN tdocume         d ON d.id_cia = a.id_cia
                                    AND d.codigo = a.tdocum
            LEFT OUTER JOIN tdocume_clases  dc ON dc.id_cia = a.id_cia
                                                 AND dc.tipdoc = a.tdocum
                                                 AND dc.moneda = ''
                                                 AND dc.clase = 1
            LEFT OUTER JOIN m_pago          mp ON mp.id_cia = a.id_cia
                                         AND mp.codigo = (
                CASE
                    WHEN (
                        SELECT
                            sp000_valida_datos_numericos(dc.codigo)
                        FROM
                            dual
                    ) = 1 THEN
                        CAST(dc.codigo AS SMALLINT)
                    ELSE
                        0
                END
            )
            LEFT OUTER JOIN m_pago_clase    mc ON mc.id_cia = mp.id_cia
                                               AND mc.codmpago = mp.codigo
                                               AND mc.clase = 4/* Compra/Venta de dólares*/
        WHERE
                a.id_cia = pin_id_cia
            AND ( a.tipcaja IN (
                604
            ) )
            AND a.situac <> 9
            AND a.codsuc = pin_codsuc
            AND a.motivo = 'V'
            AND ( ( ( pin_pnumcaja = - 1 )
                    AND ( a.FEMISI = pin_fecha ) )
                  OR ( a.doccaja = pin_pnumcaja ) )
        GROUP BY
            mp.descri,
            mc.vchar;           

  --{ INGRESO Y SALIDA A CAJA - GENERAL }

        CURSOR cur_ingreso_salida_caja_general IS
        SELECT
            3                                       AS flag,
            4                                       AS orden,
            'S'                                     AS id,
            CAST(mp.descri AS VARCHAR(50))          AS despago,
            CAST(nvl(SUM(nvl(
                CASE
                    WHEN a.moneda = 'PEN' THEN
                        a.impor01
                    ELSE
                        0
                END, 0) * d.signo), 0) AS NUMERIC(16, 2)) AS importemn,
            CAST(nvl(SUM(nvl(
                CASE
                    WHEN a.moneda = 'USD' THEN
                        a.impor02
                    ELSE
                        0
                END, 0) * d.signo), 0) AS NUMERIC(16, 2)) AS importeme,
            mc.vchar                                AS swcomven   /*Campo para llevar el control de compra y venta */
        FROM
                 compr010 a
            INNER JOIN tdocume         d ON d.id_cia = a.id_cia
                                    AND d.codigo = a.tdocum
            LEFT OUTER JOIN tdocume_clases  dc ON dc.id_cia = a.id_cia
                                                 AND dc.tipdoc = a.tdocum
                                               --  AND dc.moneda = ''
                                                 AND dc.clase = 1
            LEFT OUTER JOIN m_pago          mp ON mp.id_cia = a.id_cia
                                         AND mp.codigo = (
                CASE
                    WHEN (
                        SELECT
                            sp000_valida_datos_numericos(dc.codigo)
                        FROM
                            dual
                    ) = 1 THEN
                        CAST(dc.codigo AS SMALLINT)
                    ELSE
                        0
                END
            )
            LEFT OUTER JOIN m_pago_clase    mc ON mc.id_cia = mp.id_cia
                                               AND mc.codmpago = mp.codigo
                                               AND mc.clase = 4/* Compra/Venta de dólares*/
        WHERE
                a.id_cia = pin_id_cia
            AND ( a.tipcaja IN (
                604
            ) )
            AND a.situac <> 9
            AND (NOT ( a.motivo IN (
                'V',
                'C'
            ) ) OR a.motivo IS NULL )  
            AND a.codsuc = pin_codsuc
            AND ( ( ( pin_pnumcaja = - 1 )
                    AND a.FEMISI = pin_fecha )
                  OR ( a.doccaja = pin_pnumcaja ) )
        GROUP BY
            mp.descri,
            mc.vchar;

 -- EFECTIVO CUADRE DE CAJA }

        CURSOR cur_efectivo_cuadre_caja IS
        SELECT
            4                          AS flag,
            1                          AS orden,
            'O'                        AS id,
            m.descri                   AS despago,
            CAST(nvl(SUM(nvl(
                CASE
                    WHEN d4.tipmon = 'PEN' THEN
                        (d4.impor01)
                    ELSE
                        0
                END, 0)), 0) AS NUMERIC(16, 2)) AS importemn,
            CAST(nvl(SUM(nvl(
                CASE
                    WHEN d4.tipmon = 'USD' THEN
                        (d4.impor02)
                    ELSE
                        0
                END, 0)), 0) AS NUMERIC(16, 2)) AS importeme,
            CAST('' AS CHAR(1))        AS swcomven
        FROM
            dcta102  d2
            LEFT OUTER JOIN dcta104  d4 ON d4.id_cia = d2.id_cia
                                          AND d4.libro = d2.libro
                                          AND d4.periodo = d2.periodo
                                          AND d4.mes = d2.mes
                                          AND d4.secuencia = d2.secuencia
            LEFT OUTER JOIN m_pago   m ON m.id_cia = d4.id_cia
                                        AND m.codigo = d4.tipdep
        WHERE
                d2.id_cia = pin_id_cia
            AND d2.libro IN (
                v_f140/*Planilla de canje de cheques Tienda -71*/
            )
            AND d2.codsuc = pin_codsuc
            AND d4.tipdep IN (
                28/*TRANSFERENCIA GRATUITA*/
            )
            AND d2.situac = 'B'
            AND d4.situac = 'B'
            AND ( ( ( pin_pnumcaja = - 1 )
                    AND ( d2.femisi = pin_fecha ) )
                  OR ( d2.numcaja = pin_pnumcaja ) )
        GROUP BY
            m.descri;

        v_flag        SMALLINT := 0;
        v_orden       SMALLINT := 0;
        v_id          VARCHAR2(1) := '';
        v_despago     VARCHAR2(50) := '';
        v_importemn   NUMERIC(16, 2) := 0;
        v_importeme   NUMERIC(16, 2) := 0;
        v_importemnc  NUMERIC(16, 2) := 0;
        v_importemnv  NUMERIC(16, 2) := 0;
        v_importemec  NUMERIC(16, 2) := 0;
        v_importemev  NUMERIC(16, 2) := 0;
        v_swcomven    CHAR(1) := '';
    BEGIN
    -- TAREA: Se necesita implantación para FUNCTION PACK_REPORTE_PUNTO_VENTA.sp_cuadre_caja
        DECLARE BEGIN
            SELECT
                vstrg
            INTO v_f119
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 119;

        EXCEPTION
            WHEN no_data_found THEN
                v_f119 := '';
        END;

        /* Planilla de canje de cheques Tienda*/

        DECLARE BEGIN
            SELECT
                vstrg
            INTO v_f140
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 140;

        EXCEPTION
            WHEN no_data_found THEN
                v_f140 := '';
        END;

        v_importemn := 0;
        v_importeme := 0;
        v_importemnc := 0;
        v_importemnv := 0;
        v_importemec := 0;
        v_importemev := 0;
        FOR rti_tarjeta IN cur_total_ingreso_tarjetas LOOP
            v_importemn := rti_tarjeta.importemn;
            v_importeme := rti_tarjeta.importeme;
            IF ( rti_tarjeta.swcomven = 'C' ) THEN
                v_importemnc := rti_tarjeta.importemn * -1;
                v_importemec := rti_tarjeta.importeme;
            END IF;

            IF ( rti_tarjeta.swcomven = 'V' ) THEN
                v_importemnv := rti_tarjeta.importemn;
                v_importemev := rti_tarjeta.importeme * -1;
            END IF;

        END LOOP;

        FOR rti_otros IN cur_total_ingreso_otros LOOP
            v_table.flag := rti_otros.flag;
            v_table.orden := rti_otros.orden;
            v_table.id := rti_otros.id;
            v_table.despago := rti_otros.despago;
            v_table.importemn := rti_otros.importemn + v_importemn;
            v_table.importeme := rti_otros.importeme + v_importeme;
            IF ( rti_otros.swcomven = 'C' ) THEN
                v_table.importemn := rti_otros.importemn * -1;
                v_table.importeme := rti_otros.importeme;
                v_table.importemn := v_table.importemn + v_importemnc;
                v_table.importeme := v_table.importeme + v_importemec;
            END IF;

            IF ( rti_otros.swcomven = 'V' ) THEN
                v_table.importemn := rti_otros.importemn;
                v_table.importeme := rti_otros.importeme * -1;
                v_table.importemn := v_table.importemn + v_importemnv;
                v_table.importeme := v_table.importeme + v_importemev;
            END IF;

            v_table.swcomven := rti_otros.swcomven;
            PIPE ROW ( v_table );
        END LOOP;

        FOR rres_tarjeta IN cur_resta_tarjetas LOOP
            v_table.flag := rres_tarjeta.flag;
            v_table.orden := rres_tarjeta.orden;
            v_table.id := rres_tarjeta.id;
            v_table.despago := rres_tarjeta.despago;
            v_table.importemn := rres_tarjeta.importemn;
            v_table.importeme := rres_tarjeta.importeme;
            IF ( rres_tarjeta.swcomven = 'C' ) THEN
                v_table.importemn := rres_tarjeta.importemn * -1;
                v_table.importeme := rres_tarjeta.importeme;
            END IF;

            IF ( rres_tarjeta.swcomven = 'V' ) THEN
                v_table.importemn := rres_tarjeta.importemn;
                v_table.importeme := rres_tarjeta.importeme * -1;
            END IF;

            v_table.swcomven := rres_tarjeta.swcomven;
            PIPE ROW ( v_table );
        END LOOP;

        FOR rres_cheque_anticipocaja IN cur_resta_cheques_anticipocaja LOOP
            v_table.flag := rres_cheque_anticipocaja.flag;
            v_table.orden := rres_cheque_anticipocaja.orden;
            v_table.id := rres_cheque_anticipocaja.id;
            v_table.despago := rres_cheque_anticipocaja.despago;
            v_table.importemn := rres_cheque_anticipocaja.importemn;
            v_table.importeme := rres_cheque_anticipocaja.importeme;
            IF ( rres_cheque_anticipocaja.swcomven = 'C' ) THEN
                v_table.importemn := rres_cheque_anticipocaja.importemn * -1;
                v_table.importeme := rres_cheque_anticipocaja.importeme;
            END IF;

            IF ( rres_cheque_anticipocaja.swcomven = 'V' ) THEN
                v_table.importemn := rres_cheque_anticipocaja.importemn;
                v_table.importeme := rres_cheque_anticipocaja.importeme * -1;
            END IF;

            v_table.swcomven := rres_cheque_anticipocaja.swcomven;
            PIPE ROW ( v_table );
        END LOOP;

        FOR rres_cheque IN cur_resta_de_cheques LOOP
            v_table.flag := rres_cheque.flag;
            v_table.orden := rres_cheque.orden;
            v_table.id := rres_cheque.id;
            v_table.despago := rres_cheque.despago;
            v_table.importemn := rres_cheque.importemn;
            v_table.importeme := rres_cheque.importeme;
            IF ( rres_cheque.swcomven = 'C' ) THEN
                v_table.importemn := rres_cheque.importemn * -1;
                v_table.importeme := rres_cheque.importeme;
            END IF;

            IF ( rres_cheque.swcomven = 'V' ) THEN
                v_table.importemn := rres_cheque.importemn;
                v_table.importeme := rres_cheque.importeme * -1;
            END IF;

            v_table.swcomven := rres_cheque.swcomven;
            PIPE ROW ( v_table );
        END LOOP;

        FOR rres_vopeseguntred IN cur_vuelto_operacion_segun_tipo_de_redondeo LOOP
            v_table.flag := rres_vopeseguntred.flag;
            v_table.orden := rres_vopeseguntred.orden;
            v_table.id := rres_vopeseguntred.id;
            v_table.despago := rres_vopeseguntred.despago;
            v_table.importemn := rres_vopeseguntred.importemn + v_importemn;
            v_table.importeme := rres_vopeseguntred.importeme + v_importeme;
            IF ( rres_vopeseguntred.swcomven = 'C' ) THEN
                v_table.importemn := rres_vopeseguntred.importemn * -1;
                v_table.importeme := rres_vopeseguntred.importeme;
                v_table.importemn := v_table.importemn + v_importemnc;
                v_table.importeme := v_table.importeme + v_importemec;
            END IF;

            IF ( rres_vopeseguntred.swcomven = 'V' ) THEN
                v_table.importemn := rres_vopeseguntred.importemn;
                v_table.importeme := rres_vopeseguntred.importeme * -1;
                v_table.importemn := v_table.importemn + v_importemnv;
                v_table.importeme := v_table.importeme + v_importemev;
            END IF;

            v_table.swcomven := rres_vopeseguntred.swcomven;
            PIPE ROW ( v_table );
        END LOOP;

        FOR rres_compradolar IN cur_resta_compra_de_dolares LOOP
            v_table.flag := rres_compradolar.flag;
            v_table.orden := rres_compradolar.orden;
            v_table.id := rres_compradolar.id;
            v_table.despago := rres_compradolar.despago;
            v_table.importemn := rres_compradolar.importemn;
            v_table.importeme := rres_compradolar.importeme;
            IF ( rres_compradolar.swcomven = 'C' ) THEN
                v_table.importemn := rres_compradolar.importemn * -1;
                v_table.importeme := rres_compradolar.importeme;
            END IF;

            IF ( rres_compradolar.swcomven = 'V' ) THEN
                v_table.importemn := rres_compradolar.importemn;
                v_table.importeme := rres_compradolar.importeme * -1;
            END IF;

            v_table.swcomven := rres_compradolar.swcomven;
            PIPE ROW ( v_table );
        END LOOP;

        FOR rres_ventadolar IN cur_resta_venta_de_dolares LOOP
            v_table.flag := rres_ventadolar.flag;
            v_table.orden := rres_ventadolar.orden;
            v_table.id := rres_ventadolar.id;
            v_table.despago := rres_ventadolar.despago;
            v_table.importemn := rres_ventadolar.importemn;
            v_table.importeme := rres_ventadolar.importeme;
            IF ( rres_ventadolar.swcomven = 'C' ) THEN
                v_table.importemn := rres_ventadolar.importemn * -1;
                v_table.importeme := rres_ventadolar.importeme;
            END IF;

            IF ( rres_ventadolar.swcomven = 'V' ) THEN
                v_table.importemn := rres_ventadolar.importemn;
                v_table.importeme := rres_ventadolar.importeme * -1;
            END IF;

            v_table.swcomven := rres_ventadolar.swcomven;
            PIPE ROW ( v_table );
        END LOOP;

        FOR rres_ingsalcajagen IN cur_ingreso_salida_caja_general LOOP
            v_table.flag := rres_ingsalcajagen.flag;
            v_table.orden := rres_ingsalcajagen.orden;
            v_table.id := rres_ingsalcajagen.id;
            v_table.despago := rres_ingsalcajagen.despago;
            v_table.importemn := rres_ingsalcajagen.importemn;
            v_table.importeme := rres_ingsalcajagen.importeme;
            IF ( rres_ingsalcajagen.swcomven = 'C' ) THEN
                v_table.importemn := rres_ingsalcajagen.importemn * -1;
                v_table.importeme := rres_ingsalcajagen.importeme;
            END IF;

            IF ( rres_ingsalcajagen.swcomven = 'V' ) THEN
                v_table.importemn := rres_ingsalcajagen.importemn;
                v_table.importeme := rres_ingsalcajagen.importeme * -1;
            END IF;

            v_table.swcomven := rres_ingsalcajagen.swcomven;
            PIPE ROW ( v_table );
        END LOOP;

        FOR refectivo_cuadre IN cur_efectivo_cuadre_caja LOOP
            v_table.flag := refectivo_cuadre.flag;
            v_table.orden := refectivo_cuadre.orden;
            v_table.id := refectivo_cuadre.id;
            v_table.despago := refectivo_cuadre.despago;
            v_table.importemn := refectivo_cuadre.importemn;
            v_table.importeme := refectivo_cuadre.importeme;
            IF ( refectivo_cuadre.swcomven = 'C' ) THEN
                v_table.importemn := refectivo_cuadre.importemn * -1;
                v_table.importeme := refectivo_cuadre.importeme;
            END IF;

            IF ( refectivo_cuadre.swcomven = 'V' ) THEN
                v_table.importemn := refectivo_cuadre.importemn;
                v_table.importeme := refectivo_cuadre.importeme * -1;
            END IF;

            v_table.swcomven := refectivo_cuadre.swcomven;
            PIPE ROW ( v_table );
        END LOOP;

    END sp_cuadre_caja;

    FUNCTION sp_cuadre_caja_detallado (
        pin_id_cia    IN  NUMBER,
        pin_codsuc    IN  NUMBER,
        pin_pnumcaja  IN  NUMBER,
        pin_fecha     IN  DATE
    ) RETURN t_cuadre_caja_detallado
        PIPELINED
    AS

        v_f119      VARCHAR2(30);
        v_f140      VARCHAR2(30);
        v_codd103g  VARCHAR2(30);
        v_table     r_cuadre_caja_detallado := r_cuadre_caja_detallado(NULL, NULL, NULL, NULL, NULL,
                        NULL, NULL, NULL, NULL, NULL,
                        NULL, NULL, NULL, NULL, NULL);
        CURSOR cur_efectivo_otros IS
        SELECT DISTINCT
            CAST('A' AS CHAR(1))                     AS flag,
            CAST('I' AS CHAR(1))                     AS id,
            d2.numcaja,
            CAST(m.filtro AS INTEGER)                AS tipdep,
            d2.periodo,
            d2.mes,
            d2.secuencia,
            CAST(1 AS INTEGER)                       AS item,
            CAST(d2.concep AS VARCHAR(100))          AS concep,
            CAST('EFECTIVO' AS VARCHAR(50))          AS dtipdep,
            CAST('0' AS VARCHAR(3))                  AS motivo,
            CAST(d3.docume AS VARCHAR(25))           AS docume,
            CAST(SUM((
                CASE
                    WHEN d4.tipmon = 'PEN' THEN
                        1
                    ELSE
                        0
                END
                * d4.impor01)) AS NUMERIC(16, 2)) AS importemn,
            CAST(SUM((
                CASE
                    WHEN d4.tipmon = 'USD' THEN
                        1
                    ELSE
                        0
                END
                * d4.impor02)) AS NUMERIC(16, 2)) AS importeme,
            0                                        AS idtarjeta
        FROM
            dcta102  d2
            LEFT OUTER JOIN dcta103  d3 ON d3.id_cia = d2.id_cia
                                          AND d3.libro = d2.libro
                                          AND d3.periodo = d2.periodo
                                          AND d3.mes = d2.mes
                                          AND d3.secuencia = d2.secuencia
            LEFT OUTER JOIN dcta104  d4 ON d4.id_cia = d2.id_cia
                                          AND d4.libro = d2.libro
                                          AND d4.periodo = d2.periodo
                                          AND d4.mes = d2.mes
                                          AND d4.secuencia = d2.secuencia
            LEFT OUTER JOIN m_pago   m ON m.id_cia = d2.id_cia
                                        AND m.codigo = d4.tipdep
        WHERE
                d2.id_cia = pin_id_cia
            AND d2.libro IN (
                v_f119
            )
            AND d2.codsuc = pin_codsuc
            AND d2.situac = 'B'
            AND ( ( d4.situac = 'B' )
                  AND ( d4.tipdep IN (
                8,
                999
            ) ) )
            AND ( ( ( pin_pnumcaja = - 1 )
                    AND d2.femisi = pin_fecha )
                  OR ( d2.numcaja = pin_pnumcaja ) )
        GROUP BY
            d2.numcaja,
            d2.periodo,
            d2.mes,
            m.filtro,
            d2.secuencia,
            d2.concep,
            m.descri,
            d3.tipmon,
            d3.docume;

        CURSOR cur_efectivo_tarjeta IS
        SELECT DISTINCT
            CAST('A' AS CHAR(1))                     AS flag,
            CAST('I' AS CHAR(1))                     AS id,
            d2.numcaja,
--            CAST(m.filtro AS INTEGER)                AS tipdep,
            m.codigo                                 AS tipdep,/*-1 tarjeta */
            d2.periodo,
            d2.mes,
            d2.secuencia,
            CAST(1 AS INTEGER)                       AS item,
            CAST(d2.concep AS VARCHAR(100))          AS concep,
            CAST(m.descri AS VARCHAR(50))            AS dtipdep,
--            CAST('EFECTIVO' AS VARCHAR(50))          AS dtipdep,
            CAST('0' AS VARCHAR(3))                  AS motivo,
            CAST(d3.docume AS VARCHAR(25))           AS docume,
            CAST(SUM((
                CASE
                    WHEN d4.tipmon = 'PEN' THEN
                        1
                    ELSE
                        0
                END
                * d4.impor01)) AS NUMERIC(16, 2)) AS importemn,
            CAST(SUM((
                CASE
                    WHEN d4.tipmon = 'USD' THEN
                        1
                    ELSE
                        0
                END
                * d4.impor02)) AS NUMERIC(16, 2)) AS importeme,
            1                                        AS idtarjeta
        FROM
            dcta102       d2
            LEFT OUTER JOIN dcta103       d3 ON d3.id_cia = d2.id_cia
                                          AND d3.libro = d2.libro
                                          AND d3.periodo = d2.periodo
                                          AND d3.mes = d2.mes
                                          AND d3.secuencia = d2.secuencia
            LEFT OUTER JOIN dcta104       d4 ON d4.id_cia = d2.id_cia
                                          AND d4.libro = d2.libro
                                          AND d4.periodo = d2.periodo
                                          AND d4.mes = d2.mes
                                          AND d4.secuencia = d2.secuencia
            INNER JOIN m_pago        m ON m.id_cia = d2.id_cia
                                   AND m.codigo = d4.tipdep
            INNER JOIN m_pago_clase  mc ON mc.id_cia = m.id_cia
                                          AND mc.codmpago = m.codigo
                                          AND mc.clase = 7 /*tarjeta de credito*/
        WHERE
                d2.id_cia = pin_id_cia
            AND d2.libro IN (
                v_f119
            )
            AND d2.codsuc = pin_codsuc
            AND d2.situac = 'B'
            AND ( d4.situac = 'B' )
            AND ( ( ( pin_pnumcaja = - 1 )
                    AND d2.femisi = pin_fecha )
                  OR ( d2.numcaja = pin_pnumcaja ) )
        GROUP BY
            d2.numcaja,
            d2.periodo,
            d2.mes,
            m.codigo,
            mc.clase,
            d2.secuencia,
            d2.concep,
            m.descri,
            d3.tipmon,
            d3.docume;

    BEGIN

        /* Planilla de cobranza Tienda*/
        DECLARE BEGIN
            SELECT
                vstrg
            INTO v_f119
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 119;

        EXCEPTION
            WHEN no_data_found THEN
                v_f119 := NULL;
        END;


        /* Planilla de canje de cheques Tienda*/

        DECLARE BEGIN
            SELECT
                vstrg
            INTO v_f140
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 140;

        EXCEPTION
            WHEN no_data_found THEN
                v_f140 := NULL;
        END;


        /* medios de pago Planilla cobranza Tienda*/

        v_codd103g := '';
        FOR i IN (
            SELECT
                m.codigo
            FROM
                     m_pago m
                INNER JOIN m_pago_clase  mc ON mc.id_cia = m.id_cia
                                              AND mc.codmpago = m.codigo
                                              AND mc.clase = 1/*Visualizar en planilla de cobranza tienda*/
                                              AND upper(mc.vchar) = 'S'
                LEFT OUTER JOIN m_pago_clase  mc2 ON mc2.id_cia = m.id_cia
                                                    AND mc2.codmpago = m.codigo
                                                    AND mc2.clase = 2/*Sumar en los reportes o separarlos*/
            WHERE
                    m.id_cia = pin_id_cia
                AND m.signo = 1
                AND ( upper(mc2.vchar) = 'S' )
                AND 1 = 1
        ) LOOP
            v_codd103g := v_codd103g
                          || i.codigo
                          || ',';
        END LOOP;

        IF v_codd103g = '' THEN
            v_codd103g := '0';
        ELSE
            v_codd103g := substr(v_codd103g, 0, length(v_codd103g) - 1);
        END IF;

        FOR r_efe_tarjeta IN cur_efectivo_tarjeta LOOP
            v_table.flag := r_efe_tarjeta.flag;
            v_table.id := r_efe_tarjeta.id;
            v_table.numcaja := r_efe_tarjeta.numcaja;
            v_table.tipdep := r_efe_tarjeta.tipdep;
            v_table.periodo := r_efe_tarjeta.periodo;
            v_table.mes := r_efe_tarjeta.mes;
            v_table.secuencia := r_efe_tarjeta.secuencia;
            v_table.item := r_efe_tarjeta.item;
            v_table.concep := r_efe_tarjeta.concep;
            v_table.dtipdep := r_efe_tarjeta.dtipdep;
            v_table.motivo := r_efe_tarjeta.motivo;
            v_table.docume := r_efe_tarjeta.docume;
            v_table.importemn := r_efe_tarjeta.importemn;
            v_table.importeme := r_efe_tarjeta.importeme;
            v_table.idtarjeta := r_efe_tarjeta.idtarjeta;
            PIPE ROW ( v_table );
        END LOOP;

        FOR r_efec_otros IN cur_efectivo_otros LOOP
            v_table.flag := r_efec_otros.flag;
            v_table.id := r_efec_otros.id;
            v_table.numcaja := r_efec_otros.numcaja;
            v_table.tipdep := r_efec_otros.tipdep;
            v_table.periodo := r_efec_otros.periodo;
            v_table.mes := r_efec_otros.mes;
            v_table.secuencia := r_efec_otros.secuencia;
            v_table.item := r_efec_otros.item;
            v_table.concep := r_efec_otros.concep;
            v_table.dtipdep := r_efec_otros.dtipdep;
            v_table.motivo := r_efec_otros.motivo;
            v_table.docume := r_efec_otros.docume;
            v_table.importemn := r_efec_otros.importemn;
            v_table.importeme := r_efec_otros.importeme;
            v_table.idtarjeta := r_efec_otros.idtarjeta;
            PIPE ROW ( v_table );
        END LOOP;

        FOR e IN (
    /* VENTA DE DOLARES */
            SELECT
                CAST('A' AS CHAR(1))                    AS flag,
                CAST('I' AS CHAR(1))                    AS id,
                CAST(a.doccaja AS INTEGER)              AS numcaja,
                CAST(mp.codigo AS INTEGER)              AS tipdep,
                a.periodo,
                a.mes,
                CAST(NULL AS INTEGER)                   AS secuencia,
                CAST(NULL AS INTEGER)                   AS item,
                CAST(a.concep AS VARCHAR(100))          AS concep,
                CAST(mp.descri AS VARCHAR(50))          AS dtipdep,
                CAST(a.motivo AS VARCHAR(3))            AS motivo,
                CAST(a.docume AS VARCHAR(25))           AS docume,
                CAST(
                    CASE
                        WHEN a.moneda = 'PEN' THEN
                            a.impor01
                        ELSE
                            0
                    END
                    * d.signo AS NUMERIC(16, 2)) AS importemn,
                CAST(
                    CASE
                        WHEN a.moneda = 'USD' THEN
                            a.impor02
                        ELSE
                            0
                    END
                    * d.signo AS NUMERIC(16, 2)) AS importeme
            FROM
                     compr010 a
                INNER JOIN tdocume         d ON d.id_cia = a.id_cia
                                        AND d.codigo = a.tdocum
                LEFT OUTER JOIN tdocume_clases  dc ON dc.id_cia = a.id_cia
                                                     AND dc.tipdoc = a.tdocum
                                                     AND dc.moneda = '   '
                                                     AND dc.clase = 1
                LEFT OUTER JOIN m_pago          mp ON mp.id_cia = dc.id_cia
                                             AND mp.codigo = (
                    CASE
                        WHEN (
                            SELECT
                                sp000_valida_datos_numericos(dc.codigo)
                            FROM
                                dual
                        ) = 1 THEN
                            CAST(dc.codigo AS SMALLINT)
                        ELSE
                            0
                    END
                )
            WHERE
                    a.id_cia = pin_id_cia
                AND ( a.tipcaja IN (
                    604
                ) )
                AND a.situac <> 9
                AND a.codsuc = pin_codsuc
                AND ( a.motivo = 'V' )
                AND ( ( ( pin_pnumcaja = - 1 )
                        AND ( a.fingre = pin_fecha ) )
                      OR ( a.doccaja = pin_pnumcaja ) )
            UNION                
    /* COMPRA DE DOLARES */
            SELECT
                CAST('A' AS CHAR(1))                    AS flag,
                CAST('I' AS CHAR(1))                    AS id,
                CAST(a.doccaja AS INTEGER)              AS numcaja,
                CAST(mp.codigo AS INTEGER)              AS tipdep,
                a.periodo,
                a.mes,
                CAST(NULL AS INTEGER)                   AS secuencia,
                CAST(NULL AS INTEGER)                   AS item,
                CAST(a.concep AS VARCHAR(100))          AS concep,
                CAST(mp.descri AS VARCHAR(50))          AS dtipdep,
                CAST(a.motivo AS VARCHAR(3))            AS motivo,
                CAST(a.docume AS VARCHAR(25))           AS docume,
                CAST(
                    CASE
                        WHEN a.moneda = 'PEN' THEN
                            a.impor01
                        ELSE
                            0
                    END
                    * d.signo AS NUMERIC(16, 2)) AS importemn,
                CAST(
                    CASE
                        WHEN a.moneda = 'USD' THEN
                            a.impor02
                        ELSE
                            0
                    END
                    * d.signo AS NUMERIC(16, 2)) AS importeme
            FROM
                     compr010 a
                INNER JOIN tdocume         d ON d.id_cia = a.id_cia
                                        AND d.codigo = a.tdocum
                LEFT OUTER JOIN tdocume_clases  dc ON dc.id_cia = a.id_cia
                                                     AND dc.tipdoc = a.tdocum
                                                     AND dc.moneda = '   '
                                                     AND dc.clase = 1
                LEFT OUTER JOIN m_pago          mp ON mp.id_cia = dc.id_cia
                                             AND mp.codigo = (
                    CASE
                        WHEN (
                            SELECT
                                sp000_valida_datos_numericos(dc.codigo)
                            FROM
                                dual
                        ) = 1 THEN
                            CAST(dc.codigo AS SMALLINT)
                        ELSE
                            0
                    END
                )
            WHERE
                    a.id_cia = pin_id_cia
                AND ( a.tipcaja IN (
                    604
                ) )
                AND a.situac <> 9
                AND a.codsuc = pin_codsuc
                AND ( a.motivo = 'C' )
                AND ( ( ( pin_pnumcaja = - 1 )
                        AND ( a.fingre = pin_fecha ) )
                      OR ( a.doccaja = pin_pnumcaja ) )
            UNION                
    /* DETERMINACION DEL EFECTIVO NETO - SALIDAS (CHEQUES) */
            SELECT
                CAST('A' AS CHAR(1))                    AS flag,
                CAST('I' AS CHAR(1))                    AS id,
                d2.numcaja,
                CAST(7 AS INTEGER)                      AS tipdep,
                d2.periodo,
                d2.mes,
                d2.secuencia,
                CAST(d5.numdoc AS INTEGER)              AS item,
                CAST(CAST(d5.refere AS VARCHAR(16))
                     || ' / '
                     || CAST(d5.series AS VARCHAR(20))
                     || '-'
                     || CAST(d5.numdoc AS VARCHAR(15))
                     || ' '
                     || substr2(ef.descri, 1, 5)
                     || ' / F.Venc: '
                     || CAST(d5.fvenci AS VARCHAR(10)) AS VARCHAR(100)) AS concep,
                CAST('CHEQUES' AS VARCHAR(50))          AS dtipdep,
                CAST('0' AS VARCHAR(3))                 AS motivo,
                CAST(d3.docume AS VARCHAR(25))          AS docume,
                CAST(
                    CASE
                        WHEN d5.tipmon = 'PEN' THEN
                            d5.impor01
                        ELSE
                            0
                    END
                AS NUMERIC(16, 2)) AS importemn,
                CAST(
                    CASE
                        WHEN d5.tipmon = 'USD' THEN
                            d5.impor02
                        ELSE
                            0
                    END
                AS NUMERIC(16, 2)) AS importeme
            FROM
                dcta102       d2
                LEFT OUTER JOIN dcta105       d5 ON d5.id_cia = d2.id_cia
                                              AND d5.libro = d2.libro
                                              AND d5.periodo = d2.periodo
                                              AND d5.mes = d2.mes
                                              AND d5.secuencia = d2.secuencia
                LEFT OUTER JOIN dcta103       d3 ON d3.id_cia = d2.id_cia
                                              AND d3.libro = d2.libro
                                              AND d3.periodo = d2.periodo
                                              AND d3.mes = d2.mes
                                              AND d3.secuencia = d2.secuencia
                LEFT OUTER JOIN e_financiera  ef ON ef.id_cia = d2.id_cia
                                                   AND ef.codigo = d5.codban
            WHERE
                    d2.id_cia = pin_id_cia
                AND d2.libro IN (
                    v_f140
                )
                AND d2.codsuc = pin_codsuc
                AND d2.situac = 'B'
                AND ( ( d5.situac = 'B' ) )
                AND ( ( d3.situac = 'B' ) )
                AND ( ( ( pin_pnumcaja = - 1 )
                        AND d2.femisi = pin_fecha )
                      OR ( d2.numcaja = pin_pnumcaja ) )
            UNION                
        --{ DETERMINACION DEL SALDO SEGUN SUSTENTO - SALIDAS A BANCO }
            SELECT
                CAST('B' AS CHAR(1))                    AS flag,
                CAST('S' AS CHAR(1))                    AS id,
                CAST(a.doccaja AS INTEGER)              AS numcaja,
                CAST(mp.codigo AS INTEGER)              AS tipdep,
                a.periodo,
                a.mes,
                CAST(NULL AS INTEGER)                   AS secuencia,
                CAST(NULL AS INTEGER)                   AS item,
                CAST(a.concep AS VARCHAR(100))          AS concep,
                CAST(mp.descri AS VARCHAR(50))          AS dtipdep,
                CAST('0' AS VARCHAR(3))                 AS motivo,
                CAST(a.docume AS VARCHAR(25))           AS docume,
                CAST(
                    CASE
                        WHEN a.moneda = 'PEN' THEN
                            a.impor01
                        ELSE
                            0
                    END
                    * d.signo AS NUMERIC(16, 2)) AS importemn,
                CAST(
                    CASE
                        WHEN a.moneda = 'USD' THEN
                            a.impor02
                        ELSE
                            0
                    END
                    * d.signo AS NUMERIC(16, 2)) AS importeme
            FROM
                     compr010 a
                INNER JOIN tdocume         d ON d.id_cia = a.id_cia
                                        AND d.codigo = a.tdocum
                LEFT OUTER JOIN tdocume_clases  dc ON dc.id_cia = a.id_cia
                                                     AND dc.tipdoc = a.tdocum
                                                     AND dc.moneda = '   '
                                                     AND dc.clase = 1
                LEFT OUTER JOIN m_pago          mp ON mp.id_cia = dc.id_cia
                                             AND mp.codigo = (
                    CASE
                        WHEN (
                            SELECT
                                sp000_valida_datos_numericos(dc.codigo)
                            FROM
                                dual
                        ) = 1 THEN
                            CAST(dc.codigo AS SMALLINT)
                        ELSE
                            0
                    END
                )
            WHERE
                    a.id_cia = pin_id_cia
                AND ( a.tipcaja IN (
                    604
                ) )
                AND a.situac <> 9
                AND a.codsuc = pin_codsuc
                AND NOT ( a.motivo IN (
                    'V',
                    'C'
                ) )
                AND ( ( ( pin_pnumcaja = - 1 )
                        AND ( a.fingre = pin_fecha ) )
                      OR ( a.doccaja = pin_pnumcaja ) )
            UNION                
        /* DETERMINACION DEL DOCUMENTOS NO SUMARIZADOS - TRANSFERENCIA GRATUITA */
            SELECT
                CAST('C' AS CHAR(1))                     AS flag,
                CAST((
                    CASE
                        WHEN mpc.vchar = 'S' THEN
                            'S'
                        ELSE
                            'I'
                    END
                ) AS CHAR(1)) AS id,
                d2.numcaja,
                d4.tipdep                                AS tipdep,
                d2.periodo,
                d2.mes,
                d2.secuencia,
                CAST(d4.item AS INTEGER)                 AS item,
                CAST(d2.concep AS VARCHAR(100))          AS concep,
                CAST(mp.descri AS VARCHAR(50))           AS dtipdep,
                CAST('0' AS VARCHAR(3))                  AS motivo,
                CAST(d4.op AS VARCHAR(25))               AS docume,
                CAST((
                    CASE
                        WHEN d4.tipmon = 'PEN' THEN
                            (
                                CASE
                                    WHEN upper(mpc.vchar) = 'S' THEN
                                        d4.impor01 * - 1
                                    ELSE
                                        d4.impor01
                                END
                            )
                        ELSE
                            0
                    END
                ) AS NUMERIC(16, 2)) AS importemn,
                CAST((
                    CASE
                        WHEN d4.tipmon = 'USD' THEN
                            (
                                CASE
                                    WHEN upper(mpc.vchar) = 'S' THEN
                                        d4.impor02 * - 1
                                    ELSE
                                        d4.impor02
                                END
                            )
                        ELSE
                            0
                    END
                ) AS NUMERIC(16, 2)) AS importeme
            FROM
                dcta102       d2
                LEFT OUTER JOIN dcta104       d4 ON d4.id_cia = d2.id_cia
                                              AND d4.libro = d2.libro
                                              AND d4.periodo = d2.periodo
                                              AND d4.mes = d2.mes
                                              AND d4.secuencia = d2.secuencia
                LEFT OUTER JOIN m_pago        mp ON mp.id_cia = d4.id_cia
                                             AND mp.codigo = d4.tipdep
                LEFT OUTER JOIN m_pago_clase  mpc ON mpc.id_cia = d4.id_cia
                                                    AND mpc.codmpago = d4.tipdep
                                                    AND mpc.clase = 3
            WHERE
                    d2.id_cia = pin_id_cia
                AND d2.libro IN (
                    v_f119
                )
                AND d2.codsuc = pin_codsuc
                AND d2.situac = 'B'
                AND ( ( d4.situac = 'B' )
                      AND ( d4.tipdep IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(v_codd103g) )
                ) ) )
                AND ( ( ( pin_pnumcaja = - 1 )
                        AND d2.femisi = pin_fecha )
                      OR ( d2.numcaja = pin_pnumcaja ) )
        ) LOOP
            v_table.flag := e.flag;
            v_table.id := e.id;
            v_table.numcaja := e.numcaja;
            v_table.tipdep := e.tipdep;
            v_table.periodo := e.periodo;
            v_table.mes := e.mes;
            v_table.secuencia := e.secuencia;
            v_table.item := e.item;
            v_table.concep := e.concep;
            IF ( ( upper(e.motivo) = 'V' ) OR ( upper(e.motivo) = 'C' ) ) THEN
                v_table.dtipdep := 'COMPRA/VENTA DE DOLARES';
            ELSE
                v_table.dtipdep := e.dtipdep;
            END IF;

            v_table.motivo := e.motivo;
            v_table.docume := e.docume;
            v_table.importemn := e.importemn;
            v_table.importeme := e.importeme;
             v_table.idtarjeta :=0;
            PIPE ROW ( v_table );
        END LOOP;

    END sp_cuadre_caja_detallado;

    FUNCTION sp_documentos_registrados (
        pin_id_cia   IN  NUMBER,
        pin_fecha    IN  DATE,
        pin_codcli   IN  VARCHAR2,
        pin_codsuc   IN  NUMBER,
        pin_estado   IN  NUMBER,
        pin_tipdocs  IN  VARCHAR2 --Lista de tipo de documentos SELECCIONADOS
    ) RETURN t_documentos_registrados
        PIPELINED
    AS

        v_table r_documentos_registrados := r_documentos_registrados(NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL,
                         NULL);
    BEGIN
        FOR i IN (
            SELECT
                d.tipdoc,
                d.docume,
                d.refere01,
                d.refere02,
                d.femisi,
                d.fvenci,
                td.signo,
                d.fcance,
                d.numbco,
                d.tipmon,
                d.importe * td.signo      AS importe,
                CASE
                    WHEN d.tipmon = 'PEN' THEN
                        ( ( d.importe - (
                            SELECT
                                ( abs(CAST(SUM(
                                    CASE
                                        WHEN p.dh = 'D' THEN
                                            p.impor01
                                        ELSE
                                            p.impor01 * - 1
                                    END
                                ) AS DOUBLE PRECISION)) * 100 ) / 100
                            FROM
                                dcta101 p
                            WHERE
                                    p.id_cia = d.id_cia
                                AND ( p.tipcan < 50 )
                                AND ( p.numint = d.numint )
                                AND ( p.femisi = pin_fecha )
                        ) ) * CAST(td.signo AS DOUBLE PRECISION) )
                    ELSE
                        ( ( d.importe - (
                            SELECT
                                ( abs(CAST(SUM(
                                    CASE
                                        WHEN p.dh = 'D' THEN
                                            p.impor02
                                        ELSE
                                            p.impor02 * - 1
                                    END
                                ) AS DOUBLE PRECISION)) * 100 ) / 100
                            FROM
                                dcta101 p
                            WHERE
                                    p.id_cia = d.id_cia
                                AND ( p.tipcan < 50 )
                                AND ( p.numint = d.numint )
                                AND ( p.femisi = pin_fecha )
                        ) ) * CAST(td.signo AS DOUBLE PRECISION) )
                END AS saldo,
                d.codban,
                c.codcli,
                c.razonc,
                c.limcre1,
                c.limcre2,
                tm.simbolo                AS desmon,
                c.chedev,
                c.letpro,
                c.renova,
                c.refina,
                c.fecing,
                td.descri                 AS dtipdoc,
                m.desmot,
                cv.despag                 AS despagven
            FROM
                dcta100         d
                LEFT OUTER JOIN tdoccobranza    td ON td.id_cia = d.id_cia
                                                   AND td.tipdoc = d.tipdoc
                LEFT OUTER JOIN tmoneda         tm ON tm.id_cia = d.id_cia
                                              AND tm.codmon = d.tipmon
                LEFT OUTER JOIN documentos_cab  dc ON dc.id_cia = d.id_cia
                                                     AND dc.numint = d.numint
                LEFT OUTER JOIN c_pago          cv ON cv.id_cia = dc.id_cia
                                             AND ( cv.codpag = dc.codcpag )
                                             AND ( upper(cv.swacti) = 'S' )
                LEFT OUTER JOIN motivos         m ON m.id_cia = dc.id_cia
                                             AND m.tipdoc = dc.tipdoc
                                             AND m.id = dc.id
                                             AND m.codmot = dc.codmot
                INNER JOIN cliente         c ON c.id_cia = d.id_cia
                                        AND c.codcli = d.codcli
            WHERE
                    d.id_cia = pin_id_cia
                AND ( d.femisi = pin_fecha )
                AND ( d.tipdoc IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_tipdocs) )
                ) )
                AND ( ( pin_codcli = '-1' )
                      OR ( d.codcli = pin_codcli ) )
                AND ( ( pin_codsuc = - 1 )
                      OR ( d.codsuc = pin_codsuc ) )
                AND ( ( pin_estado = 0 )
                      OR ( ( pin_estado = 1 )
                           AND ( d.saldo = 0 ) )
                      OR ( ( pin_estado = 2 )
                           AND ( d.saldo > 0 ) ) )
            ORDER BY
                d.tipdoc,
                d.docume
        ) LOOP
            v_table.tipdoc := i.tipdoc;
            v_table.docume := i.docume;
            v_table.refere01 := i.refere01;
            v_table.refere02 := i.refere02;
            v_table.femisi := i.femisi;
            v_table.fvenci := i.fvenci;
            v_table.signo := i.signo;
            v_table.fcance := i.fcance;
            v_table.numbco := i.numbco;
            v_table.tipmon := i.tipmon;
            v_table.importe := i.importe;
            v_table.saldo := i.saldo;
            v_table.codban := i.codban;
            v_table.codcli := i.codcli;
            v_table.razonc := i.razonc;
            v_table.limcre1 := i.limcre1;
            v_table.limcre2 := i.limcre2;
            v_table.desmon := i.desmon;
            v_table.chedev := i.chedev;
            v_table.letpro := i.letpro;
            v_table.renova := i.renova;
            v_table.refina := i.refina;
            v_table.fecing := i.fecing;
            v_table.dtipdoc := i.dtipdoc;
            v_table.desmot := i.desmot;
            v_table.despagven := i.despagven;
            PIPE ROW ( v_table );
        END LOOP;
    END sp_documentos_registrados;

    FUNCTION sp_informe_diario_caja (
        pin_id_cia    IN  NUMBER,
        pin_codsuc    IN  NUMBER,
        pin_pnumcaja  IN  NUMBER,
        pin_fdesde    IN  DATE,
        pin_fhasta    IN  DATE,
        pin_fmpago    IN  NUMBER
    ) RETURN tbl_sp_informe_diario_caja
        PIPELINED
    AS

        v_f119   VARCHAR(20);
        v_f140   VARCHAR(20);
        v_table  rec_sp_informe_diario_caja := rec_sp_informe_diario_caja(NULL, NULL, NULL, NULL, NULL,
                           NULL, NULL, NULL, NULL, NULL,
                           NULL, NULL, NULL, NULL, NULL,
                           NULL, NULL, NULL, NULL, NULL,
                           NULL, NULL, NULL, NULL, NULL,
                           NULL, NULL, NULL, NULL, NULL,
                           NULL, NULL, NULL, NULL, NULL,
                           NULL);
    BEGIN


      /* PLANILLA DE COBRANZA TIENDA*/
        DECLARE BEGIN
            SELECT
                vstrg
            INTO v_f119
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 119;

        EXCEPTION
            WHEN no_data_found THEN
                v_f119 := NULL;
        END;


  /* PLANILLA DE CANJE DE CHEQUES TIENDA*/

        DECLARE BEGIN
            SELECT
                vstrg
            INTO v_f140
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 140;

        EXCEPTION
            WHEN no_data_found THEN
                v_f140 := NULL;
        END;

        FOR i IN (
            SELECT
                d2.numcaja,
                d2.periodo,
                d2.mes,
                d2.dia,
                d2.libro,
                d2.secuencia,
                CAST('A' AS VARCHAR(2))                          AS flags,
                CAST('C' AS VARCHAR(2))                          AS flag,
                cj.coduser,
                u.nombres,
                CAST(d3.item AS INTEGER)                         AS item,
                d2.femisi,
                d2.tipcam,
                d0.codcli,
                c.razonc,
                d0.tipdoc,
                upper(td.abrevi)                                 AS abrevi,
                CAST(td.descri AS VARCHAR(50))                   AS destipo,
                d0.docume,
                d0.tipdoc                                        AS tipdocori,
                upper(td.abrevi)                                 AS abreviori,
                CAST(td.descri AS VARCHAR(50))                   AS destipoori,
                CAST('' AS VARCHAR(5))                           AS tipo,
                CAST('' AS VARCHAR(50))                          AS despago,
                CAST('' AS CHAR(3))                              AS simbold,
                CAST(d3.tipmon AS VARCHAR(5))                    AS tipmonc,
                CAST(tm.simbolo AS VARCHAR(5))                   AS simboldoc,
                CAST('' AS VARCHAR(5))                           AS tipmond,
                CAST(d3.amorti AS NUMERIC(16, 2))                AS importe,
                CAST(0 AS INTEGER)                               AS mpago,
                CAST(nvl(NULL, 0) AS NUMERIC(16, 2))             AS deposito,
                CAST(nvl(NULL, 0) AS NUMERIC(16, 2))             AS depositosol,
                CAST(nvl(NULL, 0) AS NUMERIC(16, 2))             AS depositodol,
                0                                                AS swsuma,
                d0.femisi                                        AS fopera,
                ( d2.periodo
                  || '-'
                  || d2.mes
                  || '-'
                  || d2.secuencia ) AS secuenciaxls
            FROM
                dcta102           d2
                LEFT OUTER JOIN dcta103           d3 ON d3.id_cia = d2.id_cia
                                              AND d3.libro = d2.libro
                                              AND d3.periodo = d2.periodo
                                              AND d3.mes = d2.mes
                                              AND d3.secuencia = d2.secuencia
                LEFT OUTER JOIN dcta100           d0 ON d0.id_cia = d2.id_cia
                                              AND d0.numint = d3.numint
                LEFT OUTER JOIN tdoccobranza      td ON td.id_cia = d2.id_cia
                                                   AND td.tipdoc = d0.tipdoc
                LEFT OUTER JOIN cliente           c ON c.id_cia = d0.id_cia
                                             AND c.codcli = d0.codcli
                LEFT OUTER JOIN tmoneda           tm ON tm.id_cia = d2.id_cia
                                              AND tm.codmon = d3.tipmon
                LEFT OUTER JOIN dcta102_caja_cab  cj ON cj.id_cia = d2.id_cia
                                                       AND cj.numcaja = d2.numcaja
                LEFT OUTER JOIN usuarios          u ON u.id_cia = d2.id_cia
                                              AND u.coduser = cj.coduser
            WHERE
                    d2.id_cia = pin_id_cia
                AND d2.libro IN (
                    SELECT
                        *
                    FROM
                        convert_in ( v_f119 )
                )
                AND ( ( d2.femisi >= pin_fdesde )
                      AND ( d2.femisi <= pin_fhasta ) )
                AND d2.codsuc = pin_codsuc
                AND d2.situac = 'B'
                AND d3.situac = 'B'
                AND ( ( pin_pnumcaja = - 1 )
                      OR ( d2.numcaja = pin_pnumcaja ) )
                AND ( ( pin_fmpago = - 1 )
                      OR ( EXISTS (
                    SELECT
                        libro
                    FROM
                        dcta104
                    WHERE
                            id_cia = d2.id_cia
                        AND libro = d2.libro
                        AND periodo = d2.periodo
                        AND mes = d2.mes
                        AND secuencia = d2.secuencia
                        AND tipdep = pin_fmpago
                ) ) )
            UNION
            SELECT
                d2.numcaja,
                d2.periodo,
                d2.mes,
                d2.dia,
                d2.libro,
                d2.secuencia,
                CAST('A' AS VARCHAR(2))                          AS flags,
                CAST('C' AS VARCHAR(2))                          AS flag,
                cj.coduser,
                u.nombres,
                CAST(d3.item AS INTEGER)                         AS item,
                d2.femisi,
                d2.tipcam,
                d0.codcli,
                c.razonc,
                d0.tipdoc,
                upper(td.abrevi)                                 AS abrevi,
                CAST(td.descri AS VARCHAR(50))                   AS destipo,
                d0.docume,
                d0.tipdoc                                        AS tipdocori,
                upper(td.abrevi)                                 AS abreviori,
                CAST(td.descri AS VARCHAR(50))                   AS destipoori,
                CAST('' AS VARCHAR(5))                           AS tipo,
                CAST('' AS VARCHAR(50))                          AS despago,
                CAST('' AS CHAR(3))                              AS simbold,
                CAST(d3.tipmon AS VARCHAR(5))                    AS tipmonc,
                CAST(tm.simbolo AS VARCHAR(5))                   AS simboldoc,
                CAST('' AS VARCHAR(5))                           AS tipmond,
                CAST(d3.amorti AS NUMERIC(16, 2))                AS importe,
                CAST(0 AS INTEGER)                               AS mpago,
                CAST(nvl(NULL, 0) AS NUMERIC(16, 2))             AS deposito,
                CAST(nvl(NULL, 0) AS NUMERIC(16, 2))             AS depositosol,
                CAST(nvl(NULL, 0) AS NUMERIC(16, 2))             AS depositodol,
                0                                                AS swsuma,
                d0.femisi                                        AS fopera,
                ( d2.periodo
                  || '-'
                  || d2.mes
                  || '-'
                  || d2.secuencia ) AS secuenciaxls
            FROM
                dcta102           d2
                LEFT OUTER JOIN dcta103           d3 ON d3.id_cia = d2.id_cia
                                              AND d3.libro = d2.libro
                                              AND d3.periodo = d2.periodo
                                              AND d3.mes = d2.mes
                                              AND d3.secuencia = d2.secuencia
                LEFT OUTER JOIN dcta100           d0 ON d0.id_cia = d2.id_cia
                                              AND d0.numint = d3.numint
                LEFT OUTER JOIN tdoccobranza      td ON td.id_cia = d2.id_cia
                                                   AND td.tipdoc = d0.tipdoc
                LEFT OUTER JOIN tmoneda           tm ON tm.id_cia = d2.id_cia
                                              AND tm.codmon = d3.tipmon
                LEFT OUTER JOIN cliente           c ON c.id_cia = d2.id_cia
                                             AND c.codcli = d0.codcli
                LEFT OUTER JOIN dcta102_caja_cab  cj ON cj.id_cia = d2.id_cia
                                                       AND cj.numcaja = d2.numcaja
                LEFT OUTER JOIN usuarios          u ON u.id_cia = d2.id_cia
                                              AND u.coduser = cj.coduser
            WHERE
                    d2.id_cia = pin_id_cia
                AND d2.libro IN (
                    SELECT
                        *
                    FROM
                        convert_in ( v_f140 )
                )
                AND ( ( d2.femisi >= pin_fdesde )
                      AND ( d2.femisi <= pin_fhasta ) )
                AND d2.codsuc = pin_codsuc
                AND d2.situac = 'B'
                AND d3.situac = 'B'
                AND ( ( pin_pnumcaja = - 1 )
                      OR ( d2.numcaja = pin_pnumcaja ) )
                AND ( ( pin_fmpago IN (
                    - 1,
                    7
                ) )
                      OR ( ( pin_fmpago NOT IN (
                    - 1,
                    7
                ) )
                           AND ( EXISTS (
                    SELECT
                        libro
                    FROM
                        dcta104
                    WHERE
                            id_cia = d2.id_cia
                        AND libro = d2.libro
                        AND periodo = d2.periodo
                        AND mes = d2.mes
                        AND secuencia = d2.secuencia
                        AND tipdep = pin_fmpago
                ) ) ) )
            UNION
            SELECT
                d2.numcaja,
                d2.periodo,
                d2.mes,
                d2.dia,
                d2.libro,
                d2.secuencia,
                CAST('B' AS VARCHAR(2))                                   AS flags,
                CAST('' AS VARCHAR(2))                                    AS flag,
                cj.coduser,
                u.nombres,
                CAST(d4.item AS INTEGER)                                  AS item,
                d2.femisi,
                d2.tipcam,
                CAST('' AS VARCHAR(20))                                   AS codcli,
                CAST('' AS VARCHAR(80))                                   AS razonc,
                CAST(d0.tipdoc AS SMALLINT)                               AS tipdoc,
                CAST(td.abrevi AS VARCHAR(4))                             AS abrevi,
                CAST(td.descri AS VARCHAR(50))                            AS destipo,
                CAST('' AS VARCHAR(40))                                   AS docume,
                CAST(d0.tipdoc AS SMALLINT)                               AS tipdocori,
                CAST(td.abrevi AS VARCHAR(4))                             AS abreviori,
                CAST(td.descri AS VARCHAR(50))                            AS destipoori,
                CAST(m.abrevi AS VARCHAR(5))                              AS tipo,
                CAST(m.descri AS VARCHAR(50))                             AS despago,
                tm.simbolo                                                AS simbold,
                CAST('' AS VARCHAR(5))                                    AS tipmonc,
                CAST('' AS VARCHAR(5))                                    AS simboldoc,
                CAST(d4.tipmon AS VARCHAR(5))                             AS tipmond,
                CAST(nvl(NULL, 0) AS NUMERIC(16, 2))                      AS importe,
                CAST(m.codigo AS INTEGER)                                 AS mpago,
                CAST(nvl(d4.deposito, 0) AS NUMERIC(16, 2))               AS deposito,
                CAST(nvl(
                    CASE
                        WHEN d4.tipmon = 'PEN' THEN
                            nvl(d4.deposito, 0)
                        ELSE
                            0
                    END, 0) AS NUMERIC(16, 2)) AS depositosol,
                CAST(nvl(
                    CASE
                        WHEN d4.tipmon = 'USD' THEN
                            nvl(d4.deposito, 0)
                        ELSE
                            0
                    END, 0) AS NUMERIC(16, 2)) AS depositodol,
                0                                                         AS swsuma,
                d0.femisi                                                 AS fopera,
                ( d2.periodo
                  || '-'
                  || d2.mes
                  || '-'
                  || d2.secuencia ) AS secuenciaxls
            FROM
                dcta102           d2
                LEFT OUTER JOIN dcta103           d3 ON d3.id_cia = d2.id_cia
                                              AND d3.libro = d2.libro
                                              AND d3.periodo = d2.periodo
                                              AND d3.mes = d2.mes
                                              AND d3.secuencia = d2.secuencia
                                              AND d3.item = 1
                LEFT OUTER JOIN dcta104           d4 ON d4.id_cia = d2.id_cia
                                              AND d4.libro = d2.libro
                                              AND d4.periodo = d2.periodo
                                              AND d4.mes = d2.mes
                                              AND d4.secuencia = d2.secuencia
                LEFT OUTER JOIN dcta100           d0 ON d0.id_cia = d2.id_cia
                                              AND d0.numint = d3.numint
                LEFT OUTER JOIN tdoccobranza      td ON td.id_cia = d2.id_cia
                                                   AND td.tipdoc = d0.tipdoc
                LEFT OUTER JOIN tmoneda           tm ON tm.id_cia = d2.id_cia
                                              AND tm.codmon = d4.tipmon
                LEFT OUTER JOIN m_pago            m ON m.id_cia = d2.id_cia
                                            AND m.codigo = d4.tipdep
                LEFT OUTER JOIN dcta102_caja_cab  cj ON cj.id_cia = d2.id_cia
                                                       AND cj.numcaja = d2.numcaja
                LEFT OUTER JOIN usuarios          u ON u.id_cia = d2.id_cia
                                              AND u.coduser = cj.coduser
            WHERE
                    d2.id_cia = pin_id_cia
                AND d2.libro IN (
                    SELECT
                        *
                    FROM
                        convert_in ( v_f119 )
                )
                AND ( ( d2.femisi >= pin_fdesde )
                      AND ( d2.femisi <= pin_fhasta ) )
                AND d2.codsuc = pin_codsuc
                AND d2.situac = 'B'
                AND d3.situac = 'B'
                AND d4.situac = 'B'
                AND ( ( pin_pnumcaja = - 1 )
                      OR ( d2.numcaja = pin_pnumcaja ) )
                AND ( ( ( pin_fmpago = - 1 )
                        OR ( pin_fmpago <> 7 ) )
                      OR ( ( pin_fmpago = 7 )
                           AND ( EXISTS (
                    SELECT
                        libro
                    FROM
                        dcta104
                    WHERE
                            id_cia = d2.id_cia
                        AND libro = d2.libro
                        AND periodo = d2.periodo
                        AND mes = d2.mes
                        AND secuencia = d2.secuencia
                        AND tipdep = pin_fmpago
                ) ) ) )


  /* LOS DEPOSITOS DE LOS CHEQUES */
            UNION
            SELECT
                d2.numcaja,
                d2.periodo,
                d2.mes,
                d2.dia,
                d2.libro,
                d2.secuencia,
                CAST('B' AS VARCHAR(2))                                  AS flags,
                CAST('' AS VARCHAR(2))                                   AS flag,
                cj.coduser,
                u.nombres,
                CAST(d5.numdoc AS INTEGER)                               AS item,
                d2.femisi,
                d2.tipcam,
                CAST('' AS VARCHAR(20))                                  AS codcli,
                CAST(d5.series
                     || '-'
                     || CAST(d5.numdoc AS VARCHAR(20))
                     || '-F.V:'
                     || CAST(d5.fvenci AS VARCHAR(10)) AS VARCHAR(80)) AS razonc,
                CAST(d5.tipdoc AS SMALLINT)                              AS tipdoc,
                CAST(td.abrevi AS VARCHAR(4))                            AS abrevi,
                CAST(td.descri AS VARCHAR(50))                           AS destipo,
                CAST(d5.refere AS VARCHAR(40))                           AS docume,
                CAST(d0.tipdoc AS SMALLINT)                              AS tipdocori,
                CAST(td2.abrevi AS VARCHAR(4))                           AS abreviori,
                CAST(td2.descri AS VARCHAR(50))                          AS destipoori,
                CAST(m.abrevi AS VARCHAR(5))                             AS tipo,
                CAST(m.descri AS VARCHAR(50))                            AS despago,
                tm.simbolo                                               AS simbold,
                CAST('' AS VARCHAR(5))                                   AS tipmonc,
                CAST(tm2.simbolo AS VARCHAR(5))                          AS simboldoc,
                CAST(d5.tipmon AS VARCHAR(5))                            AS tipmond,
                CAST(nvl(NULL, 0) AS NUMERIC(16, 2))                     AS importe,
                CAST(7 AS INTEGER)                                       AS mpago,
                CAST(nvl(d5.importe, 0) AS NUMERIC(16, 2))               AS deposito,
                CAST(nvl(
                    CASE
                        WHEN d5.tipmon = 'PEN' THEN
                            nvl(d5.importe, 0)
                        ELSE
                            0
                    END, 0) AS NUMERIC(16, 2)) AS depositosol,
                CAST(nvl(
                    CASE
                        WHEN d5.tipmon = 'USD' THEN
                            nvl(d5.importe, 0)
                        ELSE
                            0
                    END, 0) AS NUMERIC(16, 2)) AS depositodol,
                1                                                        AS swsuma,
                d5.femisi                                                AS fopera,
                ( d2.periodo
                  || '-'
                  || d2.mes
                  || '-'
                  || d2.secuencia ) AS secuenciaxls
            FROM
                dcta102           d2
                LEFT OUTER JOIN dcta103           d3 ON d3.id_cia = d2.id_cia
                                              AND d3.libro = d2.libro
                                              AND d3.periodo = d2.periodo
                                              AND d3.mes = d2.mes
                                              AND d3.secuencia = d2.secuencia
                                              AND d3.item = 1
                LEFT OUTER JOIN dcta105           d5 ON d5.id_cia = d2.id_cia
                                              AND d5.libro = d2.libro
                                              AND d5.periodo = d2.periodo
                                              AND d5.mes = d2.mes
                                              AND d5.secuencia = d2.secuencia
                LEFT OUTER JOIN dcta100           d0 ON d0.id_cia = d2.id_cia
                                              AND d0.numint = d3.numint
                LEFT OUTER JOIN tdoccobranza      td ON td.id_cia = d2.id_cia
                                                   AND td.tipdoc = d5.tipdoc
                LEFT OUTER JOIN tdoccobranza      td2 ON td2.id_cia = d2.id_cia
                                                    AND td2.tipdoc = d0.tipdoc
                LEFT OUTER JOIN tmoneda           tm ON tm.id_cia = d2.id_cia
                                              AND tm.codmon = d5.tipmon
                LEFT OUTER JOIN tmoneda           tm2 ON tm2.id_cia = d2.id_cia
                                               AND tm2.codmon = d3.tipmon
                LEFT OUTER JOIN m_pago            m ON m.id_cia = d2.id_cia
                                            AND m.codigo = 7
                LEFT OUTER JOIN dcta102_caja_cab  cj ON cj.id_cia = d2.id_cia
                                                       AND cj.numcaja = d2.numcaja
                LEFT OUTER JOIN usuarios          u ON u.id_cia = d2.id_cia
                                              AND u.coduser = cj.coduser
            WHERE
                    d2.id_cia = pin_id_cia
                AND d2.libro IN (
                    SELECT
                        *
                    FROM
                        convert_in ( v_f140 )
                )
                AND ( ( d2.femisi >= pin_fdesde )
                      AND ( d2.femisi <= pin_fhasta ) )
                AND d2.codsuc = pin_codsuc
                AND d2.situac = 'B'
                AND d3.situac = 'B'
                AND d5.situac = 'B'
                AND ( ( pin_pnumcaja = - 1 )
                      OR ( d2.numcaja = pin_pnumcaja ) )
                AND ( ( ( pin_fmpago = - 1 )
                        OR ( pin_fmpago = 7 ) )
                      OR ( ( pin_fmpago NOT IN (
                    - 1,
                    7
                ) )
                           AND ( EXISTS (
                    SELECT
                        libro
                    FROM
                        dcta104
                    WHERE
                            id_cia = d2.id_cia
                        AND libro = d2.libro
                        AND periodo = d2.periodo
                        AND mes = d2.mes
                        AND secuencia = d2.secuencia
                        AND tipdep = pin_fmpago
                ) ) ) )
        ) LOOP
            v_table.numcaja := i.numcaja;
            v_table.periodo := i.periodo;
            v_table.mes := i.mes;
            v_table.dia := i.dia;
            v_table.libro := i.libro;
            v_table.secuencia := i.secuencia;
            v_table.flags := i.flags;
            v_table.flag := i.flag;
            v_table.coduser := i.coduser;
            v_table.nombres := i.nombres;
            v_table.item := i.item;
            v_table.femisi := i.femisi;
            v_table.tipcam := i.tipcam;
            v_table.codcli := i.codcli;
            v_table.razonc := i.razonc;
            v_table.tipdoc := i.tipdoc;
            v_table.abrevi := i.abrevi;
            v_table.destipo := i.destipo;
            v_table.docume := i.docume;
            v_table.tipdocori := i.tipdocori;
            v_table.abreviori := i.abreviori;
            v_table.destipoori := i.destipoori;
            v_table.tipo := i.tipo;
            v_table.despago := i.despago;
            v_table.simbold := i.simbold;
            v_table.tipmonc := i.tipmonc;
            v_table.simboldoc := i.simboldoc;
            v_table.tipmond := i.tipmond;
            v_table.importe := i.importe;
            v_table.mpago := i.mpago;
            v_table.deposito := i.deposito;
            v_table.depositosol := i.depositosol;
            v_table.depositodol := i.depositodol;
            v_table.swsuma := i.swsuma;
            v_table.fopera := i.fopera;
            v_table.secuenciaxls := i.secuenciaxls;
            PIPE ROW ( v_table );
        END LOOP;

    END sp_informe_diario_caja;

    FUNCTION sp_documentos_emitidos (
        pin_id_cia  IN  NUMBER,
        pin_fdesde  IN  DATE,
        pin_fhasta  IN  DATE,
        pin_codcli  IN  VARCHAR2,
        pin_codpag  IN  NUMBER,
        pin_codsuc  IN  NUMBER,
        pin_tipdoc  IN  VARCHAR2
    ) RETURN tbl_sp_documentos_emitidos
        PIPELINED
    AS

        v_table rec_sp_documentos_emitidos := rec_sp_documentos_emitidos(NULL, NULL, NULL, NULL, NULL,
                           NULL, NULL, NULL, NULL, NULL,
                           NULL, NULL, NULL, NULL, NULL,
                           NULL, NULL, NULL, NULL, NULL,
                           NULL);
    BEGIN
        FOR i IN (
            SELECT DISTINCT
                c.numint,
                c.tipdoc,
                c.femisi,
                d0.fvenci,
                c.series,
                c.numdoc,
                c.codcli,
                c.razonc,
                c.tipmon,
                c.monafe * cb.signo      AS monafe,
                c.monigv * cb.signo      AS monigv,
                c.preven * cb.signo      AS preven,
                c.situac,
                s.dessit,
                c.codven,
                (
                    SELECT
                        coalesce(MIN(
                            CASE
                                WHEN(c.femisi = d1.femisi)
                                    AND(d0.saldo = 0)
                                    AND(d1.libro NOT IN(
                                    '06', '35', '26', '71'
                                )) THEN
                                    1
                                ELSE
                                    CASE
                                        WHEN(c.femisi = d1.femisi)
                                            AND(d0.saldo = 0)
                                            AND(d1.libro IN(
                                            '06', '35',
                                            '26', '71'
                                        )) THEN
                                            2
                                        ELSE
                                            3
                                    END
                            END
                        ), 3)
                    FROM
                        dcta101 d1
                    WHERE
                            d1.id_cia = c.id_cia
                        AND d1.numint = c.numint
                ) AS grupo,
                t.simbolo,
                cp.despag,
                c.codcpag,
                cb.descri                AS desdoc
            FROM
                     documentos_cab c
                INNER JOIN dcta100       d0 ON c.id_cia = d0.id_cia
                                         AND c.numint = d0.numint
                LEFT OUTER JOIN situacion     s ON c.id_cia = s.id_cia
                                               AND c.tipdoc = s.tipdoc
                                               AND c.situac = s.situac
                LEFT OUTER JOIN tmoneda       t ON c.id_cia = t.id_cia
                                             AND c.tipmon = t.codmon
                LEFT OUTER JOIN c_pago        cp ON cp.id_cia = c.id_cia
                                             AND cp.codpag = c.codcpag
                LEFT OUTER JOIN tdoccobranza  cb ON cb.id_cia = c.id_cia
                                                   AND cb.tipdoc = c.tipdoc
            WHERE
                    c.id_cia = pin_id_cia
                AND c.situac IN (
                    'F'
                )
 --               AND c.tipdoc IN (1,3,7   )
                AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                AND ( ( pin_codcli IS NULL )
                      OR ( pin_codcli = '-1' )
                      OR ( c.codcli = pin_codcli ) )
                AND ( ( pin_codpag = - 1 )
                      OR ( c.codcpag = pin_codpag ) )
                AND ( ( pin_codsuc = - 1 )
                      OR ( c.codsuc = pin_codsuc ) )
                AND ( ( pin_tipdoc = '-1' )
                      OR ( c.tipdoc IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_tipdoc) )
                ) ) )
        ) LOOP
            v_table.numint := i.numint;
            v_table.tipdoc := i.tipdoc;
            v_table.femisi := i.femisi;
            v_table.fvenci := i.fvenci;
            v_table.series := i.series;
            v_table.numdoc := i.numdoc;
            v_table.codcli := i.codcli;
            v_table.razonc := i.razonc;
            v_table.tipmon := i.tipmon;
            v_table.monafe := i.monafe;
            v_table.monigv := i.monigv;
            v_table.preven := i.preven;
            v_table.situac := i.situac;
            v_table.dessit := i.dessit;
            v_table.codven := i.codven;
            v_table.grupo := i.grupo;
            v_table.simbolo := i.simbolo;
            v_table.despag := i.despag;
            v_table.codcpag := i.codcpag;
            v_table.desdoc := i.desdoc;
            v_table.desgru := ( CASE
                WHEN ( v_table.grupo = 1 ) THEN
                    'CANCELADOS EL MISMO DÍA'
                WHEN ( v_table.grupo = 2 ) THEN
                    'CANJEADOS EL MISMO DÍA'
                ELSE 'NO CANCELADO EL MISMO DÍA DE EMISION'
            END );

            PIPE ROW ( v_table );
        END LOOP;
    END sp_documentos_emitidos;

    FUNCTION sp_bancarizacion_documentos (
        pin_id_cia   IN  NUMBER,
        pin_fdesde   IN  DATE,
        pin_fhasta   IN  DATE,
        pin_codsuc   IN  NUMBER,
        pin_nrocaja  IN  NUMBER,
        pin_estado   IN  NUMBER
    ) RETURN tbl_sp_bancarizacion_documentos
        PIPELINED
    AS

        v_table  rec_sp_bancarizacion_documentos := rec_sp_bancarizacion_documentos(NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL);
        v_f119   VARCHAR2(20);
        v_f140   VARCHAR2(20);
        v_f355   NUMERIC(9, 2);
        v_f356   NUMERIC(9, 2);
    BEGIN


          /* PLANILLA DE COBRANZA TIENDA*/
        DECLARE BEGIN
            SELECT
                vstrg
            INTO v_f119
            FROM
                factor
            WHERE
                    codfac = 119
                AND id_cia = pin_id_cia;

        EXCEPTION
            WHEN no_data_found THEN
                v_f119 := NULL;
        END;

  /* MONTO BANCARIZABLE EN SOLES*/

        DECLARE BEGIN
            SELECT
                vreal
            INTO v_f355
            FROM
                factor
            WHERE
                    codfac = 355
                AND id_cia = pin_id_cia;

        EXCEPTION
            WHEN no_data_found THEN
                v_f355 := NULL;
        END;

  /* MONTO BANCARIZABLE EN DOLARES*/

        DECLARE BEGIN
            SELECT
                vreal
            INTO v_f356
            FROM
                factor
            WHERE
                    codfac = 356
                AND id_cia = pin_id_cia;

        EXCEPTION
            WHEN no_data_found THEN
                v_f356 := NULL;
        END;

        FOR i IN (
            SELECT
                d2.numcaja,
                d2.libro,
                d2.periodo,
                d2.mes,
                d2.secuencia,
                a.razonc
                || ' '
                || d0.docume AS concep,
                d3.docume,
                d3.tipmon,
                d3.amorti,
                d0.importe,
                d3.swdep,
                c0.importe AS montosalida
            FROM
                dcta102       d2
                LEFT OUTER JOIN dcta103       d3 ON d3.id_cia = d2.id_cia
                                              AND d3.libro = d2.libro
                                              AND d3.periodo = d2.periodo
                                              AND d3.mes = d2.mes
                                              AND d3.secuencia = d2.secuencia
                LEFT OUTER JOIN dcta100       d0 ON d0.id_cia = d2.id_cia
                                              AND d0.numint = d3.numint
                LEFT OUTER JOIN compr010      c0 ON c0.id_cia = d2.id_cia
                                               AND c0.refere02 = d3.libro
                                                                 || d3.periodo
                                                                 || d3.mes
                                                                 || d3.secuencia
                                                                 || d3.item
                LEFT OUTER JOIN tdoccobranza  td ON td.id_cia = d2.id_cia
                                                   AND td.tipdoc = d0.tipdoc
                LEFT OUTER JOIN cliente       a ON a.id_cia = d2.id_cia
                                             AND a.codcli = d0.codcli
            WHERE
                    d2.id_cia = pin_id_cia
                AND d2.libro IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(v_f119) )
                )
                AND ( ( d2.femisi >= pin_fdesde )
                      AND ( d2.femisi <= pin_fhasta ) )
                AND d2.codsuc = pin_codsuc
                AND d2.situac = 'B'
                AND d3.situac = 'B'
                AND ( ( pin_nrocaja = - 1 )
                      OR ( d2.numcaja = pin_nrocaja ) )
                AND ( ( pin_estado = 0 )
                      OR ( ( pin_estado = 1 )
                           AND ( upper(d3.swdep) = 'S' ) )
                      OR ( ( pin_estado = 2 )
                           AND ( upper(d3.swdep) = 'N' ) )
                      OR ( ( pin_estado = 3 )
                           AND ( ( ( d3.tipmon = 'PEN' )
                                   AND ( d0.importe >= v_f355 ) )
                                 OR ( ( d3.tipmon = 'USD' )
                                      AND ( d0.importe >= v_f356 ) ) ) ) )
        ) LOOP
            v_table.numcaja := i.numcaja;
            v_table.libro := i.libro;
            v_table.periodo := i.periodo;
            v_table.mes := i.mes;
            v_table.secuencia := i.secuencia;
            v_table.concep := i.concep;
            v_table.docume := i.docume;
            v_table.tipmon := i.tipmon;
            v_table.amorti := i.amorti;
            v_table.importe := i.importe;
            v_table.swdep := i.swdep;
            v_table.montosalida := i.montosalida;
            PIPE ROW ( v_table );
        END LOOP;

    END sp_bancarizacion_documentos;

    FUNCTION sp_recibo_de_caja (
        pin_id_cia     IN NUMBER,
        pin_tippla     NUMBER,
        pin_periodo    NUMBER,
        pin_mes        NUMBER,
        pin_secuencia  NUMBER
    ) RETURN tbl_sp_recibo_de_caja
        PIPELINED
    AS

        v_factor  VARCHAR2(20);
        v_table   rec_sp_recibo_de_caja := rec_sp_recibo_de_caja(NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL,
                      NULL);
    BEGIN
        DECLARE BEGIN
            SELECT
                vstrg
            INTO v_factor
            FROM
                factor
            WHERE
                codfac = pin_tippla;

        EXCEPTION
            WHEN no_data_found THEN
                v_factor := NULL;
        END;

        FOR i IN (
            SELECT
                p.libro,
                p.periodo,
                p.mes,
                p.secuencia,
                p.item,
                p.tipdep,
                p.doccan,
                p.cuenta,
                p.dh,
                p.tipmon,
                md.simbolo    AS simdoc,
                p.codban,
                p.op,
                p.agencia,
                p.tipcam,
                p.deposito,
                p.tcamb01,
                p.tcamb02,
                p.impor01,
                p.impor02,
                p.pagomn,
                p.pagome,
                p.situac,
                p.concep,
                b.descri      AS desban,
                tp.descri     AS dtipdep
            FROM
                dcta104  p
                LEFT OUTER JOIN tbancos  b ON ( b.id_cia = p.id_cia )
                                             AND ( b.codban = p.codban )
                LEFT OUTER JOIN m_pago   tp ON ( tp.id_cia = p.id_cia )
                                             AND ( tp.codigo = p.tipdep )
                LEFT OUTER JOIN tmoneda  md ON ( md.id_cia = p.id_cia )
                                              AND ( md.codmon = p.tipmon )
            WHERE
                ( p.id_cia = pin_id_cia )
                AND ( p.libro = v_factor )
                AND ( p.periodo = pin_periodo )
                AND ( p.mes = pin_mes )
                AND ( p.secuencia = pin_secuencia )
        ) LOOP
            v_table.libro := i.libro;
            v_table.periodo := i.periodo;
            v_table.mes := i.mes;
            v_table.secuencia := i.secuencia;
            v_table.item := i.item;
            v_table.tipdep := i.tipdep;
            v_table.doccan := i.doccan;
            v_table.cuenta := i.cuenta;
            v_table.dh := i.dh;
            v_table.tipmon := i.tipmon;
            v_table.simdoc := i.simdoc;
            v_table.codban := i.codban;
            v_table.op := i.op;
            v_table.agencia := i.agencia;
            v_table.tipcam := i.tipcam;
            v_table.deposito := i.deposito;
            v_table.tcamb01 := i.tcamb01;
            v_table.tcamb02 := i.tcamb02;
            v_table.impor01 := i.impor01;
            v_table.impor02 := i.impor02;
            v_table.pagomn := i.pagomn;
            v_table.pagome := i.pagome;
            v_table.situac := i.situac;
            v_table.concep := i.concep;
            v_table.desban := i.desban;
            v_table.dtipdep := i.dtipdep;
            PIPE ROW ( v_table );
        END LOOP;

    END sp_recibo_de_caja;

    FUNCTION sp00_resumen_informe_diario_mpago (
        pin_id_cia   IN  NUMBER,
        pin_fdesde   IN  DATE,
        pin_fhasta   IN  DATE,
        pin_codsuc   IN  NUMBER,
        pin_nrocaja  IN  NUMBER,
        pin_mpago    IN  NUMBER
    ) RETURN t_sp00_resumen_informe_diario_mpago
        PIPELINED
    AS

        reco r_sp00_resumen_informe_diario_mpago := r_sp00_resumen_informe_diario_mpago(NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL,
                                    NULL);
    BEGIN
        FOR i IN (
            SELECT
                tipdocori                                          AS tipdoc,
                abreviori                                          AS abrtdoc,
                destipoori                                         AS destdoc,
                mpago                                              AS mpago,
                tipo                                               AS abrmpag,
                despago                                            AS desmpag,
                tipmond                                            AS tipmon,
                simbold                                            AS simbol,
                CAST(SUM(depositosol) AS NUMBER(16, 2))            AS depositosol,
                CAST(SUM(depositodol) AS NUMBER(16, 2))            AS depositodol,
                CAST(SUM(deposito) AS NUMBER(16, 2))               AS deposito
            FROM
                TABLE ( sp_informe_diario_caja(pin_id_cia, pin_codsuc, pin_nrocaja, pin_fdesde, pin_fhasta,
                                               pin_mpago) )
            WHERE
                mpago NOT IN (
                    999,
                    12,
                    13,
                    0
                )
            GROUP BY
                mpago,
                tipdocori,
                abreviori,
                destipoori,
                tipo,
                despago,
                tipmond,
                simbold
            UNION ALL
            SELECT
                tipdocori                                          AS tipdoc,
                abreviori                                          AS abrtdoc,
                destipoori                                         AS destdoc,
                CAST(8 AS INTEGER)                                 AS mpago,
                CAST('EFEC' AS VARCHAR2(5))                        AS abrmpag,
                CAST('EFECTIVO' AS VARCHAR2(50))                   AS desmpag,
                tipmond                                            AS tipmon,
                simbold                                            AS simbol,
                CAST(SUM(depositosol) AS NUMBER(16, 2))            AS depositosol,
                CAST(SUM(depositodol) AS NUMBER(16, 2))            AS depositodol,
                CAST(SUM(deposito) AS NUMBER(16, 2))               AS deposito
            FROM
                TABLE ( sp_informe_diario_caja(pin_id_cia, pin_codsuc, pin_nrocaja, pin_fdesde, pin_fhasta,
                                               pin_mpago) )
            WHERE
                mpago = 999
            GROUP BY
                mpago,
                tipdocori,
                abreviori,
                destipoori,
                tipmond,
                simbold
        ) LOOP
            reco.tipdoc := i.tipdoc;
            reco.abrtdoc := i.abrtdoc;
            reco.destdoc := i.destdoc;
            reco.mpago := i.mpago;
            reco.abrmpag := i.abrmpag;
            reco.desmpag := i.desmpag;
            reco.tipmon := i.tipmon;
            reco.simbol := i.simbol;
            reco.depositosol := i.depositosol;
            reco.depositodol := i.depositodol;
            reco.deposito := i.deposito;
            PIPE ROW ( reco );
        END LOOP;
    END sp00_resumen_informe_diario_mpago;

    FUNCTION sp01_resumen_informe_diario_mpago (
        pin_id_cia   IN  NUMBER,
        pin_fdesde   IN  DATE,
        pin_fhasta   IN  DATE,
        pin_codsuc   IN  NUMBER,
        pin_nrocaja  IN  NUMBER,
        pin_mpago    IN  NUMBER
    ) RETURN t_sp01_resumen_informe_diario_mpago
        PIPELINED
    AS

        reco r_sp01_resumen_informe_diario_mpago := r_sp01_resumen_informe_diario_mpago(NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL,
                                    NULL);
    BEGIN
        FOR i IN (
            SELECT
                mpago,
                abrmpag,
--                tipdoc,
--                abrtdoc,
--                destdoc,
                desmpag,
--                tipmon,
--                simbol,
                SUM(depositosol)     AS depositosol,
                SUM(depositodol)     AS depositodol
--                SUM(deposito)        AS deposito
            FROM
                TABLE ( sp00_resumen_informe_diario_mpago(pin_id_cia, pin_fdesde, pin_fhasta, pin_codsuc, pin_nrocaja,
                                                          pin_mpago) )
            GROUP BY
                mpago,
--                tipdoc,
--                tipmon,
--                abrtdoc,
--                destdoc,
                abrmpag,
                desmpag
--                simbol
            ORDER BY
                desmpag
        ) LOOP
            reco.tipdoc := NULL;--i.tipdoc;
            reco.abrtdoc :=NULL; --i.abrtdoc;
            reco.destdoc :=NULL; --i.destdoc;
            reco.mpago := i.mpago;
            reco.abrmpag := i.abrmpag;
            reco.desmpag := i.desmpag;
            reco.tipmon :=NULL; -- i.tipmon;
            reco.simbol :=NULL; -- i.simbol;
            IF i.depositosol IS NOT NULL THEN
                reco.depositosol := i.depositosol;
            ELSE
                reco.depositosol := 0;
            END IF;

            IF i.depositodol IS NOT NULL THEN
                reco.depositodol := i.depositodol;
            ELSE
                reco.depositodol := 0;
            END IF;

            reco.deposito := NULL; --i.deposito;
            PIPE ROW ( reco );
        END LOOP;
    END sp01_resumen_informe_diario_mpago;

    FUNCTION sp00_resumen_informe_diario_tipdoc (
        pin_id_cia   IN  NUMBER,
        pin_fdesde   IN  DATE,
        pin_fhasta   IN  DATE,
        pin_codsuc   IN  NUMBER,
        pin_nrocaja  IN  NUMBER,
        pin_mpago    IN  NUMBER
    ) RETURN t_sp00_resumen_informe_diario_tipdoc
        PIPELINED
    AS

        reco r_sp00_resumen_informe_diario_tipdoc := r_sp00_resumen_informe_diario_tipdoc(NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL,
                                     NULL);
    BEGIN
        FOR i IN (
            SELECT
                tipdocori                                           AS tipdoc,
                abreviori                                           AS abrtdoc,
                destipoori                                          AS destdoc,
                mpago                                               AS mpago,
                tipo                                                AS abrmpag,
                despago                                             AS desmpag,
                tipmond                                             AS tipmon,
                simbold                                             AS simbol,
                CAST(SUM(depositosol) AS NUMERIC(16, 2))            AS depositosol,
                CAST(SUM(depositodol) AS NUMERIC(16, 2))            AS depositodol,
                CAST(SUM(deposito) AS NUMERIC(16, 2))               AS deposito
            FROM
                TABLE ( sp_informe_diario_caja(pin_id_cia, pin_codsuc, pin_nrocaja, pin_fdesde, pin_fhasta,
                                               pin_mpago) )
            WHERE
                mpago NOT IN (
                    999,
                    12,
                    13,
                    0
                )
            GROUP BY
                tipdocori,
                mpago,
                tipmond,
                abreviori,
                destipoori,
                tipo,
                despago,
                simbold
            UNION ALL
            SELECT
                tipdocori                                           AS tipdoc,
                abreviori                                           AS abrtdoc,
                destipoori                                          AS destdoc,
                CAST(8 AS INTEGER)                                  AS mpago,
                CAST('EFEC' AS VARCHAR(5))                          AS abrmpag,
                CAST('EFECTIVO' AS VARCHAR(50))                     AS desmpag,
                tipmond                                             AS tipmon,
                simbold                                             AS simbol,
                CAST(SUM(depositosol) AS NUMERIC(16, 2))            AS depositosol,
                CAST(SUM(depositodol) AS NUMERIC(16, 2))            AS depositodol,
                CAST(SUM(deposito) AS NUMERIC(16, 2))               AS deposito
            FROM
                TABLE ( sp_informe_diario_caja(pin_id_cia, pin_codsuc, pin_nrocaja, pin_fdesde, pin_fhasta,
                                               pin_mpago) )
            WHERE
                mpago = 999
            GROUP BY
                tipdocori,
                mpago,
                tipmond,
                abreviori,
                destipoori,
                tipo,
                despago,
                simbold
        ) LOOP
            reco.tipdoc := i.tipdoc;
            reco.abrtdoc := i.abrtdoc;
            reco.destdoc := i.destdoc;
            reco.mpago := i.mpago;
            reco.abrmpag := i.abrmpag;
            reco.desmpag := i.desmpag;
            reco.tipmon := i.tipmon;
            reco.simbol := i.simbol;
            reco.depositosol := i.depositosol;
            reco.depositodol := i.depositodol;
            reco.deposito := i.deposito;
            PIPE ROW ( reco );
        END LOOP;
    END sp00_resumen_informe_diario_tipdoc;

    FUNCTION sp01_resumen_informe_diario_tipdoc (
        pin_id_cia   IN  NUMBER,
        pin_fdesde   IN  DATE,
        pin_fhasta   IN  DATE,
        pin_codsuc   IN  NUMBER,
        pin_nrocaja  IN  NUMBER,
        pin_mpago    IN  NUMBER
    ) RETURN t_sp01_resumen_informe_diario_tipdoc
        PIPELINED
    AS

        reco r_sp01_resumen_informe_diario_tipdoc := r_sp01_resumen_informe_diario_tipdoc(NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL,
                                     NULL);
    BEGIN
        FOR i IN (
            SELECT
                tipdoc,
                mpago,
                abrmpag,
                abrtdoc,
                destdoc,
                desmpag,
                tipmon,
                simbol,
                SUM(depositosol)     AS depositosol,
                SUM(depositodol)     AS depositodol,
                SUM(deposito)        AS deposito
            FROM
                TABLE ( sp00_resumen_informe_diario_tipdoc(pin_id_cia, pin_fdesde, pin_fhasta, pin_codsuc, pin_nrocaja,
                                                           pin_mpago) )
            GROUP BY
                tipdoc,
                mpago,
                tipmon,
                abrtdoc,
                destdoc,
                abrmpag,
                desmpag,
                simbol
            ORDER BY
                tipdoc
        ) LOOP
            reco.tipdoc := i.tipdoc;
            reco.abrtdoc := i.abrtdoc;
            reco.destdoc := i.destdoc;
            reco.mpago := i.mpago;
            reco.abrmpag := i.abrmpag;
            reco.desmpag := i.desmpag;
            reco.tipmon := i.tipmon;
            reco.simbol := i.simbol;
            reco.depositosol := i.depositosol;
            reco.depositodol := i.depositodol;
            reco.deposito := i.deposito;
            PIPE ROW ( reco );
        END LOOP;
    END sp01_resumen_informe_diario_tipdoc;

END pack_reporte_punto_venta;

/
