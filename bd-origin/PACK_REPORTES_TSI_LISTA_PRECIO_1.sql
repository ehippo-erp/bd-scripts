--------------------------------------------------------
--  DDL for Package Body PACK_REPORTES_TSI_LISTA_PRECIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_REPORTES_TSI_LISTA_PRECIO" AS

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

    FUNCTION sp_buscar (
        pin_id_cia NUMBER
    ) RETURN datatable_buscar
        PIPELINED
    AS

        v_table   datatable_buscar;
        v_periodo NUMBER := extract(YEAR FROM current_timestamp);
        v_mes     NUMBER := extract(MONTH FROM current_timestamp);
        v_pdesde  NUMBER := v_periodo * 100;
        v_phasta  NUMBER := ( v_periodo * 100 ) + v_mes;
    BEGIN
        SELECT
            p.tipinv,
            p.dtipinv,
            p.codart,
            p.desart,
            a.descri2,
            p.simbolo,
            pack_reportes_tsi_lista_precio.sp_calcula(p.precio, p.desc01, p.desc02, p.desc03, p.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l2.precio, l2.desc01, l2.desc02, l2.desc03, l2.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l3.precio, l3.desc01, l3.desc02, l3.desc03, l3.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l4.precio, l4.desc01, l4.desc02, l4.desc03, l4.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l5.precio, l5.desc01, l5.desc02, l5.desc03, l5.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l6.precio, l6.desc01, l6.desc02, l6.desc03, l6.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l7.precio, l7.desc01, l7.desc02, l7.desc03, l7.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l8.precio, l8.desc01, l8.desc02, l8.desc03, l8.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l9.precio, l9.desc01, l9.desc02, l9.desc03, l9.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l10.precio, l10.desc01, l10.desc02, l10.desc03, l10.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l11.precio, l11.desc01, l11.desc02, l11.desc03, l11.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l12.precio, l12.desc01, l12.desc02, l12.desc03, l12.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l13.precio, l13.desc01, l13.desc02, l13.desc03, l13.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l14.precio, l14.desc01, l14.desc02, l14.desc03, l14.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l15.precio, l15.desc01, l15.desc02, l15.desc03, l15.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l16.precio, l16.desc01, l16.desc02, l16.desc03, l16.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l18.precio, l18.desc01, l18.desc02, l18.desc03, l18.desc04),
            pack_reportes_tsi_lista_precio.sp_calcula(l19.precio, l19.desc01, l19.desc02, l19.desc03, l19.desc04),
            p.descodigo01,
            p.descodigo02,
            c4.descodigo,
            p.glosa,
            p.desuni,
--            sk.col01     AS "VILLA",
--            sk.col02     AS "BREÑA",
            NULL,
            NULL,
            p.stock98
        BULK COLLECT
        INTO v_table
        FROM
            pack_lista_precios.sp_buscar_stock(pin_id_cia, v_pdesde, v_phasta, 1, 1,
                                               1, 2, 3, 'S')                       p
