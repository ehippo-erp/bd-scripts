--------------------------------------------------------
--  DDL for Procedure SP_CONTABILIZAR_ASIENTO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_CONTABILIZAR_ASIENTO" (
    pin_id_cia    IN NUMBER,
    pin_libro     IN VARCHAR2,
    pin_periodo   IN NUMBER,
    pin_mes       IN NUMBER,
    pin_secuencia IN NUMBER,
    pin_usuario   IN VARCHAR2,
    pin_mensaje   OUT VARCHAR2
) AS

    CURSOR cur_asiendet IS
    SELECT
        det.id_cia,
        det.periodo,
        det.mes,
        det.libro,
        det.asiento,
        det.item,
        det.sitem,
        det.concep,
        det.fecha,
        det.tasien,
        det.topera,
        det.cuenta,
        det.dh,
        det.moneda,
        det.importe,
        det.impor01,
        det.impor02,
        det.debe,
        det.debe01,
        det.debe02,
        det.haber,
        det.haber01,
        det.haber02,
        det.tcambio01,
        det.tcambio02,
        det.ccosto,
        det.proyec,
        det.subcco,
        det.tipo,
        det.docume,
        det.codigo,
        det.razon,
        det.tident,
        det.dident,
        det.tdocum,
        det.serie,
        det.numero,
        det.fdocum,
        det.usuari,
        det.fcreac,
        det.factua,
        det.regcomcol,
        det.swprovicion,
        det.saldo,
        det.swgasoper,
        det.codporret,
        det.swchkconcilia,
        det.ctaalternativa,
 --       TRIM(cco.codigo)         AS codigo,
        TRIM(cco.destin)   AS destincco,
 --       TRIM(pcta.cuenta)        AS cuenta,
        TRIM(pcta.ccosto)  AS swccosto,
        TRIM(pcta.destino) AS swdestino,
        TRIM(pcta.destid)  AS destid,
        TRIM(pcta.destih)  AS destih
    FROM
        movimientos det
        LEFT OUTER JOIN tccostos    cco ON ( cco.id_cia = pin_id_cia )
                                        AND ( cco.codigo = det.ccosto )
        LEFT OUTER JOIN pcuentas    pcta ON ( pcta.id_cia = pin_id_cia )
                                         AND ( pcta.cuenta = det.cuenta )
    WHERE
            det.id_cia = pin_id_cia
        AND det.libro = pin_libro
        AND det.periodo = pin_periodo
        AND det.mes = pin_mes
        AND det.asiento = pin_secuencia
    ORDER BY
        det.id_cia,
        det.periodo,
        det.mes,
        det.libro,
        det.asiento,
        det.item;

    v_ccosto         VARCHAR(16);
    v_codctacco      VARCHAR(16) := '';
    v_destincco      VARCHAR(16) := '';
    v_cuenta         VARCHAR2(250) := '';
    v_cuentadet      VARCHAR2(150) := '';
    v_destindpcuenta VARCHAR(16) := '';
    v_destinhpcuenta VARCHAR(16) := '';
    v_cuentaerr      VARCHAR(16) := '';
    v_sitem          INTEGER;
    v_no_genera_des  VARCHAR(10 CHAR);
    v_item           NUMBER;
    v_accion         VARCHAR2(50) := 'el proceso';
    v_result         VARCHAR2(1);
    v_error          VARCHAR2(150) := '';
    v_mensaje        VARCHAR2(250) := '';
    v_aux            VARCHAR2(25) := '';
