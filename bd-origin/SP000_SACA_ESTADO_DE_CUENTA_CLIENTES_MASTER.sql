--------------------------------------------------------
--  DDL for Function SP000_SACA_ESTADO_DE_CUENTA_CLIENTES_MASTER
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_ESTADO_DE_CUENTA_CLIENTES_MASTER" (
    pin_id_cia       IN  NUMBER,---1
    pin_codcli       IN  VARCHAR2,---2
    pin_swsolpend    IN  VARCHAR2,---3
    pin_swincdocdes  IN  VARCHAR2,---4
    pin_subicacion   IN  VARCHAR2,---5
    pin_numint       IN  NUMBER---6
) RETURN tbl_estado_de_cuenta_clientes
    PIPELINED
AS

    r_estado_de_cuenta_clientes  rec_estado_de_cuenta_clientes := rec_estado_de_cuenta_clientes(NULL, NULL, NULL, NULL, NULL,
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
                              NULL, NULL);
    v_libldes                    VARCHAR(3);
    v_fonocli                    VARCHAR(50);
    v_limcre2                    NUMERIC(9, 2);
    CURSOR cur_select_dcta100 (
        p_libldes VARCHAR2
    ) IS
    SELECT
        d.numint,
        d.tipdoc,
        td.abrevi,
        td.descri     AS desdoc,
        d.docume,
        d.serie,
        d.numero,
        d.refere01,
        d.refere02,
        d.femisi,
        d.fvenci,
        d.fcance,
        NVL((trunc(CASE
                WHEN d.saldo <> 0 THEN
                    sysdate
                ELSE
                    d.fcance
            END)
        - trunc(d.fvenci)),0) AS mora,
        d.tipmon,
        CASE
            WHEN dc.vreal IS NULL THEN
                0
            ELSE
                dc.vreal
        END AS tpercepcion,
        d.importe     AS tdocumento,
        CASE
            WHEN o.saldo IS NULL THEN
                0
            ELSE
                o.saldo
        END AS saldo_ori,
        CASE
            WHEN d.dh = 'D' THEN
                ( d.importe )
            ELSE
                0
        END AS debe,
        CASE
            WHEN d.dh = 'H' THEN
                ( d.importe )
            ELSE
                0
        END AS haber,
        d.saldo,
        d.codban,
        CASE
            WHEN d.tipdoc = 6 THEN
                ef.descri
            ELSE
                CASE
                    WHEN tb.abrevi IS NOT NULL
                         AND length(tb.abrevi) > 0 THEN
                        tb.abrevi
                    ELSE
                        tb.descri
                END
        END AS desban,
        d.numbco,
        d.operac,
        d.protes,
        d.tipcam,
        td.signo,
        d.xlibro,
        d.xperiodo,
        d.xmes,
        d.xsecuencia,
        d.xprotesto,
        CAST(d.xlibro AS VARCHAR2(3))
        || '-'
        || CAST(d.xperiodo AS VARCHAR2(4))
        || '-'
        || CAST(d.xmes AS VARCHAR2(2))
        || '-'
        || CAST(d.xsecuencia AS VARCHAR2(10)) AS xplanilla,
        tx.descri,
        d.codubi,
        u.desubi,
        a1.razonc     AS aval001,
        a2.razonc     AS aval002,
        d.tercero,
        d.codterc,
        t1.razonc     AS razoncterc,
        CASE
            WHEN ( d.tipdoc = 5
                   AND d5.libro = '35' ) THEN
                'Refinanciada'
            ELSE
                CASE
                    WHEN ( d.tipdoc = 5
                           AND d5.libro IN (
                        '12',
                        '31'
                    ) ) THEN
                        'Renovada'
                    ELSE
                        ''
                END
        END AS estadolet,
        e10.descri    AS nomesp10,
        ce10.vstrg    AS stresp10,
        CASE
            WHEN d.tipdoc = 5 THEN
                d5.libro
                || '-'
                || CAST(d5.periodo AS VARCHAR(10))
                || '-'
                || CAST(d5.mes AS VARCHAR(10))
                || '-'
                || CAST(d5.secuencia AS VARCHAR(20))
            ELSE
                NULL
        END AS planiletra
    FROM
        dcta100                    d
        LEFT OUTER JOIN dcta100_ori                o ON ( o.id_cia = pin_id_cia )
                                         AND o.numint = d.numint
        LEFT OUTER JOIN documentos_cab_clase       dc ON ( dc.id_cia = pin_id_cia )
                                                   AND dc.numint = d.numint
                                                   AND dc.clase = 4 /* SACA EL TOTAL DE PERPECTION */
        LEFT OUTER JOIN tdoccobranza               td ON ( td.id_cia = pin_id_cia )
                                           AND td.tipdoc = d.tipdoc
        LEFT OUTER JOIN dcta103                    d9 ON ( d9.id_cia = pin_id_cia )
                                      AND d9.numint = d.numint
                                      AND d9.situac = 'B'
                                      AND d9.libro = p_libldes
        LEFT OUTER JOIN tlibro                     tx ON ( tx.id_cia = pin_id_cia )
                                     AND tx.codlib = d.xlibro
        LEFT OUTER JOIN tbancos                    tb ON ( tb.id_cia = pin_id_cia )
                                      AND tb.codban = CAST(d.codban AS VARCHAR(3))
        LEFT OUTER JOIN e_financiera               ef ON ( ef.id_cia = pin_id_cia )
                                           AND ef.codigo = d.codban
        LEFT OUTER JOIN ubicacion                  u ON ( u.id_cia = pin_id_cia )
                                       AND u.codubi = d.codubi
        LEFT OUTER JOIN dcta105                    d5 ON ( d5.id_cia = pin_id_cia )
                                      AND ( d5.numint = d.numint )
        LEFT OUTER JOIN cliente                    a1 ON ( a1.id_cia = pin_id_cia )
                                      AND ( a1.codcli = d5.codaval01 )
        LEFT OUTER JOIN cliente                    a2 ON ( a2.id_cia = pin_id_cia )
                                      AND ( a2.codcli = d5.codaval02 )
        LEFT OUTER JOIN cliente                    t1 ON ( t1.id_cia = pin_id_cia )
                                      AND ( t1.codcli = d.codterc )
        LEFT OUTER JOIN especificaciones_clientes  e10 ON ( e10.id_cia = pin_id_cia )
                                                         AND e10.tipcli = 'A'
                                                         AND e10.codesp = 10
        LEFT OUTER JOIN clientes_especificacion    ce10 ON ( ce10.id_cia = pin_id_cia )
                                                        AND ce10.tipcli = 'A'
                                                        AND ce10.codcli = d.codcli
                                                        AND ce10.codesp = 10
    WHERE
        ( d.id_cia = pin_id_cia )
        AND ( pin_numint IS NULL
              OR d.numint = pin_numint )
        AND ( d.codcli = pin_codcli )
        AND ( ( ( ( pin_swincdocdes IS NULL )
                  OR ( pin_swincdocdes = 'N' ) )
                AND ( ( abs(d.operac) <= 1 )
                      OR ( d.operac IN (
            6,
            7,
            8
        ) ) ) )
              OR ( ( ( pin_swincdocdes = 'S' ) )
                   AND ( ( abs(d.operac) <= 2 )
                         OR ( d.operac IN (
            6,
            7,
            8
        ) ) ) ) )
        AND ( ( ( pin_swsolpend IS NULL )
                OR ( pin_swsolpend = 'N' ) )
              OR ( ( pin_swsolpend = 'S' )
                   AND ( d.saldo <> 0 )
                   AND ( ( ( d9.libro IS NULL )
                           OR ( ( d.xlibro <> ''
                                  AND d.xlibro IS NOT NULL )
                                AND ( d.xperiodo <> 0
                                      AND d.xperiodo IS NOT NULL )
                                AND ( d.xmes <> 0
                                      AND d.xmes IS NOT NULL )
                                AND ( d.xsecuencia <> 0
                                      AND d.xsecuencia IS NOT NULL ) ) )
                         OR ( ( ( pin_swincdocdes IS NULL )
                                OR ( pin_swincdocdes = 'N' ) )
                              OR ( ( pin_swincdocdes = 'S' )
                                   AND ( d9.libro = p_libldes ) ) ) ) ) )
        AND ( ( pin_subicacion IS NULL )
              OR ( length(pin_subicacion) = 0 )
              OR ( ','
                   || pin_subicacion
                   || ',' LIKE '%,'
                               || d.codubi
                               || ',%' ) );

