--------------------------------------------------------
--  DDL for Package Body PACK_DW_CONSULTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DW_CONSULTA" AS

    FUNCTION sp_ventas_mensuales (
        pin_id_cia     NUMBER,
        pin_jsonfilter VARCHAR2
    ) RETURN datatable_ventas_mensuales
        PIPELINED
    AS

        v_table      datatable_ventas_mensuales;
        v_rec        datarecord_ventas_mensuales := datarecord_ventas_mensuales(0, NULL, 0, NULL, 0,
                                                                        0, NULL, NULL, NULL, 0,
                                                                        0, 0, 0, 0, 0,
                                                                        0, 0, 0, 0, 0,
                                                                        0, 0, 0, 0, 0,
                                                                        0, 0, 0, 0, 0,
                                                                        0);
        v_first      NUMBER := 0;
        o            json_object_t;
        pin_tipdoc   NUMBER;
        pin_sucursal NUMBER;
        pin_codsuc NUMBER;
        pin_tipmon   VARCHAR2(10);
        pin_moneda   VARCHAR2(10);
        pin_fdesde   DATE;
        pin_fhasta   DATE;
    BEGIN
        o := json_object_t.parse(pin_jsonfilter);
        pin_sucursal := o.get_number('sucursal');
        pin_codsuc := o.get_number('codsuc');
        pin_tipdoc := o.get_number('tipdoc');
        pin_moneda := o.get_string('moneda');
        pin_fdesde := o.get_date('fdesde');
        pin_fhasta := o.get_date('fhasta');
        IF pin_sucursal = 0 OR pin_sucursal IS NULL THEN
            IF pin_tipdoc = -1 THEN
                SELECT
                    dwm.id_cia,
                    'TODOS LOS DOCUMENTOS',
                    dwm.periodo,
                    dwm.mes,
                    dwm.idmes,
                    dwm.mesid,
                    substr(dwm.mes, 1, 3) AS rotulo,
                    ''                    AS categoria,
                    dwm.moneda,
                    dwm.venta,
                    CASE
                        WHEN pin_moneda = 'PEN' THEN
                            dwn.meta01
                        ELSE
                            dwn.meta01
                    END                   AS proyectado,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL
                BULK COLLECT
                INTO v_table
                FROM
                    (
                        SELECT
                            dw.id_cia,
                            dw.periodo,
                            dw.mes,
                            dw.idmes,
                            dw.mesid,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    'PEN'
                                ELSE
                                    'USD'
                            END AS moneda,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    SUM(dw.vntsol)
                                ELSE
                                    SUM(dw.vntdol)
                            END AS venta
                        FROM
                            dw_cventas_x_dia dw
                        WHERE
                                dw.id_cia = pin_id_cia
                            AND femisi BETWEEN pin_fdesde AND pin_fhasta
                        GROUP BY
                            dw.id_cia,
                            dw.periodo,
                            dw.mes,
                            dw.idmes,
                            dw.mesid,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                        'PEN'
                                ELSE
                                    'USD'
                            END
                    )                       dwm
                    LEFT OUTER JOIN dw_cventas_mensual_meta dwn ON dwn.id_cia = dwm.id_cia
                                                                   AND dwn.codsuc = 0
                                                                   AND dwn.periodo = dwm.periodo
                                                                   AND dwn.idmes = dwm.idmes
                ORDER BY
                    dwm.mesid ASC;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

            ELSE
                SELECT
                    dwm.id_cia,
                    dwm.tipdoc,
                    dwm.periodo,
                    dwm.mes,
                    dwm.idmes,
                    dwm.mesid,
                    substr(dwm.mes, 1, 3) AS rotulo,
                    ''                    AS categoria,
                    dwm.moneda,
                    dwm.venta,
                    NULL                  AS proyectado,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL
                BULK COLLECT
                INTO v_table
                FROM
                    (
                        SELECT
                            dw.id_cia,
                            dw.tipodocumento AS tipdoc,
                            dw.periodo,
                            dw.mes,
                            dw.idmes,
                            dw.mesid,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    'PEN'
                                ELSE
                                    'USD'
                            END              AS moneda,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    SUM(dw.vntsol)
                                ELSE
                                    SUM(dw.vntdol)
                            END              AS venta
                        FROM
                            dw_cventas_x_dia dw
                        WHERE
                                dw.id_cia = pin_id_cia
                            AND femisi BETWEEN pin_fdesde AND pin_fhasta
                            AND dw.tipdoc = pin_tipdoc
                        GROUP BY
                            dw.id_cia,
                            dw.tipodocumento,
                            dw.periodo,
                            dw.mes,
                            dw.idmes,
                            dw.mesid,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                        'PEN'
                                ELSE
                                    'USD'
                            END
                    )                       dwm
                    LEFT OUTER JOIN dw_cventas_mensual_meta dwn ON dwn.id_cia = dwm.id_cia
                                                                   AND dwn.codsuc = 0
                                                                   AND dwn.periodo = dwm.periodo
                                                                   AND dwn.idmes = dwm.idmes
                ORDER BY
                    dwm.mesid ASC;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

            END IF;
        -------------------------------------------------------------------------------------------------------------------
        --------------------------------- CHEACK SUCURSAL -------------------------------------------------
        -------------------------------------------------------------------------------------------------------------------
        ELSE
            FOR i IN (
                SELECT
                    dw.id_cia,
                    dw.codsuc,
                    dw.sucursal,
                    dw.periodo,
                    dw.mes,
                    dw.idmes,
                    dw.mesid,
                    CASE
                        WHEN pin_moneda = 'PEN' THEN
                            'PEN'
                        ELSE
                            'USD'
                    END AS moneda,
                    CASE
                        WHEN pin_moneda = 'PEN' THEN
                            SUM(dw.vntsol)
                        ELSE
                            SUM(dw.vntdol)
                    END AS venta
                FROM
                    dw_cventas_x_dia dw
                WHERE
                        dw.id_cia = pin_id_cia
                    AND ( femisi BETWEEN pin_fdesde AND pin_fhasta )
                    AND ( NVL(pin_codsuc,-1) = -1 OR dw.codsuc = pin_codsuc )
                GROUP BY
                    dw.id_cia,
                    dw.codsuc,
                    dw.sucursal,
                    dw.periodo,
                    dw.mes,
                    dw.idmes,
                    dw.mesid,
                    CASE
                        WHEN pin_moneda = 'PEN' THEN
                                'PEN'
                        ELSE
                            'USD'
                    END
                ORDER BY
                    dw.mesid ASC
            ) LOOP
                -- VALIDACION PARA AGRUPAR LAS SUCURSALES
                IF i.mesid = v_rec.mesid THEN
                    NULL;
                ELSE
                    -- PARA QUE NO IMPRIMA LA PRIMERA LINEA
                    IF v_first = 0 THEN
                        v_first := 1;
                    ELSE
                        PIPE ROW ( v_rec );
                    END IF;
                END IF;

                v_rec.id_cia := i.id_cia;
                v_rec.tipdoc := 'TODOS LOS DOCUMENTOS';
                v_rec.periodo := i.periodo;
                v_rec.mes := i.mes;
                v_rec.idmes := i.idmes;
                v_rec.mesid := i.mesid;
                v_rec.rotulo := substr(i.mes, 1, 3);
                v_rec.categoria := '';
                v_rec.moneda := i.moneda;
                v_rec.venta := NULL;
                v_rec.proyectado := NULL;
                CASE i.codsuc
                    WHEN 1 THEN
                        v_rec.codsucn1 := 1;
                        v_rec.sucursaln1 := i.venta;
                    WHEN 2 THEN
                        v_rec.codsucn2 := 2;
                        v_rec.sucursaln2 := i.venta;
                    WHEN 3 THEN
                        v_rec.codsucn3 := 3;
                        v_rec.sucursaln3 := i.venta;
                    WHEN 4 THEN
                        v_rec.codsucn4 := 4;
                        v_rec.sucursaln4 := i.venta;
                    WHEN 5 THEN
                        v_rec.codsucn5 := 5;
                        v_rec.sucursaln5 := i.venta;
                    WHEN 6 THEN
                        v_rec.codsucn6 := 6;
                        v_rec.sucursaln6 := i.venta;
                    WHEN 7 THEN
                        v_rec.codsucn7 := 7;
                        v_rec.sucursaln7 := i.venta;
                    WHEN 8 THEN
                        v_rec.codsucn8 := 8;
                        v_rec.sucursaln8 := i.venta;
                    WHEN 9 THEN
                        v_rec.codsucn9 := 9;
                        v_rec.sucursaln9 := i.venta;
                    WHEN 10 THEN
                        v_rec.codsucn10 := 10;
                        v_rec.sucursaln10 := i.venta;
                    ELSE
                        NULL;
                END CASE;

            END LOOP;
        END IF;

        RETURN;
    END sp_ventas_mensuales;

    FUNCTION sp_ventas_mensuales_comparativa (
        pin_id_cia     NUMBER,
        pin_jsonfilter VARCHAR2
    ) RETURN datatable_ventas_mensuales_comparativa
        PIPELINED
    AS

        v_table     datatable_ventas_mensuales_comparativa;
        o           json_object_t;
        pin_tipdoc  NUMBER;
        pin_codsuc  NUMBER;
        pin_moneda  VARCHAR2(10);
        pin_periodo VARCHAR2(200);
        pin_mes     NUMBER;
    BEGIN
        o := json_object_t.parse(pin_jsonfilter);
        pin_codsuc := o.get_number('codsuc');
        pin_tipdoc := o.get_number('tipdoc');
        pin_moneda := o.get_string('moneda');
        pin_periodo := o.get_string('periodo');
        pin_mes := o.get_number('mes');
        IF pin_codsuc = -1 OR pin_codsuc IS NULL THEN
            IF pin_mes > -1 THEN
                SELECT
                    dwm.id_cia,
                    dwm.sucursal,
                    dwm.tipdoc,
                    dwm.periodo,
                    dwm.mes,
                    dwm.idmes,
                    dwm.mesid,
                    dwm.rotulo,
                    dwm.categoria,
                    dwm.moneda,
                    dwm.venta,
                    dwm.proyectado,
                    CASE
                        WHEN dwm.venta >= nvl(dwm.proyectado, 0) THEN
                            dwm.venta
                        ELSE
                            0
                    END,
                    CASE
                        WHEN dwm.venta < nvl(dwm.proyectado, 0) THEN
                            dwm.venta
                        ELSE
                            0
                    END
                BULK COLLECT
                INTO v_table
                FROM
                    (
                        SELECT
                            dw.id_cia,
                            'TODOS SUCURSALES'      AS sucursal,
                            'TODOS'                 AS tipdoc,
                            dw.periodo,
                            dw.mes,
                            dw.idmes,
                            dw.mesid,
                            to_char(dw.periodo, '0000')
                            || ' - '
                            || substr(dw.mes, 1, 3) AS rotulo,
                            ''                      AS categoria,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    'PEN'
                                ELSE
                                    'USD'
                            END                     AS moneda,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    SUM(dw.vntsol)
                                ELSE
                                    SUM(dw.vntdol)
                            END                     AS venta,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    dwm.meta01
                                ELSE
                                    dwm.meta02
                            END                     AS proyectado
                        FROM
                            dw_cventas_x_dia        dw
                            LEFT OUTER JOIN dw_cventas_mensual_meta dwm ON dwm.id_cia = dw.id_cia
                                                                           AND dwm.codsuc = 0
                                                                           AND dwm.periodo = dw.periodo
                                                                           AND dwm.idmes = dw.idmes
                        WHERE
                                dw.id_cia = pin_id_cia
                            AND dw.periodo IN (
                                SELECT
                                    *
                                FROM
                                    TABLE ( convert_in(pin_periodo) )
                            )
                            AND dw.idmes = pin_mes
                        GROUP BY
                            dw.id_cia,
                            'TODOS SUCURSALES',
                            'TODOS',
                            dw.periodo,
                            dw.mes,
                            dw.idmes,
                            dw.mesid,
                            to_char(dw.periodo, '0000')
                            || ' - '
                            || substr(dw.mes, 1, 3),
                            '',
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                        'PEN'
                                ELSE
                                    'USD'
                            END,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                        dwm.meta01
                                ELSE
                                    dwm.meta02
                            END
                    ) dwm
                ORDER BY
                    dwm.idmes ASC;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            ELSE
                SELECT
                    dwmm.id_cia,
                    dwmm.sucursal,
                    dwmm.tipdoc,
                    dwmm.periodo,
                    dwmm.mes,
                    dwmm.idmes,
                    dwmm.mesid,
                    dwmm.rotulo,
                    dwmm.categoria,
                    dwmm.moneda,
                    dwmm.venta,
                    dwmm.proyectado,
                    CASE
                        WHEN dwmm.venta >= nvl(dwmm.proyectado, 0) THEN
                            dwmm.venta
                        ELSE
                            0
                    END,
                    CASE
                        WHEN dwmm.venta < nvl(dwmm.proyectado, 0) THEN
                            dwmm.venta
                        ELSE
                            0
                    END
                BULK COLLECT
                INTO v_table
                FROM
                    (
                        SELECT
                            dwm.id_cia,
                            dwm.sucursal,
                            dwm.tipdoc,
                            dwm.periodo,
                            dwm.mes,
                            dwm.idmes,
                            dwm.mesid,
                            dwm.rotulo,
                            dwm.categoria,
                            dwm.moneda,
                            dwm.venta,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    SUM(dwn.meta01)
                                ELSE
                                    SUM(dwn.meta02)
                            END AS proyectado
                        FROM
                            (
                                SELECT
                                    dw.id_cia,
                                    'TODOS SUCURSALES'          AS sucursal,
                                    'TODOS'                     AS tipdoc,
                                    dw.periodo,
                                    'TODOS'                     AS mes,
                                    0                           AS idmes,
                                    dw.periodo * 100            AS mesid,
                                    to_char(dw.periodo, '0000') AS rotulo,
                                    ''                          AS categoria,
                                    CASE
                                        WHEN pin_moneda = 'PEN' THEN
                                            'PEN'
                                        ELSE
                                            'USD'
                                    END                         AS moneda,
                                    CASE
                                        WHEN pin_moneda = 'PEN' THEN
                                            SUM(dw.vntsol)
                                        ELSE
                                            SUM(dw.vntdol)
                                    END                         AS venta
                                FROM
                                    dw_cventas_x_dia dw
                                WHERE
                                        dw.id_cia = pin_id_cia
                                    AND dw.periodo IN (
                                        SELECT
                                            *
                                        FROM
                                            TABLE ( convert_in(pin_periodo) )
                                    )
                                GROUP BY
                                    dw.id_cia,
                                    'TODOS SUCURSALES',
                                    'TODOS',
                                    dw.periodo,
                                    'TODOS',
                                    0,
                                    dw.periodo * 100,
                                    to_char(dw.periodo, '0000'),
                                    '',
                                    CASE
                                        WHEN pin_moneda = 'PEN' THEN
                                                'PEN'
                                        ELSE
                                            'USD'
                                    END
                                ORDER BY
                                    dw.periodo * 100 ASC
                            )                       dwm
                            LEFT OUTER JOIN dw_cventas_mensual_meta dwn ON dwn.id_cia = dwm.id_cia
                                                                           AND dwn.codsuc = 0
                                                                           AND dwn.periodo = dwm.periodo
                                                                           AND dwn.idmes BETWEEN 1 AND 12
                        GROUP BY
                            dwm.id_cia,
                            dwm.sucursal,
                            dwm.tipdoc,
                            dwm.periodo,
                            dwm.mes,
                            dwm.idmes,
                            dwm.mesid,
                            dwm.rotulo,
                            dwm.categoria,
                            dwm.moneda,
                            dwm.venta
                    ) dwmm
                ORDER BY
                    dwmm.idmes ASC;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            END IF;
        -------------------------------------------------------------------------------------------------------------------
        --------------------------------- CHEACK SUCURSAL -------------------------------------------------
        -------------------------------------------------------------------------------------------------------------------
        ELSE
            IF pin_mes > -1 THEN
                SELECT
                    dwm.id_cia,
                    dwm.sucursal,
                    dwm.tipdoc,
                    dwm.periodo,
                    dwm.mes,
                    dwm.idmes,
                    dwm.mesid,
                    substr(dwm.sucursal, 1, 3)
                    || ' - '
                    || to_char(dwm.periodo, '0000')
                    || ' - '
                    || substr(dwm.mes, 1, 3) AS rotulo,
                    ''                       AS categoria,
                    dwm.moneda,
                    dwm.venta,
                    dwm.proyectado,
                    CASE
                        WHEN dwm.venta >= nvl(dwm.proyectado, 0) THEN
                            dwm.venta
                        ELSE
                            0
                    END,
                    CASE
                        WHEN dwm.venta < nvl(dwm.proyectado, 0) THEN
                            dwm.venta
                        ELSE
                            0
                    END
                BULK COLLECT
                INTO v_table
                FROM
                    (
                        SELECT
                            dw.id_cia,
                            dw.sucursal,
                            'TODOS' AS tipdoc,
                            dw.periodo,
                            dw.mes,
                            dw.idmes,
                            dw.mesid,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    'PEN'
                                ELSE
                                    'USD'
                            END     AS moneda,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    SUM(dw.vntsol)
                                ELSE
                                    SUM(dw.vntdol)
                            END     AS venta,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    dwm.meta01
                                ELSE
                                    dwm.meta02
                            END     AS proyectado
                        FROM
                            dw_cventas_x_dia        dw
                            LEFT OUTER JOIN dw_cventas_mensual_meta dwm ON dwm.id_cia = dw.id_cia
                                                                           AND dwm.codsuc = dw.codsuc
                                                                           AND dwm.periodo = dw.periodo
                                                                           AND dwm.idmes = dw.idmes
                        WHERE
                                dw.id_cia = pin_id_cia
                            AND dw.codsuc = pin_codsuc
                            AND dw.periodo IN (
                                SELECT
                                    *
                                FROM
                                    TABLE ( convert_in(pin_periodo) )
                            )
                            AND dw.idmes = pin_mes
                        GROUP BY
                            dw.id_cia,
                            dw.sucursal,
                            'TODOS',
                            dw.periodo,
                            dw.mes,
                            dw.idmes,
                            dw.mesid,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                        'PEN'
                                ELSE
                                    'USD'
                            END,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                        dwm.meta01
                                ELSE
                                    dwm.meta02
                            END
                    ) dwm
                ORDER BY
                    dwm.idmes ASC;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            ELSE
                SELECT
                    dwmm.id_cia,
                    dwmm.sucursal,
                    dwmm.tipdoc,
                    dwmm.periodo,
                    dwmm.mes,
                    dwmm.idmes,
                    dwmm.mesid,
                    substr(dwmm.sucursal, 1, 3)
                    || ' - '
                    || to_char(dwmm.periodo, '0000') AS rotulo,
                    ''                               AS categoria,
                    dwmm.moneda,
                    dwmm.venta,
                    dwmm.proyectado,
                    CASE
                        WHEN dwmm.venta >= nvl(dwmm.proyectado, 0) THEN
                            dwmm.venta
                        ELSE
                            0
                    END,
                    CASE
                        WHEN dwmm.venta < nvl(dwmm.proyectado, 0) THEN
                            dwmm.venta
                        ELSE
                            0
                    END
                BULK COLLECT
                INTO v_table
                FROM
                    (
                        SELECT
                            dwm.id_cia,
                            dwm.sucursal,
                            dwm.tipdoc,
                            dwm.periodo,
                            dwm.mes,
                            dwm.idmes,
                            dwm.mesid,
                            dwm.moneda,
                            dwm.venta,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    SUM(dwn.meta01)
                                ELSE
                                    SUM(dwn.meta02)
                            END AS proyectado
                        FROM
                            (
                                SELECT
                                    dw.id_cia,
                                    dw.codsuc,
                                    dw.sucursal,
                                    'TODOS'          AS tipdoc,
                                    dw.periodo,
                                    'TODOS'          AS mes,
                                    0                AS idmes,
                                    dw.periodo * 100 AS mesid,
                                    CASE
                                        WHEN pin_moneda = 'PEN' THEN
                                            'PEN'
                                        ELSE
                                            'USD'
                                    END              AS moneda,
                                    CASE
                                        WHEN pin_moneda = 'PEN' THEN
                                            SUM(dw.vntsol)
                                        ELSE
                                            SUM(dw.vntdol)
                                    END              AS venta
                                FROM
                                    dw_cventas_x_dia dw
                                WHERE
                                        dw.id_cia = pin_id_cia
                                    AND dw.codsuc = pin_codsuc
                                    AND dw.periodo IN (
                                        SELECT
                                            *
                                        FROM
                                            TABLE ( convert_in(pin_periodo) )
                                    )
                                GROUP BY
                                    dw.id_cia,
                                    dw.codsuc,
                                    dw.sucursal,
                                    'TODOS',
                                    dw.periodo,
                                    'TODOS',
                                    0,
                                    dw.periodo * 100,
                                    CASE
                                        WHEN pin_moneda = 'PEN' THEN
                                                'PEN'
                                        ELSE
                                            'USD'
                                    END
                                ORDER BY
                                    dw.periodo * 100 ASC
                            )                       dwm
                            LEFT OUTER JOIN dw_cventas_mensual_meta dwn ON dwn.id_cia = dwm.id_cia
                                                                           AND dwn.codsuc = dwm.codsuc
                                                                           AND dwn.periodo = dwm.periodo
                                                                           AND dwn.idmes BETWEEN 1 AND 12
                        GROUP BY
                            dwm.id_cia,
                            dwm.sucursal,
                            dwm.tipdoc,
                            dwm.periodo,
                            dwm.mes,
                            dwm.idmes,
                            dwm.mesid,
                            dwm.moneda,
                            dwm.venta
                    ) dwmm
                ORDER BY
                    dwmm.idmes ASC;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            END IF;
        END IF;

    END sp_ventas_mensuales_comparativa;

    FUNCTION sp_venta_costo_utilidad_articulo (
        pin_id_cia     NUMBER,
        pin_jsonfilter VARCHAR2
    ) RETURN datatable_venta_costo_utilidad_articulo
        PIPELINED
    AS

        v_table       datatable_venta_costo_utilidad_articulo;
        o             json_object_t;
        pin_tipinv    NUMBER;
        pin_codart    VARCHAR2(70);
        pin_tipmon    VARCHAR2(10);
        pin_moneda    VARCHAR2(10);
        pin_clase     NUMBER;
        pin_codigo    VARCHAR2(50);
        pin_fdesde    DATE;
        pin_fhasta    DATE;
        v_idmes       NUMBER;
        v_periodo     NUMBER;
        v_mesid       NUMBER;
        v_mes         VARCHAR2(100);
        v_rotulo      VARCHAR2(100);
        pin_codartper VARCHAR2(6);
    BEGIN
        o := json_object_t.parse(pin_jsonfilter);
        pin_tipinv := o.get_number('tipinv');
        pin_codart := o.get_string('codart');
        pin_clase := o.get_number('clase');
        pin_codigo := o.get_string('codigo');
        pin_moneda := o.get_string('moneda');
        pin_fdesde := o.get_date('fdesde');
        pin_fhasta := o.get_date('fhasta');
        pin_codartper := o.get_string('codartper');
        v_idmes := TO_NUMBER ( to_char(pin_fhasta, 'MM') );
        v_periodo := TO_NUMBER ( to_char(pin_fhasta, 'YYYY') );
        v_mesid := v_periodo * 100 + v_idmes;
        v_mes := upper(to_char(TO_DATE(v_idmes, 'MM'), 'month', 'nls_date_language=spanish'));

