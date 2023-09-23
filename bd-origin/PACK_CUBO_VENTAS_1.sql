--------------------------------------------------------
--  DDL for Package Body PACK_CUBO_VENTAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CUBO_VENTAS" AS

    FUNCTION sp_cuboventas001 (
        pin_id_cia NUMBER,
        pin_numint INTEGER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable
        PIPELINED
    IS

        output_record datarecord;
        CURSOR cur_select IS
        SELECT
            dc.descri                                    AS "DOCUMENTO",
            s.sucursal,
            ms.desmin                                    AS mes,
            EXTRACT(YEAR FROM dr.femisifac)              AS periodo,
            EXTRACT(YEAR FROM dr.femisifac)
            ||
            CASE
                WHEN ( EXTRACT(MONTH FROM dr.femisifac) < 10 ) THEN
                        '0'
                        || CAST(EXTRACT(MONTH FROM dr.femisifac) AS VARCHAR(2))
                ELSE
                    CAST(EXTRACT(MONTH FROM dr.femisifac) AS VARCHAR(2))
            END
            AS mesid,
            dr.seriefac                                  AS serie,
            dr.numdocfac                                 AS numdoc,
            dr.femisifac                                 AS femisi,
            dr.tipcamfac                                 AS tcambio,
            dr.codclifac                                 AS codcli,
            c901c.descodigo                              AS clase_abc,
            c902c.descodigo                              AS clascli,
            c900c.descodigo                              AS tipcli,
            cl.razonc                                    AS "CLIENTE",
            cl.fcreac                                    AS fcreac_cli,
            dr.rucfac                                    AS ruc,
            cp.despag                                    AS fpago,
            mt.desmot                                    AS motivo,
            ve.desven                                    AS vencompvnt,
            vc.desven                                    AS venasigcli,
            dr.tipmonfac                                 AS moneda,
            df.tipinv                                    AS tipinv,
            ap.razonc                                    AS proveedor,
            ca3.descodigo                                AS lineanegocio,
            ca2.descodigo                                AS famproducto,
            ca5.descodigo                                AS tipoproducto,
            ca11.descodigo                               AS clasproducto,
            df.codart                                    AS codigo,
            a.descri                                     AS descripcion,
            df.cantid * dc.signo                         AS cantidad,
            ( ( k.costot01 ) / (
                CASE
                    WHEN k.cantid <> 0 THEN
                        k.cantid
                    ELSE
                        1
                END
            ) ) * dc.signo                               AS cosunisol,
            ( ( k.costot02 ) / (
                CASE
                    WHEN k.cantid <> 0 THEN
                        k.cantid
                    ELSE
                        1
                END
            ) ) * dc.signo                               AS cosunidol,
       /* SACA EL COSTO DE LO FACTURADO */
            df.cantid                                    AS cantidori,
            CASE
                WHEN dr.tipmonfac = 'PEN' THEN
                        ( df.monafe + df.monina ) / CAST(df.cantid AS NUMERIC(7, 4))
                ELSE
                    ( ( df.monafe + df.monina ) * dr.tipcamfac ) / CAST(df.cantid AS NUMERIC(7, 4))
            END
            * dc.signo                                   AS prenetunisol,
            CASE
                WHEN dr.tipmonfac = 'USD' THEN
                        ( df.monafe + df.monina ) / CAST(df.cantid AS NUMERIC(7, 4))
                ELSE
                    ( ( df.monafe + df.monina ) / dr.tipcamfac ) / CAST(df.cantid AS NUMERIC(7, 4))
            END
            * dc.signo                                   AS prenetunidol,
            CASE
                WHEN dr.tipmonfac = 'PEN' THEN
                        ( df.monafe + df.monina )
                ELSE
                    ( ( df.monafe + df.monina ) * dr.tipcamfac )
            END
            * dc.signo                                   AS "VENTATOTSOL",
            CASE
                WHEN dr.tipmonfac = 'USD' THEN
                        ( df.monafe + df.monina )
                ELSE
                    ( ( df.monafe + df.monina ) / dr.tipcamfac )
            END
            * dc.signo                                   AS "VENTATOTDOL",
            d1.saldo                                     AS salpen,
            CASE
                WHEN CAST(d1.saldo AS INTEGER) = 0 THEN
                    'CANCELADO'
                ELSE
                    ''
            END                                          AS cancelado,
            dr.porcomisi                                 AS comision,
            coalesce(c1c.descodigo, 'ND - DEPARTAMENTO') AS departamento,
            coalesce(c2c.descodigo, 'ND - PROVINCIA')    AS provincia,
            coalesce(c3c.descodigo, 'ND - DISTRITO')     AS distrito,
            coalesce(c28c.descodigo, 'ND - DISTRITO')    AS geconomico,
            ue.coduser                                   AS coduseremi,
            ue.nombres                                   AS usuariemit,
            tl.titulo                                    AS tlista,
            cp900c.descodigo                             AS margenprov,
            vccc3.descri                                 AS supervisor,
            top.series
            || ' - '
            || top.numdoc                                AS ordenpedido,
            usm.coduser
            || ' - '
            || usm.nombres                               AS usuaremitop
        FROM
            TABLE ( sp_detalle_relacion_cubo(pin_id_cia, pin_numint, pin_fdesde, pin_fhasta) )  dr
            LEFT OUTER JOIN documentos_det                                                                      df ON ( df.id_cia = pin_id_cia
            )
                                                 AND ( df.numint = dr.numintfac )
                                                 AND ( df.numite = dr.numitefac )
            LEFT OUTER JOIN dcta100                                                                             d1 ON ( d1.id_cia = pin_id_cia
            )
                                          AND ( d1.numint = dr.numintfac )
            LEFT OUTER JOIN kardex                                                                              k ON ( k.id_cia = pin_id_cia
            )
                                        AND ( k.numint = CASE
                                                                 WHEN dr.deskardex = 'G' THEN
                                                                     dr.numintgui
                                                                 ELSE
                                                                     dr.numintfac
                                                             END
                                              AND k.numite = CASE
                                                                 WHEN dr.deskardex = 'G' THEN
                                                                     dr.numitegui
                                                                 ELSE
                                                                     dr.numitefac
                                                             END )
            LEFT OUTER JOIN tdoccobranza                                                                        dc ON ( dc.id_cia = pin_id_cia
            )
                                               AND ( dc.tipdoc = dr.tipdocfac )
            LEFT OUTER JOIN sucursal                                                                            s ON ( s.id_cia = pin_id_cia
            )
                                          AND ( s.codsuc = dr.codsucfac )
            LEFT OUTER JOIN motivos                                                                             mt ON ( mt.id_cia = pin_id_cia
            )
                                          AND ( mt.tipdoc = dr.tipdocfac )
                                          AND ( mt.id = dr.idfac )
                                          AND ( mt.codmot = dr.codmotfac )
            LEFT OUTER JOIN motivos_clase                                                                       mc ON ( mc.id_cia = pin_id_cia
            )
                                                AND ( mc.tipdoc = dr.tipdocfac )
                                                AND ( mc.id = dr.idfac )
                                                AND ( mc.codmot = dr.codmotfac )
                                                AND ( mc.codigo = 2 )
            LEFT OUTER JOIN meses                                                                               ms ON ( ms.id_cia = pin_id_cia
            )
                                        AND ( ms.nromes = EXTRACT(MONTH FROM dr.femisifac) )
            LEFT OUTER JOIN vendedor                                                                            ve ON ( ve.id_cia = pin_id_cia
            )
                                           AND ( ve.codven = dr.codvenfac )
            LEFT OUTER JOIN vendedor_clase                                                                      vcc ON ( vcc.id_cia = pin_id_cia
            )
                                                  AND vcc.clase = 1
                                                  AND vcc.codven = dr.codvenfac
            LEFT OUTER JOIN c_pago                                                                              cp ON ( cp.id_cia = pin_id_cia
            )
                                         AND ( cp.codpag = dr.codcpagfac )
            LEFT OUTER JOIN cliente                                                                             cl ON ( cl.id_cia = pin_id_cia
            )
                                          AND ( cl.codcli = dr.codclifac )
            LEFT OUTER JOIN titulolista                                                                         tl ON ( tl.id_cia = pin_id_cia
            )
                                              AND tl.codtit = cl.codtit
            LEFT OUTER JOIN vendedor                                                                            vc ON ( vc.id_cia = pin_id_cia
            )
                                           AND ( vc.codven = cl.codven )
            LEFT OUTER JOIN vendedor_clase                                                                      vcc3 ON ( vcc3.id_cia = pin_id_cia
            )
                                                   AND vcc3.clase = 3
                                                   AND vcc3.codven = cl.codven
            LEFT OUTER JOIN clase_vendedor_codigo                                                               vccc3 ON ( vccc3.id_cia = pin_id_cia
            )
                                                           AND vccc3.clase = 3
                                                           AND vccc3.codigo = vcc3.codigo
            LEFT OUTER JOIN articulos                                                                           a ON ( a.id_cia = pin_id_cia
            )
                                           AND ( a.tipinv = df.tipinv )
                                           AND ( a.codart = df.codart )
            LEFT OUTER JOIN TABLE ( pack_articulos.sp_buscar_clase_codigo(pin_id_cia, a.tipinv, a.codart, 2) )  ca2 ON 0 = 0
            LEFT OUTER JOIN TABLE ( pack_articulos.sp_buscar_clase_codigo(pin_id_cia, a.tipinv, a.codart, 3) )  ca3 ON 0 = 0
            LEFT OUTER JOIN TABLE ( pack_articulos.sp_buscar_clase_codigo(pin_id_cia, a.tipinv, a.codart, 5) )  ca5 ON 0 = 0
            LEFT OUTER JOIN TABLE ( pack_articulos.sp_buscar_clase_codigo(pin_id_cia, a.tipinv, a.codart, 11) ) ca11 ON 0 = 0
            LEFT OUTER JOIN cliente                                                                             ap ON ( ap.id_cia = pin_id_cia
            )
                                          AND ap.codcli = a.codprv
            LEFT OUTER JOIN TABLE ( pack_cliente.sp_buscar_clase_codigo(pin_id_cia, 'B', a.codprv, 900) )       cp900c ON 0 = 0
            LEFT OUTER JOIN TABLE ( pack_cliente.sp_buscar_clase_codigo(pin_id_cia, 'A', dr.codclifac, 14) )    c1c ON c1c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( pack_cliente.sp_buscar_clase_codigo(pin_id_cia, 'A', dr.codclifac, 15) )    c2c ON c2c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( pack_cliente.sp_buscar_clase_codigo(pin_id_cia, 'A', dr.codclifac, 16) )    c3c ON c3c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( pack_cliente.sp_buscar_clase_codigo(pin_id_cia, 'A', dr.codclifac, 28) )    c28c ON c28c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( pack_cliente.sp_buscar_clase_codigo(pin_id_cia, 'A', dr.codclifac, 902) )   c902c ON c902c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( pack_cliente.sp_buscar_clase_codigo(pin_id_cia, 'A', dr.codclifac, 900) )   c900c ON c900c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( pack_cliente.sp_buscar_clase_codigo(pin_id_cia, 'A', dr.codclifac, 901) )   c901c ON c901c.codigo <> 'ND'
            LEFT OUTER JOIN cliente                                                                             ccc ON ( ccc.id_cia = pin_id_cia
            )
                                           AND ( ccc.codcli = a.codprv )
            LEFT OUTER JOIN companias                                                                           cpp ON cpp.cia = pin_id_cia
            LEFT OUTER JOIN documentos_situac_max                                                               dx ON ( dx.id_cia = pin_id_cia
            )
                                                        AND ( dx.numint = dr.numintfac )
                                                        AND ( dx.situac = 'A' )
            LEFT OUTER JOIN usuarios                                                                            ue ON ( ue.id_cia = pin_id_cia
            )
                                           AND ue.coduser = dx.usuari
            LEFT OUTER JOIN TABLE ( pack_trazabilidad.sp_trazabilidad_tipdoc(pin_id_cia, dr.numintfac, 101) )   top ON 0 = 0
            LEFT OUTER JOIN documentos_situac_max                                                               smp ON ( smp.id_cia = pin_id_cia
            )
                                                         AND smp.numint = top.numint
                                                         AND smp.situac = 'A'
            LEFT OUTER JOIN usuarios                                                                            usm ON ( usm.id_cia = pin_id_cia
            )
                                            AND usm.coduser = smp.usuari
        WHERE
            dr.tipdocfac IN ( 1, 3, 7, 8, 210 )
            AND dr.situacfac IN ( 'C', 'B', 'H', 'G', 'F' )
        ORDER BY
            dr.tipdocfac,
            dr.seriefac,
            dr.numdocfac,
            dr.numitefac;

    BEGIN
        FOR input_record IN cur_select LOOP
            output_record.documento := input_record.documento;
            output_record.sucursal := input_record.sucursal;
            output_record.mes := input_record.mes;
            output_record.periodo := input_record.periodo;
            output_record.mesid := input_record.mesid;
            output_record.serie := input_record.serie;
            output_record.numdoc := input_record.numdoc;
            output_record.femisi := input_record.femisi;
            output_record.tcambio := input_record.tcambio;
            output_record.codcli := input_record.codcli;
            output_record.clase_abc := input_record.clase_abc;
            output_record.clascli := input_record.clascli;
            output_record.tipcli := input_record.tipcli;
            output_record.cliente := input_record.cliente;
            output_record.fcreac_cli := input_record.fcreac_cli;
            output_record.ruc := input_record.ruc;
            output_record.fpago := input_record.fpago;
            output_record.motivo := input_record.motivo;
            output_record.vencompvnt := input_record.vencompvnt;
            output_record.venasigcli := input_record.venasigcli;
            output_record.moneda := input_record.moneda;
            output_record.tipinv := input_record.tipinv;
            output_record.proveedor := input_record.proveedor;
            output_record.lineanegocio := input_record.lineanegocio;
            output_record.famproducto := input_record.famproducto;
            output_record.tipoproducto := input_record.tipoproducto;
            output_record.clasproducto := input_record.clasproducto;
            output_record.codigo := input_record.codigo;
            output_record.descripcion := input_record.descripcion;
            output_record.cantidad := input_record.cantidad;
            output_record.cosunisol := input_record.cosunisol;
            output_record.cosunidol := input_record.cosunidol;
            output_record.cantidori := input_record.cantidori;
            output_record.prenetunisol := input_record.prenetunisol;
            output_record.prenetunidol := input_record.prenetunidol;
            output_record.salpen := input_record.salpen;
            output_record.cancelado := input_record.cancelado;
            output_record.comision := input_record.comision;
            output_record.departamento := input_record.departamento;
            output_record.provincia := input_record.provincia;
            output_record.distrito := input_record.distrito;
            output_record.geconomico := input_record.geconomico;
            output_record.coduseremi := input_record.coduseremi;
            output_record.usuariemit := input_record.usuariemit;
            output_record.tlista := input_record.tlista;
            output_record.margenprov := input_record.margenprov;
            output_record.supervisor := input_record.supervisor;
            output_record.ordenpedido := input_record.ordenpedido;
            output_record.usuaremitop := input_record.usuaremitop;
            PIPE ROW ( output_record );
        END LOOP;
    END sp_cuboventas001;

    FUNCTION sp_cuboventas002 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_ventas2
        PIPELINED
    AS
        v_table datatable_cubo_ventas2;
    BEGIN
        SELECT
            ddc.descri                                                                        AS documento,
            s.sucursal                                                                        AS sucursal,
            to_char(dc.femisi, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')                            AS diasemana,
            ms.desmay                                                                         AS mes,
            TO_NUMBER(to_char(dc.femisi, 'YYYY'))                                             AS periodo,
            TO_NUMBER(to_char(dc.femisi, 'YYYY')) * 100 + TO_NUMBER(to_char(dc.femisi, 'MM')) AS mesid,
            dc.series                                                                         AS serie,
            dc.numdoc                                                                         AS nro_documento,
            to_char(dc.femisi, 'DD/MM/YYYY')                                                  AS fecha_emision,
            dc.tipcam                                                                         AS tipo_cambio,
            dc.codcli                                                                         AS codigo_cliente,
            c902c.descodigo                                                                   AS clasificacion_cliente,
            c900c.descodigo                                                                   AS tipo_cliente,
            dc.razonc                                                                         AS cliente,
            dc.ruc                                                                            AS ruc,
            cp.despag                                                                         AS forma_pago,
            mt.desmot                                                                         AS motivo,
            ve.desven                                                                         AS vendedor,
            dc.tipmon                                                                         AS moneda,
            dd.tipinv                                                                         AS tipo_inventario,
            ca3.descodigo                                                                     AS linea_negocio,
            ca2.descodigo                                                                     AS familia_producto,
            ca5.descodigo                                                                     AS tipo_producto,
            ca11.descodigo                                                                    AS clasificacion_producto,
            dd.codart                                                                         AS codigo,
            a.descri                                                                          AS descripcion,
            decode(nvl(mt60.valor, 'N'),
                   'S',
                   0,
                   dd.cantid * ddc.signo)                                                     AS cantidad,
            CASE
                WHEN nvl(mt60.valor, 'N') = 'S' THEN
                    0
                ELSE
                    nvl(round((k.costot01 / decode(k.cantid, 0, 1, k.cantid)) * ddc.signo,
                              2),
                        0)
            END                                                                               AS cosunisol,
            CASE
                WHEN nvl(mt60.valor, 'N') = 'S' THEN
                    0
                ELSE
                    nvl(round((k.costot02 / decode(k.cantid, 0, 1, k.cantid)) * ddc.signo,
                              2),
                        0)
            END                                                                               AS cosunidol,
            decode(nvl(mt60.valor, 'N'),
                   'S',
                   0,
                   nvl(k.costot01 * ddc.signo, 0))                                            AS costototsol,
            decode(nvl(mt60.valor, 'N'),
                   'S',
                   0,
                   nvl(k.costot02 * ddc.signo, 0))                                            AS costototdol,
            round(
                CASE
                    WHEN dc.tipmon = 'PEN' THEN
                        (dd.monafe + dd.monina) / CAST(dd.cantid AS NUMERIC(16, 4))
                    ELSE
                        ((dd.monafe + dd.monina) * dc.tipcam) / CAST(dd.cantid AS NUMERIC(16, 4))
                END
                * ddc.signo,
                4)                                                                          AS preunisol,
            round(
                CASE
                    WHEN dc.tipmon = 'USD' THEN
                        (dd.monafe + dd.monina) / CAST(dd.cantid AS NUMERIC(16, 4))
                    ELSE
                        ((dd.monafe + dd.monina) / dc.tipcam) / CAST(dd.cantid AS NUMERIC(16, 4))
                END
                * ddc.signo,
                4)                                                                          AS preunidol,
            round(
                CASE
                    WHEN dc.tipmon = 'PEN' THEN
                        (dd.monafe + dd.monina)
                    ELSE
                        ((dd.monafe + dd.monina) * dc.tipcam)
                END
                * ddc.signo, 4)                                                                   AS ventatotsol,
            round(
                CASE
                    WHEN dc.tipmon = 'USD' THEN
                        (dd.monafe + dd.monina)
                    ELSE
                        ((dd.monafe + dd.monina) / dc.tipcam)
                END
                * ddc.signo, 4)                                                                   AS ventatotdol,
            CAST((
                CASE
                    WHEN dc.tipmon = 'PEN' THEN
                        (dd.monafe + dd.monina)
                    ELSE
                        ((dd.monafe + dd.monina) * dc.tipcam)
                END
                - nvl(k.costot01, 0)) * ddc.signo AS NUMERIC(16,
                 2))                                                                          AS rentabilidad_soles,
            CASE
                WHEN ( dd.monafe + dd.monina ) = 0 THEN
                    CAST(0 AS NUMERIC(16, 3))
                ELSE
                    CAST((
                        CASE
                            WHEN dc.tipmon = 'PEN' THEN
                                (dd.monafe + dd.monina)
                            ELSE
                                ((dd.monafe + dd.monina) * dc.tipcam)
                        END
                        - nvl(k.costot01, 0)) /
                         CASE
                             WHEN dc.tipmon = 'PEN' THEN
                                 (dd.monafe + dd.monina)
                             ELSE
                                 ((dd.monafe + dd.monina) * dc.tipcam)
                         END
                    AS NUMERIC(16,
                         3))
            END                                                                               AS porcentaje,
            (
                SELECT
                    vreal
                FROM
                    documentos_det_clase
                WHERE
                        id_cia = dc.id_cia
                    AND numint = dc.numint
                    AND numite = dd.numite
                    AND clase = 1
            )                                                                                 AS comision,
            coalesce(c1c.descodigo, 'ND - DEPARTAMENTO')                                      AS departamento,
            coalesce(c2c.descodigo, 'ND - PROVINCIA')                                         AS provincia,
            coalesce(c3c.descodigo, 'ND - DISTRITO')                                          AS distrito,
            coalesce(c28c.descodigo, 'ND - DISTRITO')                                         AS grupo_economico,
            nvl(mc44.valor, 'N')                                                              AS transferencia_gratuita
        BULK COLLECT
        INTO v_table
        FROM
                 documentos_cab dc
            INNER JOIN documentos_det                                                           dd ON dc.id_cia = dd.id_cia -- Sale un Null
                                            AND dc.numint = dd.numint
            LEFT OUTER JOIN tdoccobranza                                                             ddc ON ( dc.id_cia = ddc.id_cia )
                                                AND ( ddc.tipdoc = dc.tipdoc )
            LEFT OUTER JOIN sucursal                                                                 s ON s.id_cia = dc.id_cia
                                          AND ( s.codsuc = dc.codsuc )
            LEFT OUTER JOIN meses                                                                    ms ON ms.id_cia = dc.id_cia
                                        AND ( ms.nromes = EXTRACT(MONTH FROM dc.femisi) )
            LEFT OUTER JOIN c_pago                                                                   cp ON cp.id_cia = dc.id_cia
                                         AND ( cp.codpag = dc.codcpag )
            LEFT OUTER JOIN vendedor                                                                 ve ON ve.id_cia = dc.id_cia
                                           AND ( ve.codven = dc.codven )
            LEFT OUTER JOIN articulos                                                                a ON a.id_cia = dd.id_cia
                                           AND ( a.tipinv = dd.tipinv )
                                           AND ( a.codart = dd.codart )
            LEFT OUTER JOIN kardex_costoventa                                                        k ON k.id_cia = dd.id_cia
                                                   AND k.numint = dd.numint
                                                   AND k.numite = dd.numite
            LEFT OUTER JOIN cliente_articulos_clase                                                  cl1 ON cl1.id_cia = dd.id_cia
                                                           AND cl1.tipcli = 'B'
                                                           AND cl1.codcli = a.codprv
                                                           AND cl1.clase = 1
                                                           AND cl1.codigo = dd.codadd01
            LEFT OUTER JOIN cliente_articulos_clase                                                  cl2 ON cl2.id_cia = dd.id_cia
                                                           AND cl2.tipcli = 'B'
                                                           AND cl2.codcli = a.codprv
                                                           AND cl2.clase = 2
                                                           AND cl2.codigo = dd.codadd02
            LEFT OUTER JOIN motivos                                                                  mt ON ( mt.id_cia = dc.id_cia )
                                          AND ( mt.tipdoc = dc.tipdoc )
                                          AND ( mt.id = dc.id )
                                          AND ( mt.codmot = dc.codmot )
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dc.id_cia, a.tipinv, a.codart, 2)  ca2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dc.id_cia, a.tipinv, a.codart, 3)  ca3 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dc.id_cia, a.tipinv, a.codart, 5)  ca5 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dc.id_cia, a.tipinv, a.codart, 11) ca11 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 902)      c902c ON c902c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 900)      c900c ON c900c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 14)       c1c ON c1c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 15)       c2c ON c2c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 16)       c3c ON c3c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 28)       c28c ON c28c.codigo <> 'ND'
            LEFT OUTER JOIN motivos_clase                                                            mc44 ON mc44.id_cia = dc.id_cia
                                                  AND mc44.tipdoc = dc.tipdoc
                                                  AND mc44.id = dc.id
                                                  AND mc44.codmot = dc.codmot
                                                  AND mc44.codigo = 44
            LEFT OUTER JOIN motivos_clase                                                            mt60 ON mt60.id_cia = dc.id_cia
                                                  AND mt60.tipdoc = dc.tipdoc
                                                  AND mt60.id = dc.id
                                                  AND mt60.codmot = dc.codmot
                                                  AND mt60.codigo = 60 -- COSTO Y CANTIDAD EN CERO, SOLO SI ESTA EN 'S'
        WHERE
                dc.id_cia = pin_id_cia
            AND trunc(dc.femisi) BETWEEN pin_fdesde AND pin_fhasta
            AND dc.tipdoc IN ( 1, 3, 7, 8, 210 )
            AND dc.situac IN ( 'C', 'B', 'H', 'G', 'F' );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cuboventas002;

    FUNCTION sp_cuboventas003 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_ventas3
        PIPELINED
    AS
        v_table datatable_cubo_ventas3;
    BEGIN
        SELECT
            ddc.descri                                                                        AS documento,
            s.sucursal                                                                        AS sucursal,
            to_char(dc.femisi, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')                            AS diasemana,
            ms.desmay                                                                         AS mes,
            TO_NUMBER(to_char(dc.femisi, 'YYYY'))                                             AS periodo,
            TO_NUMBER(to_char(dc.femisi, 'YYYY')) * 100 + TO_NUMBER(to_char(dc.femisi, 'MM')) AS mesid,
            dc.series                                                                         AS serie,
            dc.numdoc                                                                         AS nro_documento,
            to_char(dc.femisi, 'DD/MM/YYYY')                                                  AS fecha_emision,
            dc.tipcam                                                                         AS tipo_cambio,
            dc.codcli                                                                         AS codigo_cliente,
            c902c.descodigo                                                                   AS clasificacion_cliente,
            c900c.descodigo                                                                   AS tipo_cliente,
            dc.razonc                                                                         AS cliente,
            dc.ruc                                                                            AS ruc,
            cp.despag                                                                         AS forma_pago,
            mt.desmot                                                                         AS motivo,
            ve.desven                                                                         AS vendedor,
            dc.tipmon                                                                         AS moneda,
            dd.tipinv                                                                         AS tipo_inventario,
            ca3.descodigo                                                                     AS linea_negocio,
            ca2.descodigo                                                                     AS familia_producto,
            ca5.descodigo                                                                     AS tipo_producto,
            ca11.descodigo                                                                    AS clasificacion_producto,
            dd.codart                                                                         AS codigo,
            a.descri                                                                          AS descripcion,
            dd.etiqueta                                                                       AS etiqueta,
            dd.chasis                                                                         AS chasis,
            dd.motor                                                                          AS motor,
            decode(nvl(mt60.valor, 'N'),
                   'S',
                   0,
                   dd.cantid * ddc.signo)                                                     AS cantidad,
            CASE
                WHEN nvl(mt60.valor, 'N') = 'S' THEN
                    0
                ELSE
                    nvl(round((k.costot01 / decode(k.cantid, 0, 1, k.cantid)) * ddc.signo,
                              2),
                        0)
            END                                                                               AS cosunisol,
            CASE
                WHEN nvl(mt60.valor, 'N') = 'S' THEN
                    0
                ELSE
                    nvl(round((k.costot02 / decode(k.cantid, 0, 1, k.cantid)) * ddc.signo,
                              2),
                        0)
            END                                                                               AS cosunidol,
            decode(nvl(mt60.valor, 'N'),
                   'S',
                   0,
                   nvl(k.costot01 * ddc.signo, 0))                                            AS costototsol,
            decode(nvl(mt60.valor, 'N'),
                   'S',
                   0,
                   nvl(k.costot02 * ddc.signo, 0))                                            AS costototdol,
            round(
                CASE
                    WHEN dc.tipmon = 'PEN' THEN
                        (dd.monafe + dd.monina) / CAST(dd.cantid AS NUMERIC(16, 4))
                    ELSE
                        ((dd.monafe + dd.monina) * dc.tipcam) / CAST(dd.cantid AS NUMERIC(16, 4))
                END
                * ddc.signo,
                4)                                                                          AS preunisol,
            round(
                CASE
                    WHEN dc.tipmon = 'USD' THEN
                        (dd.monafe + dd.monina) / CAST(dd.cantid AS NUMERIC(16, 4))
                    ELSE
                        ((dd.monafe + dd.monina) / dc.tipcam) / CAST(dd.cantid AS NUMERIC(16, 4))
                END
                * ddc.signo,
                4)                                                                          AS preunidol,
            round(
                CASE
                    WHEN dc.tipmon = 'PEN' THEN
                        (dd.monafe + dd.monina)
                    ELSE
                        ((dd.monafe + dd.monina) * dc.tipcam)
                END
                * ddc.signo, 4)                                                                   AS ventatotsol,
            round(
                CASE
                    WHEN dc.tipmon = 'USD' THEN
                        (dd.monafe + dd.monina)
                    ELSE
                        ((dd.monafe + dd.monina) / dc.tipcam)
                END
                * ddc.signo, 4)                                                                   AS ventatotdol,
            CAST((
                CASE
                    WHEN dc.tipmon = 'PEN' THEN
                        (dd.monafe + dd.monina)
                    ELSE
                        ((dd.monafe + dd.monina) * dc.tipcam)
                END
                - nvl(k.costot01, 0)) * ddc.signo AS NUMERIC(16,
                 2))                                                                          AS rentabilidad_soles,
            CASE
                WHEN ( dd.monafe + dd.monina ) = 0 THEN
                    CAST(0 AS NUMERIC(16, 3))
                ELSE
                    CAST((
                        CASE
                            WHEN dc.tipmon = 'PEN' THEN
                                (dd.monafe + dd.monina)
                            ELSE
                                ((dd.monafe + dd.monina) * dc.tipcam)
                        END
                        - nvl(k.costot01, 0)) /
                         CASE
                             WHEN dc.tipmon = 'PEN' THEN
                                 (dd.monafe + dd.monina)
                             ELSE
                                 ((dd.monafe + dd.monina) * dc.tipcam)
                         END
                    AS NUMERIC(16,
                         3))
            END                                                                               AS porcentaje,
            (
                SELECT
                    vreal
                FROM
                    documentos_det_clase
                WHERE
                        id_cia = dc.id_cia
                    AND numint = dc.numint
                    AND numite = dd.numite
                    AND clase = 1
            )                                                                                 AS comision,
            coalesce(c1c.descodigo, 'ND - DEPARTAMENTO')                                      AS departamento,
            coalesce(c2c.descodigo, 'ND - PROVINCIA')                                         AS provincia,
            coalesce(c3c.descodigo, 'ND - DISTRITO')                                          AS distrito,
            coalesce(c28c.descodigo, 'ND - DISTRITO')                                         AS grupo_economico,
            nvl(mc44.valor, 'N')                                                              AS transferencia_gratuita
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab                                                           dc
            LEFT OUTER JOIN documentos_det                                                           dd ON dc.id_cia = dd.id_cia -- Sale un Null
                                                 AND dc.numint = dd.numint
            LEFT OUTER JOIN tdoccobranza                                                             ddc ON ( dc.id_cia = ddc.id_cia )
                                                AND ( ddc.tipdoc = dc.tipdoc )
            LEFT OUTER JOIN sucursal                                                                 s ON s.id_cia = dc.id_cia
                                          AND ( s.codsuc = dc.codsuc )
            LEFT OUTER JOIN meses                                                                    ms ON ms.id_cia = dc.id_cia
                                        AND ( ms.nromes = EXTRACT(MONTH FROM dc.femisi) )
            LEFT OUTER JOIN c_pago                                                                   cp ON cp.id_cia = dc.id_cia
                                         AND ( cp.codpag = dc.codcpag )
            LEFT OUTER JOIN vendedor                                                                 ve ON ve.id_cia = dc.id_cia
                                           AND ( ve.codven = dc.codven )
            LEFT OUTER JOIN articulos                                                                a ON a.id_cia = dd.id_cia
                                           AND ( a.tipinv = dd.tipinv )
                                           AND ( a.codart = dd.codart )
            LEFT OUTER JOIN cliente_articulos_clase                                                  cl1 ON cl1.id_cia = dd.id_cia
                                                           AND cl1.tipcli = 'B'
                                                           AND cl1.codcli = a.codprv
                                                           AND cl1.clase = 1
                                                           AND cl1.codigo = dd.codadd01
            LEFT OUTER JOIN cliente_articulos_clase                                                  cl2 ON cl2.id_cia = dd.id_cia
                                                           AND cl2.tipcli = 'B'
                                                           AND cl2.codcli = a.codprv
                                                           AND cl2.clase = 2
                                                           AND cl2.codigo = dd.codadd02
            LEFT OUTER JOIN motivos                                                                  mt ON ( mt.id_cia = dc.id_cia )
                                          AND ( mt.tipdoc = dc.tipdoc )
                                          AND ( mt.id = dc.id )
                                          AND ( mt.codmot = dc.codmot )
            LEFT OUTER JOIN kardex001                                                                k001 ON k001.id_cia = dd.id_cia
                                              AND k001.tipinv = dd.tipinv
                                              AND k001.codart = dd.codart
                                              AND k001.codalm = dd.codalm
                                              AND k001.etiqueta = dd.etiqueta
            LEFT OUTER JOIN kardex_costoventa                                                        k ON k.id_cia = dd.id_cia
                                                   AND k.numint = dd.numint
                                                   AND k.numite = dd.numite
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dc.id_cia, a.tipinv, a.codart, 2)  ca2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dc.id_cia, a.tipinv, a.codart, 3)  ca3 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dc.id_cia, a.tipinv, a.codart, 5)  ca5 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dc.id_cia, a.tipinv, a.codart, 11) ca11 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 902)      c902c ON c902c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 900)      c900c ON c900c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 14)       c1c ON c1c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 15)       c2c ON c2c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 16)       c3c ON c3c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 28)       c28c ON c28c.codigo <> 'ND'
            LEFT OUTER JOIN motivos_clase                                                            mc44 ON mc44.id_cia = dc.id_cia
                                                  AND mc44.tipdoc = dc.tipdoc
                                                  AND mc44.id = dc.id
                                                  AND mc44.codmot = dc.codmot
                                                  AND mc44.codigo = 44
            LEFT OUTER JOIN motivos_clase                                                            mt60 ON mt60.id_cia = dc.id_cia
                                                  AND mt60.tipdoc = dc.tipdoc
                                                  AND mt60.id = dc.id
                                                  AND mt60.codmot = dc.codmot
                                                  AND mt60.codigo = 60 -- COSTO Y CANTIDAD EN CERO, SOLO SI ESTA EN 'S'
        WHERE
                dc.id_cia = pin_id_cia
            AND trunc(dc.femisi) BETWEEN pin_fdesde AND pin_fhasta
            AND dc.tipdoc IN ( 1, 3, 7, 8, 210 )
            AND dc.situac IN ( 'C', 'B', 'H', 'G', 'F' );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cuboventas003;

    FUNCTION sp_cuboventas004 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_ventas4
        PIPELINED
    AS
        v_table datatable_cubo_ventas4;
    BEGIN
        SELECT
            ddc.descri                                                                        AS documento,
            s.sucursal                                                                        AS sucursal,
            ms.desmay                                                                         AS mes,
            TO_NUMBER(to_char(dc.femisi, 'YYYY'))                                             AS periodo,
            to_char(dc.femisi, 'DD/MM/YY')                                                    AS femisi,
            trunc(dc.femisi)                                                                  AS femisi,
            TO_NUMBER(to_char(dc.femisi, 'YYYY')) * 100 + TO_NUMBER(to_char(dc.femisi, 'MM')) AS mesid,
            dc.series                                                                         AS serie,
            dc.numdoc                                                                         AS nro_documento,
            cp.despag                                                                         AS forma_pago,
            dc.codcli                                                                         AS codigo_cliente,
            dc.razonc                                                                         AS cliente,
            dc.ruc                                                                            AS ruc,
            ve.desven                                                                         AS vendedor,
            dd.tipinv                                                                         AS tipo_inventario,
            dd.codart                                                                         AS codigo,
            a.descri                                                                          AS descripcion,
            a2.descodigo                                                                      AS familia,
            a3.descodigo                                                                      AS linea,
            a12.descodigo                                                                     AS marca,
            acc69.codigo                                                                      AS cuenta_contable,
            acc69.descodigo                                                                   AS descripcion_cuenta,
            dd.codalm,
            aa.descri                                                                         AS almacen,
            dd.cantid * ddc.signo                                                             AS cantidad,
            round(
                CASE
                    WHEN dc.tipmon = 'PEN' THEN
                        (dd.monafe + dd.monina) / CAST(dd.cantid AS NUMERIC(16, 4))
                    ELSE
                        ((dd.monafe + dd.monina) * dc.tipcam) / CAST(dd.cantid AS NUMERIC(16, 4))
                END
                * ddc.signo,
                4)                                                                          AS prenetunisol,
            round(
                CASE
                    WHEN dc.tipmon = 'USD' THEN
                        (dd.monafe + dd.monina) / CAST(dd.cantid AS NUMERIC(16, 4))
                    ELSE
                        ((dd.monafe + dd.monina) / dc.tipcam) / CAST(dd.cantid AS NUMERIC(16, 4))
                END
                * ddc.signo,
                4)                                                                          AS prenetunidol,
            round(
                CASE
                    WHEN dc.tipmon = 'PEN' THEN
                        (dd.monafe + dd.monina)
                    ELSE
                        ((dd.monafe + dd.monina) * dc.tipcam)
                END
                * ddc.signo, 4)                                                                   AS ventatotsol,
            round(
                CASE
                    WHEN dc.tipmon = 'USD' THEN
                        (dd.monafe + dd.monina)
                    ELSE
                        ((dd.monafe + dd.monina) / dc.tipcam)
                END
                * ddc.signo, 4)                                                                   AS ventatotdol,
            dc.tipcam                                                                         AS t_cambio,
            dc.tipmon                                                                         AS moneda,
            mt.desmot                                                                         AS motivo,
            c20.descodigo                                                                     AS "GRUPO DE CLIENTE",
            c21.descodigo                                                                     AS "CLASIFICACION DE CLIENTE",
            c14.descodigo                                                                     AS "DEPARTAMENTO",
            c15.descodigo                                                                     AS provincia,
            c16.descodigo                                                                     AS distrito,
            c35.descodigo                                                                     AS zona,
            dcd.descri                                                                        AS "TIPO VENTA",
            k001.ancho                                                                        AS dioptria,
            k001.lote                                                                         AS lote,
            k001.nrocarrete                                                                   AS "SERIE ETIQUETA",
            nvl(mc44.valor, 'N')                                                              AS transferencia_gratuita
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab                                                             dc
            LEFT OUTER JOIN tdoccobranza                                                               ddc ON ddc.id_cia = dc.id_cia
                                                AND ddc.tipdoc = dc.tipdoc
            LEFT OUTER JOIN sucursal                                                                   s ON s.id_cia = dc.id_cia
                                          AND s.codsuc = dc.codsuc
            LEFT OUTER JOIN meses                                                                      ms ON ms.id_cia = dc.id_cia
                                        AND ms.nromes = EXTRACT(MONTH FROM dc.femisi)
            LEFT OUTER JOIN c_pago                                                                     cp ON cp.id_cia = dc.id_cia
                                         AND cp.codpag = dc.codcpag
            LEFT OUTER JOIN vendedor                                                                   ve ON ve.id_cia = dc.id_cia
                                           AND ve.codven = dc.codven
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 20)         c20 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 21)         c21 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 35)         c35 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 14)         c14 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 15)         c15 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 16)         c16 ON 0 = 0
            LEFT OUTER JOIN documentos_cab_clase                                                       dcc ON dcc.id_cia = dc.id_cia
                                                        AND ( dcc.numint = dc.numint )
                                                        AND ( dcc.clase = 7 )
            LEFT OUTER JOIN clase_documentos_cab_codigo                                                dcd ON dcd.id_cia = dc.id_cia
                                                               AND ( dcd.tipdoc = 1 )
                                                               AND ( dcd.clase = dcc.clase )
                                                               AND ( dcd.codigo = dcc.codigo )
            LEFT OUTER JOIN documentos_det                                                             dd ON dd.id_cia = dc.id_cia -- Sale un Null
                                                 AND dd.numint = dc.numint
            LEFT OUTER JOIN articulos                                                                  a ON a.id_cia = dd.id_cia
                                           AND ( a.tipinv = dd.tipinv )
                                           AND ( a.codart = dd.codart )
            LEFT OUTER JOIN almacen                                                                    aa ON aa.id_cia = dd.id_cia
                                          AND aa.tipinv = dd.tipinv
                                          AND aa.codalm = dd.codalm
                                          AND aa.codsuc = dc.codsuc
            LEFT OUTER JOIN motivos                                                                    mt ON mt.id_cia = dc.id_cia
                                          AND ( mt.tipdoc = dc.tipdoc )
                                          AND ( mt.id = dc.id )
                                          AND ( mt.codmot = dc.codmot )
            LEFT OUTER JOIN motivos_clase                                                              mc ON mc.id_cia = dc.id_cia
                                                AND ( mc.tipdoc = dc.tipdoc )
                                                AND ( mc.id = dc.id )
                                                AND ( mc.codmot = dc.codmot )
                                                AND ( mc.codigo = 2 )
            LEFT OUTER JOIN kardex001                                                                  k001 ON k001.id_cia = dd.id_cia
                                              AND k001.tipinv = dd.tipinv
                                              AND k001.codart = dd.codart
                                              AND k001.codalm = dd.codalm
                                              AND k001.etiqueta = dd.etiqueta
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dd.id_cia, dd.tipinv, dd.codart, 2)  a2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dd.id_cia, dd.tipinv, dd.codart, 3)  a3 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dd.id_cia, dd.tipinv, dd.codart, 12) a12 ON 0 = 0
            LEFT OUTER JOIN cliente_clase                                                              ccl4 ON ccl4.id_cia = dc.id_cia
                                                  AND ccl4.codcli = dc.codcli
                                                  AND ccl4.tipcli = 'A'
                                                  AND ccl4.clase = 4 /* CLIENTE RELACIONADO */
            LEFT OUTER JOIN ( pack_articulos.sp_buscar_clase_codigo(dc.id_cia, dd.tipinv, dd.codart, ccl4.codigo) ) acc69 ON 0 = 0
            LEFT OUTER JOIN motivos_clase                                                              mc44 ON mc44.id_cia = dc.id_cia
                                                  AND mc44.tipdoc = dc.tipdoc
                                                  AND mc44.id = dc.id
                                                  AND mc44.codmot = dc.codmot
                                                  AND mc44.codigo = 44
        WHERE
                dc.id_cia = pin_id_cia
            AND trunc(dc.femisi) BETWEEN pin_fdesde AND pin_fhasta
            AND dc.tipdoc IN ( 1, 3, 7, 8, 210 )
            AND dc.situac IN ( 'C', 'B', 'H', 'G', 'F' );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cuboventas004;

    -- Cubo de Ventas para Taga
    FUNCTION sp_cuboventas005 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_ventas5
        PIPELINED
    AS
        v_table datatable_cubo_ventas5;
    BEGIN
        SELECT
            dc.descri                                         AS "DOCUMENTO",
            ms.desmin                                         AS "MES",
            dr.series                                         AS "SERIE",
            dr.numdoc                                         AS "NRO DOCUMENTO",
            to_char(dr.femisi, 'DD/MM/YYYY')                  AS "FECHA EMISION",
            dr.tipcam                                         AS "TCAMBIO",
            dr.codcli                                         AS "CODIGO CLIENTE",
            dr.razonc                                         AS "CLIENTE",
            dr.ruc                                            AS "RUC",
            m.desmot                                          "MOTIVO",
            cp.despag                                         AS "FORMA DE PAGO",
            vc.abrevi                                         AS "VENDEDOR ABREVIATURA",
            vc.desven                                         AS "VENDEDO ASIG CLIENTE",
            dr.tipmon                                         AS "MONEDA",
            df.numite                                         AS "ITEM ",
            df.tipinv                                         AS "TINVENTARIO",
            inv.dtipinv                                       AS "TIPO DE INVENTARIO",
            df.codart                                         AS "CODIGO",
            a.descri                                          AS "DESCRIPCION",
            df.etiqueta                                       AS "ETIQUETA",
            df.ancho                                          AS "DIOPTRIA",
            df.lote                                           AS "LOTE",
            df.nrocarrete                                     AS "SERIE ARTICULO",
            to_char(df.fvenci, 'DD/MM/YYYY')                  AS "FECHA DE VENCIMIENTO",
            al.codalm                                         AS "CODIGO ALMACEN",
            al.descri                                         AS "ALMACEN",
            CASE
                WHEN arc.cantid <> 0
                     AND arc.costo01 <> 0 THEN
                    arc.costo01 / arc.cantid
                ELSE
                    0
            END                                               AS "COSTO ALMACEN",
            ccc.razonc                                        AS "PROVEEDOR",
            cc5.descodigo                                     AS "ESPECIALIDAD",
            cc3.descodigo                                     AS "SUB FAMILIA",
            df.cantid * dc.signo                              AS "CANTIDAD",
            CASE
                WHEN dr.tipmon = 'PEN' THEN
                        ( df.monafe + df.monina ) / CAST(df.cantid AS NUMERIC(16, 4))
                ELSE
                    ( ( df.monafe + df.monina ) * dr.tipcam ) / CAST(df.cantid AS NUMERIC(16, 4))
            END
            * dc.signo                                        AS "PRECIO UNIT SOLES",
            CASE
                WHEN dr.tipmon = 'PEN' THEN
                        ( df.monafe + df.monina )
                ELSE
                    ( ( df.monafe + df.monina ) * dr.tipcam )
            END
            * dc.signo                                        AS "VENTA TOTAL SOLES",
            CAST(
                CASE
                    WHEN k.costot01 <> 0 THEN
                        k.costot01 / df.cantid
                    ELSE
                        0.0
                END
            AS NUMERIC(16, 5))                                "COSTO UNITARIO",
            k.costot01 * dc.signo                             AS "COSTO TOTAL SOLES",
            CAST((
                CASE
                    WHEN dr.tipmon = 'PEN' THEN
                        (df.monafe + df.monina)
                    ELSE
                        ((df.monafe + df.monina) * dr.tipcam)
                END
                - k.costot01) * dc.signo AS NUMERIC(16, 2))       AS "RENTABILIDAD SOLES",
            CASE
                WHEN ( df.monafe + df.monina ) = 0 THEN
                    CAST(0 AS NUMERIC(16, 3))
                ELSE
                    CAST((
                        CASE
                            WHEN dr.tipmon = 'PEN' THEN
                                (df.monafe + df.monina)
                            ELSE
                                ((df.monafe + df.monina) * dr.tipcam)
                        END
                        - k.costot01) /
                         CASE
                             WHEN dr.tipmon = 'PEN' THEN
                                 (df.monafe + df.monina)
                             ELSE
                                 ((df.monafe + df.monina) * dr.tipcam)
                         END
                    AS NUMERIC(16, 3))
            END                                               AS "PORCENTAJE",
            d1.saldo                                          AS "SALDO PENDIENTE",
            CASE
                WHEN CAST(d1.saldo AS INTEGER) = 0 THEN
                    'CANCELADO'
                ELSE
                    ''
            END                                               AS "CANCELADO",
            coalesce(c1c.descodigo, 'ND - DEPARTAMENTO')      AS "DEPARTAMENTO",
            coalesce(c2c.descodigo, 'ND - PROVINCIA')         AS "PROVINCIA",
            coalesce(c3c.descodigo, 'ND - DISTRITO')          AS "DISTRITO",
            coalesce(c35c.descodigo, 'ND - ZONA')             AS "ZONA",
            coalesce(c20c.descodigo, 'ND - GRUPO DE CLIENTE') AS "GRUPO DE CLIENTE",
            coalesce(c29c.descodigo, 'ND - FIDELIDAD')        AS "FIDELIDAD",
            coalesce(cc1.descodigo, 'ND - SITUACION')         AS "SITUACION DEL CLIENTE",
            nvl(mc44.valor, 'N')                              AS transferencia_gratuita
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab                                                            dr
            LEFT OUTER JOIN documentos_det                                                            df ON df.id_cia = dr.id_cia
                                                 AND df.numint = dr.numint
            LEFT OUTER JOIN kardex_costoventa                                                         k ON k.id_cia = df.id_cia
                                                   AND k.numint = df.numint
                                                   AND k.numite = df.numite
            LEFT OUTER JOIN dcta100                                                                   d1 ON d1.id_cia = dr.id_cia
                                          AND d1.numint = dr.numint
            LEFT OUTER JOIN tdoccobranza                                                              dc ON dc.id_cia = dr.id_cia
                                               AND dc.tipdoc = dr.tipdoc
            LEFT OUTER JOIN sucursal                                                                  s ON s.id_cia = dr.id_cia
                                          AND s.codsuc = dr.codsuc
            LEFT OUTER JOIN motivos                                                                   m ON m.id_cia = dr.id_cia
                                         AND m.tipdoc = dr.tipdoc
                                         AND m.id = dr.id
                                         AND m.codmot = dr.codmot
            LEFT OUTER JOIN motivos_clase                                                             mc ON mc.id_cia = dr.id_cia
                                                AND mc.tipdoc = dr.tipdoc
                                                AND mc.id = dr.id
                                                AND mc.codmot = dr.codmot
                                                AND mc.codigo = 2
            LEFT OUTER JOIN meses                                                                     ms ON ms.id_cia = dr.id_cia
                                        AND ms.nromes = EXTRACT(MONTH FROM dr.femisi)
            LEFT OUTER JOIN vendedor                                                                  ve ON ve.id_cia = dr.id_cia
                                           AND ve.codven = dr.codven
            LEFT OUTER JOIN vendedor_clase                                                            vcc ON vcc.id_cia = dr.id_cia
                                                  AND vcc.clase = 1
                                                  AND vcc.codven = dr.codven
            LEFT OUTER JOIN c_pago                                                                    cp ON cp.id_cia = dr.id_cia
                                         AND cp.codpag = dr.codcpag
            LEFT OUTER JOIN cliente                                                                   cl ON cl.id_cia = dr.id_cia
                                          AND cl.codcli = dr.codcli
            LEFT OUTER JOIN vendedor                                                                  vc ON vc.id_cia = dr.id_cia
                                           AND vc.codven = cl.codven
            LEFT OUTER JOIN articulos                                                                 a ON a.id_cia = df.id_cia
                                           AND a.tipinv = df.tipinv
                                           AND a.codart = df.codart
            LEFT OUTER JOIN almacen                                                                   al ON al.id_cia = df.id_cia
                                          AND al.tipinv = df.tipinv
                                          AND al.codalm = df.codalm
            LEFT OUTER JOIN t_inventario                                                              inv ON inv.id_cia = df.id_cia
                                                AND inv.tipinv = df.tipinv
            LEFT OUTER JOIN kardex001                                                                 k001 ON k001.id_cia = df.id_cia
                                              AND k001.tipinv = df.tipinv
                                              AND k001.codart = df.codart
                                              AND k001.codalm = df.codalm
                                              AND k001.etiqueta = df.etiqueta
            LEFT OUTER JOIN articulos_costo                                                           arc ON arc.id_cia = df.id_cia
                                                   AND arc.tipinv = df.tipinv
                                                   AND arc.codart = df.codart
                                                   AND arc.periodo = ( ( EXTRACT(YEAR FROM current_date) * 100 ) + EXTRACT(MONTH FROM
                                                   current_date) )
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 1)         cc1 ON cc1.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 14)        c1c ON c1c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 15)        c2c ON c2c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 16)        c3c ON c3c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 35)        c35c ON c35c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 20)        c20c ON c20c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 29)        c29c ON c20c.codigo <> 'ND'
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(df.id_cia, df.tipinv, df.codart, 2) cc2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(df.id_cia, df.tipinv, df.codart, 3) cc3 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(df.id_cia, df.tipinv, df.codart, 5) cc5 ON 0 = 0
            LEFT OUTER JOIN cliente                                                                   ccc ON ccc.id_cia = a.id_cia
                                           AND ccc.codcli = a.codprv
            LEFT OUTER JOIN companias                                                                 cpp ON cpp.cia = dr.id_cia
            LEFT OUTER JOIN motivos_clase                                                             mc44 ON mc44.id_cia = dr.id_cia
                                                  AND mc44.tipdoc = dr.tipdoc
                                                  AND mc44.id = dr.id
                                                  AND mc44.codmot = dr.codmot
                                                  AND mc44.codigo = 44
        WHERE
                dr.id_cia = pin_id_cia
            AND trunc(dr.femisi) BETWEEN pin_fdesde AND pin_fhasta
            AND dr.tipdoc IN ( 1, 3, 7, 8, 210 )
            AND dr.situac IN ( 'C', 'B', 'H', 'G', 'F' )
        ORDER BY
            dr.tipdoc,
            dr.series,
            dr.numdoc,
            df.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cuboventas005;

    -- Cubo de Ventas para RamirezFood
    FUNCTION sp_cuboventas006 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_ventas6
        PIPELINED
    AS
        v_table datatable_cubo_ventas6;
    BEGIN
        SELECT
            dc.descri                                    AS "DOCUMENTO",
            s.sucursal,
            to_char(dr.femisi, 'DAY')                    AS diasemana,
            ms.desmay                                    AS mes,
            EXTRACT(YEAR FROM dr.femisi)                 AS periodo,
            EXTRACT(YEAR FROM dr.femisi)
            ||
            CASE
                WHEN ( EXTRACT(MONTH FROM dr.femisi) < 10 ) THEN
                        '0'
                        || CAST(EXTRACT(MONTH FROM dr.femisi) AS VARCHAR(2))
                ELSE
                    CAST(EXTRACT(MONTH FROM dr.femisi) AS VARCHAR(2))
            END
            AS mesid,
            dr.series                                    AS "SERIE",
            dr.numdoc                                    AS "NRO DOCUMENTO",
            to_char(dr.femisi, 'DD/MM/YYYY')             AS "FECHA EMISION",
            dr.tipcam                                    AS "TIPO CAMBIO",
            dr.codcli                                    AS "CODIGO CLIENTE",
            c901c.descodigo                              AS "CLASE ABC",
            c902c.descodigo                              AS "CLASIFICACION DE CLIENTE",
            c900c.descodigo                              AS "TIPO DE CLIENTE",
            cl.razonc                                    AS "CLIENTE",
            to_char(cl.fcreac, 'DD/MM/YYYY')             AS "FECHA CREACION DEL CLIENTE",
            dr.ruc                                       AS "RUC",
            cp.despag                                    AS "FORMA DE PAGO",
            mt.desmot                                    AS "MOTIVO",
            ve.desven                                    AS "VENDEDOR DE COMP VNT",
            vc.desven                                    AS "VENDEDOR ASIG CLIENTE",
            dr.tipmon                                    AS "MONEDA",
            df.tipinv                                    AS "TIPO INVENTARIO",
            ap.razonc                                    AS "PROVEEDOR",
            ca3.descodigo                                AS "LINEA DE NEGOCIO",
            ca2.descodigo                                AS "FAMILIA DE PRODUCTO",
            ca5.descodigo                                AS "TIPO DE PRODUCTO",
            ca11.descodigo                               AS "CLASIFICACION DE PRODUCTO",
            df.codart                                    AS "CODIGO",
            a.descri                                     AS "DESCRIPCION",
            df.cantid * dc.signo                         AS "CANTIDAD_COSTO",
            round(((k.costot01) /(
                CASE
                    WHEN k.cantid <> 0 THEN
                        k.cantid
                    ELSE
                        1
                END
            )) * dc.signo, 2)                            AS "COSTO_UNIT_SOLES",
            round(((k.costot02) /(
                CASE
                    WHEN k.cantid <> 0 THEN
                        k.cantid
                    ELSE
                        1
                END
            )) * dc.signo, 2)                            AS "COSTO_UNIT_DOLARES",
       /* SACA EL COSTO DE LO TURADO */
            df.cantid                                    AS "CANTIDAD",
            round(
                CASE
                    WHEN dr.tipmon = 'PEN' THEN
                        (df.monafe + df.monina) / CAST(df.cantid AS NUMERIC(24, 8))
                    ELSE
                        ((df.monafe + df.monina) * dr.tipcam) / CAST(df.cantid AS NUMERIC(24, 8))
                END
                * dc.signo,
                2)                                     AS "PRENETUNISOL",
            round(
                CASE
                    WHEN dr.tipmon = 'USD' THEN
                        (df.monafe + df.monina) / CAST(df.cantid AS NUMERIC(24, 8))
                    ELSE
                        ((df.monafe + df.monina) / dr.tipcam) / CAST(df.cantid AS NUMERIC(24, 8))
                END
                * dc.signo,
                2)                                     AS "PRENETUNIDOL",
            round(
                CASE
                    WHEN dr.tipmon = 'PEN' THEN
                        (df.monafe + df.monina)
                    ELSE
                        ((df.monafe + df.monina) * dr.tipcam)
                END
                * dc.signo, 2)                               AS "VENTATOTSOL",
            round(
                CASE
                    WHEN dr.tipmon = 'USD' THEN
                        (df.monafe + df.monina)
                    ELSE
                        ((df.monafe + df.monina) / dr.tipcam)
                END
                * dc.signo, 2)                               AS "VENTATOTDOL",
            round(
                CASE
                    WHEN dr.tipmon = 'PEN' THEN
                        (df.monisc) / CAST(df.cantid AS NUMERIC(24, 8))
                    ELSE
                        ((df.monisc) * dr.tipcam) / CAST(df.cantid AS NUMERIC(24, 8))
                END
                * dc.signo,
                2)                                     AS "MONISCSOLES",
            df.valporisc                                 AS "VALPORISC",
            round(
                CASE
                    WHEN dr.tipmon = 'PEN' THEN
                        (df.monigv) / CAST(df.cantid AS NUMERIC(24, 8))
                    ELSE
                        ((df.monigv) * dr.tipcam) / CAST(df.cantid AS NUMERIC(24, 8))
                END
                * dc.signo,
                2)                                     AS "MONIGVSOLES",
            d1.saldo                                     AS "SALDO PENDIENTE",
            CASE
                WHEN CAST(d1.saldo AS INTEGER) = 0 THEN
                    'CANCELADO'
                ELSE
                    ''
            END                                          AS "CANCELADO",
            ddc.vreal                                    AS "COMISION",
            coalesce(c1c.descodigo, 'ND - DEPARTAMENTO') AS "DEPARTAMENTO",
            coalesce(c2c.descodigo, 'ND - PROVINCIA')    AS "PROVINCIA",
            coalesce(c3c.descodigo, 'ND - DISTRITO')     AS "DISTRITO",
            coalesce(c28c.descodigo, 'ND - DISTRITO')    AS "GRUPO ECONOMICO",
            coalesce(c24c.descodigo, 'ND - CANAL')       AS "CANAL",
            ue.coduser                                   AS "COD USER EMITIO",
            ue.nombres                                   AS "USUARIO EMITIDO",
            tl.titulo                                    AS "TITULO LISTA PRECIOS",
            cp900c.descodigo                             AS "MARGEN PROVEEDOR",
            vccc3.descri                                 AS "SUPERVISOR",
            top.series
            || ' - '
            || top.numdoc                                AS "ORDEN DE PEDIDO",
            usm.coduser
            || ' - '
            || usm.nombres                               AS "USUARIO QUE EMITIO OP",
            nvl(mc44.valor, 'N')                         AS transferencia_gratuita
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab                                                          dr
            LEFT OUTER JOIN documentos_det                                                          df ON df.id_cia = dr.id_cia
                                                 AND df.numint = dr.numint
            LEFT OUTER JOIN documentos_det_clase                                                    ddc ON ddc.id_cia = df.id_cia
                                                        AND ddc.numint = df.numint
                                                        AND ddc.numite = df.numite
                                                        AND ddc.clase = 1
            LEFT OUTER JOIN dcta100                                                                 d1 ON d1.id_cia = dr.id_cia
                                          AND d1.numint = dr.numint
            LEFT OUTER JOIN kardex_costoventa                                                       k ON k.id_cia = df.id_cia
                                                   AND k.numint = df.numint
                                                   AND k.numite = df.numite
            LEFT OUTER JOIN tdoccobranza                                                            dc ON dc.id_cia = dr.id_cia
                                               AND dc.tipdoc = dr.tipdoc
            LEFT OUTER JOIN sucursal                                                                s ON s.id_cia = dr.id_cia
                                          AND s.codsuc = dr.codsuc
            LEFT OUTER JOIN motivos                                                                 mt ON mt.id_cia = dr.id_cia
                                          AND ( mt.tipdoc = dr.tipdoc )
                                          AND ( mt.id = dr.id )
                                          AND ( mt.codmot = dr.codmot )
            LEFT OUTER JOIN motivos_clase                                                           mc ON mc.id_cia = dr.id_cia
                                                AND ( mc.tipdoc = dr.tipdoc )
                                                AND ( mc.id = dr.id )
                                                AND ( mc.codmot = dr.codmot )
                                                AND ( mc.codigo = 2 )
            LEFT OUTER JOIN meses                                                                   ms ON ms.id_cia = dr.id_cia
                                        AND ( ms.nromes = EXTRACT(MONTH FROM dr.femisi) )
            LEFT OUTER JOIN vendedor                                                                ve ON ve.id_cia = dr.id_cia
                                           AND ( ve.codven = dr.codven )
            LEFT OUTER JOIN vendedor_clase                                                          vcc ON vcc.id_cia = dr.id_cia
                                                  AND vcc.clase = 1
                                                  AND vcc.codven = dr.codven
            LEFT OUTER JOIN c_pago                                                                  cp ON cp.id_cia = dr.id_cia
                                         AND ( cp.codpag = dr.codcpag )
            LEFT OUTER JOIN cliente                                                                 cl ON cl.id_cia = dr.id_cia
                                          AND ( cl.codcli = dr.codcli )
            LEFT OUTER JOIN titulolista                                                             tl ON tl.id_cia = dr.id_cia
                                              AND tl.codtit = cl.codtit
            LEFT OUTER JOIN vendedor                                                                vc ON vc.id_cia = dr.id_cia
                                           AND ( vc.codven = cl.codven )
            LEFT OUTER JOIN vendedor_clase                                                          vcc3 ON vcc3.id_cia = dr.id_cia
                                                   AND vcc3.clase = 3
                                                   AND vcc3.codven = cl.codven
            LEFT OUTER JOIN clase_vendedor_codigo                                                   vccc3 ON vccc3.id_cia = dr.id_cia
                                                           AND vccc3.clase = 3
                                                           AND vccc3.codigo = vcc3.codigo
            LEFT OUTER JOIN articulos                                                               a ON a.id_cia = df.id_cia
                                           AND a.tipinv = df.tipinv
                                           AND a.codart = df.codart
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 2)  ca2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 3)  ca3 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 5)  ca5 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 11) ca11 ON 0 = 0
            LEFT OUTER JOIN cliente                                                                 ap ON ap.id_cia = dr.id_cia
                                          AND ap.codcli = a.codprv
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(a.id_cia, 'B', a.codprv, 900)       cp900c ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 14)      c1c ON c1c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 15)      c2c ON c2c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 16)      c3c ON c3c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 28)      c28c ON c28c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 902)     c902c ON c902c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 900)     c900c ON c900c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 901)     c901c ON c901c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dr.id_cia, 'A', dr.codcli, 24)      c24c ON c24c.codigo <> 'ND'
            LEFT OUTER JOIN cliente                                                                 ccc ON ccc.id_cia = dr.id_cia
                                           AND ccc.codcli = a.codprv
            LEFT OUTER JOIN companias                                                               cpp ON cpp.cia = dr.id_cia
            LEFT OUTER JOIN documentos_situac_max                                                   dx ON dx.id_cia = dr.id_cia
                                                        AND dx.numint = dr.numint
                                                        AND dx.situac = 'A'
            LEFT OUTER JOIN usuarios                                                                ue ON ue.id_cia = dr.id_cia
                                           AND ue.coduser = dx.usuari
            LEFT OUTER JOIN pack_trazabilidad.sp_trazabilidad_tipdoc(dr.id_cia, dr.numint, 101)     top ON 0 = 0
            LEFT OUTER JOIN documentos_situac_max                                                   smp ON smp.id_cia = dr.id_cia
                                                         AND smp.numint = top.numint
                                                         AND smp.situac = 'A'
            LEFT OUTER JOIN usuarios                                                                usm ON usm.id_cia = dr.id_cia
                                            AND usm.coduser = smp.usuari
            LEFT OUTER JOIN motivos_clase                                                           mc44 ON mc44.id_cia = dr.id_cia
                                                  AND mc44.tipdoc = dr.tipdoc
                                                  AND mc44.id = dr.id
                                                  AND mc44.codmot = dr.codmot
                                                  AND mc44.codigo = 44
        WHERE
                dr.id_cia = pin_id_cia
            AND trunc(dr.femisi) BETWEEN pin_fdesde AND pin_fhasta
            AND dr.tipdoc IN ( 1, 3, 7, 8, 210 )
            AND dr.situac IN ( 'C', 'B', 'H', 'G', 'F' )
        ORDER BY
            dr.tipdoc,
            dr.series,
            dr.numdoc,
            df.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cuboventas006;

    FUNCTION sp_cuboventas007 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_ventas7
        PIPELINED
    AS
        v_table datatable_cubo_ventas7;
    BEGIN
        SELECT
            ddc.descri                                                                        AS documento,
            s.sucursal                                                                        AS sucursal,
            to_char(dc.femisi, 'DAY')                                                         AS diasemana,
            ms.desmay                                                                         AS mes,
            TO_NUMBER(to_char(dc.femisi, 'YYYY'))                                             AS periodo,
            TO_NUMBER(to_char(dc.femisi, 'YYYY')) * 100 + TO_NUMBER(to_char(dc.femisi, 'MM')) AS mesid,
            dc.series                                                                         AS serie,
            dc.numdoc                                                                         AS nro_documento,
            to_char(dc.femisi, 'DD/MM/YYYY')                                                  AS fecha_emision,
            dc.tipcam                                                                         AS tipo_cambio,
            dc.codcli                                                                         AS codigo_cliente,
            c902c.descodigo                                                                   AS clasificacion_cliente,
            c900c.descodigo                                                                   AS tipo_cliente,
            dc.razonc                                                                         AS cliente,
            dc.ruc                                                                            AS ruc,
            cp.despag                                                                         AS forma_pago,
            mt.desmot                                                                         AS motivo,
    --CAST(ve.codven AS INTEGER)                                                              AS codven,
            ve.desven                                                                         AS vendedor,
            dc.tipmon                                                                         AS moneda,
            dd.tipinv                                                                         AS tipo_inventario,
            ca3.descodigo                                                                     AS linea_negocio,
            ca2.descodigo                                                                     AS familia_producto,
            ca5.descodigo                                                                     AS tipo_producto,
            ca11.descodigo                                                                    AS clasificacion_producto,
            dd.codart                                                                         AS codigo,
            a.descri                                                                          AS descripcion,
            dd.cantid * ddc.signo                                                             AS cantidad,
            CASE
                WHEN dc.tipmon = 'PEN' THEN
                        ( dd.monafe + dd.monina ) / CAST(dd.cantid AS NUMERIC(7, 4))
                ELSE
                    ( ( dd.monafe + dd.monina ) * dc.tipcam ) / CAST(dd.cantid AS NUMERIC(7, 4))
            END
            * ddc.signo                                                                       AS prenetunisol,
            round(
                CASE
                    WHEN dc.tipmon = 'USD' THEN
                        (dd.monafe + dd.monina) / CAST(dd.cantid AS NUMERIC(7, 4))
                    ELSE
                        ((dd.monafe + dd.monina) / dc.tipcam) / CAST(dd.cantid AS NUMERIC(7, 4))
                END
                * ddc.signo,
                2)                                                                          AS prenetunidol,
            CASE
                WHEN dc.tipmon = 'PEN' THEN
                        ( dd.monafe + dd.monina )
                ELSE
                    ( ( dd.monafe + dd.monina ) * dc.tipcam )
            END
            * ddc.signo                                                                       AS ventatotsol,
            round(
                CASE
                    WHEN dc.tipmon = 'USD' THEN
                        (dd.monafe + dd.monina)
                    ELSE
                        ((dd.monafe + dd.monina) / dc.tipcam)
                END
                * ddc.signo, 2)                                                                   AS ventatotdol,
            dddc.vreal                                                                        AS comision,
            coalesce(c1c.descodigo, 'ND - DEPARTAMENTO')                                      AS departamento,
            coalesce(c2c.descodigo, 'ND - PROVINCIA')                                         AS provincia,
            coalesce(c3c.descodigo, 'ND - DISTRITO')                                          AS distrito,
            coalesce(c28c.descodigo, 'ND - DISTRITO')                                         AS grupo_economico,
            nvl(mc44.valor, 'N')                                                              AS transferencia_gratuita
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab                                                          dc
            LEFT OUTER JOIN documentos_det                                                          dd ON dc.id_cia = dd.id_cia -- Sale un Null
                                                 AND dc.numint = dd.numint
            LEFT OUTER JOIN documentos_det_clase                                                    dddc ON dddc.id_cia = dd.id_cia
                                                         AND dddc.numint = dd.numint
                                                         AND dddc.numite = dd.numite
                                                         AND dddc.clase = 1
            LEFT OUTER JOIN tdoccobranza                                                            ddc ON ( dc.id_cia = ddc.id_cia )
                                                AND ( ddc.tipdoc = dc.tipdoc )
            LEFT OUTER JOIN sucursal                                                                s ON s.id_cia = dc.id_cia
                                          AND ( s.codsuc = dc.codsuc )
            LEFT OUTER JOIN meses                                                                   ms ON ms.id_cia = dc.id_cia
                                        AND ( ms.nromes = EXTRACT(MONTH FROM dc.femisi) )
            LEFT OUTER JOIN c_pago                                                                  cp ON cp.id_cia = dc.id_cia
                                         AND ( cp.codpag = dc.codcpag )
            LEFT OUTER JOIN vendedor                                                                ve ON ve.id_cia = dc.id_cia
                                           AND ( ve.codven = dc.codven )
            LEFT OUTER JOIN articulos                                                               a ON a.id_cia = dd.id_cia
                                           AND ( a.tipinv = dd.tipinv )
                                           AND ( a.codart = dd.codart )
            LEFT OUTER JOIN cliente_articulos_clase                                                 cl1 ON cl1.id_cia = dd.id_cia
                                                           AND cl1.tipcli = 'B'
                                                           AND cl1.codcli = a.codprv
                                                           AND cl1.clase = 1
                                                           AND cl1.codigo = dd.codadd01
            LEFT OUTER JOIN cliente_articulos_clase                                                 cl2 ON cl2.id_cia = dd.id_cia
                                                           AND cl2.tipcli = 'B'
                                                           AND cl2.codcli = a.codprv
                                                           AND cl2.clase = 2
                                                           AND cl2.codigo = dd.codadd02
            LEFT OUTER JOIN motivos                                                                 mt ON ( mt.id_cia = dc.id_cia )
                                          AND ( mt.tipdoc = dc.tipdoc )
                                          AND ( mt.id = dc.id )
                                          AND ( mt.codmot = dc.codmot )
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 2)  ca2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 3)  ca3 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 5)  ca5 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 11) ca11 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 902)     c902c ON c902c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 900)     c900c ON c900c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 14)      c1c ON c1c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 15)      c2c ON c2c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 16)      c3c ON c3c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(dc.id_cia, 'A', dc.codcli, 28)      c28c ON c28c.codigo <> 'ND'
            LEFT OUTER JOIN motivos_clase                                                           mc44 ON mc44.id_cia = dc.id_cia
                                                  AND mc44.tipdoc = dc.tipdoc
                                                  AND mc44.id = dc.id
                                                  AND mc44.codmot = dc.codmot
                                                  AND mc44.codigo = 44
        WHERE
                dc.id_cia = pin_id_cia
            AND trunc(dc.femisi) BETWEEN pin_fdesde AND pin_fhasta
            AND dc.tipdoc IN ( 1, 3, 7, 8, 210 )
            AND dc.situac IN ( 'C', 'B', 'H', 'G', 'F' )
        ORDER BY
            dc.tipdoc,
            dc.series,
            dc.numdoc,
            dd.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cuboventas007;
    
    -- CUBO LEYENDA, UTILIZANDO PARA LOS RESUMENES DE LOS MARGEN DE UTILIDAD Y COSTO DE MERCADERIA
    FUNCTION sp_cuboventas008 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_ventas8
        PIPELINED
    AS
        v_table datatable_cubo_ventas8;
    BEGIN
        SELECT
            dc.id_cia                              AS id_cia,
            dc.tipdoc                              AS tipdoc,
            ddc.descri                             AS documento,
            mt.codmot                              AS codmot,
            mt.desmot                              AS motivo,
            dd.tipinv                              AS tipinv,
            dd.codart                              AS codart,
            dd.etiqueta                            AS etiqueta,
            decode(nvl(mt60.valor, 'N'),
                   'S',
                   0,
                   dd.cantid * ddc.signo)          AS cantidad,
            CASE
                WHEN nvl(mt60.valor, 'N') = 'S' THEN
                    0
                ELSE
                    nvl(round((k.costot01 / decode(k.cantid, 0, 1, k.cantid)) * ddc.signo,
                              2),
                        0)
            END                                    AS cosunisol,
            CASE
                WHEN nvl(mt60.valor, 'N') = 'S' THEN
                    0
                ELSE
                    nvl(round((k.costot02 / decode(k.cantid, 0, 1, k.cantid)) * ddc.signo,
                              2),
                        0)
            END                                    AS cosunidol,
            decode(nvl(mt60.valor, 'N'),
                   'S',
                   0,
                   nvl(k.costot01 * ddc.signo, 0)) AS costototsol,
            decode(nvl(mt60.valor, 'N'),
                   'S',
                   0,
                   nvl(k.costot02 * ddc.signo, 0)) AS costototdol,
            round(
                CASE
                    WHEN dc.tipmon = 'PEN' THEN
                        (dd.monafe + dd.monina) / CAST(dd.cantid AS NUMERIC(16, 4))
                    ELSE
                        ((dd.monafe + dd.monina) * dc.tipcam) / CAST(dd.cantid AS NUMERIC(16, 4))
                END
                * ddc.signo,
                4)                               AS preunisol,
            round(
                CASE
                    WHEN dc.tipmon = 'USD' THEN
                        (dd.monafe + dd.monina) / CAST(dd.cantid AS NUMERIC(16, 4))
                    ELSE
                        ((dd.monafe + dd.monina) / dc.tipcam) / CAST(dd.cantid AS NUMERIC(16, 4))
                END
                * ddc.signo,
                4)                               AS preunidol,
            round(
                CASE
                    WHEN dc.tipmon = 'PEN' THEN
                        (dd.monafe + dd.monina)
                    ELSE
                        ((dd.monafe + dd.monina) * dc.tipcam)
                END
                * ddc.signo, 4)                        AS ventatotsol,
            round(
                CASE
                    WHEN dc.tipmon = 'USD' THEN
                        (dd.monafe + dd.monina)
                    ELSE
                        ((dd.monafe + dd.monina) / dc.tipcam)
                END
                * ddc.signo, 4)                        AS ventatotdol,
            nvl(mc44.valor, 'N')                   AS transferencia_gratuita,
            nvl(mt3.valor, 'S')                    AS imprime_utilidad
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab    dc
            LEFT OUTER JOIN documentos_det    dd ON dc.id_cia = dd.id_cia -- Sale un Null
                                                 AND dc.numint = dd.numint
            LEFT OUTER JOIN tdoccobranza      ddc ON ( dc.id_cia = ddc.id_cia )
                                                AND ( ddc.tipdoc = dc.tipdoc )
            LEFT OUTER JOIN sucursal          s ON s.id_cia = dc.id_cia
                                          AND ( s.codsuc = dc.codsuc )
            LEFT OUTER JOIN meses             ms ON ms.id_cia = dc.id_cia
                                        AND ( ms.nromes = EXTRACT(MONTH FROM dc.femisi) )
            LEFT OUTER JOIN c_pago            cp ON cp.id_cia = dc.id_cia
                                         AND ( cp.codpag = dc.codcpag )
            LEFT OUTER JOIN vendedor          ve ON ve.id_cia = dc.id_cia
                                           AND ( ve.codven = dc.codven )
            LEFT OUTER JOIN articulos         a ON a.id_cia = dd.id_cia
                                           AND ( a.tipinv = dd.tipinv )
                                           AND ( a.codart = dd.codart )
            LEFT OUTER JOIN motivos           mt ON ( mt.id_cia = dc.id_cia )
                                          AND ( mt.tipdoc = dc.tipdoc )
                                          AND ( mt.id = dc.id )
                                          AND ( mt.codmot = dc.codmot )
            LEFT OUTER JOIN kardex001         k001 ON k001.id_cia = dd.id_cia
                                              AND k001.tipinv = dd.tipinv
                                              AND k001.codart = dd.codart
                                              AND k001.codalm = dd.codalm
                                              AND k001.etiqueta = dd.etiqueta
            LEFT OUTER JOIN kardex_costoventa k ON k.id_cia = dd.id_cia
                                                   AND k.numint = dd.numint
                                                   AND k.numite = dd.numite
            LEFT OUTER JOIN motivos_clase     mc44 ON mc44.id_cia = dc.id_cia
                                                  AND mc44.tipdoc = dc.tipdoc
                                                  AND mc44.id = dc.id
                                                  AND mc44.codmot = dc.codmot
                                                  AND mc44.codigo = 44
            LEFT OUTER JOIN motivos_clase     mt60 ON mt60.id_cia = dc.id_cia
                                                  AND mt60.tipdoc = dc.tipdoc
                                                  AND mt60.id = dc.id
                                                  AND mt60.codmot = dc.codmot
                                                  AND mt60.codigo = 60 -- COSTO Y CANTIDAD EN CERO, SOLO SI ESTA EN 'S'
            LEFT OUTER JOIN motivos_clase     mt3 ON mt3.id_cia = dc.id_cia
                                                 AND mt3.tipdoc = dc.tipdoc
                                                 AND mt3.codmot = dc.codmot
                                                 AND mt3.id = dc.id
                                                 AND mt3.codigo = 3 -- IMPRIME EN REPORTE?
        WHERE
                dc.id_cia = pin_id_cia
            AND trunc(dc.femisi) BETWEEN pin_fdesde AND pin_fhasta
            AND dc.tipdoc IN ( 1, 3, 7, 8, 210 )
            AND dc.situac IN ( 'C', 'B', 'H', 'G', 'F' );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cuboventas008;

END pack_cubo_ventas;

/
