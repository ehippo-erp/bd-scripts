--------------------------------------------------------
--  DDL for Package Body PACK_DEPRECIACION_ACTIVOS_FIJOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DEPRECIACION_ACTIVOS_FIJOS" AS

    FUNCTION sp_reporte (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_clase   NUMBER
    ) RETURN datatable_reporte_buscar
        PIPELINED
    AS

        v_rec    datarecord_reporte_buscar := datarecord_reporte_buscar(NULL, NULL, NULL, NULL, NULL,
                                                                    NULL, NULL, NULL, NULL, 0,
                                                                    NULL, 0, 0, 0, 0,
                                                                    0, 0, 0, 0, 0,
                                                                    0, 0, 0, 0, 0,
                                                                    0, 0, 0, 0);
        v_pdesde NUMBER := pin_periodo * 100;
        v_phasta NUMBER := ( pin_periodo * 100 ) + pin_mes;
    BEGIN
        FOR i IN (
            SELECT
                a.id_cia,
                a.tipinv,
                t.dtipinv,
                a.codart,
                a.descri           AS desart,
                acc.codigo,
                acc.descodigo,
                ae1.vdate          AS fecadq,
                ae22.vdate         AS fecdep,
                ae2.vreal          AS totact,
                acc4.codigo || '%' AS tasa
            FROM
                articulos                                                                      a
                LEFT OUTER JOIN t_inventario                                                                   t ON t.id_cia = a.id_cia
                                                  AND t.tipinv = a.tipinv
                LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, pin_clase) acc ON 0 = 0
                LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 4)         acc4 ON 0 = 0
                LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 6)         acc6 ON 0 = 0
                LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 9)         acc9 ON 0 = 0
                LEFT OUTER JOIN articulo_especificacion                                                        ae22 ON ae22.id_cia = a.
                id_cia
                                                                AND ae22.tipinv = a.tipinv
                                                                AND ae22.codart = a.codart
                                                                AND ae22.codesp = 22
                LEFT OUTER JOIN articulo_especificacion                                                        ae2 ON ae2.id_cia = a.
                id_cia
                                                               AND ae2.tipinv = a.tipinv
                                                               AND ae2.codart = a.codart
                                                               AND ae2.codesp = 2
                LEFT OUTER JOIN articulo_especificacion                                                        ae1 ON ae1.id_cia = a.
                id_cia
                                                               AND ae1.tipinv = a.tipinv
                                                               AND ae1.codart = a.codart
                                                               AND ae1.codesp = 1
            WHERE
                    a.id_cia = pin_id_cia
            -- ACTIVO FIJO CON DEPRECIACION
                AND a.tipinv = 100
                AND acc9.codigo = '1'
                AND acc6.codigo = 'S'
                AND ( ( EXTRACT(YEAR FROM ae1.vdate) = pin_periodo
                        AND EXTRACT(MONTH FROM ae1.vdate) <= pin_mes )
                      OR EXISTS (
                    SELECT
                        ad.*
                    FROM
                        articulos_depreciacion ad
                    WHERE
                            ad.id_cia = a.id_cia
                        AND ad.tipinv = a.tipinv
                        AND ad.codart = a.codart
                        AND ad.periodo = pin_periodo
                        AND ad.mes <= pin_mes
                ) )
            ORDER BY
                acc.clase,
                a.codart
        ) LOOP
            v_rec.id_cia := i.id_cia;
            v_rec.tipinv := i.tipinv;
            v_rec.dtipinv := i.dtipinv;
            v_rec.codart := i.codart;
            v_rec.desart := i.desart;
            v_rec.codigo := i.codigo;
            v_rec.descodigo := i.descodigo;
            v_rec.fecadq := i.fecadq;
            v_rec.fecdep := i.fecdep;
            v_rec.tasa := i.tasa;
            IF v_rec.fecadq > to_date('01/01/' || pin_periodo, 'DD/MM/YYYY') THEN
                v_rec.actperiodo := i.totact;
                v_rec.actacumulado := 0;
            ELSE
                v_rec.actperiodo := 0;
                v_rec.actacumulado := i.totact;
            END IF;

            v_rec.acttotal := v_rec.actacumulado + v_rec.actperiodo;
            FOR e IN (
                SELECT
                    ad.tipinv,
                    ad.codart,
                    ad.periodo,
                    ad.mes,
                    nvl(SUM(nvl(ad.costot01, 0)), 0) AS total,
                    nvl(MAX(nvl(ad.acumu01, 0)), 0)  AS acumulado
                FROM
                    articulos              a
                    LEFT OUTER JOIN articulos_depreciacion ad ON ad.id_cia = a.id_cia
                                                                 AND ad.tipinv = a.tipinv
                                                                 AND ad.codart = a.codart
                WHERE
                        a.id_cia = i.id_cia
                    AND a.tipinv = i.tipinv
                    AND a.codart = i.codart
                    AND ( ( ad.periodo * 100 ) + ad.mes ) BETWEEN v_pdesde AND v_phasta
                GROUP BY
                    ad.tipinv,
                    ad.codart,
                    ad.periodo,
                    ad.mes
                UNION
                SELECT
                    ad.tipinv,
                    ad.codart,
                    0                               AS periodo,
                    0                               AS mes,
                    nvl(MAX(nvl(ad.acumu01, 0)), 0) AS total,
                    MAX(0.0)                        AS acumulado
                FROM
                    articulos              a
                    LEFT OUTER JOIN articulos_depreciacion ad ON ad.id_cia = a.id_cia
                                                                 AND ad.tipinv = a.tipinv
                                                                 AND ad.codart = a.codart
                WHERE
                        a.id_cia = i.id_cia
                    AND a.tipinv = i.tipinv
                    AND a.codart = i.codart
                    AND ( ( ad.periodo * 100 ) + ad.mes ) < v_pdesde
                GROUP BY
                    ad.tipinv,
                    ad.codart,
                    0,
                    0
            ) LOOP
                CASE
                    WHEN e.mes = 0 THEN
                        v_rec.depacumulado := e.total;
                    WHEN e.mes = 1 THEN
                        v_rec.depenero := e.total;
                    WHEN e.mes = 2 THEN
                        v_rec.depfebrero := e.total;
                    WHEN e.mes = 3 THEN
                        v_rec.depmarzo := e.total;
                    WHEN e.mes = 4 THEN
                        v_rec.depabril := e.total;
                    WHEN e.mes = 5 THEN
                        v_rec.depmayo := e.total;
                    WHEN e.mes = 6 THEN
                        v_rec.depjunio := e.total;
                    WHEN e.mes = 7 THEN
                        v_rec.depjulio := e.total;
                    WHEN e.mes = 8 THEN
                        v_rec.depagosto := e.total;
                    WHEN e.mes = 9 THEN
                        v_rec.depseptiembre := e.total;
                    WHEN e.mes = 10 THEN
                        v_rec.depoctubre := e.total;
                    WHEN e.mes = 11 THEN
                        v_rec.depnoviembre := e.total;
                    WHEN e.mes = 12 THEN
                        v_rec.depdiciembre := e.total;
                END CASE;

                v_rec.depperiodo := v_rec.depenero + v_rec.depfebrero + v_rec.depmarzo + v_rec.depabril + v_rec.depmayo + v_rec.depjunio +
                v_rec.depjulio + v_rec.depagosto + v_rec.depseptiembre + v_rec.depoctubre + v_rec.depnoviembre + v_rec.depdiciembre;

                v_rec.deptotal := v_rec.depacumulado + v_rec.depperiodo;
            END LOOP;

            v_rec.actneto := v_rec.acttotal - v_rec.deptotal;
            PIPE ROW ( v_rec );
        END LOOP;
    END sp_reporte;

    FUNCTION sp_activo_fijo (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER
    ) RETURN datatable_activo_fijo
        PIPELINED
    AS
        v_table datatable_activo_fijo;
    BEGIN
        SELECT
            a.id_cia,
            a.tipinv,
            t.dtipinv,
            acc2.codigo        AS cuenta,
            acc2.descodigo     AS descuenta,
            a.codart,
            a.descri           AS desart,
            ae3.vstrg          AS marca,
            ae5.vstrg          AS modelo,
            ae6.vstrg          AS serie,
            dp.actacumulado,
            dp.actperiodo,
            dp.actmejora,
            dp.actretiro_bajas,
            dp.actajsute_otros, -- NO DEFINIDO DELPHI
            dp.acthis_acumulado,
            dp.actajuste_inflacion, -- NO DEFINIDO DELPHI
            dp.actaju_acumulado,
            ae4.vdate          AS fecadq,
            ae.vdate           AS fecdep,
            acc4.codigo || '%' AS tasa,
            acc2.codigo        AS codmetdep,
            acc2.descodigo     AS desmetdep,
            dp.depacumulado,
            dp.depperiodo,
            dp.depretiro_bajas,
            dp.depajuste_otros, -- NO DEFINIDO DELPHI
            dp.dephis_acumulado,
            dp.depajuste_inflacion,
            dp.depaju_acumulado
        BULK COLLECT
        INTO v_table
        FROM
            articulos                                                                                  a
            LEFT OUTER JOIN t_inventario                                                                               t ON t.id_cia =
            a.id_cia
                                              AND t.tipinv = a.tipinv
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 2)                     acc2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 3)                     acc3 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 4)                     acc4 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 6)                     acc6 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 8)                     acc8 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 9)                     acc9 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 10)                    acc10 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 12)                    acc12 ON 0 = 0
            LEFT OUTER JOIN articulo_especificacion                                                                    ae ON ae.id_cia =
            a.id_cia
                                                          AND ae.tipinv = a.tipinv
                                                          AND ae.codart = a.codart
                                                          AND ae.codesp = 22
            LEFT OUTER JOIN articulo_especificacion                                                                    ae2 ON ae2.id_cia =
            a.id_cia
                                                           AND ae2.tipinv = a.tipinv
                                                           AND ae2.codart = a.codart
                                                           AND ae2.codesp = 2
            LEFT OUTER JOIN articulo_especificacion                                                                    ae3 ON ae3.id_cia =
            a.id_cia
                                                           AND ae3.tipinv = a.tipinv
                                                           AND ae3.codart = a.codart
                                                           AND ae3.codesp = 7
            LEFT OUTER JOIN articulo_especificacion                                                                    ae4 ON ae4.id_cia =
            a.id_cia
                                                           AND ae4.tipinv = a.tipinv
                                                           AND ae4.codart = a.codart
                                                           AND ae4.codesp = 1
            LEFT OUTER JOIN articulo_especificacion                                                                    ae5 ON ae5.id_cia =
            a.id_cia
                                                           AND ae5.tipinv = a.tipinv
                                                           AND ae5.codart = a.codart
                                                           AND ae5.codesp = 8
            LEFT OUTER JOIN articulo_especificacion                                                                    ae6 ON ae6.id_cia =
            a.id_cia
                                                           AND ae6.tipinv = a.tipinv
                                                           AND ae6.codart = a.codart
                                                           AND ae6.codesp = 9
            LEFT OUTER JOIN pack_depreciacion_activos_fijos.sp_depreciacion(a.id_cia, pin_periodo, a.tipinv, a.codart) dp ON 0 = 0
        WHERE
                a.id_cia = pin_id_cia
            AND a.tipinv = 100
            AND acc9.codigo = '1'
            AND acc6.codigo = 'S'
            AND ( ( EXTRACT(YEAR FROM ae4.vdate) = pin_periodo
                    AND EXTRACT(YEAR FROM ae.vdate) > pin_periodo )
                  OR EXISTS (
                SELECT
                    ad.*
                FROM
                    articulos_depreciacion ad
                WHERE
                        ad.id_cia = a.id_cia
                    AND ad.tipinv = a.tipinv
                    AND ad.codart = a.codart
                    AND ad.periodo = pin_periodo
            ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_activo_fijo;

    FUNCTION sp_activo_leasing (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER
    ) RETURN datatable_activo_leasing
        PIPELINED
    AS
        v_table datatable_activo_leasing;
    BEGIN
        SELECT
            a.id_cia,
            a.tipinv,
            t.dtipinv,
            a.codart,
            a.descri    AS desart,
            ae.vdate    AS fcontra,
            ae2.vstrg   AS nrocontra,
            ae3.vdate   AS finicio,
            ae4.ventero AS nrocuotas,
            ae5.vreal   AS monto
        BULK COLLECT
        INTO v_table
        FROM
            articulos               a
            LEFT OUTER JOIN t_inventario            t ON t.id_cia = a.id_cia
                                              AND t.tipinv = a.tipinv
            LEFT OUTER JOIN articulos_clase         ac ON ac.id_cia = a.id_cia
                                                  AND ac.tipinv = a.tipinv
                                                  AND ac.codart = a.codart
                                                  AND ac.clase = 8 /* 8-TIPO DE ACTIVO*/
            LEFT OUTER JOIN articulo_especificacion ae ON ae.id_cia = a.id_cia
                                                          AND ae.tipinv = a.tipinv
                                                          AND ae.codart = a.codart
                                                          AND ae.codesp = 27 /*27-FECHA CONTRATO LEASING*/
            LEFT OUTER JOIN articulo_especificacion ae2 ON ae2.id_cia = a.id_cia
                                                           AND ae2.tipinv = a.tipinv
                                                           AND ae2.codart = a.codart
                                                           AND ae2.codesp = 28 /*28-NRO CONTRATO LEASING*/
            LEFT OUTER JOIN articulo_especificacion ae3 ON ae3.id_cia = a.id_cia
                                                           AND ae3.tipinv = a.tipinv
                                                           AND ae3.codart = a.codart
                                                           AND ae3.codesp = 29/*29-FECHA INICIO CONTRARO LEASING*/
            LEFT OUTER JOIN articulo_especificacion ae4 ON ae4.id_cia = a.id_cia
                                                           AND ae4.tipinv = a.tipinv
                                                           AND ae4.codart = a.codart
                                                           AND ae4.codesp = 30 /*30- NRO DE CUOTAS LEASING*/
            LEFT OUTER JOIN articulo_especificacion ae5 ON ae5.id_cia = a.id_cia
                                                           AND ae5.tipinv = a.tipinv
                                                           AND ae5.codart = a.codart
                                                           AND ae5.codesp = 2 /*VALOR DE COMPRA EN SOLES*/
        WHERE
                a.id_cia = pin_id_cia
            AND a.tipinv = 100
            AND EXTRACT(YEAR FROM ae.vdate) <= pin_periodo
            AND ac.codigo = '2' /*2-LEASING*/
        ORDER BY
            ae.vdate;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_activo_leasing;

    FUNCTION sp_depreciacion (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_tipinv  NUMBER,
        pin_codart  VARCHAR2
    ) RETURN datatable_depreciacion
        PIPELINED
    AS

        v_rec        datarecord_depreciacion := datarecord_depreciacion(0, 0, 0, 0, 0,
                                                                0, 0, 0, 0, 0,
                                                                0, 0, 0, 0, 0);
        v_bajperiodo VARCHAR2(1 CHAR) := 'N';
        v_fecadq     DATE;
        v_totact     NUMBER(16, 2);
        v_mejora     NUMBER(16, 2);
    BEGIN


        -- ESPECIFICACION - TOTAL DE ACTIVO    
        BEGIN
            SELECT
                vreal
            INTO v_totact
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 2;

        EXCEPTION
            WHEN no_data_found THEN
                v_totact := 0;
        END;

        -- ESPECIFICACION - FECHA DE ADQUISION    
        BEGIN
            SELECT
                vdate
            INTO v_fecadq
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 1;

        EXCEPTION
            WHEN no_data_found THEN
                v_fecadq := TO_DATE('01/01/2000', 'DD/MM/YY');
        END;

        -- ESPECIFICACION - PERIODO DE BAJA    
        BEGIN
            SELECT
                CASE
                    WHEN EXTRACT(YEAR FROM vdate) = pin_periodo THEN
                        'S'
                    ELSE
                        'N'
                END AS bajperiodo
            INTO v_bajperiodo
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 40;

        EXCEPTION
            WHEN no_data_found THEN
                v_bajperiodo := 'N';
        END;

        -- ESPECIFICACION - MEJORAS    
        BEGIN
            SELECT
                vreal
            INTO v_mejora
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 31;

        EXCEPTION
            WHEN no_data_found THEN
                v_mejora := 0;
        END;

        SELECT
            nvl(SUM(nvl(costot01, 0)), 0)
        INTO v_rec.depperiodo
        FROM
            articulos_depreciacion
        WHERE
                id_cia = pin_id_cia
            AND tipinv = pin_tipinv
            AND codart = pin_codart
            AND periodo = pin_periodo
            AND acumu01 <> 0.0;

        BEGIN
            SELECT
                nvl(MAX(nvl(acumu01, 0)), 0)
            INTO v_rec.dephis_acumulado
            FROM
                articulos_depreciacion
            WHERE
                    id_cia = pin_id_cia
                AND periodo = pin_periodo
                AND tipinv = pin_tipinv
                AND codart = pin_codart;

        EXCEPTION
            WHEN no_data_found THEN
                v_rec.dephis_acumulado := 0;
        END;

        BEGIN
            SELECT
                nvl(MAX(nvl(acumu01, 0)), 0)
            INTO v_rec.depacumulado
            FROM
                articulos_depreciacion
            WHERE
                    id_cia = pin_id_cia
                AND periodo = pin_periodo - 1
                AND tipinv = pin_tipinv
                AND codart = pin_codart;

        EXCEPTION
            WHEN no_data_found THEN
                v_rec.depacumulado := 0;
        END;

        CASE
            WHEN v_fecadq < to_date('01/01/' || pin_periodo, 'DD/MM/YYYY') THEN
                v_rec.actacumulado := v_totact;
                v_rec.actperiodo := 0;
            ELSE
                v_rec.actacumulado := 0;
                v_rec.actperiodo := v_totact;
        END CASE;

        v_rec.actmejora := v_mejora;
        v_rec.actajsute_otros := 0;  -- NO DEFINIDO DELPHI
        v_rec.actajuste_inflacion := 0; -- NO DEFINIDO DELPHI
        IF v_bajperiodo = 'N' THEN
            v_rec.actretiro_bajas := 0;
            v_rec.acthis_acumulado := v_totact + v_mejora + v_rec.actajsute_otros;
            v_rec.actaju_acumulado := v_rec.acthis_acumulado + v_rec.actajuste_inflacion;
        ELSE
            v_rec.actretiro_bajas := v_totact;
            v_rec.acthis_acumulado := 0;
            v_rec.actaju_acumulado := 0;
        END IF;

        v_rec.depajuste_inflacion := 0; -- NO DEFINIDO - DELPHI
        IF v_bajperiodo = 'N' THEN
            v_rec.depretiro_bajas := 0;
            v_rec.depajuste_otros := 0;
            v_rec.depaju_acumulado := v_rec.dephis_acumulado + v_rec.depajuste_inflacion;
        ELSE
            v_rec.depretiro_bajas := v_rec.dephis_acumulado;
            v_rec.depajuste_otros := 0;
            v_rec.depaju_acumulado := 0;
        END IF;

        PIPE ROW ( v_rec );
        RETURN;
    END sp_depreciacion;

    PROCEDURE sp_procesar (
        pin_id_cia  IN NUMBER,
        pin_tipinv  IN NUMBER,
        pin_codart  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        pin_costot01               NUMBER(16, 2);
        pin_costot02               NUMBER(16, 2);
        pin_tipcam                 NUMBER(16, 2);
        pin_valcum01               NUMBER(16, 2);
        pin_valcum02               NUMBER(16, 2);
        pin_fdesde                 DATE;
        pin_fhasta                 DATE;
        pin_meses                  NUMBER;
        pin_tasa                   NUMBER;
        v_codigo                   VARCHAR2(5); /*TIPO DE ACTIVO*/
        pout_mensaje               VARCHAR2(4000 CHAR);
        v_fproceso                 DATE;
        v_saldoacu_pen             NUMBER(16, 2);
        v_daldoacu_usd             NUMBER(16, 2);
        v_mes_depre                SMALLINT := 0;
        v_snacumulado              VARCHAR2(1) := 'N';
        v_depre_pen                NUMBER(16, 2);
        v_depre_usd                NUMBER(16, 2);
        v_locali                   INTEGER;
        v_id                       VARCHAR2(1);
        v_cantid                   NUMBER;
        v_year_acu                 SMALLINT;
        v_month_acu                SMALLINT;
        v_saldo_acum01             NUMBER(16, 2);
        v_saldo_acum02             NUMBER(16, 2);
        v_year_tem                 SMALLINT;
        v_month_tem                SMALLINT;
        v_periodo                  SMALLINT;
        v_mes                      SMALLINT;
        v_meses_restantes          INTEGER;
        v_acumulado_pen            NUMBER(16, 2) := 0;
        v_acumulado_usd            NUMBER(16, 2) := 0;
        rec_articulos_depreciacion articulos_depreciacion%rowtype;
    BEGIN
        BEGIN
            SELECT
                vreal
            INTO pin_costot01
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 2; --VALOR COMPRA SOLES

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 2 - VALOR DE COMPRA SOLES ]';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                vreal
            INTO pin_costot02
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 3; --VALOR DE COMPRA DOLARES

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 3 - VALOR DE COMPRA DOLARES ]';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                vreal
            INTO pin_tipcam
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 4; --TIPO DE CAMBIO

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 4 - TIPO DE CAMBIO ]';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                vdate
            INTO pin_fdesde
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 22; --FECHA INICIO DEPRECIACION

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 22 - FECHA INICIO DEPRECIACION ]';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                nvl(vreal, 0)
            INTO pin_valcum01
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 51; --VALOR SALDO ACUMULADO SOLES

        EXCEPTION
            WHEN no_data_found THEN
                pin_valcum01 := 0;