--        v_rotulo := 'Periodo : '
--                    || to_char(pin_fdesde)
--                    || ' - '
--                    || to_char(pin_fhasta);

        IF pin_codigo IS NULL THEN
            SELECT
                dwv.id_cia,
                v_periodo,
                v_mes,
                v_idmes,
                v_mesid,
                upper(dwv.desclase),
                dwv.codclase,
                dwv.tipinv,
                dwv.dtipinv,
                dwv.codclase,
                dwv.desclase,
                dwv.codart,
                dwv.desart,
                dwv.moneda,
                dwv.cantid,
                dwv.venta,
                dwv.costo,
                dwv.igv,
                dwv.rentabilidad,
                round(decode(dwv.venta, 0, 0,(dwv.rentabilidad / dwv.venta) * 100),
                      2) AS porcentaje,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL
            BULK COLLECT
            INTO v_table
            FROM
                (
                    SELECT
                        dw.id_cia      AS id_cia,
                        dw.tipinv      AS tipinv,
                        dw.dtipinv     AS dtipinv,
                        ca.codigo      AS codclase,
                        ca.descodigo   AS desclase,
                        'TODOS'        AS codart,
                        'TODOS'        AS desart,
                        CASE
                            WHEN pin_moneda = 'PEN' THEN
                                'PEN'
                            ELSE
                                'USD'
                        END            AS moneda,
                        SUM(dw.cantid) AS cantid,
                        CASE
                            WHEN pin_moneda = 'PEN' THEN
                                SUM(dw.vntsol)
                            ELSE
                                SUM(dw.vntdol)
                        END            AS venta,
                        CASE
                            WHEN pin_moneda = 'PEN' THEN
                                SUM(dw.cstsol)
                            ELSE
                                SUM(dw.cstdol)
                        END            AS costo,
                        CASE
                            WHEN pin_moneda = 'PEN' THEN
                                SUM(dw.igvsol)
                            ELSE
                                SUM(dw.igvdol)
                        END            AS igv,
                        CASE
                            WHEN pin_moneda = 'PEN' THEN
                                SUM(dw.rentabsol)
                            ELSE
                                SUM(dw.rentabdol)
                        END            AS rentabilidad
                    FROM
                        dw_cventas_venta_costo_utilidad                                                   dw
                        LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dw.id_cia, dw.tipinv, dw.codart, pin_clase) ca ON 0 = 0
                    WHERE
                            dw.id_cia = pin_id_cia
                        AND ca.codigo <> 'ND'
                        AND dw.femisi BETWEEN pin_fdesde AND pin_fhasta
                        AND dw.tipinv = pin_tipinv
                    GROUP BY
                        dw.id_cia,
                        dw.tipinv,
                        dw.dtipinv,
                        ca.codigo,
                        ca.descodigo,
                        'TODOS',
                        'TODOS',
                        CASE
                            WHEN pin_moneda = 'PEN' THEN
                                    'PEN'
                            ELSE
                                'USD'
                        END
                ) dwv
            ORDER BY
                porcentaje DESC;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSE
            IF pin_codart IS NULL THEN
                SELECT
                    dwv.id_cia,
                    v_periodo,
                    v_mes,
                    v_idmes,
                    v_mesid,
                    '[ '
                    || dwv.codart
                    || ' ]  - '
                    || dwv.desart,
                    dwv.codart,
                    dwv.tipinv,
                    dwv.dtipinv,
                    dwv.codclase,
                    dwv.desclase,
                    upper(dwv.codart),
                    upper(dwv.desart),
                    dwv.moneda,
                    dwv.cantid,
                    dwv.venta,
                    dwv.costo,
                    dwv.igv,
                    dwv.rentabilidad,
                    round(decode(dwv.venta, 0, 0,(dwv.rentabilidad / dwv.venta) * 100),
                          2) AS porcentaje,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL
                BULK COLLECT
                INTO v_table
                FROM
                    (
                        SELECT
                            dw.id_cia      AS id_cia,
                            dw.tipinv      AS tipinv,
                            dw.dtipinv     AS dtipinv,
                            ca.codigo      AS codclase,
                            ca.descodigo   AS desclase,
                            dw.codart      AS codart,
                            dw.desart      AS desart,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    'PEN'
                                ELSE
                                    'USD'
                            END            AS moneda,
                            SUM(dw.cantid) AS cantid,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    SUM(dw.vntsol)
                                ELSE
                                    SUM(dw.vntdol)
                            END            AS venta,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    SUM(dw.cstsol)
                                ELSE
                                    SUM(dw.cstdol)
                            END            AS costo,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    SUM(dw.igvsol)
                                ELSE
                                    SUM(dw.igvdol)
                            END            AS igv,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    SUM(dw.rentabsol)
                                ELSE
                                    SUM(dw.rentabdol)
                            END            AS rentabilidad
                        FROM
                            dw_cventas_venta_costo_utilidad                                                   dw
                            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dw.id_cia, dw.tipinv, dw.codart, pin_clase) ca ON 0 = 0
                        WHERE
                                dw.id_cia = pin_id_cia
                            AND dw.femisi BETWEEN pin_fdesde AND pin_fhasta
                            AND dw.tipinv = pin_tipinv
                            AND ca.codigo = pin_codigo
                        GROUP BY
                            dw.id_cia,
                            dw.tipinv,
                            dw.dtipinv,
                            ca.codigo,
                            ca.descodigo,
                            dw.codart,
                            dw.desart,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                        'PEN'
                                ELSE
                                    'USD'
                            END
                    ) dwv
                ORDER BY
                    porcentaje DESC;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            ELSE
                IF pin_codartper IS NULL THEN
                    SELECT
                        dwv.id_cia,
                        dwv.periodo,
                        dwv.mes,
                        dwv.idmes,
                        dwv.mesid,
                        dwv.mes
                        || ' del '
                        || dwv.periodo,
                        TRIM(to_char(dwv.mesid, '000000')),
                        dwv.tipinv,
                        dwv.dtipinv,
                        NULL,
                        NULL,
