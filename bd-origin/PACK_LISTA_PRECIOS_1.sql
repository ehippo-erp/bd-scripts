--------------------------------------------------------
--  DDL for Package Body PACK_LISTA_PRECIOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_LISTA_PRECIOS" AS

    FUNCTION sp_stock_almacen (
        pin_id_cia  NUMBER,
        pin_tipinv  NUMBER,
        pin_codart  VARCHAR2,
        pin_codalms VARCHAR2,
        pin_pdesde  NUMBER,
        pin_phasta  NUMBER
    ) RETURN datatable_stock_almacen
        PIPELINED
    AS

        v_table   datatable_stock_almacen;
        v_periodo NUMBER := floor(pin_pdesde / 100);
        v_mdesde  NUMBER := pin_pdesde - v_periodo * 100;
        v_mhasta  NUMBER := pin_phasta - v_periodo * 100;
    BEGIN
        IF v_mdesde = 0 THEN
            v_mdesde := 1;
        END IF;
        FOR i IN (
            SELECT
                regexp_substr(pin_codalms, '[^,]+', 1, level) AS codalm
            FROM
                dual
            CONNECT BY
                regexp_substr(pin_codalms, '[^,]+', 1, level) IS NOT NULL
        ) LOOP
            SELECT
                i.codalm,
                nvl(stock, 0)
            BULK COLLECT
            INTO v_table
            FROM
                sp000_saca_stock_costo_articulos_almacen(pin_id_cia, pin_tipinv, i.codalm, pin_codart, v_periodo,
                                                         v_mdesde, v_mhasta);

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        END LOOP;

        RETURN;
    END sp_stock_almacen;

    FUNCTION sp_buscar_all (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codpro VARCHAR2,
        pin_codart VARCHAR2,
        pin_desart VARCHAR2,
        pin_codtit NUMBER,
        pin_offset NUMBER,
        pin_limit  NUMBER
    ) RETURN datatable_buscar_all
        PIPELINED
    AS
        v_table datatable_buscar_all;
        x       NUMBER := 1000000;
    BEGIN
        IF
            pin_codtit IS NOT NULL
            AND pin_codtit <> 99999
        THEN
            SELECT
                *
            BULK COLLECT
            INTO v_table
            FROM
                (
                    SELECT
                        l.id_cia,
                        l.vencom,
                        l.codtit,
                        l.codpro,
                        l.tipinv,
                        l.codart,
                        a.descri                 AS desart,
                        l.codmon,
                        m.simbolo,
                        a.coduni                 AS codund,
                        l.precio,
                        l.incigv,
                        l.modpre,
                        l.desc01,
                        l.desc02,
                        l.desc03,
                        l.desc04,
                        l.porigv,
                        l.sku,
                        l.desart                 AS desartcom,
                        l.desmax,
                        l.margen,
                        l.otros,
                        l.flete,
                        l.desmaxmon,
                        l.desinc,
                        l.precionac,
                        CAST('' AS VARCHAR(10))  AS codadd01,
                        CAST('' AS VARCHAR(100)) AS descodadd01,
                        CAST('' AS VARCHAR(10))  AS codadd02,
                        CAST('' AS VARCHAR(100)) AS descodadd02
                    FROM
                             articulos a
                        INNER JOIN listaprecios l ON l.id_cia = a.id_cia
                                                     AND l.codtit = pin_codtit
                                                     AND l.vencom = 1
                                                     AND l.tipinv = a.tipinv
                                                     AND l.codart = a.codart
                        LEFT OUTER JOIN tmoneda      m ON m.id_cia = l.id_cia
                                                     AND m.codmon = l.codmon
                    WHERE
                            a.id_cia = pin_id_cia
                        AND a.tipinv = pin_tipinv
                        AND ( pin_codpro IS NULL
                              OR l.codpro = pin_codpro )
                        AND ( pin_codart IS NULL
                              OR upper(l.codart) LIKE upper(pin_codart) )
                        AND ( pin_desart IS NULL
                              OR upper(a.descri) LIKE upper(pin_desart) )
                    UNION ALL
                    SELECT
                        l.id_cia,
                        l.vencom,
                        l.codtit,
                        l.codpro,
                        l.tipinv,
                        l.codart,
                        a.descri    AS desart,
                        l.codmon,
                        m.simbolo,
                        a.coduni    AS codund,
                        l.precio,
                        l.incigv,
                        l.modpre,
                        l.desc01,
                        l.desc02,
                        l.desc03,
                        l.desc04,
                        l.porigv,
                        l.sku,
                        l.desart    AS desartcom,
                        l.desmax,
                        l.margen,
                        l.otros,
                        l.flete,
                        l.desmaxmon,
                        l.desinc,
                        l.precionac,
                        l.codadd01  AS codadd01,
                        cac1.descri AS descodadd01,
                        l.codadd02  AS codadd02,
                        cac2.descri AS descodadd02
                    FROM
                             articulos a
                        INNER JOIN listaprecios_alternativa l ON l.id_cia = a.id_cia
                                                                 AND l.codtit = pin_codtit
                                                                 AND l.vencom = 1
                                                                 AND l.precio <> 0
                                                                 AND l.tipinv = a.tipinv
                                                                 AND l.codart = a.codart
                        LEFT OUTER JOIN cliente_articulos_clase  cac1 ON cac1.id_cia = a.id_cia
                                                                        AND cac1.tipcli = 'B'
                                                                        AND cac1.codcli = a.codprv
                                                                        AND cac1.clase = 1
                                                                        AND cac1.codigo = l.codadd01
                        LEFT OUTER JOIN cliente_articulos_clase  cac2 ON cac2.id_cia = a.id_cia
                                                                        AND cac2.tipcli = 'B'
                                                                        AND cac2.codcli = a.codprv
                                                                        AND cac2.clase = 2
                                                                        AND cac2.codigo = l.codadd02
                        LEFT OUTER JOIN tmoneda                  m ON m.id_cia = l.id_cia
                                                     AND m.codmon = l.codmon
                    WHERE
                            a.id_cia = pin_id_cia
                        AND a.tipinv = pin_tipinv
                        AND ( pin_codpro IS NULL
                              OR l.codpro = pin_codpro )
                        AND ( pin_codart IS NULL
                              OR upper(l.codart) LIKE upper(pin_codart) )
                        AND ( pin_desart IS NULL
                              OR upper(a.descri) LIKE upper(pin_desart) )
                    ORDER BY
                        4,
                        16,
                        18
                    OFFSET
                        CASE
                            WHEN pin_offset IS NULL THEN
                                0
                            ELSE
                                pin_offset
                        END
                    ROWS FETCH NEXT
                        CASE
                            WHEN pin_limit IS NULL THEN
                                x
                            ELSE
                                pin_limit
                        END
                    ROWS ONLY
                );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        ELSIF pin_codtit = 99999 THEN
            SELECT
                *
            BULK COLLECT
            INTO v_table
            FROM
                (
                    SELECT
                        l.id_cia,
                        l.vencom,
                        l.codtit,
                        l.codpro,
                        l.tipinv,
                        l.codart,
                        a.descri                 AS desart,
                        l.codmon,
                        m.simbolo,
                        a.coduni                 AS codund,
                        l.precio,
                        l.incigv,
                        l.modpre,
                        l.desc01,
                        l.desc02,
                        l.desc03,
                        l.desc04,
                        l.porigv,
                        l.sku,
                        l.desart                 AS desartcom,
                        l.desmax,
                        l.margen,
                        l.otros,
                        l.flete,
                        l.desmaxmon,
                        l.desinc,
                        l.precionac,
                        CAST('' AS VARCHAR(10))  AS codadd01,
                        CAST('' AS VARCHAR(100)) AS descodadd01,
                        CAST('' AS VARCHAR(10))  AS codadd02,
                        CAST('' AS VARCHAR(100)) AS descodadd02
                    FROM
                             articulos a
                        INNER JOIN listaprecios l ON l.id_cia = a.id_cia
                                                     AND l.codtit = pin_codtit
                                                     AND l.vencom = 2
                                                     AND l.tipinv = a.tipinv
                                                     AND l.codart = a.codart
                        LEFT OUTER JOIN tmoneda      m ON m.id_cia = l.id_cia
                                                     AND m.codmon = l.codmon
                    WHERE
                            a.id_cia = pin_id_cia
                        AND a.tipinv = pin_tipinv
                        AND ( pin_codpro IS NULL
                              OR l.codpro = pin_codpro )
                        AND ( pin_codart IS NULL
                              OR upper(l.codart) LIKE upper(pin_codart) )
                        AND ( pin_desart IS NULL
                              OR upper(a.descri) LIKE upper(pin_desart) )
                    UNION ALL
                    SELECT
                        l.id_cia,
                        l.vencom,
                        l.codtit,
                        l.codpro,
                        l.tipinv,
                        l.codart,
                        a.descri    AS desart,
                        l.codmon,
                        m.simbolo,
                        a.coduni    AS codund,
                        l.precio,
                        l.incigv,
                        l.modpre,
                        l.desc01,
                        l.desc02,
                        l.desc03,
                        l.desc04,
                        l.porigv,
                        l.sku,
                        l.desart    AS desartcom,
                        l.desmax,
                        l.margen,
                        l.otros,
                        l.flete,
                        l.desmaxmon,
                        l.desinc,
                        l.precionac,
                        l.codadd01  AS codadd01,
                        cac1.descri AS descodadd01,
                        l.codadd02  AS codadd02,
                        cac2.descri AS descodadd02
                    FROM
                             articulos a
                        INNER JOIN listaprecios_alternativa l ON l.id_cia = a.id_cia
                                                                 AND l.codtit = pin_codtit
                                                                 AND l.vencom = 2
                                                                 AND l.precio <> 0
                                                                 AND l.tipinv = a.tipinv
                                                                 AND l.codart = a.codart
                        LEFT OUTER JOIN cliente_articulos_clase  cac1 ON cac1.id_cia = a.id_cia
                                                                        AND cac1.tipcli = 'B'
                                                                        AND cac1.codcli = a.codprv
                                                                        AND cac1.clase = 1
                                                                        AND cac1.codigo = l.codadd01
                        LEFT OUTER JOIN cliente_articulos_clase  cac2 ON cac2.id_cia = a.id_cia
                                                                        AND cac2.tipcli = 'B'
                                                                        AND cac2.codcli = a.codprv
                                                                        AND cac2.clase = 2
                                                                        AND cac2.codigo = l.codadd02
                        LEFT OUTER JOIN tmoneda                  m ON m.id_cia = l.id_cia
                                                     AND m.codmon = l.codmon
                    WHERE
                            a.id_cia = pin_id_cia
                        AND a.tipinv = pin_tipinv
                        AND ( pin_codpro IS NULL
                              OR l.codpro = pin_codpro )
                        AND ( pin_codart IS NULL
                              OR upper(l.codart) LIKE upper(pin_codart) )
                        AND ( pin_desart IS NULL
                              OR upper(a.descri) LIKE upper(pin_desart) )
                    ORDER BY
                        4,
                        16,
                        18
                    OFFSET
                        CASE
                            WHEN pin_offset IS NULL THEN
                                0
                            ELSE
                                pin_offset
                        END
                    ROWS FETCH NEXT
                        CASE
                            WHEN pin_limit IS NULL THEN
                                x
                            ELSE
                                pin_limit
                        END
                    ROWS ONLY
                );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        END IF;
    END sp_buscar_all;

