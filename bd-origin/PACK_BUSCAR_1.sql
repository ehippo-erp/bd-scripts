--------------------------------------------------------
--  DDL for Package Body PACK_BUSCAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_BUSCAR" AS

    FUNCTION sp_buscar_comprobantes (
        pin_id_cia      IN NUMBER,
        pin_fdesde      IN DATE,
        pin_fhasta      IN DATE,
        pin_codcli      IN VARCHAR2,
        pin_situac      IN VARCHAR2,
        pin_tipdoc      IN NUMBER,
        pin_codmot      IN NUMBER,
        pin_lugemi      IN NUMBER,
        pin_destino     IN NUMBER,
        pin_codven      IN NUMBER,
        pin_codsuc      IN NUMBER,
        pin_estadosunat IN NUMBER,
        pin_offset      IN NUMBER,
        pin_limit       IN NUMBER
    ) RETURN datatable
        PIPELINED
    AS
        v_table datatable;
        x       NUMBER := 1000000;
    BEGIN
        SELECT
            d1.id_cia,--
            d1.numint,--
            d1.tipdoc,--
            d2.descri                                                       AS dtipdoc,
            d1.series,--
            d1.numdoc,--
            d1.femisi,--
            d1.lugemi,--
            d1.situac                                                       AS situac,
            d1.codmot,
            d1.codcli,
            i.abrevi                                                        AS tident,
            c.dident,
            d1.razonc,
            d1.codcpag,
            cv.despag                                                       AS desccpag,
            d1.codven,
            v.desven,
            d1.comisi,
            d1.destin,
            d1.desesp,
            d1.monafe * d2.signo                                            AS monafe,
            d1.monina * d2.signo                                            AS monina,
            d1.porigv,
            d1.monigv * d2.signo                                            AS monigv,
            d1.preven * d2.signo                                            AS preven,
            d1.tipmon,
            d1.tipcam,
            d1.observ,
            d1.ordcom,
            d1.numped,
            m.desmot,
            d1.presen,
            d1.numdue,
            d1.fentreg,
            d1.codsuc,
            d1.totcan,
            d1.ordcomni,
            d1.fecter,
            sp_get_estadocpe_por_anulacion(d1.id_cia, d1.numint, d1.tipdoc, d1.series, d1.numdoc,
                                           d1.situac, es.codest, es.descri) AS estadofe,
            CASE
                WHEN d1.tipdoc <> 3 THEN
                    ' '
                ELSE
                    CASE
                        WHEN s.cres = 0 THEN
                                'No incluido'
                        ELSE
                            'En resumen'
                    END
            END                                                             AS situacresfe,
            s.estado                                                        AS situacfe,
            s1.dessit                                                       AS situacdesc,
            ue.nombres                                                      AS emitidopor,
            d1.ucreac,
            d1.usuari,
            d1.fcreac,
            d1.factua
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab             d1
            LEFT OUTER JOIN documentos                 doc ON doc.id_cia = d1.id_cia
                                              AND doc.codigo = d1.tipdoc
                                              AND doc.series = d1.series
            LEFT OUTER JOIN cliente                    c ON d1.id_cia = c.id_cia
                                         AND d1.codcli = c.codcli
            LEFT OUTER JOIN identidad                  i ON i.id_cia = d1.id_cia
                                           AND i.tident = c.tident
            LEFT OUTER JOIN documentos_cab_envio_sunat s ON d1.id_cia = s.id_cia
                                                            AND d1.numint = s.numint
            LEFT OUTER JOIN estado_envio_sunat         es ON es.id_cia = s.id_cia
                                                     AND es.codest = nvl(s.estado, 0)
            LEFT OUTER JOIN c_pago                     cv ON cv.id_cia = d1.id_cia
                                         AND cv.codpag = d1.codcpag
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN usuarios                   ue ON ue.id_cia = d1.id_cia
                                           AND ue.coduser = d1.ucreac
            LEFT OUTER JOIN tdoccobranza               d2 ON d2.id_cia = d1.id_cia
                                               AND d2.tipdoc = d1.tipdoc
            LEFT OUTER JOIN situacion                  s1 ON s1.id_cia = d1.id_cia
                                            AND s1.tipdoc = d1.tipdoc
                                            AND s1.situac = d1.situac
            LEFT OUTER JOIN vendedor                   v ON d1.id_cia = v.id_cia
                                          AND d1.codven = v.codven
            LEFT OUTER JOIN motivos                    m ON m.id_cia = d1.id_cia
                                         AND m.tipdoc = d1.tipdoc
                                         AND m.id = d1.id
                                         AND m.codmot = d1.codmot
        WHERE
                d1.id_cia = pin_id_cia
            AND d1.tipdoc IN ( 1, 3, 7, 8, 210 )
            AND d1.femisi BETWEEN pin_fdesde AND pin_fhasta
            AND ( ( pin_tipdoc IS NULL
                    OR pin_tipdoc = - 1 )
                  OR d1.tipdoc = pin_tipdoc )
            AND ( ( pin_codmot IS NULL
                    OR pin_codmot = - 1 )
                  OR d1.codmot = pin_codmot )
            AND ( ( pin_lugemi IS NULL
                    OR pin_lugemi = - 1 )
                  OR d1.lugemi = pin_lugemi )
            AND ( ( pin_destino IS NULL
                    OR pin_destino = - 1 )
                  OR d1.destin = pin_destino )
            AND ( ( pin_codven IS NULL
                    OR pin_codven = - 1 )
                  OR d1.codven = pin_codven )
            AND ( ( pin_codsuc IS NULL
                    OR pin_codsuc = - 1 )
                  OR d1.codsuc = pin_codsuc )
            AND ( ( pin_estadosunat IS NULL
                    OR pin_estadosunat = - 1 )
                  OR s.estado = pin_estadosunat )
            AND ( ( pin_codcli IS NULL
                    OR pin_codcli = '-1' )
                  OR d1.codcli = pin_codcli )
            AND ( ( pin_situac IS NULL )
                  OR ( d1.situac IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_situac) )
            ) ) )
        ORDER BY
            d1.numdoc DESC
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

    END sp_buscar_comprobantes;

    FUNCTION sp_buscar_guias_recepcion (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_codmot IN NUMBER,
        pin_codven IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codpag IN NUMBER,
        pin_offset IN NUMBER,
        pin_limit  IN NUMBER
    ) RETURN datatable1
        PIPELINED
    AS
        rec datarecord1;
        x   NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO x
        FROM
            documentos_cab;

        FOR i IN (
            SELECT
                c.id_cia,
                c.numint,
                c.tipdoc,
                c.series,
                c.numdoc,
                c.tident,
                c.ruc,
                c.codcli,
                c.razonc   AS razonsocial,
                c.direc1   AS direccion,
                c.fentreg  AS fentreg,
                c.fecter,
                c.horter,
                c.femisi,
                c.lugemi,
                c.situac,
                s.dessit   AS situacnombre,
                c.id,
                c.codmot,
                c.codven,
                c.codsuc,
                c.tipmon   AS moneda,
                c.tipcam,
                cp.despag  AS condicionpago,
                v.desven   AS vendedor,
                c.codcpag,
                c.usuari   AS coduser,
                us.nombres AS usuario,
                CASE
                    WHEN c.incigv = 'S' THEN
                        'true'
                    ELSE
                        'false'
                END        AS incigv,
                c.porigv,
                c.monafe,
                c.monina,
                c.monigv,
                c.preven,
                c.numped   AS referencia,
                c.totbru   AS importebruto,
                c.descue   AS descuento,
                c.preven   AS importe,
                c.ucreac,
                c.usuari,
                c.fcreac,
                c.factua,
                mo.desmot
            FROM
                documentos_cab c
                LEFT OUTER JOIN motivos        mo ON mo.id_cia = c.id_cia
                                              AND mo.tipdoc = c.tipdoc
                                              AND mo.id = c.id
                                              AND mo.codmot = c.codmot
                LEFT OUTER JOIN c_pago         cp ON cp.id_cia = c.id_cia
                                             AND cp.codpag = c.codcpag
                LEFT OUTER JOIN vendedor       v ON v.id_cia = c.id_cia
                                              AND v.codven = c.codven
                LEFT OUTER JOIN cliente        cl ON cl.id_cia = c.id_cia
                                              AND cl.codcli = c.codcli
                LEFT OUTER JOIN usuarios       us ON us.id_cia = c.id_cia
                                               AND us.coduser = c.usuari
                LEFT OUTER JOIN situacion      s ON s.id_cia = c.id_cia
                                               AND s.tipdoc = c.tipdoc
                                               AND s.situac = c.situac
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = 108
                AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                AND ( ( c.codmot = pin_codmot
                        AND pin_codmot IS NOT NULL )
                      OR ( pin_codmot IS NULL
                           OR pin_codmot = - 1 ) )
                AND ( ( c.codsuc = pin_codsuc
                        AND pin_codsuc IS NOT NULL )
                      OR ( pin_codsuc IS NULL
                           OR pin_codsuc = - 1 ) )
                AND ( ( c.codcli = pin_codcli
                        AND pin_codcli IS NOT NULL )
                      OR pin_codcli IS NULL )
                AND ( ( pin_situac IS NULL )
                      OR ( c.situac IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_situac) )
                ) ) )
                AND ( ( c.codven = pin_codven
                        AND pin_codven IS NOT NULL )
                      OR ( pin_codven IS NULL
                           OR pin_codven = - 1 ) )
                AND ( ( c.codcpag = pin_codpag
                        AND pin_codpag IS NOT NULL )
                      OR ( pin_codpag IS NULL
                           OR pin_codpag = - 1 ) )
            ORDER BY
                c.numint DESC
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
            ROWS ONLY
        ) LOOP
            rec.id_cia := i.id_cia;
            rec.numint := i.numint;
            rec.tipdoc := i.tipdoc;
            rec.series := i.series;
            rec.numdoc := i.numdoc;
            rec.tident := i.tident;
            rec.ruc := i.ruc;
            rec.codcli := i.codcli;
            rec.razonsocial := i.razonsocial;
            rec.direccion := i.direccion;
            rec.fentreg := i.fentreg;
            rec.fecter := i.fecter;
            rec.horter := i.horter;
            rec.femisi := i.femisi;
            rec.lugemi := i.lugemi;
            rec.situac := i.situac;
            rec.situacdesc := i.situacnombre;
            rec.id := i.id;
            rec.codmot := i.codmot;
            rec.codven := i.codven;
            rec.codsuc := i.codsuc;
            rec.moneda := i.moneda;
            rec.tipcam := i.tipcam;
            rec.condicionpago := i.condicionpago;
            rec.desven := i.vendedor;
            rec.codcpag := i.codcpag;
            rec.coduser := i.coduser;
            rec.usuario := i.usuario;
            rec.incigv := i.incigv;
            rec.porigv := i.porigv;
            rec.monafe := i.monafe;
            rec.monina := i.monina;
            rec.monigv := i.monigv;
            rec.preven := i.importe;
            rec.referencia := i.referencia;
            rec.importebruto := i.importebruto;
            rec.descuento := i.descuento;
            rec.preven := i.preven;
            rec.ucreac := i.ucreac;
            rec.usuari := i.usuari;
            rec.fcreac := i.fcreac;
            rec.factua := i.factua;
            PIPE ROW ( rec );
        END LOOP;

    END sp_buscar_guias_recepcion;

    FUNCTION sp_buscar_cotizaciones (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codcli IN VARCHAR2,
        pin_codven IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_situac IN VARCHAR2,
        pin_lugemi IN NUMBER,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable2
        PIPELINED
    AS
        rec datarecord2;
        x   NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO x
        FROM
            documentos_cab;

        FOR i IN (
            SELECT
                c.id_cia,
                c.numint,
                c.tipdoc,
                c.series,
                c.numdoc,
                c.tident,
                c.ruc,
                c.codcli,
                c.razonc     AS razonsocial,
                c.direc1     AS direccion,
                c.fentreg    AS fentreg,
                c.femisi,
                c.lugemi,
                c.situac,
                s.dessit     AS situacnombre,
                c.id,
                c.codmot,
                mo.desmot,
                c.codven,
                c.codsuc,
                c.tipmon     AS moneda,
                c.tipcam,
                coc.numint   AS coc_numint,
                coc.fecha    AS coc_fecha,
                coc.numero   AS coc_numero,
                coc.contacto AS coc_contacto,
                cp.despag    AS condicionpago,
                v.desven     AS vendedor,
                c.codcpag,
                c.usuari     AS coduser,
                us.nombres   AS usuario,
                CASE
                    WHEN c.incigv = 'S' THEN
                        'true'
                    ELSE
                        'false'
                END          AS incigv,
                c.porigv,
                c.numped     AS referencia,
                c.observ     AS observacion,
                c.monafe,
                c.monina,
                c.monigv,
                c.preven,
                c.monisc     AS monisc,
                c.totbru     AS importebruto,
                c.preven     AS importe,
                c.ucreac,
                c.usuari,
                c.fcreac,
                c.factua,
                c.countadj
            FROM
                documentos_cab        c
                LEFT OUTER JOIN documentos_cab_ordcom coc ON coc.id_cia = c.id_cia
                                                             AND coc.numint = c.numint
                LEFT OUTER JOIN motivos               mo ON mo.id_cia = c.id_cia
                                              AND mo.tipdoc = c.tipdoc
                                              AND mo.id = c.id
                                              AND mo.codmot = c.codmot
                LEFT OUTER JOIN c_pago                cp ON cp.id_cia = c.id_cia
                                             AND cp.codpag = c.codcpag
                LEFT OUTER JOIN vendedor              v ON v.id_cia = c.id_cia
                                              AND v.codven = c.codven
                LEFT OUTER JOIN cliente               cl ON cl.id_cia = c.id_cia
                                              AND cl.codcli = c.codcli
                LEFT OUTER JOIN usuarios              us ON us.id_cia = c.id_cia
                                               AND us.coduser = c.usuari
                LEFT OUTER JOIN situacion             s ON s.id_cia = c.id_cia
                                               AND s.tipdoc = c.tipdoc
                                               AND s.situac = c.situac
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = 100
                AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                AND ( c.codsuc = pin_codsuc
                      OR ( pin_codsuc IS NULL
                           OR pin_codsuc = - 1 ) )
                AND ( c.codven = pin_codven
                      OR ( pin_codven IS NULL
                           OR pin_codven <= 0 ) )
                AND ( c.codcli = pin_codcli
                      OR pin_codcli IS NULL )
                AND ( c.lugemi = pin_lugemi
                      OR ( pin_lugemi IS NULL
                           OR pin_lugemi = - 1 ) )
                AND ( c.codcli = pin_codcli
                      OR pin_codcli IS NULL )
                AND ( pin_situac IS NULL
                      OR ( c.situac IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_situac) )
                ) ) )
            ORDER BY
                c.numint DESC
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
            ROWS ONLY
        ) LOOP
            rec.id_cia := i.id_cia;
            rec.numint := i.numint;
            rec.tipdoc := i.tipdoc;
            rec.series := i.series;
            rec.numdoc := i.numdoc;
            rec.tident := i.tident;
            rec.ruc := i.ruc;
            rec.codcli := i.codcli;
            rec.razonsocial := i.razonsocial;
            rec.direccion := i.direccion;
            rec.fentreg := i.fentreg;
            rec.femisi := i.femisi;
            rec.lugemi := i.lugemi;
            rec.situac := i.situac;
            rec.situacnombre := i.situacnombre;
            rec.id := i.id;
            rec.codmot := i.codmot;
            rec.desmot := i.desmot;
            rec.codven := i.codven;
            rec.codsuc := i.codsuc;
            rec.moneda := i.moneda;
            rec.tipcam := i.tipcam;
            rec.coc_numint := i.coc_numint;
            rec.coc_fecha := i.coc_fecha;
            rec.cocnumero := i.coc_numero;
            rec.coccontacto := i.coc_contacto;
            rec.condicionpago := i.condicionpago;
            rec.desven := i.vendedor;
            rec.codcpag := i.codcpag;
            rec.usuari := i.usuario;
            rec.incigv := i.incigv;
            rec.referencia := i.referencia;
            rec.observacion := i.observacion;
            rec.monafe := i.monafe;
            rec.monina := i.monina;
            rec.monigv := i.monigv;
            rec.preven := i.importe;
            rec.monisc := i.monisc;
            rec.importebruto := i.importebruto;
            rec.preven := i.importe;
            rec.countadj := i.countadj;
            rec.ucreac := i.ucreac;
            rec.usuari := i.usuari;
            rec.fcreac := i.fcreac;
            rec.factua := i.factua;
            PIPE ROW ( rec );
        END LOOP;

    END sp_buscar_cotizaciones;

    FUNCTION sp_buscar_pedidos (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codven IN NUMBER,
        pin_codmot IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable3
        PIPELINED
    AS
        rec datarecord3;
        x   NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO x
        FROM
            documentos_cab;

        FOR i IN (
            SELECT
                c.id_cia,
                c.numint,
                c.tipdoc,
                c.series,
                c.numdoc,
                c.tident,
                c.ruc,
                c.codcli,
                c.razonc    AS razonsocial,
                c.direc1    AS direccion,
                cl.telefono AS telefono,
                c.fentreg   AS fentreg,
                c.femisi,
                c.lugemi,
                c.situac,
                s.dessit    AS situacnombre,
                c.id,
                c.codmot,
                mo.desmot,
                c.codven,
                c.codsuc,
                c.tipmon    AS moneda,
                c.tipcam,
                cp.despag   AS condicionpago,
                v.desven    AS vendedor,
                c.codcpag,
                c.usuari    AS coduser,
                us.nombres  AS usuario,
                CASE
                    WHEN c.incigv = 'S' THEN
                        'true'
                    ELSE
                        'false'
                END         AS incigv,
                c.porigv,
                c.numped    AS referencia,
                c.monafe,
                c.monina,
                c.monigv,
                c.monisc    AS monisc,
                c.preven,
                c.totbru    AS importebruto,
                c.preven    AS importe,
                c.countadj,
                da.situac   AS situacioncredito,
                c.ucreac,
                c.usuari,
                c.fcreac,
                c.factua,
                CASE
                    WHEN da.situac = 'B' THEN
                        'Aprobado'
                    ELSE
                        CASE
                            WHEN da.situac = 'J' THEN
                                    'Desaprobado'
                            ELSE
                                'No Asignado'
                        END
                END         situacioncreditonombre,
                CASE
                    WHEN da.situac = 'B' THEN
                        'Aprobado'
                    ELSE
                        CASE
                            WHEN da.situac = 'J' THEN
                                    'Desaprobado'
                            ELSE
                                'En Espera'
                        END
                END         AS situacda
            FROM
                documentos_cab        c
                LEFT OUTER JOIN documentos_cab_ordcom coc ON coc.id_cia = c.id_cia
                                                             AND coc.numint = c.numint
                LEFT OUTER JOIN motivos               mo ON mo.id_cia = c.id_cia
                                              AND mo.tipdoc = c.tipdoc
                                              AND mo.id = c.id
                                              AND mo.codmot = c.codmot
                LEFT OUTER JOIN c_pago                cp ON cp.id_cia = c.id_cia
                                             AND cp.codpag = c.codcpag
                LEFT OUTER JOIN vendedor              v ON v.id_cia = c.id_cia
                                              AND v.codven = c.codven
                LEFT OUTER JOIN cliente               cl ON cl.id_cia = c.id_cia
                                              AND cl.codcli = c.codcli
                LEFT OUTER JOIN usuarios              us ON us.id_cia = c.id_cia
                                               AND us.coduser = c.usuari
                LEFT OUTER JOIN situacion             s ON s.id_cia = c.id_cia
                                               AND s.tipdoc = c.tipdoc
                                               AND s.situac = c.situac
                LEFT OUTER JOIN documentos_aprobacion da ON da.id_cia = c.id_cia
                                                            AND da.numint = c.numint
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = 101
                AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                AND ( ( c.codcli = pin_codcli
                        AND pin_codcli IS NOT NULL )
                      OR pin_codcli IS NULL )
                AND ( ( c.codmot = pin_codmot
                        AND pin_codmot IS NOT NULL )
                      OR ( pin_codmot IS NULL
                           OR pin_codmot = - 1 ) )
                AND ( ( c.codsuc = pin_codsuc
                        AND pin_codsuc IS NOT NULL )
                      OR ( pin_codsuc IS NULL
                           OR pin_codsuc = - 1 ) )
                AND ( ( c.codven = pin_codven
                        AND pin_codven IS NOT NULL )
                      OR ( pin_codven IS NULL
                           OR pin_codven = - 1 ) )
                AND ( ( c.codcli = pin_codcli
                        AND pin_codcli IS NOT NULL )
                      OR pin_codcli IS NULL )
                AND ( ( pin_situac IS NULL )
                      OR ( c.situac IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_situac) )
                ) ) )
            ORDER BY
                c.numint DESC
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
            ROWS ONLY
        ) LOOP
            rec.id_cia := i.id_cia;
            rec.numint := i.numint;
            rec.tipdoc := i.tipdoc;
            rec.series := i.series;
            rec.numdoc := i.numdoc;
            rec.tident := i.tident;
            rec.ruc := i.ruc;
            rec.telefono := i.telefono;
            rec.codcli := i.codcli;
            rec.razonsocial := i.razonsocial;
            rec.direccion := i.direccion;
            rec.fentreg := i.fentreg;
            rec.femisi := i.femisi;
            rec.lugemi := i.lugemi;
            rec.situac := i.situac;
            rec.situacnombre := i.situacnombre;
            rec.id := i.id;
            rec.codmot := i.codmot;
            rec.desmot := i.desmot;
            rec.codven := i.codven;
            rec.codsuc := i.codsuc;
            rec.moneda := i.moneda;
            rec.tipcam := i.tipcam;
            rec.condicionpago := i.condicionpago;
            rec.desven := i.vendedor;
            rec.codcpag := i.codcpag;
            rec.usuari := i.usuario;
            rec.incigv := i.incigv;
            rec.referencia := i.referencia;
            rec.monafe := i.monafe;
            rec.monina := i.monina;
            rec.monigv := i.monigv;
            rec.monisc := i.monisc;
            rec.preven := i.importe;
            rec.importebruto := i.importebruto;
            rec.preven := i.importe;
            rec.countadj := i.countadj;
            rec.situacda := i.situacda;
            rec.ucreac := i.ucreac;
            rec.usuari := i.usuari;
            rec.fcreac := i.fcreac;
            rec.factua := i.factua;
            PIPE ROW ( rec );
        END LOOP;

    END sp_buscar_pedidos;

    FUNCTION sp_buscar_orden_devolucion (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codven IN NUMBER,
        pin_codmot IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable3
        PIPELINED
    AS
        rec datarecord3;
        x   NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO x
        FROM
            documentos_cab;

        FOR i IN (
            SELECT
                c.id_cia,
                c.numint,
                c.tipdoc,
                c.series,
                c.numdoc,
                c.tident,
                c.ruc,
                c.codcli,
                c.razonc    AS razonsocial,
                c.direc1    AS direccion,
                cl.telefono AS telefono,
                c.fentreg   AS fentreg,
                c.femisi,
                c.lugemi,
                c.situac,
                s.dessit    AS situacnombre,
                c.id,
                c.codmot,
                c.codven,
                c.codsuc,
                c.tipmon    AS moneda,
                c.tipcam,
                cp.despag   AS condicionpago,
                v.desven    AS vendedor,
                c.codcpag,
                c.usuari    AS coduser,
                us.nombres  AS usuario,
                CASE
                    WHEN c.incigv = 'S' THEN
                        'true'
                    ELSE
                        'false'
                END         AS incigv,
                c.porigv,
                c.numped    AS referencia,
                c.monafe,
                c.monina,
                c.monigv,
                c.monisc    AS monisc,
                c.preven,
                c.totbru    AS importebruto,
                c.preven    AS importe,
                c.countadj,
                da.situac   AS situacioncredito,
                c.ucreac,
                c.usuari,
                c.fcreac,
                c.factua,
                CASE
                    WHEN da.situac = 'B' THEN
                        'Aprobado'
                    ELSE
                        CASE
                            WHEN da.situac = 'J' THEN
                                    'Desaprobado'
                            ELSE
                                'No Asignado'
                        END
                END         situacioncreditonombre,
                CASE
                    WHEN da.situac = 'B' THEN
                        'Aprobado'
                    ELSE
                        CASE
                            WHEN da.situac = 'J' THEN
                                    'Desaprobado'
                            ELSE
                                'En Espera'
                        END
                END         AS situacda
            FROM
                documentos_cab        c
                LEFT OUTER JOIN documentos_cab_ordcom coc ON coc.id_cia = c.id_cia
                                                             AND coc.numint = c.numint
                LEFT OUTER JOIN motivos               mo ON mo.id_cia = c.id_cia
                                              AND mo.tipdoc = c.tipdoc
                                              AND mo.id = c.id
                                              AND mo.codmot = c.codmot
                LEFT OUTER JOIN c_pago                cp ON cp.id_cia = c.id_cia
                                             AND cp.codpag = c.codcpag
                LEFT OUTER JOIN vendedor              v ON v.id_cia = c.id_cia
                                              AND v.codven = c.codven
                LEFT OUTER JOIN cliente               cl ON cl.id_cia = c.id_cia
                                              AND cl.codcli = c.codcli
                LEFT OUTER JOIN usuarios              us ON us.id_cia = c.id_cia
                                               AND us.coduser = c.usuari
                LEFT OUTER JOIN situacion             s ON s.id_cia = c.id_cia
                                               AND s.tipdoc = c.tipdoc
                                               AND s.situac = c.situac
                LEFT OUTER JOIN documentos_aprobacion da ON da.id_cia = c.id_cia
                                                            AND da.numint = c.numint
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = 201
                AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                AND ( ( c.codcli = pin_codcli
                        AND pin_codcli IS NOT NULL )
                      OR pin_codcli IS NULL )
                AND ( ( c.codmot = pin_codmot
                        AND pin_codmot IS NOT NULL )
                      OR ( pin_codmot IS NULL
                           OR pin_codmot = - 1 ) )
                AND ( ( c.codsuc = pin_codsuc
                        AND pin_codsuc IS NOT NULL )
                      OR ( pin_codsuc IS NULL
                           OR pin_codsuc = - 1 ) )
                AND ( ( c.codven = pin_codven
                        AND pin_codven IS NOT NULL )
                      OR ( pin_codven IS NULL
                           OR pin_codven = - 1 ) )
                AND ( ( c.codcli = pin_codcli
                        AND pin_codcli IS NOT NULL )
                      OR pin_codcli IS NULL )
                AND ( ( pin_situac IS NULL )
                      OR ( c.situac IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_situac) )
                ) ) )
            ORDER BY
                c.numint DESC
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
            ROWS ONLY
        ) LOOP
            rec.id_cia := i.id_cia;
            rec.numint := i.numint;
            rec.tipdoc := i.tipdoc;
            rec.series := i.series;
            rec.numdoc := i.numdoc;
            rec.tident := i.tident;
            rec.ruc := i.ruc;
            rec.telefono := i.telefono;
            rec.codcli := i.codcli;
            rec.razonsocial := i.razonsocial;
            rec.direccion := i.direccion;
            rec.fentreg := i.fentreg;
            rec.femisi := i.femisi;
            rec.lugemi := i.lugemi;
            rec.situac := i.situac;
            rec.situacnombre := i.situacnombre;
            rec.id := i.id;
            rec.codmot := i.codmot;
            rec.codven := i.codven;
            rec.codsuc := i.codsuc;
            rec.moneda := i.moneda;
            rec.tipcam := i.tipcam;
            rec.condicionpago := i.condicionpago;
            rec.desven := i.vendedor;
            rec.codcpag := i.codcpag;
            rec.usuari := i.usuario;
            rec.incigv := i.incigv;
            rec.referencia := i.referencia;
            rec.monafe := i.monafe;
            rec.monina := i.monina;
            rec.monigv := i.monigv;
            rec.monisc := i.monisc;
            rec.preven := i.importe;
            rec.importebruto := i.importebruto;
            rec.preven := i.importe;
            rec.countadj := i.countadj;
            rec.situacda := i.situacda;
            rec.ucreac := i.ucreac;
            rec.usuari := i.usuari;
            rec.fcreac := i.fcreac;
            rec.factua := i.factua;
            PIPE ROW ( rec );
        END LOOP;

    END sp_buscar_orden_devolucion;

    FUNCTION sp_buscar_guiasremision (
        pin_id_cia      IN NUMBER,
        pin_fdesde      IN DATE,
        pin_fhasta      IN DATE,
        pin_codcli      IN VARCHAR2,
        pin_situac      IN VARCHAR2,
        pin_codmot      IN NUMBER,
        pin_codven      IN NUMBER,
        pin_codsuc      IN NUMBER,
        pin_estadosunat IN NUMBER,
        pin_lugemi      IN NUMBER,
        pin_limit       IN NUMBER,
        pin_offset      IN NUMBER
    ) RETURN datatable_guia_remision
        PIPELINED
    AS
