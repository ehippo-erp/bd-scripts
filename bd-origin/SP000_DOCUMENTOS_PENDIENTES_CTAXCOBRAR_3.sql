--------------------------------------------------------
--  DDL for Function SP000_DOCUMENTOS_PENDIENTES_CTAXCOBRAR_3
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_DOCUMENTOS_PENDIENTES_CTAXCOBRAR_3" (
    pin_id_cia       IN NUMBER,
    pin_wcodcli      IN VARCHAR2,
    pin_wcodsuc      IN NUMBER,
    pin_wcodven      IN NUMBER,
    pin_wtipdocs     IN VARCHAR2,
    pin_wcodubis     IN VARCHAR2,
    pin_wswincletdes IN VARCHAR2,
    pin_wnumint      IN NUMBER,
    pin_swfactanti   IN VARCHAR2,
    pin_grupoeco     IN VARCHAR2
) RETURN tbl_sp000_documentos_pendientes_ctaxcobrar_2
    PIPELINED
AS

    rec            rec_sp000_documentos_pendientes_ctaxcobrar_2 := rec_sp000_documentos_pendientes_ctaxcobrar_2(NULL, NULL, NULL, NULL
    , NULL,
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
                                                                                                    NULL);
    v_wfhasta      DATE;
    v_wtipdocs     VARCHAR2(100);
    v_wcodubis     VARCHAR2(100);
    v_wswincletdes VARCHAR2(100);