--                pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 4 - TIPO DE CAMBIO ]';
--                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                nvl(vreal, 0)
            INTO pin_valcum02
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 52; --VALOR SALDO ACUMULADO DOLARES

        EXCEPTION
            WHEN no_data_found THEN
                pin_valcum02 := 0;
--                pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 4 - TIPO DE CAMBIO ]';
--                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                codigo
            INTO v_codigo
            FROM
                articulos_clase
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND clase = 8;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'El ARTICULO asignado no tiene definido la CLASE [ 8 - TIPO DE ACTIVO ]';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        DELETE FROM articulos_depreciacion
        WHERE
                id_cia = pin_id_cia
            AND tipinv = pin_tipinv
            AND codart = pin_codart;

        v_snacumulado := 'N';
        v_year_tem := extract(YEAR FROM pin_fdesde);
        v_month_tem := extract(MONTH FROM pin_fdesde);

        -- SOLO SI TIENE SALDO ACUMULADO
        IF ( pin_valcum01 > 0 OR pin_valcum02 > 0 ) THEN
            v_snacumulado := 'S';
            BEGIN
                SELECT
                    vdate
                INTO pin_fhasta
                FROM
                    articulo_especificacion
                WHERE
                        id_cia = pin_id_cia
                    AND tipinv = pin_tipinv
                    AND codart = pin_codart
                    AND codesp = 50; --FECHA DE SALDO ACUMULADO

            EXCEPTION
                WHEN no_data_found THEN
                    pin_fhasta := current_timestamp;
                    pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 50 - FECHA DE SALDO ACUMULADO ]';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            v_year_acu := extract(YEAR FROM pin_fhasta);
            v_month_acu := extract(MONTH FROM pin_fhasta);
        END IF;

        v_acumulado_pen := 0;
        v_acumulado_usd := 0;
        v_mes_depre := 0;
        IF v_codigo = '2' THEN /* 2 ==>TIPO LEASING*/

            BEGIN
                SELECT
                    ventero
                INTO pin_meses
                FROM
                    articulo_especificacion
                WHERE
                        id_cia = pin_id_cia
                    AND tipinv = pin_tipinv
                    AND codart = pin_codart
                    AND codesp = 19; --MESES A DEPRECIAR

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 19 - MESES A DEPRECIAR ]';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            v_mes_depre := pin_meses;
            v_depre_pen := round(pin_costot01 / v_mes_depre, 2);
            v_depre_usd := round(pin_costot02 / v_mes_depre, 2);
        ELSIF v_codigo = '1' THEN  /* 1 ==>TIPO PROPIO*/
            BEGIN
                SELECT
                    CAST(codigo AS NUMBER)
                INTO pin_tasa
                FROM
                    articulos_clase
                WHERE
                        id_cia = pin_id_cia
                    AND tipinv = pin_tipinv
                    AND codart = pin_codart
                    AND clase = 4; -- TASA DE DEPRECIACION ANUAL

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'El ARTICULO asignado no tiene definido la CLASE [ 4 - TASA DE DEPRECIACION ANUAL ]';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            v_mes_depre := round((100 / pin_tasa) * 12, 0);
        END IF;

        dbms_output.put_line('MESES  : ' || v_mes_depre);
        BEGIN
            SELECT
                MAX(nvl(locali, 0))
            INTO rec_articulos_depreciacion.locali
            FROM
                articulos_depreciacion
            WHERE
                id_cia = pin_id_cia;

        EXCEPTION
            WHEN no_data_found THEN
                rec_articulos_depreciacion.locali := 0;
        END;

        v_fproceso := pin_fdesde;
        FOR i IN 1..v_mes_depre LOOP
            rec_articulos_depreciacion.id_cia := pin_id_cia;
            rec_articulos_depreciacion.locali := rec_articulos_depreciacion.locali + 1;
            rec_articulos_depreciacion.id := 'I';
            rec_articulos_depreciacion.cantid := 0;
            rec_articulos_depreciacion.femisi := current_date;
            rec_articulos_depreciacion.tipinv := pin_tipinv;
            rec_articulos_depreciacion.codart := pin_codart;
            rec_articulos_depreciacion.periodo := extract(YEAR FROM add_months(pin_fdesde, i - 1));

            rec_articulos_depreciacion.mes := extract(MONTH FROM add_months(pin_fdesde, i - 1));

            rec_articulos_depreciacion.codmot := 0;
            IF v_snacumulado = 'S' THEN
                IF ( v_year_acu * 100 + v_month_acu > v_year_tem * 100 + v_month_tem ) THEN
                    rec_articulos_depreciacion.costot01 := 0;
                    rec_articulos_depreciacion.costot02 := 0;
                    rec_articulos_depreciacion.acumu01 := 0;
                    rec_articulos_depreciacion.acumu02 := 0;
                ELSIF ( v_year_acu * 100 + v_month_acu = v_year_tem * 100 + v_month_tem ) THEN
                    v_meses_restantes := v_mes_depre - i;
                    IF i = v_mes_depre THEN
                        rec_articulos_depreciacion.costot01 := round((pin_costot01 - v_acumulado_pen), 2);
                        rec_articulos_depreciacion.costot02 := round((pin_costot02 - v_acumulado_usd), 2);
                        v_acumulado_pen := v_acumulado_pen + rec_articulos_depreciacion.costot01;
                        v_acumulado_usd := v_acumulado_usd + rec_articulos_depreciacion.costot02;
                    ELSIF i = 1 THEN
                        v_acumulado_pen := pin_valcum01;
                        v_acumulado_usd := pin_valcum02;
                        rec_articulos_depreciacion.costot01 := round((pin_costot01 - v_acumulado_pen) / v_meses_restantes, 2);
                        rec_articulos_depreciacion.costot02 := round((pin_costot02 - v_acumulado_usd) / v_meses_restantes, 2);
                        v_acumulado_pen := v_acumulado_pen + rec_articulos_depreciacion.costot01;
                        v_acumulado_usd := v_acumulado_usd + rec_articulos_depreciacion.costot02;
                    ELSE
                        rec_articulos_depreciacion.costot01 := round((pin_costot01 - v_acumulado_pen) / v_meses_restantes, 2);
                        rec_articulos_depreciacion.costot02 := round((pin_costot02 - v_acumulado_usd) / v_meses_restantes, 2);
                        v_acumulado_pen := v_acumulado_pen + rec_articulos_depreciacion.costot01;
                        v_acumulado_usd := v_acumulado_usd + rec_articulos_depreciacion.costot02;
                    END IF;

                    rec_articulos_depreciacion.acumu01 := round(v_acumulado_pen, 2);
                    rec_articulos_depreciacion.acumu02 := round(v_acumulado_usd, 2);
                ELSE
                    IF ( i = v_mes_depre ) THEN
                        rec_articulos_depreciacion.costot01 := round((pin_costot01 - v_acumulado_pen), 2);
                        rec_articulos_depreciacion.costot02 := round((pin_costot02 - v_acumulado_usd), 2);
                    END IF;

                    v_acumulado_pen := v_acumulado_pen + rec_articulos_depreciacion.costot01;
                    v_acumulado_usd := v_acumulado_usd + rec_articulos_depreciacion.costot02;
                    rec_articulos_depreciacion.acumu01 := round(v_acumulado_pen, 2);
                    rec_articulos_depreciacion.acumu02 := round(v_acumulado_usd, 2);
                END IF;
            ELSE
                IF ( i = v_mes_depre ) THEN
                    rec_articulos_depreciacion.costot01 := round((pin_costot01 - v_acumulado_pen), 2);
                    rec_articulos_depreciacion.costot02 := round((pin_costot02 - v_acumulado_usd), 2);
                ELSE
                    IF v_codigo = '1' THEN /* 1 ==>TIPO PROPIO*/
                        rec_articulos_depreciacion.costot01 := round((pin_costot01 * pin_tasa) / 100 / 12, 2);

                        rec_articulos_depreciacion.costot02 := round((pin_costot02 * pin_tasa) / 100 / 12, 2);

                    ELSE
                        rec_articulos_depreciacion.costot01 := round(v_depre_pen, 2);
                        rec_articulos_depreciacion.costot02 := round(v_depre_usd, 2);
                    END IF;
                END IF;

                v_acumulado_pen := v_acumulado_pen + rec_articulos_depreciacion.costot01;
                v_acumulado_usd := v_acumulado_usd + rec_articulos_depreciacion.costot02;
                rec_articulos_depreciacion.acumu01 := round(v_acumulado_pen, 2);
                rec_articulos_depreciacion.acumu02 := round(v_acumulado_usd, 2);
            END IF;

            rec_articulos_depreciacion.tipcam := pin_tipcam;
            rec_articulos_depreciacion.situac := 'A';
            rec_articulos_depreciacion.tipdoc := 0;
            rec_articulos_depreciacion.numint := 0;
            rec_articulos_depreciacion.numite := i;
            rec_articulos_depreciacion.swacti := 'S';
            rec_articulos_depreciacion.mejora01 := 0;
            rec_articulos_depreciacion.mejora02 := 0;
            rec_articulos_depreciacion.usuari := pin_coduser;
            rec_articulos_depreciacion.fcreac := current_timestamp;
            rec_articulos_depreciacion.factua := current_timestamp;
            INSERT INTO articulos_depreciacion (
                id_cia,
                locali,
                id,
                tipdoc,
                numint,
                numite,
                periodo,
                mes,
                codmot,
                femisi,
                tipinv,
                codart,
                situac,
                fcreac,
                factua,
                usuari,
                swacti,
                cantid,
                costot01,
                costot02,
                tipcam,
                acumu01,
                acumu02,
                mejora01,
                mejora02
            ) VALUES (
                rec_articulos_depreciacion.id_cia,
                rec_articulos_depreciacion.locali,
                rec_articulos_depreciacion.id,
                rec_articulos_depreciacion.tipdoc,
                rec_articulos_depreciacion.numint,
                rec_articulos_depreciacion.numite,
                rec_articulos_depreciacion.periodo,
                rec_articulos_depreciacion.mes,
                rec_articulos_depreciacion.codmot,
                rec_articulos_depreciacion.femisi,
                rec_articulos_depreciacion.tipinv,
                rec_articulos_depreciacion.codart,
                rec_articulos_depreciacion.situac,
                rec_articulos_depreciacion.fcreac,
                rec_articulos_depreciacion.factua,
                rec_articulos_depreciacion.usuari,
                rec_articulos_depreciacion.swacti,
                rec_articulos_depreciacion.cantid,
                rec_articulos_depreciacion.costot01,
                rec_articulos_depreciacion.costot02,
                rec_articulos_depreciacion.tipcam,
                rec_articulos_depreciacion.acumu01,
                rec_articulos_depreciacion.acumu02,
                rec_articulos_depreciacion.mejora01,
                rec_articulos_depreciacion.mejora02
            );

        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
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
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_procesar;

    PROCEDURE sp_recalcular (
        pin_id_cia  IN NUMBER,
        pin_tipinv  IN NUMBER,
        pin_codart  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        pin_costot01               NUMBER(16, 2);
        pin_costot02               NUMBER(16, 2);
        pin_tipcam                 NUMBER(16, 2);
        pin_valcum01               NUMBER(16, 2);
        pin_valcum02               NUMBER(16, 2);
        pin_fdesde                 DATE;
        pin_fhasta                 DATE;
        pin_meses                  NUMBER;
        pin_tasa                   NUMBER;
        v_codigo                   VARCHAR2(5); /*TIPO DE ACTIVO*/
        pout_mensaje               VARCHAR2(4000 CHAR);
        v_fproceso                 DATE;
        v_saldoacu_pen             NUMBER(16, 2);
        v_daldoacu_usd             NUMBER(16, 2);
        v_mes_depre                SMALLINT := 0;
        v_snacumulado              VARCHAR2(1) := 'N';
        v_depre_pen                NUMBER(16, 2);
        v_depre_usd                NUMBER(16, 2);
        v_count                    INTEGER;
        v_year_acu                 SMALLINT;
        v_month_acu                SMALLINT;
        v_saldo_acum01             NUMBER(16, 2);
        v_saldo_acum02             NUMBER(16, 2);
        v_year_tem                 SMALLINT;
        v_month_tem                SMALLINT;
        v_acumulado_pen            NUMBER(16, 2) := 0;
        v_acumulado_usd            NUMBER(16, 2) := 0;
        rec_articulos_depreciacion articulos_depreciacion%rowtype;
        rec_aux                    articulos_depreciacion%rowtype;
    BEGIN
        BEGIN
            SELECT
                vreal
            INTO pin_costot01
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 2; --VALOR COMPRA SOLES

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 2 - VALOR DE COMPRA SOLES ]';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                vreal
            INTO pin_costot02
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 3; --VALOR DE COMPRA DOLARES

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 3 - VALOR DE COMPRA DOLARES ]';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                vreal
            INTO pin_tipcam
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 4; --TIPO DE CAMBIO

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 4 - TIPO DE CAMBIO ]';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                vdate
            INTO pin_fdesde
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 22; --FECHA INICIO DEPRECIACION

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 22 - FECHA INICIO DEPRECIACION ]';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                nvl(vreal, 0)
            INTO pin_valcum01
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 51; --VALOR SALDO ACUMULADO SOLES

        EXCEPTION
            WHEN no_data_found THEN
                pin_valcum01 := 0;
