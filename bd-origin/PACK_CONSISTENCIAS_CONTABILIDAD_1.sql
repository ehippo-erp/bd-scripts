--------------------------------------------------------
--  DDL for Package Body PACK_CONSISTENCIAS_CONTABILIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CONSISTENCIAS_CONTABILIDAD" AS

/*
SELECT * FROM  pack_consistencias_contabilidad.sp_clase_6_9(54,2022,1);

SELECT * FROM  pack_consistencias_contabilidad.sp_centro_costos(54);

SELECT * FROM  pack_consistencias_contabilidad.sp_centro_costos_movimientos(54,2022);

SELECT * FROM  pack_consistencias_contabilidad.sp_clase_67_9(54,2022,4); 
*/

    FUNCTION sp_clase_6_9 (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_clase_6_9
        PIPELINED
    AS
        v_table datatable_clase_6_9;
    BEGIN
        SELECT
            m.libro,
            m.periodo,
            m.mes,
            m.asiento,
            SUM(nvl(m.impor01, 0))                               AS "sumatoria de 6",
            SUM(nvl(m1.impor01, 0))                              AS "sumatoria de 9",
            SUM(nvl(m.impor01, 0)) - ( SUM(nvl(m1.impor01, 0)) ) AS "diferencia"
        BULK COLLECT
        INTO v_table
        FROM
            movimientos m
            LEFT OUTER JOIN movimientos m1 ON m1.id_cia = m.id_cia
                                              AND m1.libro = m.libro
                                              AND m1.periodo = m.periodo
                                              AND m1.mes = m.mes
                                              AND m1.asiento = m.asiento
                                              AND m1.item = m.item
                                              AND m1.cuenta LIKE '9%'
        WHERE
                m.id_cia = pin_id_cia
            AND m.periodo = pin_periodo
            AND ( pin_mes = - 1
                  OR m.mes = pin_mes )
            AND m.cuenta LIKE '6%'
            AND NOT ( m.cuenta LIKE '67%' )
            AND NOT ( m.cuenta LIKE '60%' )
            AND NOT ( m.cuenta LIKE '61%' )
        GROUP BY
            m.libro,
            m.periodo,
            m.mes,
            m.asiento
        HAVING
            SUM(nvl(m.impor01, 0)) - ( SUM(nvl(m1.impor01, 0)) ) <> 0;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_clase_6_9;

    FUNCTION sp_centro_costos (
        pin_id_cia NUMBER
    ) RETURN datatable_centros_costos
        PIPELINED
    AS
        v_table datatable_centros_costos;
    BEGIN
        SELECT
            t1.codigo AS "Centro de Costo",
            t1.destin AS "Destino",
            CASE
                WHEN ( p1.cuenta IS NULL ) THEN
                    'N'
                ELSE
                    'S'
            END       AS "CCosto en PCuentas",
            CASE
                WHEN ( p2.cuenta IS NULL ) THEN
                    'N'
                ELSE
                    'S'
            END       AS "Destino en PCuentas"
        BULK COLLECT
        INTO v_table
        FROM
            tccostos t1
            LEFT OUTER JOIN pcuentas p1 ON p1.id_cia = t1.id_cia
                                           AND p1.cuenta = t1.codigo
            LEFT OUTER JOIN pcuentas p2 ON p2.id_cia = t1.id_cia
                                           AND p2.cuenta = t1.destin
        WHERE
                t1.id_cia = pin_id_cia
            AND ( ( ( p1.cuenta IS NULL )
                    OR ( length(p1.cuenta) <= 2 ) )
                  OR ( ( p2.cuenta IS NULL )
                       OR ( length(p2.cuenta) <= 2 ) ) )
        ORDER BY
            t1.codigo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_centro_costos;

    FUNCTION sp_centro_costos_movimientos (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER
    ) RETURN datatable_centros_costos_movimientos
        PIPELINED
    AS
        v_table datatable_centros_costos_movimientos;
    BEGIN
        SELECT
            m1.periodo,
            m1.mes,
            m1.libro,
            m1.asiento,
            m1.item,
            m1.cuenta AS "Cuenta en Movimiento",
            m1.ccosto AS "CCosto en Movimiento",
            CASE
                WHEN ( p1.cuenta IS NULL ) THEN
                    'N'
                ELSE
                    'S'
            END       AS "CCosto en PCuentas",
            CASE
                WHEN ( t1.codigo IS NULL ) THEN
                    'N'
                ELSE
                    'S'
            END       AS "CCosto en TCCostos"
        BULK COLLECT
        INTO v_table
        FROM
            movimientos m1
            LEFT OUTER JOIN tccostos    t1 ON t1.codigo = m1.ccosto
            LEFT OUTER JOIN pcuentas    p1 ON p1.cuenta = m1.ccosto
        WHERE
                m1.id_cia = pin_id_cia
            AND ( m1.periodo = pin_periodo )
            AND ( substr(m1.cuenta, 1, 2) IN ( '62', '63', '64', '65', '66',
                                               '67', '68' ) )
            AND ( ( ( m1.ccosto IS NULL )
                    OR ( length(m1.ccosto) <= 2 )
                    OR ( p1.cuenta IS NULL )
                    OR ( length(p1.cuenta) <= 2 )
                    OR ( t1.codigo IS NULL )
                    OR ( length(t1.codigo) <= 2 ) ) )
        ORDER BY
            m1.periodo,
            m1.mes,
            m1.libro,
            m1.asiento,
            m1.item;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_centro_costos_movimientos;

    FUNCTION sp_clase_67_9 (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_clase_67_9
        PIPELINED
    AS
        v_table datatable_clase_67_9;
    BEGIN
        SELECT
            m.libro,
            m.periodo,
            m.mes,
            m.asiento,
            SUM(nvl(m.impor01, 0))                               AS "sumatoria de 67",
            SUM(nvl(m1.impor01, 0))                              AS "sumatoria de 9",
            /*(
                SELECT
                    coalesce(SUM(impor01), 0)
                FROM
                    movimientos
                WHERE
                        id_cia = pin_id_cia
                    AND libro = m.libro
                    AND periodo = m.periodo
                    AND mes = m.mes
                    AND asiento = m.asiento
                    AND item = m.item
                    AND cuenta LIKE '9%'
            )            AS "sumatoria de 9",
            SUM(impor01) - (
                SELECT
                    coalesce(SUM(impor01), 0)
                FROM
                    movimientos
                WHERE
                        id_cia = pin_id_cia
                    AND libro = m.libro
                    AND periodo = m.periodo
                    AND mes = m.mes
                    AND asiento = m.asiento
                    AND item = m.item
                    AND cuenta LIKE '9%'
            )            AS "diferencia"*/
            SUM(nvl(m.impor01, 0)) - ( SUM(nvl(m1.impor01, 0)) ) AS "diferencia"
        BULK COLLECT
        INTO v_table
        FROM
            movimientos m
            LEFT OUTER JOIN movimientos m1 ON m1.id_cia = m.id_cia
                                              AND m1.libro = m.libro
                                              AND m1.periodo = m.periodo
                                              AND m1.mes = m.mes
                                              AND m1.asiento = m.asiento
                                              AND m1.item = m.item
                                              AND m1.cuenta LIKE '9%'
        WHERE
                m.id_cia = pin_id_cia
            AND m.periodo = pin_periodo
            AND m.mes = pin_mes
            AND m.cuenta LIKE '67%'
        GROUP BY
            m.libro,
            m.periodo,
            m.mes,
            m.asiento
        HAVING
            SUM(nvl(m1.impor01, 0)) <> 0;

            --SUM(nvl(m.impor01, 0)) - ( SUM(nvl(m1.impor01, 0)) ) <> 0;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_clase_67_9;

END;

/