BEGIN
    v_wfhasta := current_date;
    v_wtipdocs := pin_wtipdocs;
    v_wcodubis := pin_wcodubis;
    v_wswincletdes := pin_wswincletdes;
    IF ( v_wtipdocs IS NULL ) THEN
        v_wtipdocs := 'XXX';
    END IF;
    IF ( v_wcodubis IS NULL ) THEN
        v_wcodubis := 'XXX';
    END IF;
    IF ( v_wswincletdes IS NULL ) THEN
        v_wswincletdes := 'N';
    END IF;
    FOR i IN (
        SELECT
            c.codcli,
            CASE
                WHEN d.codcli = '00000000001'
                     AND dc.razonc IS NOT NULL THEN
                    dc.razonc
                ELSE
                    c.razonc
            END                                                AS razonc,
            d.tipdoc,
            d.serie,
            d.numero,
            td.descri                                          AS desdoc,
            td.abrevi                                          AS abrevi,
            d.docume,
            d.numint,
            abs(d.codven)                                      AS codven,
            v1.desven,
            v2.codven                                          AS codven_car,
            v2.desven                                          AS desven_car,
            abs(d.codsuc)                                      AS codsuc,
            su.sucursal                                        AS dessuc,
            abs(d.codubi)                                      AS codubi,
            ub.desubi                                          AS desubi,
            ub.abrevi                                          AS abrubi,
            d.femisi,
            d.fvenci,
            d.fcance,
            CAST(d.fvenci - v_wfhasta AS INTEGER)              AS dias,
            d.tipmon,
            m.simbolo                                          AS moneda,
            d.tipcam,
            ( d.importe * CAST(td.signo AS DOUBLE PRECISION) ) AS importe,
            ( d.saldo * CAST(td.signo AS DOUBLE PRECISION) )   AS saldos,
            ( d.saldomn * CAST(td.signo AS DOUBLE PRECISION) ) AS saldosol,
            ( d.saldome * CAST(td.signo AS DOUBLE PRECISION) ) AS saldosol1,
            CASE
                WHEN d.tipmon = 'PEN' THEN
                    ( d.saldomn * CAST(td.signo AS DOUBLE PRECISION) ) / d.tipcam
                ELSE
                    d.saldome * CAST(td.signo AS DOUBLE PRECISION)
            END                                                AS saldodolar,
            CASE
                WHEN ( CAST(d.fvenci - v_wfhasta AS INTEGER) >= 0 ) THEN
                    0
                ELSE
                    CASE
                        WHEN d.tipmon = 'PEN' THEN
                                ( d.saldomn * CAST(td.signo AS DOUBLE PRECISION) ) / d.tipcam
                        ELSE
                            d.saldome * CAST(td.signo AS DOUBLE PRECISION)
                    END
            END                                                AS vencidos,
            d.dh,
            CASE
                WHEN abs(d.operac) = 2 THEN
                    'FED'
                ELSE
                    'CARTERA'
            END                                                AS fed,
            d.refere01,
            d.refere02,
            td.signo,
            d.numbco,
            d.codban,
            CASE
                WHEN d.tipdoc = 6 THEN
                    ef.descri
                ELSE
                    CASE
                        WHEN b.abrevi = ''
                             OR b.abrevi IS NULL THEN
                                    CASE
                                        WHEN b.descri IS NULL THEN
                                            ' '
                                        ELSE
                                            b.descri
                                    END
                        ELSE
                            b.abrevi
                    END
            END                                                AS desban,
            d.protes,
            CASE
                WHEN d.protes = 1 THEN
                    'Si'
                ELSE
                    'No'
            END                                                AS desprotes,
            c.limcre1,
            c.limcre2,
            c.chedev,
            c.letpro,
            c.renova,
            c.refina,
            c.fecing,
            c.codpag,
            abs(d.operac)                                      AS operac,
            CASE
                WHEN ( ( d.concpag IS NULL )
                       OR ( d.concpag = 0 ) ) THEN
                        CASE
                            WHEN dc.codcpag IS NULL THEN
                                0
                            ELSE
                                dc.codcpag
                        END
                ELSE
                    d.concpag
            END                                                AS concpag,
            cp.despag                                          AS descpag,
            c.telefono,
            CASE
                WHEN dcc.vreal IS NULL THEN
                    0
                ELSE
                    dcc.vreal
            END                                                AS tpercepcion,
            c.direc1,
            CASE
                WHEN d3.numint IS NULL THEN
                    ' '
                ELSE
                    'Renovada'
            END                                                AS renovada,
            CASE
                WHEN ( d.tipdoc = 5
                       AND d5.libro = '35' ) THEN
                    'Refinanciada'
                ELSE
                    CASE
                        WHEN ( d.tipdoc = 5
                               AND d5.libro IN ( '12', '31' ) ) THEN
                                'Renovada'
                        ELSE
                            ''
                    END
            END                                                AS estadolet,
            dc.codmot,
            mt.desmot
        FROM
                 dcta100 d
            INNER JOIN cliente                                                          c ON c.id_cia = d.id_cia
                                    AND c.codcli = d.codcli
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, 'A', c.codcli, 28) ccc ON 0 = 0
            LEFT OUTER JOIN documentos_cab                                                   dc ON dc.id_cia = d.id_cia
                                                 AND dc.numint = d.numint
            LEFT OUTER JOIN documentos_cab_clase                                             dcc ON dcc.id_cia = d.id_cia
                                                        AND dcc.numint = d.numint
                                                        AND dcc.clase = 4
            LEFT OUTER JOIN motivos                                                          mt ON mt.id_cia = dc.id_cia
                                          AND mt.tipdoc = dc.tipdoc
                                          AND mt.codmot = dc.codmot
                                          AND mt.id = dc.id
            LEFT OUTER JOIN vendedor                                                         v1 ON v1.id_cia = dc.id_cia
                                           AND v1.codven = dc.codven
            LEFT OUTER JOIN vendedor                                                         v2 ON v2.id_cia = c.id_cia
                                           AND v2.codven = c.codven
            LEFT OUTER JOIN tbancos                                                          b ON b.id_cia = d.id_cia
                                         AND b.codban = CAST(d.codban AS VARCHAR(3))
            LEFT OUTER JOIN e_financiera                                                     ef ON ef.id_cia = d.id_cia
                                               AND ef.codigo = d.codban
            LEFT OUTER JOIN sucursal                                                         su ON su.id_cia = d.id_cia
                                           AND su.codsuc = d.codsuc
            LEFT OUTER JOIN ubicacion                                                        ub ON ub.id_cia = d.id_cia
                                            AND ub.codubi = d.codubi
            LEFT OUTER JOIN tmoneda                                                          m ON m.id_cia = d.id_cia
                                         AND m.codmon = d.tipmon
            LEFT OUTER JOIN dcta103                                                          d3 ON d3.id_cia = d.id_cia
                                          AND d3.numint = d.numint
                                          AND d3.libro IN ( '12', '31' )
                                          AND d3.situac = 'A'
            LEFT OUTER JOIN dcta105                                                          d5 ON d5.id_cia = d.id_cia
                                          AND ( d5.numint = d.numint )
            INNER JOIN tdoccobranza                                                     td ON td.id_cia = d.id_cia
                                          AND td.tipdoc = d.tipdoc
            LEFT OUTER JOIN c_pago                                                           cp ON cp.id_cia = d.id_cia
                                         AND cp.codpag = CASE
                                                             WHEN nvl(d.concpag, 0) = 0 THEN
                                                                 nvl(dc.codcpag, 0)
                                                             ELSE
                                                                 d.concpag
                                                         END
        WHERE
                d.id_cia = pin_id_cia
            AND d.femisi <= v_wfhasta
            AND ( ( pin_wnumint IS NULL )
                  OR ( d.numint = pin_wnumint ) )
            AND ( ( pin_wcodcli IS NULL )
                  OR ( d.codcli = pin_wcodcli ) )
            AND ( ( pin_wcodsuc IS NULL )
                  OR ( d.codsuc = pin_wcodsuc ) )
            AND ( ( pin_wcodven IS NULL )
                  OR ( d.codven = pin_wcodven ) )
            AND ( ( v_wtipdocs = 'XXX' )
                  OR ( d.tipdoc IN (
                SELECT
                    *
                FROM
                    TABLE ( f_convert(v_wtipdocs) )
            ) ) )
            AND ( ( v_wcodubis = 'XXX' )
                  OR ( d.codubi IN (
                SELECT
                    *
                FROM
                    TABLE ( f_convert(v_wcodubis) )
            ) ) )
            AND ( ( v_wswincletdes = 'S' )
                  OR ( ( v_wswincletdes = 'N' )
                       AND ( abs(d.operac) <> 2 ) ) )
            AND d.saldo <> 0
            AND ( pin_grupoeco IS NULL
                  OR ccc.codigo = pin_grupoeco )
        ORDER BY
            d.codcli,
            d.tipdoc,
            d.docume,
            d.fvenci
    ) LOOP
        rec.codcli := i.codcli;
        rec.razonc := i.razonc;
        rec.tipdoc := i.tipdoc;
        rec.serie := i.serie;
        rec.numero := i.numero;
        rec.desdoc := i.desdoc;
        rec.abrevi := i.abrevi;
        rec.docume := i.docume;
        rec.numint := i.numint;
        rec.codven := i.codven;
        rec.desven := i.desven;
        rec.codven_car := i.codven_car;
        rec.desven_car := i.desven_car;
        rec.codsuc := i.codsuc;
        rec.dessuc := i.dessuc;
        rec.codubi := i.codubi;
        rec.desubi := i.desubi;
        rec.abrubi := i.abrubi;
        rec.femisi := i.femisi;
        rec.fvenci := i.fvenci;
        rec.fcance := i.fcance;
        rec.dias := i.dias;
        rec.tipmon := i.tipmon;
        rec.moneda := i.moneda;
        rec.tipcam := i.tipcam;
        rec.importe := i.importe;
        rec.saldo := i.saldos;
        rec.saldosol := i.saldosol;
        rec.saldodol := i.saldosol1;
        rec.saldodolar := i.saldodolar;
        rec.vencidos := i.vencidos;
        rec.dh := i.dh;
        rec.fed := i.fed;
        rec.refere01 := i.refere01;
        rec.refere02 := i.refere02;
        rec.signo := i.signo;
        rec.numbco := i.numbco;
        rec.codban := i.codban;
        rec.desban := i.desban;
        rec.protes := i.protes;
        rec.desprotes := i.desprotes;
        rec.limcre1 := i.limcre1;
        rec.limcre2 := i.limcre2;
        rec.chedev := i.chedev;
        rec.letpro := i.letpro;
        rec.renova := i.renova;
        rec.refina := i.refina;
        rec.fecing := i.fecing;
        rec.codpag := i.codpag;
        rec.operac := i.operac;
        rec.concpag := i.concpag;
        rec.descpag := i.descpag;
        rec.telefono := i.telefono;
        rec.tpercepcion := i.tpercepcion;
        rec.direc1 := i.direc1;
        rec.renovada := i.renovada;
        rec.estadolet := i.estadolet;
        rec.codmot := i.codmot;
        rec.desmot := i.desmot;
        rec.saldopercep := nvl(i.tpercepcion, 0);
        IF (
            ( i.tipdoc IN ( 1, 3 ) )
            AND ( i.tpercepcion <> 0 )
        ) THEN
            SELECT
                SUM(nvl(d.percepcion, 0))
            INTO rec.saldopercep
            FROM
                documentos_det_percepcion d
                LEFT OUTER JOIN documentos_cab            c ON c.id_cia = d.id_cia
                                                    AND c.numint = d.numint
            WHERE
                    d.id_cia = pin_id_cia
                AND c.situac = 'F'
                AND d.numintfac = i.numint;

            IF ( rec.saldopercep IS NULL ) THEN
                rec.saldopercep := 0;
            END IF;

            rec.saldopercep := ( i.tpercepcion - rec.saldopercep );
        END IF;

        rec.desoperac := 'NO DEFINIDO';
        IF ( i.operac = 0 ) THEN
            rec.desoperac := 'Cartera';
        ELSIF ( i.operac = 1 ) THEN
            rec.desoperac := 'Cobranza';
        ELSIF ( i.operac = 2 ) THEN
            rec.desoperac := 'Descuento';
        ELSIF ( i.operac = 3 ) THEN
            rec.desoperac := 'Garantía';
        ELSIF ( i.operac = 4 ) THEN
            rec.desoperac := 'Cancelado';
        ELSIF ( i.operac = 5 ) THEN
            rec.desoperac := 'Protestado';
        ELSIF ( i.operac = 6 ) THEN
            rec.desoperac := 'Retirada';
        ELSIF ( i.operac = 7 ) THEN
            rec.desoperac := 'Emitida';
        ELSIF ( i.operac = 8 ) THEN
            rec.desoperac := 'Protesto en banco';
        ELSIF ( i.operac = 9 ) THEN
            rec.desoperac := 'Ingreso a banco';
        END IF;

        PIPE ROW ( rec );
        IF ( pin_swfactanti = 'S' ) THEN
            rec.codcli := NULL;
            rec.razonc := NULL;
            rec.numint := NULL;
            rec.tipdoc := NULL;
            rec.desdoc := NULL;
            rec.abrevi := NULL;
            rec.docume := NULL;
            rec.codven := NULL;
            rec.desven := NULL;
            rec.desven_car := NULL;
            rec.codsuc := NULL;
            rec.dessuc := NULL;
            rec.codubi := NULL;
            rec.desubi := NULL;
            rec.abrubi := NULL;
            rec.femisi := NULL;
            rec.fvenci := NULL;
            rec.fcance := NULL;
            rec.dias := NULL;
            rec.tipmon := NULL;
            rec.moneda := NULL;
            rec.tipcam := NULL;
            rec.tpercepcion := NULL;
            rec.importe := NULL;
            rec.saldopercep := 0;
            rec.saldo := NULL;
            rec.saldosol := NULL;
            rec.saldodol := NULL;
            rec.saldodolar := NULL;
            rec.vencidos := NULL;
            rec.dh := NULL;
            rec.fed := NULL;
            rec.refere01 := NULL;
            rec.refere02 := NULL;
            rec.codban := 0;
            rec.desban := NULL;
            rec.numbco := NULL;
            rec.signo := NULL;
            rec.protes := NULL;
            rec.desprotes := 'No';
            rec.limcre1 := NULL;
            rec.limcre2 := NULL;
            rec.chedev := NULL;
            rec.letpro := NULL;
            rec.renova := NULL;
            rec.refina := NULL;
            rec.fecing := NULL;
            rec.codpag := NULL;
            rec.operac := NULL;
            rec.desoperac := NULL;
            rec.concpag := NULL;
            rec.descpag := NULL;
            rec.telefono := NULL;
            rec.direc1 := NULL;
            FOR j IN (
                SELECT
                    d6.numint,
                    d6.tipdoc,
                    d.abrevi,
                    d.descri         AS desdoc,
                    d6.docume,
                    d6.refere01,
                    d6.femisi,
                    d6.fvenci,
                    d6.fcance,
                    d6.tipmon,
                    d6.importe * - 1 AS importe,
                    d16.saldo * - 1  AS saldo,
                    CASE
                        WHEN d16.tipmon = 'PEN' THEN
                                d16.saldo
                        ELSE
                            0
                    END
                    * - 1            AS saldosol,
                    CASE
                        WHEN d16.tipmon <> 'PEN' THEN
                                d16.saldo
                        ELSE
                            0
                    END
                    * - 1            AS saldodol1,
                    d6.operac,
                    d6.tipcam,
                    - 1              AS signo,
                    d6.codcli,
                    cl.razonc,
                    mo.simbolo       AS moneda,
                    d6.codubi,
                    ub.desubi,
                    ub.abrevi        AS abrubi,
                    c.codmot,
                    m.desmot
                FROM
                    TABLE ( sp000_saca_saldo_dcta106(pin_id_cia, 0) )                  d16
                    LEFT OUTER JOIN dcta100                                                            d6 ON d6.id_cia = pin_id_cia
                                                  AND d6.numint = d16.numint
                    LEFT OUTER JOIN tdoccobranza                                                       d ON d.id_cia = d6.id_cia
                                                      AND d.tipdoc = d6.tipdoc
                    LEFT OUTER JOIN documentos_cab                                                     c ON c.id_cia = d6.id_cia
                                                        AND c.numint = d6.numint
                    LEFT OUTER JOIN cliente                                                            cl ON cl.id_cia = d6.id_cia
                                                  AND cl.codcli = d6.codcli
                    LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(cl.id_cia, 'A', cl.codcli, 28) ccc ON 0 = 0
                    LEFT OUTER JOIN tmoneda                                                            mo ON mo.id_cia = d6.id_cia
                                                  AND mo.codmon = d6.tipmon
                    LEFT OUTER JOIN ubicacion                                                          ub ON ub.id_cia = d6.id_cia
                                                    AND ub.codubi = d6.codubi
                    LEFT OUTER JOIN motivos                                                            m ON m.id_cia = c.id_cia
                                                 AND m.tipdoc = c.tipdoc
                                                 AND m.codmot = c.codmot
                                                 AND m.id = c.id
                WHERE
                        d6.id_cia = pin_id_cia
                    AND d6.femisi <= v_wfhasta
                    AND ( ( pin_wcodcli IS NULL )
                          OR ( d6.codcli = pin_wcodcli ) )
                    AND ( ( pin_wcodsuc IS NULL )
                          OR ( d6.codsuc = pin_wcodsuc ) )
                    AND ( ( pin_wcodven IS NULL )
                          OR ( d6.codven = pin_wcodven ) )
                    AND ( ( v_wtipdocs = 'XXX' )
                          OR ( d6.tipdoc IN (
                        SELECT
                            *
                        FROM
                            TABLE ( f_convert(v_wtipdocs) )
                    ) ) )
                    AND ( ( v_wcodubis = 'XXX' )
                          OR ( d6.codubi IN (
                        SELECT
                            *
                        FROM
                            TABLE ( f_convert(v_wcodubis) )
                    ) ) )
                    AND d16.saldo <> 0
                    AND ( pin_grupoeco IS NULL
                          OR ccc.codigo = pin_grupoeco )
            ) LOOP
                rec.numint := j.numint;
                rec.tipdoc := j.tipdoc;
                rec.abrevi := j.abrevi;
                rec.desdoc := j.desdoc;
                rec.docume := j.docume;
                rec.refere01 := j.refere01;
                rec.femisi := j.femisi;
                rec.fvenci := j.fvenci;
                rec.fcance := j.fcance;
                rec.tipmon := j.tipmon;
                rec.importe := j.importe;
                rec.saldo := j.saldo;
                rec.saldosol := j.saldosol;
                rec.saldodol := j.saldodol1;
                rec.operac := j.operac;
                rec.tipcam := j.tipcam;
                rec.signo := j.signo;
                rec.codcli := j.codcli;
                rec.razonc := j.razonc;
                rec.moneda := j.moneda;
                rec.codubi := j.codubi;
                rec.desubi := j.desubi;
                rec.abrubi := j.abrubi;
                rec.codmot := j.codmot;
                rec.desmot := j.desmot;
                PIPE ROW ( rec );
            END LOOP;

        END IF;

    END LOOP;

END sp000_documentos_pendientes_ctaxcobrar_3;

/