BEGIN
    BEGIN
        SELECT
            vstrg
        INTO v_libldes
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 107;--- PLANILLA DE LETRAS EN DESCUENTO.

    EXCEPTION
        WHEN no_data_found THEN
            v_libldes := '';
    END;

    BEGIN
        SELECT
            limcre2,
            telefono
        INTO
            v_limcre2,
            v_fonocli
        FROM
            cliente
        WHERE
                id_cia = pin_id_cia
            AND codcli = pin_codcli;

    EXCEPTION
        WHEN no_data_found THEN
            v_limcre2 := 0;
            v_fonocli := '';
    END;

    FOR registro IN cur_select_dcta100(v_libldes) LOOP
        r_estado_de_cuenta_clientes.numint := registro.numint;
        r_estado_de_cuenta_clientes.tipdoc := registro.tipdoc;
        r_estado_de_cuenta_clientes.abrevi := registro.abrevi;
        r_estado_de_cuenta_clientes.desdoc := registro.desdoc;
        r_estado_de_cuenta_clientes.docume := registro.docume;
        r_estado_de_cuenta_clientes.refere01 := registro.refere01;
        r_estado_de_cuenta_clientes.refere02 := registro.refere02;
        r_estado_de_cuenta_clientes.femisi := registro.femisi;
        r_estado_de_cuenta_clientes.fvenci := registro.fvenci;
        r_estado_de_cuenta_clientes.fcance := registro.fcance;
        r_estado_de_cuenta_clientes.mora := registro.mora;
        r_estado_de_cuenta_clientes.tipmon := registro.tipmon;
        r_estado_de_cuenta_clientes.tpercepcion := registro.tpercepcion;
        r_estado_de_cuenta_clientes.tdocumento := registro.tdocumento;
        r_estado_de_cuenta_clientes.saldo_ori := registro.saldo_ori;
        r_estado_de_cuenta_clientes.debe := registro.debe;
        r_estado_de_cuenta_clientes.haber := registro.haber;
        r_estado_de_cuenta_clientes.saldo := registro.saldo;
        r_estado_de_cuenta_clientes.saldopercep := 0;
        r_estado_de_cuenta_clientes.saldocalc := 0;
        r_estado_de_cuenta_clientes.amorti := 0;
        r_estado_de_cuenta_clientes.planilla := '';
        r_estado_de_cuenta_clientes.descri := registro.desdoc;
        r_estado_de_cuenta_clientes.libro := '';
        r_estado_de_cuenta_clientes.periodo := 0;
        r_estado_de_cuenta_clientes.mes := 0;
        r_estado_de_cuenta_clientes.secuencia := 0;
        r_estado_de_cuenta_clientes.planiletra := registro.planiletra;
        r_estado_de_cuenta_clientes.codban := registro.codban;
        r_estado_de_cuenta_clientes.desban := registro.desban;
        r_estado_de_cuenta_clientes.numbco := registro.numbco;
        r_estado_de_cuenta_clientes.tipcan := 0;
        r_estado_de_cuenta_clientes.dtipcan := '';
        r_estado_de_cuenta_clientes.operac := registro.operac;
        r_estado_de_cuenta_clientes.protes := registro.protes;
        r_estado_de_cuenta_clientes.codubi := registro.codubi;
        r_estado_de_cuenta_clientes.desubi := registro.desubi;
        r_estado_de_cuenta_clientes.tipcam := registro.tipcam;
        r_estado_de_cuenta_clientes.signo := registro.signo;
        r_estado_de_cuenta_clientes.xlibro := registro.xlibro;
        r_estado_de_cuenta_clientes.xperiodo := registro.xperiodo;
        r_estado_de_cuenta_clientes.xmes := registro.xmes;
        r_estado_de_cuenta_clientes.xsecuencia := registro.xsecuencia;
        r_estado_de_cuenta_clientes.xplanilla := registro.xsecuencia;
        r_estado_de_cuenta_clientes.xdescri := '';
        r_estado_de_cuenta_clientes.xprotes := 0;
        r_estado_de_cuenta_clientes.fonocli := v_fonocli;
        r_estado_de_cuenta_clientes.limcre2 := v_limcre2;
        r_estado_de_cuenta_clientes.aval001 := registro.aval001;
        r_estado_de_cuenta_clientes.aval002 := registro.aval002;
        r_estado_de_cuenta_clientes.tippla := 0;
        r_estado_de_cuenta_clientes.desmot := '';
        r_estado_de_cuenta_clientes.tercero := registro.tercero;
        r_estado_de_cuenta_clientes.codterc := registro.codterc;
        r_estado_de_cuenta_clientes.razoncterc := registro.razoncterc;
        r_estado_de_cuenta_clientes.concep := '';
        r_estado_de_cuenta_clientes.numero_dcorcom := '';
        r_estado_de_cuenta_clientes.presen := '';
        r_estado_de_cuenta_clientes.serie := registro.serie;
        r_estado_de_cuenta_clientes.numero := registro.numero;
        r_estado_de_cuenta_clientes.codpag := 0;
        r_estado_de_cuenta_clientes.despag := '';
        r_estado_de_cuenta_clientes.codven := 0;
        r_estado_de_cuenta_clientes.estadolet := registro.estadolet;
        r_estado_de_cuenta_clientes.nomesp10 := registro.nomesp10;
        r_estado_de_cuenta_clientes.stresp10 := registro.stresp10;
        r_estado_de_cuenta_clientes.tipcampla := 0;
        PIPE ROW ( r_estado_de_cuenta_clientes );
    END LOOP;

END sp000_saca_estado_de_cuenta_clientes_master;

/
