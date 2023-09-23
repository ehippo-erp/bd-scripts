--------------------------------------------------------
--  DDL for Function SP000_SACA_ESTADO_DE_CUENTA_CLIENTES
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_ESTADO_DE_CUENTA_CLIENTES" (
    pin_id_cia      IN NUMBER,---1
    pin_codcli      IN VARCHAR2,---2
    pin_swsolpend   IN VARCHAR2,---3
    pin_swincdocdes IN VARCHAR2,---4
    pin_subicacion  IN VARCHAR2,---5
    pin_numint      IN NUMBER,---6
    pin_swcancela   IN VARCHAR2,---7
    pin_swdcta106   IN VARCHAR2---8
) RETURN tbl_estado_de_cuenta_clientes
    PIPELINED
AS

    r_estado_de_cuenta_clientes rec_estado_de_cuenta_clientes := rec_estado_de_cuenta_clientes(NULL, NULL, NULL, NULL, NULL,
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
    v_libcanj                   VARCHAR2(3);
    v_librend                   VARCHAR2(3);
    v_librenc                   VARCHAR2(3);
    v_libanti                   VARCHAR2(3);
    v_esagenper                 VARCHAR2(3);
    CURSOR cur_select_estactacte IS
    SELECT DISTINCT
        numint,
        tipdoc,
        abrevi,
        desdoc,
        docume,
        refere01,
        refere02,
        femisi,
        fvenci,
        fcance,
        mora,
        tipmon,
        tpercepcion,
        tdocumento,
        saldo_ori,
        debe,
        haber,
        saldo,
        saldopercep,
        saldocalc,
        amorti,
        planilla,
        descri,
        libro,
        periodo,
        mes,
        secuencia,
        planiletra,
        codban,
        desban,
        numbco,
        tipcan,
        dtipcan,
        operac,
        protes,
        codubi,
        desubi,
        tipcam,
        signo,
        xlibro,
        xperiodo,
        xmes,
        xsecuencia,
        xplanilla,
        xdescri,
        xprotes,
        fonocli,
        limcre2,
        aval001,
        aval002,
        tippla,
        desmot,
        tercero,
        codterc,
        razoncterc,
        concep,
        numero_dcorcom,
        presen,
        serie,
        numero,
        codpag,
        despag,
        codven,
        estadolet,
        nomesp10,
        stresp10
    FROM
        TABLE ( sp000_saca_estado_de_cuenta_clientes_master(pin_id_cia, pin_codcli, pin_swsolpend, pin_swincdocdes, pin_subicacion,
                                                            pin_numint) );

    CURSOR cur_select_dcta101 IS
    SELECT
        CAST(d1.libro AS VARCHAR2(3))
        || '-'
        || CAST(d1.periodo AS VARCHAR2(4))
        || '-'
        || CAST(d1.mes AS VARCHAR2(2))
        || '-'
        || CAST(d1.secuencia AS VARCHAR2(20)) AS planilla,
--        CAST(d5.libro AS VARCHAR2(3))
--        || '-'
--        || CAST(d5.periodo AS VARCHAR2(4))
--        || '-'
--        || CAST(d5.mes AS VARCHAR2(2))
--        || '-'
--        || CAST(d5.secuencia AS VARCHAR2(20)) AS planilla,
        t.descri                              AS deslib,
        d1.libro,
        d1.periodo,
        d1.mes,
        d1.secuencia,
        CASE
            WHEN d2.femisi IS NOT NULL THEN
                d2.femisi
            ELSE
                p2.femisi
        END                                   AS femisi,
        CASE
            WHEN d2.femisi IS NOT NULL THEN
                d2.femisi
            ELSE
                p2.femisi
        END                                   AS fcance,
        d1.tipmon,
        CASE
            WHEN ( d1.dh = 'D' )
                 AND ( d1.tipcan < 50 ) THEN
                ( d1.importe )
            ELSE
                0
        END                                   AS debe,
        CASE
            WHEN ( d1.dh = 'H' )
                 AND ( d1.tipcan < 50 ) THEN
                ( d1.importe )
            ELSE
                0
        END                                   AS haber,
        d1.numbco,
        CAST(d1.tipcan AS NUMBER)             AS tipcan,
        CAST(tp.descri AS VARCHAR2(60))       AS dtipcan,
        d2.tippla,
        CASE
            WHEN d2.concep IS NOT NULL THEN
                d2.concep
            ELSE
                p2.concep
        END                                   AS concep,
        CASE
            WHEN ( ( d1.tcamb01 <> 0.0 )
                   AND ( d1.tcamb02 <> 0.0 ) ) THEN
                d1.tcamb01 / d1.tcamb02
            ELSE
                0.0
        END                                   AS tipcampla
    FROM
        dcta101 d1
        LEFT OUTER JOIN dcta102 d2 ON ( d2.id_cia = d1.id_cia )
                                      AND ( d2.libro = d1.libro )
                                      AND ( d2.periodo = d1.periodo )
                                      AND ( d2.mes = d1.mes )
                                      AND ( d2.secuencia = d1.secuencia )
        LEFT OUTER JOIN prov102 p2 ON ( p2.id_cia = d1.id_cia )
                                      AND ( p2.libro = d1.libro )
                                      AND ( p2.periodo = d1.periodo )
                                      AND ( p2.mes = d1.mes )
                                      AND ( p2.secuencia = d1.secuencia )
--        LEFT OUTER JOIN dcta105 d5 ON d5.id_cia = d1.id_cia
--                                      AND d5.libro = d1.libro
--                                      AND d5.periodo = d1.periodo
--                                      AND d5.mes = d1.mes
--                                      AND d5.secuencia = d1.secuencia
        LEFT OUTER JOIN prov102 p2 ON ( p2.id_cia = d1.id_cia )
                                      AND ( p2.libro = d1.libro )
                                      AND ( p2.periodo = d1.periodo )
                                      AND ( p2.mes = d1.mes )
                                      AND ( p2.secuencia = d1.secuencia )
        LEFT OUTER JOIN m_pago  tp ON ( tp.id_cia = pin_id_cia )
                                     AND ( tp.codigo = d1.tipcan )
        LEFT OUTER JOIN tlibro  t ON ( t.id_cia = pin_id_cia )
                                    AND ( t.codlib = d1.libro )
    WHERE
        ( d1.id_cia = pin_id_cia )
        AND ( d1.numint = pin_numint )
    ORDER BY
        d1.femisi,
        d1.numite;

    CURSOR cur_select_dcta106 IS
    SELECT
        d6.numint,
        d6.tipdoc,
        d.abrevi,
        d.descri AS desdoc,
        d6.docume,
        d6.refere01,
        d6.femisi,
        d6.fvenci,
        d6.fcance,
        d6.tipmon,
        d6.importe,
        d16.saldo,
        d6.operac,
        d6.tipcam,
        - 1      AS signo,
        m.desmot,
        d6.serie,
        d6.numero
    FROM
        TABLE ( sp000_saca_saldo_dcta106(pin_id_cia, 0) ) d16
        LEFT OUTER JOIN dcta100                                           d6 ON d6.id_cia = pin_id_cia
                                      AND d6.numint = d16.numint
        LEFT OUTER JOIN tdoccobranza                                      d ON d.id_cia = pin_id_cia
                                          AND d.tipdoc = d6.tipdoc
        LEFT OUTER JOIN documentos_cab                                    c ON c.id_cia = pin_id_cia
                                            AND c.numint = d6.numint
        LEFT OUTER JOIN motivos                                           m ON m.id_cia = pin_id_cia
                                     AND m.tipdoc = c.tipdoc
                                     AND m.codmot = c.codmot
                                     AND m.id = c.id
    WHERE
        d6.codcli = pin_codcli;

BEGIN
    BEGIN
        SELECT
            vstrg
        INTO v_libcanj
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 101;--- PLANILLA DE CANJES.

    EXCEPTION
        WHEN no_data_found THEN
            v_libcanj := '';
    END;

    BEGIN
        SELECT
            vstrg
        INTO v_librend
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 111;--- PLANILLA DE RENOVACIONES - DESCUENTO .

    EXCEPTION
        WHEN no_data_found THEN
            v_librend := '';
    END;

    BEGIN
        SELECT
            vstrg
        INTO v_librenc
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 113;--- PLANILLA DE RENOVACIONES - COBRANZAS.

    EXCEPTION
        WHEN no_data_found THEN
            v_librenc := '';
    END;

    BEGIN
        SELECT
            vstrg
        INTO v_esagenper
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 332;--- Es Agente de Percepción

    EXCEPTION
        WHEN no_data_found THEN
            v_esagenper := 'N';
    END;

    FOR registro IN cur_select_estactacte LOOP
        r_estado_de_cuenta_clientes.numint := registro.numint;
        r_estado_de_cuenta_clientes.tipdoc := registro.tipdoc;
        r_estado_de_cuenta_clientes.abrevi := registro.abrevi;
        r_estado_de_cuenta_clientes.desdoc := registro.desdoc;
        r_estado_de_cuenta_clientes.docume := registro.docume;
        r_estado_de_cuenta_clientes.serie := registro.serie;
        r_estado_de_cuenta_clientes.numero := registro.numero;
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
        r_estado_de_cuenta_clientes.codban := registro.codban;
        r_estado_de_cuenta_clientes.desban := registro.desban;
        r_estado_de_cuenta_clientes.numbco := registro.numbco;
        r_estado_de_cuenta_clientes.operac := registro.operac;
        r_estado_de_cuenta_clientes.protes := registro.protes;
        r_estado_de_cuenta_clientes.tipcam := registro.tipcam;
        r_estado_de_cuenta_clientes.signo := registro.signo;
        r_estado_de_cuenta_clientes.xlibro := registro.xlibro;
        r_estado_de_cuenta_clientes.xperiodo := registro.xperiodo;
        r_estado_de_cuenta_clientes.xmes := registro.xmes;
        r_estado_de_cuenta_clientes.xsecuencia := registro.xsecuencia;
        r_estado_de_cuenta_clientes.xplanilla := registro.xplanilla;
        r_estado_de_cuenta_clientes.xdescri := registro.xdescri;
        r_estado_de_cuenta_clientes.codubi := registro.codubi;
        r_estado_de_cuenta_clientes.desubi := registro.desubi;
        r_estado_de_cuenta_clientes.aval001 := registro.aval001;
        r_estado_de_cuenta_clientes.aval002 := registro.aval002;
        r_estado_de_cuenta_clientes.tercero := registro.tercero;
        r_estado_de_cuenta_clientes.codterc := registro.codterc;
        r_estado_de_cuenta_clientes.razoncterc := registro.razoncterc;
        r_estado_de_cuenta_clientes.estadolet := registro.estadolet;
        r_estado_de_cuenta_clientes.nomesp10 := registro.nomesp10;
        r_estado_de_cuenta_clientes.stresp10 := registro.stresp10;
        r_estado_de_cuenta_clientes.planiletra := registro.planiletra;
        r_estado_de_cuenta_clientes.desmot := registro.desmot;
        r_estado_de_cuenta_clientes.numero_dcorcom := registro.numero_dcorcom;
        r_estado_de_cuenta_clientes.presen := registro.presen;
        r_estado_de_cuenta_clientes.codpag := registro.codpag;
        r_estado_de_cuenta_clientes.despag := registro.despag;
        r_estado_de_cuenta_clientes.codven := registro.codven;
        r_estado_de_cuenta_clientes.saldopercep := registro.saldopercep;
        r_estado_de_cuenta_clientes.saldocalc := registro.saldocalc;
        r_estado_de_cuenta_clientes.amorti := registro.amorti;
        r_estado_de_cuenta_clientes.planilla := registro.planilla;
        r_estado_de_cuenta_clientes.descri := registro.desdoc;
        r_estado_de_cuenta_clientes.libro := registro.libro;
        r_estado_de_cuenta_clientes.periodo := registro.periodo;
        r_estado_de_cuenta_clientes.mes := registro.mes;
        r_estado_de_cuenta_clientes.secuencia := registro.secuencia;
        r_estado_de_cuenta_clientes.tipcan := registro.tipcan;
        r_estado_de_cuenta_clientes.dtipcan := registro.dtipcan;
        r_estado_de_cuenta_clientes.xprotes := registro.xprotes;
        r_estado_de_cuenta_clientes.fonocli := registro.fonocli;
        r_estado_de_cuenta_clientes.limcre2 := registro.limcre2;
        r_estado_de_cuenta_clientes.tippla := registro.tippla;
        r_estado_de_cuenta_clientes.concep := registro.concep;
        r_estado_de_cuenta_clientes.saldocalc := registro.tdocumento;
        IF ( registro.saldo_ori <> 0 ) THEN
            r_estado_de_cuenta_clientes.saldocalc := registro.saldo_ori;
        END IF;

        BEGIN
            SELECT
                m.desmot,
                doc.numero AS numero_dcorcom,
                c.presen,
                p.codpag,
                p.despag,
                c.codven
            INTO
                r_estado_de_cuenta_clientes.desmot,
                r_estado_de_cuenta_clientes.numero_dcorcom,
                r_estado_de_cuenta_clientes.presen,
                r_estado_de_cuenta_clientes.codpag,
                r_estado_de_cuenta_clientes.despag,
                r_estado_de_cuenta_clientes.codven
            FROM
                documentos_cab        c
                LEFT OUTER JOIN motivos               m ON m.id_cia = pin_id_cia
                                             AND m.tipdoc = c.tipdoc
                                             AND m.codmot = c.codmot
                                             AND m.id = c.id
                LEFT OUTER JOIN documentos_cab_ordcom doc ON doc.id_cia = pin_id_cia
                                                             AND doc.numint = c.numint
                LEFT OUTER JOIN c_pago                p ON p.id_cia = pin_id_cia
                                            AND p.codpag = c.codcpag
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numint = registro.numint;

        EXCEPTION
            WHEN no_data_found THEN
                r_estado_de_cuenta_clientes.desmot := '';
                r_estado_de_cuenta_clientes.numero_dcorcom := '';
                r_estado_de_cuenta_clientes.presen := '';
                r_estado_de_cuenta_clientes.codpag := 0;
                r_estado_de_cuenta_clientes.despag := '';
                r_estado_de_cuenta_clientes.codven := 0;
        END;

        IF ( registro.tipdoc = 41 ) THEN
            BEGIN
                SELECT
                    t.abrevi
                    || '-'
                    || d.serie
                    || '-'
                    || d.numero
                INTO r_estado_de_cuenta_clientes.refere01
                FROM
                    documentos_det_percepcion d
                    LEFT OUTER JOIN tdoccobranza              t ON t.id_cia = pin_id_cia
                                                      AND t.tipdoc = d.tdocum
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.numint = registro.numint
                FETCH FIRST 1 ROW ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    r_estado_de_cuenta_clientes.refere01 := '';
            END;
        END IF;---fin ( registro.tipdoc = 41 )

        r_estado_de_cuenta_clientes.saldopercep := registro.tpercepcion;
        IF (
            ( v_esagenper = 'S' )
            AND ( ( registro.tipdoc = 1 ) OR ( registro.tipdoc = 3 ) OR ( registro.tipdoc = 8 ) )
            AND ( registro.tpercepcion <> 0 )
        ) THEN
            BEGIN
                SELECT
                    SUM(d.percepcion)
                INTO r_estado_de_cuenta_clientes.saldopercep
                FROM
                    documentos_det_percepcion d
                    LEFT OUTER JOIN documentos_cab            c ON c.id_cia = pin_id_cia
                                                        AND c.numint = d.numint
                                                        AND c.situac = 'F'
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.numintfac = registro.numint;

            EXCEPTION
                WHEN no_data_found THEN
                    r_estado_de_cuenta_clientes.saldopercep := 0;
            END;

            IF ( r_estado_de_cuenta_clientes.saldopercep IS NULL ) THEN
                r_estado_de_cuenta_clientes.saldopercep := 0;
            END IF;

            r_estado_de_cuenta_clientes.saldopercep := registro.tpercepcion - r_estado_de_cuenta_clientes.saldopercep;
        END IF;---( ( registro.tipdoc = 1 ) OR ( registro.tipdoc = 3 ) OR ( registro.tipdoc = 8 ) ) AND ( registro.tpercepcion <> 0 )

        r_estado_de_cuenta_clientes.saldo := r_estado_de_cuenta_clientes.saldo + r_estado_de_cuenta_clientes.saldopercep;
        -- r_estado_de_cuenta_clientes.saldocalc := registro.tdocumento;

        IF ( ( pin_numint IS NOT NULL ) OR ( pin_swcancela = 'S' ) ) THEN
            BEGIN
                SELECT
                    d3.libro,
                    d3.periodo,
                    d3.mes,
                    d3.secuencia,
                    ( CAST(d3.libro AS VARCHAR(3))
                      || '-'
                      || CAST(d3.periodo AS VARCHAR(4))
                      || '-'
                      || CAST(d3.mes AS VARCHAR(2))
                      || '-'
                      || CAST(d3.secuencia AS VARCHAR(20)) ) AS planilla,
                    t.descri
                INTO
                    r_estado_de_cuenta_clientes.libro,
                    r_estado_de_cuenta_clientes.periodo,
                    r_estado_de_cuenta_clientes.mes,
                    r_estado_de_cuenta_clientes.secuencia,
                    r_estado_de_cuenta_clientes.planilla,
                    r_estado_de_cuenta_clientes.descri
                FROM
                    dcta103 d3
                    LEFT OUTER JOIN tlibro  t ON ( t.id_cia = pin_id_cia )
                                                AND ( t.codlib = d3.libro )
                WHERE
                    ( d3.id_cia = pin_id_cia )
                    AND ( d3.numint = pin_numint )
                    AND ( d3.situac <> 'J' )
                    AND ( ( d3.libro = v_libcanj )
                          OR ( d3.libro = v_librend )
                          OR ( d3.libro = v_librenc )
                          OR ( d3.libro = v_libanti ) )
                FETCH FIRST 1 ROW ONLY;
--                SELECT
--                    d5.libro,
--                    d5.periodo,
--                    d5.mes,
--                    d5.secuencia,
--                    ( CAST(d5.libro AS VARCHAR(3))
--                      || '-'
--                      || CAST(d5.periodo AS VARCHAR(4))
--                      || '-'
--                      || CAST(d5.mes AS VARCHAR(2))
--                      || '-'
--                      || CAST(d5.secuencia AS VARCHAR(20)) ) AS planilla,
--                    t.descri
--                INTO
--                    r_estado_de_cuenta_clientes.libro,
--                    r_estado_de_cuenta_clientes.periodo,
--                    r_estado_de_cuenta_clientes.mes,
--                    r_estado_de_cuenta_clientes.secuencia,
--                    r_estado_de_cuenta_clientes.planilla,
--                    r_estado_de_cuenta_clientes.descri
--                FROM
--                    dcta105 d5
--                    LEFT OUTER JOIN tlibro  t ON ( t.id_cia = d5.id_cia )
--                                                AND ( t.codlib = d5.libro )
--                WHERE
--                    ( d5.id_cia = pin_id_cia )
--                    AND ( d5.numint = pin_numint )
--                    AND ( d5.situac <> 'J' )
--                    AND ( ( d5.libro = v_libcanj )
--                          OR ( d5.libro = v_librend )
--                          OR ( d5.libro = v_librenc )
--                          OR ( d5.libro = v_libanti ) )
--                FETCH FIRST 1 ROW ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    r_estado_de_cuenta_clientes.libro := NULL;
                    r_estado_de_cuenta_clientes.periodo := NULL;
                    r_estado_de_cuenta_clientes.mes := NULL;
                    r_estado_de_cuenta_clientes.secuencia := NULL;
                    r_estado_de_cuenta_clientes.planilla := NULL;
                    r_estado_de_cuenta_clientes.descri := '';
            END;

            IF ( ( r_estado_de_cuenta_clientes.libro IS NULL ) OR ( r_estado_de_cuenta_clientes.periodo IS NULL ) OR ( r_estado_de_cuenta_clientes.mes
            IS NULL ) OR ( r_estado_de_cuenta_clientes.secuencia IS NULL ) OR ( r_estado_de_cuenta_clientes.planilla IS NULL ) ) THEN
                BEGIN
                    SELECT
                        d5.libro,
                        d5.periodo,
                        d5.mes,
                        d5.secuencia,
                        ( CAST(d5.libro AS VARCHAR(3))
                          || '-'
                          || CAST(d5.periodo AS VARCHAR(4))
                          || '-'
                          || CAST(d5.mes AS VARCHAR(2))
                          || '-'
                          || CAST(d5.secuencia AS VARCHAR(20)) ) AS planilla,
                        t.descri
                    INTO
                        r_estado_de_cuenta_clientes.libro,
                        r_estado_de_cuenta_clientes.periodo,
                        r_estado_de_cuenta_clientes.mes,
                        r_estado_de_cuenta_clientes.secuencia,
                        r_estado_de_cuenta_clientes.planilla,
                        r_estado_de_cuenta_clientes.descri
                    FROM
                        dcta105 d5
                        LEFT OUTER JOIN tlibro  t ON ( t.id_cia = pin_id_cia )
                                                    AND ( t.codlib = d5.libro )
                    WHERE
                        ( d5.id_cia = pin_id_cia )
                        AND ( d5.numint = pin_numint )
                        AND ( ( d5.libro = v_libcanj )
                              OR ( d5.libro = v_librend )
                              OR ( d5.libro = v_librenc )
                              OR ( d5.libro = v_libanti )
                              OR ( d5.libro = '24' ) )
                    FETCH FIRST 1 ROW ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        r_estado_de_cuenta_clientes.libro := NULL;
                        r_estado_de_cuenta_clientes.periodo := NULL;
                        r_estado_de_cuenta_clientes.mes := NULL;
                        r_estado_de_cuenta_clientes.secuencia := NULL;
                        r_estado_de_cuenta_clientes.planilla := NULL;
                        r_estado_de_cuenta_clientes.descri := '';
                END;

            END IF;
                    /*
                    fin IF ( ( r_estado_de_cuenta_clientes.libro IS NULL ) OR ( r_estado_de_cuenta_clientes.periodo IS NULL ) OR ( r_estado_de_cuenta_clientes.
                    mes IS NULL ) OR ( r_estado_de_cuenta_clientes.secuencia IS NULL ) OR ( r_estado_de_cuenta_clientes.planilla IS NULL ) ) THEN
                    */

            PIPE ROW ( r_estado_de_cuenta_clientes );----SUSPEND001
            r_estado_de_cuenta_clientes.codubi := 0;
            r_estado_de_cuenta_clientes.desubi := '';
            r_estado_de_cuenta_clientes.tpercepcion := 0;
            r_estado_de_cuenta_clientes.tdocumento := 0;
            r_estado_de_cuenta_clientes.xlibro := '';
            r_estado_de_cuenta_clientes.xperiodo := 0;
            r_estado_de_cuenta_clientes.xmes := 0;
            r_estado_de_cuenta_clientes.xsecuencia := 0;
            r_estado_de_cuenta_clientes.xprotes := 0;
            r_estado_de_cuenta_clientes.xplanilla := '';
            r_estado_de_cuenta_clientes.xdescri := '';
            r_estado_de_cuenta_clientes.planilla := '';
            r_estado_de_cuenta_clientes.descri := '';
            r_estado_de_cuenta_clientes.libro := '';
            r_estado_de_cuenta_clientes.periodo := 0;
            r_estado_de_cuenta_clientes.mes := 0;
            r_estado_de_cuenta_clientes.secuencia := 0;
            r_estado_de_cuenta_clientes.planiletra := '';
            r_estado_de_cuenta_clientes.tipcan := 0;
            r_estado_de_cuenta_clientes.dtipcan := '';
            r_estado_de_cuenta_clientes.fvenci := NULL;
            r_estado_de_cuenta_clientes.tippla := 0;
            r_estado_de_cuenta_clientes.concep := '';
            r_estado_de_cuenta_clientes.tipcampla := NULL;
            IF ( ( pin_swsolpend IS NULL ) OR ( upper(pin_swsolpend) = 'N' ) ) THEN
                FOR registro2 IN cur_select_dcta101 LOOP
                    r_estado_de_cuenta_clientes.planilla := registro2.planilla;
                    r_estado_de_cuenta_clientes.descri := registro2.deslib;
                    r_estado_de_cuenta_clientes.libro := registro2.libro;
                    r_estado_de_cuenta_clientes.periodo := registro2.periodo;
                    r_estado_de_cuenta_clientes.mes := registro2.mes;
                    r_estado_de_cuenta_clientes.secuencia := registro2.secuencia;
                    r_estado_de_cuenta_clientes.femisi := registro2.femisi;
                    r_estado_de_cuenta_clientes.fcance := registro2.fcance;
                    r_estado_de_cuenta_clientes.tipmon := registro2.tipmon;
                    r_estado_de_cuenta_clientes.debe := registro2.debe;
                    r_estado_de_cuenta_clientes.haber := registro2.haber;
                    r_estado_de_cuenta_clientes.numbco := registro2.numbco;
                    r_estado_de_cuenta_clientes.tipcan := registro2.tipcan;
                    r_estado_de_cuenta_clientes.dtipcan := registro2.dtipcan;
                    r_estado_de_cuenta_clientes.tippla := registro2.tippla;
                    r_estado_de_cuenta_clientes.concep := registro2.concep;
                    r_estado_de_cuenta_clientes.tipcampla := registro2.tipcampla;
                    r_estado_de_cuenta_clientes.amorti := registro2.debe - registro2.haber;
                    r_estado_de_cuenta_clientes.saldocalc := r_estado_de_cuenta_clientes.saldocalc - abs(r_estado_de_cuenta_clientes.amorti
                    );
                    IF ( r_estado_de_cuenta_clientes.tippla = 100 ) THEN
                        BEGIN
                            SELECT
                                d4.codban,
                                b.descri AS desban,
                                d4.op
                            INTO
                                r_estado_de_cuenta_clientes.codban,
                                r_estado_de_cuenta_clientes.desban,
                                r_estado_de_cuenta_clientes.numbco
                            FROM
                                dcta104 d4
                                LEFT OUTER JOIN tbancos b ON b.id_cia = pin_id_cia
                                                             AND b.codban = d4.codban
                            WHERE
                                ( d4.id_cia = pin_id_cia )
                                AND d4.periodo = r_estado_de_cuenta_clientes.periodo
                                AND d4.mes = r_estado_de_cuenta_clientes.mes
                                AND d4.libro = r_estado_de_cuenta_clientes.libro
                                AND d4.secuencia = r_estado_de_cuenta_clientes.secuencia
                            ORDER BY
                                d4.item
                            FETCH FIRST 1 ROW ONLY;

                        EXCEPTION
                            WHEN no_data_found THEN
                                r_estado_de_cuenta_clientes.codban := 0;
                                r_estado_de_cuenta_clientes.desban := '';
                                r_estado_de_cuenta_clientes.numbco := '';
                        END;
                    END IF;--(  = 100 ) 

                    PIPE ROW ( r_estado_de_cuenta_clientes );----SUSPEND 002
                END LOOP;
            END IF; ----( upper(pin_swsolpend) = 'N' )

        ELSE
            PIPE ROW ( r_estado_de_cuenta_clientes );----SUSPEND 003
            r_estado_de_cuenta_clientes.codubi := 0;
            r_estado_de_cuenta_clientes.desubi := '';
            r_estado_de_cuenta_clientes.tpercepcion := 0;
            r_estado_de_cuenta_clientes.tdocumento := 0;
            r_estado_de_cuenta_clientes.xlibro := '';
            r_estado_de_cuenta_clientes.xperiodo := 0;
            r_estado_de_cuenta_clientes.xmes := 0;
            r_estado_de_cuenta_clientes.xsecuencia := 0;
            r_estado_de_cuenta_clientes.xprotes := 0;
            r_estado_de_cuenta_clientes.xplanilla := '';
            r_estado_de_cuenta_clientes.xdescri := '';
            r_estado_de_cuenta_clientes.planilla := '';
            r_estado_de_cuenta_clientes.descri := '';
            r_estado_de_cuenta_clientes.libro := '';
            r_estado_de_cuenta_clientes.periodo := 0;
            r_estado_de_cuenta_clientes.mes := 0;
            r_estado_de_cuenta_clientes.secuencia := 0;
            r_estado_de_cuenta_clientes.planiletra := '';
            r_estado_de_cuenta_clientes.tipcan := 0;
            r_estado_de_cuenta_clientes.dtipcan := '';
            r_estado_de_cuenta_clientes.fvenci := NULL;
            r_estado_de_cuenta_clientes.tippla := 0;
            r_estado_de_cuenta_clientes.concep := '';
            r_estado_de_cuenta_clientes.tipcampla := NULL;
        END IF;--------(WSWCANCELA='S')

    END LOOP;

    r_estado_de_cuenta_clientes.codubi := 0;
    r_estado_de_cuenta_clientes.desubi := '';
    r_estado_de_cuenta_clientes.tpercepcion := 0;
    r_estado_de_cuenta_clientes.tdocumento := 0;
    r_estado_de_cuenta_clientes.xlibro := '';
    r_estado_de_cuenta_clientes.xperiodo := 0;
    r_estado_de_cuenta_clientes.xmes := 0;
    r_estado_de_cuenta_clientes.xsecuencia := 0;
    r_estado_de_cuenta_clientes.xprotes := 0;
    r_estado_de_cuenta_clientes.xplanilla := '';
    r_estado_de_cuenta_clientes.xdescri := '';
    r_estado_de_cuenta_clientes.planilla := '';
    r_estado_de_cuenta_clientes.descri := '';
    r_estado_de_cuenta_clientes.libro := '';
    r_estado_de_cuenta_clientes.periodo := 0;
    r_estado_de_cuenta_clientes.mes := 0;
    r_estado_de_cuenta_clientes.secuencia := 0;
    r_estado_de_cuenta_clientes.planiletra := '';
    r_estado_de_cuenta_clientes.tipcan := 0;
    r_estado_de_cuenta_clientes.dtipcan := '';
    r_estado_de_cuenta_clientes.fvenci := NULL;
    r_estado_de_cuenta_clientes.tippla := 0;
    r_estado_de_cuenta_clientes.concep := '';
    r_estado_de_cuenta_clientes.aval001 := '';
    r_estado_de_cuenta_clientes.aval002 := '';
    r_estado_de_cuenta_clientes.mora := 0;
    r_estado_de_cuenta_clientes.codban := 0;
    r_estado_de_cuenta_clientes.desban := '';
    r_estado_de_cuenta_clientes.numbco := '';
    r_estado_de_cuenta_clientes.protes := 0;
    IF ( upper(pin_swdcta106) = 'S' ) THEN
        FOR registro3 IN cur_select_dcta106 LOOP
            r_estado_de_cuenta_clientes.numint := registro3.numint;
            r_estado_de_cuenta_clientes.tipdoc := registro3.tipdoc;
            r_estado_de_cuenta_clientes.abrevi := registro3.abrevi;
            r_estado_de_cuenta_clientes.desdoc := registro3.desdoc
                                                  || ' - '
                                                  || 'ANTICIPO';
            r_estado_de_cuenta_clientes.docume := registro3.docume;
            r_estado_de_cuenta_clientes.refere01 := registro3.refere01;
            r_estado_de_cuenta_clientes.femisi := registro3.femisi;
            r_estado_de_cuenta_clientes.fvenci := registro3.fvenci;
            r_estado_de_cuenta_clientes.fcance := registro3.fcance;
            r_estado_de_cuenta_clientes.tipmon := registro3.tipmon;
            r_estado_de_cuenta_clientes.tdocumento := registro3.importe;
            r_estado_de_cuenta_clientes.saldo := registro3.saldo;
            r_estado_de_cuenta_clientes.operac := registro3.operac;
            r_estado_de_cuenta_clientes.tipcam := registro3.tipcam;
            r_estado_de_cuenta_clientes.signo := registro3.signo;
            r_estado_de_cuenta_clientes.desmot := registro3.desmot;
            r_estado_de_cuenta_clientes.serie := registro3.signo;
            r_estado_de_cuenta_clientes.numero := registro3.numero;
            IF ( registro3.saldo <> 0 ) THEN
                PIPE ROW ( r_estado_de_cuenta_clientes );----SUSPEND 003     
            END IF;

        END LOOP;
    END IF;

END sp000_saca_estado_de_cuenta_clientes;

/