--    FUNCTION sp_buscar (
--        pin_id_cia NUMBER,
--        pin_tipinv NUMBER,
--        pin_codart VARCHAR2,
--        pin_desart VARCHAR2,
--        pin_codtit NUMBER,
--        pin_offset NUMBER,
--        pin_limit  NUMBER
--    ) RETURN datatable_buscar
--        PIPELINED
--    AS
--        v_table datatable_buscar;
--        x       NUMBER := 1000000;
--    BEGIN
--        SELECT
--            *
--        BULK COLLECT
--        INTO v_table
--        FROM
--            (
--                SELECT
--                    a.id_cia,
--                    l.codtit,
--                    l.tipinv,
--                    l.codart,
--                    a.descri                 AS desart,
--                    l.codmon,
--                    m.simbolo,
--                    l.precio,
--                    CASE
--                        WHEN l.incigv = 'S' THEN
--                            'true'
--                        ELSE
--                            'false'
--                    END                      incigv,
--                    l.desc01,
--                    l.desc02,
--                    l.desc03,
--                    l.desc04,
--                    l.porigv,
--                    l.sku,
--                    CAST('' AS VARCHAR(10))  AS codadd01,
--                    CAST('' AS VARCHAR(100)) AS descodadd01,
--                    CAST('' AS VARCHAR(10))  AS codadd02,
--                    CAST('' AS VARCHAR(100)) AS descodadd02
--                FROM
--                         articulos a
--                    INNER JOIN listaprecios l ON l.id_cia = a.id_cia
--                                                 AND l.codtit = pin_codtit
--                                                 AND l.vencom = 1
--                                                 AND l.precio <> 0
--                                                 AND l.tipinv = a.tipinv
--                                                 AND l.codart = a.codart
--                    LEFT OUTER JOIN tmoneda      m ON m.id_cia = a.id_cia
--                                                 AND m.codmon = l.codmon
--                WHERE
--                        a.id_cia = pin_id_cia
--                    AND a.tipinv = pin_tipinv
--                    AND ( pin_codart IS NULL
--                          OR l.codart = pin_codart )
--                    AND ( pin_desart IS NULL
--                          OR instr(upper(a.descri), upper(pin_desart)) > 0 )
--                UNION ALL
--                SELECT
--                    a.id_cia,
--                    l.codtit,
--                    l.tipinv,
--                    l.codart,
--                    a.descri    AS desart,
--                    l.codmon,
--                    m.simbolo,
--                    l.precio,
--                    CASE
--                        WHEN l.incigv = 'S' THEN
--                            'true'
--                        ELSE
--                            'false'
--                    END         incigv,
--                    l.desc01,
--                    l.desc02,
--                    l.desc03,
--                    l.desc04,
--                    l.porigv,
--                    l.sku,
--                    l.codadd01  AS codadd01,
--                    cac1.descri AS descodadd01,
--                    l.codadd02  AS codadd02,
--                    cac2.descri AS descodadd02
--                FROM
--                         articulos a
--                    INNER JOIN listaprecios_alternativa l ON l.id_cia = a.id_cia
--                                                             AND l.codtit = pin_codtit
--                                                             AND l.vencom = 1
--                                                             AND l.precio <> 0
--                                                             AND l.tipinv = a.tipinv
--                                                             AND l.codart = a.codart
--                    LEFT OUTER JOIN cliente_articulos_clase  cac1 ON cac1.id_cia = a.id_cia
--                                                                    AND cac1.tipcli = 'B'
--                                                                    AND cac1.codcli = a.codprv
--                                                                    AND cac1.clase = 1
--                                                                    AND cac1.codigo = l.codadd01
--                    LEFT OUTER JOIN cliente_articulos_clase  cac2 ON cac2.id_cia = a.id_cia
--                                                                    AND cac2.tipcli = 'B'
--                                                                    AND cac2.codcli = a.codprv
--                                                                    AND cac2.clase = 2
--                                                                    AND cac2.codigo = l.codadd02
--                    LEFT OUTER JOIN tmoneda                  m ON m.id_cia = a.id_cia
--                                                 AND m.codmon = l.codmon
--                WHERE
--                        a.id_cia = pin_id_cia
--                    AND a.tipinv = pin_tipinv
--                    AND ( pin_codart IS NULL
--                          OR l.codart = pin_codart )
--                    AND ( pin_desart IS NULL
--                          OR instr(upper(a.descri), upper(pin_desart)) > 0 )
--                ORDER BY
--                    4,
--                    16,
--                    18
--                OFFSET
--                    CASE
--                        WHEN pin_offset = - 1 THEN
--                            0
--                        ELSE
--                            pin_offset
--                    END
--                ROWS FETCH NEXT
--                    CASE
--                        WHEN pin_limit = - 1 THEN
--                            x
--                        ELSE
--                            pin_limit
--                    END
--                ROWS ONLY
--            );
--
--    END sp_buscar;

    FUNCTION sp_buscar_stock (
        pin_id_cia  NUMBER,
        pin_pdesde  NUMBER,
        pin_phasta  NUMBER,
        pin_codtit  NUMBER,
        pin_tipinv  NUMBER,
        pin_codalm  NUMBER,
        pin_clase01 NUMBER,
        pin_clase02 NUMBER,
        pin_porcol  VARCHAR2
    ) RETURN datatable_buscar_stock
        PIPELINED
    AS
        v_table  datatable_buscar_stock;
        v_rec    datarecord_buscar_stock;
        v_codalm VARCHAR2(1000) := '';
    BEGIN
