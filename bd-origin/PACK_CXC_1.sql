--------------------------------------------------------
--  DDL for Package Body PACK_CXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CXC" AS

    PROCEDURE sp_update_ubicacion (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_codubi  IN NUMBER,
        pin_cuenta  IN VARCHAR2,
        pin_fecha   IN DATE,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR
    ) AS

        o            json_object_t;
        rec_dcta100  dcta100%rowtype;
        rec_asienhea asienhea%rowtype;
        rec_asiendet asiendet%rowtype;
        v_desubi     VARCHAR(2000 CHAR);
        m            json_object_t;
        pout_mensaje VARCHAR2(1000 CHAR);
        v_mensaje    VARCHAR2(1000 CHAR);
    BEGIN
        BEGIN
            SELECT
                d100.*
            INTO rec_dcta100
            FROM
                dcta100 d100
            WHERE
                    d100.id_cia = pin_id_cia
                AND d100.numint = pin_numint;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'EL DOCUMENTO N° '
                                || pin_numint
                                || ' NO EXISTE COMO CUENTA POR COBRAR!';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            IF rec_dcta100.femisi >= pin_fecha THEN
                pout_mensaje := 'LA FECHA DEL ASIENTO '
                                || to_char(pin_fecha, 'DD/MM/YY')
                                || ' NO PUEDE SER MENOR A LA FECHA DE EMISION DEL DOCUMENTO '
                                || to_char(rec_dcta100.femisi, 'DD/MM/YY');

                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

            IF rec_dcta100.codubi = pin_codubi THEN
                BEGIN
                    SELECT
                        desubi
                    INTO v_desubi
                    FROM
                        ubicacion
                    WHERE
                            id_cia = pin_id_cia
                        AND codubi = pin_codubi;

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'LA UBICACION N° '
                                        || pin_codubi
                                        || 'NO EXISTE EN EL SISTEMA';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                pout_mensaje := 'EL DOCUMENTO N° '
                                || pin_numint
                                || ' YA TIENE DEFINIDA LA UBICACION DE '
                                || v_desubi;
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END;

        UPDATE dcta100
        SET
            codubi = pin_codubi,
            cuenta = pin_cuenta
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        BEGIN
            rec_asienhea.id_cia := pin_id_cia;
            rec_asienhea.periodo := extract(YEAR FROM pin_fecha);
            rec_asienhea.mes := extract(MONTH FROM pin_fecha);
            rec_asienhea.libro := '39';
            sp00_saca_secuencia_libro(pin_id_cia, rec_asienhea.libro, rec_asienhea.periodo, rec_asienhea.mes, pin_coduser,
                                     1, rec_asienhea.asiento);

            rec_asienhea.concep := 'Cambio de Ubicación - ' || rec_dcta100.docume;
            rec_asienhea.tasien := 0;
            rec_asienhea.moneda := rec_dcta100.tipmon;
            rec_asienhea.fecha := pin_fecha;
            rec_asienhea.tcamb01 := 0;
            rec_asienhea.tcamb02 := 0;
            rec_asienhea.ncontab := 0;
            rec_asienhea.numret := 0;
            rec_asienhea.usuari := pin_coduser;
            rec_asienhea.ucreac := pin_coduser;
            rec_asienhea.situac := 1;
            rec_asienhea.fcreac := current_timestamp;
            rec_asienhea.factua := current_timestamp;
            rec_asiendet.id_cia := rec_asienhea.id_cia;
            rec_asiendet.periodo := rec_asienhea.periodo;
            rec_asiendet.mes := rec_asienhea.mes;
            rec_asiendet.libro := rec_asienhea.libro;
            rec_asiendet.asiento := rec_asienhea.asiento;
            rec_asiendet.item := 0;
            rec_asiendet.sitem := 0;
            rec_asiendet.concep := rec_asienhea.concep;
            rec_asiendet.fecha := rec_asienhea.fecha;
            rec_asiendet.tasien := '66';
            rec_asiendet.topera := '0';
            rec_asiendet.cuenta := pin_cuenta;
            rec_asiendet.moneda := rec_asienhea.moneda;
            IF rec_asienhea.moneda = 'PEN' THEN
                rec_asiendet.tcambio01 := 1;
                rec_asiendet.tcambio02 := 1 / rec_dcta100.tipcam;
            ELSE
                rec_asiendet.tcambio01 := rec_dcta100.tipcam;
                rec_asiendet.tcambio02 := 1;
            END IF;

            rec_asiendet.importe := rec_dcta100.saldo;
            rec_asiendet.impor01 := rec_dcta100.saldo * rec_asiendet.tcambio01;
            rec_asiendet.impor02 := rec_dcta100.saldo * rec_asiendet.tcambio02;
            rec_asiendet.saldo := rec_dcta100.saldo;
            rec_asiendet.tipo := 0;
            rec_asiendet.docume := -1;
            rec_asiendet.codigo := rec_dcta100.codcli;
            BEGIN
                SELECT
                    razonc
                INTO rec_asiendet.razon
                FROM
                    cliente
                WHERE
                        id_cia = pin_id_cia
                    AND codcli = rec_asiendet.codigo;

            EXCEPTION
                WHEN no_data_found THEN
                    rec_asiendet.razon := '';
            END;

            BEGIN
                SELECT
                    codigosunat
                INTO rec_asiendet.tdocum
                FROM
                    documentos_tipo
                WHERE
                        id_cia = pin_id_cia
                    AND tipdoc = rec_dcta100.tipdoc;

            EXCEPTION
                WHEN no_data_found THEN
                    rec_asiendet.tdocum := '';
            END;

            rec_asiendet.serie := rec_dcta100.serie;
            rec_asiendet.numero := rec_dcta100.numero;
            rec_asiendet.fdocum := rec_dcta100.femisi;
            rec_asiendet.ccosto := NULL;
            rec_asiendet.subcco := NULL;
            rec_asiendet.usuari := pin_coduser;
            rec_asiendet.fcreac := current_timestamp;
            rec_asiendet.factua := current_timestamp;
            rec_asiendet.regcomcol := 0;
            rec_asiendet.swgasoper := 0;
            rec_asiendet.swprovicion := 'N';
            INSERT INTO asienhea VALUES rec_asienhea;

            FOR i IN 1..2 LOOP
                rec_asiendet.item := i;
                IF i = 1 THEN
                    IF rec_dcta100.dh = 'D' THEN
                        rec_asiendet.dh := 'H';
                        rec_asiendet.debe := 0;
                        rec_asiendet.debe01 := 0;
                        rec_asiendet.debe02 := 0;
                        rec_asiendet.haber := rec_asiendet.importe;
                        rec_asiendet.haber01 := rec_asiendet.impor01;
                        rec_asiendet.haber02 := rec_asiendet.impor02;
                    ELSE
                        rec_asiendet.dh := 'D';
                        rec_asiendet.debe := rec_asiendet.importe;
                        rec_asiendet.debe01 := rec_asiendet.impor01;
                        rec_asiendet.debe02 := rec_asiendet.impor02;
                        rec_asiendet.haber := 0;
                        rec_asiendet.haber01 := 0;
                        rec_asiendet.haber02 := 0;
                    END IF;

                ELSE
                    IF rec_dcta100.dh = 'D' THEN
                        rec_asiendet.dh := 'D';
                        rec_asiendet.debe := rec_asiendet.importe;
                        rec_asiendet.debe01 := rec_asiendet.impor01;
                        rec_asiendet.debe02 := rec_asiendet.impor02;
                        rec_asiendet.haber := 0;
                        rec_asiendet.haber01 := 0;
                        rec_asiendet.haber02 := 0;
                    ELSE
                        rec_asiendet.dh := 'H';
                        rec_asiendet.debe := 0;
                        rec_asiendet.debe01 := 0;
                        rec_asiendet.debe02 := 0;
                        rec_asiendet.haber := rec_asiendet.importe;
                        rec_asiendet.haber01 := rec_asiendet.impor01;
                        rec_asiendet.haber02 := rec_asiendet.impor02;
                    END IF;
                END IF;

                INSERT INTO asiendet VALUES rec_asiendet;

            END LOOP;

            sp_contabilizar_asiento(rec_asienhea.id_cia, rec_asienhea.libro, rec_asienhea.periodo, rec_asienhea.mes, rec_asienhea.asiento
            ,
                                   pin_coduser, v_mensaje);

            o := json_object_t.parse(v_mensaje);
            dbms_output.put_line('CONTABILIZAR ASIENTO - ' || o.get_string('message'));
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := 'ASIENTO '
                                || rec_asienhea.libro
                                || '-'
                                || rec_asienhea.periodo
                                || '-'
                                || rec_asienhea.mes
                                || '-'
                                || rec_asienhea.asiento
                                || ' FALLO AL CONTABILIZAR, POR : '
                                || o.get_string('message');

                RAISE pkg_exceptionuser.ex_error_inesperado;
            ELSE
                UPDATE asienhea
                SET
                    situac = 2,
                    factua = current_timestamp,
                    usuari = pin_coduser
                WHERE
                        id_cia = rec_asienhea.id_cia
                    AND periodo = rec_asienhea.periodo
                    AND mes = rec_asienhea.mes
                    AND libro = rec_asienhea.libro
                    AND asiento = rec_asienhea.asiento;

                COMMIT;
            END IF;

        END;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'ASIENTO '
                                || rec_asienhea.libro
                                || '-'
                                || rec_asienhea.periodo
                                || '-'
                                || rec_asienhea.mes
                                || '-'
                                || rec_asienhea.asiento
                                || ' CONTABILIZADO CORRECTAMENTE'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' valcon :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_update_ubicacion;

END;

/
