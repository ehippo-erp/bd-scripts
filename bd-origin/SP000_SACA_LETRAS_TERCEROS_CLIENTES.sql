--------------------------------------------------------
--  DDL for Function SP000_SACA_LETRAS_TERCEROS_CLIENTES
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_LETRAS_TERCEROS_CLIENTES" (
    pin_id_cia        NUMBER,
    pin_codcli        VARCHAR2,
    pin_swsolpend     VARCHAR2,
    pin_swincdocdes   VARCHAR2,
    pin_ubicacion     VARCHAR2,
    pin_numint        NUMBER,
    pin_swcancela     VARCHAR2
) RETURN tbl_letras_terceros_clientes
    PIPELINED
AS

    r_letras_terceros_clientes   rec_letras_terceros_clientes := rec_letras_terceros_clientes(NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL);
    CURSOR cur_select_001 (
        wklibldes VARCHAR2
    ) IS
    SELECT DISTINCT
        d.numint,
        d.tipdoc,
        td.abrevi,
        td.descri || ' TERCEROS ' AS desdoc,
        d.docume,
        d.refere01,
        d.femisi,
        d.fvenci,
        d.fcance,
        CASE
                WHEN d.saldo <> 0 THEN
                    sysdate
                ELSE
                    d.fcance
            END
        - d.fvenci AS mora,
        d.tipmon,
        nvl(dc.vreal, 0) AS tpercepcion,
        d.importe + nvl(dc.vreal, 0) AS tdocumento,
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
        tb.descri AS desban,
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
        CAST(d.xlibro AS VARCHAR(3))
        || '-'
        || CAST(d.xperiodo AS VARCHAR(4))
        || '-'
        || CAST(d.xmes AS VARCHAR(2))
        || '-'
        || CAST(d.xsecuencia AS VARCHAR(10)) AS xplanilla,
        tx.descri,
        d.codubi,
        u.desubi,
        d.codcli,
        c.razonc
    FROM
        dcta100                d
        LEFT OUTER JOIN documentos_cab_clase   dc ON dc.id_cia = pin_id_cia
                                                   AND dc.numint = d.numint
                                                   AND dc.clase = 4 /* SACA EL TOTAL DE PERPECTION */
        LEFT OUTER JOIN tdoccobranza           td ON td.id_cia = pin_id_cia
                                           AND td.tipdoc = d.tipdoc
        LEFT OUTER JOIN dcta103                d9 ON d9.id_cia = pin_id_cia
                                      AND d9.numint = d.numint
                                      AND d9.situac = 'B'
                                      AND d9.libro = wklibldes
        LEFT OUTER JOIN tlibro                 tx ON tx.id_cia = pin_id_cia
                                     AND tx.codlib = d.xlibro
        LEFT OUTER JOIN tbancos                tb ON tb.id_cia = pin_id_cia
                                      AND tb.codban = CAST(d.codban AS VARCHAR(3))
        LEFT OUTER JOIN ubicacion              u ON tb.id_cia = pin_id_cia
                                       AND u.codubi = d.codubi
        LEFT OUTER JOIN dcta105                d5 ON d5.id_cia = pin_id_cia
                                      AND ( d5.numint = d.numint )
        LEFT OUTER JOIN cliente                c ON c.id_cia = pin_id_cia
                                     AND ( c.codcli = d.codcli )
    WHERE
        d.id_cia = pin_id_cia
        AND ( pin_numint IS NULL
              OR d.numint = pin_numint )
        AND ( d.codterc = pin_codcli )
        AND  /* SOLO SACA DOCUMENTOS A TERCEROS SI UBIECE */ ( ( ( ( pin_swincdocdes IS NULL )
                  OR ( pin_swincdocdes = 'N' ) )
                AND ( ( abs(d.operac) <= 1 )
                      OR ( d.operac = 6 ) ) )
              OR ( ( ( pin_swincdocdes = 'S' ) )
                   AND ( ( abs(d.operac) <= 2 )
                         OR ( d.operac = 6 ) ) ) )
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
                                   AND ( d9.libro = wklibldes ) ) ) ) ) )
        AND ( ( pin_ubicacion IS NULL )
              OR ( length(pin_ubicacion) = 0 )
              OR ( ','
                   || pin_ubicacion
                   || ',' LIKE '%,'
                               || d.codubi
                               || ',%' ) )
    ORDER BY
        d.codcli,
        d.tipdoc,
        d.docume,
        d.femisi;

    CURSOR cur_select_002 (
        wklibcanj   VARCHAR2,
        wklibrend   VARCHAR2,
        wklibrenc   VARCHAR2,
        wklibanti   VARCHAR2
    ) IS
    SELECT
        CAST(d1.libro AS VARCHAR(3))
        || '-'
        || CAST(d1.periodo AS VARCHAR(4))
        || '-'
        || CAST(d1.mes AS VARCHAR(2))
        || '-'
        || CAST(d1.secuencia AS VARCHAR(10)) AS planilla,
        t.descri,
        d1.libro,
        d1.periodo,
        d1.mes,
        d1.secuencia,
        d3.femisi,
        d3.femisi AS fcance,
        d1.tipmon,
        CASE
            WHEN ( d1.dh = 'D' )
                 AND ( d1.tipcan < 50 ) THEN
                ( d1.importe )
            ELSE
                0
        END AS debe,
        CASE
            WHEN ( d1.dh = 'H' )
                 AND ( d1.tipcan < 50 ) THEN
                ( d1.importe )
            ELSE
                0
        END AS haber,
        d1.numbco,
        d13.libro
        || '-'
        || CAST(d13.periodo AS VARCHAR(10))
        || '-'
        || CAST(d13.mes AS VARCHAR(10))
        || '-'
        || CAST(d13.secuencia AS VARCHAR(10)) AS planiletra,
        CAST(d1.tipcan AS SMALLINT) AS tipcan,
        CAST(tp.descri AS VARCHAR(60)) AS dtipcan,
        d3.tippla
    FROM
        dcta101   d1
        LEFT OUTER JOIN dcta102   d3 ON ( d3.id_cia = pin_id_cia )
                                      AND ( d3.libro = d1.libro )
                                      AND ( d3.periodo = d1.periodo )
                                      AND ( d3.mes = d1.mes )
                                      AND ( d3.secuencia = d1.secuencia )
        LEFT OUTER JOIN m_pago    tp ON ( tp.id_cia = pin_id_cia )
                                     AND ( tp.codigo = d1.tipcan )
        LEFT OUTER JOIN tlibro    t ON ( t.id_cia = d1.id_cia )
                                    AND ( t.codlib = d1.libro )
        LEFT OUTER JOIN dcta103   d13 ON ( d13.id_cia = pin_id_cia )
                                       AND ( d13.numint = pin_numint )
                                       AND ( d13.situac <> 'J' )
                                       AND ( ( d13.libro <> d1.libro )
                                             OR ( d13.secuencia <> d1.secuencia )
                                             OR ( d13.periodo <> d1.periodo )
                                             OR ( d13.mes <> d1.mes ) )
                                       AND ( ( d13.libro = wklibcanj )
                                             OR ( d13.libro = wklibrend )
                                             OR ( d13.libro = wklibrenc )
                                             OR ( d13.libro = wklibanti ) )
    WHERE
        ( d1.id_cia = pin_id_cia )
        AND ( d1.numint = pin_numint )
        AND
                             /*  (D1.TIPCAN   <50)           AND  Para que se puedan visualizar las planillas de envio al banco*/ ( t.codlib = d1.libro )
        AND ( d3.libro = d1.libro )
        AND ( d3.periodo = d1.periodo )
        AND ( d3.mes = d1.mes )
        AND ( d3.secuencia = d1.secuencia )
    ORDER BY
        d1.femisi,
        d1.numite;

    v_klibcanj                   VARCHAR2(3);
    v_klibrend                   VARCHAR2(3);
    v_klibrenc                   VARCHAR2(3);
    v_klibldes                   VARCHAR2(3);
    v_klibanti                   VARCHAR2(3);