--                pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 4 - TIPO DE CAMBIO ]';
--                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                nvl(vreal, 0)
            INTO pin_valcum02
            FROM
                articulo_especificacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codesp = 52; --VALOR SALDO ACUMULADO DOLARES

        EXCEPTION
            WHEN no_data_found THEN
                pin_valcum02 := 0;
--                pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 4 - TIPO DE CAMBIO ]';
--                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                codigo
            INTO v_codigo
            FROM
                articulos_clase
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND clase = 8;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'El ARTICULO asignado no tiene definido la CLASE [ 8 - TIPO DE ACTIVO ]';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        v_snacumulado := 'N';
        v_year_tem := extract(YEAR FROM pin_fdesde);
        v_month_tem := extract(MONTH FROM pin_fdesde);

        -- SOLO SI TIENE SALDO ACUMULADO
        IF ( pin_valcum01 > 0 OR pin_valcum02 > 0 ) THEN
            v_snacumulado := 'S';
            BEGIN
                SELECT
                    vdate
                INTO pin_fhasta
                FROM
                    articulo_especificacion
                WHERE
                        id_cia = pin_id_cia
                    AND tipinv = pin_tipinv
                    AND codart = pin_codart
                    AND codesp = 50; --FECHA DE SALDO ACUMULADO

            EXCEPTION
                WHEN no_data_found THEN
                    pin_fhasta := current_timestamp;
                    pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 50 - FECHA DE SALDO ACUMULADO ]';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            v_year_acu := extract(YEAR FROM pin_fhasta);
            v_month_acu := extract(MONTH FROM pin_fhasta);
        END IF;

        v_acumulado_pen := 0;
        v_acumulado_usd := 0;
        v_mes_depre := 0;
        IF v_codigo = '2' THEN /* 2 ==>TIPO LEASING*/

            BEGIN
                SELECT
                    ventero
                INTO pin_meses
                FROM
                    articulo_especificacion
                WHERE
                        id_cia = pin_id_cia
                    AND tipinv = pin_tipinv
                    AND codart = pin_codart
                    AND codesp = 19; --MESES A DEPRECIAR

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'El ARTICULO asignado no tiene definido la ESPECIFICACION [ 19 - MESES A DEPRECIAR ]';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            v_mes_depre := pin_meses;
            v_depre_pen := round(pin_costot01 / v_mes_depre, 2);
            v_depre_usd := round(pin_costot02 / v_mes_depre, 2);
        ELSIF v_codigo = '1' THEN  /* 1 ==>TIPO PROPIO*/
            BEGIN
                SELECT
                    CAST(codigo AS NUMBER)
                INTO pin_tasa
                FROM
                    articulos_clase
                WHERE
                        id_cia = pin_id_cia
                    AND tipinv = pin_tipinv
                    AND codart = pin_codart
                    AND clase = 4; -- TASA DE DEPRECIACION ANUAL

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'El ARTICULO asignado no tiene definido la CLASE [ 4 - TASA DE DEPRECIACION ANUAL ]';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            v_mes_depre := round((100 / pin_tasa) * 12, 0);
        END IF;

        BEGIN
            SELECT
                nvl(MAX(nvl(numite, 0)), 0)
            INTO v_count
            FROM
                articulos_depreciacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart;

        EXCEPTION
            WHEN no_data_found THEN
                v_count := 0;
        END;

        -- INICIO DEL PROCESO
        FOR i IN (
            SELECT
                *
            FROM
                articulos_depreciacion
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
        ) LOOP
            IF i.numite = 1 THEN
                rec_articulos_depreciacion.costot01 := i.costot01;
                rec_articulos_depreciacion.costot02 := i.costot02;
                rec_articulos_depreciacion.mejora01 := i.mejora01;
                rec_articulos_depreciacion.mejora02 := i.mejora02;
                rec_articulos_depreciacion.acumu01 := pin_valcum01;
                rec_articulos_depreciacion.acumu02 := pin_valcum02;
            END IF;

            IF i.costot01 = 0 OR i.costot02 = 0 THEN
                IF i.numite = v_count THEN
                    rec_articulos_depreciacion.costot01 := pin_costot01 - rec_articulos_depreciacion.acumu01;
                    rec_articulos_depreciacion.costot02 := pin_costot02 - rec_articulos_depreciacion.acumu02;
                    rec_articulos_depreciacion.acumu01 := rec_articulos_depreciacion.acumu01 + rec_articulos_depreciacion.costot01;
                    rec_articulos_depreciacion.acumu02 := rec_articulos_depreciacion.acumu02 + rec_articulos_depreciacion.costot02;
                ELSE
                    rec_articulos_depreciacion.costot01 := 0;
                    rec_articulos_depreciacion.costot02 := 0;
                END IF;

                UPDATE articulos_depreciacion
                SET
                    costot01 = rec_articulos_depreciacion.costot01,
                    costot02 = rec_articulos_depreciacion.costot02,
                    -- ASIGNANDO EL SALDO ANTERIOR*
                    acumu01 = rec_articulos_depreciacion.acumu01,
                    acumu02 = rec_articulos_depreciacion.acumu02,
                    mejora01 = 0,
                    mejora02 = 0
                WHERE
                        id_cia = pin_id_cia
                    AND tipinv = pin_tipinv
                    AND codart = pin_codart
                    AND numite = i.numite;

                rec_articulos_depreciacion.mejora01 := 0;
                rec_articulos_depreciacion.mejora02 := 0;
            ELSE
                IF pin_valcum01 > 0 THEN
