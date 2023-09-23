--------------------------------------------------------
--  DDL for Function SP_CONTABILIDAD_CUENTAS_PARA_ASIENTOS_CXCOBRAR
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_CONTABILIDAD_CUENTAS_PARA_ASIENTOS_CXCOBRAR" (
    pin_id_cia    IN NUMBER,
    pin_libro     IN VARCHAR2,
    pin_periodo   IN NUMBER,
    pin_mes       IN NUMBER,
    pin_secuencia IN NUMBER,
    pin_usuario   IN VARCHAR2
) RETURN tbl_detalle_asiento
    PIPELINED
AS

    rasiendet      rec_detalle_asiento := rec_detalle_asiento(NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL);
    CURSOR cur_dcta104 IS
    SELECT
        p.tipdep,
        p.cuenta,
        p.dh,
        p.tipmon,
        p.op,
        p.deposito,
        p.tcamb01,
        p.tcamb02,
        p.impor01,
        p.impor02,
        p.situac,
        p.concep
    FROM
        dcta104 p
    WHERE
        ( p.id_cia = pin_id_cia )
        AND ( p.libro = pin_libro )
        AND ( p.periodo = pin_periodo )
        AND ( p.mes = pin_mes )
        AND ( p.secuencia = pin_secuencia );

    CURSOR cur_dcta103 IS
    SELECT
        d.codcli,
        c.razonc,
        d.serie,
        d.numero,
        d.femisi,
        d.tipmon           AS tmondoc,
        d.importe,
        d.tipcam           AS tipcamdoc,
        p.tipcan,
        p.cuenta,
        p.dh,
        p.tipmon           AS tmonpag,
        p.amorti,
        p.tcamb01,
        p.tcamb02,
        p.impor01,
        p.impor02,
        p.situac,
        td.codsunat,
        CAST(
            CASE
                WHEN d.tipmon = 'PEN' THEN
                    p.impor01
                ELSE
                    p.impor02
            END
        AS NUMERIC(16, 2)) AS amortiza,
        b.cuentacob,
        b.cuentades,
        b.cuentagar,
        b.cuentaenvios,
        d2.tippla          AS tippla,
        d.protes,
        d.operac,
        b.cuentaord01,
        b.cuentacon,
        b.cuentacprot,
        b.cuentacar,
        p.deposito
    FROM
        dcta103      p
        LEFT OUTER JOIN dcta100      d ON ( d.id_cia = pin_id_cia )
                                     AND ( d.numint = p.numint )
        LEFT OUTER JOIN cliente      c ON ( c.id_cia = pin_id_cia )
                                     AND ( c.codcli = d.codcli )
        LEFT OUTER JOIN tdoccobranza td ON ( td.id_cia = pin_id_cia )
                                           AND ( td.tipdoc = d.tipdoc )
        /*agregado*/
        LEFT OUTER JOIN tbancos      b ON ( b.id_cia = p.id_cia )
                                     AND ( b.codban = d.codban )
        LEFT OUTER JOIN dcta102      d2 ON ( d2.id_cia = p.id_cia )
                                      AND ( d2.libro = p.libro )
                                      AND ( d2.periodo = p.periodo )
                                      AND ( d2.mes = p.mes )
                                      AND ( d2.secuencia = p.mes )
    WHERE
        ( p.id_cia = pin_id_cia )
        AND ( p.libro = pin_libro )
        AND ( p.periodo = pin_periodo )
        AND ( p.mes = pin_mes )
        AND ( p.secuencia = pin_secuencia );

    CURSOR cur_dcta113 IS
    SELECT
        p.swchksepaga,
        d.codcli,
        c.razonc,
        d.femisi,
        d.serie,
        d.numero,
        d.tipmon AS tmondoc,
        d.importe,
        d.dh     AS dc_dh,
        p.cuenta,
        p.dh,
        p.tipmon AS tmonpag,
        d.tipcam AS dtipcam,
        p.amorti,
        p.situac,
        td.codsunat
    FROM
        dcta113      p
        LEFT OUTER JOIN dcta100      d ON ( d.id_cia = pin_id_cia )
                                     AND ( d.numint = p.numint )
        LEFT OUTER JOIN cliente      c ON ( c.id_cia = pin_id_cia )
                                     AND ( c.codcli = d.codcli )
        LEFT OUTER JOIN tdoccobranza td ON ( td.id_cia = pin_id_cia )
                                           AND ( td.tipdoc = d.tipdoc )
    WHERE
        ( p.id_cia = pin_id_cia )
        AND ( p.libro = pin_libro )
        AND ( p.periodo = pin_periodo )
        AND ( p.mes = pin_mes )
        AND ( p.secuencia = pin_secuencia );

    CURSOR cur_prov104 IS
    SELECT
        p.libro,
        p.periodo,
        p.mes,
        p.secuencia,
        p.item,
        p.tipdep,
        p.doccan,
        p.cuenta,
        p.dh,
        p.tipmon,
        p.codban,
        p.op,
        p.agencia,
        p.tipcam,
        p.deposito,
        p.tcamb01,
        p.tcamb02,
        p.impor01,
        p.impor02,
        p.pagomn,
        p.pagome,
        p.situac,
        p.concep,
        p.retcodcli,
        p.retserie,
        p.retnumero,
        b.descri  AS desban,
        tp.descri AS dtipdep,
        c.razonc  AS retrazonc,
        p.codigo,
        p.razon,
        p.tdocum,
        td.descri AS dtipdoc,
        p.serie,
        p.numero
    FROM
        prov104 p
        LEFT OUTER JOIN tbancos b ON ( b.id_cia = p.id_cia )
                                     AND ( b.codban = p.codban )
        LEFT OUTER JOIN m_pago  tp ON ( tp.id_cia = p.id_cia )
                                     AND ( tp.codigo = p.tipdep )
        LEFT OUTER JOIN cliente c ON ( c.id_cia = p.id_cia )
                                     AND ( c.codcli = p.retcodcli )
        LEFT OUTER JOIN tdocume td ON ( td.id_cia = p.id_cia )
                                      AND ( td.codigo = p.tdocum )
    WHERE
        ( p.id_cia = pin_id_cia )
        AND ( p.libro = pin_libro )
        AND ( p.periodo = pin_periodo )
        AND ( p.mes = pin_mes )
        AND ( p.secuencia = pin_secuencia );

    CURSOR cur_prov103 IS
    SELECT
        p.swchkretiene,
        d.codcli,
        c.razonc,
        d.tipdoc,
        p.docume,
        d.serie,
        d.numero,
        d.femisi,
        d.tipmon AS tmondoc,
        d.importe,
        p.amorti,
        d.tipcam AS tipcamdoc,
        p.impor01,
        p.impor02,
        p.tipcan,
        p.cuenta,
        p.dh,
        p.tipmon AS tmonpag,
        p.situac
    FROM
        prov103 p
        LEFT OUTER JOIN prov100 d ON ( d.id_cia = pin_id_cia )
                                     AND ( d.tipo = p.tipo
                                           AND d.docu = p.docu )
        LEFT OUTER JOIN cliente c ON ( c.id_cia = pin_id_cia )
                                     AND ( c.codcli = d.codcli )
    WHERE
        ( p.id_cia = pin_id_cia )
        AND ( p.libro = pin_libro )
        AND ( p.periodo = pin_periodo )
        AND ( p.mes = pin_mes )
        AND ( p.secuencia = pin_secuencia )
    ORDER BY
        c.razonc,
        d.tipdoc,
        d.femisi,
        p.item;

    CURSOR cur_dcta105 (
        pid_cia    NUMBER,
        plibro     VARCHAR2,
        pperiodo   NUMBER,
        pmes       NUMBER,
        psecuencia NUMBER
    ) IS
    SELECT
        p.codcli,
        c.razonc,
        p.series           AS serie,
        p.numdoc           AS numero,
        p.femisi,
        p.importe,
        p.tipcam,
        p.tipcan,
        p.cuenta,
        p.dh,
        p.tipmon,
        0                  AS amorti,
        p.tcamb01,
        p.tcamb02,
        p.impor01,
        p.impor02,
        p.situac,
        td.codsunat,
        b.cuentaord02,
        b.cuentaord01,
        b.cuentacob,
        CAST(
            CASE
                WHEN p.tipmon = 'PEN' THEN
                    p.impor01
                ELSE
                    p.impor02
            END
        AS NUMERIC(16, 2)) AS amortiza,
        p.codban
    FROM
        dcta105      p
        LEFT OUTER JOIN cliente      c ON ( c.id_cia = p.id_cia )
                                     AND ( c.codcli = p.codcli )
        LEFT OUTER JOIN tdoccobranza td ON ( td.id_cia = p.id_cia )
                                           AND ( td.tipdoc = p.tipdoc )
        LEFT OUTER JOIN tbancos      b ON ( b.id_cia = p.id_cia )
                                     AND ( b.codban = p.codban )
    WHERE
        ( p.id_cia = pid_cia )
        AND ( p.libro = pin_libro )
        AND ( p.periodo = pperiodo )
        AND ( p.mes = pmes )
        AND ( p.secuencia = psecuencia );

    CURSOR cur_prov113 IS
    SELECT
        d.codcli,
        c.razonc,
        d.tipdoc,
        d.femisi,
        d.tipmon  AS tmondoc,
        d.tipcam  AS doctipcam,
        d.importe,
        p.tipcan,
        p.cuenta,
        p.dh,
        p.tipmon  AS tmonpag,
        d.serie,
        d.numero,
        p.amorti,
        p.tcamb01,
        p.tcamb02,
        p.impor01,
        p.impor02,
        p.situac,
        td.codigo AS codsunat
    FROM
        prov113 p
        LEFT OUTER JOIN prov100 d ON ( d.id_cia = pin_id_cia )
                                     AND ( d.tipo = p.tipo
                                           AND d.docu = p.docu )
        LEFT OUTER JOIN cliente c ON ( c.id_cia = pin_id_cia )
                                     AND ( c.codcli = d.codcli )
        LEFT OUTER JOIN tdocume td ON ( td.id_cia = pin_id_cia )
                                      AND ( td.codigo = d.tipdoc )
    WHERE
        ( p.id_cia = pin_id_cia )
        AND ( p.libro = pin_libro )
        AND ( p.periodo = pin_periodo )
        AND ( p.mes = pin_mes )
        AND ( p.secuencia = pin_secuencia );

    CURSOR cur_prov105 IS
    SELECT
        p.codcli,
        c.razonc,
        p.series           AS serie,
        p.numdoc           AS numero,
        p.femisi,
        p.importe,
        p.tipcam,
        p.tipcan,
        p.cuenta,
        p.dh,
        p.tipmon,
        0                  AS amorti,
        p.tcamb01,
        p.tcamb02,
        p.impor01,
        p.impor02,
        p.situac,
        td.codigo          AS codsunat,
        b.cuentaord02,
        b.cuentaord01,
        b.cuentacob,
        CAST(
            CASE
                WHEN p.tipmon = 'PEN' THEN
                    p.impor01
                ELSE
                    p.impor02
            END
        AS NUMERIC(16, 2)) AS amortiza,
        p.codban,
        p.refere,
        p.refere02
    FROM
        prov105 p
        LEFT OUTER JOIN cliente c ON ( c.id_cia = pin_id_cia )
                                     AND ( c.codcli = p.codcli )
        LEFT OUTER JOIN tdocume td ON ( td.id_cia = pin_id_cia )
                                      AND ( td.codigo = p.tipdoc )
        LEFT OUTER JOIN tbancos b ON ( b.id_cia = pin_id_cia )
                                     AND ( b.codban = p.codban )
    WHERE
        ( p.id_cia = pin_id_cia )
        AND ( p.libro = pin_libro )
        AND ( p.periodo = pin_periodo )
        AND ( p.mes = pin_mes )
        AND ( p.secuencia = pin_secuencia );

    item           NUMBER := 0;
    v_cuenta       VARCHAR2(16) := '';
    v_dh           VARCHAR2(2) := '';
    v_tipo         NUMBER := 0;
    v_regcomcol    NUMBER := 0;
    v_vstrg        VARCHAR2(1) := '';
    v_femisi_d102  DATE;
    v_moneda_d102  VARCHAR2(5);
    v_concep_d102  VARCHAR2(150) := '';
    v_codbanretsol VARCHAR(3) := '';
    v_codbanretdol VARCHAR(3) := '';
    v_girara       VARCHAR2(70) := '';
    v_referencia   VARCHAR2(30) := '';
    v_prov103_rec  cur_prov103%rowtype;
    v_codcli       VARCHAR2(20) := '';
    v_razonc       VARCHAR2(80) := '';
    v_concep_p102  VARCHAR2(150) := '';
    v_femisi_p102  DATE;
    v_moneda_p102  VARCHAR2(5);
    v_f371         VARCHAR2(1);