BEGIN
    r_letras_terceros_clientes.numint := 0;
    r_letras_terceros_clientes.tipdoc := 0;
    r_letras_terceros_clientes.abrevi := '';
    r_letras_terceros_clientes.desdoc := '';
    r_letras_terceros_clientes.docume := '';
    r_letras_terceros_clientes.refere01 := '';
    r_letras_terceros_clientes.femisi := NULL;
    r_letras_terceros_clientes.fvenci := NULL;
    r_letras_terceros_clientes.fcance := NULL;
    r_letras_terceros_clientes.mora := 0;
    r_letras_terceros_clientes.tipmon := '';
    r_letras_terceros_clientes.debe := 0;
    r_letras_terceros_clientes.haber := 0;
    r_letras_terceros_clientes.saldo := 0;
    r_letras_terceros_clientes.planilla := '';
    r_letras_terceros_clientes.descri := '';
    r_letras_terceros_clientes.libro := '';
    r_letras_terceros_clientes.periodo := 0;
    r_letras_terceros_clientes.mes := 0;
    r_letras_terceros_clientes.secuencia := 0;
    r_letras_terceros_clientes.planiletra := '';
    r_letras_terceros_clientes.codban := 0;
    r_letras_terceros_clientes.desban := '';
    r_letras_terceros_clientes.numbco := '';
    r_letras_terceros_clientes.tipcan := 0;
    r_letras_terceros_clientes.dtipcan := '';
    r_letras_terceros_clientes.operac := 0;
    r_letras_terceros_clientes.protes := 0;
    r_letras_terceros_clientes.tipcam := 0;
    r_letras_terceros_clientes.signo := 0;
    r_letras_terceros_clientes.codubi := 0;
    r_letras_terceros_clientes.desubi := '';
    r_letras_terceros_clientes.tpercepcion := 0;
    r_letras_terceros_clientes.tdocumento := 0;
    r_letras_terceros_clientes.xplanilla := '';
    r_letras_terceros_clientes.xlibro := '';
    r_letras_terceros_clientes.xperiodo := 0;
    r_letras_terceros_clientes.xmes := 0;
    r_letras_terceros_clientes.xsecuencia := 0;
    r_letras_terceros_clientes.xprotes := 0;
    r_letras_terceros_clientes.xdescri := '';
    r_letras_terceros_clientes.codcli := '';
    r_letras_terceros_clientes.razonc := '';
    BEGIN
        SELECT
            vstrg
        INTO v_klibcanj
        FROM
            factor
        WHERE
            id_cia = pin_id_cia
            AND codfac = 101;

    EXCEPTION
        WHEN no_data_found THEN
            v_klibcanj := '';
    END;

    BEGIN
        SELECT
            vstrg
        INTO v_klibanti
        FROM
            factor
        WHERE
            id_cia = pin_id_cia
            AND codfac = 104;

    EXCEPTION
        WHEN no_data_found THEN
            v_klibanti := '';
    END;

    BEGIN
        SELECT
            vstrg
        INTO v_klibrend
        FROM
            factor
        WHERE
            id_cia = pin_id_cia
            AND codfac = 111;

    EXCEPTION
        WHEN no_data_found THEN
            v_klibrend := '';
    END;

    BEGIN
        SELECT
            vstrg
        INTO v_klibrenc
        FROM
            factor
        WHERE
            id_cia = pin_id_cia
            AND codfac = 113;

    EXCEPTION
        WHEN no_data_found THEN
            v_klibrenc := '';
    END;

    BEGIN
        SELECT
            vstrg
        INTO v_klibldes
        FROM
            factor
        WHERE
            id_cia = pin_id_cia
            AND codfac = 107;

    EXCEPTION
        WHEN no_data_found THEN
            v_klibldes := '';
    END;

    BEGIN
        SELECT
            limcre2,
            telefono
        INTO
            r_letras_terceros_clientes.limcre2,
            r_letras_terceros_clientes.fonocli
        FROM
            cliente
        WHERE
            id_cia = pin_id_cia
            AND codcli = pin_codcli;

    EXCEPTION
        WHEN no_data_found THEN
            r_letras_terceros_clientes.limcre2 := 0;
            r_letras_terceros_clientes.fonocli := '';
    END;
