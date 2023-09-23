--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_CANCELACION_PLANILLA_COBRANZA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_CANCELACION_PLANILLA_COBRANZA" AS

    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        o           json_object_t;
        reg_errores r_errores;
        rec_dcta100 dcta100%rowtype;
        rec_dcta101 dcta101%rowtype;
        rec_tbancos tbancos%rowtype;
        aux_dcta100 dcta100%rowtype;
        v_compra    NUMBER(16, 2) := 0;
        v_venta     NUMBER(16, 2) := 0;
        v_amorti    NUMBER;
        v_codcob    NUMBER;
        v_aux       VARCHAR(100 CHAR);
        v_mensaje   VARCHAR2(1000 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        -- PLANILLA DCTA100
        rec_dcta100.id_cia := pin_id_cia;
        rec_dcta100.tipdoc := to_char(o.get_number('tipdoc'));
        rec_dcta100.serie := o.get_string('serie');
        rec_dcta100.numero := to_char(o.get_number('numdoc'));
        -- PLANILLA DE CANCELACION
        rec_dcta101.id_cia := pin_id_cia;
        rec_dcta101.tipcan := o.get_number('tipcam');
        rec_dcta101.operac := o.get_string('operac');
        rec_dcta101.codban := o.get_number('codban');
        rec_dcta101.femisi := o.get_date('fcance');
        rec_dcta101.periodo := extract(YEAR FROM rec_dcta101.femisi);
        rec_dcta101.mes := extract(MONTH FROM rec_dcta101.femisi);
        rec_dcta101.tipmon := o.get_string('tipmon');
        v_amorti := o.get_number('amorti');
        v_codcob := o.get_number('codcob');
--        v_aux := o.get_string('codcob');
--        v_codcob := to_number(v_aux);
--        reg_errores.valor := 'VALOR + ' || to_char(v_codcob);
--        reg_errores.deserror := 'PRUEBA TODAS LAS FILAS CON ERROR';
--        PIPE ROW ( reg_errores );
        -- NUMERO DE FILA
        reg_errores.orden := o.get_number('fila');
        reg_errores.concepto := 'FILA - N°'
                                || to_char(o.get_number('fila'));
        -- VALIDACION
        -- PERIODO Y MES?
--        sp_chequea_mes_proceso(pin_id_cia, rec_dcta101.periodo, rec_dcta101.mes, 2, v_mensaje);
--        o := json_object_t.parse(v_mensaje);
--        IF ( o.get_number('status') <> 1.0 ) THEN
--            reg_errores.valor := '';
--            reg_errores.deserror := o.get_string('message');
--            PIPE ROW ( reg_errores );
--        END IF;



        BEGIN
            SELECT
                d100.*
            INTO aux_dcta100
            FROM
                dcta100 d100
            WHERE
                    d100.id_cia = pin_id_cia
                AND d100.serie = rec_dcta100.serie
                AND d100.numero = rec_dcta100.numero;

            IF aux_dcta100.saldo = 0 THEN
                reg_errores.valor := nvl(rec_dcta100.serie, 'ND')
                                     || ' - '
                                     || nvl(rec_dcta100.numero, 0);

                reg_errores.deserror := 'EL DOCUMENTO TIENE SALDO CERO';
                PIPE ROW ( reg_errores );
            ELSIF v_amorti > aux_dcta100.saldo THEN
                reg_errores.valor := nvl(rec_dcta100.serie, 'ND')
                                     || ' - '
                                     || nvl(rec_dcta100.numero, 0)
                                     || ' | '
                                     || v_amorti
                                     || ' > '
                                     || aux_dcta100.saldo;

                reg_errores.deserror := 'EL SALDO INSUFICIENTE PARA PROCESAR LA AMORTIZACION';
                PIPE ROW ( reg_errores );
            END IF;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := nvl(rec_dcta100.serie, 'ND')
                                     || ' - '
                                     || nvl(rec_dcta100.numero, 0);

                reg_errores.deserror := 'EL DOCUMENTO NO EXISTE';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                round(compra, 2),
                round(venta, 2)
            INTO
                v_compra,
                v_venta
            FROM
                tcambio
            WHERE
                    id_cia = pin_id_cia
                AND fecha = rec_dcta101.femisi
                AND moneda = 'USD'
                AND hmoneda = 'PEN';

            IF nvl(v_venta, 0) = 0 THEN
                reg_errores.valor := to_char(rec_dcta101.femisi, 'DD/MM/YY');
                reg_errores.deserror := 'EL TIPO DE CAMBIO PARA LE FECHA '
                                        || to_char(rec_dcta101.femisi, 'DD/MM/YY')
                                        || ' ESTA EN CERO';

                PIPE ROW ( reg_errores );
            END IF;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := to_char(rec_dcta101.femisi, 'DD/MM/YY');
                reg_errores.deserror := 'NO EXISTE TIPO DE CAMBIO PARA LA FECHA '
                                        || to_char(rec_dcta101.femisi, 'DD/MM/YY');
                PIPE ROW ( reg_errores );
            WHEN too_many_rows THEN
                reg_errores.valor := to_char(rec_dcta101.femisi, 'DD/MM/YY');
                reg_errores.deserror := 'EXISTE MAS DE UN TIPO DE CAMBIO REGISTRADO PARA LA FECHA '
                                        || to_char(rec_dcta101.femisi, 'DD/MM/YY');
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                *
            INTO rec_tbancos
            FROM
                tbancos
            WHERE
                    id_cia = pin_id_cia
                AND codban = rec_dcta101.codban;

            IF rec_tbancos.moneda <> rec_dcta101.tipmon THEN
                reg_errores.valor := rec_tbancos.moneda
                                     || ' - '
                                     || rec_dcta101.tipmon;
                reg_errores.deserror := 'LA MONEDA DE LA OPERACION NO PUEDE SER DIFERENTE A LA MONEDA DE PAGO';
                PIPE ROW ( reg_errores );
            END IF;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_dcta101.codban;
                reg_errores.deserror := 'LA OPERACION NO EXISTE';
                PIPE ROW ( reg_errores );
        END;

    END;

    PROCEDURE sp_importa (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        o            json_object_t;
        rec_dcta100  dcta100%rowtype;
        aux_dcta100  dcta100%rowtype;
        rec_dcta101  dcta101%rowtype;
        rec_dcta102  dcta102%rowtype;
        rec_dcta103  dcta103%rowtype;
        rec_dcta104  dcta104%rowtype;
        rec_tbancos  tbancos%rowtype;
        v_compra     NUMBER(16, 2) := 0;
        v_venta      NUMBER(16, 2) := 0;
        v_femisi     DATE;
        v_tipcan     NUMBER;
        v_tipmon     VARCHAR2(5);
        v_amorti     NUMBER;
        v_codcob     NUMBER;
        v_concep     VARCHAR2(150 CHAR);
        v_codban     NUMBER;
        v_op         VARCHAR2(150 CHAR);
        v_mensaje    VARCHAR2(1000 CHAR);
        pout_mensaje VARCHAR2(1000 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        -- PLANILLA DCTA100
        aux_dcta100.id_cia := pin_id_cia;
        v_femisi := o.get_date('fcance');
        v_concep := o.get_string('concep');
        v_codcob := o.get_number('codcob');
        aux_dcta100.tipdoc := to_char(o.get_number('tipdoc'));
        aux_dcta100.serie := o.get_string('serie');
        aux_dcta100.numero := to_char(o.get_number('numdoc'));
        v_tipcan := o.get_number('tipcan');
        v_tipmon := o.get_string('tipmon');
        v_amorti := o.get_number('amorti');
        v_codban := o.get_number('codban');
        v_op := o.get_string('op');

        -- BUSCANDO PLANILLA 
        SELECT
            d100.*
        INTO rec_dcta100
        FROM
            dcta100 d100
        WHERE
                d100.id_cia = aux_dcta100.id_cia
            AND d100.tipdoc = aux_dcta100.tipdoc
            AND d100.serie = aux_dcta100.serie
            AND d100.numero = aux_dcta100.numero;

        -- TBANCOS
        SELECT
            *
        INTO rec_tbancos
        FROM
            tbancos
        WHERE
                id_cia = pin_id_cia
            AND codban = v_codban;

        -- TIPO DE CAMBIO
        SELECT
            round(compra, 2),
            round(venta, 2)
        INTO
            v_compra,
            v_venta
        FROM
            tcambio
        WHERE
                id_cia = pin_id_cia
            AND fecha = v_femisi
            AND moneda = 'USD'
            AND hmoneda = 'PEN';

        pack_dcta100.sp_update_saldo(rec_dcta100.id_cia, rec_dcta100.numint, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;


    -- PLANILLA DE CANCELACION DCTA101
        rec_dcta101.id_cia := pin_id_cia;
        rec_dcta101.numint := rec_dcta100.numint;
        BEGIN
            SELECT
                ( numite + 1 )
            INTO rec_dcta101.numite
            FROM
                dcta101
            WHERE
                    id_cia = rec_dcta101.id_cia
                AND numint = rec_dcta101.numint
            ORDER BY
                numite DESC
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                rec_dcta101.numite := 1;
        END;

        rec_dcta101.fproce := v_femisi;
        rec_dcta101.libro := '16';
        rec_dcta101.periodo := extract(YEAR FROM v_femisi);
        rec_dcta101.mes := extract(MONTH FROM v_femisi);
        sp00_saca_secuencia_libro(rec_dcta101.id_cia, rec_dcta101.libro, rec_dcta101.periodo, rec_dcta101.mes, pin_coduser,
                                 1, rec_dcta101.secuencia);

        rec_dcta101.item := 1;
        rec_dcta101.tipcan := v_tipcan;
        rec_dcta101.doccan := NULL;
        rec_dcta101.operac := 0;
        rec_dcta101.codban := v_codban;
        rec_dcta101.numbco := NULL;
        rec_dcta101.codcob := rec_dcta101.codcob;
        rec_dcta101.tipope := NULL;
        rec_dcta101.cuenta := rec_dcta100.cuenta;
        CASE
            WHEN rec_dcta100.dh = 'H' THEN
                rec_dcta101.dh := 'D';
            ELSE
                rec_dcta101.dh := 'H';
        END CASE;

        rec_dcta101.tipmon := v_tipmon;
        rec_dcta101.importe := v_amorti;
        IF rec_dcta101.tipmon = 'PEN' THEN
            rec_dcta101.tcamb01 := 1;
            rec_dcta101.tcamb02 := round(1 / v_venta, 2);
        ELSE
            rec_dcta101.tcamb01 := v_venta;
            rec_dcta101.tcamb02 := 1;
        END IF;

        rec_dcta101.impor01 := rec_dcta101.importe * rec_dcta101.tcamb01;
        rec_dcta101.impor02 := rec_dcta101.importe * rec_dcta101.tcamb02;
        rec_dcta101.difcam := NULL;
        rec_dcta101.comisi := NULL;
        rec_dcta101.codsuc := rec_dcta100.codsuc;
        rec_dcta101.fcreac := current_timestamp;
        rec_dcta101.factua := current_timestamp;
        rec_dcta101.usuari := pin_coduser;
        rec_dcta101.situac := 'A';
        rec_dcta101.femisi := v_femisi;
        rec_dcta101.codcli := rec_dcta100.codcli;

    -- PLANILLA, CABEZERA DCTA102
        rec_dcta102.id_cia := pin_id_cia;
        rec_dcta102.libro := rec_dcta101.libro;
        rec_dcta102.femisi := v_femisi;
        rec_dcta102.periodo := rec_dcta101.periodo;
        rec_dcta102.mes := rec_dcta101.mes;
        rec_dcta102.secuencia := rec_dcta101.secuencia;
        rec_dcta102.dia := extract(DAY FROM v_femisi);
        rec_dcta102.codcob := v_codcob;
        rec_dcta102.tipcam := v_venta;
        rec_dcta102.codsuc := 1;
        rec_dcta102.fcreac := current_timestamp;
        rec_dcta102.factua := current_timestamp;
        rec_dcta102.codusercrea := pin_coduser;
        rec_dcta102.usuari := pin_coduser;
        rec_dcta102.situac := 'B';
        rec_dcta102.conpag := NULL;
        rec_dcta102.tipmon := rec_dcta101.tipmon;
        rec_dcta102.extorno := NULL;
        rec_dcta102.deposito := NULL;
        rec_dcta102.tippla := 100;
        rec_dcta102.numcaja := NULL;
        rec_dcta102.concep := v_concep;
        rec_dcta102.swchkajuscen := 'N';
        rec_dcta102.girara := NULL;
        rec_dcta102.referencia := NULL;
        rec_dcta102.swacti := 'N';

    -- PLANILLA DE COBRANZA, DETALLE DE CUENTAS POR PAGAR DCTA103
        rec_dcta103.id_cia := pin_id_cia;
        rec_dcta103.libro := rec_dcta101.libro;
        rec_dcta103.periodo := rec_dcta101.periodo;
        rec_dcta103.mes := rec_dcta101.mes;
        rec_dcta103.secuencia := rec_dcta101.secuencia;
        rec_dcta103.item := 1;
        rec_dcta103.numint := rec_dcta100.numint;
        rec_dcta103.tipcan := v_tipcan;
        rec_dcta103.cuenta := rec_dcta100.cuenta;
        CASE
            WHEN rec_dcta100.dh = 'H' THEN
                rec_dcta103.dh := 'D';
            ELSE
                rec_dcta103.dh := 'H';
        END CASE;

        rec_dcta103.tipmon := v_tipmon;
        rec_dcta103.doccan := NULL;
        rec_dcta103.docume := rec_dcta100.docume;
        rec_dcta103.tipcam := v_venta;
        rec_dcta103.amorti := v_amorti;
        IF rec_dcta103.tipmon = 'PEN' THEN
            rec_dcta103.tcamb01 := 1;
            rec_dcta103.tcamb02 := round(1 / v_venta, 2);
            rec_dcta103.pagomn := rec_dcta103.amorti;
            rec_dcta103.pagome := 0;
        ELSE
            rec_dcta103.tcamb01 := v_venta;
            rec_dcta103.tcamb02 := 1;
            rec_dcta103.pagomn := 0;
            rec_dcta103.pagome := rec_dcta103.amorti;
        END IF;

        rec_dcta103.impor01 := rec_dcta103.amorti * rec_dcta103.tcamb01;
        rec_dcta103.impor02 := rec_dcta103.amorti * rec_dcta103.tcamb02;
        rec_dcta103.situac := 'A';
        rec_dcta103.numbco := NULL;
        rec_dcta103.deposito := NULL;
        rec_dcta103.swchksepaga := 'S';
        rec_dcta103.swdep := NULL;
        rec_dcta103.tipdoc := rec_dcta100.tipdoc;
        rec_dcta103.codban := 0;

        -- PLANILLA DE PAGOS DCTA104
        rec_dcta104.id_cia := pin_id_cia;
        rec_dcta104.libro := rec_dcta101.libro;
        rec_dcta104.periodo := rec_dcta101.periodo;
        rec_dcta104.mes := rec_dcta101.mes;
        rec_dcta104.secuencia := rec_dcta101.secuencia;
        rec_dcta104.item := 1;
        rec_dcta104.tipdep := v_tipcan;
        rec_dcta104.doccan := NULL;
        rec_dcta104.cuenta := rec_tbancos.cuentacon;
        rec_dcta104.dh := rec_dcta100.dh;
        rec_dcta104.tipmon := v_tipmon;
        rec_dcta104.codban := v_codban;
        rec_dcta104.op := v_op;
        rec_dcta104.agencia := NULL;
        rec_dcta104.tipcam := v_venta;
        rec_dcta104.deposito := v_amorti;
        IF rec_dcta104.tipmon = 'PEN' THEN
            rec_dcta104.tcamb01 := 1;
            rec_dcta104.tcamb02 := 1 / v_venta;
            rec_dcta104.pagomn := rec_dcta104.deposito;
            rec_dcta104.pagome := 0;
        ELSE
            rec_dcta104.tcamb01 := v_venta;
            rec_dcta104.tcamb02 := 1;
            rec_dcta104.pagomn := 0;
            rec_dcta104.pagome := rec_dcta104.deposito;
        END IF;

        rec_dcta104.impor01 := rec_dcta104.deposito * rec_dcta104.tcamb01;
        rec_dcta104.impor02 := rec_dcta104.deposito * rec_dcta104.tcamb02;
        rec_dcta104.situac := 'A';
        rec_dcta104.concep := v_concep;
        rec_dcta104.codigo := NULL;
        rec_dcta104.razon := NULL;
        rec_dcta104.tdocum := NULL;
        rec_dcta104.serie := NULL;
        rec_dcta104.numero := NULL;
        INSERT INTO dcta102 VALUES rec_dcta102;

        INSERT INTO dcta103 VALUES rec_dcta103;

        INSERT INTO dcta104 VALUES rec_dcta104;

        INSERT INTO dcta101 VALUES rec_dcta101;

        pack_dcta100.sp_update_saldo(rec_dcta100.id_cia, rec_dcta100.numint, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        sp_genera_asientos_cxcobrar(rec_dcta102.id_cia, rec_dcta102.libro, rec_dcta102.periodo, rec_dcta102.mes, rec_dcta102.secuencia
        ,
                                   pin_coduser, v_mensaje);

        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje || rec_dcta101.fproce
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' fijvar :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                                    || '-'
                                    || rec_dcta101.fproce
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_importa;

END;

/
