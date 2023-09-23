--------------------------------------------------------
--  DDL for Procedure SP_ADDDIFCAMBIO_ASIENDET
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ADDDIFCAMBIO_ASIENDET" (
    pin_id_cia            IN  NUMBER,
    pin_periodo           IN  NUMBER,
    pin_mes               IN  NUMBER,
    pin_libro             IN  VARCHAR2,
    pin_secuencia         IN  NUMBER,
    pin_coduser           IN  VARCHAR2,
    pin_swnoseparamoneda  IN  VARCHAR2
) AS

    rasiendet1  rec_detalle_asiento := rec_detalle_asiento(NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL);
    rasiendet2  rec_detalle_asiento := rec_detalle_asiento(NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL);
    CURSOR cur_agrupamon IS
    SELECT
        moneda,
        MAX(fecha)                AS fecha,
        SUM(debe01 - haber01)     AS total01,
        SUM(debe02 - haber02)     AS total02
    FROM
        asiendet
    WHERE
            id_cia = pin_id_cia
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND libro = pin_libro
        AND asiento = pin_secuencia
    GROUP BY
        moneda;

    CURSOR cur_noagrupamon IS
    SELECT
        moneda,
        MAX(fecha)                AS fecha,
        SUM(debe01 - haber01)     AS total01,
        SUM(debe02 - haber02)     AS total02
    FROM
        asiendet
    WHERE
            id_cia = pin_id_cia
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND libro = pin_libro
        AND asiento = pin_secuencia
    GROUP BY
        moneda;

    v_item      NUMBER := 0;
    v_moneda    VARCHAR2(5);
    v_cdifhab   VARCHAR(16) := '';
    v_cdifdeb   VARCHAR(16) := '';
