--------------------------------------------------------
--  DDL for Package Body PACK_QRYFORMATOS_GUIAREMISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_QRYFORMATOS_GUIAREMISION" AS

    FUNCTION sp_re_abre (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN tbl_sp_re_abre_qryformatos_guiaremision
        PIPELINED
    AS

        registro rec_sp_re_abre_qryformatos_guiaremision := rec_sp_re_abre_qryformatos_guiaremision(NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                                                   NULL, NULL, NULL, NULL, NULL);
        CURSOR cur_sp_re_abre_qryformatos_guiaremision IS
        SELECT
            c.tipdoc,
            dc.descri                           AS nomdoc,
            c.numint,
            c.id,
            c.series,
            c.numdoc,
            c.femisi,
            c.destin,
            c.codcli,
            c.razonc,
            c.direc1,
            c.ruc,
            c.tipcam,
            c.tipmon,
            c.codven,
            d.numite,
            d.positi,
            d.tipinv,
            d.codart,
            d.observ                            AS obsdet,
            d.codund                            AS codund,
            d.cantid,
            d.cantid                            AS cantidbase,
            d.canref,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.preuni * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.preuni
            END                                 AS preuni,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.importe_bruto * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe_bruto
            END                                 AS importe_bruto,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.importe * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe
            END                                 AS importe,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    ( d.importe_bruto - d.importe ) * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe_bruto - d.importe
            END                                 AS descdet,
            d.opronumdoc,
            d.swacti,
            d.piezas,
            d.largo,
            d.ancho,
            d.altura,
            d.etiqueta,
            d.etiqueta2,
            d.codund                            AS codunidet,
            d.tara,
            d.royos,
            d.pordes1,
            d.pordes2,
            d.pordes3,
            d.pordes4,
            d.opnumdoc                          AS dopnumdoc,
            d.opcargo                           AS dopcargo,
            d.opnumite                          AS dopnumite,
            d.codalm,
            d.monafe                            AS monafedet,
            d.monigv                            AS monigvdet,
            d.lote                              AS lote,
            d.fvenci                            AS fvenci,
            d.nrocarrete                        AS nrocarrete,
            c.descue,
            c.totbru,
            c.monafe,
            c.monina,
            c.monafe + c.monina                 AS monneto,
            c.monigv,
            (
                CASE
                    WHEN ( mt16.valor IS NULL )
                         OR ( upper(mt16.valor) <> 'S' ) THEN
                        c.preven
                    ELSE
                        0
                END
            )                                   AS preven,
            c.porigv,
            c.codsuc,
            c.incigv,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                                 AS numped,
            c.codmot,
            c.situac,
            c.observ                            AS obscab,
            c.fentreg,
            c.codarea,
            c.coduso,
            c.totcan,
            dca.codenv,
            c.horing,
            c.fecter,
            c.horter,
            c.codtec,
            c.opnumdoc,
            c.ordcom,
            c.fordcom,
            c.guiarefe,
            dca.direc1                          AS desenv01,
            dca.direc2                          AS desenv02,
            c.marcas,
            c.presen,
            c.codsec,
            c.facpro,
            c.ffacpro,
            c.numvale,
            c.fecvale,
            c.desnetx,
            c.despreven,
            c.desfle,
            c.flete,
            c.desseg,
            c.seguro,
            c.desgasa,
            c.gasadu,
            CASE
                WHEN c33.codigo <> 'S' THEN
                    a.descri
                ELSE
                    CASE
                        WHEN lpa33.desart <> '' THEN
                                lpa33.desart
                        ELSE
                            CASE
                                WHEN lp33.desart <> '' THEN
                                            lp33.desart
                                ELSE
                                    a.descri
                            END
                    END
            END                                 AS desart,
            a.codbar,
            a.codart
            || ' '
            || a.descri                         AS coddesart,
            a.codlin,
            a.faccon,
            a.consto,
            d.largo * a.faccon                  AS peslar,
            ( d.cantid * a.faccon ) + CAST(
                CASE
                    WHEN cc2.abrevi IS NULL THEN
                        '0'
                    ELSE
                        cc2.abrevi
                END
            AS NUMERIC(16, 5))                  AS pesdet,
            ( d.cantid * a.faccon )             AS pescable,
            cc2.abrevi                          AS taraadic,
            cv.despag                           AS despagven,
            cvc.valor                           AS enctacte,
            cv.diaven,
            s1.sucursal                         AS dessuc,
            s1.nomdis                           AS dissuc,
            c1.direc1                           AS dircli1,
            c1.direc2                           AS dircli2,
            c1.email                            AS emailcli,
            c1.fax                              AS faxcli,
            c1.telefono                         AS tlfcli,
            c1.dident,
            c1.tident                           AS tident,
            v1.desven,
            c.comisi                            AS comiven,
            v1.codven                           AS codvendedor,
            m1.simbolo,
            m1.desmon,
            c.codtra,
            t1.swdattra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.destra
                ELSE
                    t1.razonc
            END                                 AS razonctra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.chofer
                ELSE
                    t1.descri
            END                                 AS destra,
            t1.domici                           AS dirtra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.ruc
                ELSE
                    t1.ruc
            END                                 AS ructra,
            t1.punpar                           AS punpartra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.licenc
                ELSE
                    t1.licenc
            END                                 AS licenciatra,
            t1.placa                            AS placatra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.certif
                ELSE
                    t1.certif
            END                                 AS certiftra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.telef1
                ELSE
                    t1.telef1
            END                                 AS fonotra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.desveh
                ELSE
                    vh.descri
            END                                 AS desveh,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.tipo
                ELSE
                    vh.tipo
            END                                 AS tipoveh,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.marca
                ELSE
                    vh.marca
            END                                 AS marcaveh,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.placa
                ELSE
                    CASE
                        WHEN vh.placa IS NOT NULL
                             OR vh.placa <> '' THEN
                                vh.placa
                        ELSE
                            t1.placa
                    END
            END                                 AS placaveh,
            vh.certif                           AS certifveh,
            vh.observ                           AS observveh,
            t2.razonc                           AS razonctra2,
            t2.descri                           AS destra2,
            t2.domici                           AS dirtra2,
            t2.ruc                              AS ructra2,
            t2.punpar                           AS punpartra2,
            t2.licenc                           AS licenctra2,
            vh.placa                            AS placaveh2,
            mt.desmot,
            k.ingreso - k.salida                AS stockk001,
            ( k.ingreso - k.salida ) - d.cantid AS saldok001,
            ca.descri                           AS desenval,
            ca.direc1                           AS direnv1,
            ca.direc2                           AS direnv2,
            ct.nrodni,
            cc3.descri                          AS colorart,
            agl.observ                          AS desglosa,
            lp.sku                              AS skuventas,
            CASE
                WHEN ac2.codigo IS NULL THEN
                    'N'
                ELSE
                    ac2.codigo
            END                                 AS glosxdes,
            cr.series                           AS ocseries,
            cr.numdoc                           AS ocnumdoc,
            tdr.descri                          AS ocdesdoc,
            tdr.abrevi                          AS ocabrdoc,
            cl1.codigo                          AS codcalid,
            cl1.descri                          AS dcalidad,
            cl1.abrevi                          AS acalidad,
            cl2.codigo                          AS codcolor,
            cl2.codigo
            || '-'
            || cl2.descri                       AS dcolor,
            acc2.descodigo                      AS desfam,
            acc3.descodigo                      AS deslin,
            acc51.descodigo                     AS desmod,
            acc97.codigo                        AS codubica,
            (
                CASE
                    WHEN aca1.vreal IS NULL THEN
                        0
                    ELSE
                        aca1.vreal
                END
            )                                   valundaltven,
            ( cc14.descri
              || ','
              || cc15.descri
              || ','
              || cc16.descri )                    AS ubigeo,
            ( cc16.descri
              || ' - '
              || cc15.descri
              || ' - '
              || cc14.descri )                    AS ubigeo_b,
            ( ca16.descri
              || ' - '
              || ca15.descri
              || ' - '
              || ca14.descri )                    AS ubigeo_destino_b,
            doc.fecha                           AS fecha_dcorcom,
            doc.numero                          AS numero_dcorcom,
            doc.contacto                        AS contacto_dcorcom,
            c.pesnet,
            ( ccp14.descri
              || ','
              || ccp15.descri
              || ','
              || ccp16.descri )                   AS ubigeodes_partida_a,
            ( ccp16.descri
              || ' - '
              || ccp15.descri
              || ' - '
              || ccp14.descri )                   AS ubigeodes_partida_b,
            s1.ubigeo                           AS ubigeo_partida,
            ca16.codigo                         AS ubigeo_llegada,
            c.direccpar                         AS direccpar,
            c.ubigeopar                         AS ubigeopar,
            CASE
                WHEN length(
                    CASE
                        WHEN t1.swdattra = 'S' THEN
                            dct.ruc
                        ELSE
                            t1.ruc
                    END
                ) = 11 THEN
                    '6'
                ELSE
                    '0'
            END                                 AS tidentra,
            CASE
                WHEN ( ( t1.chofer_tident IS NULL )
                       OR ( length(t1.chofer_tident) = 0 ) ) THEN
                    dct.chofer_tident
                ELSE
                    t1.chofer_tident
            END                                 AS tidentconductor,
            CASE
                WHEN ( ( t1.chofer_tident IS NULL )
                       OR ( length(t1.chofer_tident) = 0 ) ) THEN
                    (
                        SELECT
                            descri
                        FROM
                            identidad
                        WHERE
                                id_cia = pin_id_cia
                            AND tident = dct.chofer_tident
                    )
                ELSE
                    (
                        SELECT
                            descri
                        FROM
                            identidad
                        WHERE
                                id_cia = pin_id_cia
                            AND tident = t1.chofer_tident
                    )
            END                                 AS destidentconductor,
            CASE
                WHEN ( ( t1.chofer_dident IS NULL )
                       OR ( length(t1.chofer_dident) = 0 ) ) THEN
                    dct.chofer_dident
                ELSE
                    t1.chofer_dident
            END                                 AS didentconductor,
            CASE
                WHEN length(vh.placa) > 0 THEN
                    vh.placa
                ELSE
                    CASE
                        WHEN ( ( t1.swdattra = 'S' )
                               AND ( length(dct.placa) > 0 ) ) THEN
                                dct.placa
                        ELSE
                            t1.placa
                    END
            END                                 AS placavehiculo,
            gfecab.glosa                        AS glosagfecab,
            gfepie.glosa                        AS glosagfepie,
            s2.dessit                           AS dessit,
            s2.alias                            AS aliassit,
            pt.proyec,
            und.abrevi                          AS abrunidad
        FROM
            documentos_cab                                               c
            LEFT OUTER JOIN documentos_cab                                               cr ON ( cr.id_cia = c.id_cia )
                                                 AND ( cr.numint = c.ordcomni )
            LEFT OUTER JOIN documentos_cab_ordcom                                        doc ON ( doc.id_cia = c.id_cia )
                                                         AND ( c.numint = doc.numint )
            LEFT OUTER JOIN tdoccobranza                                                 tdr ON ( tdr.id_cia = c.id_cia )
                                                AND ( tdr.tipdoc = cr.tipdoc )
            LEFT OUTER JOIN documentos_cab_clase                                         cc ON ( cc.id_cia = c.id_cia )
                                                       AND ( cc.numint = c.numint
                                                             AND cc.clase = 6 )
            LEFT OUTER JOIN motivos_clase                                                mt16 ON ( mt16.id_cia = c.id_cia )
                                                  AND ( mt16.codmot = c.codmot )
                                                  AND ( mt16.id = c.id )
                                                  AND ( mt16.tipdoc = c.tipdoc )
                                                  AND ( mt16.codigo = 16 )
            LEFT OUTER JOIN documentos_det                                               d ON ( d.id_cia = c.id_cia )
                                                AND ( d.numint = c.numint )
            LEFT OUTER JOIN documentos_cab                                               pt ON ( pt.id_cia = c.id_cia )
                                                 AND pt.numint = d.opnumdoc
            LEFT OUTER JOIN unidad                                                       und ON ( und.id_cia = c.id_cia )
                                          AND und.coduni = d.codund
            LEFT OUTER JOIN documentos                                                   dc ON ( dc.id_cia = c.id_cia )
                                             AND ( dc.codigo = c.tipdoc )
                                             AND ( dc.series = c.series )
            LEFT OUTER JOIN articulos                                                    a ON ( a.id_cia = c.id_cia )
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN cliente_articulos_clase                                      cl1 ON ( cl1.id_cia = c.id_cia )
                                                           AND ( cl1.tipcli = 'B' )
                                                           AND ( cl1.codcli = a.codprv )
                                                           AND ( cl1.clase = 1 )
                                                           AND ( cl1.codigo = d.codadd01 )
            LEFT OUTER JOIN cliente_articulos_clase                                      cl2 ON ( cl2.id_cia = c.id_cia )
                                                           AND ( cl2.tipcli = 'B' )
                                                           AND ( cl2.codcli = a.codprv )
                                                           AND ( cl2.clase = 2 )
                                                           AND ( cl2.codigo = d.codadd02 )
            LEFT OUTER JOIN articulos_clase                                              ac1 ON ( ac1.id_cia = c.id_cia )
                                                   AND ( ac1.tipinv = d.tipinv
                                                         AND ac1.codart = d.codart
                                                         AND ac1.clase = 81 )
            LEFT OUTER JOIN articulos_clase                                              ac2 ON ( ac2.id_cia = c.id_cia )
                                                   AND ( ac2.tipinv = d.tipinv
                                                         AND ac2.codart = d.codart
                                                         AND ac2.clase = 87 )
            LEFT OUTER JOIN articulos_clase                                              ac3 ON ( ac3.id_cia = c.id_cia )
                                                   AND ( ac3.tipinv = d.tipinv
                                                         AND ac3.codart = d.codart
                                                         AND ac3.clase = 74 )
            LEFT OUTER JOIN clase_codigo                                                 cc3 ON ( cc3.id_cia = c.id_cia )
                                                AND ( cc3.tipinv = d.tipinv
                                                      AND cc3.clase = ac3.clase
                                                      AND cc3.codigo = ac3.codigo )
            LEFT OUTER JOIN clase_codigo                                                 cc2 ON ( cc2.id_cia = c.id_cia )
                                                AND ( cc2.tipinv = ac1.tipinv
                                                      AND cc2.clase = ac1.clase
                                                      AND cc2.codigo = ac1.codigo )
            LEFT OUTER JOIN sp_select_articulo_clase(pin_id_cia, d.tipinv, d.codart, 2)  acc2 ON acc2.codigo <> 'ND'
            LEFT OUTER JOIN sp_select_articulo_clase(pin_id_cia, d.tipinv, d.codart, 3)  acc3 ON acc3.codigo <> 'ND'
            LEFT OUTER JOIN sp_select_articulo_clase(pin_id_cia, d.tipinv, d.codart, 51) acc51 ON acc51.codigo <> 'ND'
            LEFT OUTER JOIN sp_select_articulo_clase(pin_id_cia, d.tipinv, d.codart, 97) acc97 ON acc97.codigo <> 'ND'
            LEFT OUTER JOIN c_pago                                                       cv ON ( cv.id_cia = c.id_cia )
                                         AND ( cv.codpag = c.codcpag )
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN c_pago_clase                                                 cvc ON ( cvc.id_cia = c.id_cia )
                                                AND ( cvc.codpag = c.codcpag )
                                                AND ( cvc.codigo = 1 )
            LEFT OUTER JOIN sucursal                                                     s1 ON ( s1.id_cia = c.id_cia )
                                           AND ( s1.codsuc = c.codsuc )
            LEFT OUTER JOIN cliente                                                      c1 ON ( c1.id_cia = c.id_cia )
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN cliente_clase                                                c33 ON ( c33.id_cia = c.id_cia )
                                                 AND ( c33.tipcli = 'A' )
                                                 AND ( c33.codcli = c.codcli )
                                                 AND ( c33.clase = 33 )
            LEFT OUTER JOIN cliente_clase                                                c14 ON ( c14.id_cia = c.id_cia )
                                                 AND ( c14.tipcli = 'A' )
                                                 AND ( c14.codcli = c.codcli )
                                                 AND ( c14.clase = 14 )
            LEFT OUTER JOIN clase_cliente_codigo                                         cc14 ON ( cc14.id_cia = c.id_cia )
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase                                                c15 ON ( c15.id_cia = c.id_cia )
                                                 AND ( c15.tipcli = 'A' )
                                                 AND ( c15.codcli = c.codcli )
                                                 AND ( c15.clase = 15 )
            LEFT OUTER JOIN clase_cliente_codigo                                         cc15 ON ( cc15.id_cia = c.id_cia )
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase                                                c16 ON ( c16.id_cia = c.id_cia )
                                                 AND ( c16.tipcli = 'A' )
                                                 AND ( c16.codcli = c.codcli )
                                                 AND ( c16.clase = 16 )
            LEFT OUTER JOIN clase_cliente_codigo                                         cc16 ON ( cc16.id_cia = c.id_cia )
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN listaprecios                                                 lp33 ON ( lp33.id_cia = c.id_cia )
                                                 AND lp33.vencom = 1
                                                 AND lp33.codtit = c1.codtit
                                                 AND lp33.tipinv = d.tipinv
                                                 AND lp33.codart = d.codart
            LEFT OUTER JOIN listaprecios_alternativa                                     lpa33 ON ( lpa33.id_cia = c.id_cia )
                                                              AND lpa33.vencom = 1
                                                              AND lpa33.codtit = c1.codtit
                                                              AND lpa33.tipinv = d.tipinv
                                                              AND lpa33.codart = d.codart
                                                              AND lpa33.codadd01 = d.codadd01
                                                              AND lpa33.codadd02 = d.codadd02
            LEFT OUTER JOIN cliente_tpersona                                             ct ON ( ct.id_cia = c.id_cia )
                                                   AND ( ct.codcli = c.codcli )
            LEFT OUTER JOIN vendedor                                                     v1 ON ( v1.id_cia = c.id_cia )
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN tmoneda                                                      m1 ON ( m1.id_cia = c.id_cia )
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN transportista                                                t1 ON ( t1.id_cia = c.id_cia )
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN transportista                                                t2 ON ( t2.id_cia = c.id_cia )
                                                AND ( t2.codtra = c.codtec )
            LEFT OUTER JOIN motivos                                                      mt ON ( mt.id_cia = c.id_cia )
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( mt.tipdoc = c.tipdoc )
            LEFT OUTER JOIN kardex001                                                    k ON ( k.id_cia = c.id_cia )
                                           AND ( k.tipinv = d.tipinv )
                                           AND ( k.codart = d.codart )
                                           AND ( k.codalm = d.codalm )
                                           AND ( k.etiqueta = d.etiqueta )
            LEFT OUTER JOIN documentos_cab_almacen                                       dca ON ( dca.id_cia = c.id_cia )
                                                          AND ( c.numint = dca.numint )
            LEFT OUTER JOIN clientes_almacen_clase                                       cac10 ON ( cac10.id_cia = c.id_cia )
                                                            AND cac10.codcli = c.codcli
                                                            AND cac10.codenv = dca.codenv
                                                            AND cac10.clase = 10
            LEFT OUTER JOIN clientes_almacen_clase                                       cac14 ON ( cac14.id_cia = c.id_cia )
                                                            AND cac14.codcli = c.codcli
                                                            AND cac14.codenv = dca.codenv
                                                            AND cac14.clase = 14
            LEFT OUTER JOIN clase_clientes_almacen_codigo                                ca14 ON ( ca14.id_cia = c.id_cia )
                                                                  AND ca14.clase = cac14.clase
                                                                  AND ca14.codigo = cac14.codigo
            LEFT OUTER JOIN clientes_almacen_clase                                       cac15 ON ( cac15.id_cia = c.id_cia )
                                                            AND cac15.codcli = c.codcli
                                                            AND cac15.codenv = dca.codenv
                                                            AND cac15.clase = 15
            LEFT OUTER JOIN clase_clientes_almacen_codigo                                ca15 ON ( ca15.id_cia = c.id_cia )
                                                                  AND ca15.clase = cac15.clase
                                                                  AND ca15.codigo = cac15.codigo
            LEFT OUTER JOIN clientes_almacen_clase                                       cac16 ON ( cac16.id_cia = c.id_cia )
                                                            AND cac16.codcli = c.codcli
                                                            AND cac16.codenv = dca.codenv
                                                            AND cac16.clase = 16
            LEFT OUTER JOIN clase_clientes_almacen_codigo                                ca16 ON ( ca16.id_cia = c.id_cia )
                                                                  AND ca16.clase = cac16.clase
                                                                  AND ca16.codigo = cac16.codigo
            LEFT OUTER JOIN clientes_almacen                                             ca ON ( ca.id_cia = c.id_cia )
                                                   AND ( ca.codcli = c.codcli )
                                                   AND ( ca.codenv = dca.codenv )
            LEFT OUTER JOIN articulos_glosa                                              agl ON ( agl.id_cia = c.id_cia )
                                                   AND agl.tipo = 2
                                                   AND agl.tipinv = a.tipinv
                                                   AND agl.codart = a.codart
            LEFT OUTER JOIN listaprecios                                                 lp ON ( lp.id_cia = c.id_cia )
                                               AND ( lp.vencom = 1 )
                                               AND ( c1.codtit = lp.codtit )
                                               AND ( lp.codpro = '00000000001' )
                                               AND ( lp.tipinv = d.tipinv )
                                               AND ( lp.codart = d.codart )
            LEFT OUTER JOIN documentos_cab_transportista                                 dct ON ( dct.id_cia = c.id_cia )
                                                                AND ( dct.numint = c.numint )
            LEFT OUTER JOIN vehiculos                                                    vh ON ( vh.id_cia = c.id_cia )
                                            AND ( vh.codveh = c.codveh )
            LEFT OUTER JOIN articulos_clase_alternativo                                  aca1 ON ( aca1.id_cia = c.id_cia )
                                                                AND aca1.tipinv = d.tipinv
                                                                AND aca1.codart = d.codart
                                                                AND aca1.clase = 1
                                                                AND aca1.codigo = d.codund
            LEFT OUTER JOIN companias_glosa                                              gfecab ON ( gfecab.id_cia = c.id_cia )
                                                      AND ( gfecab.item = 31 )
            LEFT OUTER JOIN companias_glosa                                              gfepie ON ( gfepie.id_cia = c.id_cia )
                                                      AND ( gfepie.item = 32 )
            LEFT OUTER JOIN situacion                                                    s2 ON ( s2.id_cia = c.id_cia )
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN clase_clientes_almacen_codigo                                ccp14 ON ( ccp14.id_cia = c.id_cia )
                                                                   AND ccp14.clase = 14
                                                                   AND ccp14.codigo = CAST(substr(c.ubigeopar, 1, 2) AS VARCHAR(10))
            LEFT OUTER JOIN clase_clientes_almacen_codigo                                ccp15 ON ( ccp15.id_cia = c.id_cia )
                                                                   AND ccp15.clase = 15
                                                                   AND ccp15.codigo = CAST(substr(c.ubigeopar, 1, 4) AS VARCHAR(10))
            LEFT OUTER JOIN clase_clientes_almacen_codigo                                ccp16 ON ( ccp16.id_cia = c.id_cia )
                                                                   AND ccp16.clase = 16
                                                                   AND ccp16.codigo = c.ubigeopar
        WHERE
            ( c.id_cia = pin_id_cia )
            AND ( c.numint = pin_numint )
        ORDER BY
            c.tipdoc,
            c.numint,
            d.numite;

    BEGIN
        FOR j IN cur_sp_re_abre_qryformatos_guiaremision LOOP
            registro.tipdoc := j.tipdoc;
            registro.nomdoc := j.nomdoc;
            registro.numint := j.numint;
            registro.id := j.id; --CHAR,
            registro.series := j.series;
            registro.numdoc := j.numdoc;
            registro.femisi := j.femisi;
            registro.destin := j.destin;
            registro.codcli := j.codcli;
            registro.razonc := j.razonc;
            registro.direc1 := j.direc1;
            registro.ruc := j.ruc;
            registro.tipcam := j.tipcam;
            registro.tipmon := j.tipmon;
            registro.codven := j.codven;
            registro.numite := j.numite;
            registro.positi := j.positi;
            registro.tipinv := j.tipinv;
            registro.codart := j.codart;
            registro.obsdet := j.obsdet;
            registro.codund := j.codund;
            registro.cantid := j.cantid;
            registro.cantidbase := j.cantidbase;
            registro.canref := j.canref;
            registro.preuni := j.preuni;--
            registro.importe_bruto := j.importe_bruto;
            registro.importe := j.importe;
            registro.descdet := j.descdet;
            registro.opronumdoc := j.opronumdoc;
            registro.swacti := j.swacti;
            registro.piezas := j.piezas;
            registro.largo := j.largo;
            registro.ancho := j.ancho;
            registro.altura := j.altura;
            registro.etiqueta := j.etiqueta;
            registro.etiqueta2 := j.etiqueta2;
            registro.codunidet := j.codunidet;
            registro.tara := j.tara;
            registro.royos := j.royos;
            registro.pordes1 := j.pordes1;
            registro.pordes2 := j.pordes2;
            registro.pordes3 := j.pordes3;
            registro.pordes4 := j.pordes4;
            registro.dopnumdoc := j.dopnumdoc;
            registro.dopcargo := j.dopcargo;
            registro.dopnumite := j.dopnumite;
            registro.codalm := j.codalm;
            registro.monafedet := j.monafedet;
            registro.monigvdet := j.monigvdet;
            registro.lote := j.lote;
            registro.fvenci := j.fvenci;
            registro.nrocarrete := j.nrocarrete;
            registro.descue := j.descue;
            registro.totbru := j.totbru;
            registro.monafe := j.monafe;
            registro.monina := j.monina;
            registro.monneto := j.monneto;
            registro.monigv := j.monigv;
            registro.preven := j.preven;
            registro.porigv := j.porigv;--b
            registro.codsuc := j.codsuc;
            registro.incigv := j.incigv;
            registro.numped := j.numped;
            registro.codmot := j.codmot;
            registro.situac := j.situac;
            registro.obscab := j.obscab;
            registro.fentreg := j.fentreg;
            registro.codarea := j.codarea;
            registro.coduso := j.coduso;
            registro.totcan := j.totcan;
            registro.codenv := j.codenv;
            registro.horing := j.horing;
            registro.fecter := j.fecter;
            registro.horter := j.horter;
            registro.codtec := j.codtec;
            registro.opnumdoc := j.opnumdoc;
            registro.ordcom := j.ordcom;
            registro.fordcom := j.fordcom;
            registro.guiarefe := j.guiarefe;
            registro.desenv01 := j.desenv01;
            registro.desenv02 := j.desenv02;
            registro.marcas := j.marcas;
            registro.presen := j.presen;
            registro.codsec := j.codsec;
            registro.facpro := j.facpro;
            registro.ffacpro := j.ffacpro;
            registro.numvale := j.numvale;
            registro.fecvale := j.fecvale;
            registro.desnetx := j.desnetx;
            registro.despreven := j.despreven;
            registro.desfle := j.desfle;
            registro.flete := j.flete;
            registro.desseg := j.desseg;
            registro.seguro := j.seguro;
            registro.desgasa := j.desgasa;
            registro.gasadu := j.gasadu;
            registro.desart := j.desart;
            registro.codbar := j.codbar;
            registro.coddesart := j.coddesart;
            registro.codlin := j.codlin;
            registro.faccon := j.faccon;
            registro.consto := j.consto;
            registro.peslar := j.peslar;
            registro.pesdet := j.pesdet;
            registro.pescable := j.pescable;
            registro.taraadic := j.taraadic;
            registro.despagven := j.despagven;
            registro.enctacte := j.enctacte;
            registro.diaven := j.diaven;
            registro.dessuc := j.dessuc;
            registro.dissuc := j.dissuc;
            registro.dircli1 := j.dircli1;
            registro.dircli2 := j.dircli2;
            registro.emailcli := j.emailcli;
            registro.faxcli := j.faxcli;
            registro.tlfcli := j.tlfcli;
            registro.dident := j.dident;
            registro.tident := j.tident;
            registro.desven := j.desven;
            registro.comiven := j.comiven;
            registro.codvendedor := j.codvendedor;
            registro.simbolo := j.simbolo;
            registro.desmon := j.desmon;
            registro.codtra := j.codtra;
            registro.swdattra := j.swdattra;
            registro.razonctra := j.razonctra;
            registro.destra := j.destra;
            registro.dirtra := j.dirtra;
            registro.ructra := j.ructra;
            registro.licenciatra := j.licenciatra;
            registro.placatra := j.placatra;
            registro.certiftra := j.certiftra;
            registro.fonotra := j.fonotra;
            registro.desveh := j.desveh;
            registro.tipoveh := j.tipoveh;
            registro.marcaveh := j.marcaveh;
            registro.placaveh := j.placaveh;
            registro.certifveh := j.certifveh;
            registro.observveh := j.observveh;
            registro.razonctra2 := j.razonctra2;
            registro.destra2 := j.destra2;
            registro.dirtra2 := j.dirtra2;
            registro.ructra2 := j.ructra2;
            registro.punpartra2 := j.punpartra2;
            registro.licenctra2 := j.licenctra2;
            registro.placaveh2 := j.placaveh2;
            registro.desmot := j.desmot;
            registro.stockk001 := j.stockk001;
            registro.saldok001 := j.saldok001;
            registro.desenval := j.desenval;
            registro.direnv1 := j.direnv1;
            registro.direnv2 := j.direnv2;
            registro.nrodni := j.nrodni;
            registro.colorart := j.colorart;
            registro.desglosa := j.desglosa;
            registro.skuventas := j.skuventas;
            registro.glosxdes := j.glosxdes;
            registro.ocseries := j.ocseries;
            registro.ocnumdoc := j.ocnumdoc;
            registro.ocdesdoc := j.ocdesdoc;
            registro.ocabrdoc := j.ocabrdoc;
            registro.codcalid := j.codcalid;
            registro.dcalidad := j.dcalidad;
            registro.acalidad := j.acalidad;
            registro.codcolor := j.codcolor;
            registro.dcolor := j.dcolor;
            registro.desfam := j.desfam;
            registro.deslin := j.deslin;
            registro.desmod := j.desmod;
            registro.codubica := j.codubica;
            registro.valundaltven := j.valundaltven;
            registro.ubigeo := j.ubigeo;
            registro.ubigeo_b := j.ubigeo_b;
            registro.ubigeo_destino_b := j.ubigeo_destino_b;
            registro.fecha_dcorcom := j.fecha_dcorcom;
            registro.numero_dcorcom := j.numero_dcorcom;
            registro.contacto_dcorcom := j.contacto_dcorcom;
            registro.pesnet := j.pesnet;
            registro.ubigeodes_partida_a := j.ubigeodes_partida_a;
            registro.ubigeodes_partida_b := j.ubigeodes_partida_b;
            registro.ubigeo_partida := j.ubigeo_partida;
            registro.ubigeo_llegada := j.ubigeo_llegada;
            registro.direccpar := j.direccpar;
            registro.ubigeopar := j.ubigeopar;
            registro.tidentra := j.tidentra;
            registro.tidentconductor := j.tidentconductor;
            registro.destidentconductor := j.destidentconductor;
            registro.didentconductor := j.didentconductor;
            registro.placavehiculo := j.placavehiculo;
            registro.glosagfecab := j.glosagfecab;
            registro.glosagfepie := j.glosagfepie;
            registro.dessit := j.dessit;
            registro.aliassit := j.aliassit;
            registro.proyec := j.proyec;
            registro.abrunidad := j.abrunidad;
            PIPE ROW ( registro );
        END LOOP;
    END sp_re_abre;

END;

/