--                    IF ( v_year_acu * 100 + v_month_acu = v_year_tem * 100 + v_month_tem ) THEN

                    IF i.numite = v_count THEN
                        rec_articulos_depreciacion.costot01 := pin_costot01 - rec_articulos_depreciacion.acumu01;
                        rec_articulos_depreciacion.costot02 := pin_costot02 - rec_articulos_depreciacion.acumu02;
                    ELSE
                        rec_articulos_depreciacion.costot01 := i.costot01;
                        rec_articulos_depreciacion.costot02 := i.costot02;
                    END IF;
                ELSE
                    IF i.numite = v_count THEN
                        rec_articulos_depreciacion.costot01 := pin_costot01 - rec_articulos_depreciacion.acumu01;
                        rec_articulos_depreciacion.costot02 := pin_costot02 - rec_articulos_depreciacion.acumu02;
                    ELSE
                        rec_articulos_depreciacion.costot01 := i.costot01;
                        rec_articulos_depreciacion.costot02 := i.costot02;
                    END IF;
                END IF;

                rec_articulos_depreciacion.mejora01 := i.mejora01;
                rec_articulos_depreciacion.mejora02 := i.mejora02;
                UPDATE articulos_depreciacion
                SET
                    costot01 = rec_articulos_depreciacion.costot01,
                    costot02 = rec_articulos_depreciacion.costot02,
                    acumu01 = round(rec_articulos_depreciacion.acumu01 + rec_articulos_depreciacion.costot01 + rec_articulos_depreciacion.
                    mejora01, 2),
                    acumu02 = round(rec_articulos_depreciacion.acumu02 + rec_articulos_depreciacion.costot02 + rec_articulos_depreciacion.
                    mejora02, 2)
                WHERE
                        id_cia = pin_id_cia
                    AND tipinv = pin_tipinv
                    AND codart = pin_codart
                    AND numite = i.numite;

            END IF;

            -- ACUMULANDO SALDOS
            rec_articulos_depreciacion.acumu01 := rec_articulos_depreciacion.acumu01 + rec_articulos_depreciacion.costot01;
            rec_articulos_depreciacion.acumu02 := rec_articulos_depreciacion.acumu02 + rec_articulos_depreciacion.costot02;
        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
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
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_recalcular;

END;

/
