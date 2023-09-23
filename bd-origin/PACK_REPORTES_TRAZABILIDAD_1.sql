--------------------------------------------------------
--  DDL for Package Body PACK_REPORTES_TRAZABILIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_REPORTES_TRAZABILIDAD" AS

    FUNCTION sp_factura (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_factura
        PIPELINED
    AS
        v_table datatable_factura;
    BEGIN
        SELECT
            c.id_cia,
            c.tipdoc                         AS tipdoc,
            dc.descri                        AS nomdoc,
            c.numint                         AS numint,
            d.numite                         AS numite,
            c.series                         AS series,
            c.numdoc                         AS numdoc,
            c.femisi                         AS femisi,
            c.codcli                         AS codcli,
            c.razonc                         AS razonc,
            c.direc1                         AS direc1,
            c.codsuc,
            c.ruc                            AS ruc,
            c1.direc1                        AS dircli1,
            c1.direc2                        AS dircli2,
            c1.telefono                      AS tlfcli,
            c1.fax                           AS faxcli,
            c1.dident                        AS dident,
            c.tident                         AS tident_cab,
            i.descri                         AS destident,
            i.abrevi                         AS abrtident,
            ct.nrodni                        AS nrodni,
            c.guiarefe                       AS guiarefe,
            c.almdes                         AS codalmdes,
            ald.descri                       AS desalmdes,
            ald.abrevi                       AS abralmdes,
            c.marcas                         AS marcas,
            c.presen                         AS presen,
            c.codsec                         AS codsec,
            c.facpro                         AS facpro,
            c.ffacpro                        AS ffacpro,
            c.codven                         AS codven,
            c.observ                         AS obscab,
--            c.observ,
            c.tipcam                         AS tipcam,
            c.tipmon                         AS tipmon,
            c.totbru                         AS totbru,
            c.desesp                         AS desesp,
            nvl(c.descue, 0)                 AS descue,
            c.monafe                         AS monafe,
            CASE
                WHEN ( c.destin = 2
                       AND c.monina > 0 )
                     OR ( c1.codtpe <> 3
                          AND c22.codigo = 'S' ) THEN
                    CAST(0 AS NUMERIC(12, 2))
                ELSE
                    c.monina
            END                              AS monina,
            c.monexo                         AS monexo,
            c.monafe + c.monina              AS monneto,
            c.monigv                         AS monigv,
            (
                CASE
                    WHEN ( mt16.valor IS NULL )
                         OR ( upper(mt16.valor) <> 'S' ) THEN
                        c.preven
                    ELSE
                        CAST(0 AS NUMERIC(12, 2))
                END
            )                                AS preven,
            (
                CASE
                    WHEN ( dct4.vreal IS NULL ) THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct4.vreal
                END
            )                                AS percep,
            (
                CASE
                    WHEN ( mt16.valor IS NULL )
                         OR ( upper(mt16.valor) <> 'S' ) THEN
                        c.preven
                    ELSE
                        CAST(0 AS NUMERIC(12, 2))
                END
            ) + (
                CASE
                    WHEN ( dct4.vreal IS NULL ) THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct4.vreal
                END
            )                                AS totpag,
            mt19.valor                       AS relcossalprod,
            c.flete                          AS flete,
            c.seguro                         AS seguro,
            c.porigv                         AS porigv,
            c.comisi                         AS comiven,
            c.codmot                         AS codmot,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                              AS numped,
            cv.despag                        AS despagven,
            cvc.valor                        AS enctacte,
            c.ordcom                         AS ordcom,
            c.fordcom                        AS fordcom,
            m1.simbolo                       AS simbolo,
            m1.desmon                        AS desmon,
            c.opnumdoc                       AS opnumdoc,
            c.horing                         AS horing,
            c.fecter                         AS fecter,
            c.horter                         AS horter,
            c.desnetx                        AS desnetx,
            c.despreven                      AS despreven,
            c.desfle                         AS desfle,
            c.desseg                         AS desseg,
            c.desgasa                        AS desgasa,
            c.gasadu                         AS gasadu,
            c.situac                         AS situac,
            c.destin                         AS destin,
            c.id                             AS id,
            mt.desmot                        AS desmot,
            mt.docayuda                      AS docayuda,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                    'S'
                ELSE
                    'N'
            END                              AS swdocpercep,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                        ccc.codigo
                ELSE
                    CAST('0.00' AS VARCHAR(10))
            END
            || ' %'                          AS porpercep,
            (
                SELECT
                    sp_exonerado_a_igv(c.id_cia, 'A', c.codcli, c.numint)
                FROM
                    dual
            )                                AS exoimp,
            cv.diaven                        AS diaven,
            s1.sucursal                      AS dessuc,
            s1.nomdis                        AS dissuc,
            v1.desven                        AS desven,
            dca.direc1                       AS desenv01,
            dca.direc2                       AS desenv02,
            d.codalm                         AS codalm,
            al.descri                        AS desalm,
            d.tipinv                         AS tipinv,
            ti.dtipinv                       AS tipoinventario,
            d.codart                         AS codart,
--            CASE
--                WHEN c33.codigo <> 'S' THEN
--                    a.descri
--                ELSE
--                    CASE
--                        WHEN lpa33.desart <> '' THEN
--                                lpa33.desart
--                        ELSE
--                            CASE
--                                WHEN lp33.desart <> '' THEN
--                                            lp33.desart
--                                ELSE
--                                    a.descri
--                            END
--                    END
--            END                              AS desart,
            CASE
                WHEN c33.codigo != 'S' THEN
                    a.descri
                ELSE
                    CASE
                        WHEN lpa33.desart != '' THEN
                                lpa33.desart
                        ELSE
                            CASE
                                WHEN lp33.desart IS NOT NULL
                                     AND length(lp33.desart) > 0 THEN
                                            lp33.desart
                                ELSE
                                    a.descri
                            END
                    END
            END                              AS desart,
            a.faccon                         AS faccon,
            a.consto                         AS consto,
            d.largo * a.faccon               AS peslar,
            ( d.cantid * a.faccon ) + CAST(
                CASE
                    WHEN cc2.abrevi IS NULL THEN
                        CAST('0' AS VARCHAR(10))
                    ELSE
                        cc2.abrevi
                END
            AS NUMERIC(16,
     5))                              AS pesdet,
            cc2.abrevi                       AS taraadic,
            a.codart
            || ' '
            || a.descri                      AS coddesart,
            agl.observ                       AS desglosa,
--            d.numite,
            d.cantid                         AS cantid,
            d.canref                         AS canref,
            d.piezas                         AS piezas,
            d.tara                           AS tara,
            d.largo                          AS largo,
            d.etiqueta                       AS etiqueta,
            d.etiqueta2                      AS etiqueta2,
            a.coduni                         AS codund,
            d.codadd01                       AS codcalid,
            d.codadd02                       AS codcolor,
            d.opronumdoc                     AS opronumdoc,
            d.opnumdoc                       AS dopnumdoc,
            d.opcargo                        AS dopcargo,
            d.opnumite                       AS dopnumite,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.preuni * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.preuni
            END                              AS preuni,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.importe_bruto * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe_bruto
            END                              AS importe_bruto,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.importe * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe
            END                              AS importe,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    ( d.importe_bruto - d.importe ) * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe_bruto - d.importe
            END                              AS descdet,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    ( d.importe /
                      CASE
                          WHEN d.cantid IS NULL
                               OR d.cantid = 0 THEN
                                1
                          ELSE
                              d.cantid
                      END
                    ) * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    ( d.importe /
                      CASE
                          WHEN d.cantid IS NULL
                               OR d.cantid = 0 THEN
                                1
                          ELSE
                              d.cantid
                      END
                    )
            END                              AS preuni02,
            d.preuni                         AS preunireal,
            d.importe                        AS importereal,
            d.codund                         AS codunidet,
            d.pordes1                        AS pordes1,
            d.pordes2                        AS pordes2,
            d.pordes3                        AS pordes3,
            d.pordes4                        AS pordes4,
            d.monafe + d.monina              AS monlinneto,
            d.monafe                         AS monafedet,
            d.monigv                         AS monigvdet,
            d.monisc                         AS moniscdet,
            d.monotr                         AS monotrdet,
--            d.largo * a.faccon               AS peslar,
            d.nrocarrete                     AS nrocarrete,
            d.acabado,
            d.chasis,
            d.motor,
            d.lote                           AS lote,
            d.fvenci                         AS fvenci,
            d.ancho                          AS ancho,
            CASE
                WHEN ( ( fap.vstrg IS NOT NULL )
                       AND ( upper(fap.vstrg) = 'S' )
                       AND ( ddp.vreal IS NOT NULL )
                       AND ( ddp.vreal > 0 ) ) THEN
                    '*'
                ELSE
                    ''
            END                              AS astpercep,
--            ( d.cantid * a.faccon ) + CAST(
--                CASE
--                    WHEN cc2.abrevi IS NULL THEN
--                        '0'
--                    ELSE
--                        cc2.abrevi
--                END
--            AS NUMERIC(16, 5))               AS pesdet,
            CASE
                WHEN d.cantid IS NULL
                     OR d.cantid = 0 THEN
                    0
                ELSE
                    ( d.monafe + d.monina ) / d.cantid
            END                              AS monuni,
            d.observ                         AS obsdet,
            ac3.codigo                       AS codfam,
            cc3.descri                       AS desfam,
            ac4.codigo                       AS codmod,
            cc4.descri                       AS desmod,
            ac5.codigo                       AS codlin,
            cc5.descri                       AS deslin,
            cl1.descri                       AS dcalidad,
            cl1.abrevi                       AS acalidad,
            cl2.codigo
            || '-'
            || cl2.descri                    AS dcolor,
--            cl2.descri                       AS dcolor2,
            cl2.descri                       AS color,
            CASE
                WHEN ac2.codigo IS NULL THEN
                    'N'
                ELSE
                    ac2.codigo
            END                              AS glosxdes,
            (
                SELECT
                    glosa
                FROM
                    companias_glosa
                WHERE
                        id_cia = c.id_cia
                    AND item = 24
            )                                AS gpiefac,
            gar.glosa                        AS glosagar,
            gap.glosa                        AS glosagap,
            gfp.glosa                        AS glosagfp,
            gfecab.glosa                     AS glosagfecab,
            gfepie.glosa                     AS glosagfepie,
            gfemen.glosa                     AS glosagfemen,
            (
                SELECT
                    glosa
                FROM
                    companias_glosa
                WHERE
                        id_cia = c.id_cia
                    AND item = 16
            )                                AS gdfis,
            cal.abrevi                       AS calidabrev,
            (
                CASE
                    WHEN aca1.vreal IS NULL THEN
                        0
                    ELSE
                        aca1.vreal
                END
            )                                AS valundaltven,
            ds.signvalue,
            nvl(c.acuenta, 0),
            CAST(
                CASE
                    WHEN(c.destin = 2
                         AND c.monina > 0)
                        OR(c1.codtpe <> 3
                           AND c22.codigo = 'S') THEN
                        c.monina
                    ELSE
                        CAST(0 AS NUMERIC(12, 2))
                END
            AS NUMERIC(16,
                 2))                         AS totexo,
            c.monisc                         AS totisc,
--            c.marcas                         AS marcas,
            CAST(0 AS NUMERIC(16, 2))        AS totoca,
            CAST(c.monotr AS NUMERIC(16, 2)) AS tototr,
            ( cc14.descri
              || ','
              || cc15.descri
              || ','
              || cc16.descri )                 AS ubigeo,
            ( cc16.descri
              || ' - '
              || cc15.descri
              || ' - '
              || cc14.descri )                 AS ubigeo_b,
            doc.fecha                        AS fecha_dcorcom,
            doc.numero                       AS numero_dcorcom,
            doc.contacto                     AS contacto_dcorcom,
            dcc11.codigo                     AS incoterm,
            ccc11.descri                     AS desincoterm,
            dcc12.vstrg                      AS destinofinal,
            dcc15.vstrg                      AS puertoembarque,
            dcc16.vstrg                      AS contenedor,
            dcc17.vstrg                      AS booking,
            dcc18.codigo                     AS certificado,
            ccc18.descri                     AS descertificado,
            cc10.descri                      AS pais,
            s2.dessit                        AS dessit,
            s2.alias                         AS aliassit,
--            c.pesnet,
            und.abrevi                       AS abrunidad,
            cac10.codigo                     AS direnv_pais,
            ca14.descri                      AS direnv_dep,
            ca15.descri                      AS direnv_pro,
            ca16.descri                      AS direnv_dis,
            c.direccpar                      AS direccpar,
            c.ubigeopar                      AS ubigeopar,
            cao14.descri                     AS dirpar_dep,
            cao15.descri                     AS dirpar_pro,
            cao16.descri                     AS dirpar_dis,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.destra
                ELSE
                    t1.razonc
            END                              AS razonctra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.chofer
                ELSE
                    t1.descri
            END                              AS destra,
            t1.domici                        AS dirtra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.ruc
                ELSE
                    t1.ruc
            END                              AS ructra,
            t1.punpar                        AS punpartra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.licenc
                ELSE
                    t1.licenc
            END                              AS licenciatra,
            t1.placa                         AS placatra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.certif
                ELSE
                    t1.certif
            END                              AS certiftra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.telef1
                ELSE
                    t1.telef1
            END                              AS fonotra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.desveh
                ELSE
                    vh.descri
            END                              AS desveh,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.tipo
                ELSE
                    vh.tipo
            END                              AS tipoveh,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.marca
                ELSE
                    vh.marca
            END                              AS marcaveh,
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
            END                              AS tidentra,
            CASE
                WHEN t1.chofer_tident IS NULL THEN
                    dct.chofer_tident
                ELSE
                    t1.chofer_tident
            END                              AS tidentconductor,
            CASE
                WHEN t1.chofer_tident IS NULL THEN
                    (
                        SELECT
                            descri
                        FROM
                            identidad
                        WHERE
                                id_cia = dct.id_cia
                            AND tident = dct.chofer_tident
                    )
                ELSE
                    (
                        SELECT
                            descri
                        FROM
                            identidad
                        WHERE
                                id_cia = t1.id_cia
                            AND tident = t1.chofer_tident
                    )
            END                              AS destidentconductor,
            CASE
                WHEN t1.chofer_dident IS NULL THEN
                    dct.chofer_dident
                ELSE
                    t1.chofer_dident
            END                              AS didentconductor,
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
            END                              AS placavehiculo,
            CAST((
                CASE
                    WHEN(mt34.valor IS NULL) THEN
                        CAST('0' AS VARCHAR(3))
                    ELSE
                        mt34.valor
                END
            ) AS SMALLINT)                   AS tiponcresunat,
            CAST((
                CASE
                    WHEN(mt35.valor IS NULL) THEN
                        CAST('0' AS VARCHAR(3))
                    ELSE
                        mt35.valor
                END
            ) AS SMALLINT)                   AS tipondebsunat,
            c.usuari,
            c.ucreac,
            df.formato
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab                c
            LEFT OUTER JOIN documentos                    dc ON dc.id_cia = c.id_cia--R
                                             AND ( dc.codigo = c.tipdoc )
                                             AND ( dc.series = c.series )
            LEFT OUTER JOIN cliente                       c1 ON c1.id_cia = c.id_cia--R
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN cliente_tpersona              ct ON ct.id_cia = c.id_cia--R
                                                   AND ( ct.codcli = c.codcli )
            LEFT OUTER JOIN identidad                     i ON i.id_cia = c1.id_cia--R
                                           AND ( i.tident = c1.tident )
            LEFT OUTER JOIN almacen                       ald ON ald.id_cia = c.id_cia--R
                                           AND ( ald.tipinv = 1 )
                                           AND ( ald.codalm = c.almdes )
            LEFT OUTER JOIN documentos_cab_clase          cc ON cc.id_cia = c.id_cia--R
                                                       AND ( cc.numint = c.numint )
                                                       AND ( cc.clase = 6 )
            LEFT OUTER JOIN documentos_cab_clase          dcc11 ON dcc11.id_cia = c.id_cia--R
                                                          AND ( dcc11.numint = c.numint )
                                                          AND ( dcc11.clase = 11 )
                                                          AND ( dcc11.codigo <> 'ND' )
            LEFT OUTER JOIN clase_documentos_cab_codigo   ccc11 ON ccc11.id_cia = dcc11.id_cia--R
                                                                 AND ( ccc11.clase = dcc11.clase )
                                                                 AND ( ccc11.codigo = dcc11.codigo )
                                                                 AND ( ccc11.tipdoc = c.tipdoc )
            LEFT OUTER JOIN documentos_cab_clase          dcc12 ON dcc12.id_cia = c.id_cia--R
                                                          AND ( dcc12.numint = c.numint )
                                                          AND ( dcc12.clase = 12 )
            LEFT OUTER JOIN documentos_cab_clase          dcc15 ON dcc15.id_cia = c.id_cia--R
                                                          AND ( dcc15.numint = c.numint )
                                                          AND ( dcc15.clase = 15 )
            LEFT OUTER JOIN documentos_cab_clase          dcc16 ON dcc16.id_cia = c.id_cia--R
                                                          AND ( dcc16.numint = c.numint )
                                                          AND ( dcc16.clase = 16 )
            LEFT OUTER JOIN documentos_cab_clase          dcc17 ON dcc17.id_cia = c.id_cia--R
                                                          AND ( dcc17.numint = c.numint )
                                                          AND ( dcc17.clase = 17 )
            LEFT OUTER JOIN documentos_cab_clase          dcc18 ON dcc18.id_cia = c.id_cia--R
                                                          AND ( dcc18.numint = c.numint )
                                                          AND ( dcc18.clase = 18 )
            LEFT OUTER JOIN clase_documentos_cab_codigo   ccc18 ON ccc18.id_cia = dcc18.id_cia--R
                                                                 AND ( ccc18.clase = dcc18.clase )
                                                                 AND ( ccc18.codigo = dcc18.codigo )
                                                                 AND ( ccc18.tipdoc = c.tipdoc )
            LEFT OUTER JOIN c_pago                        cv ON cv.id_cia = c.id_cia--R
                                         AND ( cv.codpag = c.codcpag )
                                         AND ( upper(cv.swacti) = 'S' )
            LEFT OUTER JOIN c_pago_clase                  cvc ON cvc.id_cia = c.id_cia--R
                                                AND ( cvc.codpag = c.codcpag )
                                                AND ( cvc.codigo = 1 )
            LEFT OUTER JOIN tmoneda                       m1 ON m1.id_cia = c.id_cia--R
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN sucursal                      s1 ON s1.id_cia = c.id_cia--R
                                           AND ( s1.codsuc = c.codsuc )
            LEFT OUTER JOIN motivos                       mt ON mt.id_cia = c.id_cia--R
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( c.tipdoc = mt.tipdoc )
            LEFT OUTER JOIN motivos_clase                 mt16 ON mt16.id_cia = c.id_cia--R
                                                  AND ( mt16.codmot = c.codmot )
                                                  AND ( mt16.id = c.id )
                                                  AND ( mt16.tipdoc = c.tipdoc )
                                                  AND ( mt16.codigo = 16 )
            LEFT OUTER JOIN motivos_clase                 mt19 ON mt19.id_cia = c.id_cia--R
                                                  AND ( mt19.codmot = c.codmot )
                                                  AND ( mt19.id = c.id )
                                                  AND ( mt19.tipdoc = c.tipdoc )
                                                  AND ( mt19.codigo = 19 )
            LEFT OUTER JOIN clase_clientes_almacen_codigo cao14 ON cao14.id_cia = c.id_cia--R
                                                                   AND cao14.clase = 14
                                                                   AND cao14.codigo = CAST(substr(c.ubigeopar, 1, 2) AS VARCHAR(10))
            LEFT OUTER JOIN clase_clientes_almacen_codigo cao15 ON cao15.id_cia = c.id_cia--R
                                                                   AND cao15.clase = 15
                                                                   AND cao15.codigo = CAST(substr(c.ubigeopar, 1, 4) AS VARCHAR(10))
            LEFT OUTER JOIN clase_clientes_almacen_codigo cao16 ON cao16.id_cia = c.id_cia--R
                                                                   AND cao16.clase = 16
                                                                   AND cao16.codigo = c.ubigeopar
            LEFT OUTER JOIN documentos_cab_almacen        dca ON c.id_cia = dca.id_cia--R
                                                          AND ( c.numint = dca.numint )
            LEFT OUTER JOIN clientes_almacen_clase        cac10 ON cac10.id_cia = c.id_cia---R
                                                            AND cac10.codcli = c.codcli
                                                            AND cac10.codenv = dca.codenv
                                                            AND cac10.clase = 10
            LEFT OUTER JOIN clientes_almacen_clase        cac14 ON cac14.id_cia = c.id_cia--R
                                                            AND cac14.codcli = c.codcli
                                                            AND cac14.codenv = dca.codenv
                                                            AND cac14.clase = 14
            LEFT OUTER JOIN clase_clientes_almacen_codigo ca14 ON ca14.id_cia = cac14.id_cia--R
                                                                  AND ca14.clase = cac14.clase
                                                                  AND ca14.codigo = cac14.codigo
            LEFT OUTER JOIN clientes_almacen_clase        cac15 ON cac15.id_cia = c.id_cia--R
                                                            AND cac15.codcli = c.codcli
                                                            AND cac15.codenv = dca.codenv
                                                            AND cac15.clase = 15
            LEFT OUTER JOIN clase_clientes_almacen_codigo ca15 ON ca15.id_cia = cac15.id_cia--R
                                                                  AND ca15.clase = cac15.clase
                                                                  AND ca15.codigo = cac15.codigo
            LEFT OUTER JOIN clientes_almacen_clase        cac16 ON cac16.id_cia = c.id_cia--R
                                                            AND cac16.codcli = c.codcli
                                                            AND cac16.codenv = dca.codenv
                                                            AND cac16.clase = 16
            LEFT OUTER JOIN clase_clientes_almacen_codigo ca16 ON ca16.id_cia = cac16.id_cia--R
                                                                  AND ca16.clase = cac16.clase
                                                                  AND ca16.codigo = cac16.codigo
            LEFT OUTER JOIN documentos_cab_ordcom         doc ON c.id_cia = doc.id_cia--R
                                                         AND ( c.numint = doc.numint )
            LEFT OUTER JOIN transportista                 t1 ON t1.id_cia = c.id_cia--R
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN documentos_cab_transportista  dct ON dct.id_cia = c.id_cia--R
                                                                AND ( dct.numint = c.numint )
            LEFT OUTER JOIN vehiculos                     vh ON vh.id_cia = c.id_cia--R
                                            AND ( vh.codveh = c.codveh )
            LEFT OUTER JOIN documentos_cab_clase          dct4 ON dct4.id_cia = c.id_cia--R
                                                         AND dct4.numint = c.numint
                                                         AND dct4.clase = 4
            LEFT OUTER JOIN documentos_cab_clase          dcp ON dcp.id_cia = c.id_cia--R
                                                        AND dcp.numint = c.numint
                                                        AND dcp.clase = 3
            LEFT OUTER JOIN cliente_clase                 ccc ON ccc.id_cia = c.id_cia--R
                                                 AND ( ccc.tipcli = 'A' )
                                                 AND ( ccc.codcli = c.codcli )
                                                 AND ( ccc.clase = 23 )
            LEFT OUTER JOIN cliente_clase                 c33 ON c33.id_cia = c.id_cia--R
                                                 AND ( c33.tipcli = 'A' )
                                                 AND ( c33.codcli = c.codcli )
                                                 AND ( c33.clase = 33 )
            LEFT OUTER JOIN cliente_clase                 c10 ON c10.id_cia = c.id_cia--R
                                                 AND ( c10.tipcli = 'A' )
                                                 AND ( c10.codcli = c.codcli )
                                                 AND ( c10.clase = 10 )
                                                 AND ( c10.codigo <> 'ND' )
            LEFT OUTER JOIN clase_cliente_codigo          cc10 ON cc10.id_cia = c.id_cia--R
                                                         AND cc10.clase = c10.clase
                                                         AND cc10.codigo = c10.codigo
                                                         AND cc10.tipcli = c10.tipcli
            LEFT OUTER JOIN cliente_clase                 c14 ON c14.id_cia = c.id_cia--R
                                                 AND ( c14.tipcli = 'A' )
                                                 AND ( c14.codcli = c.codcli )
                                                 AND ( c14.clase = 14 )
                                                 AND ( c14.codigo <> 'ND' )
            LEFT OUTER JOIN clase_cliente_codigo          cc14 ON cc14.id_cia = c14.id_cia--R
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase                 c15 ON c15.id_cia = c.id_cia--R
                                                 AND ( c15.tipcli = 'A' )
                                                 AND ( c15.codcli = c.codcli )
                                                 AND ( c15.clase = 15 )
                                                 AND ( c15.codigo <> 'ND' )
            LEFT OUTER JOIN clase_cliente_codigo          cc15 ON cc15.id_cia = c15.id_cia--R
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase                 c16 ON c16.id_cia = c.id_cia--R
                                                 AND ( c16.tipcli = 'A' )
                                                 AND ( c16.codcli = c.codcli )
                                                 AND ( c16.clase = 16 )
                                                 AND ( c16.codigo <> 'ND' )
            LEFT OUTER JOIN clase_cliente_codigo          cc16 ON cc16.id_cia = c16.id_cia--R
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN cliente_clase                 c22 ON c22.id_cia = c.id_cia--RR
                                                 AND c22.tipcli = 'A'
                                                 AND c22.codcli = c.codcli
                                                 AND c22.clase = 22
                                                 AND NOT ( c22.codigo = 'ND' )
            LEFT OUTER JOIN vendedor                      v1 ON v1.id_cia = c.id_cia--R
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN factor                        far ON far.id_cia = c.id_cia--R
                                          AND ( far.codfac = 331 )
            LEFT OUTER JOIN factor                        fap ON fap.id_cia = c.id_cia--R
                                          AND ( fap.codfac = 332 )
            LEFT OUTER JOIN companias_glosa               gar ON gar.id_cia = c.id_cia
                                                   AND ( far.vstrg IS NOT NULL )
                                                   AND ( upper(far.vstrg) = 'S' )
                                                   AND ( gar.item = 15 )
            LEFT OUTER JOIN companias_glosa               gap ON gap.id_cia = c.id_cia
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( gap.item = 13 )
            LEFT OUTER JOIN companias_glosa               gfp ON gfp.id_cia = c.id_cia
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( dcp.codigo IS NOT NULL )
                                                   AND ( upper(dcp.codigo) = 'S' )
                                                   AND ( gfp.item = 14 )
            LEFT OUTER JOIN companias_glosa               gfecab ON ( gfecab.id_cia = c.id_cia )--R
                                                      AND ( gfecab.item = 31 )
            LEFT OUTER JOIN companias_glosa               gfepie ON ( gfepie.id_cia = c.id_cia )--R
                                                      AND ( gfepie.item = 32 )
            LEFT OUTER JOIN companias_glosa               gfemen ON ( gfemen.id_cia = c.id_cia )--R
                                                      AND ( gfemen.item = 33 )
            LEFT OUTER JOIN documentos_det                d ON d.id_cia = c.id_cia--R
                                                AND ( d.numint = c.numint )
            LEFT OUTER JOIN documentos_det_clase          ddp ON ddp.id_cia = d.id_cia--R
                                                        AND ( ddp.numint = d.numint )
                                                        AND ( ddp.numite = d.numite )
                                                        AND ( ddp.clase = 50 )
            LEFT OUTER JOIN almacen                       al ON al.id_cia = d.id_cia--R
                                          AND ( al.tipinv = d.tipinv )
                                          AND ( al.codalm = d.codalm )
            LEFT OUTER JOIN articulos                     a ON a.id_cia = d.id_cia--R
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN listaprecios                  lp33 ON lp33.id_cia = c1.id_cia--R
                                                 AND lp33.vencom = 1
                                                 AND lp33.codtit = c1.codtit
                                                 AND lp33.tipinv = d.tipinv
                                                 AND lp33.codart = d.codart
            LEFT OUTER JOIN listaprecios_alternativa      lpa33 ON lpa33.id_cia = c1.id_cia--R
                                                              AND lpa33.vencom = 1
                                                              AND lpa33.codtit = c1.codtit
                                                              AND lpa33.tipinv = d.tipinv
                                                              AND lpa33.codart = d.codart
                                                              AND lpa33.codadd01 = d.codadd01
                                                              AND lpa33.codadd02 = d.codadd02
            LEFT OUTER JOIN articulos_glosa               agl ON agl.id_cia = d.id_cia--R
                                                   AND ( agl.tipo = 2 )
                                                   AND ( agl.tipinv = d.tipinv )
                                                   AND ( agl.codart = d.codart )
            LEFT OUTER JOIN articulos_clase               ac1 ON ac1.id_cia = d.id_cia--R
                                                   AND ( ac1.tipinv = d.tipinv )
                                                   AND ( ac1.codart = d.codart )
                                                   AND ( ac1.clase = 81 )
            LEFT OUTER JOIN articulos_clase               ac2 ON ac2.id_cia = d.id_cia--R
                                                   AND ( ac2.tipinv = d.tipinv )
                                                   AND ( ac2.codart = d.codart )
                                                   AND ( ac2.clase = 87 )
            LEFT OUTER JOIN articulos_clase               ac3 ON ac3.id_cia = d.id_cia--R
                                                   AND ( ac3.tipinv = d.tipinv )
                                                   AND ( ac3.codart = d.codart )
                                                   AND ( ac3.clase = 2 )
            LEFT OUTER JOIN articulos_clase               ac4 ON ac4.id_cia = d.id_cia--R
                                                   AND ( ac4.tipinv = d.tipinv )
                                                   AND ( ac4.codart = d.codart )
                                                   AND ( ac4.clase = 51 )
            LEFT OUTER JOIN articulos_clase               ac5 ON ac5.id_cia = d.id_cia--R
                                                   AND ( ac5.tipinv = d.tipinv )
                                                   AND ( ac5.codart = d.codart )
                                                   AND ( ac5.clase = 3 )
            LEFT OUTER JOIN clase_codigo                  cc2 ON cc2.id_cia = ac1.id_cia--R
                                                AND ( cc2.tipinv = ac1.tipinv )
                                                AND ( cc2.clase = ac1.clase )
                                                AND ( cc2.codigo = ac1.codigo )
            LEFT OUTER JOIN clase_codigo                  cc3 ON cc3.id_cia = ac3.id_cia--R
                                                AND ( cc3.tipinv = ac3.tipinv )
                                                AND ( cc3.clase = ac3.clase )
                                                AND ( cc3.codigo = ac3.codigo )
            LEFT OUTER JOIN clase_codigo                  cc4 ON cc4.id_cia = ac4.id_cia--R
                                                AND ( cc4.tipinv = ac4.tipinv )
                                                AND ( cc4.clase = ac4.clase )
                                                AND ( cc4.codigo = ac4.codigo )
            LEFT OUTER JOIN clase_codigo                  cc5 ON cc5.id_cia = ac5.id_cia--R
                                                AND ( cc5.tipinv = ac5.tipinv )
                                                AND ( cc5.clase = ac5.clase )
                                                AND ( cc5.codigo = ac5.codigo )
            LEFT OUTER JOIN cliente_articulos_clase       cl1 ON cl1.id_cia = a.id_cia--R
                                                           AND ( cl1.tipcli = 'B' )
                                                           AND ( cl1.codcli = a.codprv )
                                                           AND ( cl1.clase = 1 )
                                                           AND ( cl1.codigo = d.codadd01 )
            LEFT OUTER JOIN cliente_articulos_clase       cl2 ON cl2.id_cia = a.id_cia--R
                                                           AND ( cl2.tipcli = 'B' )
                                                           AND ( cl2.codcli = a.codprv )
                                                           AND ( cl2.clase = 2 )
                                                           AND ( cl2.codigo = d.codadd02 )
            LEFT OUTER JOIN calidad                       cal ON cal.id_cia = d.id_cia--R
                                           AND ( cal.codigo = d.codadd01 )
            LEFT OUTER JOIN articulos_clase_alternativo   aca1 ON aca1.id_cia = d.id_cia--R
                                                                AND aca1.tipinv = d.tipinv
                                                                AND aca1.codart = d.codart
                                                                AND aca1.clase = 1
                                                                AND aca1.codigo = d.codund
            LEFT OUTER JOIN documentos_cab_envio_sunat    ds ON ds.id_cia = c.id_cia--R
                                                             AND ( ds.numint = c.numint )
            LEFT OUTER JOIN situacion                     s2 ON s2.id_cia = c.id_cia--R
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN unidad                        und ON und.id_cia = d.id_cia--R
                                          AND und.coduni = d.codund
            LEFT OUTER JOIN t_inventario                  ti ON ti.id_cia = d.id_cia--R
                                               AND ti.tipinv = d.tipinv
            LEFT OUTER JOIN motivos_clase                 mt34 ON mt34.id_cia = c.id_cia--R
                                                  AND ( mt34.codmot = c.codmot )
                                                  AND ( mt34.id = c.id )
                                                  AND ( mt34.tipdoc = c.tipdoc )
                                                  AND ( mt34.codigo = 34 )
            LEFT OUTER JOIN motivos_clase                 mt35 ON mt35.id_cia = c.id_cia---R
                                                  AND ( mt35.codmot = c.codmot )
                                                  AND ( mt35.id = c.id )
                                                  AND ( mt35.tipdoc = c.tipdoc )
                                                  AND ( mt35.codigo = 35 )
            LEFT OUTER JOIN documentos_formatos           df ON df.tipdoc = dc.codigo
                                                      AND df.item = nvl(dc.tipimp, 1)
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
--            c.tipdoc,
--            c.numint,
--            d.positi,
            d.numite ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_factura;

    FUNCTION sp_factura_groupby (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_factura
        PIPELINED
    AS
        v_table datatable_factura;
    BEGIN
        SELECT
            t.id_cia,
            t.tipdoc,
            t.nomdoc,
            t.numint,
            NULL, -- numite
            t.series,
            t.numdoc,
            t.femisi,
            t.codcli,
            t.razonc,
            t.direc1,
            t.codsuc,
            t.ruc,
            t.dircli1,
            t.dircli2,
            t.tlfcli,
            t.faxcli,
            t.dident,
            t.tident_cab,
            t.destident,
            t.abrtident,
            t.nrodni,
            t.guiarefe,
            t.codalmdes,
            t.desalmdes,
            t.abralmdes,
            t.marcas,
            t.presen,
            t.codsec,
            t.facpro,
            t.ffacpro,
            t.codven,
            t.obscab,
--            t.observ,
            t.tipcam,
            t.tipmon,
            t.totbru,
            t.desesp,
            t.descue,
            t.monafe,
            t.monina,
            t.monexo,
            t.monneto,
            t.monigv,
            t.preven,
            t.percep,
            t.totpag,
            t.relcossalprod,
            t.flete,
            t.seguro,
            t.porigv,
            t.comiven,
            t.codmot,
            t.numped,
            t.despagven,
            t.enctacte,
            t.ordcom,
            t.fordcom,
            t.simbolo,
            t.desmon,
            t.opnumdoc,
            t.horing,
            t.fecter,
            t.horter,
            t.desnetx,
            t.despreven,
            t.desfle,
            t.desseg,
            t.desgasa,
            t.gasadu,
            t.situac,
            t.destin,
            t.id,
            t.desmot,
            t.docayuda,
            t.swdocpercep,
            t.porpercep,
            t.exoimp,
            t.diaven,
            t.dessuc,
            t.dissuc,
            t.desven,
            t.desenv01,
            t.desenv02,
            t.codalm,
            t.desalm,
            t.tipinv,
            t.tipoinventario,
            t.codart,
            t.desart,
            NULL, --t.faccon,
            NULL, --t.consto,
            SUM(t.peslar),
            SUM(t.pesdet),
            NULL, --t.taraadic,
            t.coddesart,
            t.desglosa,
            SUM(t.cantid),
            SUM(t.canref),
            SUM(t.piezas),
            SUM(t.tara),
            NULL, --t.largo,
            NULL, --t.etiqueta,
            NULL, --t.etiqueta2,,
            t.codund,
            t.codcalid,
            t.codcolor,
            t.opronumdoc,
            t.dopnumdoc,
            NULL, --t.dopcargo,
            NULL, --t.dopnumite,
            t.preuni,
            SUM(t.importe_bruto),
            SUM(t.importe),
            SUM(t.descdet),
            t.preuni02,
            t.preunireal,
            SUM(t.importereal),
            t.codunidet,
            t.pordes1,
            t.pordes2,
            t.pordes3,
            t.pordes4,
            SUM(t.monlinneto),
            SUM(t.monafedet),
            SUM(t.monigvdet),
            SUM(t.moniscdet),
            SUM(t.monotrdet),
            NULL,--t.nrocarrete,
            t.acabado,
            t.chasis,
            t.motor,
            t.lote,
            t.fvenci,
            t.ancho,
            t.astpercep,
            t.monuni,
            NULL, --t.obsdet,
            t.codfan,
            t.desfan,
            t.codmod,
            t.desmod,
            t.codlin,
            t.deslin,
            t.dcalidad,
            t.acalidad,
            t.dcolor,
            t.color,
            t.glosxdes,
            t.gpiefac,
            t.glosagar,
            t.glosagab,
            t.glosagfp,
            t.glosagfecab,
            t.glosagfepie,
            t.glosagfemen,
            t.gdfis,
            t.calidabrev,
            t.valundaltven,
            t.signvalue,
            t.acuenta,
            t.totexo,
            t.totisc,
            t.totoca,
            t.tototr,
            t.ubigeo,
            t.ubigeo_b,
            t.fecha_dcorcom,
            t.numero_dcorcom,
            t.contacto_dcorcom,
            t.incoterm,
            t.desincoterm,
            t.destinofinal,
            t.puertoembarque,
            t.contenedor,
            t.booking,
            t.certificado,
            t.descertificado,
            t.pais,
            t.dessit,
            t.aliassit,
            t.abrunidad,
            t.direnv_pais,
            t.direnv_dep,
            t.direnv_pro,
            t.direnv_dis,
            t.direccpar,
            t.ubigeopar,
            t.dirpar_dep,
            t.dirpar_pro,
            t.dirpar_dis,
            t.razonctra,
            t.destra,
            t.dirtra,
            t.ructra,
            t.punpartra,
            t.licenciatra,
            t.placatra,
            t.certiftra,
            t.fonotra,
            t.desveh,
            t.tipoveh,
            t.marcaveh,
            t.tidentra,
            t.tidentconductor,
            t.destidentconductor,
            t.didentconductor,
            t.placavehiculo,
            t.tiponcresunat,
            t.tipondebsunat,
            t.uactua,
            t.ucreac,
            t.formato
        BULK COLLECT
        INTO v_table
        FROM
            pack_reportes_trazabilidad.sp_factura(pin_id_cia, pin_numint) t
        GROUP BY
            t.id_cia,
            t.tipdoc,
            t.nomdoc,
            t.numint,
            NULL, -- numite
            t.series,
            t.numdoc,
            t.femisi,
            t.codcli,
            t.razonc,
            t.direc1,
            t.codsuc,
            t.ruc,
            t.dircli1,
            t.dircli2,
            t.tlfcli,
            t.faxcli,
            t.dident,
            t.tident_cab,
            t.destident,
            t.abrtident,
            t.nrodni,
            t.guiarefe,
            t.codalmdes,
            t.desalmdes,
            t.abralmdes,
            t.marcas,
            t.presen,
            t.codsec,
            t.facpro,
            t.ffacpro,
            t.codven,
            t.obscab,
--            t.observ,
            t.tipcam,
            t.tipmon,
            t.totbru,
            t.desesp,
            t.descue,
            t.monafe,
            t.monina,
            t.monexo,
            t.monneto,
            t.monigv,
            t.preven,
            t.percep,
            t.totpag,
            t.relcossalprod,
            t.flete,
            t.seguro,
            t.porigv,
            t.comiven,
            t.codmot,
            t.numped,
            t.despagven,
            t.enctacte,
            t.ordcom,
            t.fordcom,
            t.simbolo,
            t.desmon,
            t.opnumdoc,
            t.horing,
            t.fecter,
            t.horter,
            t.desnetx,
            t.despreven,
            t.desfle,
            t.desseg,
            t.desgasa,
            t.gasadu,
            t.situac,
            t.destin,
            t.id,
            t.desmot,
            t.docayuda,
            t.swdocpercep,
            t.porpercep,
            t.exoimp,
            t.diaven,
            t.dessuc,
            t.dissuc,
            t.desven,
            t.desenv01,
            t.desenv02,
            t.codalm,
            t.desalm,
            t.tipinv,
            t.tipoinventario,
            t.codart,
            t.desart,
            NULL, --t.faccon,
            NULL, --t.consto,
--            SUM(t.peslar),
--            SUM(t.pesdet),
            NULL, --t.taraadic,
            t.coddesart,
            t.desglosa,
--            SUM(t.cantid),
--            SUM(t.canref),
--            SUM(t.piezas),
--            SUM(t.tara),
            NULL, --t.largo,
            NULL, --t.etiqueta,
            NULL, --t.etiqueta2,,
            t.codund,
            t.codcalid,
            t.codcolor,
            t.opronumdoc,
            t.dopnumdoc,
            NULL, --t.dopcargo,
            NULL, --t.dopnumite,
            t.preuni,
--            SUM(t.importe_bruto),
--            SUM(t.importe),
--            SUM(t.descdet),
            t.preuni02,
            t.preunireal,
--            t.importereal,
            t.codunidet,
            t.pordes1,
            t.pordes2,
            t.pordes3,
            t.pordes4,
--            SUM(t.monlinneto),
--            SUM(t.monafedet),
--            SUM(t.monigvdet),
--            SUM(t.moniscdet),
--            SUM(t.monotrdet),
            NULL,--t.nrocarrete,
            t.acabado,
            t.chasis,
            t.motor,
            t.lote,
            t.fvenci,
            t.ancho,
            t.astpercep,
            t.monuni,
            NULL, --t.obsdet,
            t.codfan,
            t.desfan,
            t.codmod,
            t.desmod,
            t.codlin,
            t.deslin,
            t.dcalidad,
            t.acalidad,
            t.dcolor,
            t.color,
            t.glosxdes,
            t.gpiefac,
            t.glosagar,
            t.glosagab,
            t.glosagfp,
            t.glosagfecab,
            t.glosagfepie,
            t.glosagfemen,
            t.gdfis,
            t.calidabrev,
            t.valundaltven,
            t.signvalue,
            t.acuenta,
            t.totexo,
            t.totisc,
            t.totoca,
            t.tototr,
            t.ubigeo,
            t.ubigeo_b,
            t.fecha_dcorcom,
            t.numero_dcorcom,
            t.contacto_dcorcom,
            t.incoterm,
            t.desincoterm,
            t.destinofinal,
            t.puertoembarque,
            t.contenedor,
            t.booking,
            t.certificado,
            t.descertificado,
            t.pais,
            t.dessit,
            t.aliassit,
            t.abrunidad,
            t.direnv_pais,
            t.direnv_dep,
            t.direnv_pro,
            t.direnv_dis,
            t.direccpar,
            t.ubigeopar,
            t.dirpar_dep,
            t.dirpar_pro,
            t.dirpar_dis,
            t.razonctra,
            t.destra,
            t.dirtra,
            t.ructra,
            t.punpartra,
            t.licenciatra,
            t.placatra,
            t.certiftra,
            t.fonotra,
            t.desveh,
            t.tipoveh,
            t.marcaveh,
            t.tidentra,
            t.tidentconductor,
            t.destidentconductor,
            t.didentconductor,
            t.placavehiculo,
            t.tiponcresunat,
            t.tipondebsunat,
            t.uactua,
            t.ucreac,
            t.formato
        ORDER BY
            t.tipinv,
            t.codart,
            t.preuni,
            t.pordes1,
            t.pordes2,
            t.pordes3,
            t.pordes4,
            t.lote,
            t.fvenci;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_factura_groupby;

    FUNCTION sp_guiaremision (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_guiaremision
        PIPELINED
    AS
        v_table datatable_guiaremision;
    BEGIN
        SELECT
            c.id_cia,
            c.tipdoc,
            dc.descri                           AS nomdoc,
            c.numint,
            c.id,
            c.series,
            c.numdoc,
            c.femisi,
            nvl(to_char(dsm.factua, 'HH12:MI AM'),
                '00:00 XX')                     AS hemisi,
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
--            d.codund                            AS codunidet,
            CASE
                WHEN (
                    CASE
                        WHEN aca1.vreal IS NULL THEN
                            0
                        ELSE
                            aca1.vreal
                    END
                ) > 0 THEN
                    d.cantid * aca1.vreal
                ELSE
                    d.cantid
            END                                 AS cantid,
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
            d.opronumdoc,
            d.opnumdoc                          AS dopnumdoc,
            d.opcargo                           AS dopcargo,
            d.opnumite                          AS dopnumite,
            d.codalm,
            d.monafe                            AS monafedet,
            d.monigv                            AS monigvdet,
            d.lote                              AS lote,
            d.fvenci                            AS fvenci,
            d.nrocarrete                        AS nrocarrete,
            d.acabado                           AS acabado,
            d.chasis,
            d.motor,
            nvl(c.descue, 0),
            c.totbru,
            c.monafe,
            c.monina,
            c.monafe + c.monina                 AS monneto,
            c.monigv,
            c.preven,
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
                WHEN c33.codigo != 'S' THEN
                    a.descri
                ELSE
                    CASE
                        WHEN lpa33.desart != '' THEN
                                lpa33.desart
                        ELSE
                            CASE
                                WHEN lp33.desart IS NOT NULL
                                     AND length(lp33.desart) > 0 THEN
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
--            c.codtec,
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
            cc4.descri                          AS desfam,
            cc5.descri                          AS desmod,
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
                WHEN t1.chofer_tident IS NULL THEN
                    dct.chofer_tident
                ELSE
                    t1.chofer_tident
            END                                 AS tidentconductor,
            CASE
                WHEN t1.chofer_tident IS NULL THEN
                    (
                        SELECT
                            descri
                        FROM
                            identidad
                        WHERE
                                id_cia = dct.id_cia
                            AND tident = dct.chofer_tident
                    )
                ELSE
                    (
                        SELECT
                            descri
                        FROM
                            identidad
                        WHERE
                                id_cia = t1.id_cia
                            AND tident = t1.chofer_tident
                    )
            END                                 AS destidentconductor,
            CASE
                WHEN t1.chofer_dident IS NULL THEN
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
            und.abrevi                          AS abrunidad,
            ds.signvalue,
            df.formato
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab                c
            LEFT OUTER JOIN documentos_cab                cr ON cr.id_cia = c.id_cia
                                                 AND ( cr.numint = c.ordcomni )
            LEFT OUTER JOIN documentos_cab_envio_sunat    ds ON ds.id_cia = c.id_cia
                                                             AND ( ds.numint = c.numint )
            LEFT OUTER JOIN documentos_cab_ordcom         doc ON c.id_cia = doc.id_cia
                                                         AND ( c.numint = doc.numint )
            LEFT OUTER JOIN tdoccobranza                  tdr ON tdr.id_cia = cr.id_cia
                                                AND ( tdr.tipdoc = cr.tipdoc )
            LEFT OUTER JOIN documentos_cab_clase          cc ON cc.id_cia = c.id_cia
                                                       AND ( cc.numint = c.numint
                                                             AND cc.clase = 6 )
            LEFT OUTER JOIN documentos_det                d ON d.id_cia = c.id_cia
                                                AND ( d.numint = c.numint )
            LEFT OUTER JOIN unidad                        und ON und.id_cia = d.id_cia
                                          AND und.coduni = d.codund
            LEFT OUTER JOIN documentos                    dc ON dc.id_cia = c.id_cia
                                             AND ( dc.codigo = c.tipdoc )
                                             AND ( dc.series = c.series )
            LEFT OUTER JOIN articulos                     a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN cliente_articulos_clase       cl1 ON cl1.id_cia = a.id_cia
                                                           AND ( cl1.tipcli = 'B' )
                                                           AND ( cl1.codcli = a.codprv )
                                                           AND ( cl1.clase = 1 )
                                                           AND ( cl1.codigo = d.codadd01 )
            LEFT OUTER JOIN cliente_articulos_clase       cl2 ON cl2.id_cia = a.id_cia
                                                           AND ( cl2.tipcli = 'B' )
                                                           AND ( cl2.codcli = a.codprv )
                                                           AND ( cl2.clase = 2 )
                                                           AND ( cl2.codigo = d.codadd02 )
            LEFT OUTER JOIN articulos_clase               ac1 ON ac1.id_cia = d.id_cia
                                                   AND ( ac1.tipinv = d.tipinv
                                                         AND ac1.codart = d.codart
                                                         AND ac1.clase = 81 )
            LEFT OUTER JOIN articulos_clase               ac2 ON ac2.id_cia = d.id_cia
                                                   AND ( ac2.tipinv = d.tipinv
                                                         AND ac2.codart = d.codart
                                                         AND ac2.clase = 87 )
            LEFT OUTER JOIN articulos_clase               ac3 ON ac3.id_cia = d.id_cia
                                                   AND ( ac3.tipinv = d.tipinv
                                                         AND ac3.codart = d.codart
                                                         AND ac3.clase = 74 )
            LEFT OUTER JOIN clase_codigo                  cc3 ON cc3.id_cia = d.id_cia
                                                AND ( cc3.tipinv = d.tipinv
                                                      AND cc3.clase = ac3.clase
                                                      AND cc3.codigo = ac3.codigo )
            LEFT OUTER JOIN clase_codigo                  cc2 ON cc2.id_cia = ac1.id_cia
                                                AND ( cc2.tipinv = ac1.tipinv
                                                      AND cc2.clase = ac1.clase
                                                      AND cc2.codigo = ac1.codigo )
            LEFT OUTER JOIN articulos_clase               ac4 ON ac4.id_cia = d.id_cia
                                                   AND ( ac4.tipinv = d.tipinv
                                                         AND ac4.codart = d.codart
                                                         AND ac4.clase = 2 )
            LEFT OUTER JOIN clase_codigo                  cc4 ON cc4.id_cia = ac4.id_cia
                                                AND ( cc4.tipinv = ac4.tipinv
                                                      AND cc4.clase = ac4.clase
                                                      AND cc4.codigo = ac4.codigo )
            LEFT OUTER JOIN articulos_clase               ac5 ON ac5.id_cia = d.id_cia
                                                   AND ( ac5.tipinv = d.tipinv
                                                         AND ac5.codart = d.codart
                                                         AND ac5.clase = 51 )
            LEFT OUTER JOIN clase_codigo                  cc5 ON cc5.id_cia = ac5.id_cia
                                                AND ( cc5.tipinv = ac5.tipinv
                                                      AND cc5.clase = ac5.clase
                                                      AND cc5.codigo = ac5.codigo )
            LEFT OUTER JOIN c_pago                        cv ON cv.id_cia = c.id_cia
                                         AND ( cv.codpag = c.codcpag )
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN c_pago_clase                  cvc ON cvc.id_cia = c.id_cia
                                                AND ( cvc.codpag = c.codcpag )
                                                AND ( cvc.codigo = 1 )
            LEFT OUTER JOIN sucursal                      s1 ON s1.id_cia = c.id_cia
                                           AND ( s1.codsuc = c.codsuc )
            LEFT OUTER JOIN cliente                       c1 ON c1.id_cia = c.id_cia
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN cliente_clase                 c33 ON c33.id_cia = c.id_cia
                                                 AND ( c33.tipcli = 'A' )
                                                 AND ( c33.codcli = c.codcli )
                                                 AND ( c33.clase = 33 )
            LEFT OUTER JOIN cliente_clase                 c14 ON c14.id_cia = c.id_cia
                                                 AND ( c14.tipcli = 'A' )
                                                 AND ( c14.codcli = c.codcli )
                                                 AND ( c14.clase = 14 )
            LEFT OUTER JOIN clase_cliente_codigo          cc14 ON cc14.id_cia = c14.id_cia
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase                 c15 ON c15.id_cia = c.id_cia
                                                 AND ( c15.tipcli = 'A' )
                                                 AND ( c15.codcli = c.codcli )
                                                 AND ( c15.clase = 15 )
            LEFT OUTER JOIN clase_cliente_codigo          cc15 ON cc15.id_cia = c15.id_cia
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase                 c16 ON c16.id_cia = c.id_cia
                                                 AND ( c16.tipcli = 'A' )
                                                 AND ( c16.codcli = c.codcli )
                                                 AND ( c16.clase = 16 )
            LEFT OUTER JOIN clase_cliente_codigo          cc16 ON cc16.id_cia = c16.id_cia
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN listaprecios                  lp33 ON lp33.id_cia = c1.id_cia
                                                 AND lp33.vencom = 1
                                                 AND lp33.codtit = c1.codtit
                                                 AND lp33.tipinv = d.tipinv
                                                 AND lp33.codart = d.codart
            LEFT OUTER JOIN listaprecios_alternativa      lpa33 ON lpa33.id_cia = c1.id_cia
                                                              AND lpa33.vencom = 1
                                                              AND lpa33.codtit = c1.codtit
                                                              AND lpa33.tipinv = d.tipinv
                                                              AND lpa33.codart = d.codart
                                                              AND lpa33.codadd01 = d.codadd01
                                                              AND lpa33.codadd02 = d.codadd02
            LEFT OUTER JOIN cliente_tpersona              ct ON ct.id_cia = c.id_cia
                                                   AND ( ct.codcli = c.codcli )
            LEFT OUTER JOIN vendedor                      v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN tmoneda                       m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN transportista                 t1 ON ( t1.id_cia = c.id_cia
                                                  AND t1.codtra = c.codtra )
            LEFT OUTER JOIN transportista                 t2 ON ( t2.id_cia = c.id_cia
                                                  AND t2.codtra = c.codtec )
            LEFT OUTER JOIN motivos                       mt ON mt.id_cia = c.id_cia
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( mt.tipdoc = c.tipdoc )
            LEFT OUTER JOIN kardex001                     k ON k.id_cia = d.id_cia
                                           AND ( k.tipinv = d.tipinv )
                                           AND ( k.codart = d.codart )
                                           AND ( k.codalm = d.codalm )
                                           AND ( k.etiqueta = d.etiqueta )
            LEFT OUTER JOIN documentos_cab_almacen        dca ON ( c.id_cia = dca.id_cia
                                                            AND c.numint = dca.numint )
            LEFT OUTER JOIN clientes_almacen_clase        cac10 ON cac10.id_cia = c.id_cia
                                                            AND cac10.codcli = c.codcli
                                                            AND cac10.codenv = dca.codenv
                                                            AND cac10.clase = 10
            LEFT OUTER JOIN clientes_almacen_clase        cac14 ON cac14.id_cia = c.id_cia
                                                            AND cac14.codcli = c.codcli
                                                            AND cac14.codenv = dca.codenv
                                                            AND cac14.clase = 14
            LEFT OUTER JOIN clase_clientes_almacen_codigo ca14 ON ca14.id_cia = cac14.id_cia
                                                                  AND ca14.clase = cac14.clase
                                                                  AND ca14.codigo = cac14.codigo
            LEFT OUTER JOIN clientes_almacen_clase        cac15 ON cac15.id_cia = c.id_cia
                                                            AND cac15.codcli = c.codcli
                                                            AND cac15.codenv = dca.codenv
                                                            AND cac15.clase = 15
            LEFT OUTER JOIN clase_clientes_almacen_codigo ca15 ON ca15.id_cia = cac15.id_cia
                                                                  AND ca15.clase = cac15.clase
                                                                  AND ca15.codigo = cac15.codigo
            LEFT OUTER JOIN clientes_almacen_clase        cac16 ON cac16.id_cia = c.id_cia
                                                            AND cac16.codcli = c.codcli
                                                            AND cac16.codenv = dca.codenv
                                                            AND cac16.clase = 16
            LEFT OUTER JOIN clase_clientes_almacen_codigo ca16 ON ca16.id_cia = cac16.id_cia
                                                                  AND ca16.clase = cac16.clase
                                                                  AND ca16.codigo = cac16.codigo
            LEFT OUTER JOIN clientes_almacen              ca ON ca.id_cia = c.id_cia
                                                   AND ( ca.codcli = c.codcli )
                                                   AND ( ca.codenv = dca.codenv )
            LEFT OUTER JOIN articulos_glosa               agl ON agl.id_cia = a.id_cia
                                                   AND agl.tipo = 2
                                                   AND agl.tipinv = a.tipinv
                                                   AND agl.codart = a.codart
            LEFT OUTER JOIN listaprecios                  lp ON lp.id_cia = c1.id_cia
                                               AND ( lp.vencom = 1 )
                                               AND ( c1.codtit = lp.codtit )
                                               AND ( lp.codpro = '00000000001' )
                                               AND ( lp.tipinv = d.tipinv )
                                               AND ( lp.codart = d.codart )
            LEFT OUTER JOIN documentos_cab_transportista  dct ON dct.id_cia = c.id_cia
                                                                AND ( dct.numint = c.numint )
            LEFT OUTER JOIN vehiculos                     vh ON vh.id_cia = c.id_cia
                                            AND ( vh.codveh = c.codveh )
            LEFT OUTER JOIN articulos_clase_alternativo   aca1 ON aca1.id_cia = d.id_cia
                                                                AND aca1.tipinv = d.tipinv
                                                                AND aca1.codart = d.codart
                                                                AND aca1.clase = 1
                                                                AND aca1.codigo = d.codund
            LEFT OUTER JOIN companias_glosa               gfecab ON ( gfecab.id_cia = c.id_cia )
                                                      AND ( gfecab.item = 31 )
            LEFT OUTER JOIN companias_glosa               gfepie ON ( gfepie.id_cia = c.id_cia )
                                                      AND ( gfepie.item = 32 )
            LEFT OUTER JOIN situacion                     s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN clase_clientes_almacen_codigo ccp14 ON ccp14.id_cia = c.id_cia
                                                                   AND ccp14.clase = 14
                                                                   AND ccp14.codigo = CAST(substr(c.ubigeopar, 1, 2) AS VARCHAR(10))
            LEFT OUTER JOIN clase_clientes_almacen_codigo ccp15 ON ccp15.id_cia = c.id_cia
                                                                   AND ccp15.clase = 15
                                                                   AND ccp15.codigo = CAST(substr(c.ubigeopar, 1, 4) AS VARCHAR(10))
            LEFT OUTER JOIN clase_clientes_almacen_codigo ccp16 ON ccp16.id_cia = c.id_cia
                                                                   AND ccp16.clase = 16
                                                                   AND ccp16.codigo = c.ubigeopar
            LEFT OUTER JOIN documentos_situac_max         dsm ON dsm.id_cia = c.id_cia
                                                         AND dsm.numint = c.numint
                                                         AND dsm.situac = 'F'
            LEFT OUTER JOIN documentos_formatos           df ON df.tipdoc = dc.codigo
                                                      AND df.item = nvl(dc.tipimp, 1)
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
--            c.tipdoc,
--            c.numint,
            d.numite ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_guiaremision;

    FUNCTION sp_guiaremision_groupby (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_guiaremision
        PIPELINED
    AS
        v_table datatable_guiaremision;
    BEGIN
        SELECT
            t.id_cia,
            t.tipdoc,
            t.nomdoc,
            t.numint,
            t.id,
            t.series,
            t.numdoc,
            t.femisi,
            t.hemisi,
            t.destin,
            t.codcli,
            t.razonc,
            t.direc1,
            t.ruc,
            t.tipcam,
            t.tipmon,
            t.codven,
            NULL, --t.numite,
            NULL, --t.positi,
            t.tipinv,
            t.codart,
            NULL,--t.obsdet,
            t.codund,
            SUM(t.cantid),
            SUM(t.cantidbase),
            SUM(t.canref),
            t.preuni,
            SUM(t.importe_bruto),
            SUM(t.importe),
            SUM(t.descdet),
            t.swacti,
            SUM(t.piezas),
            NULL, --t.largo,
            NULL,--t.ancho,
            NULL, --altura,
            NULL, --t.etiqueta,
            NULL, -- etiqueta2,
            t.codunidet,
            NULL, --tara,
            SUM(t.royos),
            t.pordes1,
            t.pordes2,
            t.pordes3,
            t.pordes4,
            t.opronumdoc,
            t.dopnumdoc,
            NULL,--dopcargo
            NULL,--dopnumite
            t.codalm,
            SUM(t.monafedet),
            SUM(t.monigvdet),
            t.lote,
            t.fvenci,
            NULL,--t.nrocarrete,
            t.acabado,
            t.chasis,
            t.motor,
            t.descue,
            t.totbru,
            t.monafe,
            t.monina,
            t.monneto,
            t.monigv,
            t.preven,
            t.porigv,
            t.codsuc,
            t.incigv,
            t.numped,
            t.codmot,
            t.situac,
            t.obscab,
            t.fentreg,
            t.codarea,
            t.coduso,
            t.totcan,
            t.codenv,
            t.horing,
            t.fecter,
            t.horter,
            t.codtec,
            t.opnumdoc,
            t.ordcom,
            t.fordcom,
            t.guiarefe,
            t.desenv01,
            t.desenv02,
            t.marcas,
            t.presen,
            t.codsec,
            t.facpro,
            t.ffacpro,
            t.numvale,
            t.fecvale,
            t.desnetx,
            t.despreven,
            t.desfle,
            t.flete,
            t.desseg,
            t.seguro,
            t.desgasa,
            t.gasadu,
            t.desart,
            t.codbar,
            t.coddesart,
            t.codlin,
            NULL, --t.faccon,
            NULL, --t.consto,
            SUM(t.peslar),
            SUM(t.pesdet),
            NULL, --t.taraadic
            t.despagven,
            t.enctacte,
            t.diaven,
            t.dessuc,
            t.dissuc,
            t.dircli1,
            t.dircli2,
            t.emailcli,
            t.faxcli,
            t.tlfcli,
            t.dident,
            t.tident,
            t.desven,
            t.comiven,
--            t.codven,
            t.simbolo,
            t.desmon,
            t.codtra,
            t.swdattra,
            t.razonctra,
            t.destra,
            t.dirtra,
            t.ructra,
            t.punpartra,
            t.licenciatra,
            t.placatra,
            t.certiftra,
            t.fonotra,
            t.desveh,
            t.tipoveh,
            t.marcaveh,
            t.placaveh,
            t.certifveh,
            t.observveh,
            t.razonctra2,
            t.destra2,
            t.dirtra2,
            t.ructra2,
            t.punpartra2,
            t.licenctra2,
            t.placaveh2,
            t.desmot,
            SUM(t.stockk001),
            SUM(t.saldok001),
            t.desenval,
            t.direnv1,
            t.direnv2,
            t.nrodni,
            t.colorart,
            t.desglosa,
            t.skuventas,
            t.glosxdes,
            t.ocseries,
            t.ocnumdoc,
            t.ocdesdoc,
            t.ocabrdoc,
            t.codcalid,
            t.dcalidad,
            t.acalidad,
            t.codcolor,
            t.dcolor,
            t.desfam,
            t.desmod,
            t.valundaltven,
            t.ubigeo,
            t.ubigeo_b,
            t.ubigeo_destino_b,
            t.fecha_dcorcom,
            t.numero_dcorcom,
            t.contacto_dcorcom,
            t.pesnet,
            t.ubigeodes_partida_a,
            t.ubigeodes_partida_b,
            t.ubigeo_partida,
            t.ubigeo_llegada,
            t.direccpar,
            t.ubigeopar,
            t.tidentra,
            t.tidentconductor,
            t.destidentconductor,
            t.didentconductor,
            t.placavehiculo,
            t.glosagfecab,
            t.glosagfepie,
            t.dessit,
            t.aliassit,
            t.abrunidad,
            t.signvalue,
            t.formato
        BULK COLLECT
        INTO v_table
        FROM
            pack_reportes_trazabilidad.sp_guiaremision(pin_id_cia, pin_numint) t
        GROUP BY
            t.id_cia,
            t.tipdoc,
            t.nomdoc,
            t.numint,
            t.id,
            t.series,
            t.numdoc,
            t.femisi,
            t.hemisi,
            t.destin,
            t.codcli,
            t.razonc,
            t.direc1,
            t.ruc,
            t.tipcam,
            t.tipmon,
            t.codven,
            NULL, --t.numite,
            NULL, --t.positi,
            t.tipinv,
            t.codart,
            NULL,--t.obsdet,
            t.codund,
--            SUM(t.cantid),
--            SUM(t.cantidbase),
--            SUM(t.canref),
            t.preuni,
--            SUM(t.importe_bruto),
--            SUM(t.importe),
--            SUM(t.descdet),
            t.swacti,
--            SUM(t.piezas),
            NULL, --t.largo,
            NULL,--t.ancho,
            NULL, --altura,
            NULL, --t.etiqueta,
            NULL, -- etiqueta2,
            t.codunidet,
            NULL, --tara,
--            SUM(t.royos),
            t.pordes1,
            t.pordes2,
            t.pordes3,
            t.pordes4,
            t.opronumdoc,
            t.dopnumdoc,
            NULL,--dopcargo
            NULL,--dopnumite
            t.codalm,
--            SUM(t.monafedet),
--            SUM(t.monigvdet),
            t.lote,
            t.fvenci,
            NULL,--t.nrocarrete,
            t.acabado,
            t.chasis,
            t.motor,
            t.descue,
            t.totbru,
            t.monafe,
            t.monina,
            t.monneto,
            t.monigv,
            t.preven,
            t.porigv,
            t.codsuc,
            t.incigv,
            t.numped,
            t.codmot,
            t.situac,
            t.obscab,
            t.fentreg,
            t.codarea,
            t.coduso,
            t.totcan,
            t.codenv,
            t.horing,
            t.fecter,
            t.horter,
            t.codtec,
            t.opnumdoc,
            t.ordcom,
            t.fordcom,
            t.guiarefe,
            t.desenv01,
            t.desenv02,
            t.marcas,
            t.presen,
            t.codsec,
            t.facpro,
            t.ffacpro,
            t.numvale,
            t.fecvale,
            t.desnetx,
            t.despreven,
            t.desfle,
            t.flete,
            t.desseg,
            t.seguro,
            t.desgasa,
            t.gasadu,
            t.desart,
            t.codbar,
            t.coddesart,
            t.codlin,
            NULL, --t.faccon,
            NULL, --t.consto,
--            SUM(t.peslar),
--            SUM(t.pesdet),
            NULL, --t.taraadic
            t.despagven,
            t.enctacte,
            t.diaven,
            t.dessuc,
            t.dissuc,
            t.dircli1,
            t.dircli2,
            t.emailcli,
            t.faxcli,
            t.tlfcli,
            t.dident,
            t.tident,
            t.desven,
            t.comiven,
--            t.codven,
            t.simbolo,
            t.desmon,
            t.codtra,
            t.swdattra,
            t.razonctra,
            t.destra,
            t.dirtra,
            t.ructra,
            t.punpartra,
            t.licenciatra,
            t.placatra,
            t.certiftra,
            t.fonotra,
            t.desveh,
            t.tipoveh,
            t.marcaveh,
            t.placaveh,
            t.certifveh,
            t.observveh,
            t.razonctra2,
            t.destra2,
            t.dirtra2,
            t.ructra2,
            t.punpartra2,
            t.licenctra2,
            t.placaveh2,
            t.desmot,
--            SUM(t.stockk001),
--            SUM(t.saldok001),
            t.desenval,
            t.direnv1,
            t.direnv2,
            t.nrodni,
            t.colorart,
            t.desglosa,
            t.skuventas,
            t.glosxdes,
            t.ocseries,
            t.ocnumdoc,
            t.ocdesdoc,
            t.ocabrdoc,
            t.codcalid,
            t.dcalidad,
            t.acalidad,
            t.codcolor,
            t.dcolor,
            t.desfam,
            t.desmod,
            t.valundaltven,
            t.ubigeo,
            t.ubigeo_b,
            t.ubigeo_destino_b,
            t.fecha_dcorcom,
            t.numero_dcorcom,
            t.contacto_dcorcom,
            t.pesnet,
            t.ubigeodes_partida_a,
            t.ubigeodes_partida_b,
            t.ubigeo_partida,
            t.ubigeo_llegada,
            t.direccpar,
            t.ubigeopar,
            t.tidentra,
            t.tidentconductor,
            t.destidentconductor,
            t.didentconductor,
            t.placavehiculo,
            t.glosagfecab,
            t.glosagfepie,
            t.dessit,
            t.aliassit,
            t.abrunidad,
            t.signvalue,
            t.formato
        ORDER BY
            t.tipinv,
            t.codart,
            t.preuni,
            t.pordes1,
            t.pordes2,
            t.pordes3,
            t.pordes4,
            t.lote,
            t.fvenci;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_guiaremision_groupby;

    FUNCTION sp_notacredito (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_notacredito
        PIPELINED
    AS
        v_table datatable_notacredito;
    BEGIN
        SELECT
            d.id_cia,
            c.tipdoc                         AS tipdoc,
            dc.descri                        AS nomdoc,
            c.codsuc,
            c.numint                         AS numint,
            d.numite                         AS numite,
            c.series                         AS series,
            c.numdoc                         AS numdoc,
            c.femisi                         AS femisi,
            c.codcli                         AS codcli,
            c.razonc                         AS razonc,
            c.direc1                         AS direc1,
            c.ruc                            AS ruc,
            c1.direc1                        AS dircli1,
            c1.direc2                        AS dircli2,
            c1.telefono                      AS tlfcli,
            c1.fax                           AS faxcli,
            c1.dident                        AS dident,
            c.tident                         AS tident_cab,
            i.descri                         AS destident,
            i.abrevi                         AS abrtident,
            ct.nrodni                        AS nrodni,
            c.guiarefe                       AS guiarefe,
            c.almdes                         AS codalmdes,
            ald.descri                       AS desalmdes,
            ald.abrevi                       AS abralmdes,
            c.marcas                         AS marcas,
            c.presen                         AS presen,
            c.codsec                         AS codsec,
            c.facpro                         AS facpro,
            c.ffacpro                        AS ffacpro,
            c.codven                         AS codven,
            c.observ                         AS obscab,
            c.observ                         AS observ,
            c.tipcam                         AS tipcam,
            c.tipmon                         AS tipmon,
            c.totbru                         AS totbru,
            c.desesp                         AS desesp,
            nvl(c.descue, 0)                 AS descue,
            c.monafe                         AS monafe,
--            c.observ,
            CASE
                WHEN ( c.destin = 2
                       AND c.monina > 0 )
                     OR ( c1.codtpe <> 3
                          AND c22.codigo = 'S' ) THEN
                    CAST(0 AS NUMERIC(16, 2))
                ELSE
                    c.monina
            END                              AS monina,
            c.monafe + c.monina              AS monneto,
            c.monigv                         AS monigv,
            (
                CASE
                    WHEN ( mt16.valor IS NULL )
                         OR ( upper(mt16.valor) <> 'S' ) THEN
                        c.preven
                    ELSE
                        CAST(0 AS NUMERIC(16, 2))
                END
            )                                AS preven,
            (
                CASE
                    WHEN ( dct4.vreal IS NULL ) THEN
                        CAST(0 AS NUMERIC(9, 2))
                    ELSE
                        dct4.vreal
                END
            )                                AS percep,
            (
                CASE
                    WHEN ( mt16.valor IS NULL )
                         OR ( upper(mt16.valor) <> 'S' ) THEN
                        c.preven
                    ELSE
                        CAST(0 AS NUMERIC(16, 2))
                END
            ) + (
                CASE
                    WHEN ( dct4.vreal IS NULL ) THEN
                        CAST(0 AS NUMERIC(9, 2))
                    ELSE
                        dct4.vreal
                END
            )                                AS totpag,
            mt19.valor                       AS relcossalprod,
            c.flete                          AS flete,
            c.seguro                         AS seguro,
            c.porigv                         AS porigv,
            c.comisi                         AS comiven,
            c.codmot                         AS codmot,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                              AS numped,
            cv.despag                        AS despagven,
            cvc.valor                        AS enctacte,
            c.ordcom                         AS ordcom,
            c.fordcom                        AS fordcom,
            m1.simbolo                       AS simbolo,
            m1.desmon                        AS desmon,
            c.opnumdoc                       AS opnumdoc,
            c.horing                         AS horing,
            c.fecter                         AS fecter,
            c.horter                         AS horter,
            c.desnetx                        AS desnetx,
            c.despreven                      AS despreven,
            c.desfle                         AS desfle,
            c.desseg                         AS desseg,
            c.desgasa                        AS desgasa,
            c.gasadu                         AS gasadu,
            c.situac                         AS situac,
            c.destin                         AS destin,
            c.id                             AS id,
            mt.desmot                        AS desmot,
            mt.docayuda                      AS docayuda,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                    CAST('S' AS VARCHAR(20))
                ELSE
                    CAST('N' AS VARCHAR(20))
            END                              AS swdocpercep,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                        ccc.codigo
                ELSE
                    CAST('0.00' AS VARCHAR(20))
            END
            || ' %'                          AS porpercep,
            (
                SELECT
                    sp_exonerado_a_igv(c.id_cia, 'A', c.codcli, c.numint)
                FROM
                    dual
            )                                AS exoimp,
            cv.diaven                        AS diaven,
            s1.sucursal                      AS dessuc,
            s1.nomdis                        AS dissuc,
            v1.desven                        AS desven,
            dca.direc1                       AS desenv01,
            dca.direc2                       AS desenv02,
            d.codalm                         AS codalm,
            al.descri                        AS desalm,
            d.tipinv                         AS tipinv,
            d.codart                         AS codart,
--            CASE
--                WHEN c33.codigo <> 'S' THEN
--                    a.descri
--                ELSE
--                    CASE
--                        WHEN lpa33.desart <> '' THEN
--                                lpa33.desart
--                        ELSE
--                            CASE
--                                WHEN lp33.desart <> '' THEN
--                                            lp33.desart
--                                ELSE
--                                    a.descri
--                            END
--                    END
--            END                              AS desart,
            CASE
                WHEN c33.codigo != 'S' THEN
                    a.descri
                ELSE
                    CASE
                        WHEN lpa33.desart != '' THEN
                                lpa33.desart
                        ELSE
                            CASE
                                WHEN lp33.desart IS NOT NULL
                                     AND length(lp33.desart) > 0 THEN
                                            lp33.desart
                                ELSE
                                    a.descri
                            END
                    END
            END                              AS desart,
            a.faccon                         AS faccon,
            a.consto                         AS consto,
            d.largo * a.faccon               AS peslar,
            ( d.cantid * a.faccon ) + CAST(
                CASE
                    WHEN cc2.abrevi IS NULL THEN
                        CAST('0' AS VARCHAR(6))
                    ELSE
                        cc2.abrevi
                END
            AS NUMERIC(16,
     5))                              AS pesdet,
            cc2.abrevi                       AS taraadic,
            a.codart
            || ' '
            || a.descri                      AS coddesart,
            agl.observ                       AS desglosa,
            d.cantid                         AS cantid,
            d.canref                         AS canref,
            d.piezas                         AS piezas,
            d.tara                           AS tara,
            d.largo                          AS largo,
            d.etiqueta                       AS etiqueta,
            d.etiqueta2                      AS etiqueta2,
            a.coduni                         AS codund,
            d.codadd01                       AS codcalid,
            d.codadd02                       AS codcolor,
            d.opronumdoc                     AS opronumdoc,
            d.opnumdoc                       AS dopnumdoc,
            d.opcargo                        AS dopcargo,
            d.opnumite                       AS dopnumite,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.preuni * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.preuni
            END                              AS preuni,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.importe_bruto * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe_bruto
            END                              AS importe_bruto,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.importe * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe
            END                              AS importe,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    ( d.importe_bruto - d.importe ) * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe_bruto - d.importe
            END                              AS descdet,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    ( d.importe /
                      CASE
                          WHEN d.cantid IS NULL
                               OR d.cantid = 0 THEN
                                1
                          ELSE
                              d.cantid
                      END
                    ) * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    ( d.importe /
                      CASE
                          WHEN d.cantid IS NULL
                               OR d.cantid = 0 THEN
                                CAST(1 AS NUMERIC(16, 5))
                          ELSE
                              d.cantid
                      END
                    )
            END                              AS preuni02,
            d.preuni                         AS preunireal,
            d.importe                        AS importereal,
            d.codund                         AS codunidet,
            d.pordes1                        AS pordes1,
            d.pordes2                        AS pordes2,
            d.pordes3                        AS pordes3,
            d.pordes4                        AS pordes4,
            d.monafe + d.monina              AS monlinneto,
            d.monafe                         AS monafedet,
            d.monigv                         AS monigvdet,
            d.monisc                         AS moniscdet,
            d.monotr                         AS monotrdet,
--            d.largo * a.faccon               AS peslar,
            d.nrocarrete                     AS nrocarrete,
            d.acabado                        AS acabado,
            d.chasis,
            d.motor,
            d.lote                           AS lote,
            d.fvenci                         AS fvenci,
            d.ancho                          AS ancho,
            CASE
                WHEN ( ( fap.vstrg IS NOT NULL )
                       AND ( upper(fap.vstrg) = 'S' )
                       AND ( ddp.vreal IS NOT NULL )
                       AND ( ddp.vreal > 0 ) ) THEN
                    CAST('*' AS VARCHAR(20))
                ELSE
                    CAST('' AS VARCHAR(20))
            END                              AS astpercep,
--            ( d.cantid * a.faccon ) + CAST(
--                CASE
--                    WHEN cc2.abrevi IS NULL THEN
--                        CAST('0' AS VARCHAR(20))
--                    ELSE
--                        cc2.abrevi
--                END
--            AS NUMERIC(16, 5))               AS pesdet,
            CASE
                WHEN d.cantid IS NULL
                     OR d.cantid = 0 THEN
                    CAST(0 AS NUMERIC(16, 5))
                ELSE
                    ( d.monafe + d.monina ) / d.cantid
            END                              AS monuni,
            d.observ                         AS obsdet,
            ac3.codigo                       AS codfam,
            cc3.descri                       AS desfam,
            ac4.codigo                       AS codmod,
            cc4.descri                       AS desmod,
            ac5.codigo                       AS codlin,
            cc5.descri                       AS deslin,
            cl1.descri                       AS dcalidad,
            cl1.abrevi                       AS acalidad,
            cl2.codigo
            || '-'
            || cl2.descri                    AS dcolor,
--            cl2.descri                       AS dcolor2,
            cl2.descri                       AS color,
            CASE
                WHEN ac2.codigo IS NULL THEN
                    CAST('N' AS VARCHAR(20))
                ELSE
                    ac2.codigo
            END                              AS glosxdes,
            (
                SELECT
                    glosa
                FROM
                    companias_glosa
                WHERE
                        id_cia = c.id_cia
                    AND item = 24
            )                                AS gpiefac,
            gar.glosa                        AS glosagar,
            gap.glosa                        AS glosagap,
            gfp.glosa                        AS glosagfp,
            gfecab.glosa                     AS glosagfecab,
            gfepie.glosa                     AS glosagfepie,
            gfemen.glosa                     AS glosagfemen,
            (
                SELECT
                    glosa
                FROM
                    companias_glosa
                WHERE
                        id_cia = c.id_cia
                    AND item = 16
            )                                AS gdfis,
            cal.abrevi                       AS calidabrev,
            (
                CASE
                    WHEN aca1.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 6))
                    ELSE
                        aca1.vreal
                END
            )                                AS valundaltven,
            ds.signvalue,
            nvl(c.acuenta, 0),
            CAST(
                CASE
                    WHEN(c.destin = 2
                         AND c.monina > 0)
                        OR(c1.codtpe <> 3
                           AND c22.codigo = 'S') THEN
                        c.monina
                    ELSE
                        CAST(0 AS NUMERIC(16, 2))
                END
            AS NUMERIC(16,
                 2))                         AS totexo,
            c.monisc                         AS totisc,
            CAST(0 AS NUMERIC(16, 2))        AS totoca,
            CAST(c.monotr AS NUMERIC(16, 2)) AS tototr,
            ( cc14.descri
              || ','
              || cc15.descri
              || ','
              || cc16.descri )                 AS ubigeo,
            ( cc16.descri
              || ' - '
              || cc15.descri
              || ' - '
              || cc14.descri )                 AS ubigeo_b,
            doc.fecha                        AS fecha_dcorcom,
            doc.numero                       AS numero_dcorcom,
            doc.contacto                     AS contacto_dcorcom,
            c.usuari,
            dcc11.codigo                     AS incoterm,
            ccc11.descri                     AS desincoterm,
            dcc12.vstrg                      AS destinofinal,
            dcc15.vstrg                      AS puertoembarque,
            dcc16.vstrg                      AS contenedor,
            dcc17.vstrg                      AS booking,
            dcc18.codigo                     AS certificado,
            ccc18.descri                     AS descertificado,
            cc10.descri                      AS pais,
            s2.dessit                        AS dessit,
            s2.alias                         AS aliassit,
            c.pesnet,
            und.abrevi                       AS abrunidad,
            cac10.codigo                     AS direnv_pais,
            ca14.descri                      AS direnv_dep,
            ca15.descri                      AS direnv_pro,
            ca16.descri                      AS direnv_dis,
            c.direccpar                      AS direccpar,
            c.ubigeopar                      AS ubigeopar,
            cao14.descri                     AS dirpar_dep,
            cao15.descri                     AS dirpar_pro,
            cao16.descri                     AS dirpar_dis,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.destra
                ELSE
                    t1.razonc
            END                              AS razonctra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.chofer
                ELSE
                    t1.descri
            END                              AS destra,
            t1.domici                        AS dirtra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.ruc
                ELSE
                    t1.ruc
            END                              AS ructra,
            t1.punpar                        AS punpartra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.licenc
                ELSE
                    t1.licenc
            END                              AS licenciatra,
            t1.placa                         AS placatra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.certif
                ELSE
                    t1.certif
            END                              AS certiftra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.telef1
                ELSE
                    t1.telef1
            END                              AS fonotra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.desveh
                ELSE
                    vh.descri
            END                              AS desveh,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.tipo
                ELSE
                    vh.tipo
            END                              AS tipoveh,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.marca
                ELSE
                    vh.marca
            END                              AS marcaveh,
            CASE
                WHEN length(
                    CASE
                        WHEN t1.swdattra = 'S' THEN
                            dct.ruc
                        ELSE
                            t1.ruc
                    END
                ) = 11 THEN
                    CAST('6' AS VARCHAR(20))
                ELSE
                    CAST('0' AS VARCHAR(20))
            END                              AS tidentra,
            CASE
                WHEN t1.chofer_tident IS NULL THEN
                    dct.chofer_tident
                ELSE
                    t1.chofer_tident
            END                              AS tidentconductor,
            CASE
                WHEN t1.chofer_tident IS NULL THEN
                    (
                        SELECT
                            descri
                        FROM
                            identidad
                        WHERE
                                id_cia = c.id_cia
                            AND tident = dct.chofer_tident
                    )
                ELSE
                    (
                        SELECT
                            descri
                        FROM
                            identidad
                        WHERE
                                id_cia = c.id_cia
                            AND tident = t1.chofer_tident
                    )
            END                              AS destidentconductor,
            CASE
                WHEN t1.chofer_dident IS NULL THEN
                    dct.chofer_dident
                ELSE
                    t1.chofer_dident
            END                              AS didentconductor,
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
            END                              AS placavehiculo,
            CAST((
                CASE
                    WHEN(mt34.valor IS NULL) THEN
                        CAST('0' AS VARCHAR(25))
                    ELSE
                        mt34.valor
                END
            ) AS SMALLINT)                   AS tiponcresunat,
            CAST((
                CASE
                    WHEN(mt35.valor IS NULL) THEN
                        CAST('0' AS VARCHAR(25))
                    ELSE
                        mt35.valor
                END
            ) AS SMALLINT)                   AS tipondebsunat,
            df.formato                       AS formato
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab                c
            LEFT OUTER JOIN documentos                    dc ON dc.id_cia = c.id_cia
                                             AND ( dc.codigo = c.tipdoc )
                                             AND ( dc.series = c.series )
            LEFT OUTER JOIN cliente                       c1 ON c1.id_cia = c.id_cia
                                          AND c1.codcli = c.codcli
            LEFT OUTER JOIN cliente_tpersona              ct ON ct.id_cia = c.id_cia
                                                   AND ct.codcli = c.codcli
            LEFT OUTER JOIN identidad                     i ON i.id_cia = c1.id_cia
                                           AND i.tident = c1.tident
            LEFT OUTER JOIN almacen                       ald ON ald.id_cia = c.id_cia
                                           AND ald.tipinv = 1
                                           AND ald.codalm = c.almdes
            LEFT OUTER JOIN documentos_cab_clase          cc ON cc.id_cia = c.id_cia
                                                       AND cc.numint = c.numint
                                                       AND cc.clase = 6
            LEFT OUTER JOIN documentos_cab_clase          dcc11 ON dcc11.id_cia = c.id_cia
                                                          AND dcc11.numint = c.numint
                                                          AND dcc11.clase = 11
                                                          AND dcc11.codigo <> 'ND'
            LEFT OUTER JOIN clase_documentos_cab_codigo   ccc11 ON ccc11.id_cia = c.id_cia
                                                                 AND ccc11.clase = dcc11.clase
                                                                 AND ccc11.codigo = dcc11.codigo
                                                                 AND ccc11.tipdoc = c.tipdoc
            LEFT OUTER JOIN documentos_cab_clase          dcc12 ON dcc12.id_cia = c.id_cia
                                                          AND dcc12.numint = c.numint
                                                          AND dcc12.clase = 12
            LEFT OUTER JOIN documentos_cab_clase          dcc15 ON dcc15.id_cia = c.id_cia
                                                          AND dcc15.numint = c.numint
                                                          AND dcc15.clase = 15
            LEFT OUTER JOIN documentos_cab_clase          dcc16 ON dcc16.id_cia = c.id_cia
                                                          AND dcc16.numint = c.numint
                                                          AND dcc16.clase = 16
            LEFT OUTER JOIN documentos_cab_clase          dcc17 ON dcc17.id_cia = c.id_cia
                                                          AND dcc17.numint = c.numint
                                                          AND dcc17.clase = 17
            LEFT OUTER JOIN documentos_cab_clase          dcc18 ON dcc18.id_cia = c.id_cia
                                                          AND dcc18.numint = c.numint
                                                          AND dcc18.clase = 18
            LEFT OUTER JOIN clase_documentos_cab_codigo   ccc18 ON ccc18.id_cia = c.id_cia
                                                                 AND ccc18.clase = dcc18.clase
                                                                 AND ccc18.codigo = dcc18.codigo
                                                                 AND ccc18.tipdoc = c.tipdoc
            LEFT OUTER JOIN c_pago                        cv ON cv.id_cia = c.id_cia
                                         AND cv.codpag = c.codcpag
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN c_pago_clase                  cvc ON cvc.id_cia = c.id_cia
                                                AND cvc.codpag = c.codcpag
                                                AND cvc.codigo = 1
            LEFT OUTER JOIN tmoneda                       m1 ON m1.id_cia = c.id_cia
                                          AND m1.codmon = c.tipmon
            LEFT OUTER JOIN sucursal                      s1 ON s1.id_cia = c.id_cia
                                           AND s1.codsuc = c.codsuc
            LEFT OUTER JOIN motivos                       mt ON mt.id_cia = c.id_cia
                                          AND mt.codmot = c.codmot
                                          AND mt.id = c.id
                                          AND c.tipdoc = mt.tipdoc
            LEFT OUTER JOIN motivos_clase                 mt16 ON mt16.id_cia = c.id_cia
                                                  AND mt16.codmot = c.codmot
                                                  AND mt16.id = c.id
                                                  AND mt16.tipdoc = c.tipdoc
                                                  AND mt16.codigo = 16
            LEFT OUTER JOIN motivos_clase                 mt19 ON mt19.id_cia = c.id_cia
                                                  AND mt19.codmot = c.codmot
                                                  AND mt19.id = c.id
                                                  AND mt19.tipdoc = c.tipdoc
                                                  AND mt19.codigo = 19
            LEFT OUTER JOIN clase_clientes_almacen_codigo cao14 ON cao14.id_cia = c.id_cia
                                                                   AND cao14.clase = 14
                                                                   AND cao14.codigo = CAST(substr(c.ubigeopar, 1, 2) AS VARCHAR(10))
            LEFT OUTER JOIN clase_clientes_almacen_codigo cao15 ON cao15.id_cia = c.id_cia
                                                                   AND cao15.clase = 15
                                                                   AND cao15.codigo = CAST(substr(c.ubigeopar, 1, 4) AS VARCHAR(10))
            LEFT OUTER JOIN clase_clientes_almacen_codigo cao16 ON cao16.id_cia = c.id_cia
                                                                   AND cao16.clase = 16
                                                                   AND cao16.codigo = c.ubigeopar
            LEFT OUTER JOIN documentos_cab_almacen        dca ON c.id_cia = dca.id_cia
                                                          AND c.numint = dca.numint
            LEFT OUTER JOIN clientes_almacen_clase        cac10 ON cac10.id_cia = c.id_cia
                                                            AND cac10.codcli = c.codcli
                                                            AND cac10.codenv = dca.codenv
                                                            AND cac10.clase = 10
            LEFT OUTER JOIN clientes_almacen_clase        cac14 ON cac14.id_cia = c.id_cia
                                                            AND cac14.codcli = c.codcli
                                                            AND cac14.codenv = dca.codenv
                                                            AND cac14.clase = 14
            LEFT OUTER JOIN clase_clientes_almacen_codigo ca14 ON ca14.id_cia = c.id_cia
                                                                  AND ca14.clase = cac14.clase
                                                                  AND ca14.codigo = cac14.codigo
            LEFT OUTER JOIN clientes_almacen_clase        cac15 ON cac15.id_cia = c.id_cia
                                                            AND cac15.codcli = c.codcli
                                                            AND cac15.codenv = dca.codenv
                                                            AND cac15.clase = 15
            LEFT OUTER JOIN clase_clientes_almacen_codigo ca15 ON ca15.id_cia = c.id_cia
                                                                  AND ca15.clase = cac15.clase
                                                                  AND ca15.codigo = cac15.codigo
            LEFT OUTER JOIN clientes_almacen_clase        cac16 ON cac16.id_cia = c.id_cia
                                                            AND cac16.codcli = c.codcli
                                                            AND cac16.codenv = dca.codenv
                                                            AND cac16.clase = 16
            LEFT OUTER JOIN clase_clientes_almacen_codigo ca16 ON ca16.id_cia = c.id_cia
                                                                  AND ca16.clase = cac16.clase
                                                                  AND ca16.codigo = cac16.codigo
            LEFT OUTER JOIN documentos_cab_ordcom         doc ON doc.id_cia = c.id_cia
                                                         AND c.numint = doc.numint
            LEFT OUTER JOIN transportista                 t1 ON t1.id_cia = c.id_cia
                                                AND t1.codtra = c.codtra
            LEFT OUTER JOIN documentos_cab_transportista  dct ON dct.id_cia = c.id_cia
                                                                AND dct.numint = c.numint
            LEFT OUTER JOIN vehiculos                     vh ON vh.id_cia = c.id_cia
                                            AND vh.codveh = c.codveh
            LEFT OUTER JOIN documentos_cab_clase          dct4 ON dct4.id_cia = c.id_cia
                                                         AND dct4.numint = c.numint
                                                         AND dct4.clase = 4
            LEFT OUTER JOIN documentos_cab_clase          dcp ON dcp.id_cia = c.id_cia
                                                        AND dcp.numint = c.numint
                                                        AND dcp.clase = 3
            LEFT OUTER JOIN cliente_clase                 ccc ON ccc.id_cia = c.id_cia
                                                 AND ccc.tipcli = 'A'
                                                 AND ccc.codcli = c.codcli
                                                 AND ccc.clase = 23
            LEFT OUTER JOIN cliente_clase                 c33 ON c33.id_cia = c.id_cia
                                                 AND c33.tipcli = 'A'
                                                 AND c33.codcli = c.codcli
                                                 AND c33.clase = 33
            LEFT OUTER JOIN cliente_clase                 c10 ON c10.id_cia = c.id_cia
                                                 AND c10.tipcli = 'A'
                                                 AND c10.codcli = c.codcli
                                                 AND c10.clase = 10
                                                 AND c10.codigo <> 'ND'
            LEFT OUTER JOIN clase_cliente_codigo          cc10 ON cc10.id_cia = c.id_cia
                                                         AND cc10.clase = c10.clase
                                                         AND cc10.codigo = c10.codigo
                                                         AND cc10.tipcli = c10.tipcli
            LEFT OUTER JOIN cliente_clase                 c14 ON c14.id_cia = c.id_cia
                                                 AND c14.tipcli = 'A'
                                                 AND c14.codcli = c.codcli
                                                 AND c14.clase = 14
                                                 AND c14.codigo <> 'ND'
            LEFT OUTER JOIN clase_cliente_codigo          cc14 ON cc14.id_cia = c.id_cia
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase                 c15 ON c15.id_cia = c.id_cia
                                                 AND c15.tipcli = 'A'
                                                 AND c15.codcli = c.codcli
                                                 AND c15.clase = 15
                                                 AND c15.codigo <> 'ND'
            LEFT OUTER JOIN clase_cliente_codigo          cc15 ON cc15.id_cia = c.id_cia
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase                 c16 ON c16.id_cia = c.id_cia
                                                 AND c16.tipcli = 'A'
                                                 AND c16.codcli = c.codcli
                                                 AND c16.clase = 16
                                                 AND c16.codigo <> 'ND'
            LEFT OUTER JOIN clase_cliente_codigo          cc16 ON cc16.id_cia = c.id_cia
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN cliente_clase                 c22 ON c22.id_cia = c.id_cia
                                                 AND c22.tipcli = 'A'
                                                 AND c22.codcli = c.codcli
                                                 AND c22.clase = 22
                                                 AND NOT ( c22.codigo ) = 'ND'
            LEFT OUTER JOIN vendedor                      v1 ON v1.id_cia = c.id_cia
                                           AND v1.codven = c.codven
            LEFT OUTER JOIN factor                        far ON far.id_cia = c.id_cia
                                          AND far.codfac = 331
            LEFT OUTER JOIN factor                        fap ON fap.id_cia = c.id_cia
                                          AND fap.codfac = 332
            LEFT OUTER JOIN companias_glosa               gar ON gar.id_cia = c.id_cia
                                                   AND gar.item = 15
                                                   AND far.vstrg IS NOT NULL
                                                   AND upper(far.vstrg) = 'S'
            LEFT OUTER JOIN companias_glosa               gap ON gap.id_cia = c.id_cia
                                                   AND gap.item = 13
                                                   AND fap.vstrg IS NOT NULL
                                                   AND upper(fap.vstrg) = 'S'
            LEFT OUTER JOIN companias_glosa               gfp ON gfp.id_cia = c.id_cia
                                                   AND gfp.item = 14
                                                   AND fap.vstrg IS NOT NULL
                                                   AND upper(fap.vstrg) = 'S'
                                                   AND dcp.codigo IS NOT NULL
                                                   AND upper(dcp.codigo) = 'S'
            LEFT OUTER JOIN companias_glosa               gfecab ON gfecab.id_cia = c.id_cia
                                                      AND gfecab.item = 31
            LEFT OUTER JOIN companias_glosa               gfepie ON gfepie.id_cia = c.id_cia
                                                      AND gfepie.item = 32
            LEFT OUTER JOIN companias_glosa               gfemen ON gfemen.id_cia = c.id_cia
                                                      AND gfemen.item = 33
            LEFT OUTER JOIN documentos_det                d ON d.id_cia = c.id_cia
                                                AND d.numint = c.numint
            LEFT OUTER JOIN documentos_det_clase          ddp ON ddp.id_cia = c.id_cia
                                                        AND ddp.numint = d.numint
                                                        AND ddp.numite = d.numite
                                                        AND ddp.clase = 50
            LEFT OUTER JOIN almacen                       al ON al.id_cia = d.id_cia
                                          AND al.tipinv = d.tipinv
                                          AND al.codalm = d.codalm
            LEFT OUTER JOIN articulos                     a ON a.id_cia = d.id_cia
                                           AND a.codart = d.codart
                                           AND a.tipinv = d.tipinv
            LEFT OUTER JOIN listaprecios                  lp33 ON lp33.id_cia = c.id_cia
                                                 AND lp33.vencom = 1
                                                 AND lp33.codtit = c1.codtit
                                                 AND lp33.tipinv = d.tipinv
                                                 AND lp33.codart = d.codart
            LEFT OUTER JOIN listaprecios_alternativa      lpa33 ON lpa33.id_cia = c.id_cia
                                                              AND lpa33.vencom = 1
                                                              AND lpa33.codtit = c1.codtit
                                                              AND lpa33.tipinv = d.tipinv
                                                              AND lpa33.codart = d.codart
                                                              AND lpa33.codadd01 = d.codadd01
                                                              AND lpa33.codadd02 = d.codadd02
            LEFT OUTER JOIN articulos_glosa               agl ON agl.id_cia = c.id_cia
                                                   AND agl.tipo = 2
                                                   AND agl.tipinv = d.tipinv
                                                   AND agl.codart = d.codart
            LEFT OUTER JOIN articulos_clase               ac1 ON ac1.id_cia = c.id_cia
                                                   AND ac1.tipinv = d.tipinv
                                                   AND ac1.codart = d.codart
                                                   AND ac1.clase = 81
            LEFT OUTER JOIN articulos_clase               ac2 ON ac2.id_cia = c.id_cia
                                                   AND ac2.tipinv = d.tipinv
                                                   AND ac2.codart = d.codart
                                                   AND ac2.clase = 87
            LEFT OUTER JOIN articulos_clase               ac3 ON ac3.id_cia = c.id_cia
                                                   AND ac3.tipinv = d.tipinv
                                                   AND ac3.codart = d.codart
                                                   AND ac3.clase = 2
            LEFT OUTER JOIN articulos_clase               ac4 ON ac4.id_cia = c.id_cia
                                                   AND ac4.tipinv = d.tipinv
                                                   AND ac4.codart = d.codart
                                                   AND ac4.clase = 51
            LEFT OUTER JOIN articulos_clase               ac5 ON ac5.id_cia = c.id_cia
                                                   AND ac5.tipinv = d.tipinv
                                                   AND ac5.codart = d.codart
                                                   AND ac5.clase = 3
            LEFT OUTER JOIN clase_codigo                  cc2 ON cc2.id_cia = ac1.id_cia
                                                AND cc2.tipinv = ac1.tipinv
                                                AND cc2.clase = ac1.clase
                                                AND cc2.codigo = ac1.codigo
            LEFT OUTER JOIN clase_codigo                  cc3 ON cc3.id_cia = c.id_cia
                                                AND cc3.tipinv = ac3.tipinv
                                                AND cc3.clase = ac3.clase
                                                AND cc3.codigo = ac3.codigo
            LEFT OUTER JOIN clase_codigo                  cc4 ON cc4.id_cia = c.id_cia
                                                AND cc4.tipinv = ac4.tipinv
                                                AND cc4.clase = ac4.clase
                                                AND cc4.codigo = ac4.codigo
            LEFT OUTER JOIN clase_codigo                  cc5 ON cc5.id_cia = c.id_cia
                                                AND cc5.tipinv = ac5.tipinv
                                                AND cc5.clase = ac5.clase
                                                AND cc5.codigo = ac5.codigo
            LEFT OUTER JOIN cliente_articulos_clase       cl1 ON cl1.id_cia = c.id_cia
                                                           AND cl1.tipcli = 'B'
                                                           AND cl1.codcli = a.codprv
                                                           AND cl1.clase = 1
                                                           AND cl1.codigo = d.codadd01
            LEFT OUTER JOIN cliente_articulos_clase       cl2 ON cl2.id_cia = c.id_cia
                                                           AND cl2.tipcli = 'B'
                                                           AND cl2.codcli = a.codprv
                                                           AND cl2.clase = 2
                                                           AND cl2.codigo = d.codadd02
            LEFT OUTER JOIN calidad                       cal ON cal.id_cia = c.id_cia
                                           AND cal.codigo = d.codadd01
            LEFT OUTER JOIN articulos_clase_alternativo   aca1 ON aca1.id_cia = c.id_cia
                                                                AND aca1.tipinv = d.tipinv
                                                                AND aca1.codart = d.codart
                                                                AND aca1.clase = 1
                                                                AND aca1.codigo = d.codund
            LEFT OUTER JOIN documentos_cab_envio_sunat    ds ON ds.id_cia = c.id_cia
                                                             AND ds.numint = c.numint
            LEFT OUTER JOIN situacion                     s2 ON s2.id_cia = c.id_cia
                                            AND s2.situac = c.situac
                                            AND s2.tipdoc = c.tipdoc
            LEFT JOIN unidad                        und ON und.id_cia = d.id_cia
                                    AND und.coduni = d.codund
            LEFT OUTER JOIN motivos_clase                 mt34 ON mt34.id_cia = c.id_cia
                                                  AND mt34.codmot = c.codmot
                                                  AND mt34.id = c.id
                                                  AND mt34.tipdoc = c.tipdoc
                                                  AND mt34.codigo = 34
            LEFT OUTER JOIN motivos_clase                 mt35 ON mt35.id_cia = c.id_cia
                                                  AND mt35.codmot = c.codmot
                                                  AND mt35.id = c.id
                                                  AND mt35.tipdoc = c.tipdoc
                                                  AND mt35.codigo = 35
            LEFT OUTER JOIN documentos_formatos           df ON df.tipdoc = dc.codigo
                                                      AND df.item = nvl(dc.tipimp, 1)
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_notacredito;

    FUNCTION sp_notacredito_groupby (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_notacredito
        PIPELINED
    AS
        v_table datatable_notacredito;
    BEGIN
        SELECT
            t.id_cia,
            t.tipdoc,
            t.nomdoc,
            t.codsuc,
            t.numint,
            NULL, -- numite,
            t.series,
            t.numdoc,
            t.femisi,
            t.codcli,
            t.razonc,
            t.direc1,
            t.ruc,
            t.dircli1,
            t.dircli2,
            t.tlfcli,
            t.faxcli,
            t.dident,
            t.tident_cab,
            t.destident,
            t.abrtident,
            t.nrodni,
            t.guiarefe,
            t.codalmdes,
            t.desalmdes,
            t.abralmdes,
            t.marcas,
            t.presen,
            t.codsec,
            t.facpro,
            t.ffacpro,
            t.codven,
            t.obscab,
            t.observ,
            t.tipcam,
            t.tipmon,
            t.totbru,
            t.desesp,
            t.descue,
            t.monafe,
            t.monina,
            t.monneto,
            t.monigv,
            t.preven,
            t.percep,
            t.totpag,
            t.relcossalprod,
            t.flete,
            t.seguro,
            t.porigv,
            t.comiven,
            t.codmot,
            t.numped,
            t.despagven,
            t.enctacte,
            t.ordcom,
            t.fordcom,
            t.simbolo,
            t.desmon,
            t.opnumdoc,
            t.horing,
            t.fecter,
            t.horter,
            t.desnetx,
            t.despreven,
            t.desfle,
            t.desseg,
            t.desgasa,
            t.gasadu,
            t.situac,
            t.destin,
            t.id,
            t.desmot,
            t.docayuda,
            t.swdocpercep,
            t.porpercep,
            t.exoimp,
            t.diaven,
            t.dessuc,
            t.dissuc,
            t.desven,
            t.desenv01,
            t.desenv02,
            t.codalm,
            t.desalm,
            t.tipinv,
            t.codart,
            t.desart,
            NULL, --faccon,
            NULL, -- consto,
            SUM(t.peslar),
            SUM(t.pesdet),
            NULL, --t.taraadic,
            t.coddesart,
            t.desglosa,
            SUM(t.cantid),
            SUM(t.canref),
            SUM(t.piezas),
            NULL, --tara
            NULL, --largo
            NULL, --etiqeuta
            NULL, --etiqueta2
            t.codund,
            t.codcalid,
            t.codcolor,
            t.opronumdoc,
            t.dopnumdoc,
            NULL, --dopcargo,
            NULL, -- dopnumite,
            t.preuni,
            SUM(t.importe_bruto),
            SUM(t.importe),
            t.descdet,
            t.preuni02,
            t.preunireal,
            SUM(t.importereal),
            t.codunidet,
            t.pordes1,
            t.pordes2,
            t.pordes3,
            t.pordes4,
            SUM(t.monlinneto),
            SUM(t.monafedet),
            SUM(t.monigvdet),
            SUM(t.moniscdet),
            SUM(t.monotrdet),
            t.nrocarrete,
            t.acabado,
            NULL,--t.chasis, 
            NULL,--t.motor,
            t.lote,
            t.fvenci,
            t.ancho,
            t.astpercep,
            SUM(t.monuni),
            NULL,-- obsdet
            t.codfam,
            t.desfam,
            t.codmod,
            t.desmod,
            t.codlin,
            t.deslin,
            t.dcalidad,
            t.acalidad,
            t.dcolor,
            t.color,
            t.glosxdes,
            t.gpiefac,
            t.glosagar,
            t.glosagap,
            t.glosagfp,
            t.glosagfecab,
            t.glosagfepie,
            t.glosagfemen,
            t.gdfis,
            t.calidabrev,
            t.valundaltven,
            t.signvalue,
            t.acuenta,
            t.totexo,
            t.totisc,
            t.totoca,
            t.tototr,
            t.ubigeo,
            t.ubigeo_b,
            t.fecha_dcorcom,
            t.numero_dcorcom,
            t.contacto_dcorcom,
            t.usuari,
            t.incoterm,
            t.desincoterm,
            t.destinofinal,
            t.puertoembarque,
            t.contenedor,
            t.booking,
            t.certificado,
            t.descertificado,
            t.pais,
            t.dessit,
            t.aliassit,
            t.pesnet,
            t.abrunidad,
            t.direnv_pais,
            t.direnv_dep,
            t.direnv_pro,
            t.direnv_dis,
            t.direccpar,
            t.ubigeopar,
            t.dirpar_dep,
            t.dirpar_pro,
            t.dirpar_dis,
            t.razonctra,
            t.destra,
            t.dirtra,
            t.ructra,
            t.punpartra,
            t.licenciatra,
            t.placatra,
            t.certiftra,
            t.fonotra,
            t.desveh,
            t.tipoveh,
            t.marcaveh,
            t.tidentra,
            t.tidentconductor,
            t.destidentconductor,
            t.didentconductor,
            t.placavehiculo,
            t.tiponcresunat,
            t.tipondebsunat,
            t.formato
        BULK COLLECT
        INTO v_table
        FROM
            pack_reportes_trazabilidad.sp_notacredito(pin_id_cia, pin_numint) t
        GROUP BY
            t.id_cia,
            t.tipdoc,
            t.nomdoc,
            t.codsuc,
            t.numint,
            NULL, -- numite,
            t.series,
            t.numdoc,
            t.femisi,
            t.codcli,
            t.razonc,
            t.direc1,
            t.ruc,
            t.dircli1,
            t.dircli2,
            t.tlfcli,
            t.faxcli,
            t.dident,
            t.tident_cab,
            t.destident,
            t.abrtident,
            t.nrodni,
            t.guiarefe,
            t.codalmdes,
            t.desalmdes,
            t.abralmdes,
            t.marcas,
            t.presen,
            t.codsec,
            t.facpro,
            t.ffacpro,
            t.codven,
            t.obscab,
            t.observ,
            t.tipcam,
            t.tipmon,
            t.totbru,
            t.desesp,
            t.descue,
            t.monafe,
            t.monina,
            t.monneto,
            t.monigv,
            t.preven,
            t.percep,
            t.totpag,
            t.relcossalprod,
            t.flete,
            t.seguro,
            t.porigv,
            t.comiven,
            t.codmot,
            t.numped,
            t.despagven,
            t.enctacte,
            t.ordcom,
            t.fordcom,
            t.simbolo,
            t.desmon,
            t.opnumdoc,
            t.horing,
            t.fecter,
            t.horter,
            t.desnetx,
            t.despreven,
            t.desfle,
            t.desseg,
            t.desgasa,
            t.gasadu,
            t.situac,
            t.destin,
            t.id,
            t.desmot,
            t.docayuda,
            t.swdocpercep,
            t.porpercep,
            t.exoimp,
            t.diaven,
            t.dessuc,
            t.dissuc,
            t.desven,
            t.desenv01,
            t.desenv02,
            t.codalm,
            t.desalm,
            t.tipinv,
            t.codart,
            t.desart,
            NULL, --faccon,
            NULL, -- consto,
--            SUM(t.peslar),
--            SUM(t.pesdet),
            NULL, --t.taraadic,
            t.coddesart,
            t.desglosa,
--            SUM(t.cantid),
--            SUM(t.canref),
--            SUM(t.piezas),
            NULL, --tara
            NULL, --largo
            NULL, --etiqeuta
            NULL, --etiqueta2
            t.codund,
            t.codcalid,
            t.codcolor,
            t.opronumdoc,
            t.dopnumdoc,
            NULL, --dopcargo,
            NULL, -- dopnumite,
            t.preuni,
--            SUM(t.importe_bruto),
--            SUM(t.importe),
            t.descdet,
            t.preuni02,
            t.preunireal,
--            SUM(t.importereal),
            t.codunidet,
            t.pordes1,
            t.pordes2,
            t.pordes3,
            t.pordes4,
--            SUM(t.monlinneto),
--            SUM(t.monafedet),
--            SUM(t.monigvdet),
--            SUM(t.moniscdet),
--            SUM(t.monotrdet),
            t.nrocarrete,
            t.acabado,
            NULL,--t.chasis, 
            NULL,--t.motor,
            t.lote,
            t.fvenci,
            t.ancho,
            t.astpercep,
--            SUM(t.monuni),
            NULL,-- obsdet
            t.codfam,
            t.desfam,
            t.codmod,
            t.desmod,
            t.codlin,
            t.deslin,
            t.dcalidad,
            t.acalidad,
            t.dcolor,
            t.color,
            t.glosxdes,
            t.gpiefac,
            t.glosagar,
            t.glosagap,
            t.glosagfp,
            t.glosagfecab,
            t.glosagfepie,
            t.glosagfemen,
            t.gdfis,
            t.calidabrev,
            t.valundaltven,
            t.signvalue,
            t.acuenta,
            t.totexo,
            t.totisc,
            t.totoca,
            t.tototr,
            t.ubigeo,
            t.ubigeo_b,
            t.fecha_dcorcom,
            t.numero_dcorcom,
            t.contacto_dcorcom,
            t.usuari,
            t.incoterm,
            t.desincoterm,
            t.destinofinal,
            t.puertoembarque,
            t.contenedor,
            t.booking,
            t.certificado,
            t.descertificado,
            t.pais,
            t.dessit,
            t.aliassit,
            t.pesnet,
            t.abrunidad,
            t.direnv_pais,
            t.direnv_dep,
            t.direnv_pro,
            t.direnv_dis,
            t.direccpar,
            t.ubigeopar,
            t.dirpar_dep,
            t.dirpar_pro,
            t.dirpar_dis,
            t.razonctra,
            t.destra,
            t.dirtra,
            t.ructra,
            t.punpartra,
            t.licenciatra,
            t.placatra,
            t.certiftra,
            t.fonotra,
            t.desveh,
            t.tipoveh,
            t.marcaveh,
            t.tidentra,
            t.tidentconductor,
            t.destidentconductor,
            t.didentconductor,
            t.placavehiculo,
            t.tiponcresunat,
            t.tipondebsunat,
            t.formato
        ORDER BY
            t.tipinv,
            t.codart,
            t.preuni,
            t.pordes1,
            t.pordes2,
            t.pordes3,
            t.pordes4,
            t.lote,
            t.fvenci;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_notacredito_groupby;

    FUNCTION sp_notadebito (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_notadebito
        PIPELINED
    AS
        v_table datatable_notadebito;
    BEGIN
        SELECT
            c.id_cia,
            c.tipdoc                         AS tipdoc,
            dc.descri                        AS nomdoc,
            c.codsuc                         AS codsuc,
            c.numint                         AS numint,
            d.numite                         AS numite,
            c.series                         AS series,
            c.numdoc                         AS numdoc,
            c.femisi                         AS femisi,
            c.codcli                         AS codcli,
            c.razonc                         AS razonc,
            c.direc1                         AS direc1,
            c.ruc                            AS ruc,
            c1.direc1                        AS dircli1,
            c1.direc2                        AS dircli2,
            c1.telefono                      AS tlfcli,
            c1.fax                           AS faxcli,
            c1.dident                        AS dident,
            c.tident                         AS tident_cab,
            i.descri                         AS destident,
            i.abrevi                         AS abrtident,
            ct.nrodni                        AS nrodni,
            c.guiarefe                       AS guiarefe,
            c.almdes                         AS codalmdes,
            ald.descri                       AS desalmdes,
            ald.abrevi                       AS abralmdes,
            c.marcas                         AS marcas,
            c.presen                         AS presen,
            c.codsec                         AS codsec,
            c.facpro                         AS facpro,
            c.ffacpro                        AS ffacpro,
            c.codven                         AS codven,
            c.observ                         AS obscab,
            c.tipcam                         AS tipcam,
            c.tipmon                         AS tipmon,
            c.totbru                         AS totbru,
            c.desesp                         AS desesp,
            nvl(c.descue, 0)                 AS descue,
            c.monafe                         AS monafe,
--            C.observ,
            CASE
                WHEN ( c.destin = 2
                       AND c.monina > 0 )
                     OR ( c1.codtpe <> 3
                          AND c22.codigo = 'S' ) THEN
                    CAST(0 AS NUMERIC(16, 2))
                ELSE
                    c.monina
            END                              AS monina,
            c.monafe + c.monina              AS monneto,
            c.monigv                         AS monigv,
            (
                CASE
                    WHEN ( mt16.valor IS NULL )
                         OR ( upper(mt16.valor) <> 'S' ) THEN
                        c.preven
                    ELSE
                        CAST(0 AS NUMERIC(16, 2))
                END
            )                                AS preven,
            (
                CASE
                    WHEN ( dct4.vreal IS NULL ) THEN
                        CAST(0 AS NUMERIC(9, 2))
                    ELSE
                        dct4.vreal
                END
            )                                AS percep,
            (
                CASE
                    WHEN ( mt16.valor IS NULL )
                         OR ( upper(mt16.valor) <> 'S' ) THEN
                        c.preven
                    ELSE
                        CAST(0 AS NUMERIC(16, 2))
                END
            ) + (
                CASE
                    WHEN ( dct4.vreal IS NULL ) THEN
                        CAST(0 AS NUMERIC(9, 4))
                    ELSE
                        dct4.vreal
                END
            )                                AS totpag,
            mt19.valor                       AS relcossalprod,
            c.flete                          AS flete,
            c.seguro                         AS seguro,
            c.porigv                         AS porigv,
            c.comisi                         AS comiven,
            c.codmot                         AS codmot,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                              AS numped,
            cv.despag                        AS despagven,
            cvc.valor                        AS enctacte,
            c.ordcom                         AS ordcom,
            c.fordcom                        AS fordcom,
            m1.simbolo                       AS simbolo,
            m1.desmon                        AS desmon,
            c.opnumdoc                       AS opnumdoc,
            c.horing                         AS horing,
            c.fecter                         AS fecter,
            c.horter                         AS horter,
            c.desnetx                        AS desnetx,
            c.despreven                      AS despreven,
            c.desfle                         AS desfle,
            c.desseg                         AS desseg,
            c.desgasa                        AS desgasa,
            c.gasadu                         AS gasadu,
            c.situac                         AS situac,
            c.destin                         AS destin,
            c.id                             AS id,
--            C.CODSUC,
            mt.desmot                        AS desmot,
            mt.docayuda                      AS docayuda,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                    CAST('S' AS VARCHAR(20))
                ELSE
                    CAST('N' AS VARCHAR(20))
            END                              AS swdocpercep,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                        ccc.codigo
                ELSE
                    CAST('0.00' AS VARCHAR(20))
            END
            || ' %'                          AS porpercep,
            (
                SELECT
                    sp_exonerado_a_igv(c.id_cia, 'A', c.codcli, c.numint)
                FROM
                    dual
            )                                AS exoimp,
            cv.diaven                        AS diaven,
            s1.sucursal                      AS dessuc,
            s1.nomdis                        AS dissuc,
            v1.desven                        AS desven,
--            T1.Descri as DesTra,
--            T1.Domici as DirTra,
--            T1.Ruc as RucTra,
--            T1.PunPar as PunParTra,
            dca.direc1                       AS desenv01,
            dca.direc2                       AS desenv02,
            d.codalm                         AS codalm,
            al.descri                        AS desalm,
            d.tipinv                         AS tipinv,
            d.codart                         AS codart,
--            CASE
--                WHEN c33.codigo <> 'S' THEN
--                    a.descri
--                ELSE
--                    CASE
--                        WHEN lpa33.desart <> '' THEN
--                                lpa33.desart
--                        ELSE
--                            CASE
--                                WHEN lp33.desart <> '' THEN
--                                            lp33.desart
--                                ELSE
--                                    a.descri
--                            END
--                    END
--            END                              AS desart,
            CASE
                WHEN c33.codigo != 'S' THEN
                    a.descri
                ELSE
                    CASE
                        WHEN lpa33.desart != '' THEN
                                lpa33.desart
                        ELSE
                            CASE
                                WHEN lp33.desart IS NOT NULL
                                     AND length(lp33.desart) > 0 THEN
                                            lp33.desart
                                ELSE
                                    a.descri
                            END
                    END
            END                              AS desart,
            a.faccon                         AS faccon,
            a.consto                         AS consto,
            d.largo * a.faccon               AS peslar,
            ( d.cantid * a.faccon ) + CAST(
                CASE
                    WHEN cc2.abrevi IS NULL THEN
                        CAST('0' AS VARCHAR(6))
                    ELSE
                        cc2.abrevi
                END
            AS NUMERIC(16,
     5))                              AS pesdet,
            cc2.abrevi                       AS taraadic,
            a.codart
            || ' '
            || a.descri                      AS coddesart,
            agl.observ                       AS desglosa,
            d.cantid                         AS cantid,
            d.canref                         AS canref,
            d.piezas                         AS piezas,
            d.tara                           AS tara,
            d.largo                          AS largo,
            d.etiqueta                       AS etiqueta,
            d.etiqueta2                      AS etiqueta2,
            a.coduni                         AS codund,
            d.codadd01                       AS codcalid,
            d.codadd02                       AS codcolor,
            d.opronumdoc                     AS opronumdoc,
            d.opnumdoc                       AS dopnumdoc,
            d.opcargo                        AS dopcargo,
            d.opnumite                       AS dopnumite,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.preuni * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.preuni
            END                              AS preuni,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.importe_bruto * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe_bruto
            END                              AS importe_bruto,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.importe * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe
            END                              AS importe,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    ( d.importe_bruto - d.importe ) * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe_bruto - d.importe
            END                              AS descdet,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    ( d.importe /
                      CASE
                          WHEN d.cantid IS NULL
                               OR d.cantid = 0 THEN
                                CAST(1 AS NUMERIC(16, 5))
                          ELSE
                              d.cantid
                      END
                    ) * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    ( d.importe /
                      CASE
                          WHEN d.cantid IS NULL
                               OR d.cantid = 0 THEN
                                CAST(1 AS NUMERIC(16, 5))
                          ELSE
                              d.cantid
                      END
                    )
            END                              AS preuni02,
            d.preuni                         AS preunireal,
            d.importe                        AS importereal,
            d.codund                         AS codunidet,
            d.pordes1                        AS pordes1,
            d.pordes2                        AS pordes2,
            d.pordes3                        AS pordes3,
            d.pordes4                        AS pordes4,
            d.monafe + d.monina              AS monlinneto,
            d.monafe                         AS monafedet,
            d.monigv                         AS monigvdet,
            d.monisc                         AS moniscdet,
            d.monotr                         AS monotrdet,
--            D.LARGO * A.FacCon as PesLar,
            d.nrocarrete                     AS nrocarrete,
            d.acabado                        AS acabado,
            d.chasis,
            d.motor,
            d.lote                           AS lote,
            d.fvenci                         AS fvenci,
            d.ancho                          AS ancho,
            CASE
                WHEN ( ( fap.vstrg IS NOT NULL )
                       AND ( upper(fap.vstrg) = 'S' )
                       AND ( ddp.vreal IS NOT NULL )
                       AND ( ddp.vreal > 0 ) ) THEN
                    CAST('*' AS VARCHAR(20))
                ELSE
                    CAST('' AS VARCHAR(20))
            END                              AS astpercep,
--            (D.Cantid * A.FacCon) + Cast(Case When Cc2.Abrevi is null Then CAST('0' AS VARCHAR(6) )  Else CC2.Abrevi End as Numeric(16,5) ) as PesDet, 
            CASE
                WHEN d.cantid IS NULL
                     OR d.cantid = 0 THEN
                    CAST(0 AS NUMERIC(16, 5))
                ELSE
                    ( d.monafe + d.monina ) / d.cantid
            END                              AS monuni,
            d.observ                         AS obsdet,
            ac3.codigo                       AS codfam,
            cc3.descri                       AS desfam,
            ac4.codigo                       AS codmod,
            cc4.descri                       AS desmod,
            ac5.codigo                       AS codlin,
            cc5.descri                       AS deslin,
            cl1.descri                       AS dcalidad,
            cl1.abrevi                       AS acalidad,
            cl2.codigo
            || '-'
            || cl2.descri                    AS dcolor,
--            CL2.DESCRI AS DColor2,
            cl2.descri                       AS color,
            CASE
                WHEN ac2.codigo IS NULL THEN
                    CAST('N' AS VARCHAR(20))
                ELSE
                    ac2.codigo
            END                              AS glosxdes,
            (
                SELECT
                    glosa
                FROM
                    companias_glosa
                WHERE
                        id_cia = c.id_cia
                    AND item = 24
            )                                AS gpiefac,
            gar.glosa                        AS glosagar,
            gap.glosa                        AS glosagap,
            gfp.glosa                        AS glosagfp,
            gfecab.glosa                     AS glosagfecab,
            gfepie.glosa                     AS glosagfepie,
            gfemen.glosa                     AS glosagfemen,
            (
                SELECT
                    glosa
                FROM
                    companias_glosa
                WHERE
                        id_cia = c.id_cia
                    AND item = 16
            )                                AS gdfis,
            cal.abrevi                       AS calidabrev,
            (
                CASE
                    WHEN aca1.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 6))
                    ELSE
                        aca1.vreal
                END
            )                                AS valundaltven,
            ds.signvalue,
            nvl(c.acuenta, 0),
            CAST(
                CASE
                    WHEN(c.destin = 2
                         AND c.monina > 0)
                        OR(c1.codtpe <> 3
                           AND c22.codigo = 'S') THEN
                        c.monina
                    ELSE
                        CAST(0 AS NUMERIC(16, 2))
                END
            AS NUMERIC(16,
                 2))                         AS totexo,
            c.monisc                         AS totisc,
--            C.MARCAS AS MARCAS,
            CAST(0 AS NUMERIC(16, 2))        AS totoca,
            CAST(c.monotr AS NUMERIC(16, 2)) AS tototr,
            ( cc14.descri
              || ','
              || cc15.descri
              || ','
              || cc16.descri )                 AS ubigeo,
            ( cc16.descri
              || ' - '
              || cc15.descri
              || ' - '
              || cc14.descri )                 AS ubigeo_b,
            doc.fecha                        AS fecha_dcorcom,
            doc.numero                       AS numero_dcorcom,
            doc.contacto                     AS contacto_dcorcom,
            c.usuari,
            dcc11.codigo                     AS incoterm,
            ccc11.descri                     AS desincoterm,
            dcc12.vstrg                      AS destinofinal,
            dcc15.vstrg                      AS puertoembarque,
            dcc16.vstrg                      AS contenedor,
            dcc17.vstrg                      AS booking,
            dcc18.codigo                     AS certificado,
            ccc18.descri                     AS descertificado,
            cc10.descri                      AS pais,
            s2.dessit                        AS dessit,
            s2.alias                         AS aliassit,
            c.pesnet,
            und.abrevi                       AS abrunidad,
            cac10.codigo                     AS direnv_pais,
            ca14.descri                      AS direnv_dep,
            ca15.descri                      AS direnv_pro,
            ca16.descri                      AS direnv_dis,
            c.direccpar                      AS direccpar,
            c.ubigeopar                      AS ubigeopar,
            cao14.descri                     AS dirpar_dep,
            cao15.descri                     AS dirpar_pro,
            cao16.descri                     AS dirpar_dis,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.destra
                ELSE
                    t1.razonc
            END                              AS razonctra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.chofer
                ELSE
                    t1.descri
            END                              AS destra,
            t1.domici                        AS dirtra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.ruc
                ELSE
                    t1.ruc
            END                              AS ructra,
            t1.punpar                        AS punpartra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.licenc
                ELSE
                    t1.licenc
            END                              AS licenciatra,
            t1.placa                         AS placatra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.certif
                ELSE
                    t1.certif
            END                              AS certiftra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.telef1
                ELSE
                    t1.telef1
            END                              AS fonotra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.desveh
                ELSE
                    vh.descri
            END                              AS desveh,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.tipo
                ELSE
                    vh.tipo
            END                              AS tipoveh,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.marca
                ELSE
                    vh.marca
            END                              AS marcaveh,
            CASE
                WHEN length(
                    CASE
                        WHEN t1.swdattra = 'S' THEN
                            dct.ruc
                        ELSE
                            t1.ruc
                    END
                ) = 11 THEN
                    CAST('6' AS VARCHAR(15))
                ELSE
                    CAST('0' AS VARCHAR(15))
            END                              AS tidentra,
            CASE
                WHEN t1.chofer_tident IS NULL THEN
                    dct.chofer_tident
                ELSE
                    t1.chofer_tident
            END                              AS tidentconductor,
            CASE
                WHEN t1.chofer_tident IS NULL THEN
                    (
                        SELECT
                            descri
                        FROM
                            identidad
                        WHERE
                                id_cia = dct.id_cia
                            AND tident = dct.chofer_tident
                    )
                ELSE
                    (
                        SELECT
                            descri
                        FROM
                            identidad
                        WHERE
                                id_cia = t1.id_cia
                            AND tident = t1.chofer_tident
                    )
            END                              AS destidentconductor,
            CASE
                WHEN t1.chofer_dident IS NULL THEN
                    dct.chofer_dident
                ELSE
                    t1.chofer_dident
            END                              AS didentconductor,
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
            END                              AS placavehiculo,
            CAST((
                CASE
                    WHEN(mt34.valor IS NULL) THEN
                        CAST('0' AS VARCHAR(25))
                    ELSE
                        mt34.valor
                END
            ) AS SMALLINT)                   AS tiponcresunat,
            CAST((
                CASE
                    WHEN(mt35.valor IS NULL) THEN
                        CAST('0' AS VARCHAR(25))
                    ELSE
                        mt35.valor
                END
            ) AS SMALLINT)                   AS tipondebsunat,
            df.formato                       AS formato
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab                c
            LEFT OUTER JOIN documentos                    dc ON dc.id_cia = c.id_cia
                                             AND ( dc.codigo = c.tipdoc )
                                             AND ( dc.series = c.series )
            LEFT OUTER JOIN cliente                       c1 ON c1.id_cia = c.id_cia
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN cliente_tpersona              ct ON ct.id_cia = c.id_cia
                                                   AND ( ct.codcli = c.codcli )
            LEFT OUTER JOIN identidad                     i ON i.id_cia = c.id_cia
                                           AND ( i.tident = c1.tident )
            LEFT OUTER JOIN almacen                       ald ON ald.id_cia = c.id_cia
                                           AND ( ald.tipinv = 1 )
                                           AND ( ald.codalm = c.almdes )
            LEFT OUTER JOIN documentos_cab_clase          cc ON cc.id_cia = c.id_cia
                                                       AND ( cc.numint = c.numint )
                                                       AND ( cc.clase = 6 )
            LEFT OUTER JOIN documentos_cab_clase          dcc11 ON dcc11.id_cia = c.id_cia
                                                          AND ( dcc11.numint = c.numint )
                                                          AND ( dcc11.clase = 11 )
                                                          AND ( dcc11.codigo <> 'ND' )
            LEFT OUTER JOIN clase_documentos_cab_codigo   ccc11 ON ccc11.id_cia = c.id_cia
                                                                 AND ( ccc11.clase = dcc11.clase )
                                                                 AND ( ccc11.codigo = dcc11.codigo )
                                                                 AND ( ccc11.tipdoc = c.tipdoc )
            LEFT OUTER JOIN documentos_cab_clase          dcc12 ON dcc12.id_cia = c.id_cia
                                                          AND ( dcc12.numint = c.numint )
                                                          AND ( dcc12.clase = 12 )
            LEFT OUTER JOIN documentos_cab_clase          dcc15 ON dcc15.id_cia = c.id_cia
                                                          AND ( dcc15.numint = c.numint )
                                                          AND ( dcc15.clase = 15 )
            LEFT OUTER JOIN documentos_cab_clase          dcc16 ON dcc16.id_cia = c.id_cia
                                                          AND ( dcc16.numint = c.numint )
                                                          AND ( dcc16.clase = 16 )
            LEFT OUTER JOIN documentos_cab_clase          dcc17 ON dcc17.id_cia = c.id_cia
                                                          AND ( dcc17.numint = c.numint )
                                                          AND ( dcc17.clase = 17 )
            LEFT OUTER JOIN documentos_cab_clase          dcc18 ON dcc18.id_cia = c.id_cia
                                                          AND ( dcc18.numint = c.numint )
                                                          AND ( dcc18.clase = 18 )
            LEFT OUTER JOIN clase_documentos_cab_codigo   ccc18 ON ccc18.id_cia = c.id_cia
                                                                 AND ( ccc18.clase = dcc18.clase )
                                                                 AND ( ccc18.codigo = dcc18.codigo )
                                                                 AND ( ccc18.tipdoc = c.tipdoc )
            LEFT OUTER JOIN c_pago                        cv ON cv.id_cia = c.id_cia
                                         AND ( cv.codpag = c.codcpag )
                                         AND ( upper(cv.swacti) = 'S' )
            LEFT OUTER JOIN c_pago_clase                  cvc ON cvc.id_cia = c.id_cia
                                                AND ( cvc.codpag = c.codcpag )
                                                AND ( cvc.codigo = 1 )
            LEFT OUTER JOIN tmoneda                       m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN sucursal                      s1 ON s1.id_cia = c.id_cia
                                           AND ( s1.codsuc = c.codsuc )
            LEFT OUTER JOIN motivos                       mt ON mt.id_cia = c.id_cia
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( c.tipdoc = mt.tipdoc )
            LEFT OUTER JOIN motivos_clase                 mt16 ON mt16.id_cia = c.id_cia
                                                  AND ( mt16.codmot = c.codmot )
                                                  AND ( mt16.id = c.id )
                                                  AND ( mt16.tipdoc = c.tipdoc )
                                                  AND ( mt16.codigo = 16 )
            LEFT OUTER JOIN motivos_clase                 mt19 ON mt19.id_cia = c.id_cia
                                                  AND ( mt19.codmot = c.codmot )
                                                  AND ( mt19.id = c.id )
                                                  AND ( mt19.tipdoc = c.tipdoc )
                                                  AND ( mt19.codigo = 19 )
            LEFT OUTER JOIN clase_clientes_almacen_codigo cao14 ON cao14.id_cia = c.id_cia
                                                                   AND cao14.clase = 14
                                                                   AND cao14.codigo = CAST(substr(c.ubigeopar, 1, 2) AS VARCHAR(10))
            LEFT OUTER JOIN clase_clientes_almacen_codigo cao15 ON cao15.id_cia = c.id_cia
                                                                   AND cao15.clase = 15
                                                                   AND cao15.codigo = CAST(substr(c.ubigeopar, 1, 4) AS VARCHAR(10))
            LEFT OUTER JOIN clase_clientes_almacen_codigo cao16 ON cao16.id_cia = c.id_cia
                                                                   AND cao16.clase = 16
                                                                   AND cao16.codigo = c.ubigeopar
            LEFT OUTER JOIN documentos_cab_almacen        dca ON dca.id_cia = c.id_cia
                                                          AND ( c.numint = dca.numint )
            LEFT OUTER JOIN clientes_almacen_clase        cac10 ON cac10.id_cia = c.id_cia
                                                            AND cac10.codcli = c.codcli
                                                            AND cac10.codenv = dca.codenv
                                                            AND cac10.clase = 10
            LEFT OUTER JOIN clientes_almacen_clase        cac14 ON cac14.id_cia = c.id_cia
                                                            AND cac14.codcli = c.codcli
                                                            AND cac14.codenv = dca.codenv
                                                            AND cac14.clase = 14
            LEFT OUTER JOIN clase_clientes_almacen_codigo ca14 ON ca14.id_cia = c.id_cia
                                                                  AND ca14.clase = cac14.clase
                                                                  AND ca14.codigo = cac14.codigo
            LEFT OUTER JOIN clientes_almacen_clase        cac15 ON cac15.id_cia = c.id_cia
                                                            AND cac15.codcli = c.codcli
                                                            AND cac15.codenv = dca.codenv
                                                            AND cac15.clase = 15
            LEFT OUTER JOIN clase_clientes_almacen_codigo ca15 ON ca15.id_cia = c.id_cia
                                                                  AND ca15.clase = cac15.clase
                                                                  AND ca15.codigo = cac15.codigo
            LEFT OUTER JOIN clientes_almacen_clase        cac16 ON cac16.id_cia = c.id_cia
                                                            AND cac16.codcli = c.codcli
                                                            AND cac16.codenv = dca.codenv
                                                            AND cac16.clase = 16
            LEFT OUTER JOIN clase_clientes_almacen_codigo ca16 ON ca16.id_cia = c.id_cia
                                                                  AND ca16.clase = cac16.clase
                                                                  AND ca16.codigo = cac16.codigo
            LEFT OUTER JOIN documentos_cab_ordcom         doc ON doc.id_cia = c.id_cia
                                                         AND ( c.numint = doc.numint )
            LEFT OUTER JOIN transportista                 t1 ON t1.id_cia = c.id_cia
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN documentos_cab_transportista  dct ON dct.id_cia = c.id_cia
                                                                AND ( dct.numint = c.numint )
            LEFT OUTER JOIN vehiculos                     vh ON vh.id_cia = c.id_cia
                                            AND ( vh.codveh = c.codveh )
            LEFT OUTER JOIN documentos_cab_clase          dct4 ON dct4.id_cia = c.id_cia
                                                         AND dct4.numint = c.numint
                                                         AND dct4.clase = 4
            LEFT OUTER JOIN documentos_cab_clase          dcp ON dcp.id_cia = c.id_cia
                                                        AND dcp.numint = c.numint
                                                        AND dcp.clase = 3
            LEFT OUTER JOIN cliente_clase                 ccc ON ccc.id_cia = c.id_cia
                                                 AND ( ccc.tipcli = 'A' )
                                                 AND ( ccc.codcli = c.codcli )
                                                 AND ( ccc.clase = 23 )
            LEFT OUTER JOIN cliente_clase                 c33 ON c33.id_cia = c.id_cia
                                                 AND ( c33.tipcli = 'A' )
                                                 AND ( c33.codcli = c.codcli )
                                                 AND ( c33.clase = 33 )
            LEFT OUTER JOIN cliente_clase                 c10 ON c10.id_cia = c.id_cia
                                                 AND ( c10.tipcli = 'A' )
                                                 AND ( c10.codcli = c.codcli )
                                                 AND ( c10.clase = 10 )
                                                 AND ( c10.codigo <> 'ND' )
            LEFT OUTER JOIN clase_cliente_codigo          cc10 ON cc10.id_cia = c.id_cia
                                                         AND cc10.clase = c10.clase
                                                         AND cc10.codigo = c10.codigo
                                                         AND cc10.tipcli = c10.tipcli
            LEFT OUTER JOIN cliente_clase                 c14 ON c14.id_cia = c.id_cia
                                                 AND ( c14.tipcli = 'A' )
                                                 AND ( c14.codcli = c.codcli )
                                                 AND ( c14.clase = 14 )
                                                 AND ( c14.codigo <> 'ND' )
            LEFT OUTER JOIN clase_cliente_codigo          cc14 ON cc14.id_cia = c.id_cia
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase                 c15 ON c15.id_cia = c.id_cia
                                                 AND ( c15.tipcli = 'A' )
                                                 AND ( c15.codcli = c.codcli )
                                                 AND ( c15.clase = 15 )
                                                 AND ( c15.codigo <> 'ND' )
            LEFT OUTER JOIN clase_cliente_codigo          cc15 ON cc15.id_cia = c.id_cia
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase                 c16 ON c16.id_cia = c.id_cia
                                                 AND ( c16.tipcli = 'A' )
                                                 AND ( c16.codcli = c.codcli )
                                                 AND ( c16.clase = 16 )
                                                 AND ( c16.codigo <> 'ND' )
            LEFT OUTER JOIN clase_cliente_codigo          cc16 ON cc16.id_cia = c.id_cia
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN cliente_clase                 c22 ON c22.id_cia = c.id_cia
                                                 AND c22.tipcli = 'A'
                                                 AND c22.codcli = c.codcli
                                                 AND c22.clase = 22
                                                 AND NOT ( c22.codigo = 'ND' )
            LEFT OUTER JOIN vendedor                      v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN factor                        far ON far.id_cia = c.id_cia
                                          AND ( far.codfac = 331 )
            LEFT OUTER JOIN factor                        fap ON fap.id_cia = c.id_cia
                                          AND ( fap.codfac = 332 )
            LEFT OUTER JOIN companias_glosa               gar ON gar.id_cia = c.id_cia
                                                   AND ( far.vstrg IS NOT NULL )
                                                   AND ( upper(far.vstrg) = 'S' )
                                                   AND ( gar.item = 15 )
            LEFT OUTER JOIN companias_glosa               gap ON gap.id_cia = c.id_cia
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( gap.item = 13 )
            LEFT OUTER JOIN companias_glosa               gfp ON gfp.id_cia = c.id_cia
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( dcp.codigo IS NOT NULL )
                                                   AND ( upper(dcp.codigo) = 'S' )
                                                   AND ( gfp.item = 14 )
            LEFT OUTER JOIN companias_glosa               gfecab ON gfecab.id_cia = c.id_cia
                                                      AND ( gfecab.item = 31 )
            LEFT OUTER JOIN companias_glosa               gfepie ON gfepie.id_cia = c.id_cia
                                                      AND ( gfepie.item = 32 )
            LEFT OUTER JOIN companias_glosa               gfemen ON gfemen.id_cia = c.id_cia
                                                      AND ( gfemen.item = 33 )
            LEFT OUTER JOIN documentos_det                d ON d.id_cia = c.id_cia
                                                AND ( d.numint = c.numint )
            LEFT OUTER JOIN documentos_det_clase          ddp ON ddp.id_cia = c.id_cia
                                                        AND ( ddp.numint = d.numint )
                                                        AND ( ddp.numite = d.numite )
                                                        AND ( ddp.clase = 50 )
            LEFT OUTER JOIN almacen                       al ON al.id_cia = c.id_cia
                                          AND ( al.tipinv = d.tipinv )
                                          AND ( al.codalm = d.codalm )
            LEFT OUTER JOIN articulos                     a ON a.id_cia = c.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN listaprecios                  lp33 ON lp33.id_cia = c.id_cia
                                                 AND lp33.vencom = 1
                                                 AND lp33.codtit = c1.codtit
                                                 AND lp33.tipinv = d.tipinv
                                                 AND lp33.codart = d.codart
            LEFT OUTER JOIN listaprecios_alternativa      lpa33 ON lpa33.id_cia = c.id_cia
                                                              AND lpa33.vencom = 1
                                                              AND lpa33.codtit = c1.codtit
                                                              AND lpa33.tipinv = d.tipinv
                                                              AND lpa33.codart = d.codart
                                                              AND lpa33.codadd01 = d.codadd01
                                                              AND lpa33.codadd02 = d.codadd02
            LEFT OUTER JOIN articulos_glosa               agl ON agl.id_cia = c.id_cia
                                                   AND ( agl.tipo = 2 )
                                                   AND ( agl.tipinv = d.tipinv )
                                                   AND ( agl.codart = d.codart )
            LEFT OUTER JOIN articulos_clase               ac1 ON ac1.id_cia = c.id_cia
                                                   AND ( ac1.tipinv = d.tipinv )
                                                   AND ( ac1.codart = d.codart )
                                                   AND ( ac1.clase = 81 )
            LEFT OUTER JOIN articulos_clase               ac2 ON ac2.id_cia = c.id_cia
                                                   AND ( ac2.tipinv = d.tipinv )
                                                   AND ( ac2.codart = d.codart )
                                                   AND ( ac2.clase = 87 )
            LEFT OUTER JOIN articulos_clase               ac3 ON ac3.id_cia = c.id_cia
                                                   AND ( ac3.tipinv = d.tipinv )
                                                   AND ( ac3.codart = d.codart )
                                                   AND ( ac3.clase = 2 )
            LEFT OUTER JOIN articulos_clase               ac4 ON ac4.id_cia = c.id_cia
                                                   AND ( ac4.tipinv = d.tipinv )
                                                   AND ( ac4.codart = d.codart )
                                                   AND ( ac4.clase = 51 )
            LEFT OUTER JOIN articulos_clase               ac5 ON ac5.id_cia = c.id_cia
                                                   AND ( ac5.tipinv = d.tipinv )
                                                   AND ( ac5.codart = d.codart )
                                                   AND ( ac5.clase = 3 )
            LEFT OUTER JOIN clase_codigo                  cc2 ON cc2.id_cia = c.id_cia
                                                AND ( cc2.tipinv = ac1.tipinv )
                                                AND ( cc2.clase = ac1.clase )
                                                AND ( cc2.codigo = ac1.codigo )
            LEFT OUTER JOIN clase_codigo                  cc3 ON cc3.id_cia = c.id_cia
                                                AND ( cc3.tipinv = ac3.tipinv )
                                                AND ( cc3.clase = ac3.clase )
                                                AND ( cc3.codigo = ac3.codigo )
            LEFT OUTER JOIN clase_codigo                  cc4 ON cc4.id_cia = c.id_cia
                                                AND ( cc4.tipinv = ac4.tipinv )
                                                AND ( cc4.clase = ac4.clase )
                                                AND ( cc4.codigo = ac4.codigo )
            LEFT OUTER JOIN clase_codigo                  cc5 ON cc5.id_cia = c.id_cia
                                                AND ( cc5.tipinv = ac5.tipinv )
                                                AND ( cc5.clase = ac5.clase )
                                                AND ( cc5.codigo = ac5.codigo )
            LEFT OUTER JOIN cliente_articulos_clase       cl1 ON cl1.id_cia = c.id_cia
                                                           AND ( cl1.tipcli = 'B' )
                                                           AND ( cl1.codcli = a.codprv )
                                                           AND ( cl1.clase = 1 )
                                                           AND ( cl1.codigo = d.codadd01 )
            LEFT OUTER JOIN cliente_articulos_clase       cl2 ON cl2.id_cia = c.id_cia
                                                           AND ( cl2.tipcli = 'B' )
                                                           AND ( cl2.codcli = a.codprv )
                                                           AND ( cl2.clase = 2 )
                                                           AND ( cl2.codigo = d.codadd02 )
            LEFT OUTER JOIN calidad                       cal ON cal.id_cia = c.id_cia
                                           AND ( cal.codigo = d.codadd01 )
            LEFT OUTER JOIN articulos_clase_alternativo   aca1 ON aca1.id_cia = c.id_cia
                                                                AND aca1.tipinv = d.tipinv
                                                                AND aca1.codart = d.codart
                                                                AND aca1.clase = 1
                                                                AND aca1.codigo = d.codund
            LEFT OUTER JOIN documentos_cab_envio_sunat    ds ON ds.id_cia = c.id_cia
                                                             AND ( ds.numint = c.numint )
            LEFT OUTER JOIN situacion                     s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT JOIN unidad                        und ON und.id_cia = c.id_cia
                                    AND und.coduni = d.codund
            LEFT OUTER JOIN motivos_clase                 mt34 ON mt34.id_cia = c.id_cia
                                                  AND ( mt34.codmot = c.codmot )
                                                  AND ( mt34.id = c.id )
                                                  AND ( mt34.tipdoc = c.tipdoc )
                                                  AND ( mt34.codigo = 34 )
            LEFT OUTER JOIN motivos_clase                 mt35 ON mt35.id_cia = c.id_cia
                                                  AND ( mt35.codmot = c.codmot )
                                                  AND ( mt35.id = c.id )
                                                  AND ( mt35.tipdoc = c.tipdoc )
                                                  AND ( mt35.codigo = 35 )
            LEFT OUTER JOIN documentos_formatos           df ON df.tipdoc = dc.codigo
                                                      AND df.item = nvl(dc.tipimp, 1)
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
            c.tipdoc,
            c.numint,
            d.positi,
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_notadebito;

    FUNCTION sp_notadebito_groupby (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_notadebito
        PIPELINED
    AS
        v_table datatable_notadebito;
    BEGIN
        SELECT
            t.id_cia,
            t.tipdoc,
            t.nomdoc,
            t.codsuc,
            t.numint,
            NULL, -- numite,
            t.series,
            t.numdoc,
            t.femisi,
            t.codcli,
            t.razonc,
            t.direc1,
            t.ruc,
            t.dircli1,
            t.dircli2,
            t.tlfcli,
            t.faxcli,
            t.dident,
            t.tident_cab,
            t.destident,
            t.abrtident,
            t.nrodni,
            t.guiarefe,
            t.codalmdes,
            t.desalmdes,
            t.abralmdes,
            t.marcas,
            t.presen,
            t.codsec,
            t.facpro,
            t.ffacpro,
            t.codven,
            t.obscab,
            t.tipcam,
            t.tipmon,
            t.totbru,
            t.desesp,
            t.descue,
            t.monafe,
            t.monina,
            t.monneto,
            t.monigv,
            t.preven,
            t.percep,
            t.totpag,
            t.relcossalprod,
            t.flete,
            t.seguro,
            t.porigv,
            t.comiven,
            t.codmot,
            t.numped,
            t.despagven,
            t.enctacte,
            t.ordcom,
            t.fordcom,
            t.simbolo,
            t.desmon,
            t.opnumdoc,
            t.horing,
            t.fecter,
            t.horter,
            t.desnetx,
            t.despreven,
            t.desfle,
            t.desseg,
            t.desgasa,
            t.gasadu,
            t.situac,
            t.destin,
            t.id,
            t.desmot,
            t.docayuda,
            t.swdocpercep,
            t.porpercep,
            t.exoimp,
            t.diaven,
            t.dessuc,
            t.dissuc,
            t.desven,
            t.desenv01,
            t.desenv02,
            t.codalm,
            t.desalm,
            t.tipinv,
            t.codart,
            t.desart,
            NULL, --faccon,
            NULL, -- consto,
            SUM(t.peslar),
            SUM(t.pesdet),
            NULL, --t.taraadic,
            t.coddesart,
            t.desglosa,
            SUM(t.cantid),
            SUM(t.canref),
            SUM(t.piezas),
            NULL, --tara
            NULL, --largo
            NULL, --etiqeuta
            NULL, --etiqueta2
            t.codund,
            t.codcalid,
            t.codcolor,
            t.opronumdoc,
            t.dopnumdoc,
            NULL, --dopcargo,
            NULL, -- dopnumite,
            t.preuni,
            SUM(t.importe_bruto),
            SUM(t.importe),
            t.descdet,
            t.preuni02,
            t.preunireal,
            SUM(t.importereal),
            t.codunidet,
            t.pordes1,
            t.pordes2,
            t.pordes3,
            t.pordes4,
            SUM(t.monlinneto),
            SUM(t.monafedet),
            SUM(t.monigvdet),
            SUM(t.moniscdet),
            SUM(t.monotrdet),
            t.nrocarrete,
            t.acabado,
            NULL,--t.chasis,
            NULL,--t.motor,
            t.lote,
            t.fvenci,
            t.ancho,
            t.astpercep,
            SUM(t.monuni),
            NULL,-- obsdet
            t.codfam,
            t.desfam,
            t.codmod,
            t.desmod,
            t.codlin,
            t.deslin,
            t.dcalidad,
            t.acalidad,
            t.dcolor,
            t.color,
            t.glosxdes,
            t.gpiefac,
            t.glosagar,
            t.glosagap,
            t.glosagfp,
            t.glosagfecab,
            t.glosagfepie,
            t.glosagfemen,
            t.gdfis,
            t.calidabrev,
            t.valundaltven,
            t.signvalue,
            t.acuenta,
            t.totexo,
            t.totisc,
            t.totoca,
            t.tototr,
            t.ubigeo,
            t.ubigeo_b,
            t.fecha_dcorcom,
            t.numero_dcorcom,
            t.contacto_dcorcom,
            t.usuari,
            t.incoterm,
            t.desincoterm,
            t.destinofinal,
            t.puertoembarque,
            t.contenedor,
            t.booking,
            t.certificado,
            t.descertificado,
            t.pais,
            t.dessit,
            t.aliassit,
            t.pesnet,
            t.abrunidad,
            t.direnv_pais,
            t.direnv_dep,
            t.direnv_pro,
            t.direnv_dis,
            t.direccpar,
            t.ubigeopar,
            t.dirpar_dep,
            t.dirpar_pro,
            t.dirpar_dis,
            t.razonctra,
            t.destra,
            t.dirtra,
            t.ructra,
            t.punpartra,
            t.licenciatra,
            t.placatra,
            t.certiftra,
            t.fonotra,
            t.desveh,
            t.tipoveh,
            t.marcaveh,
            t.tidentra,
            t.tidentconductor,
            t.destidentconductor,
            t.didentconductor,
            t.placavehiculo,
            t.tiponcresunat,
            t.tipondebsunat,
            t.formato
        BULK COLLECT
        INTO v_table
        FROM
            pack_reportes_trazabilidad.sp_notadebito(pin_id_cia, pin_numint) t
        GROUP BY
            t.id_cia,
            t.tipdoc,
            t.nomdoc,
            t.codsuc,
            t.numint,
            NULL, -- numite,
            t.series,
            t.numdoc,
            t.femisi,
            t.codcli,
            t.razonc,
            t.direc1,
            t.ruc,
            t.dircli1,
            t.dircli2,
            t.tlfcli,
            t.faxcli,
            t.dident,
            t.tident_cab,
            t.destident,
            t.abrtident,
            t.nrodni,
            t.guiarefe,
            t.codalmdes,
            t.desalmdes,
            t.abralmdes,
            t.marcas,
            t.presen,
            t.codsec,
            t.facpro,
            t.ffacpro,
            t.codven,
            t.obscab,
            t.tipcam,
            t.tipmon,
            t.totbru,
            t.desesp,
            t.descue,
            t.monafe,
            t.monina,
            t.monneto,
            t.monigv,
            t.preven,
            t.percep,
            t.totpag,
            t.relcossalprod,
            t.flete,
            t.seguro,
            t.porigv,
            t.comiven,
            t.codmot,
            t.numped,
            t.despagven,
            t.enctacte,
            t.ordcom,
            t.fordcom,
            t.simbolo,
            t.desmon,
            t.opnumdoc,
            t.horing,
            t.fecter,
            t.horter,
            t.desnetx,
            t.despreven,
            t.desfle,
            t.desseg,
            t.desgasa,
            t.gasadu,
            t.situac,
            t.destin,
            t.id,
            t.desmot,
            t.docayuda,
            t.swdocpercep,
            t.porpercep,
            t.exoimp,
            t.diaven,
            t.dessuc,
            t.dissuc,
            t.desven,
            t.desenv01,
            t.desenv02,
            t.codalm,
            t.desalm,
            t.tipinv,
            t.codart,
            t.desart,
            NULL, --faccon,
            NULL, -- consto,
--            SUM(t.peslar),
--            SUM(t.pesdet),
            NULL, --t.taraadic,
            t.coddesart,
            t.desglosa,
--            SUM(t.cantid),
--            SUM(t.canref),
--            SUM(t.piezas),
            NULL, --tara
            NULL, --largo
            NULL, --etiqeuta
            NULL, --etiqueta2
            t.codund,
            t.codcalid,
            t.codcolor,
            t.opronumdoc,
            t.dopnumdoc,
            NULL, --dopcargo,
            NULL, -- dopnumite,
            t.preuni,
--            SUM(t.importe_bruto),
--            SUM(t.importe),
            t.descdet,
            t.preuni02,
            t.preunireal,
--            SUM(t.importereal),
            t.codunidet,
            t.pordes1,
            t.pordes2,
            t.pordes3,
            t.pordes4,
--            SUM(t.monlinneto),
--            SUM(t.monafedet),
--            SUM(t.monigvdet),
--            SUM(t.moniscdet),
--            SUM(t.monotrdet),
            t.nrocarrete,
            t.acabado,
            NULL,--t.chasis,
            NULL,--t.motor,
            t.lote,
            t.fvenci,
            t.ancho,
            t.astpercep,
--            SUM(t.monuni),
            NULL,-- obsdet
            t.codfam,
            t.desfam,
            t.codmod,
            t.desmod,
            t.codlin,
            t.deslin,
            t.dcalidad,
            t.acalidad,
            t.dcolor,
            t.color,
            t.glosxdes,
            t.gpiefac,
            t.glosagar,
            t.glosagap,
            t.glosagfp,
            t.glosagfecab,
            t.glosagfepie,
            t.glosagfemen,
            t.gdfis,
            t.calidabrev,
            t.valundaltven,
            t.signvalue,
            t.acuenta,
            t.totexo,
            t.totisc,
            t.totoca,
            t.tototr,
            t.ubigeo,
            t.ubigeo_b,
            t.fecha_dcorcom,
            t.numero_dcorcom,
            t.contacto_dcorcom,
            t.usuari,
            t.incoterm,
            t.desincoterm,
            t.destinofinal,
            t.puertoembarque,
            t.contenedor,
            t.booking,
            t.certificado,
            t.descertificado,
            t.pais,
            t.dessit,
            t.aliassit,
            t.pesnet,
            t.abrunidad,
            t.direnv_pais,
            t.direnv_dep,
            t.direnv_pro,
            t.direnv_dis,
            t.direccpar,
            t.ubigeopar,
            t.dirpar_dep,
            t.dirpar_pro,
            t.dirpar_dis,
            t.razonctra,
            t.destra,
            t.dirtra,
            t.ructra,
            t.punpartra,
            t.licenciatra,
            t.placatra,
            t.certiftra,
            t.fonotra,
            t.desveh,
            t.tipoveh,
            t.marcaveh,
            t.tidentra,
            t.tidentconductor,
            t.destidentconductor,
            t.didentconductor,
            t.placavehiculo,
            t.tiponcresunat,
            t.tipondebsunat,
            t.formato
        ORDER BY
            t.tipinv,
            t.codart,
            t.preuni,
            t.pordes1,
            t.pordes2,
            t.pordes3,
            t.pordes4,
            t.lote,
            t.fvenci;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_notadebito_groupby;

    FUNCTION sp_ordenpedido (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_ordenpedido
        PIPELINED
    AS
        v_table datatable_ordenpedido;
    BEGIN
        SELECT
            c.id_cia,
            c.numint                            AS numint,
            d.numite                            AS numite,
            c.series                            AS series,
            c.numdoc                            AS numdoc,
            c.femisi                            AS femisi,
            c.codsuc,
            c.opnumdoc                          AS opnumdoc,
            c.razonc                            AS razonc,
            c.direc1                            AS direc1,
            c.ruc                               AS ruc,
            c.tipmon                            AS tipmon,
            c.fentreg                           AS fentreg,
            c.fecter                            AS fecter,
            c.horter                            AS horter,
            c.observ                            AS obscab,
            c.monafe                            AS monafe,
            c.monina                            AS monina,
            c.monafe + c.monina + c.monexo      AS monneto,
            c.monexo                            AS monexo,
            c.monigv                            AS monigv,
            c.monisc                            AS monisc,
            c.monotr                            AS monotr,
            c.preven                            AS preven,
--            c.observ,
            (
                CASE
                    WHEN dct.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct.vreal
                END
            )                                   AS percep,
            ( c.preven ) + (
                CASE
                    WHEN dct.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct.vreal
                END
            )                                   AS totpag,
            c.porigv                            AS porigv,
            c.desesp                            AS desesp,
            c1.fax                              AS faxcli,
            c1.telefono                         AS tlfcli,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                                 AS numped,
            CASE
                WHEN ac5.codigo IS NULL THEN
                    CAST('N' AS VARCHAR(20))
                ELSE
                    ac5.codigo
            END                                 AS glosxdes,
            dca.direc1                          AS desenv01,
            t1.descri                           AS destra,
            t2.descri                           AS destra2,
            dcc.atenci                          AS atenci,
            v1.desven                           AS desven,
            CASE
                WHEN dap.situac = 'B' THEN
                    CAST('Aprobado' AS VARCHAR(50))
                ELSE
                    CASE
                        WHEN dap.situac = 'J' THEN
                                CAST('Desaprobado' AS VARCHAR(50))
                        ELSE
                            s2.alias
                    END
            END                                 AS aliassit,
            s2.dessit                           AS dessit,
            mt.desmot                           AS desmot,
            ds.tipimp,
            df.formato                          AS tipimpformato,
            d.tipinv,
            d.codart                            AS codart,
            a.descri                            AS desart,
--            CASE
--                WHEN c33.codigo != 'S' THEN
--                    a.descri
--                ELSE
--                    CASE
--                        WHEN lpa33.desart != '' THEN
--                                lpa33.desart
--                        ELSE
--                            CASE
--                                WHEN lp33.desart IS NOT NULL
--                                     AND length(lp33.desart) > 0 THEN
--                                            lp33.desart
--                                ELSE
--                                    a.descri
--                            END
--                    END
--            END                                 AS desart,
            a.consto                            AS consto,
            d.codalm                            AS codalm,
            d.observ                            AS obsdet,
            d.monafe                            AS monafedet,
            d.monina                            AS moninadet,
            d.monisc                            AS moniscdet,
            d.monigv                            AS monigvdet,
            d.monotr                            AS monotrdet,
            d.codund                            AS codunddet,
            a.coduni                            AS codund,
            d.cantid                            AS cantid,
            d.piezas                            AS piezas,
            d.largo                             AS largo,
            d.ancho                             AS ancho,
            d.preuni                            AS preuni,
            d.importe                           AS importe,
            d.importe_bruto                     AS importe_bruto,
            d.pordes1                           AS pordes1,
            d.pordes2                           AS pordes2,
            d.pordes3                           AS pordes3,
            d.pordes4                           AS pordes4,
            d.opronumdoc                        AS opronumdoc,
            d.etiqueta                          AS etiqueta,
            d.nrocarrete                        AS nrocarrete,
            d.acabado                           AS acabado,
            d.chasis,
            d.motor,
            d.lote,
            d.fvenci,
            ( k.ingreso - k.salida )            AS stockk001,
            ( k.ingreso - k.salida ) - d.cantid AS saldok001,
            m1.simbolo                          AS simbolo,
            m1.desmon                           AS desmon,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                        ccc.codigo
                ELSE
                    CAST('0.00' AS VARCHAR(20))
            END
            || ' %'                             AS porpercep,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                    's'
                ELSE
                    'n'
            END                                 AS swdocpercep,
            CASE
                WHEN ( ( fap.vstrg IS NOT NULL )
                       AND ( upper(fap.vstrg) = 'S' )
                       AND ( ddp.vreal IS NOT NULL )
                       AND ( ddp.vreal > 0 ) ) THEN
                    '*'
                ELSE
                    ''
            END                                 AS astpercep,
            gar.glosa                           AS glosagar,
            gap.glosa                           AS glosagap,
            gfp.glosa                           AS glosagfp,
            dc2.vstrg                           AS codpiepagforf01,
            dc3.vstrg                           AS codpiepagforf02,
            (
                CASE
                    WHEN aca1.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 6))
                    ELSE
                        aca1.vreal
                END
            )                                   AS valundaltven,
            sv.usuari                           AS c_visadopor,
            uv.nombres                          AS visadopor,
            se.usuari                           AS c_emitidopor,
            ue.nombres                          AS emitidopor,
            dap.uactua                          AS c_aprobadopor,
            ua.nombres                          AS aprobadopor,
            (
                CASE
                    WHEN dap.situac IS NULL THEN
                        CAST('E' AS CHAR(1))
                    ELSE
                        dap.situac
                END
            )                                   AS situac_aprob,
            ( cc14.descri
              || ','
              || cc15.descri
              || ','
              || cc16.descri )                    AS ubigeo,
            ( cc16.descri
              || ' - '
              || cc15.descri
              || '- '
              || cc14.descri )                    AS ubigeo_b,
            doc.fecha                           AS fecha_dcorcom,
            doc.numero                          AS numero_dcorcom,
            doc.contacto                        AS contacto_dcorcom,
            un.abrevi                           AS abrunidad,
            d.codadd01,
            cl1.descri                          AS descodadd01,
            d.codadd02,
            cl2.descri                          AS descodadd02,
            df.formato
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab              c
            LEFT OUTER JOIN documentos                  ds ON ds.id_cia = c.id_cia
                                             AND ( ds.codigo = c.tipdoc )
                                             AND ( ds.series = c.series )
            LEFT OUTER JOIN documentos_formatos         df ON df.tipdoc = ds.codigo
                                                      AND df.item = nvl(ds.tipimp, 1)
            LEFT OUTER JOIN cliente                     c1 ON c1.id_cia = c.id_cia
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN vendedor                    v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN situacion                   s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN transportista               t1 ON t1.id_cia = c.id_cia
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN transportista               t2 ON t2.id_cia = c.id_cia
                                                AND ( t2.codtra = c.codtec )
            LEFT OUTER JOIN motivos                     mt ON mt.id_cia = c.id_cia
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( mt.tipdoc = c.tipdoc )
            LEFT OUTER JOIN cliente_clase               ccc ON ccc.id_cia = c.id_cia
                                                 AND ( ccc.tipcli = 'A' )
                                                 AND ( ccc.codcli = c.codcli )
                                                 AND ( ccc.clase = 23 )
            LEFT OUTER JOIN cliente_clase               c14 ON c14.id_cia = c.id_cia
                                                 AND ( c14.tipcli = 'A' )
                                                 AND ( c14.codcli = c.codcli )
                                                 AND ( c14.clase = 14 )
            LEFT OUTER JOIN clase_cliente_codigo        cc14 ON cc14.id_cia = c14.id_cia
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase               c15 ON c15.id_cia = c.id_cia
                                                 AND ( c15.tipcli = 'A' )
                                                 AND ( c15.codcli = c.codcli )
                                                 AND ( c15.clase = 15 )
            LEFT OUTER JOIN clase_cliente_codigo        cc15 ON cc15.id_cia = c15.id_cia
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase               c16 ON c16.id_cia = c.id_cia
                                                 AND ( c16.tipcli = 'A' )
                                                 AND ( c16.codcli = c.codcli )
                                                 AND ( c16.clase = 16 )
            LEFT OUTER JOIN clase_cliente_codigo        cc16 ON cc16.id_cia = c16.id_cia
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN documentos_cab_ordcom       doc ON doc.id_cia = c.id_cia
                                                         AND doc.numint = c.numint
            LEFT OUTER JOIN documentos_cab_almacen      dca ON dca.id_cia = c.id_cia
                                                          AND ( dca.numint = c.numint )
            LEFT OUTER JOIN documentos_cab_contacto     dcc ON dcc.id_cia = c.id_cia
                                                           AND ( dcc.numint = c.numint )
            LEFT OUTER JOIN documentos_cab_clase        cc ON cc.id_cia = c.id_cia
                                                       AND ( cc.numint = c.numint )
                                                       AND ( cc.clase = 6 )
            LEFT OUTER JOIN factor                      far ON far.id_cia = c.id_cia
                                          AND ( far.codfac = 331 )
            LEFT OUTER JOIN factor                      fap ON fap.id_cia = c.id_cia
                                          AND ( fap.codfac = 332 )
            LEFT OUTER JOIN documentos_det              d ON d.id_cia = c.id_cia
                                                AND ( d.numint = c.numint )
            LEFT OUTER JOIN unidad                      un ON un.id_cia = d.id_cia
                                         AND un.coduni = d.codund
            LEFT OUTER JOIN kardex001                   k ON k.id_cia = d.id_cia
                                           AND ( k.tipinv = d.tipinv )
                                           AND ( k.codart = d.codart )
                                           AND ( k.codalm = d.codalm )
                                           AND ( k.etiqueta = d.etiqueta )
            LEFT OUTER JOIN documentos_cab_clase        dcp ON dcp.id_cia = c.id_cia
                                                        AND ( dcp.numint = c.numint )
                                                        AND ( dcp.clase = 3 )
            LEFT OUTER JOIN documentos_cab_clase        dct ON dct.id_cia = c.id_cia
                                                        AND ( dct.numint = c.numint )
                                                        AND ( dct.clase = 4 )
            LEFT OUTER JOIN documentos_det_clase        ddp ON ddp.id_cia = d.id_cia
                                                        AND ( ddp.numint = d.numint )
                                                        AND ( ddp.numite = d.numite )
                                                        AND ( ddp.clase = 50 )
            LEFT OUTER JOIN articulos                   a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN cliente_articulos_clase     cl1 ON cl1.id_cia = a.id_cia
                                                           AND ( cl1.tipcli = 'B' )
                                                           AND ( cl1.codcli = a.codprv )
                                                           AND ( cl1.clase = 1 )
                                                           AND ( cl1.codigo = d.codadd01 )
            LEFT OUTER JOIN cliente_articulos_clase     cl2 ON cl2.id_cia = a.id_cia
                                                           AND ( cl2.tipcli = 'B' )
                                                           AND ( cl2.codcli = a.codprv )
                                                           AND ( cl2.clase = 2 )
                                                           AND ( cl2.codigo = d.codadd02 )
            LEFT OUTER JOIN tmoneda                     m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN documentos_clase            dc2 ON dc2.id_cia = c.id_cia
                                                    AND dc2.codigo = c.tipdoc
                                                    AND dc2.series = c.series
                                                    AND dc2.clase = 14
            LEFT OUTER JOIN documentos_clase            dc3 ON dc3.id_cia = c.id_cia
                                                    AND dc3.codigo = c.tipdoc
                                                    AND dc3.series = c.series
                                                    AND dc3.clase = 15
            LEFT OUTER JOIN companias_glosa             gar ON ( gar.id_cia = c.id_cia )
                                                   AND ( far.vstrg IS NOT NULL )
                                                   AND ( upper(far.vstrg) = 'S' )
                                                   AND ( gar.item = 15 )
            LEFT OUTER JOIN companias_glosa             gap ON ( gap.id_cia = c.id_cia )
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( gap.item = 13 )
            LEFT OUTER JOIN companias_glosa             gfp ON ( gfp.id_cia = c.id_cia )
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( dcp.codigo IS NOT NULL )
                                                   AND ( upper(dcp.codigo) = 'S' )
                                                   AND ( gfp.item = 14 )
            LEFT OUTER JOIN articulos_clase_alternativo aca1 ON aca1.id_cia = d.id_cia
                                                                AND aca1.tipinv = d.tipinv
                                                                AND aca1.codart = d.codart
                                                                AND aca1.clase = 1
                                                                AND aca1.codigo = d.codund
            LEFT OUTER JOIN articulos_clase             ac5 ON ac5.id_cia = d.id_cia
                                                   AND ( ac5.tipinv = d.tipinv )
                                                   AND ( ac5.codart = d.codart )
                                                   AND ( ac5.clase = 87 )
            LEFT OUTER JOIN cliente_clase               c33 ON c33.id_cia = c.id_cia
                                                 AND ( c33.tipcli = 'A' )
                                                 AND ( c33.codcli = c.codcli )
                                                 AND ( c33.clase = 33 )
            LEFT OUTER JOIN listaprecios                lp33 ON lp33.id_cia = c.id_cia
                                                 AND lp33.vencom = 1
                                                 AND lp33.codtit = c1.codtit
                                                 AND lp33.tipinv = d.tipinv
                                                 AND lp33.codart = d.codart
            LEFT OUTER JOIN listaprecios_alternativa    lpa33 ON lpa33.id_cia = c.id_cia
                                                              AND lpa33.vencom = 1
                                                              AND lpa33.codtit = c1.codtit
                                                              AND lpa33.tipinv = d.tipinv
                                                              AND lpa33.codart = d.codart
                                                              AND lpa33.codadd01 = d.codadd01
                                                              AND lpa33.codadd02 = d.codadd02
            LEFT OUTER JOIN documentos_situac_max       sv ON sv.id_cia = c.id_cia
                                                        AND sv.numint = c.numint
                                                        AND sv.situac = 'B'
            LEFT OUTER JOIN usuarios                    uv ON uv.id_cia = sv.id_cia
                                           AND uv.coduser = sv.usuari
            LEFT OUTER JOIN documentos_situac_max       se ON se.id_cia = c.id_cia
                                                        AND se.numint = c.numint
                                                        AND se.situac = 'A'
            LEFT OUTER JOIN usuarios                    ue ON ue.id_cia = se.id_cia
                                           AND ue.coduser = se.usuari
            LEFT OUTER JOIN documentos_aprobacion       dap ON dap.id_cia = c.id_cia
                                                         AND dap.numint = c.numint
            LEFT OUTER JOIN usuarios                    ua ON ua.id_cia = dap.id_cia
                                           AND ua.coduser = dap.uactua
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ordenpedido;

    FUNCTION sp_ordenproduccion (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_ordenproduccion
        PIPELINED
    AS
        v_table datatable_ordenproduccion;
    BEGIN
        SELECT
            c.id_cia,
            c.numint                       AS numint,
            d.numite                       AS numite,
            c.series                       AS series,
            c.numdoc                       AS numdoc,
            c.femisi                       AS femisi,
            c.codsuc,
            c.opnumdoc                     AS opnumdoc,
            c.razonc                       AS razonc,
            c.direc1                       AS direc1,
            c.ruc                          AS ruc,
            c.tipmon                       AS tipmon,
            c.fentreg                      AS fentreg,
            c.fecter                       AS fecter,
            c.horter                       AS horter,
            c.observ                       AS obscab,
            c.presen                       AS comentario,
            c.monafe                       AS monafe,
            c.monina                       AS monina,
            c.monafe + c.monina + c.monexo AS monneto,
            c.monexo                       AS monexo,
            c.monigv                       AS monigv,
            c.monisc                       AS monisc,
            c.monotr                       AS monotr,
            c.preven                       AS preven,
            0                              AS percep,
            c.preven                       AS totpag,
            c.porigv                       AS porigv,
            c.desesp                       AS desesp,
            c1.fax                         AS faxcli,
            c1.telefono                    AS tlfcli,
            c.numped                       AS numped,
            CASE
                WHEN ac5.codigo IS NULL THEN
                    CAST('N' AS VARCHAR(20))
                ELSE
                    ac5.codigo
            END                            AS glosxdes,
            NULL                           AS desenv01,
            t1.descri                      AS destra,
            t2.descri                      AS destra2,
            NULL                           AS atenci,
            v1.desven                      AS desven,
            CASE
                WHEN dap.situac = 'B' THEN
                    CAST('Aprobado' AS VARCHAR(50))
                ELSE
                    CASE
                        WHEN dap.situac = 'J' THEN
                                CAST('Desaprobado' AS VARCHAR(50))
                        ELSE
                            s2.alias
                    END
            END                            AS aliassit,
            s2.dessit                      AS dessit,
            mt.desmot                      AS desmot,
            ds.tipimp,
            df.formato                     AS tipimpformato,
            d.tipinv,
            d.codart                       AS codart,
            a.descri                       AS desart,
            a.consto                       AS consto,
            d.codalm                       AS codalm,
            d.observ                       AS obsdet,
            d.monafe                       AS monafedet,
            d.monina                       AS moninadet,
            d.monisc                       AS moniscdet,
            d.monigv                       AS monigvdet,
            d.monotr                       AS monotrdet,
            d.codund                       AS codunddet,
            a.coduni                       AS codund,
            d.cantid                       AS cantid,
            d.piezas                       AS piezas,
            d.largo                        AS largo,
            d.ancho                        AS ancho,
            d.preuni                       AS preuni,
            d.importe                      AS importe,
            d.importe_bruto                AS importe_bruto,
            d.pordes1                      AS pordes1,
            d.pordes2                      AS pordes2,
            d.pordes3                      AS pordes3,
            d.pordes4                      AS pordes4,
            d.opronumdoc                   AS opronumdoc,
            d.etiqueta                     AS etiqueta,
            d.nrocarrete                   AS nrocarrete,
            d.acabado                      AS acabado,
            d.chasis,
            d.motor,
            d.lote,
            d.fvenci,
            0                              AS stockk001,
            0                              AS saldok001,
            m1.simbolo                     AS simbolo,
            m1.desmon                      AS desmon,
            NULL                           AS porpercep,
            NULL                           AS swdocpercep,
            NULL                           AS astpercep,
            gar.glosa                      AS glosagar,
            gap.glosa                      AS glosagap,
            gfp.glosa                      AS glosagfp,
            NULL                           AS codpiepagforf01,
            NULL                           AS codpiepagforf02,
            0                              AS valundaltven,
            sv.usuari                      AS c_visadopor,
            uv.nombres                     AS visadopor,
            se.usuari                      AS c_emitidopor,
            ue.nombres                     AS emitidopor,
            dap.uactua                     AS c_aprobadopor,
            ua.nombres                     AS aprobadopor,
            (
                CASE
                    WHEN dap.situac IS NULL THEN
                        CAST('E' AS CHAR(1))
                    ELSE
                        dap.situac
                END
            )                              AS situac_aprob,
            ( cc14.descri
              || ','
              || cc15.descri
              || ','
              || cc16.descri )               AS ubigeo,
            ( cc16.descri
              || ' - '
              || cc15.descri
              || '- '
              || cc14.descri )               AS ubigeo_b,
--            doc.fecha                      AS fecha_dcorcom,
            NULL                           AS fecha_dcorcom,
--            doc.numero                     AS numero_dcorcom,
            NULL                           AS numero_dcorcom,
--            doc.contacto                   AS contacto_dcorcom,
            NULL                           AS contacto_dcorcom,
            un.abrevi                      AS abrunidad,
            d.codadd01,
--            cl1.descri                          AS descodadd01,
            NULL                           AS descodadd01,
            d.codadd02,
--            cl2.descri                          AS descodadd02
            NULL                           AS descodadd02,
            df.formato
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab        c
            LEFT OUTER JOIN documentos            ds ON ds.id_cia = c.id_cia
                                             AND ds.codigo = c.tipdoc
                                             AND ds.series = c.series
            LEFT OUTER JOIN documentos_formatos   df ON df.tipdoc = ds.codigo
                                                      AND df.item = nvl(ds.tipimp, 1)
            LEFT OUTER JOIN cliente               c1 ON c1.id_cia = c.id_cia
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN vendedor              v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN situacion             s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN transportista         t1 ON t1.id_cia = c.id_cia
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN transportista         t2 ON t2.id_cia = c.id_cia
                                                AND ( t2.codtra = c.codtec )
            LEFT OUTER JOIN motivos               mt ON mt.id_cia = c.id_cia
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( mt.tipdoc = c.tipdoc )
            LEFT OUTER JOIN cliente_clase         c14 ON c14.id_cia = c.id_cia
                                                 AND ( c14.tipcli = 'A' )
                                                 AND ( c14.codcli = c.codcli )
                                                 AND ( c14.clase = 14 )
            LEFT OUTER JOIN clase_cliente_codigo  cc14 ON cc14.id_cia = c14.id_cia
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase         c15 ON c15.id_cia = c.id_cia
                                                 AND ( c15.tipcli = 'A' )
                                                 AND ( c15.codcli = c.codcli )
                                                 AND ( c15.clase = 15 )
            LEFT OUTER JOIN clase_cliente_codigo  cc15 ON cc15.id_cia = c15.id_cia
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase         c16 ON c16.id_cia = c.id_cia
                                                 AND ( c16.tipcli = 'A' )
                                                 AND ( c16.codcli = c.codcli )
                                                 AND ( c16.clase = 16 )
            LEFT OUTER JOIN clase_cliente_codigo  cc16 ON cc16.id_cia = c16.id_cia
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN factor                far ON far.id_cia = c.id_cia
                                          AND ( far.codfac = 331 )
            LEFT OUTER JOIN factor                fap ON fap.id_cia = c.id_cia
                                          AND ( fap.codfac = 332 )
            LEFT OUTER JOIN documentos_det        d ON d.id_cia = c.id_cia
                                                AND ( d.numint = c.numint )
            LEFT OUTER JOIN unidad                un ON un.id_cia = d.id_cia
                                         AND un.coduni = d.codund
            LEFT OUTER JOIN documentos_cab_clase  dcp ON dcp.id_cia = c.id_cia
                                                        AND ( dcp.numint = c.numint )
                                                        AND ( dcp.clase = 3 )
            LEFT OUTER JOIN documentos_cab_clase  dct ON dct.id_cia = c.id_cia
                                                        AND ( dct.numint = c.numint )
                                                        AND ( dct.clase = 4 )
            LEFT OUTER JOIN documentos_det_clase  ddp ON ddp.id_cia = d.id_cia
                                                        AND ( ddp.numint = d.numint )
                                                        AND ( ddp.numite = d.numite )
                                                        AND ( ddp.clase = 50 )
            LEFT OUTER JOIN articulos             a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN tmoneda               m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN companias_glosa       gar ON ( gar.id_cia = c.id_cia )
                                                   AND ( far.vstrg IS NOT NULL )
                                                   AND ( upper(far.vstrg) = 'S' )
                                                   AND ( gar.item = 15 )
            LEFT OUTER JOIN companias_glosa       gap ON ( gap.id_cia = c.id_cia )
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( gap.item = 13 )
            LEFT OUTER JOIN companias_glosa       gfp ON ( gfp.id_cia = c.id_cia )
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( dcp.codigo IS NOT NULL )
                                                   AND ( upper(dcp.codigo) = 'S' )
                                                   AND ( gfp.item = 14 )
            LEFT OUTER JOIN articulos_clase       ac5 ON ac5.id_cia = d.id_cia
                                                   AND ( ac5.tipinv = d.tipinv )
                                                   AND ( ac5.codart = d.codart )
                                                   AND ( ac5.clase = 87 )
            LEFT OUTER JOIN documentos_situac_max sv ON sv.id_cia = c.id_cia
                                                        AND sv.numint = c.numint
                                                        AND sv.situac = 'B'
            LEFT OUTER JOIN usuarios              uv ON uv.id_cia = sv.id_cia
                                           AND uv.coduser = sv.usuari
            LEFT OUTER JOIN documentos_situac_max se ON se.id_cia = c.id_cia
                                                        AND se.numint = c.numint
                                                        AND se.situac = 'A'
            LEFT OUTER JOIN usuarios              ue ON ue.id_cia = se.id_cia
                                           AND ue.coduser = se.usuari
            LEFT OUTER JOIN documentos_aprobacion dap ON dap.id_cia = c.id_cia
                                                         AND dap.numint = c.numint
            LEFT OUTER JOIN usuarios              ua ON ua.id_cia = dap.id_cia
                                           AND ua.coduser = dap.uactua
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ordenproduccion;

    FUNCTION sp_ordentrabajo (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_ordenproduccion
        PIPELINED
    AS
        v_table datatable_ordenproduccion;
    BEGIN
        SELECT
            c.id_cia,
            c.numint                       AS numint,
            d.numite                       AS numite,
            c.series                       AS series,
            c.numdoc                       AS numdoc,
            c.femisi                       AS femisi,
            c.codsuc,
            c.opnumdoc                     AS opnumdoc,
            c.razonc                       AS razonc,
            c.direc1                       AS direc1,
            c.ruc                          AS ruc,
            c.tipmon                       AS tipmon,
            c.fentreg                      AS fentreg,
            c.fecter                       AS fecter,
            c.horter                       AS horter,
            c.observ                       AS obscab,
            c.presen                       AS comentario,
            c.monafe                       AS monafe,
            c.monina                       AS monina,
            c.monafe + c.monina + c.monexo AS monneto,
            c.monexo                       AS monexo,
            c.monigv                       AS monigv,
            c.monisc                       AS monisc,
            c.monotr                       AS monotr,
            c.preven                       AS preven,
            0                              AS percep,
            c.preven                       AS totpag,
            c.porigv                       AS porigv,
            c.desesp                       AS desesp,
            c1.fax                         AS faxcli,
            c1.telefono                    AS tlfcli,
            c.numped                       AS numped,
            CASE
                WHEN ac5.codigo IS NULL THEN
                    CAST('N' AS VARCHAR(20))
                ELSE
                    ac5.codigo
            END                            AS glosxdes,
            NULL                           AS desenv01,
            t1.descri                      AS destra,
            t2.descri                      AS destra2,
            NULL                           AS atenci,
            v1.desven                      AS desven,
            CASE
                WHEN dap.situac = 'B' THEN
                    CAST('Aprobado' AS VARCHAR(50))
                ELSE
                    CASE
                        WHEN dap.situac = 'J' THEN
                                CAST('Desaprobado' AS VARCHAR(50))
                        ELSE
                            s2.alias
                    END
            END                            AS aliassit,
            s2.dessit                      AS dessit,
            mt.desmot                      AS desmot,
            ds.tipimp,
            df.formato                     AS tipimpformato,
            d.tipinv,
            d.codart                       AS codart,
            a.descri                       AS desart,
            a.consto                       AS consto,
            d.codalm                       AS codalm,
            d.observ                       AS obsdet,
            d.monafe                       AS monafedet,
            d.monina                       AS moninadet,
            d.monisc                       AS moniscdet,
            d.monigv                       AS monigvdet,
            d.monotr                       AS monotrdet,
            d.codund                       AS codunddet,
            a.coduni                       AS codund,
            d.cantid                       AS cantid,
            d.piezas                       AS piezas,
            d.largo                        AS largo,
            d.ancho                        AS ancho,
            d.preuni                       AS preuni,
            d.importe                      AS importe,
            d.importe_bruto                AS importe_bruto,
            d.pordes1                      AS pordes1,
            d.pordes2                      AS pordes2,
            d.pordes3                      AS pordes3,
            d.pordes4                      AS pordes4,
            d.opronumdoc                   AS opronumdoc,
            d.etiqueta                     AS etiqueta,
            d.nrocarrete                   AS nrocarrete,
            d.acabado                      AS acabado,
            d.chasis,
            d.motor,
            d.lote,
            d.fvenci,
            0                              AS stockk001,
            0                              AS saldok001,
            m1.simbolo                     AS simbolo,
            m1.desmon                      AS desmon,
            NULL                           AS porpercep,
            NULL                           AS swdocpercep,
            NULL                           AS astpercep,
            gar.glosa                      AS glosagar,
            gap.glosa                      AS glosagap,
            gfp.glosa                      AS glosagfp,
            NULL                           AS codpiepagforf01,
            NULL                           AS codpiepagforf02,
            0                              AS valundaltven,
            sv.usuari                      AS c_visadopor,
            uv.nombres                     AS visadopor,
            se.usuari                      AS c_emitidopor,
            ue.nombres                     AS emitidopor,
            dap.uactua                     AS c_aprobadopor,
            ua.nombres                     AS aprobadopor,
            (
                CASE
                    WHEN dap.situac IS NULL THEN
                        CAST('E' AS CHAR(1))
                    ELSE
                        dap.situac
                END
            )                              AS situac_aprob,
            ( cc14.descri
              || ','
              || cc15.descri
              || ','
              || cc16.descri )               AS ubigeo,
            ( cc16.descri
              || ' - '
              || cc15.descri
              || '- '
              || cc14.descri )               AS ubigeo_b,
--            doc.fecha                      AS fecha_dcorcom,
            NULL                           AS fecha_dcorcom,
--            doc.numero                     AS numero_dcorcom,
            NULL                           AS numero_dcorcom,
--            doc.contacto                   AS contacto_dcorcom,
            NULL                           AS contacto_dcorcom,
            un.abrevi                      AS abrunidad,
            d.codadd01,
--            cl1.descri                          AS descodadd01,
            NULL                           AS descodadd01,
            d.codadd02,
--            cl2.descri                          AS descodadd02
            NULL                           AS descodadd02,
            df.formato
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab        c
            LEFT OUTER JOIN documentos            ds ON ds.id_cia = c.id_cia
                                             AND ds.codigo = c.tipdoc
                                             AND ds.series = c.series
            LEFT OUTER JOIN documentos_formatos   df ON df.tipdoc = ds.codigo
                                                      AND df.item = nvl(ds.tipimp, 1)
            LEFT OUTER JOIN cliente               c1 ON c1.id_cia = c.id_cia
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN vendedor              v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN situacion             s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN transportista         t1 ON t1.id_cia = c.id_cia
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN transportista         t2 ON t2.id_cia = c.id_cia
                                                AND ( t2.codtra = c.codtec )
            LEFT OUTER JOIN motivos               mt ON mt.id_cia = c.id_cia
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( mt.tipdoc = c.tipdoc )
            LEFT OUTER JOIN cliente_clase         c14 ON c14.id_cia = c.id_cia
                                                 AND ( c14.tipcli = 'A' )
                                                 AND ( c14.codcli = c.codcli )
                                                 AND ( c14.clase = 14 )
            LEFT OUTER JOIN clase_cliente_codigo  cc14 ON cc14.id_cia = c14.id_cia
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase         c15 ON c15.id_cia = c.id_cia
                                                 AND ( c15.tipcli = 'A' )
                                                 AND ( c15.codcli = c.codcli )
                                                 AND ( c15.clase = 15 )
            LEFT OUTER JOIN clase_cliente_codigo  cc15 ON cc15.id_cia = c15.id_cia
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase         c16 ON c16.id_cia = c.id_cia
                                                 AND ( c16.tipcli = 'A' )
                                                 AND ( c16.codcli = c.codcli )
                                                 AND ( c16.clase = 16 )
            LEFT OUTER JOIN clase_cliente_codigo  cc16 ON cc16.id_cia = c16.id_cia
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN factor                far ON far.id_cia = c.id_cia
                                          AND ( far.codfac = 331 )
            LEFT OUTER JOIN factor                fap ON fap.id_cia = c.id_cia
                                          AND ( fap.codfac = 332 )
            LEFT OUTER JOIN documentos_det        d ON d.id_cia = c.id_cia
                                                AND ( d.numint = c.numint )
            LEFT OUTER JOIN unidad                un ON un.id_cia = d.id_cia
                                         AND un.coduni = d.codund
            LEFT OUTER JOIN documentos_cab_clase  dcp ON dcp.id_cia = c.id_cia
                                                        AND ( dcp.numint = c.numint )
                                                        AND ( dcp.clase = 3 )
            LEFT OUTER JOIN documentos_cab_clase  dct ON dct.id_cia = c.id_cia
                                                        AND ( dct.numint = c.numint )
                                                        AND ( dct.clase = 4 )
            LEFT OUTER JOIN documentos_det_clase  ddp ON ddp.id_cia = d.id_cia
                                                        AND ( ddp.numint = d.numint )
                                                        AND ( ddp.numite = d.numite )
                                                        AND ( ddp.clase = 50 )
            LEFT OUTER JOIN articulos             a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN tmoneda               m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN companias_glosa       gar ON ( gar.id_cia = c.id_cia )
                                                   AND ( far.vstrg IS NOT NULL )
                                                   AND ( upper(far.vstrg) = 'S' )
                                                   AND ( gar.item = 15 )
            LEFT OUTER JOIN companias_glosa       gap ON ( gap.id_cia = c.id_cia )
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( gap.item = 13 )
            LEFT OUTER JOIN companias_glosa       gfp ON ( gfp.id_cia = c.id_cia )
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( dcp.codigo IS NOT NULL )
                                                   AND ( upper(dcp.codigo) = 'S' )
                                                   AND ( gfp.item = 14 )
            LEFT OUTER JOIN articulos_clase       ac5 ON ac5.id_cia = d.id_cia
                                                   AND ( ac5.tipinv = d.tipinv )
                                                   AND ( ac5.codart = d.codart )
                                                   AND ( ac5.clase = 87 )
            LEFT OUTER JOIN documentos_situac_max sv ON sv.id_cia = c.id_cia
                                                        AND sv.numint = c.numint
                                                        AND sv.situac = 'B'
            LEFT OUTER JOIN usuarios              uv ON uv.id_cia = sv.id_cia
                                           AND uv.coduser = sv.usuari
            LEFT OUTER JOIN documentos_situac_max se ON se.id_cia = c.id_cia
                                                        AND se.numint = c.numint
                                                        AND se.situac = 'A'
            LEFT OUTER JOIN usuarios              ue ON ue.id_cia = se.id_cia
                                           AND ue.coduser = se.usuari
            LEFT OUTER JOIN documentos_aprobacion dap ON dap.id_cia = c.id_cia
                                                         AND dap.numint = c.numint
            LEFT OUTER JOIN usuarios              ua ON ua.id_cia = dap.id_cia
                                           AND ua.coduser = dap.uactua
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ordentrabajo;

    FUNCTION sp_cotizacion (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_cotizacion
        PIPELINED
    AS
        v_table datatable_cotizacion;
    BEGIN
        SELECT
            c.id_cia,
            c.tipdoc                    AS tipdoc,
            dx.descri                   AS desdoc,
            c.codsuc,
            c.numint                    AS numint,
            d.numite                    AS numite,
            c.series                    AS series,
            c.numdoc                    AS numdoc,
            c.femisi                    AS femisi,
            c.codcli                    AS codcli,
            c.razonc                    AS razonc,
            c.direc1                    AS direc1,
            c.ruc                       AS ruc,
            c.tipcam                    AS tipcam,
            c.tipmon                    AS tipmon,
            c.situac                    AS situac,
            c.observ                    AS obscab,
            c.fentreg                   AS fentreg,
            c.ffacpro                   AS ffacpro,
            c.ordcom                    AS ordcom,
            c.guiarefe                  AS guiarefe,
            c.marcas                    AS marcas,
            d.tipinv,
            d.codart,
            d.positi                    AS positi,
            d.codund                    AS codunddet,
            d.cantid                    AS cantid,
            d.preuni                    AS preuni,
            d.cosuni    AS coduni,
            d.importe                   AS importe,
            d.pordes1                   AS pordes1,
            d.pordes2                   AS pordes2,
            d.pordes3                   AS pordes3,
            d.pordes4                   AS pordes4,
            d.ubica                     AS ubica,
            d.importe_bruto - d.importe AS descdet,
            d.observ                    AS obsdet,
            d.swacti                    AS swacti,
            c.monafe + c.monina         AS monneto,
            c.monigv                    AS monigv,
            c.preven                    AS preven,
            c.descue                    AS descue,
            c.totbru                    AS totbru,
            (
                CASE
                    WHEN dct.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct.vreal
                END
            )                           AS percep,
            ( c.preven ) + (
                CASE
                    WHEN dct.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct.vreal
                END
            )                           AS totpag,
            c.porigv                    AS porigv,
            dcc.atenci                  AS atenci,
            c.incigv                    AS incigv,
            dcc.plaent                  AS plaent,
            dcc.valide                  AS valide,
            dcc.email                   AS mailcont,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                         AS numped,
            a.descri                    AS desart,
--            CASE
--                WHEN c33.codigo != 'S' THEN
--                    a.descri
--                ELSE
--                    CASE
--                        WHEN lpa33.desart != '' THEN
--                                lpa33.desart
--                        ELSE
--                            CASE
--                                WHEN lp33.desart IS NOT NULL
--                                     AND length(lp33.desart) > 0 THEN
--                                            lp33.desart
--                                ELSE
--                                    a.descri
--                            END
--                    END
--            END                         AS desart,
            a.coduni                    AS codund,
            a.codlin                    AS conlin,
            a.faccon                    AS faccon,
            a.conesp                    AS conesp,
            d.cantid * a.faccon         AS pesdet,
            c.codcpag                   AS codcpag,
            cv.despag                   AS despagven,
            CASE
                WHEN ac5.codigo IS NULL THEN
                    CAST('N' AS VARCHAR(20))
                ELSE
                    ac5.codigo
            END                         AS glosxdes,
            v1.codven                   AS codven,
            v1.desven                   AS desven,
            v1.cargo                    AS carven,
            v1.email                    AS mailven,
            v1.celular                  AS celuven,
            v1.telefo                   AS tlfven,
            m1.simbolo                  AS simbolo,
            m1.desmon                   AS desmon,
            s2.alias                    AS aliassit,
            vcc.descri                  AS especialidad,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                    CAST('S' AS VARCHAR(20))
                ELSE
                    CAST('N' AS VARCHAR(20))
            END                         AS swdocpercep,
            CASE
                WHEN ( ( fap.vstrg IS NOT NULL )
                       AND ( upper(fap.vstrg) = 'S' )
                       AND ( ddp.vreal IS NOT NULL )
                       AND ( ddp.vreal > 0 ) ) THEN
                    '*'
                ELSE
                    ''
            END                         AS astpercep,
            gar.glosa                   AS glosagar,
            gap.glosa                   AS glosagap,
            gfp.glosa                   AS glosagfp,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                        ccc.codigo
                ELSE
                    CAST('0.00' AS VARCHAR(20))
            END
            || ' %'                     AS porpercep,
            (
                SELECT
                    glosa
                FROM
                    companias_glosa
                WHERE
                        id_cia = pin_id_cia
                    AND item = 9
            )                           AS gnotas,
            (
                CASE
                    WHEN aca1.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 6))
                    ELSE
                        aca1.vreal
                END
            )                           valundaltven,
            ( cc14.descri
              || ' - '
              || cc15.descri
              || ' - '
              || cc16.descri )            AS ubigeo,
            ( cc16.descri
              || ' -'
              || cc15.descri
              || ' - '
              || cc14.descri )            AS ubigeo_b,
            un.abrevi                   AS abrunidad,
            dca.direc1                  AS desenv01,
            t1.descri                   AS destra,
            cia.ruc                     AS ruccia,
            df.formato                  AS formato
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab              c
            LEFT OUTER JOIN documentos_det              d ON ( d.id_cia = c.id_cia
                                                  AND d.numint = c.numint )
            LEFT OUTER JOIN unidad                      un ON un.id_cia = d.id_cia
                                         AND un.coduni = d.codund
            LEFT OUTER JOIN articulos                   a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN tmoneda                     m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN cliente                     c1 ON c1.id_cia = c.id_cia
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN cliente_clase               c33 ON c33.id_cia = c.id_cia
                                                 AND ( c33.tipcli = 'A' )
                                                 AND ( c33.codcli = c.codcli )
                                                 AND ( c33.clase = 33 )
            LEFT OUTER JOIN cliente_clase               ccc ON ccc.id_cia = c.id_cia
                                                 AND ( ccc.tipcli = 'A' )
                                                 AND ( ccc.codcli = c.codcli )
                                                 AND ( ccc.clase = 23 )
            LEFT OUTER JOIN cliente_clase               c14 ON c14.id_cia = c.id_cia
                                                 AND ( c14.tipcli = 'A' )
                                                 AND ( c14.codcli = c.codcli )
                                                 AND ( c14.clase = 14 )
            LEFT OUTER JOIN clase_cliente_codigo        cc14 ON cc14.id_cia = c14.id_cia
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase               c15 ON c15.id_cia = c.id_cia
                                                 AND ( c15.tipcli = 'A' )
                                                 AND ( c15.codcli = c.codcli )
                                                 AND ( c15.clase = 15 )
            LEFT OUTER JOIN clase_cliente_codigo        cc15 ON cc15.id_cia = c15.id_cia
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase               c16 ON c16.id_cia = c.id_cia
                                                 AND ( c16.tipcli = 'A' )
                                                 AND ( c16.codcli = c.codcli )
                                                 AND ( c16.clase = 16 )
            LEFT OUTER JOIN clase_cliente_codigo        cc16 ON cc16.id_cia = c16.id_cia
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN listaprecios                lp33 ON lp33.id_cia = c1.id_cia
                                                 AND lp33.vencom = 1
                                                 AND lp33.codtit = c1.codtit
                                                 AND lp33.tipinv = d.tipinv
                                                 AND lp33.codart = d.codart
            LEFT OUTER JOIN listaprecios_alternativa    lpa33 ON lpa33.id_cia = c1.id_cia
                                                              AND lpa33.vencom = 1
                                                              AND lpa33.codtit = c1.codtit
                                                              AND lpa33.tipinv = d.tipinv
                                                              AND lpa33.codart = d.codart
                                                              AND lpa33.codadd01 = d.codadd01
                                                              AND lpa33.codadd02 = d.codadd02
            LEFT OUTER JOIN documentos_cab_almacen      dca ON c.id_cia = dca.id_cia
                                                          AND ( c.numint = dca.numint )
            LEFT OUTER JOIN documentos_cab_contacto     dcc ON ( c.id_cia = dcc.id_cia
                                                             AND c.numint = dcc.numint )
            LEFT OUTER JOIN documentos_cab_clase        cc ON cc.id_cia = c.id_cia
                                                       AND ( cc.numint = c.numint )
                                                       AND ( cc.clase = 6 )
            LEFT OUTER JOIN documentos_cab_clase        dcp ON dcp.id_cia = c.id_cia
                                                        AND ( dcp.numint = c.numint )
                                                        AND ( dcp.clase = 3 )
            LEFT OUTER JOIN documentos_cab_clase        dct ON dct.id_cia = c.id_cia
                                                        AND ( dct.numint = c.numint )
                                                        AND ( dct.clase = 4 )
            LEFT OUTER JOIN documentos_det_clase        ddp ON ddp.id_cia = d.id_cia
                                                        AND ( ddp.numint = d.numint )
                                                        AND ( ddp.numite = d.numite )
                                                        AND ( ddp.clase = 50 )
            LEFT OUTER JOIN factor                      far ON far.id_cia = c.id_cia
                                          AND ( far.codfac = 331 )
            LEFT OUTER JOIN factor                      fap ON fap.id_cia = c.id_cia
                                          AND ( fap.codfac = 332 )
            LEFT OUTER JOIN companias_glosa             gar ON gar.id_cia = far.id_cia
                                                   AND ( far.vstrg IS NOT NULL )
                                                   AND ( upper(far.vstrg) = 'S' )
                                                   AND ( gar.item = 15 )
            LEFT OUTER JOIN companias_glosa             gap ON gap.id_cia = fap.id_cia
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( gap.item = 13 )
            LEFT OUTER JOIN companias_glosa             gfp ON gfp.id_cia = fap.id_cia
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( dcp.codigo IS NOT NULL )
                                                   AND ( upper(dcp.codigo) = 'S' )
                                                   AND ( gfp.item = 14 )
            LEFT OUTER JOIN c_pago                      cv ON cv.id_cia = c.id_cia
                                         AND ( cv.codpag = c.codcpag )
                                         AND ( upper(cv.swacti) = 'S' )
            LEFT OUTER JOIN vendedor                    v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN vendedor_clase              vc ON vc.id_cia = c.id_cia
                                                 AND ( vc.codven = c.codven )
                                                 AND ( vc.clase = 3 )
            LEFT OUTER JOIN clase_vendedor_codigo       vcc ON vcc.id_cia = vc.id_cia
                                                         AND ( vcc.clase = vc.clase )
                                                         AND ( vcc.codigo = vc.codigo )
            LEFT OUTER JOIN situacion                   s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN articulos_clase             ac5 ON ac5.id_cia = d.id_cia
                                                   AND ( ac5.tipinv = d.tipinv )
                                                   AND ( ac5.codart = d.codart )
                                                   AND ( ac5.clase = 87 )
            LEFT OUTER JOIN articulos_clase_alternativo aca1 ON aca1.id_cia = d.id_cia
                                                                AND aca1.tipinv = d.tipinv
                                                                AND aca1.codart = d.codart
                                                                AND aca1.clase = 1
                                                                AND aca1.codigo = d.codund
            LEFT OUTER JOIN documentos                  dx ON dx.id_cia = c.id_cia
                                             AND ( dx.codigo = c.tipdoc )
                                             AND ( dx.series = c.series )
            LEFT OUTER JOIN documentos_formatos         df ON df.tipdoc = dx.codigo
                                                      AND df.item = nvl(dx.tipimp, 1)
            LEFT OUTER JOIN transportista               t1 ON t1.id_cia = c.id_cia
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN companias                   cia ON cia.cia = c.id_cia
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
            AND c.tipdoc = 100
        ORDER BY
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cotizacion;

END;

/