/*
  KPLACANJ  = 101;  //- PLANILLA DE CANJES.
  KPLAREND  = 111;  //- PLANILLA DE RENOVACIONES - DESCUENTO .
  KPLARENC  = 113;  //- PLANILLA DE RENOVACIONES - COBRANZAS .
  KPLALDES  = 107;  //- PLANILLA DE LETRAS EN DESCUENTO.

*/

    FOR registro IN cur_select_001(v_klibldes) LOOP
        r_letras_terceros_clientes.numint := registro.numint;
        r_letras_terceros_clientes.tipdoc := registro.tipdoc;
        r_letras_terceros_clientes.abrevi := registro.abrevi;
        r_letras_terceros_clientes.desdoc := registro.desdoc;
        r_letras_terceros_clientes.docume := registro.docume;
        r_letras_terceros_clientes.refere01 := registro.refere01;
        r_letras_terceros_clientes.femisi := registro.femisi;
        r_letras_terceros_clientes.fvenci := registro.fvenci;
        r_letras_terceros_clientes.fcance := registro.fcance;
        r_letras_terceros_clientes.mora := registro.mora;
        r_letras_terceros_clientes.tipmon := registro.tipmon;
        r_letras_terceros_clientes.tpercepcion := registro.tpercepcion;
        r_letras_terceros_clientes.tdocumento := registro.tdocumento;
        r_letras_terceros_clientes.debe := registro.debe;
        r_letras_terceros_clientes.haber := registro.haber;
        r_letras_terceros_clientes.saldo := registro.saldo;
        r_letras_terceros_clientes.codban := registro.codban;
        r_letras_terceros_clientes.desban := registro.desban;
        r_letras_terceros_clientes.numbco := registro.numbco;
        r_letras_terceros_clientes.operac := registro.operac;
        r_letras_terceros_clientes.protes := registro.protes;
        r_letras_terceros_clientes.tipcam := registro.tipcam;
        r_letras_terceros_clientes.signo := registro.signo;
        r_letras_terceros_clientes.xlibro := registro.xlibro;
        r_letras_terceros_clientes.xperiodo := registro.xperiodo;
        r_letras_terceros_clientes.xmes := registro.xmes;
        r_letras_terceros_clientes.xsecuencia := registro.xsecuencia;
        r_letras_terceros_clientes.xprotes := registro.xprotesto;
        r_letras_terceros_clientes.xplanilla := registro.xplanilla;
        r_letras_terceros_clientes.xdescri := registro.descri;
        r_letras_terceros_clientes.codubi := registro.codubi;
        r_letras_terceros_clientes.desubi := registro.desubi;
        r_letras_terceros_clientes.codcli := registro.codcli;
        r_letras_terceros_clientes.razonc := registro.razonc;
        BEGIN
            SELECT
                m.desmot
            INTO r_letras_terceros_clientes.desmot
            FROM
                documentos_cab   c
                LEFT OUTER JOIN motivos          m ON m.id_cia = pin_id_cia
                                             AND m.tipdoc = c.tipdoc
                                             AND m.codmot = c.codmot
                                             AND m.id = c.id
            WHERE
                numint = pin_numint;

        EXCEPTION
            WHEN no_data_found THEN
                r_letras_terceros_clientes.desmot := '';
        END;

        IF ( r_letras_terceros_clientes.tipdoc = 41 ) THEN
            BEGIN
                SELECT
                    t.abrevi
                    || '-'
                    || d.serie
                    || '-'
                    || d.numero
                INTO r_letras_terceros_clientes.refere01
                FROM
                    documentos_det_percepcion   d
                    LEFT OUTER JOIN tdoccobranza                t ON t.id_cia = pin_id_cia
                                                      AND t.tipdoc = d.tdocum
                WHERE
                    d.id_cia = pin_id_cia
                    AND d.numint = pin_numint
                FETCH FIRST 1 ROW ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    r_letras_terceros_clientes.refere01 := '';
            END;
        END IF;

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
                  || CAST(d3.secuencia AS VARCHAR(10)) ) AS planilla,
                t.descri
            INTO
                r_letras_terceros_clientes.libro,
                r_letras_terceros_clientes.periodo,
                r_letras_terceros_clientes.mes,
                r_letras_terceros_clientes.secuencia,
                r_letras_terceros_clientes.planilla,
                r_letras_terceros_clientes.descri
            FROM
                dcta103   d3
                LEFT OUTER JOIN tlibro    t ON t.id_cia = pin_id_cia
                                            AND ( t.codlib = d3.libro )
            WHERE
                d3.id_cia = pin_id_cia
                AND ( d3.numint = pin_numint )
                AND ( d3.situac <> 'J' )
                AND ( ( d3.libro = v_klibcanj )
                      OR ( d3.libro = v_klibrend )
                      OR ( d3.libro = v_klibrenc )
                      OR ( d3.libro = v_klibanti ) )
            FETCH FIRST 1 ROW ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                r_letras_terceros_clientes.libro := NULL;
                r_letras_terceros_clientes.periodo := NULL;
                r_letras_terceros_clientes.mes := NULL;
                r_letras_terceros_clientes.secuencia := NULL;
                r_letras_terceros_clientes.planilla := NULL;
                r_letras_terceros_clientes.descri := NULL;
        END;

        IF ( ( r_letras_terceros_clientes.libro IS NULL ) OR ( r_letras_terceros_clientes.periodo IS NULL ) OR ( r_letras_terceros_clientes
        .mes IS NULL ) OR ( r_letras_terceros_clientes.secuencia IS NULL ) OR ( r_letras_terceros_clientes.planilla IS NULL ) ) THEN
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
                      || CAST(d5.secuencia AS VARCHAR(10)) ) AS planilla,
                    t.descri
                INTO
                    r_letras_terceros_clientes.libro,
                    r_letras_terceros_clientes.periodo,
                    r_letras_terceros_clientes.mes,
                    r_letras_terceros_clientes.secuencia,
                    r_letras_terceros_clientes.planilla,
                    r_letras_terceros_clientes.descri
                FROM
                    dcta105   d5
                    LEFT OUTER JOIN tlibro    t ON t.id_cia = pin_id_cia
                                                AND ( t.codlib = d5.libro )
                WHERE
                    d5.id_cia = pin_id_cia
                    AND ( d5.numint = pin_numint )
                    AND ( ( d5.libro = v_klibcanj )
                          OR ( d5.libro = v_klibrend )
                          OR ( d5.libro = v_klibrenc )
                          OR ( d5.libro = v_klibanti ) )
                FETCH FIRST 1 ROW ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    r_letras_terceros_clientes.libro := NULL;
                    r_letras_terceros_clientes.periodo := NULL;
                    r_letras_terceros_clientes.mes := NULL;
                    r_letras_terceros_clientes.secuencia := NULL;
                    r_letras_terceros_clientes.planilla := NULL;
                    r_letras_terceros_clientes.descri := NULL;
            END;
        END IF;

        IF ( ( pin_numint IS NOT NULL ) OR ( pin_swcancela = 'S' ) ) THEN
            PIPE ROW ( r_letras_terceros_clientes );
            r_letras_terceros_clientes.codubi := 0;
            r_letras_terceros_clientes.desubi := '';
            r_letras_terceros_clientes.tpercepcion := 0;
            r_letras_terceros_clientes.tdocumento := 0;
            r_letras_terceros_clientes.xlibro := '';
            r_letras_terceros_clientes.xperiodo := 0;
            r_letras_terceros_clientes.xmes := 0;
            r_letras_terceros_clientes.xsecuencia := 0;
            r_letras_terceros_clientes.xprotes := 0;
            r_letras_terceros_clientes.xplanilla := '';
            r_letras_terceros_clientes.xdescri := '';
            r_letras_terceros_clientes.planilla := '';
            r_letras_terceros_clientes.descri := '';
            r_letras_terceros_clientes.libro := '';
            r_letras_terceros_clientes.periodo := 0;
            r_letras_terceros_clientes.mes := 0;
            r_letras_terceros_clientes.secuencia := 0;
            r_letras_terceros_clientes.planiletra := '';
            r_letras_terceros_clientes.tipcan := 0;
            r_letras_terceros_clientes.dtipcan := '';
            r_letras_terceros_clientes.fvenci := NULL;
            r_letras_terceros_clientes.tippla := 0;
            IF ( ( pin_swsolpend IS NULL ) OR ( pin_swsolpend = 'N' ) ) THEN
                FOR registro2 IN cur_select_002(v_klibcanj, v_klibrend, v_klibrenc, v_klibanti) LOOP
                    r_letras_terceros_clientes.planilla := registro2.planilla;
                    r_letras_terceros_clientes.descri := registro2.descri;
                    r_letras_terceros_clientes.libro := registro2.libro;
                    r_letras_terceros_clientes.periodo := registro2.periodo;
                    r_letras_terceros_clientes.mes := registro2.mes;
                    r_letras_terceros_clientes.secuencia := registro2.secuencia;
                    r_letras_terceros_clientes.femisi := registro2.femisi;
                    r_letras_terceros_clientes.fcance := registro2.fcance;
                    r_letras_terceros_clientes.tipmon := registro2.tipmon;
                    r_letras_terceros_clientes.debe := registro2.debe;
                    r_letras_terceros_clientes.haber := registro2.haber;
                    r_letras_terceros_clientes.numbco := registro2.numbco;
                    r_letras_terceros_clientes.planiletra := registro2.planiletra;
                    r_letras_terceros_clientes.tipcan := registro2.tipcan;
                    r_letras_terceros_clientes.dtipcan := registro2.dtipcan;
                    r_letras_terceros_clientes.tippla := registro2.tippla;
                    PIPE ROW ( r_letras_terceros_clientes );
                END LOOP;
            END IF;

        ELSE
            PIPE ROW ( r_letras_terceros_clientes );
            r_letras_terceros_clientes.codubi := 0;
            r_letras_terceros_clientes.desubi := '';
            r_letras_terceros_clientes.tpercepcion := 0;
            r_letras_terceros_clientes.tdocumento := 0;
            r_letras_terceros_clientes.xlibro := '';
            r_letras_terceros_clientes.xperiodo := 0;
            r_letras_terceros_clientes.xmes := 0;
            r_letras_terceros_clientes.xsecuencia := 0;
            r_letras_terceros_clientes.xprotes := 0;
            r_letras_terceros_clientes.xplanilla := '';
            r_letras_terceros_clientes.xdescri := '';
            r_letras_terceros_clientes.planilla := '';
            r_letras_terceros_clientes.descri := '';
            r_letras_terceros_clientes.libro := '';
            r_letras_terceros_clientes.periodo := 0;
            r_letras_terceros_clientes.mes := 0;
            r_letras_terceros_clientes.secuencia := 0;
            r_letras_terceros_clientes.planiletra := '';
            r_letras_terceros_clientes.tipcan := 0;
            r_letras_terceros_clientes.dtipcan := '';
            r_letras_terceros_clientes.fvenci := NULL;
            r_letras_terceros_clientes.tippla := 0;
        END IF;

    END LOOP;

    r_letras_terceros_clientes.codubi := 0;
    r_letras_terceros_clientes.desubi := '';
    r_letras_terceros_clientes.tpercepcion := 0;
    r_letras_terceros_clientes.tdocumento := 0;
    r_letras_terceros_clientes.xlibro := '';
    r_letras_terceros_clientes.xperiodo := 0;
    r_letras_terceros_clientes.xmes := 0;
    r_letras_terceros_clientes.xsecuencia := 0;
    r_letras_terceros_clientes.xprotes := 0;
    r_letras_terceros_clientes.xplanilla := '';
    r_letras_terceros_clientes.xdescri := '';
    r_letras_terceros_clientes.planilla := '';
    r_letras_terceros_clientes.descri := '';
    r_letras_terceros_clientes.libro := '';
    r_letras_terceros_clientes.periodo := 0;
    r_letras_terceros_clientes.mes := 0;
    r_letras_terceros_clientes.secuencia := 0;
    r_letras_terceros_clientes.planiletra := '';
    r_letras_terceros_clientes.tipcan := 0;
    r_letras_terceros_clientes.dtipcan := '';
    r_letras_terceros_clientes.fvenci := NULL;
    r_letras_terceros_clientes.tippla := 0;
    r_letras_terceros_clientes.mora := 0;
    r_letras_terceros_clientes.tpercepcion := 0;
    r_letras_terceros_clientes.codban := 0;
    r_letras_terceros_clientes.desban := '';
    r_letras_terceros_clientes.numbco := '';
    r_letras_terceros_clientes.protes := 0;
END sp000_saca_letras_terceros_clientes;

/