--        IF
--            pin_codalm = -1
--            AND pin_porcol = 'S'
--        THEN
--            FOR i IN (
--                SELECT
--                    CAST(codalm AS VARCHAR(3))
--                FROM
--                    almacen
--                WHERE
--                        id_cia = pin_id_cia AND 
--                        tipinv = pin_tipinv
--                    AND swacti IN ( 'S', 'A' )
--                    AND NOT codalm IN ( 98, 99 )
--            ) LOOP
--                v_codalm := v_codalm
--                            || i.codalm
--                            || ',';
--            END LOOP;
--
--            v_codalm := substr(v_codalm, 1, strlen(v_codalm) - 1);
--        ELSIF
--            pin_codalm <> -1
--            AND pin_porcol = 'S'
--        THEN
--            v_codalm := '';
--            FOR e IN (
--                SELECT
--                    CAST(codalm AS VARCHAR(3))
--                FROM
--                    almacen
--                WHERE
--                        id_cia = pin_id_cia AND 
--                        tipinv = pin_tipinv
--                    AND swacti IN ( 'S', 'A' )
--                    AND ( codalm IN (
--                        SELECT
--                            campo
--                        FROM
--                            sp000_comas_en_filas ( :ucodalm )
--                    ) )
--                    AND NOT codalm IN ( 98, 99 )
--            ) LOOP
--                v_codalm := :v_codalm
--                            || e.codalm
--                            || ',';
--            END LOOP;
--
--            v_codalm := substr2(:v_codalm, 1, strlen(:v_codalm) - 1);
--
--        END IF;

        IF
            pin_clase01 = 0
            AND pin_clase02 = 0
        THEN
            SELECT
                a.id_cia,
                l.codtit,
                tl.titulo,
                a.tipinv,
                ti.dtipinv,
                l.codart,
                a.descri,
                a.codprv,
                l.codmon,
                m.simbolo,
                nvl(l.precio, 0) AS precio,
                l.desc01,
                l.desc02,
                l.desc03,
                l.desc04,
                l.modpre,
                l.incigv,
                l.porigv,
                0,
                NULL,
                NULL,
                NULL,
                0,
                NULL,
                NULL,
                NULL,
                l.sku,
                SUM(
                    CASE
                        WHEN al.codalm NOT IN(98, 99) THEN
                            nvl(al.ingreso, 0) - nvl(al.salida, 0)
                        ELSE
                            0
                    END
                )                AS stock,
                NULL             AS stock98,