--        rec datarecord4;
        v_table datatable_guia_remision;
        x       NUMBER := 10000000;
    BEGIN
        SELECT
            c.id_cia,
            c.tipdoc,
            c.numint,
            c.series,
            c.numdoc,
            c.tident,
            c.femisi,
            c.comisi,
            c.codven,
            c.lugemi,
            c.situac            AS situac,
            s.estado            AS situacfe,
            c.destin,
            es.descri           AS estadofe,
            NULL                AS situacresfe,
            c.tipcam,
            c.tipmon,
            c.codcpag,
            c.numdue,
            c.porigv,
            c.fecter,
            c.fentreg           AS fentrega,
            c.razonc            AS razonsocial,
            CASE
                WHEN doc.docelec = 'S' THEN
                    'true'
                ELSE
                    'false'
            END                 docelec,
            i.abrevi            AS tident1,
            c.totcan,
            c.ordcom,
            s.permis,
            cc.descri           AS dtipdoc,
            c.countadj,
            c.codsuc,
            c.codcli,
            c.ordcomni,
            v.desven,
            c.monafe * cc.signo AS monafe,
            c.monina * cc.signo AS monina,
            c.monigv * cc.signo AS monigv,
            c.preven * cc.signo AS preven,
            c.codmot,
            c.numped            AS referencia,
            c.observ,
            c.presen,
            c.desesp,
            NULL,
            mo.desmot,
            ue.nombres          AS emitidopor,
            ua.nombres          AS anuladopor,
            (
                CASE
                    WHEN s.dessit IS NULL THEN
                        CAST('-' AS VARCHAR(50))
                    ELSE
                        s.dessit
                END
            )                   AS situacdesc,
            cp.despag           AS condicionpago,
            (
                CASE
                    WHEN ci.codigo = 'ND' THEN
                        CAST(' ' AS VARCHAR(50))
                    ELSE
                        ci.descri
                END
            )                   AS incoterm,
            c.ucreac,
            c.usuari,
            c.fcreac,
            c.factua
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab              c
            LEFT OUTER JOIN documentos                  doc ON doc.id_cia = c.id_cia
                                              AND doc.codigo = c.tipdoc
                                              AND doc.series = c.series
            LEFT OUTER JOIN documentos_cab_ordcom       coc ON coc.id_cia = c.id_cia
                                                         AND coc.numint = c.numint
            LEFT OUTER JOIN documentos_cab_envio_sunat  s ON s.id_cia = c.id_cia
                                                            AND s.numint = c.numint
            LEFT OUTER JOIN documentos_cab_clase        cl ON cl.id_cia = c.id_cia
                                                       AND ( cl.numint = c.numint )
                                                       AND ( cl.clase = 11 )
            LEFT OUTER JOIN clase_documentos_cab_codigo ci ON ci.id_cia = c.id_cia
                                                              AND ci.tipdoc = c.tipdoc
                                                              AND ci.clase = cl.clase
                                                              AND ci.codigo = cl.codigo
            LEFT OUTER JOIN motivos                     mo ON mo.id_cia = c.id_cia
                                          AND mo.tipdoc = c.tipdoc
                                          AND mo.id = c.id
                                          AND mo.codmot = c.codmot
            LEFT OUTER JOIN c_pago                      cp ON cp.id_cia = c.id_cia
                                         AND cp.codpag = c.codcpag
            LEFT OUTER JOIN vendedor                    v ON v.id_cia = c.id_cia
                                          AND v.codven = c.codven
            LEFT OUTER JOIN cliente                     cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codcli
            LEFT OUTER JOIN usuarios                    ue ON ue.id_cia = c.id_cia
                                           AND ue.coduser = c.usuari
            LEFT OUTER JOIN usuarios                    ua ON ua.id_cia = c.id_cia
                                           AND ua.coduser = c.usuari
            LEFT OUTER JOIN situacion                   s ON s.id_cia = c.id_cia
                                           AND s.tipdoc = c.tipdoc
                                           AND s.situac = c.situac
            LEFT OUTER JOIN identidad                   i ON i.id_cia = c.id_cia
                                           AND i.tident = cl.tident
            LEFT OUTER JOIN tdoccobranza                cc ON cc.id_cia = c.id_cia
                                               AND ( cc.tipdoc = c.tipdoc )
            LEFT OUTER JOIN estado_envio_sunat          es ON es.id_cia = s.id_cia
                                                     AND es.codest = nvl(s.estado, 0)
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 102
            AND trunc(c.femisi) BETWEEN pin_fdesde AND pin_fhasta
            AND ( ( pin_estadosunat IS NULL
                    OR pin_estadosunat = - 1 )
                  OR s.estado = pin_estadosunat )
            AND ( ( pin_codmot IS NULL
                    OR pin_codmot = - 1 )
                  OR c.codmot = pin_codmot )
            AND ( ( pin_codsuc IS NULL
                    OR pin_codsuc = - 1 )
                  OR c.codsuc = pin_codsuc )
            AND ( ( pin_codven IS NULL
                    OR pin_codven = - 1 )
                  OR c.codven = pin_codven )
            AND ( ( pin_lugemi IS NULL
                    OR pin_lugemi = - 1 )
                  OR c.lugemi = pin_lugemi )
            AND ( pin_codcli IS NULL
                  OR c.codcli = pin_codcli )
            AND ( pin_situac IS NULL
                  OR ( c.situac IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_situac) )
            ) ) )
        ORDER BY
            c.numint DESC
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
    END sp_buscar_guiasremision;

    FUNCTION sp_buscar_req_compra (
        pin_id_cia IN NUMBER,
        pin_lugemi IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_codven IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable5
        PIPELINED
    AS
        rec datarecord5;
        x   NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO x
        FROM
            documentos_cab;

        FOR i IN (
            SELECT
                c.id_cia,
                c.numint,
                c.tipdoc,
                c.series,
                c.numdoc,
                c.tident,
                c.ruc,
                c.codcli,
                c.razonc     AS razonsocial,
                c.direc1     AS direccion,
                c.fentreg    AS fentreg,
                c.femisi,
                c.lugemi,
                c.situac,
                s.dessit     AS situacnombre,
                c.id,
                c.codmot,
                c.codven,
                c.codsuc,
                c.tipmon     AS moneda,
                c.tipcam,
                c.codarea    AS area,
                c.destin     AS destin,
                coc.numint   AS coc_numint,
                coc.fecha    AS coc_fecha,
                coc.numero   AS coc_numero,
                coc.contacto AS coc_contacto,
                dcc.codcont  AS codigocontacto,
                dcc.atenci   AS contacto,
                dcc.email    AS contactoemail,
                cp.despag    AS condicionpago,
                v.desven     AS vendedor,
                c.codcpag,
                us.nombres   AS usuario,
                c.ucreac,
                c.usuari,
                c.fcreac,
                c.factua,
                CASE
                    WHEN c.incigv = 'S' THEN
                        'true'
                    ELSE
                        'false'
                END          AS incigv,
                c.porigv,
                c.numped     AS referencia,
                c.observ     AS observacion,
                c.presen     AS comentario,
                c.monafe,
                c.monina,
                c.monigv,
                c.preven,
                c.countadj,
                c.totbru     AS importebruto,
                c.preven     AS importe,
                c.codarea    AS areaf
            FROM
                documentos_cab             c
                LEFT OUTER JOIN documentos_cab_ordcom      coc ON coc.id_cia = c.id_cia
                                                             AND coc.numint = c.numint
                LEFT OUTER JOIN documentos_cab_envio_sunat s ON s.id_cia = c.id_cia
                                                                AND s.numint = c.numint
                LEFT OUTER JOIN documentos_cab_contacto    dcc ON dcc.id_cia = c.id_cia
                                                               AND dcc.numint = c.numint
                LEFT OUTER JOIN situacion                  ss ON ss.id_cia = c.id_cia
                                                AND ( ss.tipdoc = c.tipdoc )
                                                AND ( ss.situac = c.situac )
                LEFT OUTER JOIN motivos                    mo ON mo.id_cia = c.id_cia
                                              AND mo.tipdoc = c.tipdoc
                                              AND mo.id = c.id
                                              AND mo.codmot = c.codmot
                LEFT OUTER JOIN c_pago                     cp ON cp.id_cia = c.id_cia
                                             AND cp.codpag = c.codcpag
                LEFT OUTER JOIN vendedor                   v ON v.id_cia = c.id_cia
                                              AND v.codven = c.codven
                LEFT OUTER JOIN cliente                    cl ON cl.id_cia = c.id_cia
                                              AND cl.codcli = c.codcli
                LEFT OUTER JOIN usuarios                   us ON us.id_cia = c.id_cia
                                               AND us.coduser = c.usuari
                LEFT OUTER JOIN situacion                  s ON s.id_cia = c.id_cia
                                               AND s.tipdoc = c.tipdoc
                                               AND s.situac = c.situac
                LEFT OUTER JOIN tdoccobranza               cc ON cc.id_cia = c.id_cia
                                                   AND ( cc.tipdoc = c.tipdoc )
                LEFT OUTER JOIN estado_envio_sunat         es ON es.id_cia = s.id_cia
                                                         AND es.codest = nvl(s.estado, 0)
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = 125
                AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                AND ( c.codcli = pin_codcli
                      OR pin_codcli IS NULL )
                AND ( c.codsuc = pin_codsuc
                      OR pin_codsuc IS NULL
                      OR pin_codsuc = - 1 )
                AND ( c.lugemi = pin_lugemi
                      OR pin_lugemi IS NULL
                      OR pin_lugemi = - 1 )
                AND ( c.codven = pin_codven
                      OR pin_codven IS NULL
                      OR pin_codven = - 1 )
                AND ( ( pin_situac IS NULL )
                      OR ( c.situac IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_situac) )
                ) ) )
            ORDER BY
                c.numint DESC
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
            ROWS ONLY
        ) LOOP
            rec.id_cia := i.id_cia;
            rec.numint := i.numint;
            rec.tipdoc := i.tipdoc;
            rec.series := i.series;
            rec.numdoc := i.numdoc;
            rec.tident := i.tident;
            rec.ruc := i.ruc;
            rec.codcli := i.codcli;
            rec.razonsocial := i.razonsocial;
            rec.direccion := i.direccion;
            rec.fentreg := i.fentreg;
            rec.femisi := i.femisi;
            rec.lugemi := i.lugemi;
            rec.situac := i.situac;
            rec.situacnombre := i.situacnombre;
            rec.id := i.id;
            rec.codmot := i.codmot;
            rec.codven := i.codven;
            rec.codsuc := i.codsuc;
            rec.moneda := i.moneda;
            rec.tipcam := i.tipcam;
            rec.codarea := i.area;
            rec.destin := i.destin;
            rec.coc_numint := i.coc_numint;
            rec.coc_fecha := i.coc_fecha;
            rec.cocnumero := i.coc_numero;
            rec.coccontacto := i.coc_contacto;
            rec.dcccodcont := i.codigocontacto;
            rec.dccatenci := i.contacto;
            rec.dccemail := i.contactoemail;
            rec.condicionpago := i.condicionpago;
            rec.desven := i.vendedor;
            rec.codcpag := i.codcpag;
            rec.nombres := i.usuario;
            rec.incigv := i.incigv;
            rec.porigv := i.porigv;
            rec.referencia := i.referencia;
            rec.observacion := i.observacion;
            rec.comentario := i.comentario;
            rec.monafe := i.monafe;
            rec.monina := i.monina;
            rec.monigv := i.monigv;
            rec.preven := i.preven;
            rec.countadj := i.countadj;
            rec.importebruto := i.importebruto;
            rec.preven := i.preven;
            rec.codarea := i.areaf;
            rec.ucreac := i.ucreac;
            rec.usuari := i.usuari;
            rec.fcreac := i.fcreac;
            rec.factua := i.factua;
            PIPE ROW ( rec );
        END LOOP;

    END sp_buscar_req_compra;

    FUNCTION sp_buscar_orden_compra (
        pin_id_cia IN NUMBER,
        pin_lugemi IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_codven IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_destin IN NUMBER,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable6
        PIPELINED
    AS
        rec datarecord6;
        x   NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO x
        FROM
            documentos_cab;

        FOR i IN (
            SELECT
                c.id_cia,
                c.numint,
                c.tipdoc,
                c.series,
                c.numdoc,
                c.tident,
                c.ruc,
                c.codcli,
                c.razonc     AS razonsocial,
                c.direc1     AS direccion,
                c.fentreg    AS fentreg,
                c.femisi,
                c.lugemi,
                c.situac,
                s.dessit     AS situacnombre,
                c.id,
                c.codmot,
                c.codven,
                c.codsuc,
                c.tipmon     AS moneda,
                c.tipcam,
                c.codarea    AS area,
                c.destin     AS destin,
                CASE
                    WHEN c.destin = 1 THEN
                        'Nacional'
                    WHEN c.destin = 2 THEN
                        'Importación'
                    ELSE
                        'No Definido'
                END          AS desdestin,
                mo.desmot    AS desmot,
                coc.numint   AS coc_numint,
                coc.fecha    AS coc_fecha,
                coc.numero   AS coc_numero,
                coc.contacto AS coc_contacto,
                dcc.codcont  AS codigocontacto,
                dcc.email    AS contactoemail,
                dcc.plaent   AS plazoentrega,
                dcc.valide   AS validez,
                cp.despag    AS condicionpago,
                v.desven     AS vendedor,
                c.codcpag,
                c.usuari     AS coduser,
                us.nombres   AS usuario,
                CASE
                    WHEN c.incigv = 'S' THEN
                        'true'
                    ELSE
                        'false'
                END          AS incigv,
                c.porigv,
                c.numped     AS referencia,
                c.observ     AS observacion,
                c.presen     AS comentario,
                c.monafe,
                c.monina,
                c.monigv,
                c.preven,
                c.totbru     AS importebruto,
                c.preven     AS importe,
                c.facpro,
                c.ffacpro,
                c.numdue,
                /*d.numint     AS dd_numint,
                d.numite     AS dd_numite,
                d.tipinv     AS dd_tipinv,
                d.codart     AS dd_codart,
                a.descri     AS dd_desart,
                d.preuni     AS dd_preuni,
                d.pordes1    AS dd_pordes1,
                d.pordes2    AS dd_pordes2,
                d.pordes3    AS dd_pordes3,
                d.pordes4    AS dd_pordes4,
                d.importe    AS dd_importe,
                d.observ     AS dd_observ,
                d.cantid     AS dd_cantid,
                d.codadd01   AS dd_codadd01,
                cc1.descri   AS dd_descodadd01,
                d.codadd02   AS dd_codadd02,
                cc2.descri   AS dd_descodadd02,
                d.etiqueta   AS dd_etiqueta,
                d.positi     AS dd_positi,
                d.codund     AS dd_undmed,
                d.codalm     AS dd_codalm,
                c.countadj,*/
                --dc9.vreal    AS dd_arancel,
                c.ucreac,
                c.usuari,
                c.fcreac,
                c.factua,
                CASE
                    WHEN da.situac = 'B' THEN
                        'Aprobado'
                    ELSE
                        CASE
                            WHEN da.situac = 'J' THEN
                                    'Desprobado'
                            ELSE
                                'En espera'
                        END
                END          AS situacda
            FROM
                documentos_cab          c
                LEFT OUTER JOIN documentos_cab_ordcom   coc ON coc.id_cia = c.id_cia
                                                             AND coc.numint = c.numint
                /*LEFT OUTER JOIN documentos_cab_envio_sunat s ON s.id_cia = c.id_cia
                                                                AND s.numint = c.numint*/
                LEFT OUTER JOIN documentos_cab_contacto dcc ON dcc.id_cia = c.id_cia
                                                               AND dcc.numint = c.numint
                LEFT OUTER JOIN situacion               ss ON ss.id_cia = c.id_cia
                                                AND ( ss.tipdoc = c.tipdoc )
                                                AND ( ss.situac = c.situac )
                LEFT OUTER JOIN motivos                 mo ON mo.id_cia = c.id_cia
                                              AND mo.tipdoc = c.tipdoc
                                              AND mo.id = c.id
                                              AND mo.codmot = c.codmot
                LEFT OUTER JOIN c_pago                  cp ON cp.id_cia = c.id_cia
                                             AND cp.codpag = c.codcpag
                LEFT OUTER JOIN vendedor                v ON v.id_cia = c.id_cia
                                              AND v.codven = c.codven
                LEFT OUTER JOIN cliente                 cl ON cl.id_cia = c.id_cia
                                              AND cl.codcli = c.codcli
                LEFT OUTER JOIN usuarios                us ON us.id_cia = c.id_cia
                                               AND us.coduser = c.usuari
                LEFT OUTER JOIN situacion               s ON s.id_cia = c.id_cia
                                               AND s.tipdoc = c.tipdoc
                                               AND s.situac = c.situac
                LEFT OUTER JOIN tdoccobranza            cc ON cc.id_cia = c.id_cia
                                                   AND ( cc.tipdoc = c.tipdoc )
                /*LEFT OUTER JOIN documentos_det             d ON d.id_cia = c.id_cia
                                                    AND d.numint = c.numint
                LEFT OUTER JOIN documentos_det_clase       dc9 ON dc9.id_cia = c.id_cia
                                                            AND dc9.numint = d.numint
                                                            AND dc9.numite = d.numite
                                                            AND dc9.clase = 9*/
                /*LEFT OUTER JOIN articulos                  a ON a.id_cia = d.id_cia
                                               AND a.tipinv = d.tipinv
                                               AND a.codart = d.codart
                LEFT OUTER JOIN cliente_articulos_clase    cc1 ON cc1.id_cia = a.id_cia
                                                               AND cc1.tipcli = 'B'
                                                               AND cc1.codcli = a.codprv
                                                               AND cc1.clase = 1
                                                               AND cc1.codigo = d.codadd01
                LEFT OUTER JOIN cliente_articulos_clase    cc2 ON cc2.id_cia = a.id_cia
                                                               AND cc2.tipcli = 'B'
                                                               AND cc2.codcli = a.codprv
                                                               AND cc2.clase = 2
                                                               AND cc2.codigo = d.codadd02*/
                LEFT OUTER JOIN documentos_aprobacion   da ON da.id_cia = c.id_cia
                                                            AND da.numint = c.numint
                /*LEFT OUTER JOIN estado_envio_sunat         es ON c.id_cia = es.id_cia
                                                         AND s.estado = (
                    CASE
                        WHEN es.codest IS NULL THEN
                            0
                        ELSE
                            es.codest
                    END
                )*/
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = 105
                AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                AND ( c.codcli = pin_codcli
                      OR pin_codcli IS NULL )
                AND ( c.codsuc = pin_codsuc
                      OR ( pin_codsuc IS NULL
                           OR pin_codsuc = - 1 ) )
                AND ( ( c.lugemi = pin_lugemi )
                      OR ( pin_lugemi IS NULL
                           OR pin_lugemi = - 1 ) )
                AND ( ( c.codven = pin_codven )
                      OR ( pin_codven IS NULL
                           OR pin_codven = - 1 ) )
                AND ( ( c.destin = pin_destin )
                      OR ( pin_destin IS NULL
                           OR pin_destin = - 1 ) )
                AND ( ( pin_situac IS NULL )
                      OR ( c.situac IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_situac) )
                ) ) )
            ORDER BY
                c.numint DESC
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
            ROWS ONLY
        ) LOOP
            rec.id_cia := i.id_cia;
            rec.numint := i.numint;
            rec.tipdoc := i.tipdoc;
            rec.series := i.series;
            rec.numdoc := i.numdoc;
            rec.tident := i.tident;
            rec.ruc := i.ruc;
            rec.codcli := i.codcli;
            rec.razonsocial := i.razonsocial;
            rec.direccion := i.direccion;
            rec.fentreg := i.fentreg;
            rec.femisi := i.femisi;
            rec.lugemi := i.lugemi;
            rec.situac := i.situac;
            rec.situacnombre := i.situacnombre;
            rec.id := i.id;
            rec.codmot := i.codmot;
            rec.codven := i.codven;
            rec.codsuc := i.codsuc;
            rec.moneda := i.moneda;
            rec.tipcam := i.tipcam;
            rec.codarea := i.area;
            rec.destin := i.destin;
            rec.desdestin := i.desdestin;
            rec.desmot := i.desmot;
            rec.coc_numint := i.coc_numint;
            rec.coc_fecha := i.coc_fecha;
            rec.cocnumero := i.coc_numero;
            rec.coccontacto := i.coc_contacto;
            rec.dcccodcont := i.codigocontacto;
            rec.dccemail := i.contactoemail;
            rec.dccplaent := i.plazoentrega;
            rec.dccvalide := i.validez;
            rec.condicionpago := i.condicionpago;
            rec.desven := i.vendedor;
            rec.codcpag := i.codcpag;
            rec.usuari := i.coduser;
            rec.nombres := i.usuario;
            rec.incigv := i.incigv;
            rec.porigv := i.porigv;
            rec.referencia := i.referencia;
            rec.observacion := i.observacion;
            rec.comentario := i.comentario;
            rec.monafe := i.monafe;
            rec.monina := i.monina;
            rec.monigv := i.monigv;
            rec.preven := i.preven;--
            rec.importebruto := i.importebruto;
            rec.preven := i.importe;
            rec.facpro := i.facpro;
            rec.ffacpro := i.ffacpro;
            rec.numdue := i.numdue;
            --rec.dnumint := i.dd_numint;
            --rec.dnumite := i.dd_numite;
            --rec.dtipinv := i.dd_tipinv;
            --rec.dcodart := i.dd_codart;
            --rec.ddescri := i.dd_desart;
            --rec.dpreuni := i.dd_preuni;
            --rec.dpordes1 := i.dd_pordes1;
            --rec.dpordes2 := i.dd_pordes2;
            --rec.dpordes3 := i.dd_pordes3;
            --rec.dpordes4 := i.dd_pordes4;
            /*rec.dimporte := i.dd_importe;
            rec.ddobserv := i.dd_observ;
            rec.dcantid := i.dd_cantid;
            rec.dcodadd01 := i.dd_codadd01;
            rec.cc1descri := i.dd_descodadd01;
            rec.dcodadd02 := i.dd_codadd02;
            rec.cc2descri := i.dd_descodadd02;
            rec.detiqueta := i.dd_etiqueta;
            rec.dpositi := i.dd_positi;
            rec.dcodund := i.dd_undmed;*/
            /*rec.dcodalm := i.dd_codalm;
            rec.countadj := i.countadj;
            rec.dvreal := i.dd_arancel;*/
            rec.situacda := i.situacda;
            rec.ucreac := i.ucreac;
            rec.usuari := i.usuari;
            rec.fcreac := i.fcreac;
            rec.factua := i.factua;
            PIPE ROW ( rec );
        END LOOP;

    END sp_buscar_orden_compra;

    FUNCTION sp_buscar_doc_importacion (
        pin_id_cia IN NUMBER,
        pin_lugemi IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_codven IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable7
        PIPELINED
    AS
        rec datarecord7;
        x   NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO x
        FROM
            documentos_cab;

        FOR i IN (
            SELECT
                c.id_cia,
                c.numint,
                c.tipdoc,
                c.series,
                c.numdoc,
                c.tident,
                c.ruc,
                c.codcli,
                c.razonc     AS razonsocial,
                c.direc1     AS direccion,
                c.fentreg    AS fentreg,
                c.femisi,
                c.lugemi,
                c.situac,
                s.dessit     AS situacnombre,
                c.id,
                c.codmot,
                c.codven,
                c.codsuc,
                c.tipmon     AS moneda,
                c.tipcam,
                c.codarea    AS area,
                c.destin     AS destin,
                coc.numint   AS coc_numint,
                coc.fecha    AS coc_fecha,
                coc.numero   AS coc_numero,
                coc.contacto AS coc_contacto,
                dcc.codcont  AS codigocontacto,
                dcc.email    AS contactoemail,
                dcc.plaent   AS plazoentrega,
                dcc.valide   AS validez,
                cp.despag    AS condicionpago,
                v.desven     AS vendedor,
                c.codcpag,
                c.usuari     AS coduser,
                us.nombres   AS usuario,
                CASE
                    WHEN c.incigv = 'S' THEN
                        'true'
                    ELSE
                        'false'
                END          AS incigv,
                c.porigv,
                c.numped     AS referencia,
                c.observ     AS observacion,
                c.presen     AS comentario,
                c.monafe,
                c.monina,
                c.monigv,
                c.preven,
                c.totbru     AS importebruto,
                c.preven     AS importe,
                c.facpro,
                c.ffacpro,
                c.numdue,
                /*d.numint     AS dd_numint,
                d.numite     AS dd_numite,
                d.tipinv     AS dd_tipinv,
                d.codart     AS dd_codart,
                a.descri     AS dd_desart,
                d.preuni     AS dd_preuni,
                d.pordes1    AS dd_pordes1,
                d.pordes2    AS dd_pordes2,
                d.pordes3    AS dd_pordes3,
                d.pordes4    AS dd_pordes4,
                d.importe    AS dd_importe,
                d.observ     AS dd_observ,
                d.cantid     AS dd_cantid,
                d.codadd01   AS dd_codadd01,*/
                --cc1.descri   AS dd_descodadd01,
                --d.codadd02   AS dd_codadd02,
                --cc2.descri   AS dd_descodadd02,
                /*d.etiqueta   AS dd_etiqueta,
                d.positi     AS dd_positi,
                d.codund     AS dd_undmed,
                d.codalm     AS dd_codalm,*/
                c.countadj,
                --dc9.vreal    AS dd_arancel,
                c.ucreac,
                c.usuari,
                c.fcreac,
                c.factua,
                CASE
                    WHEN da.situac = 'B' THEN
                        'Aprobado'
                    ELSE
                        CASE
                            WHEN da.situac = 'J' THEN
                                    'Desprobado'
                            ELSE
                                'En espera'
                        END
                END          AS situacda
            FROM
                documentos_cab             c
                LEFT OUTER JOIN documentos_cab_ordcom      coc ON coc.id_cia = c.id_cia
                                                             AND coc.numint = c.numint
                LEFT OUTER JOIN documentos_cab_envio_sunat s ON s.id_cia = c.id_cia
                                                                AND s.numint = c.numint
                LEFT OUTER JOIN documentos_cab_contacto    dcc ON dcc.id_cia = c.id_cia
                                                               AND dcc.numint = c.numint
                LEFT OUTER JOIN situacion                  ss ON ss.id_cia = c.id_cia
                                                AND ( ss.tipdoc = c.tipdoc )
                                                AND ( ss.situac = c.situac )
                LEFT OUTER JOIN motivos                    mo ON mo.id_cia = c.id_cia
                                              AND mo.tipdoc = c.tipdoc
                                              AND mo.id = c.id
                                              AND mo.codmot = c.codmot
                LEFT OUTER JOIN c_pago                     cp ON cp.id_cia = c.id_cia
                                             AND cp.codpag = c.codcpag
                LEFT OUTER JOIN vendedor                   v ON v.id_cia = c.id_cia
                                              AND v.codven = c.codven
                LEFT OUTER JOIN cliente                    cl ON cl.id_cia = c.id_cia
                                              AND cl.codcli = c.codcli
                LEFT OUTER JOIN usuarios                   us ON us.id_cia = c.id_cia
                                               AND us.coduser = c.usuari
                LEFT OUTER JOIN situacion                  s ON s.id_cia = c.id_cia
                                               AND s.tipdoc = c.tipdoc
                                               AND s.situac = c.situac
                LEFT OUTER JOIN tdoccobranza               cc ON cc.id_cia = c.id_cia
                                                   AND ( cc.tipdoc = c.tipdoc )
                /*LEFT OUTER JOIN documentos_det             d ON d.id_cia = c.id_cia
                                                    AND d.numint = c.numint
                LEFT OUTER JOIN documentos_det_clase       dc9 ON dc9.id_cia = c.id_cia
                                                            AND dc9.numint = d.numint
                                                            AND dc9.numite = d.numite
                                                            AND dc9.clase = 9
                LEFT OUTER JOIN articulos                  a ON a.id_cia = d.id_cia
                                               AND a.tipinv = d.tipinv
                                               AND a.codart = d.codart
                LEFT OUTER JOIN cliente_articulos_clase    cc1 ON cc1.id_cia = a.id_cia
                                                               AND cc1.tipcli = 'B'
                                                               AND cc1.codcli = a.codprv
                                                               AND cc1.clase = 1
                                                               AND cc1.codigo = d.codadd01
                LEFT OUTER JOIN cliente_articulos_clase    cc2 ON cc2.id_cia = a.id_cia
                                                               AND cc2.tipcli = 'B'
                                                               AND cc2.codcli = a.codprv
                                                               AND cc2.clase = 2
                                                               AND cc2.codigo = d.codadd02
                */
                LEFT OUTER JOIN documentos_aprobacion      da ON da.id_cia = c.id_cia
                                                            AND da.numint = c.numint
                LEFT OUTER JOIN estado_envio_sunat         es ON es.id_cia = s.id_cia
                                                         AND es.codest = nvl(s.estado, 0)
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = 115
                AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                AND ( ( c.codcli = pin_codcli
                        AND pin_codcli IS NOT NULL )
                      OR pin_codcli IS NULL )
                AND ( ( c.codsuc = pin_codsuc
                        AND pin_codsuc IS NOT NULL )
                      OR ( pin_codsuc IS NULL
                           OR pin_codsuc = - 1 ) )
                AND ( ( c.lugemi = pin_lugemi
                        AND pin_lugemi IS NOT NULL )
                      OR ( pin_lugemi IS NULL
                           OR pin_lugemi = - 1 ) )
                AND ( ( c.codven = pin_codven
                        AND pin_codven IS NOT NULL )
                      OR ( pin_codven IS NULL
                           OR pin_codven = - 1 ) )
                AND ( ( pin_situac IS NULL )
                      OR ( c.situac IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_situac) )
                ) ) )
            ORDER BY
                c.numint DESC
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
            ROWS ONLY
        ) LOOP
            rec.id_cia := i.id_cia;
            rec.numint := i.numint;
            rec.tipdoc := i.tipdoc;
            rec.series := i.series;
            rec.numdoc := i.numdoc;
            rec.tident := i.tident;
            rec.ruc := i.ruc;
            rec.codcli := i.codcli;
            rec.razonsocial := i.razonsocial;
            rec.direccion := i.direccion;
            rec.fentreg := i.fentreg;
            rec.femisi := i.femisi;
            rec.lugemi := i.lugemi;
            rec.situac := i.situac;
            rec.situacnombre := i.situacnombre;
            rec.id := i.id;
            rec.codmot := i.codmot;
            rec.codven := i.codven;
            rec.codsuc := i.codsuc;
            rec.moneda := i.moneda;
            rec.tipcam := i.tipcam;
            rec.coc_numint := i.coc_numint;
            rec.coc_fecha := i.coc_fecha;
            rec.cocnumero := i.coc_numero;
            rec.coccontacto := i.coc_contacto;
            rec.condicionpago := i.condicionpago;
            rec.desven := i.vendedor;
            rec.codcpag := i.codcpag;
            rec.usuari := i.coduser;
            rec.nombres := i.usuario;
            rec.incigv := i.incigv;
            rec.porigv := i.porigv;
            rec.referencia := i.referencia;
            rec.observacion := i.observacion;
            rec.monafe := i.monafe;
            rec.monina := i.monina;
            rec.monigv := i.monigv;
            rec.preven := i.preven;--
            rec.countadj := i.countadj;
            rec.preven := i.importe;
            rec.ucreac := i.ucreac;
            rec.usuari := i.usuari;
            rec.fcreac := i.fcreac;
            rec.factua := i.factua;
            PIPE ROW ( rec );
        END LOOP;

    END sp_buscar_doc_importacion;

    FUNCTION sp_buscar_guiias_internas (
        pin_id_cia IN NUMBER,
        pin_lugemi IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_codven IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_id     CHAR,
        pin_codmot IN NUMBER,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable_guias_internas
        PIPELINED
    AS
        v_table datatable_guias_internas;
        x       NUMBER := 1000000;
    BEGIN
        SELECT
            c.id_cia,
            c.numint,
            c.tipdoc,
            c.series,
            c.numdoc,
            c.tident,
            c.ruc,
            c.codcli,
            c.razonc     AS razonsocial,
            c.direc1     AS direccion,
            c.fentreg    AS fentreg,
            c.femisi,
            c.lugemi,
            c.situac,
            s.dessit     AS situacnombre,
            c.id,
            c.codmot,
            mo.desmot,
            c.codven,
            c.codsuc,
            c.tipmon     AS moneda,
            c.monisc     AS monisc,
            c.tipcam,
            coc.numint   AS coc_numint,
            coc.fecha    AS coc_fecha,
            coc.numero   AS coc_numero,
            coc.contacto AS coc_contacto,
            dcc.codcont  AS codigocontacto,
            v.desven     AS vendedor,
            c.codcpag,
            us.nombres   AS usuario,
            CASE
                WHEN c.incigv = 'S' THEN
                    'true'
                ELSE
                    'false'
            END          AS incigv,
            c.porigv,
            c.numped     AS referencia,
            c.observ     AS observacion,
            c.presen     AS comentario,
            c.monafe,
            c.monina,
            c.monigv,
            c.preven,
            c.totbru     AS importebruto,
            c.preven     AS importe,
            cl1.vchar    AS situacimp,
            CASE
                WHEN cl1.vchar = 'S' THEN
                    'Liquidado'
                ELSE
                    'En proceso'
            END          AS dessituacimp,
            c.flete,
            c.countadj,
            c.seguro,
            c.guipro,
            c.facpro,
            c.fguipro,
            c.ffacpro,
            c.ucreac,
            c.usuari,
            c.fcreac,
            c.factua
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab          c
            LEFT OUTER JOIN documentos_cab_ordcom   coc ON coc.id_cia = c.id_cia
                                                         AND coc.numint = c.numint
            LEFT OUTER JOIN documentos_cab_contacto dcc ON dcc.id_cia = c.id_cia
                                                           AND dcc.numint = c.numint
            LEFT OUTER JOIN documentos_cab_clase    cl1 ON cl1.id_cia = c.id_cia
                                                        AND cl1.numint = c.numint
                                                        AND cl1.clase = 1
            LEFT OUTER JOIN motivos                 mo ON mo.id_cia = c.id_cia
                                          AND mo.tipdoc = c.tipdoc
                                          AND mo.id = c.id
                                          AND mo.codmot = c.codmot
            LEFT OUTER JOIN c_pago                  cp ON cp.id_cia = c.id_cia
                                         AND cp.codpag = c.codcpag
            LEFT OUTER JOIN vendedor                v ON v.id_cia = c.id_cia
                                          AND v.codven = c.codven
            LEFT OUTER JOIN cliente                 cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codcli
            LEFT OUTER JOIN usuarios                us ON us.id_cia = c.id_cia
                                           AND us.coduser = c.usuari
            LEFT OUTER JOIN situacion               s ON s.id_cia = c.id_cia
                                           AND s.tipdoc = c.tipdoc
                                           AND s.situac = c.situac
            LEFT OUTER JOIN tdoccobranza            cc ON cc.id_cia = c.id_cia
                                               AND cc.tipdoc = c.tipdoc
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 103
            AND trunc(c.femisi) BETWEEN pin_fdesde AND pin_fhasta
            AND ( ( pin_codsuc IS NULL
                    OR pin_codsuc = - 1 )
                  OR c.codsuc = pin_codsuc )
            AND ( ( pin_lugemi IS NULL
                    OR pin_lugemi = - 1 )
                  OR c.lugemi = pin_lugemi )
            AND ( ( pin_codven IS NULL
                    OR pin_codven = - 1 )
                  OR c.codven = pin_codven )
            AND ( ( pin_codmot IS NULL
                    OR pin_codmot = - 1 )
                  OR c.codmot = pin_codmot )
            AND ( c.id = pin_id
                  OR pin_id IS NULL )
            AND ( c.codcli = pin_codcli
                  OR pin_codcli IS NULL )
            AND ( pin_situac IS NULL
                  OR ( c.situac IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_situac) )
            ) ) )
        ORDER BY
            c.numint DESC
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
    END sp_buscar_guiias_internas;

    FUNCTION sp_buscar_req_compra_importacion (
        pin_id_cia IN NUMBER,
        pin_lugemi IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_codven IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable5
        PIPELINED
    AS
        rec datarecord5;
        x   NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO x
        FROM
            documentos_cab;

        FOR i IN (
            SELECT
                c.id_cia,
                c.numint,
                c.tipdoc,
                c.series,
                c.numdoc,
                c.tident,
                c.ruc,
                c.codcli,
                c.razonc     AS razonsocial,
                c.direc1     AS direccion,
                c.fentreg    AS fentreg,
                c.femisi,
                c.lugemi,
                c.situac,
                s.dessit     AS situacnombre,
                c.id,
                c.codmot,
                c.codven,
                c.codsuc,
                c.tipmon     AS moneda,
                c.tipcam,
                c.codarea    AS area,
                c.destin     AS destin,
                coc.numint   AS coc_numint,
                coc.fecha    AS coc_fecha,
                coc.numero   AS coc_numero,
                coc.contacto AS coc_contacto,
                dcc.codcont  AS codigocontacto,
                dcc.atenci   AS contacto,
                dcc.email    AS contactoemail,
                cp.despag    AS condicionpago,
                v.desven     AS vendedor,
                c.codcpag,
                us.nombres   AS usuario,
                c.ucreac,
                c.usuari,
                c.fcreac,
                c.factua,
                CASE
                    WHEN c.incigv = 'S' THEN
                        'true'
                    ELSE
                        'false'
                END          AS incigv,
                c.porigv,
                c.numped     AS referencia,
                c.observ     AS observacion,
                c.presen     AS comentario,
                c.monafe,
                c.monina,
                c.monigv,
                c.preven,
                c.countadj,
                c.totbru     AS importebruto,
                c.preven     AS importe,
                c.codarea    AS areaf
            FROM
                documentos_cab             c
                LEFT OUTER JOIN documentos_cab_ordcom      coc ON coc.id_cia = c.id_cia
                                                             AND coc.numint = c.numint
                LEFT OUTER JOIN documentos_cab_envio_sunat s ON s.id_cia = c.id_cia
                                                                AND s.numint = c.numint
                LEFT OUTER JOIN documentos_cab_contacto    dcc ON dcc.id_cia = c.id_cia
                                                               AND dcc.numint = c.numint
                LEFT OUTER JOIN situacion                  ss ON ss.id_cia = c.id_cia
                                                AND ( ss.tipdoc = c.tipdoc )
                                                AND ( ss.situac = c.situac )
                LEFT OUTER JOIN motivos                    mo ON mo.id_cia = c.id_cia
                                              AND mo.tipdoc = c.tipdoc
                                              AND mo.id = c.id
                                              AND mo.codmot = c.codmot
                LEFT OUTER JOIN c_pago                     cp ON cp.id_cia = c.id_cia
                                             AND cp.codpag = c.codcpag
                LEFT OUTER JOIN vendedor                   v ON v.id_cia = c.id_cia
                                              AND v.codven = c.codven
                LEFT OUTER JOIN cliente                    cl ON cl.id_cia = c.id_cia
                                              AND cl.codcli = c.codcli
                LEFT OUTER JOIN usuarios                   us ON us.id_cia = c.id_cia
                                               AND us.coduser = c.usuari
                LEFT OUTER JOIN situacion                  s ON s.id_cia = c.id_cia
                                               AND s.tipdoc = c.tipdoc
                                               AND s.situac = c.situac
                LEFT OUTER JOIN tdoccobranza               cc ON cc.id_cia = c.id_cia
                                                   AND ( cc.tipdoc = c.tipdoc )
                LEFT OUTER JOIN estado_envio_sunat         es ON es.id_cia = s.id_cia
                                                         AND es.codest = nvl(s.estado, 0)
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = 126
                AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                AND ( ( c.codcli = pin_codcli
                        AND pin_codcli IS NOT NULL )
                      OR pin_codcli IS NULL )
                AND ( ( c.codsuc = pin_codsuc
                        AND pin_codsuc IS NOT NULL )
                      OR ( pin_codsuc IS NULL
                           OR pin_codsuc = - 1 ) )
                AND ( ( c.lugemi = pin_lugemi
                        AND pin_lugemi IS NOT NULL )
                      OR ( pin_lugemi IS NULL
                           OR pin_lugemi = - 1 ) )
                AND ( ( c.codven = pin_codven
                        AND pin_codven IS NOT NULL )
                      OR ( pin_codven IS NULL
                           OR pin_codven = - 1 ) )
                AND ( ( pin_situac IS NULL )
                      OR ( c.situac IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_situac) )
                ) ) )
            ORDER BY
                c.numint DESC
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
            ROWS ONLY
        ) LOOP
            rec.id_cia := i.id_cia;
            rec.numint := i.numint;
            rec.tipdoc := i.tipdoc;
            rec.series := i.series;
            rec.numdoc := i.numdoc;
            rec.tident := i.tident;
            rec.ruc := i.ruc;
            rec.codcli := i.codcli;
            rec.razonsocial := i.razonsocial;
            rec.direccion := i.direccion;
            rec.fentreg := i.fentreg;
            rec.femisi := i.femisi;
            rec.lugemi := i.lugemi;
            rec.situac := i.situac;
            rec.situacnombre := i.situacnombre;
            rec.id := i.id;
            rec.codmot := i.codmot;
            rec.codven := i.codven;
            rec.codsuc := i.codsuc;
            rec.moneda := i.moneda;
            rec.tipcam := i.tipcam;
            rec.codarea := i.area;
            rec.destin := i.destin;
            rec.coc_numint := i.coc_numint;
            rec.coc_fecha := i.coc_fecha;
            rec.cocnumero := i.coc_numero;
            rec.coccontacto := i.coc_contacto;
            rec.dcccodcont := i.codigocontacto;
            rec.dccatenci := i.contacto;
            rec.dccemail := i.contactoemail;
            rec.condicionpago := i.condicionpago;
            rec.desven := i.vendedor;
            rec.codcpag := i.codcpag;
            rec.nombres := i.usuario;
            rec.incigv := i.incigv;
            rec.porigv := i.porigv;
            rec.referencia := i.referencia;
            rec.observacion := i.observacion;
            rec.comentario := i.comentario;
            rec.monafe := i.monafe;
            rec.monina := i.monina;
            rec.monigv := i.monigv;
            rec.preven := i.preven;
            rec.countadj := i.countadj;
            rec.importebruto := i.importebruto;
            rec.preven := i.preven;
            rec.codarea := i.areaf;
            rec.ucreac := i.ucreac;
            rec.usuari := i.usuari;
            rec.fcreac := i.fcreac;
            rec.factua := i.factua;
            PIPE ROW ( rec );
        END LOOP;

    END sp_buscar_req_compra_importacion;

    FUNCTION sp_buscar_orden_compra_importacion (
        pin_id_cia IN NUMBER,
        pin_lugemi IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_codven IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_destin IN NUMBER,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable9
        PIPELINED
    AS
        rec datarecord9;
        x   NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO x
        FROM
            documentos_cab;

        FOR i IN (
            SELECT
                c.id_cia,
                c.numint,
                c.tipdoc,
                c.series,
                c.numdoc,
                c.tident,
                c.ruc,
                c.codcli,
                c.razonc     AS razonsocial,
                c.direc1     AS direccion,
                c.fentreg    AS fentreg,
                c.femisi,
                c.lugemi,
                c.situac,
                s.dessit     AS situacnombre,
                c.id,
                c.codmot,
                c.codven,
                c.codsuc,
                c.tipmon     AS moneda,
                c.tipcam,
                c.codarea    AS area,
                c.destin     AS destin,
                CASE
                    WHEN c.destin = 1 THEN
                        'Nacional'
                    WHEN c.destin = 2 THEN
                        'Importación'
                    ELSE
                        'No Definido'
                END          AS desdestin,
                mo.desmot    AS desmot,
                coc.numint   AS coc_numint,
                coc.fecha    AS coc_fecha,
                coc.numero   AS coc_numero,
                coc.contacto AS coc_contacto,
                dcc.codcont  AS codigocontacto,
                dcc.email    AS contactoemail,
                dcc.plaent   AS plazoentrega,
                dcc.valide   AS validez,
                cp.despag    AS condicionpago,
                v.desven     AS vendedor,
                c.codcpag,
                c.usuari     AS coduser,
                us.nombres   AS usuario,
                CASE
                    WHEN c.incigv = 'S' THEN
                        'true'
                    ELSE
                        'false'
                END          AS incigv,
                c.porigv,
                c.numped     AS referencia,
                c.observ     AS observacion,
                c.presen     AS comentario,
                c.monafe,
                c.monina,
                c.monigv,
                c.preven,
                c.totbru     AS importebruto,
                c.preven     AS importe,
                c.facpro,
                c.ffacpro,
                c.numdue,
                /*d.numint     AS dd_numint,
                d.numite     AS dd_numite,
                d.tipinv     AS dd_tipinv,
                d.codart     AS dd_codart,
                a.descri     AS dd_desart,
                d.preuni     AS dd_preuni,
                d.pordes1    AS dd_pordes1,
                d.pordes2    AS dd_pordes2,
                d.pordes3    AS dd_pordes3,
                d.pordes4    AS dd_pordes4,
                d.importe    AS dd_importe,
                d.observ     AS dd_observ,
                d.cantid     AS dd_cantid,
                d.codadd01   AS dd_codadd01,
                cc1.descri   AS dd_descodadd01,
                d.codadd02   AS dd_codadd02,
                cc2.descri   AS dd_descodadd02,
                d.etiqueta   AS dd_etiqueta,
                d.positi     AS dd_positi,
                d.codund     AS dd_undmed,
                d.codalm     AS dd_codalm,
                c.countadj,*/
                --dc9.vreal    AS dd_arancel,
                c.flete,
                c.seguro,
                c.ucreac,
                c.usuari,
                c.fcreac,
                c.factua,
                CASE
                    WHEN da.situac = 'B' THEN
                        'Aprobado'
                    ELSE
                        CASE
                            WHEN da.situac = 'J' THEN
                                    'Desprobado'
                            ELSE
                                'En espera'
                        END
                END          AS situacda
            FROM
                documentos_cab          c
                LEFT OUTER JOIN documentos_cab_ordcom   coc ON coc.id_cia = c.id_cia
                                                             AND coc.numint = c.numint
                /*LEFT OUTER JOIN documentos_cab_envio_sunat s ON s.id_cia = c.id_cia
                                                                AND s.numint = c.numint*/
                LEFT OUTER JOIN documentos_cab_contacto dcc ON dcc.id_cia = c.id_cia
                                                               AND dcc.numint = c.numint
                LEFT OUTER JOIN situacion               ss ON ss.id_cia = c.id_cia
                                                AND ( ss.tipdoc = c.tipdoc )
                                                AND ( ss.situac = c.situac )
                LEFT OUTER JOIN motivos                 mo ON mo.id_cia = c.id_cia
                                              AND mo.tipdoc = c.tipdoc
                                              AND mo.id = c.id
                                              AND mo.codmot = c.codmot
                LEFT OUTER JOIN c_pago                  cp ON cp.id_cia = c.id_cia
                                             AND cp.codpag = c.codcpag
                LEFT OUTER JOIN vendedor                v ON v.id_cia = c.id_cia
                                              AND v.codven = c.codven
                LEFT OUTER JOIN cliente                 cl ON cl.id_cia = c.id_cia
                                              AND cl.codcli = c.codcli
                LEFT OUTER JOIN usuarios                us ON us.id_cia = c.id_cia
                                               AND us.coduser = c.usuari
                LEFT OUTER JOIN situacion               s ON s.id_cia = c.id_cia
                                               AND s.tipdoc = c.tipdoc
                                               AND s.situac = c.situac
                LEFT OUTER JOIN tdoccobranza            cc ON cc.id_cia = c.id_cia
                                                   AND ( cc.tipdoc = c.tipdoc )
                /*LEFT OUTER JOIN documentos_det             d ON d.id_cia = c.id_cia
                                                    AND d.numint = c.numint
                LEFT OUTER JOIN documentos_det_clase       dc9 ON dc9.id_cia = c.id_cia
                                                            AND dc9.numint = d.numint
                                                            AND dc9.numite = d.numite
                                                            AND dc9.clase = 9*/
                /*LEFT OUTER JOIN articulos                  a ON a.id_cia = d.id_cia
                                               AND a.tipinv = d.tipinv
                                               AND a.codart = d.codart
                LEFT OUTER JOIN cliente_articulos_clase    cc1 ON cc1.id_cia = a.id_cia
                                                               AND cc1.tipcli = 'B'
                                                               AND cc1.codcli = a.codprv
                                                               AND cc1.clase = 1
                                                               AND cc1.codigo = d.codadd01
                LEFT OUTER JOIN cliente_articulos_clase    cc2 ON cc2.id_cia = a.id_cia
                                                               AND cc2.tipcli = 'B'
                                                               AND cc2.codcli = a.codprv
                                                               AND cc2.clase = 2
                                                               AND cc2.codigo = d.codadd02*/
                LEFT OUTER JOIN documentos_aprobacion   da ON da.id_cia = c.id_cia
                                                            AND da.numint = c.numint
                /*LEFT OUTER JOIN estado_envio_sunat         es ON c.id_cia = es.id_cia
                                                         AND s.estado = (
                    CASE
                        WHEN es.codest IS NULL THEN
                            0
                        ELSE
                            es.codest
                    END
                )*/
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = 127
                AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                AND ( ( c.codcli = pin_codcli
                        AND pin_codcli IS NOT NULL )
                      OR pin_codcli IS NULL )
                AND ( ( c.codsuc = pin_codsuc
                        AND pin_codsuc IS NOT NULL )
                      OR ( pin_codsuc IS NULL
                           OR pin_codsuc = - 1 ) )
                AND ( ( c.lugemi = pin_lugemi
                        AND pin_lugemi IS NOT NULL )
                      OR ( pin_lugemi IS NULL
                           OR pin_lugemi = - 1 ) )
                AND ( ( c.codven = pin_codven
                        AND pin_codven IS NOT NULL )
                      OR ( pin_codven IS NULL
                           OR pin_codven = - 1 ) )
                AND ( ( c.destin = pin_destin
                        AND pin_destin IS NOT NULL )
                      OR ( pin_destin IS NULL
                           OR pin_destin = - 1 ) )
                AND ( ( pin_situac IS NULL )
                      OR ( c.situac IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_situac) )
                ) ) )
            ORDER BY
                c.numint DESC
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
            ROWS ONLY
        ) LOOP
            rec.id_cia := i.id_cia;
            rec.numint := i.numint;
            rec.tipdoc := i.tipdoc;
            rec.series := i.series;
            rec.numdoc := i.numdoc;
            rec.tident := i.tident;
            rec.ruc := i.ruc;
            rec.codcli := i.codcli;
            rec.razonsocial := i.razonsocial;
            rec.direccion := i.direccion;
            rec.fentreg := i.fentreg;
            rec.femisi := i.femisi;
            rec.lugemi := i.lugemi;
            rec.situac := i.situac;
            rec.situacnombre := i.situacnombre;
            rec.id := i.id;
            rec.codmot := i.codmot;
            rec.codven := i.codven;
            rec.codsuc := i.codsuc;
            rec.moneda := i.moneda;
            rec.tipcam := i.tipcam;
            rec.codarea := i.area;
            rec.destin := i.destin;
            rec.desdestin := i.desdestin;
            rec.desmot := i.desmot;
            rec.coc_numint := i.coc_numint;
            rec.coc_fecha := i.coc_fecha;
            rec.cocnumero := i.coc_numero;
            rec.coccontacto := i.coc_contacto;
            rec.dcccodcont := i.codigocontacto;
            rec.dccemail := i.contactoemail;
            rec.dccplaent := i.plazoentrega;
            rec.dccvalide := i.validez;
            rec.condicionpago := i.condicionpago;
            rec.desven := i.vendedor;
            rec.codcpag := i.codcpag;
            rec.usuari := i.coduser;
            rec.nombres := i.usuario;
            rec.incigv := i.incigv;
            rec.porigv := i.porigv;
            rec.referencia := i.referencia;
            rec.observacion := i.observacion;
            rec.comentario := i.comentario;
            rec.monafe := i.monafe;
            rec.monina := i.monina;
            rec.monigv := i.monigv;
            rec.preven := i.preven;--
            rec.importebruto := i.importebruto;
            rec.preven := i.importe;
            rec.facpro := i.facpro;
            rec.ffacpro := i.ffacpro;
            rec.numdue := i.numdue;
            --rec.dnumint := i.dd_numint;
            --rec.dnumite := i.dd_numite;
            --rec.dtipinv := i.dd_tipinv;
            --rec.dcodart := i.dd_codart;
            --rec.ddescri := i.dd_desart;
            --rec.dpreuni := i.dd_preuni;
            --rec.dpordes1 := i.dd_pordes1;
            --rec.dpordes2 := i.dd_pordes2;
            --rec.dpordes3 := i.dd_pordes3;
            --rec.dpordes4 := i.dd_pordes4;
            /*rec.dimporte := i.dd_importe;
            rec.ddobserv := i.dd_observ;
            rec.dcantid := i.dd_cantid;
            rec.dcodadd01 := i.dd_codadd01;
            rec.cc1descri := i.dd_descodadd01;
            rec.dcodadd02 := i.dd_codadd02;
            rec.cc2descri := i.dd_descodadd02;
            rec.detiqueta := i.dd_etiqueta;
            rec.dpositi := i.dd_positi;
            rec.dcodund := i.dd_undmed;*/
            /*rec.dcodalm := i.dd_codalm;
            rec.countadj := i.countadj;
            rec.dvreal := i.dd_arancel;*/
            rec.situacda := i.situacda;
            rec.flete := i.flete;
            rec.seguro := i.seguro;
            rec.ucreac := i.ucreac;
            rec.usuari := i.usuari;
            rec.fcreac := i.fcreac;
            rec.factua := i.factua;
            PIPE ROW ( rec );
        END LOOP;

    END sp_buscar_orden_compra_importacion;

    FUNCTION sp_buscar_orden_servicios (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codven IN NUMBER,
        pin_codmot IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable3
        PIPELINED
    AS
        rec datarecord3;
        x   NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO x
        FROM
            documentos_cab;

        FOR i IN (
            SELECT
                c.id_cia,
                c.numint,
                c.tipdoc,
                c.series,
                c.numdoc,
                c.tident,
                c.ruc,
                c.codcli,
                c.razonc    AS razonsocial,
                c.direc1    AS direccion,
                cl.telefono AS telefono,
                c.fentreg   AS fentreg,
                c.femisi,
                c.lugemi,
                c.situac,
                s.dessit    AS situacnombre,
                c.id,
                c.codmot,
                c.codven,
                c.codsuc,
                c.tipmon    AS moneda,
                c.tipcam,
                cp.despag   AS condicionpago,
                v.desven    AS vendedor,
                c.codcpag,
                c.usuari    AS coduser,
                us.nombres  AS usuario,
                CASE
                    WHEN c.incigv = 'S' THEN
                        'true'
                    ELSE
                        'false'
                END         AS incigv,
                c.porigv,
                c.numped    AS referencia,
                c.monafe,
                c.monina,
                c.monigv,
                c.monisc    AS monisc,
                c.preven,
                c.totbru    AS importebruto,
                c.preven    AS importe,
                c.countadj,
                da.situac   AS situacioncredito,
                c.ucreac,
                c.usuari,
                c.fcreac,
                c.factua,
                CASE
                    WHEN da.situac = 'B' THEN
                        'Aprobado'
                    ELSE
                        CASE
                            WHEN da.situac = 'J' THEN
                                    'Desaprobado'
                            ELSE
                                'No Asignado'
                        END
                END         situacioncreditonombre,
                CASE
                    WHEN da.situac = 'B' THEN
                        'Aprobado'
                    ELSE
                        CASE
                            WHEN da.situac = 'J' THEN
                                    'Desaprobado'
                            ELSE
                                'En Espera'
                        END
                END         AS situacda
            FROM
                documentos_cab        c
                LEFT OUTER JOIN documentos_cab_ordcom coc ON coc.id_cia = c.id_cia
                                                             AND coc.numint = c.numint
                LEFT OUTER JOIN motivos               mo ON mo.id_cia = c.id_cia
                                              AND mo.tipdoc = c.tipdoc
                                              AND mo.id = c.id
                                              AND mo.codmot = c.codmot
                LEFT OUTER JOIN c_pago                cp ON cp.id_cia = c.id_cia
                                             AND cp.codpag = c.codcpag
                LEFT OUTER JOIN vendedor              v ON v.id_cia = c.id_cia
                                              AND v.codven = c.codven
                LEFT OUTER JOIN cliente               cl ON cl.id_cia = c.id_cia
                                              AND cl.codcli = c.codcli
                LEFT OUTER JOIN usuarios              us ON us.id_cia = c.id_cia
                                               AND us.coduser = c.usuari
                LEFT OUTER JOIN situacion             s ON s.id_cia = c.id_cia
                                               AND s.tipdoc = c.tipdoc
                                               AND s.situac = c.situac
                LEFT OUTER JOIN documentos_aprobacion da ON da.id_cia = c.id_cia
                                                            AND da.numint = c.numint
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = 129 -- Orden de Servicio
                AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                AND ( ( c.codcli = pin_codcli )
                      OR pin_codcli IS NULL )
                AND ( ( c.codmot = pin_codmot )
                      OR ( pin_codmot IS NULL
                           OR pin_codmot = - 1 ) )
                AND ( ( c.codsuc = pin_codsuc )
                      OR ( pin_codsuc IS NULL
                           OR pin_codsuc = - 1 ) )
                AND ( ( c.codven = pin_codven )
                      OR ( pin_codven IS NULL
                           OR pin_codven = - 1 ) )
                AND ( ( c.codcli = pin_codcli )
                      OR pin_codcli IS NULL )
                AND ( ( pin_situac IS NULL )
                      OR ( c.situac IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_situac) )
                ) ) )
            ORDER BY
                c.numint DESC
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
            ROWS ONLY
        ) LOOP
            rec.id_cia := i.id_cia;
            rec.numint := i.numint;
            rec.tipdoc := i.tipdoc;
            rec.series := i.series;
            rec.numdoc := i.numdoc;
            rec.tident := i.tident;
            rec.ruc := i.ruc;
            rec.telefono := i.telefono;
            rec.codcli := i.codcli;
            rec.razonsocial := i.razonsocial;
            rec.direccion := i.direccion;
            rec.fentreg := i.fentreg;
            rec.femisi := i.femisi;
            rec.lugemi := i.lugemi;
            rec.situac := i.situac;
            rec.situacnombre := i.situacnombre;
            rec.id := i.id;
            rec.codmot := i.codmot;
            rec.codven := i.codven;
            rec.codsuc := i.codsuc;
            rec.moneda := i.moneda;
            rec.tipcam := i.tipcam;
            rec.condicionpago := i.condicionpago;
            rec.desven := i.vendedor;
            rec.codcpag := i.codcpag;
            rec.usuari := i.usuario;
            rec.incigv := i.incigv;
            rec.referencia := i.referencia;
            rec.monafe := i.monafe;
            rec.monina := i.monina;
            rec.monigv := i.monigv;
            rec.monisc := i.monisc;
            rec.preven := i.importe;
            rec.importebruto := i.importebruto;
            rec.preven := i.importe;
            rec.countadj := i.countadj;
            rec.situacda := i.situacda;
            rec.ucreac := i.ucreac;
            rec.usuari := i.usuari;
            rec.fcreac := i.fcreac;
            rec.factua := i.factua;
            PIPE ROW ( rec );
        END LOOP;

    END sp_buscar_orden_servicios;

    FUNCTION sp_buscar_orden_produccion (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codven IN NUMBER,
        pin_codmot IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable_buscar_orden_produccion
        PIPELINED
    AS
        v_table datatable_buscar_orden_produccion;
        x       NUMBER := 1000000;
    BEGIN
        SELECT
            c.id_cia,
            c.numint,
            c.tipdoc,
            c.series,
            c.numdoc,
            c.tident,
            c.ruc,
            c.codcli,
            c.razonc    AS razonsocial,
            c.direc1    AS direccion,
            cl.telefono AS telefono,
            c.fentreg   AS fentreg,
            c.femisi,
            c.lugemi,
            c.situac,
            s.dessit    AS situacnombre,
            c.id,
            c.codmot,
            mo.desmot,
            c.codven,
            c.codsuc,
            c.tipmon    AS moneda,
            c.tipcam,
            cp.despag   AS condicionpago,
            v.desven    AS vendedor,
            c.codcpag,
            us.nombres  AS usuario,
            CASE
                WHEN c.incigv = 'S' THEN
                    'true'
                ELSE
                    'false'
            END         AS incigv,
            c.porigv,
            c.numped    AS referencia,
            c.monafe,
            c.monina,
            c.monigv,
            c.monisc    AS monisc,
            c.preven,
            c.totbru    AS importebruto,
            c.preven    AS importe,
            c.countadj,
            da.situac   AS situacioncredito,
            c.ucreac,
            c.usuari,
            c.fcreac,
            c.factua
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab        c
            LEFT OUTER JOIN documentos_cab_ordcom coc ON coc.id_cia = c.id_cia
                                                         AND coc.numint = c.numint
            LEFT OUTER JOIN motivos               mo ON mo.id_cia = c.id_cia
                                          AND mo.tipdoc = c.tipdoc
                                          AND mo.id = c.id
                                          AND mo.codmot = c.codmot
            LEFT OUTER JOIN c_pago                cp ON cp.id_cia = c.id_cia
                                         AND cp.codpag = c.codcpag
            LEFT OUTER JOIN vendedor              v ON v.id_cia = c.id_cia
                                          AND v.codven = c.codven
            LEFT OUTER JOIN cliente               cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codcli
            LEFT OUTER JOIN usuarios              us ON us.id_cia = c.id_cia
                                           AND us.coduser = c.usuari
            LEFT OUTER JOIN situacion             s ON s.id_cia = c.id_cia
                                           AND s.tipdoc = c.tipdoc
                                           AND s.situac = c.situac
            LEFT OUTER JOIN documentos_aprobacion da ON da.id_cia = c.id_cia
                                                        AND da.numint = c.numint
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 104
            AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
            AND ( c.codcli = pin_codcli
                  OR pin_codcli IS NULL )
            AND ( c.codmot = pin_codmot
                  OR ( pin_codmot IS NULL
                       OR pin_codmot = - 1 ) )
            AND ( c.codsuc = pin_codsuc
                  OR ( pin_codsuc IS NULL
                       OR pin_codsuc = - 1 ) )
            AND ( c.codven = pin_codven
                  OR ( pin_codven IS NULL
                       OR pin_codven = - 1 ) )
            AND ( c.codcli = pin_codcli
                  OR pin_codcli IS NULL )
            AND ( ( pin_situac IS NULL )
                  OR ( c.situac IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_situac) )
            ) ) )
        ORDER BY
            c.numint DESC
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
    END sp_buscar_orden_produccion;

    FUNCTION sp_buscar_orden_produccion_noliq (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codven IN NUMBER,
        pin_codmot IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable_buscar_orden_produccion
        PIPELINED
    AS
        v_table datatable_buscar_orden_produccion;
        x       NUMBER := 1000000;
    BEGIN
        SELECT
            c.id_cia,
            c.numint,
            c.tipdoc,
            c.series,
            c.numdoc,
            c.tident,
            c.ruc,
            c.codcli,
            c.razonc    AS razonsocial,
            c.direc1    AS direccion,
            cl.telefono AS telefono,
            c.fentreg   AS fentreg,
            c.femisi,
            c.lugemi,
            c.situac,
            s.dessit    AS situacnombre,
            c.id,
            c.codmot,
            mo.desmot,
            c.codven,
            c.codsuc,
            c.tipmon    AS moneda,
            c.tipcam,
            cp.despag   AS condicionpago,
            v.desven    AS vendedor,
            c.codcpag,
            us.nombres  AS usuario,
            CASE
                WHEN c.incigv = 'S' THEN
                    'true'
                ELSE
                    'false'
            END         AS incigv,
            c.porigv,
            c.numped    AS referencia,
            c.monafe,
            c.monina,
            c.monigv,
            c.monisc    AS monisc,
            c.preven,
            c.totbru    AS importebruto,
            c.preven    AS importe,
            c.countadj,
            da.situac   AS situacioncredito,
            c.ucreac,
            c.usuari,
            c.fcreac,
            c.factua
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab        c
            LEFT OUTER JOIN documentos_cab_ordcom coc ON coc.id_cia = c.id_cia
                                                         AND coc.numint = c.numint
            LEFT OUTER JOIN motivos               mo ON mo.id_cia = c.id_cia
                                          AND mo.tipdoc = c.tipdoc
                                          AND mo.id = c.id
                                          AND mo.codmot = c.codmot
            LEFT OUTER JOIN c_pago                cp ON cp.id_cia = c.id_cia
                                         AND cp.codpag = c.codcpag
            LEFT OUTER JOIN vendedor              v ON v.id_cia = c.id_cia
                                          AND v.codven = c.codven
            LEFT OUTER JOIN cliente               cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codcli
            LEFT OUTER JOIN usuarios              us ON us.id_cia = c.id_cia
                                           AND us.coduser = c.usuari
            LEFT OUTER JOIN situacion             s ON s.id_cia = c.id_cia
                                           AND s.tipdoc = c.tipdoc
                                           AND s.situac = c.situac
            LEFT OUTER JOIN documentos_aprobacion da ON da.id_cia = c.id_cia
                                                        AND da.numint = c.numint
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 104
            AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
            AND ( c.codcli = pin_codcli
                  OR pin_codcli IS NULL )
            AND ( c.codmot = pin_codmot
                  OR ( pin_codmot IS NULL
                       OR pin_codmot = - 1 ) )
            AND ( c.codsuc = pin_codsuc
                  OR ( pin_codsuc IS NULL
                       OR pin_codsuc = - 1 ) )
            AND ( c.codven = pin_codven
                  OR ( pin_codven IS NULL
                       OR pin_codven = - 1 ) )
            AND ( c.codcli = pin_codcli
                  OR pin_codcli IS NULL )
            AND ( ( pin_situac IS NULL )
                  OR ( c.situac IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_situac) )
            ) ) )
            AND EXISTS (
                SELECT
                    ddd.*
                FROM
                    documentos_det ddd
                WHERE
                        ddd.id_cia = c.id_cia
                    AND ddd.numint = c.numint
                    AND nvl(ddd.swacti, 0) = 0
            )
        ORDER BY
            c.numint DESC
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
    END sp_buscar_orden_produccion_noliq;

    FUNCTION sp_buscar_orden_trabajo (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codven IN NUMBER,
        pin_codmot IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable_buscar_orden_produccion
        PIPELINED
    AS
        v_table datatable_buscar_orden_produccion;
        x       NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO x
        FROM
            documentos_cab;

        SELECT
            c.id_cia,
            c.numint,
            c.tipdoc,
            c.series,
            c.numdoc,
            c.tident,
            c.ruc,
            c.codcli,
            c.razonc    AS razonsocial,
            c.direc1    AS direccion,
            cl.telefono AS telefono,
            c.fentreg   AS fentreg,
            c.femisi,
            c.lugemi,
            c.situac,
            s.dessit    AS situacnombre,
            c.id,
            c.codmot,
            mo.desmot,
            c.codven,
            c.codsuc,
            c.tipmon    AS moneda,
            c.tipcam,
            cp.despag   AS condicionpago,
            v.desven    AS vendedor,
            c.codcpag,
--            c.usuari    AS coduser,
            us.nombres  AS usuario,
            CASE
                WHEN c.incigv = 'S' THEN
                    'true'
                ELSE
                    'false'
            END         AS incigv,
            c.porigv,
            c.numped    AS referencia,
            c.monafe,
            c.monina,
            c.monigv,
            c.monisc    AS monisc,
            c.preven,
            c.totbru    AS importebruto,
            c.preven    AS importe,
            c.countadj,
            da.situac   AS situacioncredito,
            c.ucreac,
            c.usuari,
            c.fcreac,
            c.factua
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab        c
            LEFT OUTER JOIN documentos_cab_ordcom coc ON coc.id_cia = c.id_cia
                                                         AND coc.numint = c.numint
            LEFT OUTER JOIN motivos               mo ON mo.id_cia = c.id_cia
                                          AND mo.tipdoc = c.tipdoc
                                          AND mo.id = c.id
                                          AND mo.codmot = c.codmot
            LEFT OUTER JOIN c_pago                cp ON cp.id_cia = c.id_cia
                                         AND cp.codpag = c.codcpag
            LEFT OUTER JOIN vendedor              v ON v.id_cia = c.id_cia
                                          AND v.codven = c.codven
            LEFT OUTER JOIN cliente               cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codcli
            LEFT OUTER JOIN usuarios              us ON us.id_cia = c.id_cia
                                           AND us.coduser = c.usuari
            LEFT OUTER JOIN situacion             s ON s.id_cia = c.id_cia
                                           AND s.tipdoc = c.tipdoc
                                           AND s.situac = c.situac
            LEFT OUTER JOIN documentos_aprobacion da ON da.id_cia = c.id_cia
                                                        AND da.numint = c.numint
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 109
            AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
            AND ( c.codcli = pin_codcli
                  OR pin_codcli IS NULL )
            AND ( c.codmot = pin_codmot
                  OR ( pin_codmot IS NULL
                       OR pin_codmot = - 1 ) )
            AND ( c.codsuc = pin_codsuc
                  OR ( pin_codsuc IS NULL
                       OR pin_codsuc = - 1 ) )
            AND ( c.codven = pin_codven
                  OR ( pin_codven IS NULL
                       OR pin_codven = - 1 ) )
            AND ( c.codcli = pin_codcli
                  OR pin_codcli IS NULL )
            AND ( ( pin_situac IS NULL )
                  OR ( c.situac IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_situac) )
            ) ) )
        ORDER BY
            c.numint DESC
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
    END sp_buscar_orden_trabajo;

END;

/
