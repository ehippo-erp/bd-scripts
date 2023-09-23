--------------------------------------------------------
--  DDL for Package Body PACK_ARTICULOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ARTICULOS" AS

    FUNCTION sp_articulo_ventas (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_tipinv IN NUMBER,
        pin_codart IN VARCHAR2,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable_articulo_ventas
        PIPELINED
    AS
        x       NUMBER;
        v_table datatable_articulo_ventas;
    BEGIN
        SELECT
            COUNT(*)
        INTO x
        FROM
            documentos_cab;

        SELECT
            c.tipdoc,
            c.numint,
            d.numite,
            c.codmot,
            m.desmot,
            c.codven,
            v.desven,
            c.codcpag,
            cp.despag,
            c.femisi,
            c.numdoc,
            c.series,
            c.codcli,
            c.razonc,
            td.signo,
            c.incigv,
            d.tipinv,
            d.codart,
            a.descri   AS desart,
            d.cantid,
            d.largo,
            d.codalm,
            d.pordes1,
            d.pordes2,
            d.pordes3,
            d.pordes4,
            d.ancho,
            d.lote,
            d.nrocarrete,
            d.fvenci,
            CASE
                WHEN tipmon = 'PEN' THEN
                        d.preuni
                ELSE
                    0
            END
            * td.signo AS preunisol,
            CASE
                WHEN tipmon = 'USD' THEN
                        d.preuni
                ELSE
                    0
            END
            * td.signo AS preunidol,
            CASE
                WHEN tipmon = 'PEN' THEN
                        d.importe
                ELSE
                    0
            END
            * td.signo AS pretotsol,
            CASE
                WHEN tipmon = 'USD' THEN
                        d.importe
                ELSE
                    0
            END
            * td.signo AS pretotdol,
            al.descri  AS desalm,
            c.ordcom,
            dc.descri  AS desdoc,
            s.dessit
        BULK COLLECT
        INTO v_table
        FROM
                 documentos_det d
            INNER JOIN documentos_cab c ON c.id_cia = d.id_cia
                                           AND ( c.numint = d.numint )
            LEFT OUTER JOIN documentos     dc ON dc.id_cia = d.id_cia
                                             AND ( dc.codigo = d.tipdoc )
                                             AND ( dc.series = c.series )
            LEFT OUTER JOIN situacion      s ON s.id_cia = d.id_cia
                                           AND ( s.tipdoc = d.tipdoc
                                                 AND s.situac = c.situac )
            LEFT OUTER JOIN almacen        al ON al.id_cia = d.id_cia
                                          AND al.tipinv = d.tipinv
                                          AND al.codalm = d.codalm
            LEFT OUTER JOIN tdoccobranza   td ON td.id_cia = d.id_cia
                                               AND ( td.tipdoc = d.tipdoc )
            LEFT OUTER JOIN articulos      a ON a.id_cia = d.id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
            LEFT OUTER JOIN c_pago         cp ON cp.id_cia = d.id_cia
                                         AND cp.codpag = c.codcpag
            LEFT OUTER JOIN vendedor       v ON v.id_cia = d.id_cia
                                          AND v.codven = c.codven
            LEFT OUTER JOIN motivos        m ON m.id_cia = d.id_cia
                                         AND m.tipdoc = c.tipdoc
                                         AND m.id = c.id
                                         AND m.codmot = c.codmot
        WHERE
                c.id_cia = pin_id_cia
            AND ( ( pin_fdesde IS NULL
                    AND pin_fhasta IS NULL )
                  OR ( c.femisi BETWEEN pin_fdesde AND pin_fhasta ) )
            AND c.tipdoc IN ( 1, 3, 7, 8 )
            AND c.situac IN ( 'F', 'G', 'C', 'H' )
            AND ( d.tipinv = pin_tipinv
                  OR nvl(pin_tipinv, - 1) = - 1 )
            AND ( d.codart = pin_codart
                  OR pin_codart IS NULL )
            AND ( c.codsuc = pin_codsuc
                  OR nvl(pin_codsuc, - 1) = - 1 )
            AND ( c.codcli = pin_codcli
                  OR pin_codcli IS NULL )
            AND c.id = 'S'
            AND c.codmot = 1
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
    END sp_articulo_ventas;

    FUNCTION sp_cotizaciones (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2,
        pin_codsuc NUMBER,
        pin_codcli VARCHAR2,
        pin_situac VARCHAR2,
        pin_limit  NUMBER,
        pin_offset NUMBER
    ) RETURN datatable_cotizaciones
        PIPELINED
    AS
        v_table datatable_cotizaciones;
    BEGIN
        SELECT
            c.tipdoc,
            c.numint,
            d.numite,
            c.codmot,
            c.femisi,
            c.numdoc,
            c.series,
            c.codcli,
            c.razonc,
            c.incigv,
            d.tipinv,
            d.codart,
            d.cantid,
            d.codalm,
            CASE
                WHEN ( c.tipmon = 'PEN' )
                     AND ( d.cantid > 0 ) THEN
                    d.preuni
                ELSE
                    0
            END       AS preunisol,
            CASE
                WHEN ( c.tipmon = 'USD' )
                     AND ( d.cantid > 0 ) THEN
                    d.preuni
                ELSE
                    0
            END       AS preunidol,
            CASE
                WHEN ( c.tipmon = 'PEN' ) THEN
                    d.importe
                ELSE
                    0
            END       AS pretotsol,
            CASE
                WHEN ( c.tipmon = 'USD' ) THEN
                    d.preuni
                ELSE
                    0
            END       AS pretotdol,
            d.pordes1,
            d.pordes2,
            d.pordes3,
            d.pordes4,
            al.descri AS desalm,
            c.ordcom,
            dc.descri AS desdoc,
            s.dessit,
            d.largo
        BULK COLLECT
        INTO v_table
        FROM
            documentos_det d
            LEFT OUTER JOIN documentos_cab c ON c.id_cia = d.id_cia
                                                AND c.numint = d.numint
            LEFT OUTER JOIN documentos     dc ON dc.id_cia = d.id_cia
                                             AND dc.codigo = d.tipdoc
                                             AND dc.series = c.series
            LEFT OUTER JOIN situacion      s ON s.id_cia = d.id_cia
                                           AND s.tipdoc = d.tipdoc
                                           AND s.situac = d.situac
            LEFT OUTER JOIN almacen        al ON al.id_cia = d.id_cia
                                          AND al.tipinv = d.tipinv
                                          AND al.codalm = d.codalm
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 100
            AND ( ( pin_fdesde IS NULL
                    AND pin_fhasta IS NULL )
                  OR ( c.femisi BETWEEN pin_fdesde AND pin_fhasta ) )
            AND d.tipinv = pin_tipinv
            AND d.codart = pin_codart
            AND ( nvl(pin_codsuc, - 1) = - 1
                  OR c.codsuc = pin_codsuc )
            AND ( ( pin_situac IS NULL )
                  OR ( c.situac IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_situac) )
            ) ) )
            AND ( ( pin_codcli IS NULL )
                  OR ( c.codcli = pin_codcli ) )
            AND c.codmot <> 0
        ORDER BY
            c.femisi DESC
        OFFSET pin_offset ROWS FETCH NEXT pin_limit ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cotizaciones;

    FUNCTION sp_buscar_clase_codigo (
        pin_id_cia IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_codart IN VARCHAR2,
        pin_clase  IN NUMBER
    ) RETURN datatable_clase_codigo
        PIPELINED
    AS
        v_table datatable_clase_codigo;
    BEGIN
        SELECT
            c.tipinv  AS tipinv,
            c.codart  AS codart,
            c.clase   AS clase,
            cl.descri AS desclase,
            c.codigo  AS codigo,
            co.descri AS descodigo
        BULK COLLECT
        INTO v_table
        FROM
            articulos_clase c
            LEFT OUTER JOIN clase           cl ON cl.id_cia = c.id_cia
                                        AND cl.tipinv = c.tipinv
                                        AND cl.clase = c.clase
            LEFT OUTER JOIN clase_codigo    co ON co.id_cia = c.id_cia
                                               AND co.tipinv = c.tipinv
                                               AND co.clase = c.clase
                                               AND co.codigo = c.codigo
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipinv = pin_tipinv
            AND c.codart = pin_codart
            AND c.clase = pin_clase;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_clase_codigo;

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_codart IN VARCHAR2
    ) RETURN datatable_articulos
        PIPELINED
    AS
        v_table datatable_articulos;
    BEGIN
        SELECT
            a.id_cia   AS id_cia,
            a.tipinv   AS tipinv,
            t.dtipinv  AS dtipinv,
            a.codart   AS codart,
            a.descri   AS desart,
            a.codmar   AS codmar,
            a.codubi   AS codubi,
            a.codprc   AS codprc,
            a.codmod   AS codmod,