--                SUM(
--                    CASE
--                        WHEN al.codalm IN(98) THEN
--                            nvl(al.ingreso, 0) - nvl(al.salida, 0)
--                        ELSE
--                            0
--                    END
--                )                AS stock98,
                a.wglosa,
                u.coduni,
                u.desuni,
                NULL,
                NULL
            BULK COLLECT
            INTO v_table
            FROM
                listaprecios      l
                LEFT OUTER JOIN titulolista       tl ON tl.id_cia = l.id_cia
                                                  AND tl.codtit = l.codtit
                LEFT OUTER JOIN t_inventario      ti ON ti.id_cia = l.id_cia
                                                   AND ti.tipinv = l.tipinv
                LEFT OUTER JOIN articulos         a ON a.id_cia = l.id_cia
                                               AND a.tipinv = l.tipinv
                                               AND a.codart = l.codart
                LEFT OUTER JOIN unidad            u ON u.id_cia = l.id_cia
                                            AND u.coduni = a.coduni
                LEFT OUTER JOIN tmoneda           m ON m.id_cia = l.id_cia
                                             AND m.codmon = l.codmon
                LEFT OUTER JOIN articulos_almacen al ON al.id_cia = l.id_cia
                                                        AND al.tipinv = l.tipinv
                                                        AND al.codart = l.codart
                                                        AND al.codalm = pin_codalm
                                                        AND al.periodo BETWEEN pin_pdesde AND pin_phasta
            WHERE
                    l.id_cia = pin_id_cia
                AND l.codtit = pin_codtit
                AND l.tipinv = pin_tipinv
            GROUP BY
                a.id_cia,
                l.codtit,
                tl.titulo,
                a.tipinv,
                ti.dtipinv,
                l.codart,
                a.descri,
                a.codprv,
                l.codmon,
                m.simbolo,
                nvl(l.precio, 0),
                l.desc01,
                l.desc02,
                l.desc03,
                l.desc04,
                l.modpre,
                l.incigv,
                l.porigv,
                0,
                NULL,
                NULL,
                NULL,
                0,
                NULL,
                NULL,
                NULL,
                l.sku,
                a.wglosa,
                u.coduni,
                u.desuni,
                NULL,
                NULL;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSE
            SELECT
                ti.id_cia,
                l.codtit,
                tl.titulo,
                a.tipinv,
                ti.dtipinv,
                l.codart,
                a.descri,
                a.codprv,
                l.codmon,
                m.simbolo,
                nvl(l.precio, 0) AS precio,
                l.desc01,
                l.desc02,
                l.desc03,
                l.desc04,
                l.modpre,
                l.incigv,
                l.porigv,
                ac01.clase       AS clase01,
                ac01.desclase    AS desclase01,
                ac01.codigo      AS codigo01,
                ac01.descodigo   AS descodigo01,
                ac02.clase       AS clase02,
                ac02.desclase    AS desclase02,
                ac02.codigo      AS codigo02,
                ac02.descodigo   AS descodigo02,
                l.sku,
                SUM(
                    CASE
                        WHEN al.codalm NOT IN(98, 99) THEN
                            nvl(al.ingreso, 0) - nvl(al.salida, 0)
                        ELSE
                            0
                    END
                )                AS stock,
                NULL             AS stock98,
