--------------------------------------------------------
--  DDL for Function SP000_SACA_ESTADO_DE_CUENTA_PROVEEDORES
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_ESTADO_DE_CUENTA_PROVEEDORES" (
    pin_id_cia       IN  NUMBER,---1
    pin_codpro       IN  VARCHAR2,---2
    pin_swsolpend    IN  VARCHAR2,---3
    pin_swincdocdes  IN  VARCHAR2,---4
    pin_tipo         IN  NUMBER,---5
    pin_docu         IN  NUMBER,---6
    pin_swcancela    IN  VARCHAR2
) RETURN tbl_estado_de_cuenta_proveedores
    PIPELINED
AS

    regprov    rec_estado_de_cuenta_proveedores := rec_estado_de_cuenta_proveedores(NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL);
    v_libcanj  VARCHAR2(3);
    v_librend  VARCHAR2(3);
    v_librenc  VARCHAR2(3);
    v_libanti  VARCHAR2(3);
    v_libldes  VARCHAR2(3);
    CURSOR cur_select_prov100 (
        plibdes VARCHAR2
    ) IS
    SELECT
        d.tipo,
        d.docu,
        d.tipdoc,
        td.abrevi,
        td.descri    AS desdoc,
        d.docume,
        d.refere01,
        d.refere02,
        d.femisi,
        d.fvenci,
        d.fcance,
        trunc(
            CASE
                WHEN d.saldo <> 0 THEN
                    current_date
                ELSE
                    d.fcance
            END
        ) - trunc(d.fvenci) AS mora,
        d.tipmon,
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
        d.dh,
        d.importe    AS tdocumento,
        d.saldo,
        d.codban,
        CASE
            WHEN NOT ( ( d.numbco IS NULL )
                       OR ( d.numbco = '' ) ) THEN
                CASE
                    WHEN d.operac = 0 THEN
                        ef.descri
                    ELSE
                        tb.descri
                END
            ELSE
                ''
        END AS desban,
        d.numbco,
        d.operac,
        d.protes,
        d.tipcam,
        td.signo,
        cr.ddetrac,
        cr.fdetrac,
        cr.impdetrac,
        d.codclir,
        cc.razonc    AS desclir,
        d.fvenci2,
        CAST(d5.libro AS VARCHAR2(3))
        || '-'
        || CAST(d5.periodo AS VARCHAR2(4))
        || '-'
        || CAST(d5.mes AS VARCHAR2(2))
        || '-'
        || CAST(d5.secuencia AS VARCHAR2(4)) AS planilla
    FROM
        prov100       d
        LEFT OUTER JOIN compr010      cr ON ( cr.id_cia = d.id_cia )
                                       AND cr.tipo = d.tipo
                                       AND cr.docume = d.docu
        LEFT OUTER JOIN tdocume       td ON ( td.id_cia = d.id_cia )
                                      AND td.codigo = d.tipdoc
        LEFT OUTER JOIN prov105       d5 ON d5.id_cia=d.id_cia 
                                            AND d5.tipo=d.tipo
                                            AND d5.docu=d.docu
                                            AND d5.situac='B'
        LEFT OUTER JOIN prov103       d9 ON ( d9.id_cia = d.id_cia )
                                      AND d9.tipo = d.tipo
                                      AND d9.docu = d.docu
                                      AND d9.situac = 'B'
                                      AND d9.libro = plibdes
        LEFT OUTER JOIN tbancos       tb ON ( tb.id_cia = d.id_cia )
                                      AND tb.codban = CAST(d.codban AS VARCHAR2(3))
        LEFT OUTER JOIN e_financiera  ef ON ( ef.id_cia = d.id_cia )
                                           AND ef.codigo = d.codban
        LEFT OUTER JOIN cliente       cc ON ( cc.id_cia = d.id_cia )
                                      AND cc.codcli = d.codclir
    WHERE
        ( d.id_cia = pin_id_cia )
        AND ( ( ( pin_tipo IS NULL )
                AND ( pin_docu IS NULL ) )
              OR ( ( d.tipo = pin_tipo )
                   AND ( d.docu = pin_docu ) ) )
        AND ( d.codcli = pin_codpro )
        AND ( ( ( pin_swsolpend IS NULL )
                OR ( pin_swsolpend = 'N' ) )
              OR ( ( pin_swsolpend = 'S' )
                   AND ( d.saldo <> 0 )
                   AND ( ( ( ( pin_swincdocdes IS NULL )
                             OR ( pin_swincdocdes = 'N' ) )
                           AND ( abs(d.operac) <= 1 ) )
                         OR ( ( ( pin_swincdocdes = 'S' ) )
                              AND ( abs(d.operac) <= 2 ) ) )
                   AND ( ( ( d9.libro IS NULL )
                           OR ( ( d.xlibro <> ''
                                  AND d.xlibro IS NOT NULL )
                                AND ( d.xperiodo <> 0
                                      AND d.xperiodo IS NOT NULL )
                                AND ( d.xmes <> 0
                                      AND d.xmes IS NOT NULL )
                                AND ( d.xsecuencia <> 0
                                      AND d.xsecuencia IS NOT NULL ) ) )
                         OR ( ( pin_swincdocdes IS NOT NULL )
                              AND ( pin_swincdocdes = 'S' )
                              AND ( d9.libro = plibdes ) ) ) ) );

    CURSOR cur_select_prov101 (
        ptipo  INTEGER,
        pdocu  INTEGER
    ) IS
    SELECT
        CAST(d1.libro AS VARCHAR2(3))
        || '-'
        || CAST(d1.periodo AS VARCHAR2(4))
        || '-'
        || CAST(d1.mes AS VARCHAR2(2))
        || '-'
        || CAST(d1.secuencia AS VARCHAR2(4)) AS planilla,
        t.descri,
        d1.libro,
        d1.periodo,
        d1.mes,
        d1.secuencia,
        d3.femisi,
        d3.femisi                                AS fvenci,
        d3.femisi                                AS fcance,
        d1.tipmon,
        CASE
            WHEN d1.dh = 'D' THEN
                ( d1.importe )
            ELSE
                0
        END AS debe,
        CASE
            WHEN d1.dh = 'H' THEN
                ( d1.importe )
            ELSE
                0
        END AS haber,
        d1.numbco,
        d13.libro
        || '-'
        || CAST(d13.periodo AS VARCHAR2(10))
        || '-'
        || CAST(d13.mes AS VARCHAR2(10))
        || '-'
        || CAST(d13.secuencia AS VARCHAR2(10)) AS planiletra,
        CAST(d1.tipcan AS SMALLINT)              AS tipcan,
        CAST(tp.descri AS VARCHAR2(60))          AS dtipcan,
        cr.ddetrac,
        cr.fdetrac,
        cr.impdetrac,
        d3.tippla,
        d1.refere01,
        d1.refere02
    FROM
        prov101   d1
        LEFT OUTER JOIN compr010  cr ON ( cr.id_cia = d1.id_cia )
                                       AND cr.tipo = d1.tipo
                                       AND cr.docume = d1.docu
        LEFT OUTER JOIN prov102   d3 ON ( d3.id_cia = d1.id_cia )
                                      AND ( d3.libro = d1.libro )
                                      AND ( d3.periodo = d1.periodo )
                                      AND ( d3.mes = d1.mes )
                                      AND ( d3.secuencia = d1.secuencia )
        LEFT OUTER JOIN m_pago    tp ON ( tp.id_cia = d1.id_cia )
                                     AND ( tp.codigo = d1.tipcan )
        LEFT OUTER JOIN tlibro    t ON ( t.id_cia = d1.id_cia )
                                    AND ( t.codlib = d1.libro )
        LEFT OUTER JOIN prov103   d13 ON ( d13.id_cia = d1.id_cia )
                                       AND ( d13.tipo = d1.tipo )
                                       AND ( d13.docu = d1.docu )
                                       AND ( d13.situac <> 'J' )
                                       AND ( d13.libro = d1.libro )
                                       AND ( d13.periodo = d1.periodo )
                                       AND ( d13.mes = d1.mes )
                                       AND ( d13.secuencia = d1.secuencia )
    WHERE
        ( d1.id_cia = pin_id_cia )
        AND ( d1.tipo = ptipo )
        AND ( d1.docu = pdocu )
        AND ( NOT ( ( d1.tipcan >= 50 )
                    AND ( d1.tipcan <= 60 ) ) )
    ORDER BY
        d1.femisi,
        d1.numite;