BEGIN
    BEGIN

    /*Cuenta de envio a bancos se generar por separado*/
        BEGIN
            SELECT
                vstrg
            INTO v_f371
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 371;

        EXCEPTION
            WHEN no_data_found THEN
                v_f371 := 'N';
        END;

        SELECT
            femisi,
            TRIM(tipmon),
            concep
        INTO
            v_femisi_d102,
            v_moneda_d102,
            v_concep_d102
        FROM
            dcta102
        WHERE
                id_cia = pin_id_cia
            AND libro = pin_libro
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND secuencia = pin_secuencia;

    EXCEPTION
        WHEN no_data_found THEN
            v_femisi_d102 := NULL;
            v_moneda_d102 := NULL;
            v_concep_p102 := NULL;
    END;

    BEGIN
        SELECT
		/*
            CASE
                WHEN femisi IS NULL THEN
                    v_femisi
                ELSE
                    femisi
            END AS femisi,
            CASE
                WHEN tipmon IS NULL THEN
                    v_moneda
                ELSE
                    TRIM(tipmon)
            END AS moneda,*/
            femisi,
            tipmon AS moneda,
            girara,
            referencia,
            concep
        INTO
            v_femisi_p102,
            v_moneda_p102,
            v_girara,
            v_referencia,
            v_concep_p102
        FROM
            prov102
        WHERE
                id_cia = pin_id_cia
            AND libro = pin_libro
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND secuencia = pin_secuencia;

    EXCEPTION
        WHEN no_data_found THEN
            v_femisi_p102 := NULL;
            v_moneda_p102 := NULL;
            v_girara := '';
            v_referencia := '';
            v_concep_p102 := '';
    END;

    FOR reg_dcta104 IN cur_dcta104 LOOP
        IF reg_dcta104.situac <> 'J' THEN
            item := item + 1;
            rasiendet.id_cia := pin_id_cia;
            rasiendet.periodo := pin_periodo;
            rasiendet.mes := pin_mes;
            rasiendet.libro := pin_libro;
            rasiendet.asiento := pin_secuencia;
            rasiendet.item := item;
            rasiendet.sitem := 0;
            rasiendet.concep := substr(v_concep_d102, 1, 74); --reg_dcta104.concep;
            rasiendet.fecha := v_femisi_d102;
            rasiendet.tasien := 66;
            rasiendet.topera := reg_dcta104.tipdep;
            rasiendet.cuenta := reg_dcta104.cuenta;
            IF reg_dcta104.deposito < 0 THEN
                CASE
                    WHEN reg_dcta104.dh = 'D' THEN
                        rasiendet.dh := 'H';
                    WHEN reg_dcta104.dh = 'H' THEN
                        rasiendet.dh := 'D';
                END CASE;
            ELSE
                rasiendet.dh := reg_dcta104.dh;
            END IF;

            rasiendet.moneda := reg_dcta104.tipmon;
            rasiendet.importe := abs(reg_dcta104.deposito);
            rasiendet.impor01 := abs(reg_dcta104.impor01);
            rasiendet.impor02 := abs(reg_dcta104.impor02);
            rasiendet.debe := 0;
            rasiendet.debe01 := 0;
            rasiendet.debe02 := 0;
            rasiendet.haber := 0;
            rasiendet.haber01 := 0;
            rasiendet.haber02 := 0;
            CASE
                WHEN rasiendet.dh = 'D' THEN
                    rasiendet.debe := rasiendet.importe;
                    rasiendet.debe01 := rasiendet.impor01;
                    rasiendet.debe02 := rasiendet.impor02;
                WHEN rasiendet.dh = 'H' THEN
                    rasiendet.haber := rasiendet.importe;
                    rasiendet.haber01 := rasiendet.impor01;
                    rasiendet.haber02 := rasiendet.impor02;
            END CASE;

            rasiendet.tcambio01 := reg_dcta104.tcamb01;
            rasiendet.tcambio02 := reg_dcta104.tcamb02;
            rasiendet.ccosto := ' ';
            rasiendet.proyec := ' ';
            rasiendet.subcco := ' ';
            rasiendet.ctaalternativa := ' ';
            rasiendet.tipo := 0;
            rasiendet.docume := 0;
            rasiendet.codigo := ' ';
            rasiendet.razon := substr(reg_dcta104.concep, 1, 74);
            rasiendet.tident := ' ';
            rasiendet.dident := ' ';
            rasiendet.tdocum := ' ';
            rasiendet.serie := ' ';
            rasiendet.numero := reg_dcta104.op;
            rasiendet.fdocum := v_femisi_d102;
            rasiendet.usuari := pin_usuario;
            rasiendet.fcreac := current_date;
            rasiendet.factua := current_date;
            rasiendet.regcomcol := 0;
            rasiendet.swprovicion := 'N';
            rasiendet.saldo := 0;
            rasiendet.swgasoper := 1;
            rasiendet.codporret := '';
            rasiendet.swchkconcilia := 'N';
            PIPE ROW ( rasiendet );
        END IF;
    END LOOP;

    FOR reg_dcta103 IN cur_dcta103 LOOP
         -- SI ES UNA PLANILLA 118,136,137,138,143,144
        rasiendet := rec_detalle_asiento(NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL);

        IF reg_dcta103.tippla IN ( 118, 136, 137, 138, 143,
                                   144 ) THEN
        /********************************/
         /*  Planilla de envio al banco  */
         /********************************/
            IF (
                reg_dcta103.tippla = 118
                AND reg_dcta103.situac <> 'J'
            ) THEN
                -- GENERANDO EL PRIMER ASIENTO
                item := item + 1;
                rasiendet.id_cia := pin_id_cia;
                rasiendet.periodo := pin_periodo;
                rasiendet.mes := pin_mes;
                rasiendet.libro := pin_libro;
                rasiendet.asiento := pin_secuencia;
                rasiendet.item := item;
                rasiendet.sitem := 0;
                rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.fecha := reg_dcta103.femisi;
                rasiendet.tasien := 66;
                rasiendet.topera := reg_dcta103.tipcan;
                IF ( v_f371 = 'S' ) THEN
                    rasiendet.cuenta :=
                        CASE
                            WHEN ( reg_dcta103.tipcan = 51 ) THEN
                                reg_dcta103.cuentacob
                            WHEN ( reg_dcta103.tipcan = 52 ) THEN
                                reg_dcta103.cuentades
                            WHEN ( reg_dcta103.tipcan = 53 ) THEN
                                reg_dcta103.cuentagar
                            ELSE ''
                        END;
                ELSE
                    rasiendet.cuenta := reg_dcta103.cuentaenvios;
                END IF;

                rasiendet.dh :=
                    CASE
                        WHEN ( reg_dcta103.dh = 'D' ) THEN
                            'H'
                        WHEN ( reg_dcta103.dh = 'H' ) THEN
                            'D'
                    END;

                rasiendet.moneda := reg_dcta103.tmonpag;
                IF reg_dcta103.tmonpag = 'PEN' THEN
                    rasiendet.tcambio01 := 1;
                    rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                ELSE
                    rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                    rasiendet.tcambio02 := 1;
                END IF;

                rasiendet.importe := reg_dcta103.amorti;
                IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                    rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                    rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                ELSE
                    IF reg_dcta103.tmondoc = 'PEN' THEN
                        rasiendet.impor01 := reg_dcta103.impor01;
                        rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                        rasiendet.importe := rasiendet.impor02;
                    ELSE
                        rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                        rasiendet.impor02 := reg_dcta103.impor02;
                        rasiendet.importe := rasiendet.impor01;
                    END IF;
                END IF;

                rasiendet.debe := 0;
                rasiendet.debe01 := 0;
                rasiendet.debe02 := 0;
                rasiendet.haber := 0;
                rasiendet.haber01 := 0;
                rasiendet.haber02 := 0;
                CASE
                    WHEN rasiendet.dh = 'D' THEN
                        rasiendet.debe := rasiendet.importe;
                        rasiendet.debe01 := rasiendet.impor01;
                        rasiendet.debe02 := rasiendet.impor02;
                    WHEN rasiendet.dh = 'H' THEN
                        rasiendet.haber := rasiendet.importe;
                        rasiendet.haber01 := rasiendet.impor01;
                        rasiendet.haber02 := rasiendet.impor02;
                END CASE;

                rasiendet.ccosto := ' ';
                rasiendet.proyec := ' ';
                rasiendet.subcco := ' ';
                rasiendet.ctaalternativa := ' ';
                rasiendet.tipo := 0;
                rasiendet.docume := 0;
                rasiendet.codigo := reg_dcta103.codcli;
                rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.tident := ' ';
                rasiendet.dident := ' ';
                rasiendet.tdocum := reg_dcta103.codsunat;
                rasiendet.serie := reg_dcta103.serie;
                rasiendet.numero := reg_dcta103.numero;
                rasiendet.fdocum := reg_dcta103.femisi;
                rasiendet.usuari := pin_usuario;
                rasiendet.fcreac := current_date;
                rasiendet.factua := current_date;
                rasiendet.regcomcol := 0;
                rasiendet.swprovicion := 'N';
                rasiendet.saldo := 0;
                rasiendet.swgasoper := 1;
                rasiendet.codporret := '';
                rasiendet.swchkconcilia := 'N';
                PIPE ROW ( rasiendet );
                -- GENERANDO EL SEGUNDO ASIENTO  
                item := item + 1;
                rasiendet.id_cia := pin_id_cia;
                rasiendet.periodo := pin_periodo;
                rasiendet.mes := pin_mes;
                rasiendet.libro := pin_libro;
                rasiendet.asiento := pin_secuencia;
                rasiendet.item := item;
                rasiendet.sitem := 0;
                rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.fecha := reg_dcta103.femisi;
                rasiendet.tasien := 66;
                rasiendet.topera := reg_dcta103.tipcan;
                rasiendet.cuenta := reg_dcta103.cuenta;
                rasiendet.dh := reg_dcta103.dh;
                rasiendet.moneda := reg_dcta103.tmonpag;
                IF reg_dcta103.tmonpag = 'PEN' THEN
                    rasiendet.tcambio01 := 1;
                    rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                ELSE
                    rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                    rasiendet.tcambio02 := 1;
                END IF;

                rasiendet.importe := reg_dcta103.amorti;
                IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                    rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                    rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                ELSE
                    IF reg_dcta103.tmondoc = 'PEN' THEN
                        rasiendet.impor01 := reg_dcta103.impor01;
                        rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                        rasiendet.importe := rasiendet.impor02;
                    ELSE
                        rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                        rasiendet.impor02 := reg_dcta103.impor02;
                        rasiendet.importe := rasiendet.impor01;
                    END IF;
                END IF;

                rasiendet.debe := 0;
                rasiendet.debe01 := 0;
                rasiendet.debe02 := 0;
                rasiendet.haber := 0;
                rasiendet.haber01 := 0;
                rasiendet.haber02 := 0;
                CASE
                    WHEN rasiendet.dh = 'D' THEN
                        rasiendet.debe := rasiendet.importe;
                        rasiendet.debe01 := rasiendet.impor01;
                        rasiendet.debe02 := rasiendet.impor02;
                    WHEN rasiendet.dh = 'H' THEN
                        rasiendet.haber := rasiendet.importe;
                        rasiendet.haber01 := rasiendet.impor01;
                        rasiendet.haber02 := rasiendet.impor02;
                END CASE;

                rasiendet.ccosto := ' ';
                rasiendet.proyec := ' ';
                rasiendet.subcco := ' ';
                rasiendet.ctaalternativa := ' ';
                rasiendet.tipo := 0;
                rasiendet.docume := 0;
                rasiendet.codigo := reg_dcta103.codcli;
                rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.tident := ' ';
                rasiendet.dident := ' ';
                rasiendet.tdocum := reg_dcta103.codsunat;
                rasiendet.serie := reg_dcta103.serie;
                rasiendet.numero := reg_dcta103.numero;
                rasiendet.fdocum := reg_dcta103.femisi;
                rasiendet.usuari := pin_usuario;
                rasiendet.fcreac := current_date;
                rasiendet.factua := current_date;
                rasiendet.regcomcol := 0;
                rasiendet.swprovicion := 'N';
                rasiendet.saldo := 0;
                rasiendet.swgasoper := 1;
                rasiendet.codporret := '';
                rasiendet.swchkconcilia := 'N';
                PIPE ROW ( rasiendet );

         /************************************************/
         /*  Planilla de Retiro de documentos del banco  */
         /************************************************/
            ELSIF (
                reg_dcta103.tippla = 136
                AND reg_dcta103.situac <> 'J'
                AND reg_dcta103.protes = 0
            ) THEN
                -- IMPRIMIENDO EL PRIMER ASIENTO
                item := item + 1;
                rasiendet.id_cia := pin_id_cia;
                rasiendet.periodo := pin_periodo;
                rasiendet.mes := pin_mes;
                rasiendet.libro := pin_libro;
                rasiendet.asiento := pin_secuencia;
                rasiendet.item := item;
                rasiendet.sitem := 0;
                rasiendet.fecha := reg_dcta103.femisi;
                rasiendet.tasien := 66;
                rasiendet.topera := reg_dcta103.tipcan;
                rasiendet.codigo := reg_dcta103.codcli;
                rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                IF ( v_f371 = 'S' ) THEN
                    rasiendet.cuenta :=
                        CASE
                            WHEN ( reg_dcta103.tipcan = 51 ) THEN
                                reg_dcta103.cuentacob
                            WHEN ( reg_dcta103.tipcan = 52 ) THEN
                                reg_dcta103.cuentades
                            WHEN ( reg_dcta103.tipcan = 53 ) THEN
                                reg_dcta103.cuentagar
                            ELSE ''
                        END;
                ELSE
                    rasiendet.cuenta := reg_dcta103.cuentaenvios;
                END IF;

                rasiendet.dh := reg_dcta103.dh;
                rasiendet.moneda := reg_dcta103.tmonpag;
                IF reg_dcta103.tmonpag = 'PEN' THEN
                    rasiendet.tcambio01 := 1;
                    rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                ELSE
                    rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                    rasiendet.tcambio02 := 1;
                END IF;

                rasiendet.importe := reg_dcta103.amorti;
                IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                    rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                    rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                ELSE
                    IF reg_dcta103.tmondoc = 'PEN' THEN
                        rasiendet.impor01 := reg_dcta103.impor01;
                        rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                        rasiendet.importe := rasiendet.impor02;
                    ELSE
                        rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                        rasiendet.impor02 := reg_dcta103.impor02;
                        rasiendet.importe := rasiendet.impor01;
                    END IF;
                END IF;

                rasiendet.debe := 0;
                rasiendet.debe01 := 0;
                rasiendet.debe02 := 0;
                rasiendet.haber := 0;
                rasiendet.haber01 := 0;
                rasiendet.haber02 := 0;
                CASE
                    WHEN rasiendet.dh = 'D' THEN
                        rasiendet.debe := rasiendet.importe;
                        rasiendet.debe01 := rasiendet.impor01;
                        rasiendet.debe02 := rasiendet.impor02;
                    WHEN rasiendet.dh = 'H' THEN
                        rasiendet.haber := rasiendet.importe;
                        rasiendet.haber01 := rasiendet.impor01;
                        rasiendet.haber02 := rasiendet.impor02;
                END CASE;
                -- GENERICO
                rasiendet.ccosto := ' ';
                rasiendet.proyec := ' ';
                rasiendet.subcco := ' ';
                rasiendet.ctaalternativa := ' ';
                rasiendet.tipo := 0;
                rasiendet.docume := 0;
                rasiendet.tident := ' ';
                rasiendet.dident := ' ';
                rasiendet.tdocum := reg_dcta103.codsunat;
                rasiendet.serie := reg_dcta103.serie;
                rasiendet.numero := reg_dcta103.numero;
                rasiendet.fdocum := reg_dcta103.femisi;
                rasiendet.usuari := pin_usuario;
                rasiendet.fcreac := current_date;
                rasiendet.factua := current_date;
                rasiendet.regcomcol := 0;
                rasiendet.swprovicion := 'N';
                rasiendet.saldo := 0;
                rasiendet.swgasoper := 1;
                rasiendet.codporret := '';
                rasiendet.swchkconcilia := 'N';
                PIPE ROW ( rasiendet );
                -- IMPRIMIENDO EL SEGUNDO ASIENTO
                item := item + 1;
                rasiendet.id_cia := pin_id_cia;
                rasiendet.periodo := pin_periodo;
                rasiendet.mes := pin_mes;
                rasiendet.libro := pin_libro;
                rasiendet.asiento := pin_secuencia;
                rasiendet.item := item;
                rasiendet.sitem := 0;
                rasiendet.fecha := reg_dcta103.femisi;
                rasiendet.tasien := 66;
                rasiendet.topera := reg_dcta103.tipcan;
                rasiendet.codigo := reg_dcta103.codcli;
                rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.cuenta := reg_dcta103.cuenta;
                rasiendet.dh :=
                    CASE
                        WHEN ( reg_dcta103.dh = 'D' ) THEN
                            'H'
                        WHEN ( reg_dcta103.dh = 'H' ) THEN
                            'D'
                    END;

                rasiendet.moneda := reg_dcta103.tmonpag;
                IF reg_dcta103.tmonpag = 'PEN' THEN
                    rasiendet.tcambio01 := 1;
                    rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                ELSE
                    rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                    rasiendet.tcambio02 := 1;
                END IF;

                rasiendet.importe := reg_dcta103.amorti;
                IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                    rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                    rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                ELSE
                    IF reg_dcta103.tmondoc = 'PEN' THEN
                        rasiendet.impor01 := reg_dcta103.impor01;
                        rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                        rasiendet.importe := rasiendet.impor02;
                    ELSE
                        rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                        rasiendet.impor02 := reg_dcta103.impor02;
                        rasiendet.importe := rasiendet.impor01;
                    END IF;
                END IF;

                rasiendet.debe := 0;
                rasiendet.debe01 := 0;
                rasiendet.debe02 := 0;
                rasiendet.haber := 0;
                rasiendet.haber01 := 0;
                rasiendet.haber02 := 0;
                CASE
                    WHEN rasiendet.dh = 'D' THEN
                        rasiendet.debe := rasiendet.importe;
                        rasiendet.debe01 := rasiendet.impor01;
                        rasiendet.debe02 := rasiendet.impor02;
                    WHEN rasiendet.dh = 'H' THEN
                        rasiendet.haber := rasiendet.importe;
                        rasiendet.haber01 := rasiendet.impor01;
                        rasiendet.haber02 := rasiendet.impor02;
                END CASE;
                -- GENERICO
                rasiendet.ccosto := ' ';
                rasiendet.proyec := ' ';
                rasiendet.subcco := ' ';
                rasiendet.ctaalternativa := ' ';
                rasiendet.tipo := 0;
                rasiendet.docume := 0;
                rasiendet.tident := ' ';
                rasiendet.dident := ' ';
                rasiendet.tdocum := reg_dcta103.codsunat;
                rasiendet.serie := reg_dcta103.serie;
                rasiendet.numero := reg_dcta103.numero;
                rasiendet.fdocum := reg_dcta103.femisi;
                rasiendet.usuari := pin_usuario;
                rasiendet.fcreac := current_date;
                rasiendet.factua := current_date;
                rasiendet.regcomcol := 0;
                rasiendet.swprovicion := 'N';
                rasiendet.saldo := 0;
                rasiendet.swgasoper := 1;
                rasiendet.codporret := '';
                rasiendet.swchkconcilia := 'N';
                PIPE ROW ( rasiendet );
        /**************************************************/
         /*  Planilla de protestos de documentos en banco  */
         /**************************************************/
            ELSIF (
                reg_dcta103.tippla = 137
                AND reg_dcta103.situac <> 'J'
            ) THEN
                -- IMPRIMIENDO EL PRIMER ASIENTO
                item := item + 1;
                rasiendet.id_cia := pin_id_cia;
                rasiendet.periodo := pin_periodo;
                rasiendet.mes := pin_mes;
                rasiendet.libro := pin_libro;
                rasiendet.asiento := pin_secuencia;
                rasiendet.item := item;
                rasiendet.sitem := 0;
                rasiendet.fecha := reg_dcta103.femisi;
                rasiendet.tasien := 66;
                rasiendet.topera := reg_dcta103.tipcan;
                rasiendet.codigo := reg_dcta103.codcli;
                rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.cuenta := reg_dcta103.cuenta;
                rasiendet.dh :=
                    CASE
                        WHEN ( reg_dcta103.dh = 'D' ) THEN
                            'H'
                        WHEN ( reg_dcta103.dh = 'H' ) THEN
                            'D'
                    END;

                rasiendet.moneda := reg_dcta103.tmonpag;
                IF reg_dcta103.tmonpag = 'PEN' THEN
                    rasiendet.tcambio01 := 1;
                    rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                ELSE
                    rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                    rasiendet.tcambio02 := 1;
                END IF;

                rasiendet.importe := reg_dcta103.amorti;
                IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                    rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                    rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                ELSE
                    IF reg_dcta103.tmondoc = 'PEN' THEN
                        rasiendet.impor01 := reg_dcta103.impor01;
                        rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                        rasiendet.importe := rasiendet.impor02;
                    ELSE
                        rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                        rasiendet.impor02 := reg_dcta103.impor02;
                        rasiendet.importe := rasiendet.impor01;
                    END IF;
                END IF;

                rasiendet.debe := 0;
                rasiendet.debe01 := 0;
                rasiendet.debe02 := 0;
                rasiendet.haber := 0;
                rasiendet.haber01 := 0;
                rasiendet.haber02 := 0;
                CASE
                    WHEN rasiendet.dh = 'D' THEN
                        rasiendet.debe := rasiendet.importe;
                        rasiendet.debe01 := rasiendet.impor01;
                        rasiendet.debe02 := rasiendet.impor02;
                    WHEN rasiendet.dh = 'H' THEN
                        rasiendet.haber := rasiendet.importe;
                        rasiendet.haber01 := rasiendet.impor01;
                        rasiendet.haber02 := rasiendet.impor02;
                END CASE;
                -- GENERICO
                rasiendet.ccosto := ' ';
                rasiendet.proyec := ' ';
                rasiendet.subcco := ' ';
                rasiendet.ctaalternativa := ' ';
                rasiendet.tipo := 0;
                rasiendet.docume := 0;
                rasiendet.tident := ' ';
                rasiendet.dident := ' ';
                rasiendet.tdocum := reg_dcta103.codsunat;
                rasiendet.serie := reg_dcta103.serie;
                rasiendet.numero := reg_dcta103.numero;
                rasiendet.fdocum := reg_dcta103.femisi;
                rasiendet.usuari := pin_usuario;
                rasiendet.fcreac := current_date;
                rasiendet.factua := current_date;
                rasiendet.regcomcol := 0;
                rasiendet.swprovicion := 'N';
                rasiendet.saldo := 0;
                rasiendet.swgasoper := 1;
                rasiendet.codporret := '';
                rasiendet.swchkconcilia := 'N';
                PIPE ROW ( rasiendet );

                -- IMPRIMIENDO EL SEGUNDO ASIENTO
                item := item + 1;
                rasiendet.id_cia := pin_id_cia;
                rasiendet.periodo := pin_periodo;
                rasiendet.mes := pin_mes;
                rasiendet.libro := pin_libro;
                rasiendet.asiento := pin_secuencia;
                rasiendet.item := item;
                rasiendet.sitem := 0;
                rasiendet.fecha := reg_dcta103.femisi;
                rasiendet.tasien := 66;
                rasiendet.topera := reg_dcta103.tipcan;
                rasiendet.codigo := reg_dcta103.codcli;
                rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                IF ( v_f371 = 'S' ) THEN
                    rasiendet.cuenta :=
                        CASE
                            WHEN ( reg_dcta103.tipcan = 51 ) THEN
                                reg_dcta103.cuentacob
                            WHEN ( reg_dcta103.tipcan = 52 ) THEN
                                reg_dcta103.cuentades
                            WHEN ( reg_dcta103.tipcan = 53 ) THEN
                                reg_dcta103.cuentagar
                            ELSE ''
                        END;
                ELSE
                    rasiendet.cuenta := reg_dcta103.cuentaenvios;
                END IF;

                rasiendet.dh := reg_dcta103.dh;
                rasiendet.moneda := reg_dcta103.tmonpag;
                IF reg_dcta103.tmonpag = 'PEN' THEN
                    rasiendet.tcambio01 := 1;
                    rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                ELSE
                    rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                    rasiendet.tcambio02 := 1;
                END IF;

                rasiendet.importe := reg_dcta103.amorti;
                IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                    rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                    rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                ELSE
                    IF reg_dcta103.tmondoc = 'PEN' THEN
                        rasiendet.impor01 := reg_dcta103.impor01;
                        rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                        rasiendet.importe := rasiendet.impor02;
                    ELSE
                        rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                        rasiendet.impor02 := reg_dcta103.impor02;
                        rasiendet.importe := rasiendet.impor01;
                    END IF;
                END IF;

                rasiendet.debe := 0;
                rasiendet.debe01 := 0;
                rasiendet.debe02 := 0;
                rasiendet.haber := 0;
                rasiendet.haber01 := 0;
                rasiendet.haber02 := 0;
                CASE
                    WHEN rasiendet.dh = 'D' THEN
                        rasiendet.debe := rasiendet.importe;
                        rasiendet.debe01 := rasiendet.impor01;
                        rasiendet.debe02 := rasiendet.impor02;
                    WHEN rasiendet.dh = 'H' THEN
                        rasiendet.haber := rasiendet.importe;
                        rasiendet.haber01 := rasiendet.impor01;
                        rasiendet.haber02 := rasiendet.impor02;
                END CASE;
                -- GENERICO
                rasiendet.ccosto := ' ';
                rasiendet.proyec := ' ';
                rasiendet.subcco := ' ';
                rasiendet.ctaalternativa := ' ';
                rasiendet.tipo := 0;
                rasiendet.docume := 0;
                rasiendet.tident := ' ';
                rasiendet.dident := ' ';
                rasiendet.tdocum := reg_dcta103.codsunat;
                rasiendet.serie := reg_dcta103.serie;
                rasiendet.numero := reg_dcta103.numero;
                rasiendet.fdocum := reg_dcta103.femisi;
                rasiendet.usuari := pin_usuario;
                rasiendet.fcreac := current_date;
                rasiendet.factua := current_date;
                rasiendet.regcomcol := 0;
                rasiendet.swprovicion := 'N';
                rasiendet.saldo := 0;
                rasiendet.swgasoper := 1;
                rasiendet.codporret := '';
                rasiendet.swchkconcilia := 'N';
                PIPE ROW ( rasiendet );
        /****************************************************/
         /*  Planilla de Cancelación de documentos en banco  */
         /****************************************************/
            ELSIF (
                reg_dcta103.tippla = 138
                AND reg_dcta103.situac <> 'J'
            ) THEN
                -- IMPRIMIENDO EL PRIMER ASIENTO
                item := item + 1;
                rasiendet.id_cia := pin_id_cia;
                rasiendet.periodo := pin_periodo;
                rasiendet.mes := pin_mes;
                rasiendet.libro := pin_libro;
                rasiendet.asiento := pin_secuencia;
                rasiendet.item := item;
                rasiendet.sitem := 0;
                rasiendet.fecha := reg_dcta103.femisi;
                rasiendet.tasien := 66;
                rasiendet.topera := reg_dcta103.tipcan;
                rasiendet.codigo := reg_dcta103.codcli;
                rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.cuenta :=
                    CASE
                        WHEN ( reg_dcta103.tipcan = 51 ) THEN
                            reg_dcta103.cuentacon
                        WHEN ( reg_dcta103.tipcan = 52 ) THEN
                            reg_dcta103.cuentaord01
                        ELSE reg_dcta103.cuentaord01
                    END;

                rasiendet.dh :=
                    CASE
                        WHEN ( reg_dcta103.dh = 'D' ) THEN
                            'H'
                        WHEN ( reg_dcta103.dh = 'H' ) THEN
                            'D'
                    END;

                rasiendet.moneda := reg_dcta103.tmonpag;
                IF reg_dcta103.tmonpag = 'PEN' THEN
                    rasiendet.tcambio01 := 1;
                    rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                ELSE
                    rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                    rasiendet.tcambio02 := 1;
                END IF;

                rasiendet.importe := reg_dcta103.amorti;
                IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                    rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                    rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                ELSE
                    IF reg_dcta103.tmondoc = 'PEN' THEN
                        rasiendet.impor01 := reg_dcta103.impor01;
                        rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                        rasiendet.importe := rasiendet.impor02;
                    ELSE
                        rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                        rasiendet.impor02 := reg_dcta103.impor02;
                        rasiendet.importe := rasiendet.impor01;
                    END IF;
                END IF;

                rasiendet.debe := 0;
                rasiendet.debe01 := 0;
                rasiendet.debe02 := 0;
                rasiendet.haber := 0;
                rasiendet.haber01 := 0;
                rasiendet.haber02 := 0;
                CASE
                    WHEN rasiendet.dh = 'D' THEN
                        rasiendet.debe := rasiendet.importe;
                        rasiendet.debe01 := rasiendet.impor01;
                        rasiendet.debe02 := rasiendet.impor02;
                    WHEN rasiendet.dh = 'H' THEN
                        rasiendet.haber := rasiendet.importe;
                        rasiendet.haber01 := rasiendet.impor01;
                        rasiendet.haber02 := rasiendet.impor02;
                END CASE;
                -- GENERICO
                rasiendet.ccosto := ' ';
                rasiendet.proyec := ' ';
                rasiendet.subcco := ' ';
                rasiendet.ctaalternativa := ' ';
                rasiendet.tipo := 0;
                rasiendet.docume := 0;
                rasiendet.tident := ' ';
                rasiendet.dident := ' ';
                rasiendet.tdocum := reg_dcta103.codsunat;
                rasiendet.serie := reg_dcta103.serie;
                rasiendet.numero := reg_dcta103.numero;
                rasiendet.fdocum := reg_dcta103.femisi;
                rasiendet.usuari := pin_usuario;
                rasiendet.fcreac := current_date;
                rasiendet.factua := current_date;
                rasiendet.regcomcol := 0;
                rasiendet.swprovicion := 'N';
                rasiendet.saldo := 0;
                rasiendet.swgasoper := 1;
                rasiendet.codporret := '';
                rasiendet.swchkconcilia := 'N';
                PIPE ROW ( rasiendet );
                -- IMPRIMIENDO EL SEGUNDO ASIENTO
                item := item + 1;
                rasiendet.id_cia := pin_id_cia;
                rasiendet.periodo := pin_periodo;
                rasiendet.mes := pin_mes;
                rasiendet.libro := pin_libro;
                rasiendet.asiento := pin_secuencia;
                rasiendet.item := item;
                rasiendet.sitem := 0;
                rasiendet.fecha := reg_dcta103.femisi;
                rasiendet.tasien := 66;
                rasiendet.topera := reg_dcta103.tipcan;
                rasiendet.codigo := reg_dcta103.codcli;
                rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.cuenta := reg_dcta103.cuentaenvios;
                rasiendet.dh := reg_dcta103.dh;
                rasiendet.moneda := reg_dcta103.tmonpag;
                IF reg_dcta103.tmonpag = 'PEN' THEN
                    rasiendet.tcambio01 := 1;
                    rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                ELSE
                    rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                    rasiendet.tcambio02 := 1;
                END IF;

                rasiendet.importe := reg_dcta103.amorti;
                IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                    rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                    rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                ELSE
                    IF reg_dcta103.tmondoc = 'PEN' THEN
                        rasiendet.impor01 := reg_dcta103.impor01;
                        rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                        rasiendet.importe := rasiendet.impor02;
                    ELSE
                        rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                        rasiendet.impor02 := reg_dcta103.impor02;
                        rasiendet.importe := rasiendet.impor01;
                    END IF;
                END IF;

                rasiendet.debe := 0;
                rasiendet.debe01 := 0;
                rasiendet.debe02 := 0;
                rasiendet.haber := 0;
                rasiendet.haber01 := 0;
                rasiendet.haber02 := 0;
                CASE
                    WHEN rasiendet.dh = 'D' THEN
                        rasiendet.debe := rasiendet.importe;
                        rasiendet.debe01 := rasiendet.impor01;
                        rasiendet.debe02 := rasiendet.impor02;
                    WHEN rasiendet.dh = 'H' THEN
                        rasiendet.haber := rasiendet.importe;
                        rasiendet.haber01 := rasiendet.impor01;
                        rasiendet.haber02 := rasiendet.impor02;
                END CASE;
                -- GENERICO
                rasiendet.ccosto := ' ';
                rasiendet.proyec := ' ';
                rasiendet.subcco := ' ';
                rasiendet.ctaalternativa := ' ';
                rasiendet.tipo := 0;
                rasiendet.docume := 0;
                rasiendet.tident := ' ';
                rasiendet.dident := ' ';
                rasiendet.tdocum := reg_dcta103.codsunat;
                rasiendet.serie := reg_dcta103.serie;
                rasiendet.numero := reg_dcta103.numero;
                rasiendet.fdocum := reg_dcta103.femisi;
                rasiendet.usuari := pin_usuario;
                rasiendet.fcreac := current_date;
                rasiendet.factua := current_date;
                rasiendet.regcomcol := 0;
                rasiendet.swprovicion := 'N';
                rasiendet.saldo := 0;
                rasiendet.swgasoper := 1;
                rasiendet.codporret := '';
                rasiendet.swchkconcilia := 'N';
                PIPE ROW ( rasiendet );
         /***********************************/
         /*  Planilla de Ingresos al banco  */
         /***********************************/
            ELSIF (
                reg_dcta103.tippla = 143
                AND reg_dcta103.situac <> 'J'
            ) THEN
                item := item + 1;
                rasiendet.id_cia := pin_id_cia;
                rasiendet.periodo := pin_periodo;
                rasiendet.mes := pin_mes;
                rasiendet.libro := pin_libro;
                rasiendet.asiento := pin_secuencia;
                rasiendet.item := item;
                rasiendet.sitem := 0;
                rasiendet.fecha := reg_dcta103.femisi;
                rasiendet.tasien := 66;
                rasiendet.topera := reg_dcta103.tipcan;
                rasiendet.codigo := reg_dcta103.codcli;
                rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                rasiendet.cuenta := reg_dcta103.cuentaord01;
                rasiendet.dh := reg_dcta103.dh;
                rasiendet.moneda := reg_dcta103.tmonpag;
                IF reg_dcta103.tmonpag = 'PEN' THEN
                    rasiendet.tcambio01 := 1;
                    rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                ELSE
                    rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                    rasiendet.tcambio02 := 1;
                END IF;

                rasiendet.importe := reg_dcta103.amorti;
                IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                    rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                    rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                ELSE
                    IF reg_dcta103.tmondoc = 'PEN' THEN
                        rasiendet.impor01 := reg_dcta103.impor01;
                        rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                        rasiendet.importe := rasiendet.impor02;
                    ELSE
                        rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                        rasiendet.impor02 := reg_dcta103.impor02;
                        rasiendet.importe := rasiendet.impor01;
                    END IF;
                END IF;

                rasiendet.debe := 0;
                rasiendet.debe01 := 0;
                rasiendet.debe02 := 0;
                rasiendet.haber := 0;
                rasiendet.haber01 := 0;
                rasiendet.haber02 := 0;
                CASE
                    WHEN rasiendet.dh = 'D' THEN
                        rasiendet.debe := rasiendet.importe;
                        rasiendet.debe01 := rasiendet.impor01;
                        rasiendet.debe02 := rasiendet.impor02;
                    WHEN rasiendet.dh = 'H' THEN
                        rasiendet.haber := rasiendet.importe;
                        rasiendet.haber01 := rasiendet.impor01;
                        rasiendet.haber02 := rasiendet.impor02;
                END CASE;
                -- GENERICO
                rasiendet.ccosto := ' ';
                rasiendet.proyec := ' ';
                rasiendet.subcco := ' ';
                rasiendet.ctaalternativa := ' ';
                rasiendet.tipo := 0;
                rasiendet.docume := 0;
                rasiendet.tident := ' ';
                rasiendet.dident := ' ';
                rasiendet.tdocum := reg_dcta103.codsunat;
                rasiendet.serie := reg_dcta103.serie;
                rasiendet.numero := reg_dcta103.numero;
                rasiendet.fdocum := reg_dcta103.femisi;
                rasiendet.usuari := pin_usuario;
                rasiendet.fcreac := current_date;
                rasiendet.factua := current_date;
                rasiendet.regcomcol := 0;
                rasiendet.swprovicion := 'N';
                rasiendet.saldo := 0;
                rasiendet.swgasoper := 1;
                rasiendet.codporret := '';
                rasiendet.swchkconcilia := 'N';
                PIPE ROW ( rasiendet );
         /**************************************/
         /*  Planilla de cargos de documentos  */
         /**************************************/
            ELSIF (
                reg_dcta103.tippla = 144
                AND reg_dcta103.situac <> 'J'
            ) THEN
                IF ( ( reg_dcta103.protes = 1 ) OR ( reg_dcta103.operac = 6 ) ) THEN /*operac 6 = Letras retiradas*/
                    -- IMPRIMIENDO EL PRIMER ASIENTO
                    item := item + 1;
                    rasiendet.id_cia := pin_id_cia;
                    rasiendet.periodo := pin_periodo;
                    rasiendet.mes := pin_mes;
                    rasiendet.libro := pin_libro;
                    rasiendet.asiento := pin_secuencia;
                    rasiendet.item := item;
                    rasiendet.sitem := 0;
                    rasiendet.fecha := reg_dcta103.femisi;
                    rasiendet.tasien := 66;
                    rasiendet.topera := reg_dcta103.tipcan;
                    rasiendet.codigo := reg_dcta103.codcli;
                    rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.cuenta := reg_dcta103.cuentaord01;
                    rasiendet.dh :=
                        CASE
                            WHEN ( reg_dcta103.dh = 'D' ) THEN
                                'H'
                            WHEN ( reg_dcta103.dh = 'H' ) THEN
                                'D'
                        END;

                    rasiendet.moneda := reg_dcta103.tmonpag;
                    IF reg_dcta103.tmonpag = 'PEN' THEN
                        rasiendet.tcambio01 := 1;
                        rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                    ELSE
                        rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                        rasiendet.tcambio02 := 1;
                    END IF;

                    rasiendet.importe := reg_dcta103.amorti;
                    IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                        rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                        rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                    ELSE
                        IF reg_dcta103.tmondoc = 'PEN' THEN
                            rasiendet.impor01 := reg_dcta103.impor01;
                            rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                            rasiendet.importe := rasiendet.impor02;
                        ELSE
                            rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                            rasiendet.impor02 := reg_dcta103.impor02;
                            rasiendet.importe := rasiendet.impor01;
                        END IF;
                    END IF;

                    rasiendet.debe := 0;
                    rasiendet.debe01 := 0;
                    rasiendet.debe02 := 0;
                    rasiendet.haber := 0;
                    rasiendet.haber01 := 0;
                    rasiendet.haber02 := 0;
                    CASE
                        WHEN rasiendet.dh = 'D' THEN
                            rasiendet.debe := rasiendet.importe;
                            rasiendet.debe01 := rasiendet.impor01;
                            rasiendet.debe02 := rasiendet.impor02;
                        WHEN rasiendet.dh = 'H' THEN
                            rasiendet.haber := rasiendet.importe;
                            rasiendet.haber01 := rasiendet.impor01;
                            rasiendet.haber02 := rasiendet.impor02;
                    END CASE;
                    -- GENERICO
                    rasiendet.ccosto := ' ';
                    rasiendet.proyec := ' ';
                    rasiendet.subcco := ' ';
                    rasiendet.ctaalternativa := ' ';
                    rasiendet.tipo := 0;
                    rasiendet.docume := 0;
                    rasiendet.tident := ' ';
                    rasiendet.dident := ' ';
                    rasiendet.tdocum := reg_dcta103.codsunat;
                    rasiendet.serie := reg_dcta103.serie;
                    rasiendet.numero := reg_dcta103.numero;
                    rasiendet.fdocum := reg_dcta103.femisi;
                    rasiendet.usuari := pin_usuario;
                    rasiendet.fcreac := current_date;
                    rasiendet.factua := current_date;
                    rasiendet.regcomcol := 0;
                    rasiendet.swprovicion := 'N';
                    rasiendet.saldo := 0;
                    rasiendet.swgasoper := 1;
                    rasiendet.codporret := '';
                    rasiendet.swchkconcilia := 'N';
                    PIPE ROW ( rasiendet );
                    -- IMPRIMIENDO EL SEGUNDO ASIENTO
                    item := item + 1;
                    rasiendet.id_cia := pin_id_cia;
                    rasiendet.periodo := pin_periodo;
                    rasiendet.mes := pin_mes;
                    rasiendet.libro := pin_libro;
                    rasiendet.asiento := pin_secuencia;
                    rasiendet.item := item;
                    rasiendet.sitem := 0;
                    rasiendet.fecha := reg_dcta103.femisi;
                    rasiendet.tasien := 66;
                    rasiendet.topera := reg_dcta103.tipcan;
                    rasiendet.codigo := reg_dcta103.codcli;
                    rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.cuenta := reg_dcta103.cuentacon;
                    rasiendet.dh := reg_dcta103.dh;
                    rasiendet.moneda := reg_dcta103.tmonpag;
                    IF reg_dcta103.tmonpag = 'PEN' THEN
                        rasiendet.tcambio01 := 1;
                        rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                    ELSE
                        rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                        rasiendet.tcambio02 := 1;
                    END IF;

                    rasiendet.importe := reg_dcta103.deposito;
                    IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                        rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                        rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                    ELSE
                        IF reg_dcta103.tmondoc = 'PEN' THEN
                            rasiendet.impor01 := reg_dcta103.impor01;
                            rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                            rasiendet.importe := rasiendet.impor02;
                        ELSE
                            rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                            rasiendet.impor02 := reg_dcta103.impor02;
                            rasiendet.importe := rasiendet.impor01;
                        END IF;
                    END IF;

                    rasiendet.debe := 0;
                    rasiendet.debe01 := 0;
                    rasiendet.debe02 := 0;
                    rasiendet.haber := 0;
                    rasiendet.haber01 := 0;
                    rasiendet.haber02 := 0;
                    CASE
                        WHEN rasiendet.dh = 'D' THEN
                            rasiendet.debe := rasiendet.importe;
                            rasiendet.debe01 := rasiendet.impor01;
                            rasiendet.debe02 := rasiendet.impor02;
                        WHEN rasiendet.dh = 'H' THEN
                            rasiendet.haber := rasiendet.importe;
                            rasiendet.haber01 := rasiendet.impor01;
                            rasiendet.haber02 := rasiendet.impor02;
                    END CASE;
                -- GENERICO
                    rasiendet.ccosto := ' ';
                    rasiendet.proyec := ' ';
                    rasiendet.subcco := ' ';
                    rasiendet.ctaalternativa := ' ';
                    rasiendet.tipo := 0;
                    rasiendet.docume := 0;
                    rasiendet.tident := ' ';
                    rasiendet.dident := ' ';
                    rasiendet.tdocum := reg_dcta103.codsunat;
                    rasiendet.serie := reg_dcta103.serie;
                    rasiendet.numero := reg_dcta103.numero;
                    rasiendet.fdocum := reg_dcta103.femisi;
                    rasiendet.usuari := pin_usuario;
                    rasiendet.fcreac := current_date;
                    rasiendet.factua := current_date;
                    rasiendet.regcomcol := 0;
                    rasiendet.swprovicion := 'N';
                    rasiendet.saldo := 0;
                    rasiendet.swgasoper := 1;
                    rasiendet.codporret := '';
                    rasiendet.swchkconcilia := 'N';
                    PIPE ROW ( rasiendet );
                    -- IMPRIMIENDO EL TERCER ASIENTO
                    item := item + 1;
                    rasiendet.id_cia := pin_id_cia;
                    rasiendet.periodo := pin_periodo;
                    rasiendet.mes := pin_mes;
                    rasiendet.libro := pin_libro;
                    rasiendet.asiento := pin_secuencia;
                    rasiendet.item := item;
                    rasiendet.sitem := 0;
                    rasiendet.fecha := reg_dcta103.femisi;
                    rasiendet.tasien := 66;
                    rasiendet.topera := reg_dcta103.tipcan;
                    rasiendet.codigo := reg_dcta103.codcli;
                    rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.cuenta := reg_dcta103.cuentacon;
                    rasiendet.dh := reg_dcta103.dh;
                    rasiendet.moneda := reg_dcta103.tmonpag;
                    IF reg_dcta103.tmonpag = 'PEN' THEN
                        rasiendet.tcambio01 := 1;
                        rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                    ELSE
                        rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                        rasiendet.tcambio02 := 1;
                    END IF;

                    rasiendet.importe := reg_dcta103.deposito;
                    IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                        rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                        rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                    ELSE
                        IF reg_dcta103.tmondoc = 'PEN' THEN
                            rasiendet.impor01 := reg_dcta103.impor01;
                            rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                            rasiendet.importe := rasiendet.impor02;
                        ELSE
                            rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                            rasiendet.impor02 := reg_dcta103.impor02;
                            rasiendet.importe := rasiendet.impor01;
                        END IF;
                    END IF;

                    rasiendet.debe := 0;
                    rasiendet.debe01 := 0;
                    rasiendet.debe02 := 0;
                    rasiendet.haber := 0;
                    rasiendet.haber01 := 0;
                    rasiendet.haber02 := 0;
                    CASE
                        WHEN rasiendet.dh = 'D' THEN
                            rasiendet.debe := rasiendet.importe;
                            rasiendet.debe01 := rasiendet.impor01;
                            rasiendet.debe02 := rasiendet.impor02;
                        WHEN rasiendet.dh = 'H' THEN
                            rasiendet.haber := rasiendet.importe;
                            rasiendet.haber01 := rasiendet.impor01;
                            rasiendet.haber02 := rasiendet.impor02;
                    END CASE;
                -- GENERICO
                    rasiendet.ccosto := ' ';
                    rasiendet.proyec := ' ';
                    rasiendet.subcco := ' ';
                    rasiendet.ctaalternativa := ' ';
                    rasiendet.tipo := 0;
                    rasiendet.docume := 0;
                    rasiendet.tident := ' ';
                    rasiendet.dident := ' ';
                    rasiendet.tdocum := reg_dcta103.codsunat;
                    rasiendet.serie := reg_dcta103.serie;
                    rasiendet.numero := reg_dcta103.numero;
                    rasiendet.fdocum := reg_dcta103.femisi;
                    rasiendet.usuari := pin_usuario;
                    rasiendet.fcreac := current_date;
                    rasiendet.factua := current_date;
                    rasiendet.regcomcol := 0;
                    rasiendet.swprovicion := 'N';
                    rasiendet.saldo := 0;
                    rasiendet.swgasoper := 1;
                    rasiendet.codporret := '';
                    rasiendet.swchkconcilia := 'N';
                    PIPE ROW ( rasiendet );
                    -- IMPRIMIENDO EL CUARTO ASIENTO
                    item := item + 1;
                    rasiendet.id_cia := pin_id_cia;
                    rasiendet.periodo := pin_periodo;
                    rasiendet.mes := pin_mes;
                    rasiendet.libro := pin_libro;
                    rasiendet.asiento := pin_secuencia;
                    rasiendet.item := item;
                    rasiendet.sitem := 0;
                    rasiendet.fecha := reg_dcta103.femisi;
                    rasiendet.tasien := 66;
                    rasiendet.topera := reg_dcta103.tipcan;
                    rasiendet.codigo := reg_dcta103.codcli;
                    rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                    IF reg_dcta103.protes = 1 THEN
                        rasiendet.cuenta := reg_dcta103.cuentacprot;
                    ELSE
                        rasiendet.cuenta := reg_dcta103.cuentacar;
                    END IF;

                    IF ( ( reg_dcta103.amorti - reg_dcta103.deposito ) < 0 ) THEN
                        rasiendet.dh :=
                            CASE
                                WHEN ( reg_dcta103.dh = 'D' ) THEN
                                    'H'
                                WHEN ( reg_dcta103.dh = 'H' ) THEN
                                    'D'
                            END;
                    ELSE
                        rasiendet.dh := reg_dcta103.dh;
                    END IF;

                    rasiendet.importe := ( reg_dcta103.amorti - reg_dcta103.deposito );
                    IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                        rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                        rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                    ELSE
                        IF reg_dcta103.tmondoc = 'PEN' THEN
                            rasiendet.impor01 := reg_dcta103.impor01;
                            rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                            rasiendet.importe := rasiendet.impor02;
                        ELSE
                            rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                            rasiendet.impor02 := reg_dcta103.impor02;
                            rasiendet.importe := rasiendet.impor01;
                        END IF;
                    END IF;

                    rasiendet.debe := 0;
                    rasiendet.debe01 := 0;
                    rasiendet.debe02 := 0;
                    rasiendet.haber := 0;
                    rasiendet.haber01 := 0;
                    rasiendet.haber02 := 0;
                    CASE
                        WHEN rasiendet.dh = 'D' THEN
                            rasiendet.debe := rasiendet.importe;
                            rasiendet.debe01 := rasiendet.impor01;
                            rasiendet.debe02 := rasiendet.impor02;
                        WHEN rasiendet.dh = 'H' THEN
                            rasiendet.haber := rasiendet.importe;
                            rasiendet.haber01 := rasiendet.impor01;
                            rasiendet.haber02 := rasiendet.impor02;
                    END CASE;
                    -- GENERICO
                    rasiendet.ccosto := ' ';
                    rasiendet.proyec := ' ';
                    rasiendet.subcco := ' ';
                    rasiendet.ctaalternativa := ' ';
                    rasiendet.tipo := 0;
                    rasiendet.docume := 0;
                    rasiendet.tident := ' ';
                    rasiendet.dident := ' ';
                    rasiendet.tdocum := '';
                    rasiendet.serie := '';
                    rasiendet.numero := '';
                    rasiendet.fdocum := NULL;
                    rasiendet.usuari := pin_usuario;
                    rasiendet.fcreac := current_date;
                    rasiendet.factua := current_date;
                    rasiendet.regcomcol := 0;
                    rasiendet.swprovicion := 'N';
                    rasiendet.saldo := 0;
                    rasiendet.swgasoper := 1;
                    rasiendet.codporret := '';
                    rasiendet.swchkconcilia := 'N';
                    PIPE ROW ( rasiendet );
                ELSE
                    -- IMPRIMIENDO EL PRIMER ASIENTO
                    item := item + 1;
                    rasiendet.id_cia := pin_id_cia;
                    rasiendet.periodo := pin_periodo;
                    rasiendet.mes := pin_mes;
                    rasiendet.libro := pin_libro;
                    rasiendet.asiento := pin_secuencia;
                    rasiendet.item := item;
                    rasiendet.sitem := 0;
                    rasiendet.fecha := reg_dcta103.femisi;
                    rasiendet.tasien := 66;
                    rasiendet.topera := reg_dcta103.tipcan;
                    rasiendet.codigo := reg_dcta103.codcli;
                    rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.cuenta := reg_dcta103.cuentaenvios;
                    rasiendet.dh := reg_dcta103.dh;
                    rasiendet.moneda := reg_dcta103.tmonpag;
                    IF reg_dcta103.tmonpag = 'PEN' THEN
                        rasiendet.tcambio01 := 1;
                        rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                    ELSE
                        rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                        rasiendet.tcambio02 := 1;
                    END IF;

                    rasiendet.importe := reg_dcta103.amorti;
                    IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                        rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                        rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                    ELSE
                        IF reg_dcta103.tmondoc = 'PEN' THEN
                            rasiendet.impor01 := reg_dcta103.impor01;
                            rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                            rasiendet.importe := rasiendet.impor02;
                        ELSE
                            rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                            rasiendet.impor02 := reg_dcta103.impor02;
                            rasiendet.importe := rasiendet.impor01;
                        END IF;
                    END IF;

                    rasiendet.debe := 0;
                    rasiendet.debe01 := 0;
                    rasiendet.debe02 := 0;
                    rasiendet.haber := 0;
                    rasiendet.haber01 := 0;
                    rasiendet.haber02 := 0;
                    CASE
                        WHEN rasiendet.dh = 'D' THEN
                            rasiendet.debe := rasiendet.importe;
                            rasiendet.debe01 := rasiendet.impor01;
                            rasiendet.debe02 := rasiendet.impor02;
                        WHEN rasiendet.dh = 'H' THEN
                            rasiendet.haber := rasiendet.importe;
                            rasiendet.haber01 := rasiendet.impor01;
                            rasiendet.haber02 := rasiendet.impor02;
                    END CASE;
                    -- GENERICO
                    rasiendet.ccosto := ' ';
                    rasiendet.proyec := ' ';
                    rasiendet.subcco := ' ';
                    rasiendet.ctaalternativa := ' ';
                    rasiendet.tipo := 0;
                    rasiendet.docume := 0;
                    rasiendet.tident := ' ';
                    rasiendet.dident := ' ';
                    rasiendet.tdocum := reg_dcta103.codsunat;
                    rasiendet.serie := reg_dcta103.serie;
                    rasiendet.numero := reg_dcta103.numero;
                    rasiendet.fdocum := reg_dcta103.femisi;
                    rasiendet.usuari := pin_usuario;
                    rasiendet.fcreac := current_date;
                    rasiendet.factua := current_date;
                    rasiendet.regcomcol := 0;
                    rasiendet.swprovicion := 'N';
                    rasiendet.saldo := 0;
                    rasiendet.swgasoper := 1;
                    rasiendet.codporret := '';
                    rasiendet.swchkconcilia := 'N';
                    PIPE ROW ( rasiendet );
                    -- IMPRIMIENDO EL SEGUNDO ASIENTO
                    item := item + 1;
                    rasiendet.id_cia := pin_id_cia;
                    rasiendet.periodo := pin_periodo;
                    rasiendet.mes := pin_mes;
                    rasiendet.libro := pin_libro;
                    rasiendet.asiento := pin_secuencia;
                    rasiendet.item := item;
                    rasiendet.sitem := 0;
                    rasiendet.fecha := reg_dcta103.femisi;
                    rasiendet.tasien := 66;
                    rasiendet.topera := reg_dcta103.tipcan;
                    rasiendet.codigo := reg_dcta103.codcli;
                    rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.cuenta := reg_dcta103.cuenta;
                    rasiendet.dh :=
                        CASE
                            WHEN ( reg_dcta103.dh = 'D' ) THEN
                                'H'
                            WHEN ( reg_dcta103.dh = 'H' ) THEN
                                'D'
                        END;

                    rasiendet.moneda := reg_dcta103.tmonpag;
                    IF reg_dcta103.tmonpag = 'PEN' THEN
                        rasiendet.tcambio01 := 1;
                        rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                    ELSE
                        rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                        rasiendet.tcambio02 := 1;
                    END IF;

                    rasiendet.importe := reg_dcta103.amorti;
                    IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                        rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                        rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                    ELSE
                        IF reg_dcta103.tmondoc = 'PEN' THEN
                            rasiendet.impor01 := reg_dcta103.impor01;
                            rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                            rasiendet.importe := rasiendet.impor02;
                        ELSE
                            rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                            rasiendet.impor02 := reg_dcta103.impor02;
                            rasiendet.importe := rasiendet.impor01;
                        END IF;
                    END IF;

                    rasiendet.debe := 0;
                    rasiendet.debe01 := 0;
                    rasiendet.debe02 := 0;
                    rasiendet.haber := 0;
                    rasiendet.haber01 := 0;
                    rasiendet.haber02 := 0;
                    CASE
                        WHEN rasiendet.dh = 'D' THEN
                            rasiendet.debe := rasiendet.importe;
                            rasiendet.debe01 := rasiendet.impor01;
                            rasiendet.debe02 := rasiendet.impor02;
                        WHEN rasiendet.dh = 'H' THEN
                            rasiendet.haber := rasiendet.importe;
                            rasiendet.haber01 := rasiendet.impor01;
                            rasiendet.haber02 := rasiendet.impor02;
                    END CASE;
                    -- GENERICO
                    rasiendet.ccosto := ' ';
                    rasiendet.proyec := ' ';
                    rasiendet.subcco := ' ';
                    rasiendet.ctaalternativa := ' ';
                    rasiendet.tipo := 0;
                    rasiendet.docume := 0;
                    rasiendet.tident := ' ';
                    rasiendet.dident := ' ';
                    rasiendet.tdocum := reg_dcta103.codsunat;
                    rasiendet.serie := reg_dcta103.serie;
                    rasiendet.numero := reg_dcta103.numero;
                    rasiendet.fdocum := reg_dcta103.femisi;
                    rasiendet.usuari := pin_usuario;
                    rasiendet.fcreac := current_date;
                    rasiendet.factua := current_date;
                    rasiendet.regcomcol := 0;
                    rasiendet.swprovicion := 'N';
                    rasiendet.saldo := 0;
                    rasiendet.swgasoper := 1;
                    rasiendet.codporret := '';
                    rasiendet.swchkconcilia := 'N';
                    PIPE ROW ( rasiendet );

                    -- IMPRIMIENDO EL TERCER ASIENTO
                    item := item + 1;
                    rasiendet.id_cia := pin_id_cia;
                    rasiendet.periodo := pin_periodo;
                    rasiendet.mes := pin_mes;
                    rasiendet.libro := pin_libro;
                    rasiendet.asiento := pin_secuencia;
                    rasiendet.item := item;
                    rasiendet.sitem := 0;
                    rasiendet.fecha := reg_dcta103.femisi;
                    rasiendet.tasien := 66;
                    rasiendet.codigo := reg_dcta103.codcli;
                    rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.cuenta := reg_dcta103.cuentaord01;
                    rasiendet.dh :=
                        CASE
                            WHEN ( reg_dcta103.dh = 'D' ) THEN
                                'H'
                            WHEN ( reg_dcta103.dh = 'H' ) THEN
                                'D'
                        END;

                    rasiendet.moneda := reg_dcta103.tmonpag;
                    IF reg_dcta103.tmonpag = 'PEN' THEN
                        rasiendet.tcambio01 := 1;
                        rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                    ELSE
                        rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                        rasiendet.tcambio02 := 1;
                    END IF;

                    rasiendet.importe := reg_dcta103.amorti;
                    IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                        rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                        rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                    ELSE
                        IF reg_dcta103.tmondoc = 'PEN' THEN
                            rasiendet.impor01 := reg_dcta103.impor01;
                            rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                            rasiendet.importe := rasiendet.impor02;
                        ELSE
                            rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                            rasiendet.impor02 := reg_dcta103.impor02;
                            rasiendet.importe := rasiendet.impor01;
                        END IF;
                    END IF;

                    rasiendet.debe := 0;
                    rasiendet.debe01 := 0;
                    rasiendet.debe02 := 0;
                    rasiendet.haber := 0;
                    rasiendet.haber01 := 0;
                    rasiendet.haber02 := 0;
                    CASE
                        WHEN rasiendet.dh = 'D' THEN
                            rasiendet.debe := rasiendet.importe;
                            rasiendet.debe01 := rasiendet.impor01;
                            rasiendet.debe02 := rasiendet.impor02;
                        WHEN rasiendet.dh = 'H' THEN
                            rasiendet.haber := rasiendet.importe;
                            rasiendet.haber01 := rasiendet.impor01;
                            rasiendet.haber02 := rasiendet.impor02;
                    END CASE;
                    -- GENERICO
                    rasiendet.ccosto := ' ';
                    rasiendet.proyec := ' ';
                    rasiendet.subcco := ' ';
                    rasiendet.ctaalternativa := ' ';
                    rasiendet.tipo := 0;
                    rasiendet.docume := 0;
                    rasiendet.tident := ' ';
                    rasiendet.dident := ' ';
                    rasiendet.tdocum := reg_dcta103.codsunat;
                    rasiendet.serie := reg_dcta103.serie;
                    rasiendet.numero := reg_dcta103.numero;
                    rasiendet.fdocum := reg_dcta103.femisi;
                    rasiendet.usuari := pin_usuario;
                    rasiendet.fcreac := current_date;
                    rasiendet.factua := current_date;
                    rasiendet.regcomcol := 0;
                    rasiendet.swprovicion := 'N';
                    rasiendet.saldo := 0;
                    rasiendet.swgasoper := 1;
                    rasiendet.codporret := '';
                    rasiendet.swchkconcilia := 'N';
                    PIPE ROW ( rasiendet );
                    -- IMPRIMIENDO EL CUARTO ASIENTO
                    item := item + 1;
                    rasiendet.id_cia := pin_id_cia;
                    rasiendet.periodo := pin_periodo;
                    rasiendet.mes := pin_mes;
                    rasiendet.libro := pin_libro;
                    rasiendet.asiento := pin_secuencia;
                    rasiendet.item := item;
                    rasiendet.sitem := 0;
                    rasiendet.fecha := reg_dcta103.femisi;
                    rasiendet.tasien := 66;
                    rasiendet.topera := reg_dcta103.tipcan;
                    rasiendet.codigo := reg_dcta103.codcli;
                    rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.cuenta := reg_dcta103.cuentacon;
                    rasiendet.dh := reg_dcta103.dh;
                    rasiendet.moneda := reg_dcta103.tmonpag;
                    IF reg_dcta103.tmonpag = 'PEN' THEN
                        rasiendet.tcambio01 := 1;
                        rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                    ELSE
                        rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                        rasiendet.tcambio02 := 1;
                    END IF;

                    rasiendet.importe := reg_dcta103.deposito;
                    IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                        rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                        rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                    ELSE
                        IF reg_dcta103.tmondoc = 'PEN' THEN
                            rasiendet.impor01 := reg_dcta103.impor01;
                            rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                            rasiendet.importe := rasiendet.impor02;
                        ELSE
                            rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                            rasiendet.impor02 := reg_dcta103.impor02;
                            rasiendet.importe := rasiendet.impor01;
                        END IF;
                    END IF;

                    rasiendet.debe := 0;
                    rasiendet.debe01 := 0;
                    rasiendet.debe02 := 0;
                    rasiendet.haber := 0;
                    rasiendet.haber01 := 0;
                    rasiendet.haber02 := 0;
                    CASE
                        WHEN rasiendet.dh = 'D' THEN
                            rasiendet.debe := rasiendet.importe;
                            rasiendet.debe01 := rasiendet.impor01;
                            rasiendet.debe02 := rasiendet.impor02;
                        WHEN rasiendet.dh = 'H' THEN
                            rasiendet.haber := rasiendet.importe;
                            rasiendet.haber01 := rasiendet.impor01;
                            rasiendet.haber02 := rasiendet.impor02;
                    END CASE;
                    -- GENERICO
                    rasiendet.ccosto := ' ';
                    rasiendet.proyec := ' ';
                    rasiendet.subcco := ' ';
                    rasiendet.ctaalternativa := ' ';
                    rasiendet.tipo := 0;
                    rasiendet.docume := 0;
                    rasiendet.tident := ' ';
                    rasiendet.dident := ' ';
                    rasiendet.tdocum := reg_dcta103.codsunat;
                    rasiendet.serie := reg_dcta103.serie;
                    rasiendet.numero := reg_dcta103.numero;
                    rasiendet.fdocum := reg_dcta103.femisi;
                    rasiendet.usuari := pin_usuario;
                    rasiendet.fcreac := current_date;
                    rasiendet.factua := current_date;
                    rasiendet.regcomcol := 0;
                    rasiendet.swprovicion := 'N';
                    rasiendet.saldo := 0;
                    rasiendet.swgasoper := 1;
                    rasiendet.codporret := '';
                    rasiendet.swchkconcilia := 'N';
                    PIPE ROW ( rasiendet );
                    -- IMPRIMIENDO EL QUINTO ASIENTO
                    item := item + 1;
                    rasiendet.id_cia := pin_id_cia;
                    rasiendet.periodo := pin_periodo;
                    rasiendet.mes := pin_mes;
                    rasiendet.libro := pin_libro;
                    rasiendet.asiento := pin_secuencia;
                    rasiendet.item := item;
                    rasiendet.sitem := 0;
                    rasiendet.fecha := reg_dcta103.femisi;
                    rasiendet.tasien := 66;
                    rasiendet.topera := reg_dcta103.tipcan;
                    rasiendet.codigo := reg_dcta103.codcli;
                    rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
                    rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
                    IF reg_dcta103.protes = 1 THEN
                        rasiendet.cuenta := reg_dcta103.cuentacprot;
                    ELSE
                        rasiendet.cuenta := reg_dcta103.cuentacar;
                    END IF;

                    IF ( ( reg_dcta103.amorti - reg_dcta103.deposito ) < 0 ) THEN
                        rasiendet.dh :=
                            CASE
                                WHEN ( reg_dcta103.dh = 'D' ) THEN
                                    'H'
                                WHEN ( reg_dcta103.dh = 'H' ) THEN
                                    'D'
                            END;
                    ELSE
                        rasiendet.dh := reg_dcta103.dh;
                    END IF;

                    rasiendet.moneda := reg_dcta103.tmonpag;
                    IF reg_dcta103.tmonpag = 'PEN' THEN
                        rasiendet.tcambio01 := 1;
                        rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
                    ELSE
                        rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                        rasiendet.tcambio02 := 1;
                    END IF;

                    rasiendet.importe := ( reg_dcta103.amorti - reg_dcta103.deposito );
                    IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                        rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                        rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
                    ELSE
                        IF reg_dcta103.tmondoc = 'PEN' THEN
                            rasiendet.impor01 := reg_dcta103.impor01;
                            rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                            rasiendet.importe := rasiendet.impor02;
                        ELSE
                            rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                            rasiendet.impor02 := reg_dcta103.impor02;
                            rasiendet.importe := rasiendet.impor01;
                        END IF;
                    END IF;

                    rasiendet.debe := 0;
                    rasiendet.debe01 := 0;
                    rasiendet.debe02 := 0;
                    rasiendet.haber := 0;
                    rasiendet.haber01 := 0;
                    rasiendet.haber02 := 0;
                    CASE
                        WHEN rasiendet.dh = 'D' THEN
                            rasiendet.debe := rasiendet.importe;
                            rasiendet.debe01 := rasiendet.impor01;
                            rasiendet.debe02 := rasiendet.impor02;
                        WHEN rasiendet.dh = 'H' THEN
                            rasiendet.haber := rasiendet.importe;
                            rasiendet.haber01 := rasiendet.impor01;
                            rasiendet.haber02 := rasiendet.impor02;
                    END CASE;
                    -- GENERICO
                    rasiendet.ccosto := ' ';
                    rasiendet.proyec := ' ';
                    rasiendet.subcco := ' ';
                    rasiendet.ctaalternativa := ' ';
                    rasiendet.tipo := 0;
                    rasiendet.docume := 0;
                    rasiendet.tident := ' ';
                    rasiendet.dident := ' ';
                    rasiendet.tdocum := '';
                    rasiendet.serie := '';
                    rasiendet.numero := '';
                    rasiendet.fdocum := NULL;
                    rasiendet.usuari := pin_usuario;
                    rasiendet.fcreac := current_date;
                    rasiendet.factua := current_date;
                    rasiendet.regcomcol := 0;
                    rasiendet.swprovicion := 'N';
                    rasiendet.saldo := 0;
                    rasiendet.swgasoper := 1;
                    rasiendet.codporret := '';
                    rasiendet.swchkconcilia := 'N';
                    PIPE ROW ( rasiendet );
                END IF;
            END IF;

        ELSIF reg_dcta103.situac <> 'J' THEN
            item := item + 1;
            rasiendet.id_cia := pin_id_cia;
            rasiendet.periodo := pin_periodo;
            rasiendet.mes := pin_mes;
            rasiendet.libro := pin_libro;
            rasiendet.asiento := pin_secuencia;
            rasiendet.item := item;
            rasiendet.sitem := 0;
            rasiendet.concep := substr(reg_dcta103.razonc, 1, 74);
            rasiendet.fecha := reg_dcta103.femisi;
            rasiendet.tasien := 66;
            rasiendet.topera := reg_dcta103.tipcan;
            rasiendet.cuenta := reg_dcta103.cuenta;
            rasiendet.dh := reg_dcta103.dh;
            rasiendet.moneda := reg_dcta103.tmonpag;
            IF reg_dcta103.tmonpag = 'PEN' THEN
                rasiendet.tcambio01 := 1;
                rasiendet.tcambio02 := 1 / reg_dcta103.tipcamdoc;
            END IF;

            IF reg_dcta103.tmonpag <> 'PEN' THEN
                rasiendet.tcambio01 := reg_dcta103.tipcamdoc;
                rasiendet.tcambio02 := 1;
            END IF;

            rasiendet.importe := reg_dcta103.amorti;
            IF reg_dcta103.tmondoc = reg_dcta103.tmonpag THEN
                rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
            ELSE
                IF reg_dcta103.tmondoc = 'PEN' THEN
                    rasiendet.impor01 := reg_dcta103.impor01;
                    rasiendet.impor02 := reg_dcta103.impor01 / rasiendet.tcambio01;
                    rasiendet.importe := rasiendet.impor02;
                ELSIF ( reg_dcta103.tmondoc <> 'PEN' ) THEN
                    rasiendet.impor01 := reg_dcta103.impor02 / rasiendet.tcambio02;
                    rasiendet.impor02 := reg_dcta103.impor02;
                    rasiendet.importe := rasiendet.impor01;
                END IF;
            END IF;

            rasiendet.debe := 0;
            rasiendet.debe01 := 0;
            rasiendet.debe02 := 0;
            rasiendet.haber := 0;
            rasiendet.haber01 := 0;
            rasiendet.haber02 := 0;
            CASE
                WHEN rasiendet.dh = 'D' THEN
                    rasiendet.debe := rasiendet.importe;
                    rasiendet.debe01 := rasiendet.impor01;
                    rasiendet.debe02 := rasiendet.impor02;
                WHEN rasiendet.dh = 'H' THEN
                    rasiendet.haber := rasiendet.importe;
                    rasiendet.haber01 := rasiendet.impor01;
                    rasiendet.haber02 := rasiendet.impor02;
            END CASE;

            rasiendet.ccosto := ' ';
            rasiendet.proyec := ' ';
            rasiendet.subcco := ' ';
            rasiendet.ctaalternativa := ' ';
            rasiendet.tipo := 0;
            rasiendet.docume := 0;
            rasiendet.codigo := reg_dcta103.codcli;
            rasiendet.razon := substr(reg_dcta103.razonc, 1, 74);
            rasiendet.tident := ' ';
            rasiendet.dident := ' ';
            rasiendet.tdocum := reg_dcta103.codsunat;
            rasiendet.serie := reg_dcta103.serie;
            rasiendet.numero := reg_dcta103.numero;
            rasiendet.fdocum := reg_dcta103.femisi;
            rasiendet.usuari := pin_usuario;
            rasiendet.fcreac := current_date;
            rasiendet.factua := current_date;
            rasiendet.regcomcol := 0;
            rasiendet.swprovicion := 'N';
            rasiendet.saldo := 0;
            rasiendet.swgasoper := 1;
            rasiendet.codporret := '';
            rasiendet.swchkconcilia := 'N';
            PIPE ROW ( rasiendet );
        END IF;

    END LOOP;

    FOR reg_dcta113 IN cur_dcta113 LOOP
        IF reg_dcta113.situac <> 'J' THEN
            item := item + 1;
            rasiendet.id_cia := pin_id_cia;
            rasiendet.periodo := pin_periodo;
            rasiendet.mes := pin_mes;
            rasiendet.libro := pin_libro;
            rasiendet.asiento := pin_secuencia;
            rasiendet.item := item;
            rasiendet.sitem := 0;
            rasiendet.concep := substr(reg_dcta113.razonc, 1, 74);
            rasiendet.fecha := reg_dcta113.femisi;
            rasiendet.tasien := 66;
            rasiendet.topera := 0;
            rasiendet.cuenta := reg_dcta113.cuenta;
            rasiendet.dh := reg_dcta113.dh;
            rasiendet.moneda := reg_dcta113.tmonpag;
            IF reg_dcta113.tmonpag = 'PEN' THEN
                rasiendet.tcambio01 := 1;
                rasiendet.tcambio02 := 1 / reg_dcta113.dtipcam;
            END IF;

            IF reg_dcta113.tmonpag <> 'PEN' THEN
                rasiendet.tcambio01 := reg_dcta113.dtipcam;
                rasiendet.tcambio02 := 1;
            END IF;

            rasiendet.importe := reg_dcta113.amorti;
            rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
            rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
            rasiendet.debe := 0;
            rasiendet.debe01 := 0;
            rasiendet.debe02 := 0;
            rasiendet.haber := 0;
            rasiendet.haber01 := 0;
            rasiendet.haber02 := 0;
            CASE
                WHEN rasiendet.dh = 'D' THEN
                    rasiendet.debe := rasiendet.importe;
                    rasiendet.debe01 := rasiendet.impor01;
                    rasiendet.debe02 := rasiendet.impor02;
                WHEN rasiendet.dh = 'H' THEN
                    rasiendet.haber := rasiendet.importe;
                    rasiendet.haber01 := rasiendet.impor01;
                    rasiendet.haber02 := rasiendet.impor02;
            END CASE;

            rasiendet.ccosto := ' ';
            rasiendet.proyec := ' ';
            rasiendet.subcco := ' ';
            rasiendet.ctaalternativa := ' ';
            rasiendet.tipo := 0;
            rasiendet.docume := 0;
            rasiendet.codigo := reg_dcta113.codcli;
            rasiendet.razon := substr(reg_dcta113.razonc, 1, 74);
            rasiendet.tident := ' ';
            rasiendet.dident := ' ';
            rasiendet.tdocum := reg_dcta113.codsunat;
            rasiendet.serie := reg_dcta113.serie;
            rasiendet.numero := reg_dcta113.numero;
            rasiendet.fdocum := reg_dcta113.femisi;
            rasiendet.usuari := pin_usuario;
            rasiendet.fcreac := current_date;
            rasiendet.factua := current_date;
            rasiendet.regcomcol := 0;
            rasiendet.swprovicion := 'N';
            rasiendet.saldo := 0;
            rasiendet.swgasoper := 1;
            rasiendet.codporret := '';
            rasiendet.swchkconcilia := 'N';
            PIPE ROW ( rasiendet );
        END IF;
    END LOOP;

    FOR reg_dcta105 IN cur_dcta105(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia) LOOP
        IF reg_dcta105.situac <> 'J' THEN
            item := item + 1;
            rasiendet.id_cia := pin_id_cia;
            rasiendet.periodo := pin_periodo;
            rasiendet.mes := pin_mes;
            rasiendet.libro := pin_libro;
            rasiendet.asiento := pin_secuencia;
            rasiendet.item := item;
            rasiendet.sitem := 0;
            rasiendet.concep := substr(reg_dcta105.razonc, 1, 74);
            rasiendet.fecha := reg_dcta105.femisi;
            rasiendet.tasien := 66;
            rasiendet.topera := 0;
            rasiendet.cuenta := reg_dcta105.cuenta;
            rasiendet.dh := reg_dcta105.dh;
            rasiendet.moneda := reg_dcta105.tipmon;
            IF reg_dcta105.tipmon = 'PEN' THEN
                rasiendet.tcambio01 := 1;
                rasiendet.tcambio02 := 1 / reg_dcta105.tipcam;
            END IF;

            IF reg_dcta105.tipmon <> 'PEN' THEN
                rasiendet.tcambio01 := reg_dcta105.tipcam;
                rasiendet.tcambio02 := 1;
            END IF;

            rasiendet.importe := reg_dcta105.importe;
            rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
            rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
            rasiendet.debe := 0;
            rasiendet.debe01 := 0;
            rasiendet.debe02 := 0;
            rasiendet.haber := 0;
            rasiendet.haber01 := 0;
            rasiendet.haber02 := 0;
            CASE
                WHEN rasiendet.dh = 'D' THEN
                    rasiendet.debe := rasiendet.importe;
                    rasiendet.debe01 := rasiendet.impor01;
                    rasiendet.debe02 := rasiendet.impor02;
                WHEN rasiendet.dh = 'H' THEN
                    rasiendet.haber := rasiendet.importe;
                    rasiendet.haber01 := rasiendet.impor01;
                    rasiendet.haber02 := rasiendet.impor02;
            END CASE;

            rasiendet.ccosto := ' ';
            rasiendet.proyec := ' ';
            rasiendet.subcco := ' ';
            rasiendet.ctaalternativa := ' ';
            rasiendet.tipo := 0;
            rasiendet.docume := 0;
            rasiendet.codigo := reg_dcta105.codcli;
            rasiendet.razon := substr(reg_dcta105.razonc, 1, 74);
            rasiendet.tident := ' ';
            rasiendet.dident := ' ';
            rasiendet.tdocum := reg_dcta105.codsunat;
            rasiendet.serie := reg_dcta105.serie;
            rasiendet.numero := reg_dcta105.numero;
            rasiendet.fdocum := reg_dcta105.femisi;
            rasiendet.usuari := pin_usuario;
            rasiendet.fcreac := current_date;
            rasiendet.factua := current_date;
            rasiendet.regcomcol := 0;
            rasiendet.swprovicion := 'N';
            rasiendet.saldo := 0;
            rasiendet.swgasoper := 1;
            rasiendet.codporret := '';
            rasiendet.swchkconcilia := 'N';
            PIPE ROW ( rasiendet );
            IF (
                ( reg_dcta105.codban IS NOT NULL )
                AND ( to_number(reg_dcta105.codban) > 0 )
 --               ( ( ( reg_dcta105.codban IS not NULL ) and ( trim(reg_dcta105.codban) <> '' ) ) ) /*AND ( to_number(reg_dcta105.codban) >  0 )*/
            ) THEN
                BEGIN
                    SELECT
                        cuentacon
                    INTO rasiendet.cuenta
                    FROM
                        tbancos
                    WHERE
                            id_cia = pin_id_cia
                        AND codban = reg_dcta105.codban;

                EXCEPTION
                    WHEN no_data_found THEN
                        rasiendet.cuenta := '';
                END;

                item := item + 1;
                rasiendet.item := item;
                rasiendet.tdocum := '';
                rasiendet.serie := '';
                rasiendet.numero := '';
                rasiendet.debe := 0;
                rasiendet.debe01 := 0;
                rasiendet.debe02 := 0;
                rasiendet.haber := 0;
                rasiendet.haber01 := 0;
                rasiendet.haber02 := 0;
                IF ( rasiendet.dh = 'D' ) THEN
                    rasiendet.dh := 'H';
                    rasiendet.haber := rasiendet.importe;
                    rasiendet.haber01 := rasiendet.impor01;
                    rasiendet.haber02 := rasiendet.impor02;
                ELSE
                    rasiendet.dh := 'D';
                    rasiendet.debe := rasiendet.importe;
                    rasiendet.debe01 := rasiendet.impor01;
                    rasiendet.debe02 := rasiendet.impor02;
                END IF;

                PIPE ROW ( rasiendet );
            END IF;

        END IF;
    END LOOP;