--                SUM(
--                    CASE
--                        WHEN al.codalm IN(98) THEN
--                            nvl(al.ingreso, 0) - nvl(al.salida, 0)
--                        ELSE
--                            0
--                    END
--                )                AS stock98,
                a.wglosa,
                u.coduni,
                u.desuni,
                NULL,
                NULL
            BULK COLLECT
            INTO v_table
            FROM
                listaprecios                                                                     l
                LEFT OUTER JOIN titulolista                                                                      tl ON tl.id_cia = l.id_cia
                                                  AND tl.codtit = l.codtit
                LEFT OUTER JOIN t_inventario                                                                     ti ON ti.id_cia = l.id_cia
                                                   AND ti.tipinv = l.tipinv
                LEFT OUTER JOIN articulos                                                                        a ON a.id_cia = l.id_cia
                                               AND a.tipinv = l.tipinv
                                               AND a.codart = l.codart
                LEFT OUTER JOIN unidad                                                                           u ON u.id_cia = a.id_cia
                                            AND u.coduni = a.coduni
                LEFT OUTER JOIN tmoneda                                                                          m ON m.id_cia = l.id_cia
                                             AND m.codmon = l.codmon
                LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, pin_clase01) ac01 ON 0 = 0
                LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, pin_clase02) ac02 ON 0 = 0
                LEFT OUTER JOIN articulos_almacen                                                                al ON al.id_cia = l.id_cia
                                                        AND al.tipinv = l.tipinv
                                                        AND al.codart = l.codart
                                                        AND al.codalm = pin_codalm
                                                        AND al.periodo BETWEEN pin_pdesde AND pin_phasta
            WHERE
                    l.id_cia = pin_id_cia
                AND l.codtit = pin_codtit
                AND l.tipinv = pin_tipinv
            GROUP BY
                ti.id_cia,
                l.codtit,
                tl.titulo,
                a.tipinv,
                ti.dtipinv,
                l.codart,
                a.descri,
                a.codprv,
                l.codmon,
                m.simbolo,
                nvl(l.precio, 0),
                l.desc01,
                l.desc02,
                l.desc03,
                l.desc04,
                l.modpre,
                l.incigv,
                l.porigv,
                ac01.clase,
                ac01.desclase,
                ac01.codigo,
                ac01.descodigo,
                ac02.clase,
                ac02.desclase,
                ac02.codigo,
                ac02.descodigo,
                l.sku,
                a.wglosa,
                u.coduni,
                u.desuni,
                NULL,
                NULL;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        END IF;
    END sp_buscar_stock;

    FUNCTION sp_exportar (
        pin_id_cia   NUMBER,
        pin_tipinv   NUMBER,
        pin_codprv   VARCHAR2,
        pin_codigo01 VARCHAR2,
        pin_codigo02 VARCHAR2
    ) RETURN datatable_exportar
        PIPELINED
    AS
        v_table  datatable_exportar;
        v_pdesde NUMBER;
        v_phasta NUMBER;
    BEGIN
        v_pdesde := extract(YEAR FROM current_date) * 100;
        v_phasta := extract(YEAR FROM current_date) * 100 + extract(MONTH FROM current_date);

        SELECT
            lp.codtit                           AS "C.Lista",
            lp.titulo                           AS "Lista",
            lp.tipinv                           AS "C.T.Inventario",
            lp.dtipinv                          AS "T.Inventario",
            lp.codart                           AS "Código",
            lp.desart                           AS "Descripción",
            ac01.codigo                         AS "C.Procedencia",
            ac01.descodigo                      AS "Procedencia",
            lp.codigo01                         AS "C.Familia",
            lp.descodigo01                      AS "Familia",
            lp.codigo02                         AS "C.Linea",
            lp.descodigo02                      AS "Línea",
            ac04.codigo                         AS "C.Marca",
            ac04.descodigo                      AS "Marca",
            ac97.codigo                         AS "C.Empaque",
            ac97.descodigo                      AS "Empaque",
            lp.coduni                           AS "U.Medida",
            lp.codmon                           AS "Moneda",
            lp.precio                           AS "Precio",
            lp.stock                            AS "Stock",
            al.codalm                           AS "C.Almacen",
            al.descri                           AS "Almacen",
            lp.codprv                           AS "C.Proveedor",
            c.razonc                            AS "Proveedor",
            to_char(current_date, 'DD/MM/YYYY') AS "Femisi"
        BULK COLLECT
        INTO v_table
        FROM
            pack_lista_precios.sp_buscar_stock(pin_id_cia, v_pdesde, v_phasta, 1, pin_tipinv,
                                               1, 2, 3, 'N')                           lp
            LEFT OUTER JOIN almacen                                                                    al ON al.id_cia = lp.id_cia
                                          AND al.tipinv = lp.tipinv
                                          AND al.codalm = 1
            LEFT OUTER JOIN cliente                                                                    c ON c.id_cia = lp.id_cia
                                         AND c.codcli = lp.codprv
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(lp.id_cia, lp.tipinv, lp.codart, 1)  ac01 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(lp.id_cia, lp.tipinv, lp.codart, 4)  ac04 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(lp.id_cia, lp.tipinv, lp.codart, 97) ac97 ON 0 = 0
        WHERE
                lp.id_cia = pin_id_cia
            AND lp.tipinv = pin_tipinv
            AND ( pin_codprv IS NULL
                  OR pin_codprv = '-1'
                  OR lp.codprv = pin_codprv )
            AND ( pin_codigo01 IS NULL
                  OR pin_codigo01 = '-1'
                  OR lp.codigo01 = pin_codigo01 )
            AND ( pin_codigo02 IS NULL
                  OR pin_codigo02 = '-1'
                  OR lp.codigo02 = pin_codigo02 );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_exportar;

    FUNCTION sp_asigna (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_vencom NUMBER,
        pin_codtit NUMBER,
        pin_codprv VARCHAR2,
        pin_clase  NUMBER
    ) RETURN datatable_asigna_nuevo
        PIPELINED
    AS
        v_table datatable_asigna_nuevo;
    BEGIN
        IF pin_vencom = 1 THEN
            SELECT
                a.id_cia,
                pin_vencom AS vencom,
                pin_codtit AS codtit,
                pin_codprv AS codprv,
                tl.codmon,
                tl.incigv,
                f.vreal    AS porigv,
                tl.modpre,
                a.tipinv,
                a.codart,
                a.descri   AS desart,
                a.coduni,
                acc.clase,
                acc.desclase,
                acc.codigo,
                acc.descodigo
            BULK COLLECT
            INTO v_table
            FROM
                articulos                                                                      a
                LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, pin_clase) acc ON 0 = 0
                INNER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 9)         acc9 ON 0 = 0
                INNER JOIN titulolista                                                                    tl ON tl.id_cia = pin_id_cia
                                             AND tl.codtit = pin_codtit
                INNER JOIN factor                                                                         f ON f.id_cia = pin_id_cia
                                       AND f.codfac = 1
            WHERE
                    a.id_cia = pin_id_cia
                AND a.tipinv = pin_tipinv
                AND acc9.codigo = '1' -- SOLO ARTICULOS ACTIVOS
                AND ( nvl(pin_codprv, '-1') = '-1'
                      OR a.codprv = pin_codprv )
                AND NOT EXISTS (
                    SELECT
                        l.codart
                    FROM
                        listaprecios l
                    WHERE
                            l.id_cia = a.id_cia
                        AND l.vencom = pin_vencom
                        AND l.codtit = pin_codtit
                        AND l.codpro = '00000000001'
                        AND l.tipinv = a.tipinv
                        AND l.codart = a.codart
                );

        ELSE
            SELECT
                a.id_cia,
                pin_vencom AS vencom,
                pin_codtit AS codtit,
                pin_codprv AS codprv,
                tl.codmon,
                tl.incigv,
                f.vreal    AS porigv,
                tl.modpre,
                a.tipinv,
                a.codart,
                a.descri   AS desart,
                a.coduni,
                acc.clase,
                acc.desclase,
                acc.codigo,
                acc.descodigo
            BULK COLLECT
            INTO v_table
            FROM
                articulos                                                                      a
                LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, pin_clase) acc ON 0 = 0
                INNER JOIN titulolista                                                                    tl ON tl.id_cia = pin_id_cia
                                             AND tl.codtit = pin_codtit
                INNER JOIN factor                                                                         f ON f.id_cia = pin_id_cia
                                       AND f.codfac = 1
            WHERE
                    a.id_cia = pin_id_cia
                AND a.tipinv = pin_tipinv
                AND a.codprv = pin_codprv
                AND NOT EXISTS (
                    SELECT
                        l.codart
                    FROM
                        listaprecios l
                    WHERE
                            l.id_cia = a.id_cia
                        AND l.vencom = pin_vencom
                        AND l.codtit = pin_codtit
                        AND l.codpro = a.codprv
                        AND l.tipinv = a.tipinv
                        AND l.codart = a.codart
                );

        END IF;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_asigna;

    FUNCTION sp_nueva_lista (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_vencom NUMBER,
        pin_codtit NUMBER,
        pin_codprv VARCHAR2,
        pin_clase  NUMBER
    ) RETURN datatable_nueva_lista
        PIPELINED
    AS
        v_table datatable_nueva_lista;
    BEGIN