--            LEFT OUTER JOIN sp000_comas_en_columnas(p.stockcol, ';')                                 sk ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(p.id_cia, p.tipinv, p.codart, 4) c4 ON 0 = 0
            LEFT OUTER JOIN articulos                                                              a ON a.id_cia = p.id_cia
                                           AND a.tipinv = p.tipinv
                                           AND a.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l2 ON l2.id_cia = p.id_cia
                                               AND l2.vencom = 1
                                               AND l2.codtit = 2
                                               AND l2.tipinv = p.tipinv
                                               AND l2.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l3 ON l3.id_cia = p.id_cia
                                               AND l3.vencom = 1
                                               AND l3.codtit = 3
                                               AND l3.tipinv = p.tipinv
                                               AND l3.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l4 ON l4.id_cia = p.id_cia
                                               AND l4.vencom = 1
                                               AND l4.codtit = 4
                                               AND l4.tipinv = p.tipinv
                                               AND l4.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l5 ON l5.id_cia = p.id_cia
                                               AND l5.vencom = 1
                                               AND l5.codtit = 5
                                               AND l5.tipinv = p.tipinv
                                               AND l5.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l6 ON l6.id_cia = p.id_cia
                                               AND l6.vencom = 1
                                               AND l6.codtit = 6
                                               AND l6.tipinv = p.tipinv
                                               AND l6.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l7 ON l7.id_cia = p.id_cia
                                               AND l7.vencom = 1
                                               AND l7.codtit = 7
                                               AND l7.tipinv = p.tipinv
                                               AND l7.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l8 ON l8.id_cia = p.id_cia
                                               AND l8.vencom = 1
                                               AND l8.codtit = 8
                                               AND l8.tipinv = p.tipinv
                                               AND l8.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l9 ON l9.id_cia = p.id_cia
                                               AND l9.vencom = 1
                                               AND l9.codtit = 9
                                               AND l9.tipinv = p.tipinv
                                               AND l9.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l10 ON l10.id_cia = p.id_cia
                                                AND l10.vencom = 1
                                                AND l10.codtit = 10
                                                AND l10.tipinv = p.tipinv
                                                AND l10.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l11 ON l11.id_cia = p.id_cia
                                                AND l11.vencom = 1
                                                AND l11.codtit = 11
                                                AND l11.tipinv = p.tipinv
                                                AND l11.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l12 ON l12.id_cia = p.id_cia
                                                AND l12.vencom = 1
                                                AND l12.codtit = 12
                                                AND l12.tipinv = p.tipinv
                                                AND l12.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l13 ON l13.id_cia = p.id_cia
                                                AND l13.vencom = 1
                                                AND l13.codtit = 13
                                                AND l13.tipinv = p.tipinv
                                                AND l13.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l14 ON l14.id_cia = p.id_cia
                                                AND l14.vencom = 1
                                                AND l14.codtit = 14
                                                AND l14.tipinv = p.tipinv
                                                AND l14.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l15 ON l15.id_cia = p.id_cia
                                                AND l15.vencom = 1
                                                AND l15.codtit = 15
                                                AND l15.tipinv = p.tipinv
                                                AND l15.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l16 ON l16.id_cia = p.id_cia
                                                AND l16.vencom = 1
                                                AND l16.codtit = 16
                                                AND l16.tipinv = p.tipinv
                                                AND l16.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l18 ON l18.id_cia = p.id_cia
                                                AND l18.vencom = 1
                                                AND l18.codtit = 18
                                                AND l18.tipinv = p.tipinv
                                                AND l18.codart = p.codart
            LEFT OUTER JOIN listaprecios                                                           l19 ON l19.id_cia = p.id_cia
                                                AND l19.vencom = 1
                                                AND l19.codtit = 19
                                                AND l19.tipinv = p.tipinv
                                                AND l19.codart = p.codart
        ORDER BY
            p.clase01,
            p.codigo01,
            p.clase02,
            p.codigo02,
            p.desart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_kanban (
        pin_id_cia NUMBER,
        pin_kanban NUMBER
    ) RETURN datatable_kanban
        PIPELINED
    AS

        v_table  datatable_kanban;
        v_pdesde NUMBER := extract(YEAR FROM current_timestamp) * 100;
        v_phasta NUMBER := extract(YEAR FROM current_timestamp) * 100 + extract(MONTH FROM current_timestamp);
    BEGIN
        SELECT
            to_char(current_timestamp, 'DD/MM/YY') AS fecha,
            kc.descri                              AS kanban,
            ccc.descodigo                          AS familia,
            a.codart,
            a.descri                               AS articulo,
            ac.stock                               AS stock,
            kd.cantidmin                           AS stock_minimo,
            ac.costo                               AS costo_unitario,
            ac.stock * ac.costo                    AS costo_total,
            round(tcmn.preciolista, 2)             AS precio_sol,
            round(tcme.preciolista, 2)             AS precio_dol
        BULK COLLECT
        INTO v_table
        FROM
                 kanban_cab kc
            INNER JOIN kanban_det                                                             kd ON kd.id_cia = kc.id_cia
                                        AND kd.codkan = kc.codkan
            INNER JOIN articulos                                                              a ON a.id_cia = kd.id_cia
                                      AND a.tipinv = kd.tipinv
                                      AND a.codart = kd.codart
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 2) ccc ON 0 = 0
            LEFT OUTER JOIN sp_stock_articulo_costo(a.id_cia, a.tipinv, a.codart, ' ', ' ',
                                                    v_pdesde, v_phasta)                                                    ac ON 0 = 0
            LEFT OUTER JOIN listaprecios                                                           l ON l.id_cia = a.id_cia
                                              AND l.tipinv = a.tipinv
                                              AND l.codart = a.codart
                                              AND l.vencom = 1
                                              AND l.codtit = 1
                                              AND l.codpro = '00000000001'
            LEFT OUTER JOIN tcambio                                                                t ON t.id_cia = kc.id_cia
                                         AND t.hmoneda = 'PEN'
                                         AND trunc(t.fecha) = trunc(current_timestamp)
                                         AND t.moneda = 'USD'
            LEFT OUTER JOIN pack_articulos_clase.sp_tipcamlista(a.id_cia, l.codmon, l.incigv, 'PEN', 'N',
                                                                t.fventa, l.precio, l.porigv, current_timestamp)                       tcmn
                                                                ON 0 = 0
            LEFT OUTER JOIN pack_articulos_clase.sp_tipcamlista(a.id_cia, l.codmon, l.incigv, 'USD', 'N',
                                                                t.fventa, l.precio, l.porigv, current_timestamp)                       tcme
                                                                ON 0 = 0
        WHERE
                kc.id_cia = pin_id_cia
            AND kc.codkan = pin_kanban
        ORDER BY
            ccc.codigo ASC,
            a.codart ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_kanban;

    FUNCTION sp_stock_articulo_costo (
        pin_id_cia   NUMBER,
        pin_tipinv   NUMBER,
        pin_codart   VARCHAR2,
        pin_codadd01 IN VARCHAR2,
        pin_codadd02 IN VARCHAR2,
        pin_pdesde   NUMBER,
        pin_phasta   NUMBER
    ) RETURN datatable_costo
        PIPELINED
    AS
        v_rec    datarecord_costo;
        v_costo  NUMBER;
        v_cantid NUMBER;
    BEGIN