--                        dwv.codclase,
--                        dwv.desclase,
                        dwv.codart,
                        dwv.desart,
                        dwv.moneda,
                        dwv.cantid,
                        dwv.venta,
                        dwv.costo,
                        dwv.igv,
                        dwv.rentabilidad,
                        round(decode(dwv.venta, 0, 0,(dwv.rentabilidad / dwv.venta) * 100),
                              2) AS porcentaje,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL
                    BULK COLLECT
                    INTO v_table
                    FROM
                        (
                            SELECT
                                dw.id_cia      AS id_cia,
                                dw.periodo,
                                dw.mes,
                                dw.idmes,
                                dw.mesid,
                                dw.tipinv      AS tipinv,
                                dw.dtipinv     AS dtipinv,
                                dw.codart      AS codart,
                                dw.desart      AS desart,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        'PEN'
                                    ELSE
                                        'USD'
                                END            AS moneda,
                                SUM(dw.cantid) AS cantid,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        SUM(dw.vntsol)
                                    ELSE
                                        SUM(dw.vntdol)
                                END            AS venta,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        SUM(dw.cstsol)
                                    ELSE
                                        SUM(dw.cstdol)
                                END            AS costo,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        SUM(dw.igvsol)
                                    ELSE
                                        SUM(dw.igvdol)
                                END            AS igv,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        SUM(dw.rentabsol)
                                    ELSE
                                        SUM(dw.rentabdol)
                                END            AS rentabilidad
                            FROM
                                dw_cventas_venta_costo_utilidad dw
                            WHERE
                                    dw.id_cia = pin_id_cia
                                AND dw.femisi BETWEEN pin_fdesde AND pin_fhasta
                                AND dw.tipinv = pin_tipinv
                                AND dw.codart = pin_codart
                            GROUP BY
                                dw.id_cia,
                                dw.periodo,
                                dw.mes,
                                dw.idmes,
                                dw.mesid,
                                dw.tipinv,
                                dw.dtipinv,
                                dw.codart,
                                dw.desart,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                            'PEN'
                                    ELSE
                                        'USD'
                                END
                        ) dwv
                    ORDER BY
                        mesid ASC;

                    FOR registro IN 1..v_table.count LOOP
                        PIPE ROW ( v_table(registro) );
                    END LOOP;

                    RETURN;
                ELSE
                    SELECT
                        dwv.id_cia,
                        dwv.periodo,
                        dwv.mes,
                        NULL,
                        NULL,
                        to_char(dwv.femisi, 'DD/MM/YYYY')
                        || ' - '
                        || upper(dwv.tipodocumento)
                        || ' - '
                        || dwv.series
                        || ' - '
                        || dwv.numdoc          AS rotulo,
                        to_char(dwv.numintfac) AS categoria,
                        dwv.tipinv,
                        NULL,