--            a.modelo   AS modelo,
            a.codobs   AS codobs,
            a.coduni   AS coduni,
--            a.codlin   AS codlin,
            a.codori   AS codori,
--            a.codfam   AS codfam,
            a.codbar   AS codbar,
            a.parara   AS parara,
            a.proart   AS proart,
            a.consto   AS consto,
            a.codprv   AS codprv,
            a.agrupa   AS agrupa,
            a.fmatri   AS fmatri,
--            a.usuari   AS usuari,
            a.wglosa   AS wglosa,
            a.faccon   AS faccon,
            a.tusoesp  AS tusoesp,
            a.tusoing  AS tusoing,
            a.diacmm   AS diacmm,
--            a.cuenta   AS cuenta,
            a.conesp   AS conesp,
--            a.linea    AS linea,
            a.proint   AS proint,
            a.codint   AS codint,
            a.codope   AS codope,
--            a.situac   AS situac,
            agc.observ AS glosacotizaciondefecto,
            agf.observ AS glosafacturaciondefecto,
            a.usuari   AS ucreac,
            a.usuari   AS uactua,
            a.factua,
            a.fcreac
        BULK COLLECT
        INTO v_table
        FROM
            articulos       a
            LEFT OUTER JOIN t_inventario    t ON t.id_cia = a.id_cia
                                              AND t.tipinv = a.tipinv
            LEFT OUTER JOIN articulos_glosa agc ON agc.id_cia = a.id_cia
                                                   AND agc.tipinv = a.tipinv
                                                   AND agc.codart = a.codart
                                                   AND agc.tipo = 1
            LEFT OUTER JOIN articulos_glosa agf ON agf.id_cia = a.id_cia
                                                   AND agf.tipinv = a.tipinv
                                                   AND agf.codart = a.codart
                                                   AND agf.tipo = 2
        WHERE
                a.id_cia = pin_id_cia
            AND a.tipinv = pin_tipinv
            AND a.codart = pin_codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_xrecibir (
        pin_id_cia INTEGER,
        pin_tipinv INTEGER,
        pin_codart VARCHAR2,
        pin_codalm INTEGER
    ) RETURN datatable_xrecibir
        PIPELINED
    AS
        v_table datatable_xrecibir;
    BEGIN
        SELECT
            s.numint,
            s.numite,
            s.cantidad,
            s.entrega,
            s.saldo,
            c.series,
            c.numdoc,
            c.femisi,
            c.fentreg,
            c.tipmon,
            c.tipcam,
            c.codcli,
            c.razonc,
            c.ruc,
            c.opnumdoc,
            d.codund,
            CASE
                WHEN c.tipmon = 'PEN' THEN
                    ( d.monafe + d.monina ) / d.cantid
                ELSE
                    ( ( d.monafe + d.monina ) * c.tipcam ) / d.cantid
            END AS preunisol,
            CASE
                WHEN c.tipmon = 'USD' THEN
                    ( d.monafe + d.monina ) / d.cantid
                ELSE
                    ( ( d.monafe + d.monina ) / c.tipcam ) / d.cantid
            END AS preunidol,
            CASE
                WHEN c.tipmon = 'PEN' THEN
                    ( d.monafe + d.monina )
                ELSE
                    ( ( d.monafe + d.monina ) * c.tipcam )
            END AS pretotsol,
            CASE
                WHEN c.tipmon = 'USD' THEN
                    ( d.monafe + d.monina )
                ELSE
                    ( ( d.monafe + d.monina ) / c.tipcam )
            END AS pretotdol
        BULK COLLECT
        INTO v_table
        FROM
            sp00_saca_saldos_documentos(pin_id_cia, pin_tipinv, pin_codart, pin_codalm, 105,
                                        'B G', 1, 'I') s -- VISADA Y ATENDIDAS PARCIALMENTE
            LEFT OUTER JOIN documentos_cab                             c ON c.id_cia = pin_id_cia
                                                AND c.numint = s.numint
            LEFT OUTER JOIN documentos_det                             d ON d.id_cia = pin_id_cia
                                                AND d.numint = s.numint
                                                AND d.numite = s.numite
        WHERE
                c.id_cia = pin_id_cia
            AND s.saldo <> 0
        ORDER BY
            s.numint,
            s.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_xrecibir;

    FUNCTION sp_listaprecios_prov (
        pin_id_cia INTEGER,
        pin_tipinv INTEGER,
        pin_codart VARCHAR2
    ) RETURN datatable_listaprecios_prov
        PIPELINED
    AS
        v_table datatable_listaprecios_prov;
    BEGIN
        SELECT
            c.codcli,
            c.razonc,
            c.dident,
            lp.codmon,
            lp.precio,
            lp.incigv,
            lp.modpre,
            lp.desc01,
            lp.desc02,
            lp.desc03,
            lp.desc04,
            lp.porigv,
            lp.factua,
            ' '      AS codcalid,
            ' '      AS dcalidad,
            ' '      AS codcolor,
            ' '      AS dcolor,
            a.coduni AS codund
        BULK COLLECT
        INTO v_table
        FROM
            listaprecios lp
            LEFT OUTER JOIN articulos    a ON a.id_cia = lp.id_cia
                                           AND a.tipinv = lp.tipinv
                                           AND a.codart = lp.codart
            LEFT OUTER JOIN cliente      c ON c.id_cia = lp.id_cia
                                         AND c.codcli = lp.codpro
        WHERE
                lp.id_cia = pin_id_cia
            AND lp.codart = pin_codart
            AND lp.tipinv = pin_tipinv
            AND lp.codtit = '99999';

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        SELECT
            c.codcli,
            c.razonc,
            c.dident,
            lp.codmon,
            lp.precio,
            lp.incigv,
            lp.modpre,
            lp.desc01,
            lp.desc02,
            lp.desc03,
            lp.desc04,
            lp.porigv,
            lp.factua,
            ' ' AS codcalid,
            ' ' AS dcalidad,
            ' ' AS codcolor,
            ' ' AS dcolor,
            lp.codund
        BULK COLLECT
        INTO v_table
        FROM
            listaprecios_codund lp
            LEFT OUTER JOIN cliente             c ON c.id_cia = lp.id_cia
                                         AND c.codcli = lp.codpro
        WHERE
                lp.id_cia = pin_id_cia
            AND lp.codart = pin_codart
            AND lp.tipinv = pin_tipinv
            AND lp.codtit = '99999';

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        SELECT
            c.codcli,
            c.razonc,
            c.dident,
            lp.codmon,
            lp.precio,
            lp.incigv,
            lp.modpre,
            lp.desc01,
            lp.desc02,
            lp.desc03,
            lp.desc04,
            lp.porigv,
            lp.factua,
            CAST(cl1.codigo AS VARCHAR(20))  AS codcalid,
            CAST(cl1.descri AS VARCHAR(100)) AS dcalidad,
            CAST(cl2.codigo AS VARCHAR(20))  AS codcolor,
            CAST(cl2.descri AS VARCHAR(100)) AS dcolor,
            a.coduni                         AS codund
        BULK COLLECT
        INTO v_table
        FROM
            listaprecios_alternativa lp
            LEFT OUTER JOIN articulos                a ON a.id_cia = lp.id_cia
                                           AND a.tipinv = lp.tipinv
                                           AND a.codart = lp.codart
            LEFT OUTER JOIN cliente                  c ON c.id_cia = lp.id_cia
                                         AND c.codcli = lp.codpro
            LEFT OUTER JOIN cliente_articulos_clase  cl1 ON cl1.id_cia = a.id_cia
                                                           AND ( cl1.tipcli = 'B' )
                                                           AND ( cl1.codcli = a.codprv )
                                                           AND ( cl1.clase = 1 )
                                                           AND ( cl1.codigo = lp.codadd01 )
            LEFT OUTER JOIN cliente_articulos_clase  cl2 ON cl2.id_cia = a.id_cia
                                                           AND ( cl2.tipcli = 'B' )
                                                           AND ( cl2.codcli = a.codprv )
                                                           AND ( cl2.clase = 2 )
                                                           AND ( cl2.codigo = lp.codadd02 )
        WHERE
                lp.id_cia = pin_id_cia
            AND lp.codart = pin_codart
            AND lp.tipinv = pin_tipinv
            AND lp.codtit = '99999';

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_listaprecios_prov;

    FUNCTION sp_compras (
        pin_id_cia  NUMBER,
        pin_tipinv  NUMBER,
        pin_codart  VARCHAR2,
        pin_codsuc  NUMBER,
        pin_codprov VARCHAR2,
        pin_limit   NUMBER,
        pin_offset  NUMBER
    ) RETURN datatable_compras
        PIPELINED
    AS
        v_table datatable_compras;
    BEGIN
        SELECT
            t.numint,
            t.id,
            t.tipdoc,
            t.codmot,
            t.periodo,
            t.femisi,
            t.tipinv,
            t.codalm,
            t.codart,
            t.cantid,
            t.costot01,
            t.costot01 / t.cantid AS tcos01,
            t.costot02,
            t.costot02 / t.cantid AS tcos02,
            t.fobtot01,
            t.fobtot02,
            dc.razonc,
            dc.numdoc,
            dc.series,
            dc.codcli,
            m.desmot,
            al.descri             AS desalm,
            ar.descri             AS desart
        BULK COLLECT
        INTO v_table
        FROM
                 (
                SELECT
                    kk.id_cia,
                    kk.id,
                    kk.tipdoc,
                    kk.numint,
                    kk.periodo,
                    kk.codmot,
                    kk.femisi,
                    kk.tipinv,
                    kk.codalm,
                    kk.codart,
                    SUM(kk.cantid)   AS cantid,
                    SUM(kk.costot01) AS costot01,
                    SUM(kk.costot02) AS costot02,
                    SUM(kk.fobtot01) AS fobtot01,
                    SUM(kk.fobtot02) AS fobtot02
                FROM
                         kardex kk
                    INNER JOIN documentos_cab dc ON dc.id_cia = kk.id_cia
                                                    AND dc.numint = kk.numint
                WHERE
                        kk.id_cia = pin_id_cia
                    AND kk.tipinv = pin_tipinv
                    AND kk.codart = pin_codart
                    AND kk.id = 'I'
                    AND kk.codmot IN ( 1, 28 )
                    AND dc.codsuc = pin_codsuc
                    AND ( pin_codprov IS NULL
                          OR dc.codcli = pin_codprov )
                GROUP BY
                    kk.id_cia,
                    kk.id,
                    kk.tipdoc,
                    kk.numint,
                    kk.periodo,
                    kk.codmot,
                    kk.femisi,
                    kk.tipinv,
                    kk.codalm,
                    kk.codart
                ORDER BY
                    kk.femisi DESC
            ) t
            INNER JOIN documentos_cab dc ON dc.id_cia = t.id_cia
                                            AND dc.numint = t.numint
            INNER JOIN almacen        al ON al.id_cia = t.id_cia
                                     AND al.tipinv = t.tipinv
                                     AND al.codalm = t.codalm
            LEFT OUTER JOIN articulos      ar ON ar.id_cia = t.id_cia
                                            AND ar.tipinv = t.tipinv
                                            AND ar.codart = t.codart
            LEFT OUTER JOIN motivos        m ON m.id_cia = dc.id_cia
                                         AND m.codmot = dc.codmot
                                         AND m.id = dc.id
                                         AND m.tipdoc = dc.tipdoc
        ORDER BY
            t.femisi DESC
        OFFSET pin_offset ROWS FETCH NEXT pin_limit ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_compras;

    FUNCTION sp_especificaciones (
        pin_id_cia INTEGER,
        pin_tipinv INTEGER,
        pin_codart VARCHAR2
    ) RETURN datatable_especificaciones
        PIPELINED
    AS
        v_table datatable_especificaciones;
    BEGIN
        SELECT
            e.codesp AS codigo,
            e.descri AS descri,
            ae.vreal,
            ae.vstrg,
            ae.vchar,
            ae.vdate,
            ae.vtime,
            ae.ventero