--        SELECT
--            SUM(nvl(ac.costo01, 0)) AS costo,
--            SUM(nvl(ac.cantid, 0))  AS cantid
--        INTO
--            v_costo,
--            v_cantid
--        FROM
--            articulos_costo ac
--        WHERE
--                ac.id_cia = pin_id_cia
--            AND ac.tipinv = pin_tipinv
--            AND ac.codart = pin_codart
--            AND ac.periodo = pin_phasta;

        SELECT
            acr.cosuni01
        INTO v_rec.costo
        FROM
            articulos_costo_reposicion acr
        WHERE
                acr.id_cia = pin_id_cia
            AND acr.tipinv = pin_tipinv
            AND acr.codart = pin_codart
            AND nvl(acr.codadd01, ' ') = nvl(pin_codadd01, ' ')
            AND nvl(acr.codadd02, ' ') = nvl(pin_codadd02, ' ');

        SELECT
            SUM(nvl(aa.ingreso, 0)) - SUM(nvl(aa.salida, 0))
        INTO v_rec.stock
        FROM
            articulos_almacen aa
        WHERE
                aa.id_cia = pin_id_cia
            AND aa.tipinv = pin_tipinv
            AND aa.codart = pin_codart
            AND periodo BETWEEN pin_pdesde AND pin_phasta;

--        IF v_cantid = 0 THEN
--            v_rec.costo := 0;
--        ELSE
--            v_rec.costo := round(v_costo / v_cantid, 2);
--        END IF;

        PIPE ROW ( v_rec );
    END sp_stock_articulo_costo;

END;

/