--                        dwv.tipoinventario,
                        NULL,
                        NULL,
                        dwv.codart,
                        NULL                   AS desart,
--                        dwv.desart,
                        dwv.moneda,
                        dwv.cantid,
                        dwv.venta,
                        dwv.costo,
                        dwv.igv,
                        dwv.rentabilidad,
                        round(decode(dwv.venta, 0, 0,(dwv.rentabilidad / dwv.venta) * 100),
                              2)               AS porcentaje,
                        to_char(dwv.femisi, 'YYYY-MM-DD'),
                        dwv.tipodocumento,
                        dwv.numintfac,
                        dwv.series,
                        dwv.numdoc,
                        dwv.cliente
                    BULK COLLECT
                    INTO v_table
                    FROM
                        (
                            SELECT
                                dw.id_cia           AS id_cia,
                                dw.periodo,
                                dw.mes,
                                dw.mesid,
                                dw.femisi,
                                dw.tipodocumento,
                                dw.numintfac,
                                dw.series,
                                dw.numdoc,
                                dw.cliente,
                                dw.tipinv           AS tipinv,
                                dw.codart           AS codart,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        'PEN'
                                    ELSE
                                        'USD'
                                END                 AS moneda,
                                SUM(decode(nvl(mt60.valor, 'N'),
                                           'S',
                                           0,
                                           nvl(dw.cantid, 0))) AS cantid,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        SUM(dw.vntsol)
                                    ELSE
                                        SUM(dw.vntdol)
                                END                 AS venta,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        SUM(decode(nvl(mt60.valor, 'N'),
                                                   'S',
                                                   0,
                                                   nvl(dw.cstsol, 0)))
                                    ELSE
                                        SUM(decode(nvl(mt60.valor, 'N'),
                                                   'S',
                                                   0,
                                                   nvl(dw.cstdol, 0)))
                                END                 AS costo,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        SUM(dw.igvsol)
                                    ELSE
                                        SUM(dw.igvdol)
                                END                 AS igv,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        SUM(dw.vntsol - decode(nvl(mt60.valor, 'N'),
                                                               'S',
                                                               0,
                                                               nvl(dw.cstsol, 0)))
                                    ELSE
                                        SUM(dw.vntdol - decode(nvl(mt60.valor, 'N'),
                                                               'S',
                                                               0,
                                                               nvl(dw.cstdol, 0)))
                                END                 AS rentabilidad
                            FROM
                                dw_cventas     dw
                                LEFT OUTER JOIN documentos_cab dc ON dc.id_cia = dw.id_cia
                                                                     AND dc.numint = dw.numintfac
                                LEFT OUTER JOIN motivos_clase  mt44 ON mt44.id_cia = dc.id_cia
                                                                      AND mt44.tipdoc = dc.tipdoc
                                                                      AND mt44.codmot = dc.codmot
                                                                      AND mt44.id = dc.id
                                                                      AND mt44.codigo = 44 -- TRANFERENCIA GRATUITA, NO SALE EN EL REPORTE
                                LEFT OUTER JOIN motivos_clase  mt60 ON mt60.id_cia = dc.id_cia
                                                                      AND mt60.tipdoc = dc.tipdoc
                                                                      AND mt60.codmot = dc.codmot
                                                                      AND mt60.id = dc.id
                                                                      AND mt60.codigo = 60 -- COSTO Y CANTIDAD EN CERO, SOLO SI ESTA EN 'S'
                                LEFT OUTER JOIN motivos_clase  mt3 ON mt3.id_cia = dc.id_cia
                                                                     AND mt3.tipdoc = dc.tipdoc
                                                                     AND mt3.codmot = dc.codmot
                                                                     AND mt3.id = dc.id
                                                                     AND mt3.codigo = 3 -- IMPRIME EN REPORTE?, SOLO SI ES 'S'
                            WHERE
                                    dw.id_cia = pin_id_cia
                                AND dw.mesid = TO_NUMBER(pin_codartper)
                                AND dw.tipinv = pin_tipinv
                                AND dw.codart = pin_codart
                                AND nvl(mt44.valor, 'N') = 'N'
                                AND nvl(mt3.valor, 'N') = 'S'
                            GROUP BY
                                dw.id_cia,
                                dw.periodo,
                                dw.mes,
                                dw.mesid,
                                dw.femisi,
                                dw.tipodocumento,
                                dw.numintfac,
                                dw.series,
                                dw.numdoc,
                                dw.cliente,
                                dw.tipinv,
--                                dw.tipoinventario,
                                dw.codart,
--                                dw.desart,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                            'PEN'
                                    ELSE
                                        'USD'
                                END
                        ) dwv
                    ORDER BY
                        dwv.femisi ASC;

                    FOR registro IN 1..v_table.count LOOP
                        PIPE ROW ( v_table(registro) );
                    END LOOP;

                    RETURN;
                END IF;
            END IF;
        END IF;

    END sp_venta_costo_utilidad_articulo;

    FUNCTION sp_ventas_mensuales_vendedor_objetivos (
        pin_id_cia     NUMBER,
        pin_jsonfilter VARCHAR2
    ) RETURN datatable_ventas_mensuales_vendedor_objetivos
        PIPELINED
    AS

        v_table     datatable_ventas_mensuales_vendedor_objetivos;
        o           json_object_t;
        pin_tipdoc  NUMBER;
        pin_tipven  NUMBER;
        pin_codven  NUMBER;
        pin_tipreg  NUMBER;
        pin_periodo NUMBER;
        pin_mes     NUMBER;
        pin_fdesde  DATE;
        pin_fhasta  DATE;
        pin_moneda  VARCHAR2(10);
        v_idmes     NUMBER := 0;
    BEGIN
        o := json_object_t.parse(pin_jsonfilter);
        pin_tipdoc := o.get_number('tipdoc');
        pin_tipven := o.get_number('tipven');
        pin_codven := o.get_number('codven');
        pin_moneda := o.get_string('moneda');
        pin_fdesde := o.get_date('fdesde');
        pin_fhasta := o.get_date('fhasta');
        pin_tipreg := o.get_number('tipreg');
        pin_periodo := o.get_string('periodo');
        pin_mes := o.get_number('mes');
        ----------------------------------------------------------------------------------------------------------------
        ---------------------------------- VENDEDOR DOCUMENTO --------------------------------------
        ----------------------------------------------------------------------------------------------------------------
        IF pin_tipven = 1 THEN
            IF pin_mes > -1 THEN
                BEGIN
                    SELECT
                        finicio,
                        ffin
                    INTO
                        pin_fdesde,
                        pin_fhasta
                    FROM
                        pack_periodo_comision.sp_buscar(pin_id_cia, pin_periodo, pin_mes);

                EXCEPTION
                    WHEN no_data_found THEN
                        pin_fdesde := trunc(TO_DATE(to_char('01'
                                                            || '/'
                                                            || pin_mes
                                                            || '/'
                                                            || pin_periodo), 'DD/MM/YYYY'));

                        pin_fhasta := last_day(trunc(TO_DATE(to_char('01'
                                                                     || '/'
                                                                     || pin_mes
                                                                     || '/'
                                                                     || pin_periodo), 'DD/MM/YYYY')));

                END;

                dbms_output.put_line(pin_fdesde);
                dbms_output.put_line(pin_fhasta);
                SELECT
                    dwv.id_cia,
                    dwv.sucursal,
                    dwv.tipdoc,
                    dwv.codven,
                    dwv.desven,
                    CASE
                        WHEN ve.abrevi IS NULL THEN
                            substr(dwv.desven, 1, 5)
                        ELSE
                            upper(ve.abrevi)
                    END AS rotulo,
                    dwv.periodo,
                    dwv.mes,
                    dwv.idmes,
                    dwv.mesid,
                    dwv.moneda,
                    dwv.venta,
                    dwv.meta,
                    CASE
                        WHEN dwv.venta >= nvl(dwv.meta, 0) THEN
                            dwv.venta
                        ELSE
                            0
                    END AS ventaup,
                    CASE
                        WHEN dwv.venta < nvl(dwv.meta, 0) THEN
                            dwv.venta
                        ELSE
                            0
                    END AS ventadown,
                    CASE
                        WHEN dwv.venta > nvl(dwv.meta, 0) THEN
                            dwv.venta
                        ELSE
                            dwv.meta
                    END AS base,
                    CASE
                        WHEN dwv.venta > nvl(dwv.meta, 0) THEN
                            dwv.venta - dwv.meta
                        ELSE
                            0
                    END AS cumplio,
                    CASE
                        WHEN dwv.venta < nvl(dwv.meta, 0) THEN
                            dwv.meta - dwv.venta
                        ELSE
                            0
                    END AS nocumplio
                BULK COLLECT
                INTO v_table
                FROM
                    (
                        SELECT
                            dw.id_cia                     AS id_cia,
                            dw.sucursal                   AS sucursal,
                            'TODOS'                       AS tipdoc,
                            dw.codven                     AS codven,
                            dw.vendedor                   AS desven,
                            pin_periodo                   AS periodo,
                            upper(to_char(TO_DATE(pin_mes, 'MM'),
                                          'month',
                                          'nls_date_language=spanish')) AS mes,
                            pin_mes                       AS idmes,
                            pin_periodo * 100 + pin_mes   AS mesid,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    'PEN'
                                ELSE
                                    'USD'
                            END                           AS moneda,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    SUM(dw.vntsol)
                                ELSE
                                    SUM(dw.vntdol)
                            END                           AS venta,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    MAX(vm.meta01)
                                ELSE
                                    MAX(vm.meta02)
                            END                           AS meta,
                            SUM(0)                        AS extra,
                            SUM(0)                        AS falta
                        FROM
                            dw_cventas_vendedor_documento_x_dia dw
                            LEFT OUTER JOIN vendedor_metas                      vm ON vm.id_cia = dw.id_cia
                                                                 AND vm.codven = dw.codven
                                                                 AND vm.periodo = pin_periodo
                                                                 AND vm.mes = pin_mes
                        WHERE
                                dw.id_cia = pin_id_cia
                            AND ( dw.codven = pin_codven
                                  OR pin_codven = - 1 )
                            AND dw.codven <> 999
                            AND dw.femisi BETWEEN pin_fdesde AND pin_fhasta
                        GROUP BY
                            dw.id_cia,
                            dw.sucursal,
                            'TODOS',
                            dw.codven,
                            dw.vendedor,
                            pin_periodo,
                            upper(to_char(TO_DATE(pin_mes, 'MM'),
                                          'month',
                                          'nls_date_language=spanish')),
                            pin_mes,
                            pin_periodo * 100 + pin_mes,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                        'PEN'
                                ELSE
                                    'USD'
                            END
                    )        dwv
                    LEFT OUTER JOIN vendedor ve ON ve.id_cia = dwv.id_cia
                                                   AND ve.codven = dwv.codven
                ORDER BY
                    ve.codven ASC;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            ELSE
                pin_fdesde := trunc(TO_DATE(to_char('01'
                                                    || '/'
                                                    || '01'
                                                    || '/'
                                                    || pin_periodo), 'DD/MM/YYYY'));

                pin_fhasta := last_day(trunc(TO_DATE(to_char('01'
                                                             || '/'
                                                             || '12'
                                                             || '/'
                                                             || pin_periodo), 'DD/MM/YYYY')));

                IF pin_codven = -1 THEN
                    SELECT
                        dwv.id_cia,
                        dwv.sucursal,
                        dwv.tipdoc,
                        dwv.codven,
                        dwv.desven,
                        CASE
                            WHEN ve.abrevi IS NULL THEN
                                substr(dwv.desven, 1, 5)
                            ELSE
                                upper(ve.abrevi)
                        END AS rotulo,
                        pin_periodo,
                        'TODOS',
                        00,
                        pin_periodo * 100,
                        dwv.moneda,
                        dwv.venta,
                        dwv.meta,
                        CASE
                            WHEN dwv.venta >= nvl(dwv.meta, 0) THEN
                                dwv.venta
                            ELSE
                                0
                        END AS ventaup,
                        CASE
                            WHEN dwv.venta < nvl(dwv.meta, 0) THEN
                                dwv.venta
                            ELSE
                                0
                        END AS ventadown,
                        CASE
                            WHEN dwv.venta > nvl(dwv.meta, 0) THEN
                                dwv.venta
                            ELSE
                                dwv.meta
                        END AS base,
                        CASE
                            WHEN dwv.venta > nvl(dwv.meta, 0) THEN
                                dwv.venta - dwv.meta
                            ELSE
                                0
                        END AS cumplio,
                        CASE
                            WHEN dwv.venta < nvl(dwv.meta, 0) THEN
                                dwv.meta - dwv.venta
                            ELSE
                                0
                        END AS nocumplio
                    BULK COLLECT
                    INTO v_table
                    FROM
                        (
                            SELECT
                                dw.id_cia   AS id_cia,
                                dw.sucursal AS sucursal,
                                'TODOS'     AS tipdoc,
                                dw.codven   AS codven,
                                dw.vendedor AS desven,
                                dw.vendedor AS rotulo,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        'PEN'
                                    ELSE
                                        'USD'
                                END         AS moneda,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        SUM(dw.vntsol)
                                    ELSE
                                        SUM(dw.vntdol)
                                END         AS venta,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        MAX(vm.meta01)
                                    ELSE
                                        MAX(vm.meta02)
                                END         AS meta
                            FROM
                                dw_cventas_vendedor_documento_x_dia dw
                                LEFT OUTER JOIN vendedor_metas                      vm ON vm.id_cia = dw.id_cia
                                                                     AND vm.codven = dw.codven
                                                                     AND vm.periodo = pin_periodo
                                                                     AND vm.mes = 0
                            WHERE
                                    dw.id_cia = pin_id_cia
                                AND dw.codven <> 999
                                AND dw.femisi BETWEEN pin_fdesde AND pin_fhasta
                            GROUP BY
                                dw.id_cia,
                                dw.sucursal,
                                'TODOS',
                                dw.codven,
                                dw.vendedor,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                            'PEN'
                                    ELSE
                                        'USD'
                                END
                        )        dwv
                        LEFT OUTER JOIN vendedor ve ON ve.id_cia = dwv.id_cia
                                                       AND ve.codven = dwv.codven
                    ORDER BY
                        ve.codven ASC;

                    FOR registro IN 1..v_table.count LOOP
                        PIPE ROW ( v_table(registro) );
                    END LOOP;

                    RETURN;
                ELSE
                    SELECT
                        dwv.id_cia,
                        dwv.sucursal,
                        dwv.tipdoc,
                        dwv.codven,
                        dwv.desven,
                        substr(dwv.mes, 1, 3) AS rotulo,
                        dwv.periodo,
                        dwv.mes,
                        dwv.idmes,
                        dwv.mesid,
                        dwv.moneda,
                        dwv.venta,
                        dwv.meta,
                        CASE
                            WHEN dwv.venta >= nvl(dwv.meta, 0) THEN
                                dwv.venta
                            ELSE
                                0
                        END                   AS ventaup,
                        CASE
                            WHEN dwv.venta < nvl(dwv.meta, 0) THEN
                                dwv.venta
                            ELSE
                                0
                        END                   AS ventadown,
                        CASE
                            WHEN dwv.venta > nvl(dwv.meta, 0) THEN
                                dwv.venta
                            ELSE
                                dwv.meta
                        END                   AS base,
                        CASE
                            WHEN dwv.venta > nvl(dwv.meta, 0) THEN
                                dwv.venta - dwv.meta
                            ELSE
                                0
                        END                   AS cumplio,
                        CASE
                            WHEN dwv.venta < nvl(dwv.meta, 0) THEN
                                dwv.meta - dwv.venta
                            ELSE
                                0
                        END                   AS nocumplio
                    BULK COLLECT
                    INTO v_table
                    FROM
                        (
                            SELECT
                                dw.id_cia                     AS id_cia,
                                dw.sucursal                   AS sucursal,
                                dw.periodo                    AS periodo,
                                upper(to_char(TO_DATE(dw.idmes, 'MM'),
                                              'month',
                                              'nls_date_language=spanish')) AS mes,
                                dw.idmes                      AS idmes,
                                dw.periodo * 100 + dw.idmes   AS mesid,
                                'TODOS'                       AS tipdoc,
                                dw.codven                     AS codven,
                                dw.vendedor                   AS desven,
--                            dw.vendedor                                                                    AS rotulo,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        'PEN'
                                    ELSE
                                        'USD'
                                END                           AS moneda,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        SUM(dw.vntsol)
                                    ELSE
                                        SUM(dw.vntdol)
                                END                           AS venta,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        MAX(vm.meta01)
                                    ELSE
                                        MAX(vm.meta02)
                                END                           AS meta,
                                SUM(0)                        AS extra,
                                SUM(0)                        AS falta
                            FROM
                                dw_cventas_vendedor_documento_x_dia dw
                                LEFT OUTER JOIN vendedor_metas                      vm ON vm.id_cia = dw.id_cia
                                                                     AND vm.codven = dw.codven
                                                                     AND vm.periodo = pin_periodo
                                                                     AND vm.mes BETWEEN 1 AND 12
                            WHERE
                                    dw.id_cia = pin_id_cia
                                AND dw.codven = pin_codven
                                AND dw.codven <> 999
                                AND dw.femisi BETWEEN pin_fdesde AND pin_fhasta
                            GROUP BY
                                dw.id_cia,
                                dw.sucursal,
                                dw.periodo,
                                upper(to_char(TO_DATE(dw.idmes, 'MM'),
                                              'month',
                                              'nls_date_language=spanish')),
                                dw.idmes,
                                dw.periodo * 100 + dw.idmes,
                                'TODOS',
                                dw.codven,
                                dw.vendedor,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                            'PEN'
                                    ELSE
                                        'USD'
                                END
                        ) dwv
                    ORDER BY
                        dwv.mesid ASC;

                    FOR registro IN 1..v_table.count LOOP
                        PIPE ROW ( v_table(registro) );
                    END LOOP;

                    RETURN;
                END IF;

            END IF;
        ----------------------------------------------------------------------------------------------------------------
        ---------------------------------- VENDEDOR CARTERA ------------------------------------------
        ----------------------------------------------------------------------------------------------------------------
        ELSE
            IF pin_mes > -1 THEN
                BEGIN
                    SELECT
                        finicio,
                        ffin
                    INTO
                        pin_fdesde,
                        pin_fhasta
                    FROM
                        pack_periodo_comision.sp_buscar(pin_id_cia, pin_periodo, pin_mes);

                EXCEPTION
                    WHEN no_data_found THEN
                        pin_fdesde := trunc(TO_DATE(to_char('01'
                                                            || '/'
                                                            || pin_mes
                                                            || '/'
                                                            || pin_periodo), 'DD/MM/YYYY'));

                        pin_fhasta := last_day(trunc(TO_DATE(to_char('01'
                                                                     || '/'
                                                                     || pin_mes
                                                                     || '/'
                                                                     || pin_periodo), 'DD/MM/YYYY')));

                END;

                dbms_output.put_line(pin_fdesde);
                dbms_output.put_line(pin_fhasta);
                SELECT
                    dwv.id_cia,
                    dwv.sucursal,
                    dwv.tipdoc,
                    dwv.codven,
                    dwv.desven,
                    CASE
                        WHEN ve.abrevi IS NULL THEN
                            substr(dwv.desven, 1, 5)
                        ELSE
                            upper(ve.abrevi)
                    END AS rotulo,
                    dwv.periodo,
                    dwv.mes,
                    dwv.idmes,
                    dwv.mesid,
                    dwv.moneda,
                    dwv.venta,
                    dwv.meta,
                    CASE
                        WHEN dwv.venta >= nvl(dwv.meta, 0) THEN
                            dwv.venta
                        ELSE
                            0
                    END AS ventaup,
                    CASE
                        WHEN dwv.venta < nvl(dwv.meta, 0) THEN
                            dwv.venta
                        ELSE
                            0
                    END AS ventadown,
                    CASE
                        WHEN dwv.venta > nvl(dwv.meta, 0) THEN
                            dwv.venta
                        ELSE
                            dwv.meta
                    END AS base,
                    CASE
                        WHEN dwv.venta > nvl(dwv.meta, 0) THEN
                            dwv.venta - dwv.meta
                        ELSE
                            0
                    END AS cumplio,
                    CASE
                        WHEN dwv.venta < nvl(dwv.meta, 0) THEN
                            dwv.meta - dwv.venta
                        ELSE
                            0
                    END AS nocumplio
                BULK COLLECT
                INTO v_table
                FROM
                    (
                        SELECT
                            dw.id_cia                     AS id_cia,
                            dw.sucursal                   AS sucursal,
                            'TODOS'                       AS tipdoc,
                            dw.codven                     AS codven,
                            dw.vendedor                   AS desven,
                            pin_periodo                   AS periodo,
                            upper(to_char(TO_DATE(pin_mes, 'MM'),
                                          'month',
                                          'nls_date_language=spanish')) AS mes,
                            pin_mes                       AS idmes,
                            pin_periodo * 100 + pin_mes   AS mesid,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    'PEN'
                                ELSE
                                    'USD'
                            END                           AS moneda,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    SUM(dw.vntsol)
                                ELSE
                                    SUM(dw.vntdol)
                            END                           AS venta,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                    MAX(vm.meta01)
                                ELSE
                                    MAX(vm.meta02)
                            END                           AS meta,
                            SUM(0)                        AS extra,
                            SUM(0)                        AS falta
                        FROM
                            dw_cventas_vendedor_cartera_x_dia dw
                            LEFT OUTER JOIN vendedor_metas                    vm ON vm.id_cia = dw.id_cia
                                                                 AND vm.codven = dw.codven
                                                                 AND vm.periodo = pin_periodo
                                                                 AND vm.mes = pin_mes
                        WHERE
                                dw.id_cia = pin_id_cia
                            AND ( dw.codven = pin_codven
                                  OR pin_codven = - 1 )
                            AND dw.codven <> 999
                            AND dw.femisi BETWEEN pin_fdesde AND pin_fhasta
                        GROUP BY
                            dw.id_cia,
                            dw.sucursal,
                            'TODOS',
                            dw.codven,
                            dw.vendedor,
                            pin_periodo,
                            upper(to_char(TO_DATE(pin_mes, 'MM'),
                                          'month',
                                          'nls_date_language=spanish')),
                            pin_mes,
                            pin_periodo * 100 + pin_mes,
                            CASE
                                WHEN pin_moneda = 'PEN' THEN
                                        'PEN'
                                ELSE
                                    'USD'
                            END
                    )        dwv
                    LEFT OUTER JOIN vendedor ve ON ve.id_cia = dwv.id_cia
                                                   AND ve.codven = dwv.codven
                ORDER BY
                    ve.codven ASC;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            ELSE
                pin_fdesde := trunc(TO_DATE(to_char('01'
                                                    || '/'
                                                    || '01'
                                                    || '/'
                                                    || pin_periodo), 'DD/MM/YYYY'));

                pin_fhasta := last_day(trunc(TO_DATE(to_char('01'
                                                             || '/'
                                                             || '12'
                                                             || '/'
                                                             || pin_periodo), 'DD/MM/YYYY')));

                IF pin_codven = -1 THEN
                    SELECT
                        dwv.id_cia,
                        dwv.sucursal,
                        dwv.tipdoc,
                        dwv.codven,
                        dwv.desven,
                        CASE
                            WHEN ve.abrevi IS NULL THEN
                                substr(dwv.desven, 1, 5)
                            ELSE
                                upper(ve.abrevi)
                        END AS rotulo,
                        pin_periodo,
                        'TODOS',
                        00,
                        pin_periodo * 100,
                        dwv.moneda,
                        dwv.venta,
                        dwv.meta,
                        CASE
                            WHEN dwv.venta >= nvl(dwv.meta, 0) THEN
                                dwv.venta
                            ELSE
                                0
                        END AS ventaup,
                        CASE
                            WHEN dwv.venta < nvl(dwv.meta, 0) THEN
                                dwv.venta
                            ELSE
                                0
                        END AS ventadown,
                        CASE
                            WHEN dwv.venta > nvl(dwv.meta, 0) THEN
                                dwv.venta
                            ELSE
                                dwv.meta
                        END AS base,
                        CASE
                            WHEN dwv.venta > nvl(dwv.meta, 0) THEN
                                dwv.venta - dwv.meta
                            ELSE
                                0
                        END AS cumplio,
                        CASE
                            WHEN dwv.venta < nvl(dwv.meta, 0) THEN
                                dwv.meta - dwv.venta
                            ELSE
                                0
                        END AS nocumplio
                    BULK COLLECT
                    INTO v_table
                    FROM
                        (
                            SELECT
                                dw.id_cia   AS id_cia,
                                dw.sucursal AS sucursal,
                                'TODOS'     AS tipdoc,
                                dw.codven   AS codven,
                                dw.vendedor AS desven,
                                dw.vendedor AS rotulo,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        'PEN'
                                    ELSE
                                        'USD'
                                END         AS moneda,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        SUM(dw.vntsol)
                                    ELSE
                                        SUM(dw.vntdol)
                                END         AS venta,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        MAX(vm.meta01)
                                    ELSE
                                        MAX(vm.meta02)
                                END         AS meta
                            FROM
                                dw_cventas_vendedor_cartera_x_dia dw
                                LEFT OUTER JOIN vendedor_metas                    vm ON vm.id_cia = dw.id_cia
                                                                     AND vm.codven = dw.codven
                                                                     AND vm.periodo = pin_periodo
                                                                     AND vm.mes = 0
                            WHERE
                                    dw.id_cia = pin_id_cia
                                AND dw.codven <> 999
                                AND dw.femisi BETWEEN pin_fdesde AND pin_fhasta
                            GROUP BY
                                dw.id_cia,
                                dw.sucursal,
                                'TODOS',
                                dw.codven,
                                dw.vendedor,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                            'PEN'
                                    ELSE
                                        'USD'
                                END
                        )        dwv
                        LEFT OUTER JOIN vendedor ve ON ve.id_cia = dwv.id_cia
                                                       AND ve.codven = dwv.codven
                    ORDER BY
                        ve.codven ASC;

                    FOR registro IN 1..v_table.count LOOP
                        PIPE ROW ( v_table(registro) );
                    END LOOP;

                    RETURN;
                ELSE
                    SELECT
                        dwv.id_cia,
                        dwv.sucursal,
                        dwv.tipdoc,
                        dwv.codven,
                        dwv.desven,
                        substr(dwv.mes, 1, 3) AS rotulo,
                        dwv.periodo,
                        dwv.mes,
                        dwv.idmes,
                        dwv.mesid,
                        dwv.moneda,
                        dwv.venta,
                        dwv.meta,
                        CASE
                            WHEN dwv.venta >= nvl(dwv.meta, 0) THEN
                                dwv.venta
                            ELSE
                                0
                        END                   AS ventaup,
                        CASE
                            WHEN dwv.venta < nvl(dwv.meta, 0) THEN
                                dwv.venta
                            ELSE
                                0
                        END                   AS ventadown,
                        CASE
                            WHEN dwv.venta > nvl(dwv.meta, 0) THEN
                                dwv.venta
                            ELSE
                                dwv.meta
                        END                   AS base,
                        CASE
                            WHEN dwv.venta > nvl(dwv.meta, 0) THEN
                                dwv.venta - dwv.meta
                            ELSE
                                0
                        END                   AS cumplio,
                        CASE
                            WHEN dwv.venta < nvl(dwv.meta, 0) THEN
                                dwv.meta - dwv.venta
                            ELSE
                                0
                        END                   AS nocumplio
                    BULK COLLECT
                    INTO v_table
                    FROM
                        (
                            SELECT
                                dw.id_cia                     AS id_cia,
                                dw.sucursal                   AS sucursal,
                                dw.periodo                    AS periodo,
                                upper(to_char(TO_DATE(dw.idmes, 'MM'),
                                              'month',
                                              'nls_date_language=spanish')) AS mes,
                                dw.idmes                      AS idmes,
                                dw.periodo * 100 + dw.idmes   AS mesid,
                                'TODOS'                       AS tipdoc,
                                dw.codven                     AS codven,
                                dw.vendedor                   AS desven,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        'PEN'
                                    ELSE
                                        'USD'
                                END                           AS moneda,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        SUM(dw.vntsol)
                                    ELSE
                                        SUM(dw.vntdol)
                                END                           AS venta,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                        MAX(vm.meta01)
                                    ELSE
                                        MAX(vm.meta02)
                                END                           AS meta
                            FROM
                                dw_cventas_vendedor_cartera_x_dia dw
                                LEFT OUTER JOIN vendedor_metas                    vm ON vm.id_cia = dw.id_cia
                                                                     AND vm.codven = dw.codven
                                                                     AND vm.periodo = pin_periodo
                                                                     AND vm.mes BETWEEN 1 AND 12
                            WHERE
                                    dw.id_cia = pin_id_cia
                                AND dw.codven = pin_codven
                                AND dw.codven <> 999
                                AND dw.femisi BETWEEN pin_fdesde AND pin_fhasta
                            GROUP BY
                                dw.id_cia,
                                dw.sucursal,
                                dw.periodo,
                                upper(to_char(TO_DATE(dw.idmes, 'MM'),
                                              'month',
                                              'nls_date_language=spanish')),
                                dw.idmes,
                                dw.periodo * 100 + dw.idmes,
                                'TODOS',
                                dw.codven,
                                dw.vendedor,
                                CASE
                                    WHEN pin_moneda = 'PEN' THEN
                                            'PEN'
                                    ELSE
                                        'USD'
                                END
                        ) dwv
                    ORDER BY
                        dwv.mesid ASC;

                    FOR registro IN 1..v_table.count LOOP
                        PIPE ROW ( v_table(registro) );
                    END LOOP;

                    RETURN;
                END IF;

            END IF;
        END IF;

    END sp_ventas_mensuales_vendedor_objetivos;

END;

/