BEGIN
    BEGIN
        SELECT
            vstrg
        INTO v_no_genera_des
        FROM
            tlibros_clase
        WHERE
                id_cia = pin_id_cia
            AND codlib = pin_libro
            AND clase = 2
            AND vstrg IN ( 'S', 'N' );

    EXCEPTION
        WHEN no_data_found THEN
            v_no_genera_des := 'N';
    END;

    DELETE FROM movimientos
    WHERE
            id_cia = pin_id_cia
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND libro = pin_libro
        AND asiento = pin_secuencia;

    v_cuenta := 'DETALLE DEL ASIENTO - '; --INICIALIZANDO
    -- BUSCANDO CUENTAS DEL DOCUMENTOS_DET
    dbms_output.put_line('INICIANDO VALIDACION');
    pack_pcuentas.sp_cuenta_no_existe(pin_id_cia, pin_periodo, pin_mes, pin_libro, pin_secuencia,
                                     v_cuentadet);
    v_cuenta := v_cuenta || v_cuentadet;
    dbms_output.put_line('GENERANDO DETALLE DEL ASIENTO (ASIENDET)');
    INSERT INTO movimientos
        SELECT
            d.id_cia,
            d.periodo,
            d.mes,
            d.libro,
            d.asiento,
            d.item,
            d.sitem,
            d.concep,
            c.fecha,
            d.tasien,
            d.topera,
            d.cuenta,
            d.dh,
            d.moneda,
            d.importe,
            d.impor01,
            d.impor02,
            d.debe,
            d.debe01,
            d.debe02,
            d.haber,
            d.haber01,
            d.haber02,
            d.tcambio01,
            d.tcambio02,
            d.ccosto,
            d.proyec,
            d.subcco,
            d.tipo,
            d.docume,
            d.codigo,
            d.razon,
            d.tident,
            d.dident,
            d.tdocum,
            d.serie,
            d.numero,
            d.fdocum,
            d.usuari,
            d.fcreac,
            d.factua,
            d.regcomcol,
            d.swprovicion,
            d.saldo,
            d.swgasoper,
            d.codporret,
            d.swchkconcilia,
            d.ctaalternativa
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
            AND d.asiento = pin_secuencia;

    COMMIT;
    v_cuenta := 'ASOCIADO AL TIPO DE CAMBIO';
    dbms_output.put_line('GENERANDO ASIENTO RELACIONADO AL TIPO DE CAMBIO');
    sp_genera_asiento_diferencia_cambio(pin_id_cia, pin_periodo, pin_libro, pin_mes, pin_secuencia,
                                       pin_usuario);
    COMMIT;
    FOR r_asiendet IN cur_asiendet LOOP 
                -- v_no_genera_des = 'S' no genera 
				-- v_no_genera_des = 'N' si genera
        IF
            ( upper(v_no_genera_des) = 'N' )
            AND ( r_asiendet.swccosto = 'S' )
        THEN
		    /*SI LA CUENTA CONTABLE PIDE CENTRO DE COSTO*/

			/* VERIFICA EL CAMPO CCOSTO EN PLAN DE CUENTAS*/
            IF ( ( r_asiendet.ccosto IS NULL ) OR ( r_asiendet.ccosto = '' ) ) THEN
                v_error := 'DETALLE DEL ASIENTO - CUENTA ( CONFIGURADA CON CENTRO DE COSTO OBLIGATORIO ) [ '
                           || r_asiendet.cuenta
                           || ' ] CON CENTRO DE COSTO EN BLANCO';
                RAISE pkg_exceptionuser.ex_cuenta_en_blanco;
            ELSE
                v_result := sp_valida_cuenta_existe_en_pcuentas(pin_id_cia, r_asiendet.ccosto);
                IF v_result = 'N' THEN
                    v_error := 'Asiendet - cuenta ccosto ['
                               || r_asiendet.ccosto
                               || '] No existe en plan de cuentas';
                    RAISE pkg_exceptionuser.ex_destin_no_existe_pcuentas;
                END IF;

            END IF;			


			/* VERIFICA EL CAMPO DESTIN EN PLAN DE CUENTAS*/

            IF ( ( r_asiendet.destincco IS NULL ) OR ( r_asiendet.destincco = '' ) ) THEN
                v_error := 'Centro de costo - cuenta Destin en blanco';
                RAISE pkg_exceptionuser.ex_cuenta_en_blanco;
            ELSE
                v_result := sp_valida_cuenta_existe_en_pcuentas(pin_id_cia, r_asiendet.destincco);
                IF v_result = 'N' THEN
                    v_error := 'Centro de costo - cuenta Destin ['
                               || r_asiendet.destincco
                               || '] No existe en plan de cuentas';
                    RAISE pkg_exceptionuser.ex_destin_no_existe_tccostos;
                END IF;

            END IF;

            v_cuenta := 'C. CCOSTO - ' || r_asiendet.ccosto; -- CENTRO DE CCOSTO
            dbms_output.put_line('GENERANDO CUENTAS RELACIONADAS CON CENTRO DE COSTO');
            INSERT INTO movimientos (
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
                pin_id_cia,
                r_asiendet.periodo,
                r_asiendet.mes,
                r_asiendet.libro,
                r_asiendet.asiento,
                r_asiendet.item,
                1,
                r_asiendet.concep,
                r_asiendet.fecha,
                r_asiendet.tasien,
                r_asiendet.topera,
                r_asiendet.ccosto,
                r_asiendet.dh,
                r_asiendet.moneda,
                r_asiendet.importe,
                r_asiendet.impor01,
                r_asiendet.impor02,
                r_asiendet.debe,
                r_asiendet.debe01,
                r_asiendet.debe02,
                r_asiendet.haber,
                r_asiendet.haber01,
                r_asiendet.haber02,
                r_asiendet.tcambio01,
                r_asiendet.tcambio02,
                '',
                '',
                '',
                r_asiendet.tipo,
                r_asiendet.docume,
                r_asiendet.codigo,
                r_asiendet.razon,
                r_asiendet.tident,
                r_asiendet.dident,
                r_asiendet.tdocum,
                r_asiendet.serie,
                r_asiendet.numero,
                r_asiendet.fdocum,
                r_asiendet.usuari,
                current_date,
                current_date,
                0,
                r_asiendet.swprovicion,
                r_asiendet.saldo,
                NULL,
                r_asiendet.codporret,
                r_asiendet.swchkconcilia,
                r_asiendet.ctaalternativa
            );

            IF r_asiendet.dh = 'D' THEN
                r_asiendet.dh := 'H';
                r_asiendet.haber := r_asiendet.importe;
                r_asiendet.haber01 := r_asiendet.impor01;
                r_asiendet.haber02 := r_asiendet.impor02;
                r_asiendet.debe := 0;
                r_asiendet.debe01 := 0;
                r_asiendet.debe02 := 0;
            ELSE
                r_asiendet.dh := 'D';
                r_asiendet.haber := 0;
                r_asiendet.haber01 := 0;
                r_asiendet.haber02 := 0;
                r_asiendet.debe := r_asiendet.importe;
                r_asiendet.debe01 := r_asiendet.impor01;
                r_asiendet.debe02 := r_asiendet.impor02;
            END IF;

            v_cuenta := 'DESTINO - ' || r_asiendet.destincco;
            dbms_output.put_line('GENERANDO CUENTAS RELACIONADAS CON DESTINO');
            INSERT INTO movimientos (
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
                pin_id_cia,
                r_asiendet.periodo,
                r_asiendet.mes,
                r_asiendet.libro,
                r_asiendet.asiento,
                r_asiendet.item,
                2,
                r_asiendet.concep,
                r_asiendet.fecha,
                r_asiendet.tasien,
                r_asiendet.topera,
                r_asiendet.destincco,
                r_asiendet.dh,
                r_asiendet.moneda,
                r_asiendet.importe,
                r_asiendet.impor01,
                r_asiendet.impor02,
                r_asiendet.debe,
                r_asiendet.debe01,
                r_asiendet.debe02,
                r_asiendet.haber,
                r_asiendet.haber01,
                r_asiendet.haber02,
                r_asiendet.tcambio01,
                r_asiendet.tcambio02,
                '',
                '',
                '',
                r_asiendet.tipo,
                r_asiendet.docume,
                r_asiendet.codigo,
                r_asiendet.razon,
                r_asiendet.tident,
                r_asiendet.dident,
                r_asiendet.tdocum,
                r_asiendet.serie,
                r_asiendet.numero,
                r_asiendet.fdocum,
                r_asiendet.usuari,
                current_date,
                current_date,
                0,
                r_asiendet.swprovicion,
                r_asiendet.saldo,
                NULL,
                r_asiendet.codporret,
                r_asiendet.swchkconcilia,
                r_asiendet.ctaalternativa
            );

        END IF;

        IF
            ( upper(v_no_genera_des) = 'N' )
            AND ( r_asiendet.swdestino = 'S' )
        THEN
		    /*SI LA CUENTA CONTABLE TIENE DESTINO AUTOMATICO*/
			/* VERIFICA EL CAMPO DESTIN EN PLAN DE CUENTAS*/
            IF ( ( r_asiendet.destid IS NULL ) OR ( r_asiendet.destid = '' ) ) THEN
                v_error := 'Plan de cuentas[Destino automatico] - cuenta Debe en blanco';
                RAISE pkg_exceptionuser.ex_cuenta_en_blanco;
            ELSE
                v_result := sp_valida_cuenta_existe_en_pcuentas(pin_id_cia, r_asiendet.destid);
                IF v_result = 'N' THEN
                    v_error := 'Plan de cuentas[Destino automatico]  - cuenta Debe ['
                               || r_asiendet.destid
                               || '] No existe en plan de cuentas';
                    RAISE pkg_exceptionuser.ex_destin_no_existe_pcuentas;
                END IF;

            END IF;

            IF ( ( r_asiendet.destih IS NULL ) OR ( r_asiendet.destih = '' ) ) THEN
                v_error := 'Plan de cuentas[Destino automatico] - cuenta Haber en blanco';
                RAISE pkg_exceptionuser.ex_cuenta_en_blanco;
            ELSE
                v_result := sp_valida_cuenta_existe_en_pcuentas(pin_id_cia, r_asiendet.destih);
                IF v_result = 'N' THEN
                    v_error := 'Plan de cuentas[Destino automatico]  - cuenta Haber ['
                               || r_asiendet.destih
                               || '] No existe en plan de cuentas';
                    RAISE pkg_exceptionuser.ex_destin_no_existe_pcuentas;
                END IF;

            END IF;

            v_cuenta := 'DESTID - ' || r_asiendet.destid;
            dbms_output.put_line('GENERANDO CUENTAS RELACIONADAS CON DESTID');
            INSERT INTO movimientos (
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
                pin_id_cia,
                r_asiendet.periodo,
                r_asiendet.mes,
                r_asiendet.libro,
                r_asiendet.asiento,
                r_asiendet.item,
                1,
                r_asiendet.concep,
                r_asiendet.fecha,
                r_asiendet.tasien,
                r_asiendet.topera,
                r_asiendet.destid,
                r_asiendet.dh,
                r_asiendet.moneda,
                r_asiendet.importe,
                r_asiendet.impor01,
                r_asiendet.impor02,
                r_asiendet.debe,
                r_asiendet.debe01,
                r_asiendet.debe02,
                r_asiendet.haber,
                r_asiendet.haber01,
                r_asiendet.haber02,
                r_asiendet.tcambio01,
                r_asiendet.tcambio02,
                '',
                '',
                '',
                r_asiendet.tipo,
                r_asiendet.docume,
                r_asiendet.codigo,
                r_asiendet.razon,
                r_asiendet.tident,
                r_asiendet.dident,
                r_asiendet.tdocum,
                r_asiendet.serie,
                r_asiendet.numero,
                r_asiendet.fdocum,
                r_asiendet.usuari,
                current_date,
                current_date,
                0,
                r_asiendet.swprovicion,
                r_asiendet.saldo,
                NULL,
                r_asiendet.codporret,
                r_asiendet.swchkconcilia,
                r_asiendet.ctaalternativa
            );

            IF r_asiendet.dh = 'D' THEN
                r_asiendet.dh := 'H';
                r_asiendet.haber := r_asiendet.importe;
                r_asiendet.haber01 := r_asiendet.impor01;
                r_asiendet.haber02 := r_asiendet.impor02;
                r_asiendet.debe := 0;
                r_asiendet.debe01 := 0;
                r_asiendet.debe02 := 0;
            ELSE
                r_asiendet.dh := 'D';
                r_asiendet.haber := 0;
                r_asiendet.haber01 := 0;
                r_asiendet.haber02 := 0;
                r_asiendet.debe := r_asiendet.importe;
                r_asiendet.debe01 := r_asiendet.impor01;
                r_asiendet.debe02 := r_asiendet.impor02;
            END IF;

            v_cuenta := 'DESTIH ' || r_asiendet.destih;
            INSERT INTO movimientos (
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
                pin_id_cia,
                r_asiendet.periodo,
                r_asiendet.mes,
                r_asiendet.libro,
                r_asiendet.asiento,
                r_asiendet.item,
                2,
                r_asiendet.concep,
                r_asiendet.fecha,
                r_asiendet.tasien,
                r_asiendet.topera,
                r_asiendet.destih,
                r_asiendet.dh,
                r_asiendet.moneda,
                r_asiendet.importe,
                r_asiendet.impor01,
                r_asiendet.impor02,
                r_asiendet.debe,
                r_asiendet.debe01,
                r_asiendet.debe02,
                r_asiendet.haber,
                r_asiendet.haber01,
                r_asiendet.haber02,
                r_asiendet.tcambio01,
                r_asiendet.tcambio02,
                '',
                '',
                '',
                r_asiendet.tipo,
                r_asiendet.docume,
                r_asiendet.codigo,
                r_asiendet.razon,
                r_asiendet.tident,
                r_asiendet.dident,
                r_asiendet.tdocum,
                r_asiendet.serie,
                r_asiendet.numero,
                r_asiendet.fdocum,
                r_asiendet.usuari,
                current_date,
                current_date,
                0,
                r_asiendet.swprovicion,
                r_asiendet.saldo,
                NULL,
                r_asiendet.codporret,
                r_asiendet.swchkconcilia,
                r_asiendet.ctaalternativa
            );

        END IF;

        COMMIT;
    END LOOP;

    v_accion := 'el proceso completó correctamente.';
    SELECT
        JSON_OBJECT(
            'status' VALUE 1.0,
            'message' VALUE 'El proceso completó correctamente.'
        )
    INTO pin_mensaje
    FROM
        dual;