/*Cuentas por Pagar*/

    BEGIN
        SELECT
            vstrg
        INTO v_codbanretsol
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 319;--- Código de Banco para Deposito de Retención en Soles.

    EXCEPTION
        WHEN no_data_found THEN
            v_codbanretsol := '';
    END;

    BEGIN
        SELECT
            vstrg
        INTO v_codbanretdol
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 320;--- Código de Banco para Deposito de Retención en Dolares.

    EXCEPTION
        WHEN no_data_found THEN
            v_codbanretdol := '';
    END;

    v_codcli := '';
    v_razonc := '';
    OPEN cur_prov103;   --abre el cursor
    LOOP
        FETCH cur_prov103 INTO v_prov103_rec;   --asigna los valores a las variables.
        EXIT WHEN cur_prov103%notfound;
        v_codcli := v_prov103_rec.codcli;
        v_razonc := v_prov103_rec.razonc;
    END LOOP;

    CLOSE cur_prov103;       --cierra el cursor.

    FOR reg_prov104 IN cur_prov104 LOOP
        IF reg_prov104.situac <> 'J' THEN
            item := item + 1;
            rasiendet.id_cia := pin_id_cia;
            rasiendet.periodo := pin_periodo;
            rasiendet.mes := pin_mes;
            rasiendet.libro := pin_libro;
            rasiendet.asiento := pin_secuencia;
            rasiendet.item := item;
            rasiendet.sitem := 0;
            rasiendet.concep := substr(v_concep_p102, 1, 74);
            rasiendet.fecha := v_femisi_p102;
            rasiendet.tasien := 66;
            rasiendet.topera := reg_prov104.tipdep;
            rasiendet.cuenta := reg_prov104.cuenta;
            IF reg_prov104.deposito < 0 THEN
                CASE
                    WHEN reg_prov104.dh = 'D' THEN
                        rasiendet.dh := 'H';
                    WHEN reg_prov104.dh = 'H' THEN
                        rasiendet.dh := 'D';
                END CASE;
            ELSE
                rasiendet.dh := reg_prov104.dh;
            END IF;

            rasiendet.moneda := reg_prov104.tipmon;
            rasiendet.importe := abs(reg_prov104.deposito);
            rasiendet.impor01 := abs(reg_prov104.impor01);
            rasiendet.impor02 := abs(reg_prov104.impor02);
            rasiendet.debe := 0;
            rasiendet.debe01 := 0;
            rasiendet.debe02 := 0;
            rasiendet.haber := 0;
            rasiendet.haber01 := 0;
            rasiendet.haber02 := 0;
            CASE
                WHEN rasiendet.dh = 'D' THEN
                    rasiendet.debe := rasiendet.importe;
                    rasiendet.debe01 := rasiendet.impor01;
                    rasiendet.debe02 := rasiendet.impor02;
                WHEN rasiendet.dh = 'H' THEN
                    rasiendet.haber := rasiendet.importe;
                    rasiendet.haber01 := rasiendet.impor01;
                    rasiendet.haber02 := rasiendet.impor02;
            END CASE;

            rasiendet.tcambio01 := reg_prov104.tcamb01;
            rasiendet.tcambio02 := reg_prov104.tcamb02;
            rasiendet.ccosto := ' ';
            rasiendet.proyec := ' ';
            rasiendet.subcco := ' ';
            rasiendet.ctaalternativa := ' ';
            rasiendet.tipo := 0;
            rasiendet.docume := 0;
            IF ( ( reg_prov104.codban = v_codbanretsol ) OR ( reg_prov104.codban = v_codbanretdol ) ) THEN
                rasiendet.codigo := reg_prov104.retcodcli;
                rasiendet.razon := substr(reg_prov104.concep, 1, 74);
                rasiendet.tdocum := '20';
                rasiendet.serie := reg_prov104.retserie;
                rasiendet.numero := reg_prov104.retnumero;
                rasiendet.fdocum := v_femisi_p102;
            ELSE
                rasiendet.codigo := reg_prov104.codigo;
                IF length(reg_prov104.razon) > 0 THEN
                    rasiendet.razon := substr(reg_prov104.razon, 1, 74);
                ELSE
                    IF length(trim(v_girara)) > 0 THEN
                        rasiendet.razon := substr(v_girara, 1, 74);
                    ELSE
                        IF ( ( rasiendet.codigo IS NULL ) OR ( length(trim(rasiendet.codigo)) = 0 ) ) THEN
                            rasiendet.codigo := v_codcli;
                            rasiendet.razon := substr(v_razonc, 1, 74);
                        END IF;
                    END IF;
                END IF;

                IF ( ( length(reg_prov104.serie) > 0 ) OR ( length(reg_prov104.numero) > 0 ) ) THEN
                    rasiendet.tdocum := reg_prov104.tdocum;
                    rasiendet.serie := reg_prov104.serie;
                    rasiendet.numero := reg_prov104.numero;
                ELSE
                    rasiendet.tdocum := '';
                    rasiendet.serie := '';
                    CASE
                        WHEN v_referencia IS NOT NULL THEN
                            rasiendet.numero := v_referencia;/*CHEQUE*/
                        ELSE
                            rasiendet.numero := reg_prov104.op;
                    END CASE;

                END IF;

                rasiendet.fdocum := v_femisi_p102;
                rasiendet.concep := substr(v_concep_p102, 1, 74);
                rasiendet.tident := ' ';
                rasiendet.dident := ' ';
                rasiendet.usuari := pin_usuario;
                rasiendet.fcreac := current_date;
                rasiendet.factua := current_date;
                rasiendet.regcomcol := 0;
                rasiendet.swprovicion := 'N';
                rasiendet.saldo := 0;
                rasiendet.swgasoper := 1;
                rasiendet.codporret := '';
                rasiendet.swchkconcilia := 'N';
            END IF;

            PIPE ROW ( rasiendet );
        END IF;
    END LOOP;

    FOR reg_prov103 IN cur_prov103 LOOP
        IF reg_prov103.situac <> 'J' THEN
            item := item + 1;
            rasiendet.id_cia := pin_id_cia;
            rasiendet.periodo := pin_periodo;
            rasiendet.mes := pin_mes;
            rasiendet.libro := pin_libro;
            rasiendet.asiento := pin_secuencia;
            rasiendet.item := item;
            rasiendet.sitem := 0;
            rasiendet.concep := substr(v_concep_p102, 1, 74);
            rasiendet.fecha := v_femisi_p102;
            rasiendet.tasien := 1;
            rasiendet.topera := 0;
            rasiendet.cuenta := reg_prov103.cuenta;
            rasiendet.dh := reg_prov103.dh;
            rasiendet.moneda := reg_prov103.tmonpag;
            IF reg_prov103.tmonpag = 'PEN' THEN
                rasiendet.tcambio01 := 1;
                rasiendet.tcambio02 := 1 / reg_prov103.tipcamdoc;
            END IF;

            IF reg_prov103.tmonpag <> 'PEN' THEN
                rasiendet.tcambio01 := reg_prov103.tipcamdoc;
                rasiendet.tcambio02 := 1;
            END IF;

            rasiendet.importe := reg_prov103.amorti;
            IF reg_prov103.tmondoc = reg_prov103.tmonpag THEN
                rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
            ELSE
                IF reg_prov103.tmondoc = 'PEN' THEN
                    rasiendet.impor01 := reg_prov103.impor01;
                    rasiendet.impor02 := reg_prov103.impor01 / rasiendet.tcambio01;
                    rasiendet.importe := rasiendet.impor02;
                ELSIF ( reg_prov103.tmondoc <> 'PEN' ) THEN
                    rasiendet.impor01 := reg_prov103.impor02 / rasiendet.tcambio02;
                    rasiendet.impor02 := reg_prov103.impor02;
                    rasiendet.importe := rasiendet.impor01;
                END IF;
            END IF;

            rasiendet.debe := 0;
            rasiendet.debe01 := 0;
            rasiendet.debe02 := 0;
            rasiendet.haber := 0;
            rasiendet.haber01 := 0;
            rasiendet.haber02 := 0;
            CASE
                WHEN rasiendet.dh = 'D' THEN
                    rasiendet.debe := rasiendet.importe;
                    rasiendet.debe01 := rasiendet.impor01;
                    rasiendet.debe02 := rasiendet.impor02;
                WHEN rasiendet.dh = 'H' THEN
                    rasiendet.haber := rasiendet.importe;
                    rasiendet.haber01 := rasiendet.impor01;
                    rasiendet.haber02 := rasiendet.impor02;
            END CASE;

            rasiendet.ccosto := ' ';
            rasiendet.proyec := ' ';
            rasiendet.subcco := ' ';
            rasiendet.ctaalternativa := ' ';
            rasiendet.tipo := 0;
            rasiendet.docume := 0;
            rasiendet.codigo := reg_prov103.codcli;
            rasiendet.razon := substr(reg_prov103.razonc, 1, 74);
            rasiendet.tident := '';
            rasiendet.dident := ' ';
            rasiendet.tdocum := reg_prov103.tipdoc;
            rasiendet.serie := reg_prov103.serie;
            rasiendet.numero := reg_prov103.numero;
            rasiendet.fdocum := reg_prov103.femisi;
            rasiendet.usuari := pin_usuario;
            rasiendet.fcreac := current_date;
            rasiendet.factua := current_date;
            rasiendet.regcomcol := 0;
            rasiendet.swprovicion := 'N';
            rasiendet.saldo := 0;
            rasiendet.swgasoper := 0;
            rasiendet.codporret := '';
            IF reg_prov103.swchkretiene = 'S' THEN
                rasiendet.swgasoper := 1;
                rasiendet.codporret := '060'; /* Codigo del Factor de Retencion 6 %  */
            END IF;

            rasiendet.swchkconcilia := 'N';
            PIPE ROW ( rasiendet );
        END IF;
    END LOOP;

    FOR reg_prov113 IN cur_prov113 LOOP
        IF reg_prov113.situac <> 'J' THEN
            item := item + 1;
            rasiendet.id_cia := pin_id_cia;
            rasiendet.periodo := pin_periodo;
            rasiendet.mes := pin_mes;
            rasiendet.libro := pin_libro;
            rasiendet.asiento := pin_secuencia;
            rasiendet.item := item;
            rasiendet.sitem := 0;
            rasiendet.concep := substr(reg_prov113.razonc, 1, 74);
            rasiendet.fecha := reg_prov113.femisi;
            rasiendet.tasien := 66;
            rasiendet.topera := 0;
            rasiendet.cuenta := reg_prov113.cuenta;
            rasiendet.dh := reg_prov113.dh;
            rasiendet.moneda := reg_prov113.tmonpag;
            IF reg_prov113.tmonpag = 'PEN' THEN
                rasiendet.tcambio01 := 1;
                rasiendet.tcambio02 := 1 / reg_prov113.doctipcam;
            END IF;

            IF reg_prov113.tmonpag <> 'PEN' THEN
                rasiendet.tcambio01 := reg_prov113.doctipcam;
                rasiendet.tcambio02 := 1;
            END IF;

            rasiendet.importe := reg_prov113.amorti;
            IF reg_prov113.tmondoc = reg_prov113.tmonpag THEN
                rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
                rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
            ELSE
                IF reg_prov113.tmondoc = 'PEN' THEN
                    rasiendet.impor01 := reg_prov113.impor01;
                    rasiendet.impor02 := reg_prov113.impor01 / rasiendet.tcambio01;
                    rasiendet.importe := rasiendet.impor02;
                ELSIF ( reg_prov113.tmondoc <> 'PEN' ) THEN
                    rasiendet.impor01 := reg_prov113.impor02 / rasiendet.tcambio02;
                    rasiendet.impor02 := reg_prov113.impor02;
                    rasiendet.importe := rasiendet.impor01;
                END IF;
            END IF;

            rasiendet.debe := 0;
            rasiendet.debe01 := 0;
            rasiendet.debe02 := 0;
            rasiendet.haber := 0;
            rasiendet.haber01 := 0;
            rasiendet.haber02 := 0;
            CASE
                WHEN rasiendet.dh = 'D' THEN
                    rasiendet.debe := rasiendet.importe;
                    rasiendet.debe01 := rasiendet.impor01;
                    rasiendet.debe02 := rasiendet.impor02;
                WHEN rasiendet.dh = 'H' THEN
                    rasiendet.haber := rasiendet.importe;
                    rasiendet.haber01 := rasiendet.impor01;
                    rasiendet.haber02 := rasiendet.impor02;
            END CASE;

            rasiendet.ccosto := ' ';
            rasiendet.proyec := ' ';
            rasiendet.subcco := ' ';
            rasiendet.ctaalternativa := ' ';
            rasiendet.tipo := 0;
            rasiendet.docume := 0;
            rasiendet.codigo := reg_prov113.codcli;
            rasiendet.razon := substr(reg_prov113.razonc, 1, 74);
            rasiendet.tident := ' ';
            rasiendet.dident := ' ';
            rasiendet.tdocum := reg_prov113.codsunat;
            rasiendet.serie := reg_prov113.serie;
            rasiendet.numero := reg_prov113.numero;
            rasiendet.fdocum := reg_prov113.femisi;
            rasiendet.usuari := pin_usuario;
            rasiendet.fcreac := current_date;
            rasiendet.factua := current_date;
            rasiendet.regcomcol := 0;
            rasiendet.swprovicion := 'N';
            rasiendet.saldo := 0;
            rasiendet.swgasoper := 1;
            rasiendet.codporret := '';
            rasiendet.swchkconcilia := 'N';
            PIPE ROW ( rasiendet );
        END IF;
    END LOOP;

    FOR reg_prov105 IN cur_prov105 LOOP
        IF reg_prov105.situac <> 'J' THEN
            item := item + 1;
            rasiendet.id_cia := pin_id_cia;
            rasiendet.periodo := pin_periodo;
            rasiendet.mes := pin_mes;
            rasiendet.libro := pin_libro;
            rasiendet.asiento := pin_secuencia;
            rasiendet.item := item;
            rasiendet.sitem := 0;
            rasiendet.concep := substr(reg_prov105.razonc, 1, 74);
            rasiendet.fecha := reg_prov105.femisi;
            rasiendet.tasien := 66;
            rasiendet.topera := 0;
            rasiendet.cuenta := reg_prov105.cuenta;
            rasiendet.dh := reg_prov105.dh;
            rasiendet.moneda := reg_prov105.tipmon;
            IF reg_prov105.tipmon = 'PEN' THEN
                rasiendet.tcambio01 := 1;
                rasiendet.tcambio02 := 1 / reg_prov105.tipcam;
            END IF;

            IF reg_prov105.tipmon <> 'PEN' THEN
                rasiendet.tcambio01 := reg_prov105.tipcam;
                rasiendet.tcambio02 := 1;
            END IF;

            rasiendet.importe := reg_prov105.importe;
            rasiendet.impor01 := rasiendet.importe * rasiendet.tcambio01;
            rasiendet.impor02 := rasiendet.importe * rasiendet.tcambio02;
            rasiendet.debe := 0;
            rasiendet.debe01 := 0;
            rasiendet.debe02 := 0;
            rasiendet.haber := 0;
            rasiendet.haber01 := 0;
            rasiendet.haber02 := 0;
            CASE
                WHEN rasiendet.dh = 'D' THEN
                    rasiendet.debe := rasiendet.importe;
                    rasiendet.debe01 := rasiendet.impor01;
                    rasiendet.debe02 := rasiendet.impor02;
                WHEN rasiendet.dh = 'H' THEN
                    rasiendet.haber := rasiendet.importe;
                    rasiendet.haber01 := rasiendet.impor01;
                    rasiendet.haber02 := rasiendet.impor02;
            END CASE;

            rasiendet.ccosto := ' ';
            rasiendet.proyec := ' ';
            rasiendet.subcco := ' ';
            rasiendet.ctaalternativa := ' ';
            rasiendet.tipo := 0;
            rasiendet.docume := 0;
            rasiendet.codigo := reg_prov105.codcli;
            rasiendet.razon := substr(reg_prov105.razonc, 1, 74);
            rasiendet.tident := ' ';
            rasiendet.dident := ' ';
            rasiendet.tdocum := reg_prov105.codsunat;
            rasiendet.serie := reg_prov105.serie;
            rasiendet.numero := reg_prov105.numero;
            rasiendet.fdocum := reg_prov105.femisi;
            rasiendet.usuari := pin_usuario;
            rasiendet.fcreac := current_date;
            rasiendet.factua := current_date;
            rasiendet.regcomcol := 0;
            rasiendet.swprovicion := 'N';
            rasiendet.saldo := 0;
            rasiendet.swgasoper := 1;
            rasiendet.codporret := '';
            rasiendet.swchkconcilia := 'N';
            PIPE ROW ( rasiendet );
            IF (
                ( reg_prov105.codban IS NOT NULL )
                AND ( to_number(reg_prov105.codban) > 0 )
 --               ( ( ( reg_prov105.codban IS not NULL ) and ( trim(reg_prov105.codban) <> '' ) ) ) /*AND ( to_number(reg_prov105.codban) >  0 )*/
            ) THEN
                BEGIN
                    SELECT
                        cuentacon
                    INTO rasiendet.cuenta
                    FROM
                        tbancos
                    WHERE
                            id_cia = pin_id_cia
                        AND codban = reg_prov105.codban;

                EXCEPTION
                    WHEN no_data_found THEN
                        rasiendet.cuenta := '';
                END;

                item := item + 1;
                rasiendet.item := item;
                rasiendet.fdocum := NULL;
                rasiendet.tdocum := '';
                rasiendet.serie := '';
                rasiendet.numero := reg_prov105.refere;
                rasiendet.debe := 0;
                rasiendet.debe01 := 0;
                rasiendet.debe02 := 0;
                rasiendet.haber := 0;
                rasiendet.haber01 := 0;
                rasiendet.haber02 := 0;
                IF ( rasiendet.dh = 'D' ) THEN
                    rasiendet.dh := 'H';
                    rasiendet.haber := rasiendet.importe;
                    rasiendet.haber01 := rasiendet.impor01;
                    rasiendet.haber02 := rasiendet.impor02;
                ELSE
                    rasiendet.dh := 'D';
                    rasiendet.debe := rasiendet.importe;
                    rasiendet.debe01 := rasiendet.impor01;
                    rasiendet.debe02 := rasiendet.impor02;
                END IF;

                PIPE ROW ( rasiendet );
            END IF;

        END IF;
    END LOOP;

END sp_contabilidad_cuentas_para_asientos_cxcobrar;

/