--        IF pin_vencom = 1 THEN
--            SELECT
--                l.codart,
--                a.descri AS desart,
--                a.coduni,
--                l.codmon,
--                l.precio,
--                l.desc01,
--                l.desc02,
--                l.desc03,
--                l.desc04,
--                l.desinc,
--                pack_lista_precios.sp_calcula(l.precio, l.desc01, l.desc02, l.desc03, l.desc04),
--                l.modpre,
--                l.incigv,
--                l.porigv,
--                l.desmax,
--                l.desmaxmon,
--                l.sku,
--                l.margen,
--                l.otros,
--                l.flete,
--                l.factua,
--                l.vencom,
--                l.codtit,
--                l.codpro,
--                l.tipinv,
--                l.desart AS descom,
--                'N'
--            BULK COLLECT
--            INTO v_table
--            FROM
--                listaprecios l
--                LEFT OUTER JOIN articulos    a ON a.id_cia = l.id_cia
--                                               AND a.tipinv = l.tipinv
--                                               AND a.codart = l.codart
--            WHERE
--                    l.id_cia = pin_id_cia
--                AND l.vencom = pin_vencom
--                AND l.codtit = pin_codtit
--                AND l.codpro = '00000000001'
--                AND l.tipinv = pin_tipinv;
--
--        ELSE
--            SELECT
--                l.codart,
--                a.descri AS desart,
--                a.coduni,
--                l.codmon,
--                l.precio,
--                l.desc01,
--                l.desc02,
--                l.desc03,
--                l.desc04,
--                l.desinc,
--                pack_lista_precios.sp_calcula(l.precio, l.desc01, l.desc02, l.desc03, l.desc04),
--                l.modpre,
--                l.incigv,
--                l.porigv,
--                l.desmax,
--                l.desmaxmon,
--                l.sku,
--                l.margen,
--                l.otros,
--                l.flete,
--                l.factua,
--                l.vencom,
--                l.codtit,
--                l.codpro,
--                l.tipinv,
--                l.desart AS descom,
--                'N'
--            BULK COLLECT
--            INTO v_table
--            FROM
--                listaprecios l
--                LEFT OUTER JOIN articulos    a ON a.id_cia = l.id_cia
--                                               AND a.tipinv = l.tipinv
--                                               AND a.codart = l.codart
--            WHERE
--                    l.id_cia = pin_id_cia
--                AND l.vencom = pin_vencom
--                AND l.codtit = pin_codtit
--                AND l.codpro = pin_codprv
--                AND l.tipinv = pin_tipinv;
--
--        END IF;
--
--        FOR registro IN 1..v_table.count LOOP
--            PIPE ROW ( v_table(registro) );
--        END LOOP;

        SELECT
            l.codart AS "ID",
            l.desart AS "Articulo",
            l.codund AS "Unidad",
            l.codmon AS "Moneda",
            0.0      AS "Precio",
            0.0      AS "Dsct0 1",
            0.0      AS "Dsct0 2",
            0.0      AS "Dsct0 3",
            0.0      AS "Dsct0 4",
            0.0      AS "Desc./Incre",
            0.0      AS "Tot. Neto",
            l.modpre AS "Md. Precio",
            l.incigv AS "I.G.V",
            l.porigv AS "% I.G.V",
            NULL     AS "% Desc. Max",
            NULL     AS "Desc. Max",
            NULL     AS "SKU",
            0.0      AS "Utilidad %",
            0.0      AS "Otros %",
            0        AS "Flete %",
            NULL     AS "Actualizado",
            l.vencom AS "VENCOM",
            l.codtit AS "CODTIT",
            CASE
                WHEN pin_vencom = 1 THEN
                    '00000000001'
                ELSE
                    l.codprv
            END      AS "CODPRO",
            l.tipinv AS "TIPINV",
            NULL     AS "Descripción comercial"
        BULK COLLECT
        INTO v_table
        FROM
            pack_lista_precios.sp_asigna(pin_id_cia, pin_tipinv, pin_vencom, pin_codtit, pin_codprv,
                                         pin_clase) l;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_nueva_lista;

    FUNCTION sp_calcula (
        pin_preuni  NUMBER,
        pin_pordes1 NUMBER,
        pin_pordes2 NUMBER,
        pin_pordes3 NUMBER,
        pin_pordes4 NUMBER
    ) RETURN NUMBER AS
        v_precio NUMBER := 0;
    BEGIN
        IF pin_preuni > 0 THEN
            v_precio := pin_preuni;
            v_precio := v_precio * ( ( 100 - pin_pordes1 ) / 100 );
            v_precio := v_precio * ( ( 100 - pin_pordes2 ) / 100 );
            v_precio := v_precio * ( ( 100 - pin_pordes3 ) / 100 );
            v_precio := v_precio * ( ( 100 - pin_pordes4 ) / 100 );
        END IF;

        RETURN v_precio;
    END sp_calcula;

END;

/
