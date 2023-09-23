--------------------------------------------------------
--  DDL for Package Body PACK_PCUENTAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_PCUENTAS" AS

    FUNCTION sp_sel_pcuentas (
        pin_id_cia IN NUMBER
    ) RETURN t_pcuentas
        PIPELINED
    IS
        v_table t_pcuentas;
    BEGIN
        SELECT
            p.id_cia,
            p.cuenta,
            p.nombre,
            p.tipgas,
            p.cpadre,
            p.nivel,
            p.imputa,
            p.codtana,
            p.destino,
            p.destid,
            p.destih,
            p.dh,
            p.moneda01,
            p.moneda02,
            p.ccosto AS "Centro_Costo",
            p.proyec,
            p.docori,
            p.tipo,
            p.refere,
            p.fhabdes,
            p.fhabhas,
            p.balance,
            p.regcomcol,
            p.regvencol,
            p.clasif,
            p.situac,
            p.usuari,
            p.fcreac,
            p.factua,
            p.balancecol,
            p.habilitado,
            p.concilia
        BULK COLLECT
        INTO v_table
        FROM
            pcuentas p
        WHERE
            p.id_cia = pin_id_cia;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_sel_pcuentas;

    PROCEDURE sp_save_pcuentas (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o            json_object_t;
        rec_pcuentas pcuentas%rowtype;
        v_accion     VARCHAR2(50) := '';
    BEGIN
--SET SERVEROUTPUT ON;
--
--DECLARE
--    cadjson  VARCHAR2(4000);
--    mensaje  VARCHAR(150);
--BEGIN
--    cadjson := '{"cuenta":"999999",
--    "nombre":"nombre de la cuenta",
--    "tipgas":4,
--    "cpadre":"9999",
--    "nivel":3,
--    "imputa":"S",
--    "codtana":1,
--    "destino":"S",
--    "destid":"262131",
--    "destih":"262131",
--    "dh":"H",
--    "moneda01":"PEN",
--    "moneda02":"PEN",
--    "ccosto":"S",
--    "proyec":"S",
--    "docori":0,
--    "tipo":"",
--    "refere":"REFERENCIA",
--    "fhabdes":"2021-04-25",
--    "fhabhas":"2021-04-25",
--    "balance":"S",
--    "regcomcol":0,
--    "regvencol":0,
--    "clasif":0,
--    "situac":"A",
--    "usuari":"RAOJ",
--    "balancecol":"S",
--    "habilitado":"N",
--    "concilia":"N"
--}';
--    pack_pcuentas.sp_save_pcuentas(13, cadjson, 3, mensaje);
--    dbms_output.put_line(mensaje);
--END;
        o := json_object_t.parse(pin_datos);
        rec_pcuentas.id_cia := pin_id_cia;
        rec_pcuentas.cuenta := o.get_string('cuenta');
        rec_pcuentas.nombre := o.get_string('nombre');
        rec_pcuentas.tipgas := o.get_number('tipgas');
        rec_pcuentas.cpadre := o.get_string('cpadre');
        rec_pcuentas.nivel := o.get_number('nivel');
        rec_pcuentas.imputa := o.get_string('imputa');
        rec_pcuentas.codtana := o.get_number('codtana');
        rec_pcuentas.destino := o.get_string('destino');
        rec_pcuentas.destid := o.get_string('destid');
        rec_pcuentas.destih := o.get_string('destih');
        rec_pcuentas.dh := o.get_string('dh');
        rec_pcuentas.moneda01 := o.get_string('moneda01');
        rec_pcuentas.moneda02 := o.get_string('moneda02');
        rec_pcuentas.ccosto := o.get_string('ccosto');
        rec_pcuentas.proyec := o.get_string('proyec');
        rec_pcuentas.docori := o.get_number('docori');
        rec_pcuentas.tipo := o.get_string('tipo');
        rec_pcuentas.refere := o.get_string('refere');
        rec_pcuentas.fhabdes := o.get_date('fhabdes');
        rec_pcuentas.fhabhas := o.get_date('fhabhas');
        rec_pcuentas.balance := o.get_string('balance');
        rec_pcuentas.regcomcol := o.get_number('regcomcol');
        rec_pcuentas.regvencol := o.get_number('regvencol');
        rec_pcuentas.clasif := o.get_number('clasif');
        rec_pcuentas.situac := o.get_string('situac');
        rec_pcuentas.usuari := o.get_string('usuari');
        rec_pcuentas.balancecol := o.get_string('balancecol');
        rec_pcuentas.habilitado := o.get_string('habilitado');
        rec_pcuentas.concilia := o.get_string('concilia');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO pcuentas (
                    id_cia,
                    cuenta,
                    nombre,
                    tipgas,
                    cpadre,
                    nivel,
                    imputa,
                    codtana,
                    destino,
                    destid,
                    destih,
                    dh,
                    moneda01,
                    moneda02,
                    ccosto,
                    proyec,
                    docori,
                    tipo,
                    refere,
                    fhabdes,
                    fhabhas,
                    balance,
                    regcomcol,
                    regvencol,
                    clasif,
                    situac,
                    usuari,
                    balancecol,
                    habilitado,
                    concilia
                ) VALUES (
                    rec_pcuentas.id_cia,
                    rec_pcuentas.cuenta,
                    rec_pcuentas.nombre,
                    rec_pcuentas.tipgas,
                    rec_pcuentas.cpadre,
                    rec_pcuentas.nivel,
                    rec_pcuentas.imputa,
                    rec_pcuentas.codtana,
                    rec_pcuentas.destino,
                    rec_pcuentas.destid,
                    rec_pcuentas.destih,
                    rec_pcuentas.dh,
                    rec_pcuentas.moneda01,
                    rec_pcuentas.moneda02,
                    rec_pcuentas.ccosto,
                    rec_pcuentas.proyec,
                    rec_pcuentas.docori,
                    rec_pcuentas.tipo,
                    rec_pcuentas.refere,
                    rec_pcuentas.fhabdes,
                    rec_pcuentas.fhabhas,
                    rec_pcuentas.balance,
                    rec_pcuentas.regcomcol,
                    rec_pcuentas.regvencol,
                    rec_pcuentas.clasif,
                    rec_pcuentas.situac,
                    rec_pcuentas.usuari,
                    rec_pcuentas.balancecol,
                    rec_pcuentas.habilitado,
                    rec_pcuentas.concilia
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE pcuentas
                SET
                    nombre = rec_pcuentas.nombre,
                    tipgas = rec_pcuentas.tipgas,
                    cpadre = rec_pcuentas.cpadre,
                    nivel = rec_pcuentas.nivel,
                    imputa = rec_pcuentas.imputa,
                    codtana = rec_pcuentas.codtana,
                    destino = rec_pcuentas.destino,
                    destid = rec_pcuentas.destid,
                    destih = rec_pcuentas.destih,
                    dh = rec_pcuentas.dh,
                    moneda01 = rec_pcuentas.moneda01,
                    moneda02 = rec_pcuentas.moneda02,
                    ccosto = rec_pcuentas.ccosto,
                    proyec = rec_pcuentas.proyec,
                    docori = rec_pcuentas.docori,
                    tipo = rec_pcuentas.tipo,
                    refere = rec_pcuentas.refere,
                    fhabdes = rec_pcuentas.fhabdes,
                    fhabhas = rec_pcuentas.fhabhas,
                    balance = rec_pcuentas.balance,
                    regcomcol = rec_pcuentas.regcomcol,
                    regvencol = rec_pcuentas.regvencol,
                    clasif = rec_pcuentas.clasif,
                    situac = rec_pcuentas.situac,
                    usuari = rec_pcuentas.usuari,
                    balancecol = rec_pcuentas.balancecol,
                    habilitado = rec_pcuentas.habilitado,
                    concilia = rec_pcuentas.concilia
                WHERE
                        id_cia = rec_pcuentas.id_cia
                    AND cuenta = rec_pcuentas.cuenta;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM pcuentas
                WHERE
                        id_cia = rec_pcuentas.id_cia
                    AND cuenta = rec_pcuentas.cuenta;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;

    FUNCTION sp_sel_pcuentas_ccosto (
        pin_id_cia IN NUMBER,
        pin_cuenta IN VARCHAR2
    ) RETURN t_pcuentas_ccosto
        PIPELINED
    IS
        v_table t_pcuentas_ccosto;
    BEGIN
        SELECT
            pc.id_cia,
            pc.cuenta,
            pc.ccosto,
            p.nombre AS "desccosto",
            pc.porcen
        BULK COLLECT
        INTO v_table
        FROM
            pcuentas_ccosto pc
            LEFT OUTER JOIN pcuentas        p ON pc.id_cia = pin_id_cia
                                          AND p.cuenta = pc.ccosto
        WHERE
            p.id_cia = pin_id_cia;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_sel_pcuentas_ccosto;

    PROCEDURE sp_save_pcuentas_ccosto (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                   json_object_t;
        rec_pcuentas_ccosto pcuentas_ccosto%rowtype;
        v_accion            VARCHAR2(50) := '';
    BEGIN
--SET SERVEROUTPUT ON;
--
--DECLARE
--    cadjson  VARCHAR2(4000);
--    mensaje  VARCHAR(150);
--BEGIN
--    cadjson := '{"cuenta":"999999",
--    "ccosto":"101503",
--    "porcen":100,
--    "cpadre":"9999",
--    "nivel":3
--}';
--    pack_pcuentas.sp_save_pcuentas_ccosto(13, cadjson, 3, mensaje);
--    dbms_output.put_line(mensaje);
--END;
        o := json_object_t.parse(pin_datos);
        rec_pcuentas_ccosto.id_cia := pin_id_cia;
        rec_pcuentas_ccosto.cuenta := o.get_string('cuenta');
        rec_pcuentas_ccosto.ccosto := o.get_string('ccosto');
        rec_pcuentas_ccosto.porcen := o.get_number('porcen');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO pcuentas_ccosto (
                    id_cia,
                    cuenta,
                    ccosto,
                    porcen
                ) VALUES (
                    rec_pcuentas_ccosto.id_cia,
                    rec_pcuentas_ccosto.cuenta,
                    rec_pcuentas_ccosto.ccosto,
                    rec_pcuentas_ccosto.porcen
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE pcuentas_ccosto
                SET
                    porcen = rec_pcuentas_ccosto.porcen
                WHERE
                        id_cia = rec_pcuentas_ccosto.id_cia
                    AND cuenta = rec_pcuentas_ccosto.cuenta
                    AND ccosto = rec_pcuentas_ccosto.ccosto;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM pcuentas_ccosto
                WHERE
                        id_cia = rec_pcuentas_ccosto.id_cia
                    AND cuenta = rec_pcuentas_ccosto.cuenta
                    AND ccosto = rec_pcuentas_ccosto.ccosto;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;

    PROCEDURE sp_cuenta_no_existe (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_libro   IN VARCHAR2,
        pin_asiento IN NUMBER,
        pin_cuenta  IN OUT VARCHAR2
    ) AS

        v_mensaje      VARCHAR2(4000) := '';
        v_mensajefinal VARCHAR2(100) := '';
        v_serie        VARCHAR2(20 CHAR) := '';
        v_numero       VARCHAR2(20 CHAR) := '';
    BEGIN
        FOR i IN (
            SELECT
                d.cuenta,
                d.serie,
                d.numero
            FROM
                asiendet d
                LEFT OUTER JOIN asienhea c ON c.id_cia = d.id_cia
                                              AND c.libro = d.libro
                                              AND c.periodo = d.periodo
                                              AND c.mes = d.mes
                                              AND c.asiento = d.asiento
            WHERE
                    d.id_cia = pin_id_cia
                AND d.periodo = pin_periodo
                AND d.mes = pin_mes
                AND d.libro = pin_libro
                AND d.asiento = pin_asiento
                AND NOT EXISTS (
                    SELECT
                        *
                    FROM
                        pcuentas p
                    WHERE
                            p.id_cia = pin_id_cia
                        AND p.cuenta = d.cuenta
                )
        ) LOOP
            v_mensaje := v_mensaje
                         || ' - '
                         || nvl(i.cuenta, 'ND');
            v_serie := i.serie;
            v_numero := i.numero;
        END LOOP;

        v_mensajefinal := substr(v_mensaje, 3, 40)
                          || '['
                          || v_serie
                          || '-'
                          || v_numero
                          || ']';

        pin_cuenta := v_mensajefinal;
    EXCEPTION
        WHEN OTHERS THEN
            pin_cuenta := '';
    END sp_cuenta_no_existe;

END;

/
