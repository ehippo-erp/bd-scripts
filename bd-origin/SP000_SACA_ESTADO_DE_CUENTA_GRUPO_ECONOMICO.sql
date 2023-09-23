--------------------------------------------------------
--  DDL for Function SP000_SACA_ESTADO_DE_CUENTA_GRUPO_ECONOMICO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_ESTADO_DE_CUENTA_GRUPO_ECONOMICO" (
    pin_id_cia     IN  INTEGER,
    pin_grupoeco   IN  VARCHAR2,
    pin_solpend    IN  VARCHAR2,
    pin_incdocdes  VARCHAR2,
    pin_ubiacion   VARCHAR2
) RETURN tbl_estado_cuenta_grupo_economico
    PIPELINED
AS

    r_estado_de_cuenta_grupo_economico  rec_estado_cuenta_grupo_economico := rec_estado_cuenta_grupo_economico(NULL, NULL, NULL, NULL,
    NULL,
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
    CURSOR cur_mainselec (
        p_libldes VARCHAR2
    ) IS
    SELECT DISTINCT
        d.codcli,
        c.razonc,
        d.numint,
        d.tipdoc,
        td.abrevi,
        td.descri    AS desdoc,
        d.docume,
        d.serie,
        d.numero,
        d.refere01,
        d.refere02,
        d.femisi,
        d.fvenci,
        d.fcance,
        nvl((trunc(
            CASE
                WHEN d.saldo <> 0 THEN
                    sysdate
                ELSE
                    d.fcance
            END
        ) - trunc(d.fvenci)), 0) AS mora,
        d.tipmon,
        CASE
            WHEN dc.vreal IS NULL THEN
                0
            ELSE
                dc.vreal
        END AS tpercepcion,
        d.importe    AS tdocumento,
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
        a1.razonc    AS aval001,
        a2.razonc    AS aval002,
        d.tercero,
        d.codterc,
        t1.razonc    AS razoncterc
    FROM
        cliente_clase         cge
        LEFT OUTER JOIN dcta100               d ON d.id_cia = cge.id_cia
                                     AND d.codcli = cge.codcli
        LEFT OUTER JOIN dcta100_ori           o ON o.id_cia = cge.id_cia
                                         AND o.numint = d.numint
        LEFT OUTER JOIN documentos_cab_clase  dc ON dc.id_cia = cge.id_cia
                                                   AND dc.numint = d.numint
                                                   AND dc.clase = 4 /* SACA EL TOTAL DE PERPECTION */
        LEFT OUTER JOIN tdoccobranza          td ON td.id_cia = cge.id_cia
                                           AND td.tipdoc = d.tipdoc
        LEFT OUTER JOIN dcta103               d9 ON d9.id_cia = cge.id_cia
                                      AND d9.numint = d.numint
                                      AND d9.situac = 'B'
                                      AND d9.libro = p_libldes
        LEFT OUTER JOIN tlibro                tx ON tx.id_cia = cge.id_cia
                                     AND tx.codlib = d.xlibro
        LEFT OUTER JOIN tbancos               tb ON tb.id_cia = cge.id_cia
                                      AND tb.codban = CAST(d.codban AS VARCHAR(3))
        LEFT OUTER JOIN e_financiera          ef ON ef.id_cia = cge.id_cia
                                           AND ef.codigo = d.codban
        LEFT OUTER JOIN ubicacion             u ON u.id_cia = cge.id_cia
                                       AND u.codubi = d.codubi
        LEFT OUTER JOIN dcta105               d5 ON d5.id_cia = cge.id_cia
                                      AND ( d5.numint = d.numint )
        LEFT OUTER JOIN cliente               c ON c.id_cia = cge.id_cia
                                     AND ( c.codcli = d.codcli )
        LEFT OUTER JOIN cliente               a1 ON a1.id_cia = cge.id_cia
                                      AND ( a1.codcli = d5.codaval01 )
        LEFT OUTER JOIN cliente               a2 ON a2.id_cia = cge.id_cia
                                      AND ( a2.codcli = d5.codaval02 )
        LEFT OUTER JOIN cliente               t1 ON t1.id_cia = cge.id_cia
                                      AND ( t1.codcli = d.codterc )
    WHERE
            cge.id_cia = pin_id_cia
        AND cge.tipcli = 'A'
        AND cge.codcli = d.codcli
        AND cge.clase = 28 /*28-GRUPO ECONOMICO*/
        AND cge.codigo = pin_grupoeco
        AND ( ( ( ( pin_incdocdes IS NULL )
                  OR ( pin_incdocdes = 'N' ) )
                AND ( ( abs(d.operac) <= 1 )
                      OR ( d.operac IN (
            6,
            7,
            8
        ) ) ) )
              OR ( ( ( pin_incdocdes = 'S' ) )
                   AND ( ( abs(d.operac) <= 2 )
                         OR ( d.operac IN (
            6,
            7,
            8
        ) ) ) ) )
        AND ( ( ( pin_solpend IS NULL )
                OR ( pin_solpend = 'N' ) )
              OR ( ( pin_solpend = 'S' )
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
                         OR ( ( ( pin_incdocdes IS NULL )
                                OR ( pin_incdocdes = 'N' ) )
                              OR ( ( pin_incdocdes = 'S' )
                                   AND ( d9.libro = p_libldes ) ) ) ) ) )
        AND ( ( pin_ubiacion IS NULL )
              OR ( length(pin_ubiacion) = 0 )
              OR ( ','
                   || pin_ubiacion
                   || ',' LIKE '%,'
                               || d.codubi
                               || ',%' ) )
    ORDER BY
        d.codcli,
        d.tipdoc,
        d.docume,
        d.femisi;

    v_fonocli                           VARCHAR(50);
    v_limcre2                           NUMERIC(9, 2);
    v_f101                              VARCHAR2(20) := '';
    v_f104                              VARCHAR2(20) := '';
    v_f113                              VARCHAR2(20) := '';
    v_f107                              VARCHAR2(20) := '';
    v_f111                              VARCHAR2(20) := '';