--            CASE
--                WHEN e.vreal = 'S' THEN
--                    ae.vreal
--                ELSE
--                    NULL
--            END      vreal,
--            CASE
--                WHEN e.vstrg = 'S' THEN
--                    ae.vstrg
--                ELSE
--                    NULL
--            END      vstrg,
--            CASE
--                WHEN e.vchar = 'S' THEN
--                    ae.vchar
--                ELSE
--                    NULL
--            END      vchar,
--            CASE
--                WHEN e.vdate = 'S' THEN
--                    ae.vdate
--                ELSE
--                    NULL
--            END      vdate,
--            CASE
--                WHEN e.vtime = 'S' THEN
--                    ae.vtime
--                ELSE
--                    NULL
--            END      vtime,
--            CASE
--                WHEN e.ventero = 'S' THEN
--                    ae.ventero
--                ELSE
--                    NULL
--            END      ventero
        BULK COLLECT
        INTO v_table
        FROM
                 especificaciones e
            INNER JOIN articulo_especificacion ae ON ae.id_cia = e.id_cia
                                                     AND ae.tipinv = e.tipinv
                                                     AND ae.codart = pin_codart
                                                     AND ae.codesp = e.codesp
        WHERE
                e.id_cia = pin_id_cia
            AND e.tipinv = pin_tipinv
            AND ae.codart = pin_codart
        ORDER BY
            ae.codesp ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END;

    FUNCTION sp_listaprecios (
        pin_id_cia INTEGER,
        pin_tipinv INTEGER,
        pin_codart VARCHAR2
    ) RETURN datatable_listaprecios
        PIPELINED
    AS
        v_table datatable_listaprecios;
    BEGIN
        SELECT
            l.vencom    AS vencom,
            l.codtit    AS codtit,
            l.codpro    AS codpro,
            l.tipinv    AS tipinv,
            l.codart    AS codart,
            l.codmon    AS codmon,
            l.precio    AS precio,
            l.incigv    AS incigv,
            l.modpre    AS modpre,
            l.desc01    AS desc01,
            l.desc02    AS desc02,
            l.desc03    AS desc03,
            l.desc04    AS desc04,
            l.fcreac    AS fcreac,
            l.factua    AS factua,
            l.usuari    AS usuari,
            l.porigv    AS porigv,
            l.sku       AS sku,
            l.desart    AS desartcom,
            l.desmax    AS desmax,
            l.margen    AS margen,
            l.otros     AS otros,
            l.flete     AS flete,
            l.desmaxmon AS desmaxmon,
            l.desinc    AS desinc,
            t.titulo    AS destit,
            m.simbolo
        BULK COLLECT
        INTO v_table
        FROM
            listaprecios l
            LEFT OUTER JOIN titulolista  t ON t.id_cia = l.id_cia
                                             AND t.codtit = l.codtit
            LEFT OUTER JOIN tmoneda      m ON m.id_cia = l.id_cia
                                         AND m.codmon = l.codmon
        WHERE
                l.id_cia = pin_id_cia
            AND l.vencom = 1
            AND l.tipinv = pin_tipinv
            AND l.codart = pin_codart
        ORDER BY
            l.codtit DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_listaprecios;

END;

/