EXCEPTION
    WHEN pkg_exceptionuser.ex_cuenta_en_blanco THEN
        v_accion := 'el proceso no se completo.';
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.1,
                'message' VALUE v_error
            )
        INTO pin_mensaje
        FROM
            dual;

--        raise_application_error(pkg_exceptionuser.cuenta_en_blanco, v_error);
    WHEN pkg_exceptionuser.ex_destin_no_existe_pcuentas THEN
        v_accion := 'el proceso no se completo.';
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.1,
                'message' VALUE v_error
            )
        INTO pin_mensaje
        FROM
            dual;

--        raise_application_error(pkg_exceptionuser.destin_no_existe_pcuentas, v_error);
    WHEN pkg_exceptionuser.ex_destin_no_existe_tccostos THEN
        v_accion := 'el proceso no se completo.';
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.1,
                'message' VALUE v_error
            )
        INTO pin_mensaje
        FROM
            dual;

--        raise_application_error(pkg_exceptionuser.destin_no_existe_tccostos, v_error);
    WHEN OTHERS THEN
        IF sqlcode = -2291 THEN -- RESTRICCION FK
            sp_descontabilizar_asiento(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                                      pin_usuario, v_mensaje);
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'EL ASIENTO TIENE CUENTAS [ '
                                    || v_cuenta
                                    || ' ] QUE NO EXISTEN EN EL PLAN DE CUENTAS'
                )
            INTO pin_mensaje
            FROM
                dual;

        ELSIF sqlcode = -1400 THEN -- CUENTA NULL
            sp_descontabilizar_asiento(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                                      pin_usuario, v_mensaje);
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'EL ASIENTO TIENE CUENTAS [ '
                                    || v_cuenta
                                    || ' ] NO DEFINIDAS (NULL)'
                )
            INTO pin_mensaje
            FROM
                dual;

        ELSE
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        END IF;
END sp_contabilizar_asiento;

/