BEGIN
	   /**********************************************/
       /*  factor 101 - Planilla de Canje de Letras  */
       /**********************************************/
    BEGIN
        SELECT
            vstrg
        INTO v_f101
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 101;

    EXCEPTION
        WHEN no_data_found THEN
            v_f101 := '';
    END;
	   /**********************************************/
       /*  factor 104 - Planilla de Anticipos  */
       /**********************************************/

    BEGIN
        SELECT
            vstrg
        INTO v_f104
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 104;

    EXCEPTION
        WHEN no_data_found THEN
            v_f104 := '';
    END;
	   /*******************************************************/
       /*  factor 111 - Planilla de Renovaciones - Descuento  */
       /*******************************************************/

    BEGIN
        SELECT
            vstrg
        INTO v_f111
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 111;

    EXCEPTION
        WHEN no_data_found THEN
            v_f111 := '';
    END;
	   /*******************************************************/
       /*  factor 113 - Planilla de Renovaciones - Cobranza   */
       /*******************************************************/

    BEGIN
        SELECT
            vstrg
        INTO v_f113
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 113;

    EXCEPTION
        WHEN no_data_found THEN
            v_f113 := '';
    END;
	   /*******************************************************/
       /*  factor 107 - Planilla de Letras en Descuento       */
       /*******************************************************/

    BEGIN
        SELECT
            vstrg
        INTO v_f107
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 107;

    EXCEPTION
        WHEN no_data_found THEN
            v_f107 := '';
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
            AND codcli = pin_grupoeco;

    EXCEPTION
        WHEN no_data_found THEN
            v_limcre2 := NULL;
    END;

    IF v_limcre2 IS NULL THEN
        v_limcre2 := 0;
    END IF;
    FOR r_main IN cur_mainselec(v_f107) LOOP
        r_estado_de_cuenta_grupo_economico.codcli := r_main.codcli;
        r_estado_de_cuenta_grupo_economico.razonc := r_main.razonc;
        r_estado_de_cuenta_grupo_economico.numint := r_main.numint;
        r_estado_de_cuenta_grupo_economico.tipdoc := r_main.tipdoc;
        r_estado_de_cuenta_grupo_economico.abrevi := r_main.abrevi;
        r_estado_de_cuenta_grupo_economico.desdoc := r_main.desdoc;
        r_estado_de_cuenta_grupo_economico.docume := r_main.docume;
        r_estado_de_cuenta_grupo_economico.serie := r_main.serie;
        r_estado_de_cuenta_grupo_economico.numero := r_main.numero;
        r_estado_de_cuenta_grupo_economico.refere01 := r_main.refere01;
        r_estado_de_cuenta_grupo_economico.refere02 := r_main.refere02;
        r_estado_de_cuenta_grupo_economico.femisi := r_main.femisi;
        r_estado_de_cuenta_grupo_economico.fvenci := r_main.fvenci;
        r_estado_de_cuenta_grupo_economico.fcance := r_main.fcance;
        r_estado_de_cuenta_grupo_economico.mora := r_main.mora;
        r_estado_de_cuenta_grupo_economico.tipmon := r_main.tipmon;
        r_estado_de_cuenta_grupo_economico.tpercepcion := r_main.tpercepcion;
        r_estado_de_cuenta_grupo_economico.tdocumento := r_main.tdocumento;
        r_estado_de_cuenta_grupo_economico.saldo_ori := r_main.saldo_ori;
        r_estado_de_cuenta_grupo_economico.debe := r_main.debe;
        r_estado_de_cuenta_grupo_economico.haber := r_main.haber;
        r_estado_de_cuenta_grupo_economico.saldo := r_main.saldo;
        r_estado_de_cuenta_grupo_economico.codban := r_main.codban;
        r_estado_de_cuenta_grupo_economico.desban := r_main.desban;
        r_estado_de_cuenta_grupo_economico.numbco := r_main.numbco;
        r_estado_de_cuenta_grupo_economico.operac := r_main.operac;
        r_estado_de_cuenta_grupo_economico.protes := r_main.protes;
        r_estado_de_cuenta_grupo_economico.tipcam := r_main.tipcam;
        r_estado_de_cuenta_grupo_economico.signo := r_main.signo;
        r_estado_de_cuenta_grupo_economico.xlibro := r_main.xlibro;
        r_estado_de_cuenta_grupo_economico.xperiodo := r_main.xperiodo;
        r_estado_de_cuenta_grupo_economico.xmes := r_main.xmes;
        r_estado_de_cuenta_grupo_economico.xsecuencia := r_main.xsecuencia;
        r_estado_de_cuenta_grupo_economico.xprotes := r_main.xprotesto;
        r_estado_de_cuenta_grupo_economico.xplanilla := r_main.xplanilla;
        r_estado_de_cuenta_grupo_economico.xdescri := r_main.descri;
        r_estado_de_cuenta_grupo_economico.codubi := r_main.codubi;
        r_estado_de_cuenta_grupo_economico.desubi := r_main.desubi;
        r_estado_de_cuenta_grupo_economico.aval001 := r_main.aval001;
        r_estado_de_cuenta_grupo_economico.aval002 := r_main.aval002;
        r_estado_de_cuenta_grupo_economico.tercero := r_main.tercero;
        r_estado_de_cuenta_grupo_economico.codterc := r_main.codterc;
        r_estado_de_cuenta_grupo_economico.razoncterc := r_main.razoncterc;
        IF ( r_main.saldo_ori <> 0 ) THEN
            r_estado_de_cuenta_grupo_economico.saldocalc := r_main.saldo_ori;
        END IF;

        BEGIN
            SELECT
                m.desmot,
                doc.numero AS numero_dcorcom,
                c.presen
            INTO
                r_estado_de_cuenta_grupo_economico.desmot,
                r_estado_de_cuenta_grupo_economico.numero_dcorcom,
                r_estado_de_cuenta_grupo_economico.presen
            FROM
                documentos_cab         c
                LEFT OUTER JOIN motivos                m ON m.id_cia = pin_id_cia
                                             AND m.tipdoc = c.tipdoc
                                             AND m.codmot = c.codmot
                                             AND m.id = c.id
                LEFT OUTER JOIN documentos_cab_ordcom  doc ON doc.id_cia = pin_id_cia
                                                             AND doc.numint = c.numint
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numint = r_main.numint;

        EXCEPTION
            WHEN no_data_found THEN
                r_estado_de_cuenta_grupo_economico.desmot := '';
                r_estado_de_cuenta_grupo_economico.numero_dcorcom := '';
                r_estado_de_cuenta_grupo_economico.presen := '';
        END;

        IF ( r_main.tipdoc = 41 ) THEN
            BEGIN
                SELECT
                    t.abrevi
                    || '-'
                    || d.serie
                    || '-'
                    || d.numero
                INTO r_estado_de_cuenta_grupo_economico.refere01
                FROM
                    documentos_det_percepcion  d
                    LEFT OUTER JOIN tdoccobranza               t ON t.id_cia = pin_id_cia
                                                      AND t.tipdoc = d.tdocum
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.numint = r_main.numint
                FETCH FIRST 1 ROW ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    r_estado_de_cuenta_grupo_economico.refere01 := '';
            END;
        END IF;

        r_estado_de_cuenta_grupo_economico.saldopercep := r_main.tpercepcion;
        IF (
            ( r_main.tipdoc IN (
                1,
                3,
                8
            ) ) AND ( r_main.tpercepcion <> 0 )
        ) THEN
            BEGIN
                SELECT
                    SUM(d.percepcion)
                INTO r_estado_de_cuenta_grupo_economico.saldopercep
                FROM
                    documentos_det_percepcion  d
                    LEFT OUTER JOIN documentos_cab             c ON c.id_cia = d.id_cia
                                                        AND c.numint = d.numint
                WHERE
                        d.id_cia = pin_id_cia
                    AND c.situac = 'F'
                    AND d.numintfac = r_main.numint;

            EXCEPTION
                WHEN no_data_found THEN
                    r_estado_de_cuenta_grupo_economico.saldopercep := NULL;
            END;

            IF ( r_estado_de_cuenta_grupo_economico.saldopercep IS NULL ) THEN
                r_estado_de_cuenta_grupo_economico.saldopercep := 0;
            END IF;

            r_estado_de_cuenta_grupo_economico.saldopercep := r_main.tpercepcion - r_estado_de_cuenta_grupo_economico.saldopercep;
        END IF;

        r_estado_de_cuenta_grupo_economico.saldo := r_estado_de_cuenta_grupo_economico.saldo + r_estado_de_cuenta_grupo_economico.
        saldopercep;
        r_estado_de_cuenta_grupo_economico.saldocalc := r_main.tdocumento;
        PIPE ROW ( r_estado_de_cuenta_grupo_economico );
    END LOOP;

END;

/
