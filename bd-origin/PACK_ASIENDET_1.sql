--------------------------------------------------------
--  DDL for Package Body PACK_ASIENDET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ASIENDET" AS

    PROCEDURE sp_save_asiendet (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o            json_object_t;
        rec_asiendet asiendet%rowtype;
        v_accion     VARCHAR2(50) := '';
    BEGIN
    -- TAREA: Se necesita implantación para PROCEDURE PACK_ASIENDET.sp_save_ASIENDET
        o := json_object_t.parse(pin_datos);
        rec_asiendet.id_cia := pin_id_cia;
        rec_asiendet.periodo := o.get_number('periodo');
        rec_asiendet.mes := o.get_number('mes');
        rec_asiendet.libro := o.get_string('libro');
        rec_asiendet.asiento := o.get_number('asiento');
        rec_asiendet.item := o.get_number('item');
        rec_asiendet.sitem := o.get_number('sitem');
        rec_asiendet.concep := o.get_string('concep');
        rec_asiendet.fecha := o.get_date('fecha');
        rec_asiendet.tasien := o.get_number('tasien');
        rec_asiendet.topera := o.get_string('topera');
        rec_asiendet.cuenta := o.get_string('cuenta');
        rec_asiendet.dh := o.get_string('dh');
        rec_asiendet.moneda := o.get_string('moneda');
        rec_asiendet.importe := o.get_number('importe');
        rec_asiendet.impor01 := o.get_number('impor01');
        rec_asiendet.impor02 := o.get_number('impor02');
        rec_asiendet.debe := o.get_number('debe');
        rec_asiendet.debe01 := o.get_number('debe01');
        rec_asiendet.debe02 := o.get_number('debe02');
        rec_asiendet.haber := o.get_number('haber');
        rec_asiendet.haber01 := o.get_number('haber01');
        rec_asiendet.haber02 := o.get_number('haber02');
        rec_asiendet.tcambio01 := o.get_number('tcambio01');
        rec_asiendet.tcambio02 := o.get_number('tcambio02');
        rec_asiendet.ccosto := o.get_string('ccosto');
        rec_asiendet.proyec := o.get_string('proyec');
        rec_asiendet.subcco := o.get_string('subcco');
        rec_asiendet.tipo := o.get_number('tipo');
        rec_asiendet.docume := o.get_number('docume');
        rec_asiendet.codigo := o.get_string('codigo');
        rec_asiendet.razon := o.get_string('razon');
        rec_asiendet.tident := o.get_string('tident');
        rec_asiendet.dident := o.get_string('dident');
        rec_asiendet.tdocum := o.get_string('tdocum');
        rec_asiendet.serie := o.get_string('serie');
        rec_asiendet.numero := o.get_string('numero');
        rec_asiendet.fdocum := o.get_date('fdocum');
        rec_asiendet.usuari := o.get_string('usuari');
        rec_asiendet.regcomcol := o.get_number('regcomcol');
        rec_asiendet.swprovicion := o.get_string('swprovicion');
        rec_asiendet.saldo := o.get_number('saldo');
        rec_asiendet.swgasoper := o.get_number('swgasoper');
        rec_asiendet.codporret := o.get_string('codporret');
        rec_asiendet.swchkconcilia := o.get_string('swchkconcilia');
        rec_asiendet.ctaalternativa := o.get_string('ctaalternativa');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO asiendet (
                    id_cia,
                    periodo,
                    mes,
                    libro,
                    asiento,
                    item,
                    sitem,
                    concep,
                    fecha,
                    tasien,
                    topera,
                    cuenta,
                    dh,
                    moneda,
                    importe,
                    impor01,
                    impor02,
                    debe,
                    debe01,
                    debe02,
                    haber,
                    haber01,
                    haber02,
                    tcambio01,
                    tcambio02,
                    ccosto,
                    proyec,
                    subcco,
                    tipo,
                    docume,
                    codigo,
                    razon,
                    tident,
                    dident,
                    tdocum,
                    serie,
                    numero,
                    fdocum,
                    usuari,
                    fcreac,
                    factua,
                    regcomcol,
                    swprovicion,
                    saldo,
                    swgasoper,
                    codporret,
                    swchkconcilia,
                    ctaalternativa
                ) VALUES (
                    rec_asiendet.id_cia,
                    rec_asiendet.periodo,
                    rec_asiendet.mes,
                    rec_asiendet.libro,
                    rec_asiendet.asiento,
                    rec_asiendet.item,
                    rec_asiendet.sitem,
                    rec_asiendet.concep,
                    rec_asiendet.fecha,
                    rec_asiendet.tasien,
                    rec_asiendet.topera,
                    rec_asiendet.cuenta,
                    rec_asiendet.dh,
                    rec_asiendet.moneda,
                    rec_asiendet.importe,
                    rec_asiendet.impor01,
                    rec_asiendet.impor02,
                    rec_asiendet.debe,
                    rec_asiendet.debe01,
                    rec_asiendet.debe02,
                    rec_asiendet.haber,
                    rec_asiendet.haber01,
                    rec_asiendet.haber02,
                    rec_asiendet.tcambio01,
                    rec_asiendet.tcambio02,
                    rec_asiendet.ccosto,
                    rec_asiendet.proyec,
                    rec_asiendet.subcco,
                    rec_asiendet.tipo,
                    rec_asiendet.docume,
                    rec_asiendet.codigo,
                    rec_asiendet.razon,
                    rec_asiendet.tident,
                    rec_asiendet.dident,
                    rec_asiendet.tdocum,
                    rec_asiendet.serie,
                    rec_asiendet.numero,
                    rec_asiendet.fdocum,
                    rec_asiendet.usuari,
                    current_timestamp,
                    current_timestamp,
                    rec_asiendet.regcomcol,
                    rec_asiendet.swprovicion,
                    rec_asiendet.saldo,
                    rec_asiendet.swgasoper,
                    rec_asiendet.codporret,
                    rec_asiendet.swchkconcilia,
                    rec_asiendet.ctaalternativa
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE asiendet
                SET
                    concep = rec_asiendet.concep,
                    fecha = rec_asiendet.fecha,
                    tasien = rec_asiendet.tasien,
                    topera = rec_asiendet.topera,
                    cuenta = rec_asiendet.cuenta,
                    dh = rec_asiendet.dh,
                    moneda = rec_asiendet.moneda,
                    importe = rec_asiendet.importe,
                    impor01 = rec_asiendet.impor01,
                    impor02 = rec_asiendet.impor02,
                    debe = rec_asiendet.debe,
                    debe01 = rec_asiendet.debe01,
                    debe02 = rec_asiendet.debe02,
                    haber = rec_asiendet.haber,
                    haber01 = rec_asiendet.haber01,
                    haber02 = rec_asiendet.haber02,
                    tcambio01 = rec_asiendet.tcambio01,
                    tcambio02 = rec_asiendet.tcambio02,
                    ccosto = rec_asiendet.ccosto,
                    proyec = rec_asiendet.proyec,
                    subcco = rec_asiendet.subcco,
                    tipo = rec_asiendet.tipo,
                    docume = rec_asiendet.docume,
                    codigo = rec_asiendet.codigo,
                    razon = rec_asiendet.razon,
                    tident = rec_asiendet.tident,
                    dident = rec_asiendet.dident,
                    tdocum = rec_asiendet.tdocum,
                    serie = rec_asiendet.serie,
                    numero = rec_asiendet.numero,
                    fdocum = rec_asiendet.fdocum,
                    usuari = rec_asiendet.usuari,
                    factua = current_timestamp,
                    regcomcol = rec_asiendet.regcomcol,
                    swprovicion = rec_asiendet.swprovicion,
                    saldo = rec_asiendet.saldo,
                    swgasoper = rec_asiendet.swgasoper,
                    codporret = rec_asiendet.codporret,
                    swchkconcilia = rec_asiendet.swchkconcilia,
                    ctaalternativa = rec_asiendet.ctaalternativa
                WHERE
                        id_cia = rec_asiendet.id_cia
                    AND periodo = rec_asiendet.periodo
                    AND mes = rec_asiendet.mes
                    AND libro = rec_asiendet.libro
                    AND asiento = rec_asiendet.asiento
                    AND item = rec_asiendet.item
                    AND sitem = rec_asiendet.sitem;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM asiendet
                WHERE
                        id_cia = rec_asiendet.id_cia
                    AND periodo = rec_asiendet.periodo
                    AND mes = rec_asiendet.mes
                    AND libro = rec_asiendet.libro
                    AND asiento = rec_asiendet.asiento
                    AND item = rec_asiendet.item
                    AND sitem = rec_asiendet.sitem;

                COMMIT;
            ELSE
                NULL;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    END sp_save_asiendet;

    FUNCTION genera_asiento_apertura (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER
    ) RETURN tbl_asiento_apertura
        PIPELINED
    AS

        rec          rec_asiento_apertura := rec_asiento_apertura(NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL);
        v_item       NUMBER := 1;
        v_dh         VARCHAR2(1) := 'D';
        v_tipcam     NUMBER;
        v_importesol NUMBER;
        v_importedol NUMBER;
        v_tipcam_com NUMBER;
        v_tipcam_ven NUMBER;
        v_fechaini   DATE;
    BEGIN
        v_fechaini := TO_DATE ( '01/01/'
                                || ( pin_periodo + 1 ), 'DD/MM/YYYY' );
        SELECT
            compra,
            venta
        INTO
            v_tipcam_com,
            v_tipcam_ven
        FROM
            tcambio
        WHERE
                id_cia = pin_id_cia
            AND moneda = 'USD'
            AND fecha = v_fechaini;


  -- SaldosPorCuentas

        FOR i IN (
            SELECT
                m.cuenta,
                ( (
                    CASE
                        WHEN pc8.codigo IS NULL THEN
                            '0'
                        ELSE
                            pc8.codigo
                    END
                ) )                                            AS tipodiario,
                p.nombre,
                p.moneda01                                     AS moneda,
                p.codtana,
                SUM(nvl(m.debe01, 0)) - SUM(nvl(m.haber01, 0)) AS saldo01,
                SUM(nvl(m.debe02, 0)) - SUM(nvl(m.haber02, 0)) AS saldo02,
                11                                             AS obs
            FROM
                     movimientos m
                INNER JOIN pcuentas       p ON ( p.id_cia = m.id_cia
                                           AND p.cuenta = m.cuenta )
                                         AND ( ( p.codtana IS NULL )
                                               OR ( p.codtana <= 0 ) )
                LEFT OUTER JOIN pcuentas_clase pc8 ON ( pc8.id_cia = p.id_cia
                                                        AND pc8.cuenta = p.cuenta )
                                                      AND ( pc8.clase = 8 ) -- Clasificación de Cuentas (Si es Activo)
            WHERE
                    m.id_cia = pin_id_cia
                AND ( m.periodo = pin_periodo ) -- Lee Movimientos del PERIODO ANTERIOR
                AND ( CAST(substr(m.cuenta, 1, 2) AS INTEGER) >= 0 )
                AND ( CAST(substr(m.cuenta, 1, 2) AS INTEGER) <= 59 )
            GROUP BY
                m.cuenta,
                pc8.codigo,
                p.nombre,
                p.moneda01,
                p.codtana
            HAVING
                ( SUM(nvl(m.debe01, 0)) - SUM(nvl(m.haber01, 0)) ) <> 0
            ORDER BY
                m.cuenta
        ) LOOP
            rec.importe := 0;
            rec.debe := 0;
            rec.debe01 := 0;
            rec.debe02 := 0;
            rec.haber := 0;
            rec.haber01 := 0;
            rec.haber02 := 0;
            v_importesol := abs(i.saldo01);
            v_importedol := abs(i.saldo02);
            v_dh := 'D';
            IF
                i.saldo01 IS NOT NULL
                AND i.saldo01 < 0
            THEN
                v_dh := 'H';
            END IF;

            IF /*i.tipodiario IS NOT NULL AND*/ i.tipodiario = '1' THEN
                v_tipcam := v_tipcam_com;
            ELSE
                v_tipcam := v_tipcam_ven;
            END IF;

            rec.item := v_item;
            rec.sitem := 0;
            rec.concep := 'Asiento de Apertura';
            rec.tasien := NULL;
            rec.topera := '0';
            rec.cuenta := i.cuenta;
            rec.dh := v_dh;
            rec.fecha := v_fechaini;
            rec.moneda := i.moneda;
            IF rec.moneda = 'PEN' THEN
                rec.importe := v_importesol;
            ELSE
                rec.importe := v_importedol;
            END IF;

            rec.impor01 := v_importesol;
            rec.impor02 := v_importedol;
            IF rec.dh = 'D' THEN
                rec.debe := rec.importe;
                rec.debe01 := rec.impor01;
                rec.debe02 := rec.impor02;
            END IF;

            IF rec.dh = 'H' THEN
                rec.haber := rec.importe;
                rec.haber01 := rec.impor01;
                rec.haber02 := rec.impor02;
            END IF;

            IF rec.moneda = 'PEN' THEN
                rec.tcambio01 := 1;
                rec.tcambio02 := 1 / v_tipcam;
            ELSE
                IF v_importedol <> 0 THEN
                    rec.tcambio01 := v_importesol / v_importedol;
                ELSE
                    rec.tcambio01 := v_tipcam;
                END IF;

                rec.tcambio02 := 1;
            END IF;

            rec.ccosto := '';
            rec.proyec := NULL;
            rec.subcco := '';
            rec.subccosto := '';
            rec.tipo := NULL;
            rec.docume := -1;
            rec.codigo := NULL;
            rec.razon := NULL;
            rec.tident := NULL;
            rec.dident := NULL;
            rec.tdocum := NULL;
            rec.serie := NULL;
            rec.numero := NULL;
            rec.fdocum := NULL;
            rec.usuari := NULL;
            rec.fcreac := NULL;
            rec.factua := NULL;
            rec.regcomcol := 0;
            rec.swprovicion := 'N';
            rec.saldo := rec.importe;
            rec.swgasoper := NULL;
            rec.codporret := NULL;
            rec.swchkconcilia := NULL;
            rec.ctaalternativa := NULL;
            PIPE ROW ( rec );
            v_item := ( v_item + 1 );
        END LOOP;




 -- SaldosDocumento

        FOR j IN (
            SELECT
                m.cuenta,
                ( (
                    CASE
                        WHEN pc8.codigo IS NULL THEN
                            '0'
                        ELSE
                            pc8.codigo
                    END
                ) )                                            AS tipodiario,
                p.nombre,
                p.moneda01                                     AS moneda,
                p.codtana,
                m.codigo,
                cl.razonc,
                m.tdocum,
                m.serie,
                m.numero,
                MIN(nvl(m.fdocum, m.fecha))                    AS fecdoc,
                SUM(nvl(m.debe01, 0)) - SUM(nvl(m.haber01, 0)) AS saldo01,
                SUM(nvl(m.debe02, 0)) - SUM(nvl(m.haber02, 0)) AS saldo02,
                22                                             AS obs
            FROM
                     movimientos m
                INNER JOIN pcuentas       p ON ( p.id_cia = m.id_cia
                                           AND p.cuenta = m.cuenta )
                                         AND ( /*( NOT ( p.codtana IS NULL ) )
                                               AND */ ( p.codtana > 0 ) )
                LEFT OUTER JOIN cliente        cl ON ( cl.id_cia = m.id_cia
                                                AND cl.codcli = m.codigo )
                LEFT OUTER JOIN pcuentas_clase pc8 ON ( pc8.id_cia = p.id_cia
                                                        AND pc8.cuenta = p.cuenta )
                                                      AND ( pc8.clase = 8 )
            WHERE
                    m.id_cia = pin_id_cia
                AND ( m.periodo = pin_periodo ) -- Lee Movimientos del PERIODO ANTERIOR
                AND ( CAST(substr(m.cuenta, 1, 2) AS INTEGER) >= 0 )
                AND ( CAST(substr(m.cuenta, 1, 2) AS INTEGER) <= 59 )
            GROUP BY
                m.cuenta,
                pc8.codigo,
                p.nombre,
                p.moneda01,
                p.codtana,
                m.codigo,
                cl.razonc,
                m.tdocum,
                m.serie,
                m.numero
            HAVING
                ( SUM(nvl(m.debe01, 0)) - SUM(nvl(m.haber01, 0)) ) <> 0
            ORDER BY
                m.cuenta,
                m.codigo,
                m.tdocum,
                m.serie,
                m.numero
        ) LOOP
            rec.importe := 0;
            rec.debe := 0;
            rec.debe01 := 0;
            rec.debe02 := 0;
            rec.haber := 0;
            rec.haber01 := 0;
            rec.haber02 := 0;
            v_importesol := abs(j.saldo01);
            v_importedol := abs(j.saldo02);
            v_dh := 'D';
            IF
                j.saldo01 IS NOT NULL
                AND j.saldo01 < 0
            THEN
                v_dh := 'H';
            END IF;

            IF /*j.tipodiario IS NOT NULL AND*/ j.tipodiario = '1' THEN
                v_tipcam := v_tipcam_com;
            ELSE
                v_tipcam := v_tipcam_ven;
            END IF;

            rec.item := v_item;
            rec.sitem := 0;
            rec.concep := 'Asiento de Apertura';
            rec.tasien := NULL;
            rec.topera := '0';
            rec.cuenta := j.cuenta;
            rec.dh := v_dh;
            rec.moneda := j.moneda;
            IF rec.moneda = 'PEN' THEN
                rec.importe := v_importesol;
            ELSE
                rec.importe := v_importedol;
            END IF;

            rec.impor01 := v_importesol;
            rec.impor02 := v_importedol;
            IF rec.dh = 'D' THEN
                rec.debe := rec.importe;
                rec.debe01 := rec.impor01;
                rec.debe02 := rec.impor02;
            END IF;

            IF rec.dh = 'H' THEN
                rec.haber := rec.importe;
                rec.haber01 := rec.impor01;
                rec.haber02 := rec.impor02;
            END IF;

            IF rec.moneda = 'PEN' THEN
                rec.tcambio01 := 1;
                rec.tcambio02 := 1 / v_tipcam;
            ELSE
                IF v_importedol <> 0 THEN
                    rec.tcambio01 := v_importesol / v_importedol;
                ELSE
                    rec.tcambio01 := v_tipcam;
                END IF;

                rec.tcambio02 := 1;
            END IF;

            rec.ccosto := '';
            rec.proyec := NULL;
            rec.subcco := '';
            rec.subccosto := '';
            rec.tipo := NULL;
            rec.docume := -1;
            IF
                j.codtana IS NOT NULL
                AND j.codtana > 0
            THEN
                rec.codigo := j.codigo;
                rec.razon := j.razonc;
                rec.tdocum := j.tdocum;
                rec.serie := j.serie;
                rec.numero := j.numero;
                rec.fdocum := NULL;
            END IF;

            rec.usuari := NULL;
            rec.fcreac := NULL;
            rec.factua := NULL;
            rec.regcomcol := NULL;
            rec.swprovicion := 'N';
            rec.saldo := rec.importe;
            rec.swgasoper := NULL;
            rec.codporret := NULL;
            rec.swchkconcilia := NULL;
            rec.ctaalternativa := NULL;
            PIPE ROW ( rec );
            v_item := ( v_item + 1 );
        END LOOP;

    END genera_asiento_apertura;

    FUNCTION genera_asiento_apertura_con_ajuste_final (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER
    ) RETURN tbl_asiento_apertura
        PIPELINED
    AS

        rec          rec_asiento_apertura := rec_asiento_apertura(NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL);
        v_cuenta     VARCHAR2(60);
        v_moneda01   VARCHAR(3);
        v_item       NUMBER := 1;
        v_dh         VARCHAR2(1) := 'D';
        v_importesol NUMBER;
        v_importedol NUMBER;
        v_tipcam     NUMBER;
        v_tipcam_com NUMBER;
        v_tipcam_ven NUMBER;
        v_fechaini   DATE;
    BEGIN
        v_fechaini := TO_DATE ( '01/01/'
                                || ( pin_periodo + 1 ), 'DD/MM/YYYY' );
        SELECT
            compra,
            venta
        INTO
            v_tipcam_com,
            v_tipcam_ven
        FROM
            tcambio
        WHERE
                id_cia = pin_id_cia
            AND moneda = 'USD'
            AND fecha = v_fechaini;

        SELECT
            cuenta
        INTO v_cuenta
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 225;
            -- Factor (225) = Cuenta Default Para Asiento de Apertura

        SELECT
            moneda01
        INTO v_moneda01
        FROM
            companias
        WHERE
            cia = pin_id_cia;

        FOR i IN (
            SELECT
                id_cia,
                periodo,
                mes,
                libro,
                asiento,
                item,
                sitem,
                concep,
                fecha,
                tasien,
                topera,
                cuenta,
                dh,
                moneda,
                abs(importe) AS importe,
                abs(impor01) AS impor01,
                abs(impor02) AS impor02,
                debe,
                debe01,
                debe02,
                haber,
                abs(haber01) AS haber01,
                abs(haber02) AS haber02,
                tcambio01,
                tcambio02,
                ccosto,
                proyec,
                subcco,
                subccosto,
                tipo,
                docume,
                codigo,
                razon,
                tident,
                dident,
                tdocum,
                serie,
                numero,
                fdocum,
                usuari,
                fcreac,
                factua,
                regcomcol,
                swprovicion,
                saldo,
                swgasoper,
                codporret,
                swchkconcilia,
                ctaalternativa
            FROM
                pack_asiendet.genera_asiento_apertura(pin_id_cia, pin_periodo)
        ) LOOP
            rec.id_cia := i.id_cia;
            rec.periodo := i.periodo;
            rec.mes := i.mes;
            rec.libro := i.libro;
            rec.asiento := i.asiento;
            rec.item := v_item;
            rec.sitem := i.sitem;
            rec.concep := i.concep;
            rec.fecha := i.fecha;
            rec.tasien := i.tasien;
            rec.topera := i.topera;
            rec.cuenta := i.cuenta;
            rec.dh := i.dh;
            rec.moneda := i.moneda;
            rec.importe := i.importe;
            rec.impor01 := i.impor01;
            rec.impor02 := i.impor02;
            rec.debe := i.debe;
            rec.debe01 := i.debe01;
            rec.debe02 := i.debe02;
            rec.haber := i.haber;
            rec.haber01 := i.haber01;
            rec.haber02 := i.haber02;
            rec.tcambio01 := i.tcambio01;
            rec.tcambio02 := i.tcambio02;
            rec.ccosto := i.ccosto;
            rec.proyec := i.proyec;
            rec.subcco := i.subcco;
            rec.subccosto := i.subccosto;
            rec.tipo := i.tipo;
            rec.docume := i.docume;
            rec.codigo := i.codigo;
            rec.razon := i.razon;
            rec.tident := i.tident;
            rec.dident := i.dident;
            rec.tdocum := i.tdocum;
            rec.serie := i.serie;
            rec.numero := i.numero;
            rec.fdocum := i.fdocum;
            rec.usuari := i.usuari;
            rec.fcreac := i.fcreac;
            rec.factua := i.factua;
            rec.regcomcol := i.regcomcol;
            rec.swprovicion := i.swprovicion;
            rec.saldo := i.saldo;
            rec.swgasoper := i.swgasoper;
            rec.codporret := i.codporret;
            rec.swchkconcilia := i.swchkconcilia;
            rec.ctaalternativa := i.ctaalternativa;
            PIPE ROW ( rec );
            v_item := ( v_item + 1 );
        END LOOP;

        FOR j IN (
            SELECT
                - 1                        AS codtana,
                0                          AS tipodiario,
                SUM(haber) - SUM(debe)     AS saldo,
                SUM(haber01) - SUM(debe01) AS saldo01,
                SUM(haber02) - SUM(debe02) AS saldo02
            FROM
                pack_asiendet.genera_asiento_apertura(pin_id_cia, pin_periodo)
        ) LOOP
            rec.importe := 0;
            rec.debe := 0;
            rec.debe01 := 0;
            rec.debe02 := 0;
            rec.haber := 0;
            rec.haber01 := 0;
            rec.haber02 := 0;
            v_importesol := abs(j.saldo01);
            v_importedol := abs(j.saldo02);
            v_dh := 'D';
            IF
                j.saldo01 IS NOT NULL
                AND j.saldo01 < 0
            THEN
                v_dh := 'H';
            END IF;

            IF
                j.tipodiario IS NOT NULL
                AND j.tipodiario = '1'
            THEN
                v_tipcam := v_tipcam_com;
            ELSE
                v_tipcam := v_tipcam_ven;
            END IF;

            rec.item := v_item;
            rec.sitem := 0;
            rec.concep := 'Asiento de Apertura';
            rec.tasien := NULL;
            rec.topera := '0';
            rec.cuenta := v_cuenta;
            rec.dh := v_dh;
            rec.fecha := v_fechaini;
            rec.moneda := v_moneda01;
            IF rec.moneda = 'PEN' THEN
                rec.importe := v_importesol;
            ELSE
                rec.importe := v_importedol;
            END IF;

            rec.impor01 := v_importesol;
            rec.impor02 := v_importedol;
            IF rec.dh = 'D' THEN
                rec.debe := rec.importe;
                rec.debe01 := rec.impor01;
                rec.debe02 := rec.impor02;
            END IF;

            IF rec.dh = 'H' THEN
                rec.haber := rec.importe;
                rec.haber01 := rec.impor01;
                rec.haber02 := rec.impor02;
            END IF;

            IF rec.moneda = 'PEN' THEN
                rec.tcambio01 := 1;
                rec.tcambio02 := 1 / v_tipcam;
            ELSE
                IF v_importedol <> 0 THEN
                    rec.tcambio01 := v_importesol / v_importedol;
                ELSE
                    rec.tcambio01 := v_tipcam;
                END IF;

                rec.tcambio02 := 1;
            END IF;

            rec.ccosto := '';
            rec.proyec := NULL;
            rec.subcco := '';
            rec.subccosto := '';
            rec.tipo := NULL;
            rec.docume := -1;
            rec.usuari := NULL;
            rec.fcreac := NULL;
            rec.factua := NULL;
            rec.regcomcol := NULL;
            rec.swprovicion := 'N';
            rec.saldo := rec.importe;
            rec.swgasoper := NULL;
            rec.codporret := NULL;
            rec.swchkconcilia := NULL;
            rec.ctaalternativa := NULL;
            PIPE ROW ( rec );
            v_item := ( v_item + 1 );
        END LOOP;

    END genera_asiento_apertura_con_ajuste_final;

END pack_asiendet;

/