BEGIN
    BEGIN
        SELECT
            TRIM(moneda01)
        INTO v_moneda
        FROM
            companias
        WHERE
            cia = pin_id_cia;

    EXCEPTION
        WHEN no_data_found THEN
            v_moneda := NULL;
    END;

    IF v_moneda <> '' THEN
        BEGIN
            SELECT
                cdifhab,
                cdifdeb
            INTO
                v_cdifhab,
                v_cdifdeb
            FROM
                tmoneda
            WHERE
                    id_cia = pin_id_cia
                AND codmon = v_moneda;

        EXCEPTION
            WHEN no_data_found THEN
                v_cdifhab := NULL;
                v_cdifdeb := NULL;
        END;

    END IF;

    IF NOT ( upper(pin_swnoseparamoneda) = 'S' ) THEN
        FOR reg_asiendet IN cur_agrupamon LOOP
            IF NOT ( reg_asiendet.total01 = 0 ) THEN
                BEGIN
                    SELECT
                        trunc((MAX(item) / 1)) AS item
                    INTO v_item
                    FROM
                        asiendet
                    WHERE
                            id_cia = pin_id_cia
                        AND ( periodo = pin_periodo )
                        AND ( mes = pin_mes )
                        AND ( libro = pin_libro )
                        AND ( asiento = pin_secuencia );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_item := 0;
                END;

                rasiendet1.id_cia := pin_id_cia;
                rasiendet1.periodo := pin_periodo;
                rasiendet1.mes := pin_mes;
                rasiendet1.libro := pin_libro;
                rasiendet1.asiento := pin_secuencia;
                rasiendet1.item := v_item + 1;
                rasiendet1.sitem := 0;
                rasiendet1.concep := 'Diferencia de cambio';
                rasiendet1.fecha := reg_asiendet.fecha;
                rasiendet1.fdocum := reg_asiendet.fecha;
                rasiendet1.moneda := reg_asiendet.moneda;
                rasiendet1.tasien := 99;
                rasiendet1.topera := '';
                IF ( reg_asiendet.total01 > 0 ) THEN
                    rasiendet1.dh := 'H';
                    rasiendet1.cuenta := v_cdifhab;
                ELSE
                    rasiendet1.dh := 'D';
                    rasiendet1.cuenta := v_cdifdeb;
                END IF;

                IF ( reg_asiendet.moneda = 'PEN' ) THEN
                    rasiendet1.tcambio01 := 1;
                    rasiendet1.tcambio02 := abs(reg_asiendet.total02 / reg_asiendet.total01);
                    rasiendet1.importe := abs(reg_asiendet.total01);
                ELSE
                    rasiendet1.tcambio01 := abs(reg_asiendet.total01 / reg_asiendet.total02);
                    rasiendet1.tcambio02 := 1;
                END IF;

                rasiendet1.impor01 := abs(reg_asiendet.total01);
                rasiendet1.impor02 := abs(reg_asiendet.total02);
                rasiendet1.debe := 0;
                rasiendet1.debe01 := 0;
                rasiendet1.debe02 := 0;
                rasiendet1.haber := 0;
                rasiendet1.haber01 := 0;
                rasiendet1.haber02 := 0;
                CASE
                    WHEN rasiendet1.dh = 'D' THEN
                        rasiendet1.debe := rasiendet1.importe;
                        rasiendet1.debe01 := rasiendet1.impor01;
                        rasiendet1.debe02 := rasiendet1.impor02;
                    WHEN rasiendet1.dh = 'H' THEN
                        rasiendet1.haber := rasiendet1.importe;
                        rasiendet1.haber01 := rasiendet1.impor01;
                        rasiendet1.haber02 := rasiendet1.impor02;
                END CASE;

                rasiendet1.ccosto := ' ';
                rasiendet1.proyec := ' ';
                rasiendet1.subcco := ' ';
                rasiendet1.ctaalternativa := ' ';
                rasiendet1.tipo := 0;
                rasiendet1.docume := 0;
                rasiendet1.codigo := ' ';
                rasiendet1.razon := '';
                rasiendet1.tident := ' ';
                rasiendet1.dident := ' ';
                rasiendet1.tdocum := ' ';
                rasiendet1.serie := ' ';
                rasiendet1.numero := '';
                rasiendet1.usuari := pin_coduser;
                rasiendet1.fcreac := sysdate;
                rasiendet1.factua := sysdate;
                rasiendet1.regcomcol := 0;
                rasiendet1.swprovicion := 'N';
                rasiendet1.saldo := 0;
                rasiendet1.swgasoper := 1;
                rasiendet1.codporret := '';
                rasiendet1.swchkconcilia := 'N';
                INSERT INTO asiendet (
                    id_cia,--01
                    periodo,--02
                    mes,--03
                    libro,--04
                    asiento,--05
                    item,--06
                    sitem,--07
                    concep,--08
                    fecha,--09
                    tasien,--10
                    topera,--11
                    cuenta,--12
                    dh,--13
                    moneda,--14
                    importe,--15
                    impor01,--16
                    impor02,--17
                    debe,--18
                    debe01,--19
                    debe02,--20
                    haber,--21
                    haber01,--22
                    haber02,--23
                    tcambio01,--24
                    tcambio02,--25
                    ccosto,--26
                    proyec,--27
                    subcco,--28
                    ctaalternativa,--29
                    tipo,--30
                    docume,--31
                    codigo,--32
                    razon,--33
                    tident,--34
                    dident,--35
                    tdocum,--36
                    serie,--37
                    numero,--38
                    fdocum,--39
                    usuari,--40
                    fcreac,--41
                    factua,--42
                    regcomcol,--43
                    swprovicion,--44
                    saldo,--45
                    swgasoper,--46
                    codporret,--47
                    swchkconcilia--48
                ) VALUES (
                    pin_id_cia,
                    rasiendet1.periodo,
                    rasiendet1.mes,
                    rasiendet1.libro,
                    rasiendet1.asiento,
                    rasiendet1.item,
                    rasiendet1.sitem,
                    rasiendet1.concep,
                    rasiendet1.fecha,
                    rasiendet1.tasien,
                    rasiendet1.topera,
                    rasiendet1.cuenta,
                    rasiendet1.dh,
                    rasiendet1.moneda,
                    rasiendet1.importe,
                    rasiendet1.impor01,
                    rasiendet1.impor02,
                    rasiendet1.debe,
                    rasiendet1.debe01,
                    rasiendet1.debe02,
                    rasiendet1.haber,
                    rasiendet1.haber01,
                    rasiendet1.haber02,
                    rasiendet1.tcambio01,
                    rasiendet1.tcambio02,
                    rasiendet1.ccosto,
                    rasiendet1.proyec,
                    rasiendet1.subcco,
                    rasiendet1.ctaalternativa,
                    rasiendet1.tipo,
                    rasiendet1.docume,
                    rasiendet1.codigo,
                    rasiendet1.razon,
                    rasiendet1.tident,
                    rasiendet1.dident,
                    rasiendet1.tdocum,
                    rasiendet1.serie,
                    rasiendet1.numero,
                    rasiendet1.fdocum,
                    rasiendet1.usuari,
                    rasiendet1.fcreac,
                    rasiendet1.factua,
                    rasiendet1.regcomcol,
                    rasiendet1.swprovicion,
                    rasiendet1.saldo,
                    rasiendet1.swgasoper,
                    rasiendet1.codporret,
                    rasiendet1.swchkconcilia
                );

                COMMIT;
            END IF;
        END LOOP;

        FOR reg_asiendet IN cur_agrupamon LOOP
            IF NOT ( reg_asiendet.total02 = 0 ) THEN
                BEGIN
                    SELECT
                        trunc((MAX(item) / 1)) AS item
                    INTO v_item
                    FROM
                        asiendet
                    WHERE
                            id_cia = pin_id_cia
                        AND ( periodo = pin_periodo )
                        AND ( mes = pin_mes )
                        AND ( libro = pin_libro )
                        AND ( asiento = pin_secuencia );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_item := 0;
                END;

                rasiendet2.id_cia := pin_id_cia;
                rasiendet2.periodo := pin_periodo;
                rasiendet2.mes := pin_mes;
                rasiendet2.libro := pin_libro;
                rasiendet2.asiento := pin_secuencia;
                rasiendet2.item := v_item + 1;
                rasiendet2.sitem := 0;
                rasiendet2.concep := 'Diferencia de cambio';
                rasiendet2.fecha := reg_asiendet.fecha;
                rasiendet2.fdocum := reg_asiendet.fecha;
                rasiendet2.moneda := reg_asiendet.moneda;
                rasiendet2.tasien := 99;
                rasiendet2.topera := '';
                IF ( reg_asiendet.total02 > 0 ) THEN
                    rasiendet2.dh := 'H';
                    rasiendet2.cuenta := v_cdifhab;
                ELSE
                    rasiendet2.dh := 'D';
                    rasiendet2.cuenta := v_cdifdeb;
                END IF;

                IF ( reg_asiendet.moneda = 'PEN' ) THEN
                    rasiendet2.tcambio01 := 1;
                    rasiendet2.tcambio02 := abs(reg_asiendet.total02 / reg_asiendet.total01);
                    rasiendet2.importe := abs(reg_asiendet.total01);
                ELSE
                    rasiendet2.tcambio01 := abs(reg_asiendet.total01 / reg_asiendet.total02);
                    rasiendet2.tcambio02 := 1;
                END IF;

                rasiendet2.impor01 := abs(reg_asiendet.total01);
                rasiendet2.impor02 := abs(reg_asiendet.total02);
                rasiendet2.debe := 0;
                rasiendet2.debe01 := 0;
                rasiendet2.debe02 := 0;
                rasiendet2.haber := 0;
                rasiendet2.haber01 := 0;
                rasiendet2.haber02 := 0;
                CASE
                    WHEN rasiendet2.dh = 'D' THEN
                        rasiendet2.debe := rasiendet2.importe;
                        rasiendet2.debe01 := rasiendet2.impor01;
                        rasiendet2.debe02 := rasiendet2.impor02;
                    WHEN rasiendet2.dh = 'H' THEN
                        rasiendet2.haber := rasiendet2.importe;
                        rasiendet2.haber01 := rasiendet2.impor01;
                        rasiendet2.haber02 := rasiendet2.impor02;
                END CASE;

                rasiendet2.ccosto := ' ';
                rasiendet2.proyec := ' ';
                rasiendet2.subcco := ' ';
                rasiendet2.ctaalternativa := ' ';
                rasiendet2.tipo := 0;
                rasiendet2.docume := 0;
                rasiendet2.codigo := ' ';
                rasiendet2.razon := '';
                rasiendet2.tident := ' ';
                rasiendet2.dident := ' ';
                rasiendet2.tdocum := ' ';
                rasiendet2.serie := ' ';
                rasiendet2.numero := '';
                rasiendet2.usuari := pin_coduser;
                rasiendet2.fcreac := sysdate;
                rasiendet2.factua := sysdate;
                rasiendet2.regcomcol := 0;
                rasiendet2.swprovicion := 'N';
                rasiendet2.saldo := 0;
                rasiendet2.swgasoper := 1;
                rasiendet2.codporret := '';
                rasiendet2.swchkconcilia := 'N';
                INSERT INTO asiendet (
                    id_cia,--01
                    periodo,--02
                    mes,--03
                    libro,--04
                    asiento,--05
                    item,--06
                    sitem,--07
                    concep,--08
                    fecha,--09
                    tasien,--10
                    topera,--11
                    cuenta,--12
                    dh,--13
                    moneda,--14
                    importe,--15
                    impor01,--16
                    impor02,--17
                    debe,--18
                    debe01,--19
                    debe02,--20
                    haber,--21
                    haber01,--22
                    haber02,--23
                    tcambio01,--24
                    tcambio02,--25
                    ccosto,--26
                    proyec,--27
                    subcco,--28
                    ctaalternativa,--29
                    tipo,--30
                    docume,--31
                    codigo,--32
                    razon,--33
                    tident,--34
                    dident,--35
                    tdocum,--36
                    serie,--37
                    numero,--38
                    fdocum,--39
                    usuari,--40
                    fcreac,--41
                    factua,--42
                    regcomcol,--43
                    swprovicion,--44
                    saldo,--45
                    swgasoper,--46
                    codporret,--47
                    swchkconcilia--48
                ) VALUES (
                    pin_id_cia,
                    rasiendet2.periodo,
                    rasiendet2.mes,
                    rasiendet2.libro,
                    rasiendet2.asiento,
                    rasiendet2.item,
                    rasiendet2.sitem,
                    rasiendet2.concep,
                    rasiendet2.fecha,
                    rasiendet2.tasien,
                    rasiendet2.topera,
                    rasiendet2.cuenta,
                    rasiendet2.dh,
                    rasiendet2.moneda,
                    rasiendet2.importe,
                    rasiendet2.impor01,
                    rasiendet2.impor02,
                    rasiendet2.debe,
                    rasiendet2.debe01,
                    rasiendet2.debe02,
                    rasiendet2.haber,
                    rasiendet2.haber01,
                    rasiendet2.haber02,
                    rasiendet2.tcambio01,
                    rasiendet2.tcambio02,
                    rasiendet2.ccosto,
                    rasiendet2.proyec,
                    rasiendet2.subcco,
                    rasiendet2.ctaalternativa,
                    rasiendet2.tipo,
                    rasiendet2.docume,
                    rasiendet2.codigo,
                    rasiendet2.razon,
                    rasiendet2.tident,
                    rasiendet2.dident,
                    rasiendet2.tdocum,
                    rasiendet2.serie,
                    rasiendet2.numero,
                    rasiendet2.fdocum,
                    rasiendet2.usuari,
                    rasiendet2.fcreac,
                    rasiendet2.factua,
                    rasiendet2.regcomcol,
                    rasiendet2.swprovicion,
                    rasiendet2.saldo,
                    rasiendet2.swgasoper,
                    rasiendet2.codporret,
                    rasiendet2.swchkconcilia
                );

                COMMIT;
            END IF;
        END LOOP;

    ELSE
        FOR reg_asiendet IN cur_noagrupamon LOOP
            IF NOT ( reg_asiendet.total01 = 0 ) THEN
                BEGIN
                    SELECT
                        trunc((MAX(item) / 1)) AS item
                    INTO v_item
                    FROM
                        asiendet
                    WHERE
                            id_cia = pin_id_cia
                        AND ( periodo = pin_periodo )
                        AND ( mes = pin_mes )
                        AND ( libro = pin_libro )
                        AND ( asiento = pin_secuencia );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_item := 0;
                END;

                rasiendet1.id_cia := pin_id_cia;
                rasiendet1.periodo := pin_periodo;
                rasiendet1.mes := pin_mes;
                rasiendet1.libro := pin_libro;
                rasiendet1.asiento := pin_secuencia;
                rasiendet1.item := v_item + 1;
                rasiendet1.sitem := 0;
                rasiendet1.concep := 'Diferencia de cambio';
                rasiendet1.fecha := reg_asiendet.fecha;
                rasiendet1.fdocum := reg_asiendet.fecha;
                rasiendet1.moneda := v_moneda;
                rasiendet1.tasien := 99;
                rasiendet1.topera := '';
                IF ( reg_asiendet.total01 > 0 ) THEN
                    rasiendet1.dh := 'H';
                    rasiendet1.cuenta := v_cdifhab;
                ELSE
                    rasiendet1.dh := 'D';
                    rasiendet1.cuenta := v_cdifdeb;
                END IF;

                IF ( reg_asiendet.moneda = 'PEN' ) THEN
                    rasiendet1.tcambio01 := 1;
                    rasiendet1.tcambio02 := abs(reg_asiendet.total02 / reg_asiendet.total01);
                    rasiendet1.importe := abs(reg_asiendet.total01);
                ELSE
                    rasiendet1.tcambio01 := abs(reg_asiendet.total01 / reg_asiendet.total02);
                    rasiendet1.tcambio02 := 1;
                END IF;

                rasiendet1.impor01 := abs(reg_asiendet.total01);
                rasiendet1.impor02 := abs(reg_asiendet.total02);
                rasiendet1.debe := 0;
                rasiendet1.debe01 := 0;
                rasiendet1.debe02 := 0;
                rasiendet1.haber := 0;
                rasiendet1.haber01 := 0;
                rasiendet1.haber02 := 0;
                CASE
                    WHEN rasiendet1.dh = 'D' THEN
                        rasiendet1.debe := rasiendet1.importe;
                        rasiendet1.debe01 := rasiendet1.impor01;
                        rasiendet1.debe02 := rasiendet1.impor02;
                    WHEN rasiendet1.dh = 'H' THEN
                        rasiendet1.haber := rasiendet1.importe;
                        rasiendet1.haber01 := rasiendet1.impor01;
                        rasiendet1.haber02 := rasiendet1.impor02;
                END CASE;

                rasiendet1.ccosto := ' ';
                rasiendet1.proyec := ' ';
                rasiendet1.subcco := ' ';
                rasiendet1.ctaalternativa := ' ';
                rasiendet1.tipo := 0;
                rasiendet1.docume := 0;
                rasiendet1.codigo := ' ';
                rasiendet1.razon := '';
                rasiendet1.tident := ' ';
                rasiendet1.dident := ' ';
                rasiendet1.tdocum := ' ';
                rasiendet1.serie := ' ';
                rasiendet1.numero := '';
                rasiendet1.usuari := pin_coduser;
                rasiendet1.fcreac := sysdate;
                rasiendet1.factua := sysdate;
                rasiendet1.regcomcol := 0;
                rasiendet1.swprovicion := 'N';
                rasiendet1.saldo := 0;
                rasiendet1.swgasoper := 1;
                rasiendet1.codporret := '';
                rasiendet1.swchkconcilia := 'N';
                INSERT INTO asiendet (
                    id_cia,--01
                    periodo,--02
                    mes,--03
                    libro,--04
                    asiento,--05
                    item,--06
                    sitem,--07
                    concep,--08
                    fecha,--09
                    tasien,--10
                    topera,--11
                    cuenta,--12
                    dh,--13
                    moneda,--14
                    importe,--15
                    impor01,--16
                    impor02,--17
                    debe,--18
                    debe01,--19
                    debe02,--20
                    haber,--21
                    haber01,--22
                    haber02,--23
                    tcambio01,--24
                    tcambio02,--25
                    ccosto,--26
                    proyec,--27
                    subcco,--28
                    ctaalternativa,--29
                    tipo,--30
                    docume,--31
                    codigo,--32
                    razon,--33
                    tident,--34
                    dident,--35
                    tdocum,--36
                    serie,--37
                    numero,--38
                    fdocum,--39
                    usuari,--40
                    fcreac,--41
                    factua,--42
                    regcomcol,--43
                    swprovicion,--44
                    saldo,--45
                    swgasoper,--46
                    codporret,--47
                    swchkconcilia--48
                ) VALUES (
                    pin_id_cia,
                    rasiendet1.periodo,
                    rasiendet1.mes,
                    rasiendet1.libro,
                    rasiendet1.asiento,
                    rasiendet1.item,
                    rasiendet1.sitem,
                    rasiendet1.concep,
                    rasiendet1.fecha,
                    rasiendet1.tasien,
                    rasiendet1.topera,
                    rasiendet1.cuenta,
                    rasiendet1.dh,
                    rasiendet1.moneda,
                    rasiendet1.importe,
                    rasiendet1.impor01,
                    rasiendet1.impor02,
                    rasiendet1.debe,
                    rasiendet1.debe01,
                    rasiendet1.debe02,
                    rasiendet1.haber,
                    rasiendet1.haber01,
                    rasiendet1.haber02,
                    rasiendet1.tcambio01,
                    rasiendet1.tcambio02,
                    rasiendet1.ccosto,
                    rasiendet1.proyec,
                    rasiendet1.subcco,
                    rasiendet1.ctaalternativa,
                    rasiendet1.tipo,
                    rasiendet1.docume,
                    rasiendet1.codigo,
                    rasiendet1.razon,
                    rasiendet1.tident,
                    rasiendet1.dident,
                    rasiendet1.tdocum,
                    rasiendet1.serie,
                    rasiendet1.numero,
                    rasiendet1.fdocum,
                    rasiendet1.usuari,
                    rasiendet1.fcreac,
                    rasiendet1.factua,
                    rasiendet1.regcomcol,
                    rasiendet1.swprovicion,
                    rasiendet1.saldo,
                    rasiendet1.swgasoper,
                    rasiendet1.codporret,
                    rasiendet1.swchkconcilia
                );

                COMMIT;
            END IF;
        END LOOP;

        FOR reg_asiendet IN cur_noagrupamon LOOP
            IF NOT ( reg_asiendet.total02 = 0 ) THEN
                BEGIN
                    SELECT
                        trunc((MAX(item) / 1)) AS item
                    INTO v_item
                    FROM
                        asiendet
                    WHERE
                            id_cia = pin_id_cia
                        AND ( periodo = pin_periodo )
                        AND ( mes = pin_mes )
                        AND ( libro = pin_libro )
                        AND ( asiento = pin_secuencia );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_item := 0;
                END;

                rasiendet2.id_cia := pin_id_cia;
                rasiendet2.periodo := pin_periodo;
                rasiendet2.mes := pin_mes;
                rasiendet2.libro := pin_libro;
                rasiendet2.asiento := pin_secuencia;
                rasiendet2.item := v_item + 1;
                rasiendet2.sitem := 0;
                rasiendet2.concep := 'Diferencia de cambio';
                rasiendet2.fecha := reg_asiendet.fecha;
                rasiendet2.fdocum := reg_asiendet.fecha;
                rasiendet2.moneda := v_moneda;
                rasiendet2.tasien := 99;
                rasiendet2.topera := '';
                IF ( reg_asiendet.total02 > 0 ) THEN
                    rasiendet2.dh := 'H';
                    rasiendet2.cuenta := v_cdifhab;
                ELSE
                    rasiendet2.dh := 'D';
                    rasiendet2.cuenta := v_cdifdeb;
                END IF;

                IF ( reg_asiendet.moneda = 'PEN' ) THEN
                    rasiendet2.tcambio01 := 1;
                    rasiendet2.tcambio02 := abs(reg_asiendet.total02 / reg_asiendet.total01);
                    rasiendet2.importe := abs(reg_asiendet.total01);
                ELSE
                    rasiendet2.tcambio01 := abs(reg_asiendet.total01 / reg_asiendet.total02);
                    rasiendet2.tcambio02 := 1;
                END IF;

                rasiendet2.impor01 := abs(reg_asiendet.total01);
                rasiendet2.impor02 := abs(reg_asiendet.total02);
                rasiendet2.debe := 0;
                rasiendet2.debe01 := 0;
                rasiendet2.debe02 := 0;
                rasiendet2.haber := 0;
                rasiendet2.haber01 := 0;
                rasiendet2.haber02 := 0;
                CASE
                    WHEN rasiendet2.dh = 'D' THEN
                        rasiendet2.debe := rasiendet2.importe;
                        rasiendet2.debe01 := rasiendet2.impor01;
                        rasiendet2.debe02 := rasiendet2.impor02;
                    WHEN rasiendet2.dh = 'H' THEN
                        rasiendet2.haber := rasiendet2.importe;
                        rasiendet2.haber01 := rasiendet2.impor01;
                        rasiendet2.haber02 := rasiendet2.impor02;
                END CASE;

                rasiendet2.ccosto := ' ';
                rasiendet2.proyec := ' ';
                rasiendet2.subcco := ' ';
                rasiendet2.ctaalternativa := ' ';
                rasiendet2.tipo := 0;
                rasiendet2.docume := 0;
                rasiendet2.codigo := ' ';
                rasiendet2.razon := '';
                rasiendet2.tident := ' ';
                rasiendet2.dident := ' ';
                rasiendet2.tdocum := ' ';
                rasiendet2.serie := ' ';
                rasiendet2.numero := '';
                rasiendet2.usuari := pin_coduser;
                rasiendet2.fcreac := sysdate;
                rasiendet2.factua := sysdate;
                rasiendet2.regcomcol := 0;
                rasiendet2.swprovicion := 'N';
                rasiendet2.saldo := 0;
                rasiendet2.swgasoper := 1;
                rasiendet2.codporret := '';
                rasiendet2.swchkconcilia := 'N';
                INSERT INTO asiendet (
                    id_cia,--01
                    periodo,--02
                    mes,--03
                    libro,--04
                    asiento,--05
                    item,--06
                    sitem,--07
                    concep,--08
                    fecha,--09
                    tasien,--10
                    topera,--11
                    cuenta,--12
                    dh,--13
                    moneda,--14
                    importe,--15
                    impor01,--16
                    impor02,--17
                    debe,--18
                    debe01,--19
                    debe02,--20
                    haber,--21
                    haber01,--22
                    haber02,--23
                    tcambio01,--24
                    tcambio02,--25
                    ccosto,--26
                    proyec,--27
                    subcco,--28
                    ctaalternativa,--29
                    tipo,--30
                    docume,--31
                    codigo,--32
                    razon,--33
                    tident,--34
                    dident,--35
                    tdocum,--36
                    serie,--37
                    numero,--38
                    fdocum,--39
                    usuari,--40
                    fcreac,--41
                    factua,--42
                    regcomcol,--43
                    swprovicion,--44
                    saldo,--45
                    swgasoper,--46
                    codporret,--47
                    swchkconcilia--48
                ) VALUES (
                    pin_id_cia,
                    rasiendet2.periodo,
                    rasiendet2.mes,
                    rasiendet2.libro,
                    rasiendet2.asiento,
                    rasiendet2.item,
                    rasiendet2.sitem,
                    rasiendet2.concep,
                    rasiendet2.fecha,
                    rasiendet2.tasien,
                    rasiendet2.topera,
                    rasiendet2.cuenta,
                    rasiendet2.dh,
                    rasiendet2.moneda,
                    rasiendet2.importe,
                    rasiendet2.impor01,
                    rasiendet2.impor02,
                    rasiendet2.debe,
                    rasiendet2.debe01,
                    rasiendet2.debe02,
                    rasiendet2.haber,
                    rasiendet2.haber01,
                    rasiendet2.haber02,
                    rasiendet2.tcambio01,
                    rasiendet2.tcambio02,
                    rasiendet2.ccosto,
                    rasiendet2.proyec,
                    rasiendet2.subcco,
                    rasiendet2.ctaalternativa,
                    rasiendet2.tipo,
                    rasiendet2.docume,
                    rasiendet2.codigo,
                    rasiendet2.razon,
                    rasiendet2.tident,
                    rasiendet2.dident,
                    rasiendet2.tdocum,
                    rasiendet2.serie,
                    rasiendet2.numero,
                    rasiendet2.fdocum,
                    rasiendet2.usuari,
                    rasiendet2.fcreac,
                    rasiendet2.factua,
                    rasiendet2.regcomcol,
                    rasiendet2.swprovicion,
                    rasiendet2.saldo,
                    rasiendet2.swgasoper,
                    rasiendet2.codporret,
                    rasiendet2.swchkconcilia
                );

                COMMIT;
            END IF;
        END LOOP;

    END IF;

END sp_adddifcambio_asiendet;

/