BEGIN
    BEGIN
        SELECT
            vstrg
        INTO v_libcanj
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 121;-- PLANILLA DE CANJES.

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
            AND codfac = 131;--- PLANILLA DE RENOVACIONES - DESCUENTO .

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
            AND codfac = 133;--- PLANILLA DE RENOVACIONES - COBRANZAS.

    EXCEPTION
        WHEN no_data_found THEN
            v_librenc := '';
    END;

    BEGIN
        SELECT
            vstrg
        INTO v_libldes
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 127;--- PLANILLA DE LETRAS EN DESCUENTO.

    EXCEPTION
        WHEN no_data_found THEN
            v_libldes := '';
    END;

    regprov.tipo := 0;
    regprov.docu := 0;
    regprov.tipdoc := '0';
    regprov.abrevi := '';
    regprov.desdoc := '';
    regprov.docume := '';
    regprov.refere01 := '';
    regprov.refere02 := '';
    regprov.femisi := NULL;
    regprov.fvenci := NULL;
    regprov.fcance := NULL;
    regprov.mora := 0;
    regprov.tipmon := '';
    regprov.debe := 0;
    regprov.haber := 0;
    regprov.dh := '';
    regprov.tdocumento := 0;
    regprov.saldo := 0;
    regprov.planilla := '';
    regprov.descri := '';
    regprov.libro := '';
    regprov.periodo := 0;
    regprov.mes := 0;
    regprov.secuencia := 0;
    regprov.planiletra := '';
    regprov.codban := 0;
    regprov.desban := '';
    regprov.numbco := '';
    regprov.tipcan := 0;
    regprov.dtipcan := '';
    regprov.operac := 0;
    regprov.protes := 0;
    regprov.tipcam := 0;
    regprov.signo := 0;
    regprov.ddetrac := '';
    regprov.fdetrac := NULL;
    regprov.impdetrac := 0;
    regprov.fvenci2 := NULL;
    regprov.amorti := 0;
    regprov.saldocalc := 0;


    FOR regprov100 IN cur_select_prov100(v_libldes) LOOP
        regprov.tipo := regprov100.tipo;
        regprov.docu := regprov100.docu;
        regprov.tipdoc := regprov100.tipdoc;
        regprov.abrevi := regprov100.abrevi;
        regprov.desdoc := regprov100.desdoc;
        regprov.docume := regprov100.docume;
        regprov.refere01 := regprov100.refere01;
        regprov.refere02 := regprov100.refere02;
        regprov.femisi := regprov100.femisi;
        regprov.fvenci := regprov100.fvenci;
        regprov.fcance := regprov100.fcance;
        regprov.mora := regprov100.mora;
        regprov.tipmon := regprov100.tipmon;
        regprov.debe := regprov100.debe;
        regprov.haber := regprov100.haber;
        regprov.amorti := regprov.haber - regprov.debe;

        regprov.dh := regprov100.dh;
        regprov.tdocumento := regprov100.tdocumento;
        regprov.saldocalc := regprov.tdocumento ;


        regprov.saldo := regprov100.saldo;
        regprov.codban := regprov100.codban;
        regprov.desban := regprov100.desban;
        regprov.numbco := regprov100.numbco;
        regprov.operac := regprov100.operac;
        regprov.protes := regprov100.protes;
        regprov.tipcam := regprov100.tipcam;
        regprov.signo := regprov100.signo;
        regprov.ddetrac := regprov100.ddetrac;
        regprov.fdetrac := regprov100.fdetrac;
        regprov.impdetrac := regprov100.impdetrac;
        regprov.codclir := regprov100.codclir;
        regprov.desclir := regprov100.desclir;
        regprov.fvenci2 := regprov100.fvenci2;
        IF ( ( pin_docu IS NOT NULL ) OR ( pin_tipo IS NOT NULL ) OR ( pin_swcancela = 'S' ) ) THEN
            regprov.planilla := regprov100.planilla;
            regprov.descri := '';
            regprov.libro := '';
            regprov.periodo := 0;
            regprov.mes := 0;
            regprov.secuencia := 0;
            regprov.planiletra := '';
            regprov.tipcan := 0;
            regprov.dtipcan := '';
            regprov.tippla := 0;
            PIPE ROW ( regprov );----SUSPEND001       
            regprov.tdocumento := 0;
            IF ( ( pin_swsolpend IS NULL ) OR ( upper(pin_swsolpend) = 'N' ) ) THEN
                FOR regprov101 IN cur_select_prov101(regprov.tipo, regprov.docu) LOOP
                    regprov.planilla := regprov101.planilla;
                    regprov.descri := regprov101.descri;
                    regprov.libro := regprov101.libro;
                    regprov.periodo := regprov101.periodo;
                    regprov.mes := regprov101.mes;
                    regprov.secuencia := regprov101.secuencia;
                    regprov.femisi := regprov101.femisi;
                    regprov.fvenci := regprov101.fvenci;
                    regprov.fcance := regprov101.fcance;
                    regprov.tipmon := regprov101.tipmon;
                    regprov.debe := regprov101.debe;
                    regprov.haber := regprov101.haber;
                    regprov.amorti := regprov.haber - regprov.debe;
                    regprov.saldocalc := regprov.saldocalc - abs(regprov.amorti);
                    regprov.numbco := regprov101.numbco;
                    regprov.planiletra := regprov101.planiletra;
                    regprov.tipcan := regprov101.tipcan;
                    regprov.dtipcan := regprov101.dtipcan;
                    regprov.ddetrac := regprov101.ddetrac;
                    regprov.fdetrac := regprov101.fdetrac;
                    regprov.impdetrac := regprov101.impdetrac;
                    regprov.tippla := regprov101.tippla;
                    regprov.refere01 := regprov101.refere01;
                    regprov.refere02 := regprov101.refere02;
                    IF ( regprov101.tippla = 120 ) THEN
                        BEGIN
                            SELECT
                                p4.codban,
                                b.descri,
                                p4.op
                            INTO
                                regprov.codban,
                                regprov.desban,
                                regprov.numbco
                            FROM
                                prov104  p4
                                LEFT OUTER JOIN tbancos  b ON b.id_cia = p4.id_cia
                                                             AND b.codban = p4.codban
                            WHERE
                                    p4.id_cia = pin_id_cia
                                AND p4.periodo = regprov.periodo
                                AND p4.mes = regprov.mes
                                AND p4.libro = regprov.libro
                                AND p4.secuencia = regprov.secuencia
                            ORDER BY
                                p4.item
                            FETCH FIRST 1 ROW ONLY;

                        EXCEPTION
                            WHEN no_data_found THEN
                                regprov.codban := NULL;
                                regprov.desban := NULL;
                                regprov.numbco := NULL;
                        END;
                    END IF;

                    PIPE ROW ( regprov );----SUSPEND001  
                END LOOP;
            END IF;

        ELSE
            regprov.planilla := '';
            regprov.descri := '';
            regprov.libro := '';
            regprov.periodo := 0;
            regprov.mes := 0;
            regprov.secuencia := 0;
            regprov.planiletra := '';
            regprov.tipcan := 0;
            regprov.dtipcan := '';
            regprov.tippla := 0;
            PIPE ROW ( regprov );----SUSPEND001  
        END IF;

    END LOOP;

END sp000_saca_estado_de_cuenta_proveedores;

/
