--------------------------------------------------------
--  DDL for Package Body PACK_HR_IMPORT_PERSONAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_IMPORT_PERSONAL" AS

    PROCEDURE sp_asigna_conceptos_fijos (
        pin_id_cia  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        m            json_object_t;
        pout_mensaje VARCHAR2(1000 CHAR);
        v_number     NUMBER := extract(MONTH FROM current_timestamp) - 1;
        v_mensaje    VARCHAR2(1000 CHAR);
    BEGIN
        FOR i IN 0..v_number LOOP
            -- REPLICAR CON LOS CONCEPTOS FIJO DEL SISTEMA AL PERSONAL CONCEPTO, PARA QUE EL MES DE APERTURA
            -- Y CONSECUENTES, TENGAN TODOS LOS CONCEPOS DEBIDAMENTE CARGADOS ( EN 0* )
            pack_hr_personal_concepto.sp_asigna_conceptos_fijos(pin_id_cia, NULL, extract(YEAR FROM current_timestamp), i, pin_coduser
            ,
                                                               v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := 'ERROR, AL ASIGNAR MASIVAMENTE LOS CONCEPTOS FIJOS, SERA NECESARIO UNA ACUALIZACION MANUAL, ERROR :  '
                || m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END LOOP;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'El proceso completó correctamente.'
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

            ROLLBACK;
    END sp_asigna_conceptos_fijos;

    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores                 r_errores := r_errores(NULL, NULL, NULL, NULL);
        fila                        NUMBER := 3;
        o                           json_object_t;
        rec_personal                personal%rowtype;
        rec_personal_periodolaboral personal_periodolaboral%rowtype;
        rec_personal_documento      personal_documento%rowtype;
        rec_personal_concepto       personal_concepto%rowtype;
        rec_personal_cts            personal_cts%rowtype;
        rec_personal_clase          personal_clase%rowtype;
        rec_personal_ccosto         personal_ccosto%rowtype;
        v_aux                       NUMBER := 0;
        v_char                      VARCHAR2(1 CHAR);
        v_jubinv                    NUMBER := 0;
        v_trab65                    NUMBER := 0;
        v_jubret                    NUMBER := 0;
        v_jubpen                    NUMBER := 0;
        v_recibebol                 VARCHAR2(1000 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal.id_cia := pin_id_cia;
        rec_personal.codper := o.get_string('codper');
        rec_personal.apepat := o.get_string('apepat');
        rec_personal.apemat := o.get_string('apemat');
        rec_personal.nombre := o.get_string('nombre');
        rec_personal.direcc := o.get_string('direcc');
        rec_personal.nrotlf := o.get_string('nrotlf');
        rec_personal.sexper := o.get_string('sexper');
        rec_personal.fecnac := o.get_date('fecnac');
        rec_personal.codeci := o.get_string('codeci'); -- CODIGO DE ESTADO CIVIL
        rec_personal.tiptra := o.get_string('tiptra'); -- TIP TRABAJADOR
        rec_personal.codnac := o.get_string('codnac'); -- CODIGO DE NACIONALIDAD
        rec_personal.codcar := o.get_string('codcar'); -- CODIGO DE CARGO
        rec_personal_periodolaboral.finicio := o.get_date('finicio');
        rec_personal_periodolaboral.ffinal := o.get_date('ffinal');
        rec_personal.forpag := o.get_string('forpag'); -- FORMA DE PAGO
        rec_personal.codban := o.get_number('codban'); -- CODBAN
        rec_personal.tipcta := o.get_number('tipcta'); -- TIPO DE CUENTA
        rec_personal.codmon := o.get_string('codmon'); -- MONEDA
        rec_personal.nrocta := o.get_string('nrocta'); -- NRO DE CUENTA
        rec_personal.situac := o.get_string('situac');
        rec_personal.codest := o.get_string('codest');
        rec_personal.codafp := o.get_string('codafp');
        rec_personal.codsuc := o.get_number('codsuc');
        rec_personal.email := o.get_string('email');
        rec_personal_ccosto.codcco := o.get_string('codcco');
        rec_personal_ccosto.prcdis := o.get_number('prcdis');
        v_jubinv := o.get_number('jubinv');
        v_trab65 := o.get_number('trab65');
        v_jubret := o.get_number('jubret');
        v_jubpen := o.get_number('jubpen');
        reg_errores.orden := rec_personal.codper;
        reg_errores.concepto := rec_personal.apepat
                                || ' '
                                || rec_personal.apemat
                                || ' '
                                || rec_personal.nombre;

        BEGIN
            SELECT
                p.codper
            INTO rec_personal.codper
            FROM
                personal p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.codper = rec_personal.codper;

            reg_errores.valor := rec_personal.codper;
            reg_errores.deserror := 'YA EXISTE UN PERSONAL REGISTRADO CON ESTE CODIGO';
            PIPE ROW ( reg_errores );
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

        IF rec_personal_periodolaboral.ffinal < TO_DATE ( '01/01/00', 'DD/MM/YY' ) THEN
            reg_errores.valor := to_char(rec_personal_periodolaboral.ffinal, 'DD/MM/YY');
            reg_errores.deserror := 'FECHA NO VALIDA FINAL, FECHA DEBE SER MAYOR AL 01/01/00';
            PIPE ROW ( reg_errores );
        END IF;

        IF rec_personal.sexper NOT IN ( 'M', 'F' ) THEN
            reg_errores.valor := rec_personal.sexper;
            reg_errores.deserror := 'SEXO DEL PERSONAL NO VALIDO';
            PIPE ROW ( reg_errores );
        END IF;

        IF rec_personal.forpag NOT IN ( 'E', 'C', 'D' ) THEN
            reg_errores.valor := rec_personal.forpag;
            reg_errores.deserror := 'FORMA DE PAGO NO VALIDO';
            PIPE ROW ( reg_errores );
        END IF;

        IF nvl(rec_personal.codsuc, 0) <= 0 THEN
            reg_errores.valor := rec_personal.codsuc;
            reg_errores.deserror := 'CODIGO DE SUCURSAL NO VALIDO';
            PIPE ROW ( reg_errores );
        END IF;

        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                estado_civil
            WHERE
                    id_cia = rec_personal.id_cia
                AND codeci = rec_personal.codeci;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := to_char(rec_personal.codeci);
                reg_errores.deserror := 'CODIGO DE ESTADO CIVIL NO VALIDO O NO DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                tipo_trabajador
            WHERE
                    id_cia = rec_personal.id_cia
                AND tiptra = rec_personal.tiptra;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := to_char(rec_personal.tiptra);
                reg_errores.deserror := 'CODIGO DE TIPO DE TRABAJADOR NO VALIDO O NO DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                nacionalidad
            WHERE
                    id_cia = rec_personal.id_cia
                AND codnac = rec_personal.codnac;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := to_char(rec_personal.codnac);
                reg_errores.deserror := 'CODIGO DE NACIONALIDAD NO VALIDO O NO DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                cargo
            WHERE
                    id_cia = rec_personal.id_cia
                AND codcar = rec_personal.codcar;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := to_char(rec_personal.codcar);
                reg_errores.deserror := 'CODIGO DE CARGO NO VALIDO O NO DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

        IF nvl(rec_personal.forpag, 'ND') NOT IN ( 'E', 'C', 'D' ) THEN
            reg_errores.valor := nvl(rec_personal.forpag, 'ND');
            reg_errores.deserror := 'LA FORMA DE PAGO, SOLO PUEDE ESTAR DEFINIDA COMO E, C O D ( EFECTIVO, CHEQUE O DEPOSITO )';
            PIPE ROW ( reg_errores );
        END IF;

        IF nvl(rec_personal.tipcta, 0) <> 0 THEN
            BEGIN
                SELECT
                    1
                INTO v_aux
                FROM
                    e_financiera
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codigo = rec_personal.codban
                    AND situac = 'S';

            EXCEPTION
                WHEN no_data_found THEN
                    reg_errores.valor := to_char(rec_personal.codban);
                    reg_errores.deserror := 'LA ENTIDAD FINANCIERA NO VALIDA (NO ACTIVA*) O NO DEFINIDA';
                    PIPE ROW ( reg_errores );
            END;

            BEGIN
                SELECT
                    1
                INTO v_aux
                FROM
                    e_financiera_tipo
                WHERE
                        id_cia = rec_personal.id_cia
                    AND tipcta = rec_personal.tipcta;

            EXCEPTION
                WHEN no_data_found THEN
                    reg_errores.valor := to_char(rec_personal.tipcta);
                    reg_errores.deserror := 'EL TIPO DE ENTIDAD FINANCIERA NO VALIDA O NO DEFINIDO';
                    PIPE ROW ( reg_errores );
            END;

        END IF;

        IF rec_personal.codmon IS NOT NULL THEN
            BEGIN
                SELECT
                    1
                INTO v_aux
                FROM
                    tmoneda
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codmon = rec_personal.codmon;

            EXCEPTION
                WHEN no_data_found THEN
                    reg_errores.valor := rec_personal.codmon;
                    reg_errores.deserror := 'EL TIPO DE MONEDA NO VALIDA O NO DEFINIDO';
                    PIPE ROW ( reg_errores );
            END;
        END IF;

        IF
            nvl(rec_personal.forpag, 'ND') = 'D'
            AND nvl(rec_personal.nrocta, 'ND') = 'ND'
        THEN
            reg_errores.valor := nvl(rec_personal.nrocta, 'ND');
            reg_errores.deserror := 'SI LA FORMA DE PAGO ES POR DEPOSITO, EL NUMERO DE CUENTA DEBE ESTAR DEFINIDO';
            PIPE ROW ( reg_errores );
        END IF;

        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                situacion_personal
            WHERE
                    id_cia = rec_personal.id_cia
                AND codsit = rec_personal.situac;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal.situac;
                reg_errores.deserror := 'SITUACION NO VALIDA O NO DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                estado_personal
            WHERE
                    id_cia = rec_personal.id_cia
                AND codest = rec_personal.codest;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal.codest;
                reg_errores.deserror := 'CODIGO DE ESTADO NO VALIDO O NO DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                afp
            WHERE
                    id_cia = rec_personal.id_cia
                AND codafp = rec_personal.codafp;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal.codafp;
                reg_errores.deserror := 'CODIGO DE AFP NO VALIDA O NO DEFINIDA';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                tccostos
            WHERE
                    id_cia = rec_personal.id_cia
                AND codigo = rec_personal_ccosto.codcco;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal_ccosto.codcco;
                reg_errores.deserror := 'CENTRO DE COSTO NO VALIDO O NO DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

        IF nvl(rec_personal_ccosto.prcdis, 0) > 100 THEN
            reg_errores.valor := to_char(nvl(rec_personal_ccosto.prcdis, 0));
            reg_errores.deserror := 'EL PORCENTAJE DE DISTRIBUCION DEL CENTRO DE COSTO NO PUEDE SER MAYOR AL 100%';
            PIPE ROW ( reg_errores );
        END IF;

        IF nvl(rec_personal_ccosto.prcdis, 0) <= 0 THEN
            reg_errores.valor := to_char(nvl(rec_personal_ccosto.prcdis, 0));
            reg_errores.deserror := 'EL PORCENTAJE DE DISTRIBUCION DEL CENTRO DE COSTO NO PUEDE SER 0 O NULO';
            PIPE ROW ( reg_errores );
        END IF;

        rec_personal_documento.codigo := o.get_string('tident');
        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                clase_codigo_personal
            WHERE
                    id_cia = rec_personal.id_cia
                AND clase = 3
                AND codigo = rec_personal_documento.codigo;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal_documento.codigo;
                reg_errores.deserror := 'TIPO DE DOCUMENTO IDENTIDAD SEGUN SUNAT NO VALIDO O NO DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

        rec_personal_clase.codigo := o.get_string('tiptrasunat');
        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                clase_codigo_personal
            WHERE
                    id_cia = rec_personal.id_cia
                AND clase = 8
                AND codigo = rec_personal_clase.codigo;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal_clase.codigo;
                reg_errores.deserror := 'TIPO DE TRABAJADOR SEGUN SUNAT NO VALIDA O NO DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

        rec_personal_clase.codigo := o.get_string('regpensunat');
        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                clase_codigo_personal
            WHERE
                    id_cia = rec_personal.id_cia
                AND clase = 11
                AND codigo = rec_personal_clase.codigo;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal_clase.codigo;
                reg_errores.deserror := 'TIPO DE REGIMEN PENSIONARIO SEGUN SUNAT NO VALIDA O NO DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

        rec_personal_clase.codigo := o.get_string('tipcontsunat');
        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                clase_codigo_personal
            WHERE
                    id_cia = rec_personal.id_cia
                AND clase = 12
                AND codigo = rec_personal_clase.codigo;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal_clase.codigo;
                reg_errores.deserror := 'TIPO DE CONTRATO SEGUN SUNAT NO VALIDA O NO DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

        rec_personal_clase.codigo := o.get_string('tippagsunat');
        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                clase_codigo_personal
            WHERE
                    id_cia = rec_personal.id_cia
                AND clase = 16
                AND codigo = rec_personal_clase.codigo;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal_clase.codigo;
                reg_errores.deserror := 'TIPO DE PAGO SEGUN SUNAT NO VALIDA O NO DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

        rec_personal_clase.codigo := o.get_string('ocutrasunat');
        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                clase_codigo_personal
            WHERE
                    id_cia = rec_personal.id_cia
                AND clase = 24
                AND codigo = rec_personal_clase.codigo;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal_clase.codigo;
                reg_errores.deserror := 'TIPO DE OCUPACION SEGUN SUNAT NO VALIDA O NO DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

        rec_personal_clase.codigo := o.get_string('tipdocafp');
        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                clase_codigo_personal
            WHERE
                    id_cia = rec_personal.id_cia
                AND clase = 1001
                AND codigo = rec_personal_clase.codigo;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal_clase.codigo;
                reg_errores.deserror := 'TIPO DE DOCUMENTO DE INDENTIDAD DE AFP NO VALIDA O NO DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

        rec_personal_cts.codban := o.get_number('codbancts');
        rec_personal_cts.tipcta := o.get_number('tipctacts');
        rec_personal_cts.codmon := o.get_string('codmoncts');
        rec_personal_cts.cuenta := o.get_string('cuentacts');
        IF
            nvl(rec_personal_cts.tipcta, 0) <> 0
            AND rec_personal_cts.codmon IS NOT NULL
            AND rec_personal_cts.cuenta IS NOT NULL
        THEN
            BEGIN
                SELECT
                    1
                INTO v_aux
                FROM
                    e_financiera
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codigo = rec_personal_cts.codban
                    AND situac = 'S';

            EXCEPTION
                WHEN no_data_found THEN
                    reg_errores.valor := to_char(rec_personal_cts.codban);
                    reg_errores.deserror := 'LA ENTIDAD FINANCIERA DE CTS NO VALIDA (NO ACTIVA*) O NO DEFINIDA';
                    PIPE ROW ( reg_errores );
            END;

            BEGIN
                SELECT
                    1
                INTO v_aux
                FROM
                    e_financiera_tipo
                WHERE
                        id_cia = rec_personal.id_cia
                    AND tipcta = rec_personal_cts.tipcta;

            EXCEPTION
                WHEN no_data_found THEN
                    reg_errores.valor := to_char(rec_personal_cts.tipcta);
                    reg_errores.deserror := 'EL TIPO DE ENTIDAD FINANCIERA DE CTS NO VALIDA O NO DEFINIDO';
                    PIPE ROW ( reg_errores );
            END;

            BEGIN
                SELECT
                    1
                INTO v_aux
                FROM
                    tmoneda
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codmon = rec_personal_cts.codmon;

            EXCEPTION
                WHEN no_data_found THEN
                    reg_errores.valor := rec_personal_cts.codmon;
                    reg_errores.deserror := 'EL TIPO DE MONEDA DE CTS NO VALIDA O NO DEFINIDO';
                    PIPE ROW ( reg_errores );
            END;

        END IF;

        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                factor_clase_planilla
            WHERE
                    id_cia = rec_personal.id_cia
                AND codfac = '418'
                AND codcla = rec_personal.tiptra
                AND tipcla = 1
                AND tipvar = 'S';

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := '418';
                reg_errores.deserror := 'EL FACTOR 418 NO TIENE LA CLASE DEFINIDA PARA EL TIPO DE TRABAJADOR [ '
                                        || rec_personal.tiptra
                                        || ' ] , PARA LA ASIGNACION DEL CONCEPTO POR JUBILACION POR INVALIDEZ';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                factor_clase_planilla
            WHERE
                    id_cia = rec_personal.id_cia
                AND codfac = '420'
                AND codcla = rec_personal.tiptra
                AND tipcla = 1
                AND tipvar = 'S';

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := '420';
                reg_errores.deserror := 'EL FACTOR 418 NO TIENE LA CLASE DEFINIDA PARA EL TIPO DE TRABAJADOR [ '
                                        || rec_personal.tiptra
                                        || ' ] , PARA LA ASIGNACION DEL CONCEPTO POR JUBILACION POR  TRABAJADOR DE MAS DE 65 AÑOS';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                factor_clase_planilla
            WHERE
                    id_cia = rec_personal.id_cia
                AND codfac = '423'
                AND codcla = rec_personal.tiptra
                AND tipcla = 1
                AND tipvar = 'S';

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := '423';
                reg_errores.deserror := 'EL FACTOR 418 NO TIENE LA CLASE DEFINIDA PARA EL TIPO DE TRABAJADOR [ '
                                        || rec_personal.tiptra
                                        || ' ] , PARA LA ASIGNACION DEL CONCEPTO POR JUBILACION POR RETENCION DE FONDO';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                factor_clase_planilla
            WHERE
                    id_cia = rec_personal.id_cia
                AND codfac = '425'
                AND codcla = rec_personal.tiptra
                AND tipcla = 1
                AND tipvar = 'S';

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := '425';
                reg_errores.deserror := 'EL FACTOR 418 NO TIENE LA CLASE DEFINIDA PARA EL TIPO DE TRABAJADOR [ '
                                        || rec_personal.tiptra
                                        || ' ] , PARA LA ASIGNACION DEL CONCEPTO POR JUBILACION POR PENSION';
                PIPE ROW ( reg_errores );
        END;

        IF nvl(v_jubinv, 0) NOT IN ( 0, 1 ) THEN
            reg_errores.valor := v_jubinv;
            reg_errores.deserror := 'EL TIPO DE EXONERACION (JUBILACION POR INVALIDEZ) DE APORTACION A LA AFP, NO VALIDO!';
            PIPE ROW ( reg_errores );
        END IF;

        IF nvl(v_trab65, 0) NOT IN ( 0, 1 ) THEN
            reg_errores.valor := v_trab65;
            reg_errores.deserror := 'EL TIPO DE EXONERACION (TRABAJADOR CON MAS DE 65 AÑOS) DE APORTACION A LA AFP, NO VALIDO!';
            PIPE ROW ( reg_errores );
        END IF;

        IF nvl(v_jubret, 0) NOT IN ( 0, 1 ) THEN
            reg_errores.valor := v_jubret;
            reg_errores.deserror := 'EL TIPO DE EXONERACION (JUBILACION POR RETENCION DE FONDO) DE APORTACION A LA AFP, NO VALIDO!';
            PIPE ROW ( reg_errores );
        END IF;

        IF nvl(v_jubpen, 0) NOT IN ( 0, 1 ) THEN
            reg_errores.valor := v_jubpen;
            reg_errores.deserror := 'EL TIPO DE EXONERACION (JUBILADO POR PENSION) DE APORTACION A LA AFP, NO VALIDO!';
            PIPE ROW ( reg_errores );
        END IF;

        v_recibebol := o.get_string('recibebol');
        IF nvl(v_recibebol, 'ND') NOT IN ( 'S', 'N' ) THEN
            reg_errores.valor := nvl(v_recibebol, 'ND');
            reg_errores.deserror := 'RECIBE BOLETAS POR EMAIL, SOLO RECIBE EL VALOR [ N ] O [ S ]';
            PIPE ROW ( reg_errores );
        END IF;

        IF
            TRIM(rec_personal.email) IS NULL
            AND nvl(v_recibebol, 'ND') = 'S'
        THEN
            reg_errores.valor := nvl(v_recibebol, 'ND');
            reg_errores.deserror := 'RECIBE BOLETAS POR EMAIL SOLO PUEDE ESTAR ACTIVO ( S ), SI SE ESPECIFICA UN EMAIL PARA EL TRABAJADOR'
            ;
            PIPE ROW ( reg_errores );
        END IF;

    END sp_valida_objeto;

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                           json_object_t;
        rec_personal                personal%rowtype;
        rec_personal_periodolaboral personal_periodolaboral%rowtype;
        rec_personal_documento      personal_documento%rowtype;
        rec_personal_concepto       personal_concepto%rowtype;
        rec_personal_cts            personal_cts%rowtype;
        rec_personal_clase          personal_clase%rowtype;
        rec_personal_ccosto         personal_ccosto%rowtype;
        m                           json_object_t;
        pout_mensaje                VARCHAR2(1000 CHAR);
        v_number                    NUMBER := 0;
        v_mensaje                   VARCHAR2(1000 CHAR);
        v_jubinv                    NUMBER := 0;
        v_trab65                    NUMBER := 0;
        v_jubret                    NUMBER := 0;
        v_jubpen                    NUMBER := 0;
        v_recibebol                 VARCHAR2(1000 CHAR);
    BEGIN
        v_number := extract(MONTH FROM current_timestamp);
        o := json_object_t.parse(pin_datos);
        rec_personal.id_cia := pin_id_cia;
        rec_personal.codper := o.get_string('codper');
        rec_personal.apepat := o.get_string('apepat');
        rec_personal.apemat := o.get_string('apemat');
        rec_personal.nombre := o.get_string('nombre');
        rec_personal.direcc := o.get_string('direcc');
        rec_personal.nrotlf := o.get_string('nrotlf');
        rec_personal.sexper := o.get_string('sexper');
        rec_personal.fecnac := o.get_date('fecnac');
        rec_personal.codeci := o.get_string('codeci'); -- CODIGO DE ESTADO CIVIL
        rec_personal.tiptra := o.get_string('tiptra'); -- TIP TRABAJADOR
        rec_personal.codnac := o.get_string('codnac'); -- CODIGO DE NACIONALIDAD
        rec_personal.codcar := o.get_string('codcar'); -- CODIGO DE CARGO
        rec_personal_periodolaboral.finicio := o.get_date('finicio');
        rec_personal_periodolaboral.ffinal := o.get_date('ffinal');
        rec_personal.forpag := o.get_string('forpag'); -- FORMA DE PAGO
        rec_personal.codban := o.get_number('codban'); -- CODBAN
        rec_personal.tipcta := o.get_number('tipcta'); -- TIPO DE CUENTA
        rec_personal.codmon := o.get_string('codmon'); -- MONEDA
        rec_personal.nrocta := o.get_string('nrocta'); -- NRO DE CUENTA
        rec_personal.situac := o.get_string('situac');
        rec_personal.codest := o.get_string('codest');
        rec_personal.glonot := NULL;
        rec_personal.codafp := o.get_string('codafp');
        rec_personal.fotogr := NULL;
        rec_personal.formato := NULL;
        rec_personal.codsuc := o.get_number('codsuc');
        rec_personal.email := o.get_string('email');
        rec_personal.ucreac := pin_coduser;
        rec_personal.uactua := pin_coduser;
        rec_personal.fcreac := TO_TIMESTAMP ( to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS' );
        rec_personal.factua := TO_TIMESTAMP ( to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS' );
        -- INSERTANDO PERSONAL
        INSERT INTO personal (
            id_cia,
            codper,
            apepat,
            apemat,
            nombre,
            direcc,
            nrotlf,
            sexper,
            fecnac,
            codeci,
            tiptra,
            codnac,
            codcar,
            forpag,
            codban,
            nrocta,
            tipcta,
            codmon,
            situac,
            codest,
            glonot,
            codafp,
            fotogr,
            formato,
            codsuc,
            email,
            ucreac,
            uactua,
            fcreac,
            factua
        ) VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            rec_personal.apepat,
            rec_personal.apemat,
            rec_personal.nombre,
            rec_personal.direcc,
            rec_personal.nrotlf,
            rec_personal.sexper,
            rec_personal.fecnac,
            rec_personal.codeci,
            rec_personal.tiptra,
            rec_personal.codnac,
            rec_personal.codcar,
            rec_personal.forpag,
            rec_personal.codban,
            rec_personal.nrocta,
            rec_personal.tipcta,
            rec_personal.codmon,
            rec_personal.situac,
            rec_personal.codest,
            rec_personal.glonot,
            rec_personal.codafp,
            rec_personal.fotogr,
            rec_personal.formato,
            rec_personal.codsuc,
            rec_personal.email,
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );

        -- INSERTANDO PERIODO LABORAL
        INSERT INTO personal_periodolaboral VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            1,
            rec_personal_periodolaboral.finicio,
            rec_personal_periodolaboral.ffinal,
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );

        -- INSERTANDO REGIMEN DE PENSIONES
        INSERT INTO personal_periodo_rpension VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            rec_personal.codafp,
            1,
            rec_personal_periodolaboral.finicio,
            rec_personal_periodolaboral.ffinal,
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );

        -- INSERTANDO PERSONAL DOCUMENTO
        rec_personal_documento.codtip := 'DO';
        rec_personal_documento.codite := 201;
        rec_personal_documento.nrodoc := o.get_string('dident');
        rec_personal_documento.clase := 3;
        rec_personal_documento.codigo := o.get_string('tident');
        INSERT INTO personal_documento VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            rec_personal_documento.codtip,
            rec_personal_documento.codite,
            rec_personal_documento.nrodoc,
            rec_personal_documento.clase,
            rec_personal_documento.codigo,
            'S',
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );

        rec_personal_documento.codite := 204;
        rec_personal_documento.nrodoc := o.get_string('nroseg'); -- NUMERO DE SEGURO    
        INSERT INTO personal_documento VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            rec_personal_documento.codtip,
            rec_personal_documento.codite,
            rec_personal_documento.nrodoc,
            NULL,
            NULL,
            'S',
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );

        rec_personal_documento.codite := 205;
        rec_personal_documento.nrodoc := o.get_string('nrocup'); -- NUMERO DE CUSPP
        INSERT INTO personal_documento VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            rec_personal_documento.codtip,
            rec_personal_documento.codite,
            rec_personal_documento.nrodoc,
            NULL,
            NULL,
            'S',
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );

        rec_personal_documento.codite := 209;
        rec_personal_documento.nrodoc := o.get_string('nrotra'); -- TRATAMIENTO
        INSERT INTO personal_documento VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            rec_personal_documento.codtip,
            rec_personal_documento.codite,
            rec_personal_documento.nrodoc,
            NULL,
            NULL,
            'S',
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );
        -- CONCEPTOS FIJOS
        rec_personal_concepto.codcon := '001';
        rec_personal_concepto.valcon := nvl(o.get_number('ingmen'), 0);
        FOR i IN 0..v_number LOOP
            INSERT INTO personal_concepto VALUES (
                rec_personal.id_cia,
                rec_personal.codper,
                rec_personal_concepto.codcon,
                EXTRACT(YEAR FROM current_timestamp),
                i,
                rec_personal_concepto.valcon,
                rec_personal.ucreac,
                rec_personal.uactua,
                rec_personal.fcreac,
                rec_personal.factua
            );

        END LOOP;

        rec_personal_concepto.codcon := '002';
        rec_personal_concepto.valcon := nvl(o.get_number('asgfam'), 0);
        FOR i IN 0..v_number LOOP
            INSERT INTO personal_concepto VALUES (
                rec_personal.id_cia,
                rec_personal.codper,
                rec_personal_concepto.codcon,
                EXTRACT(YEAR FROM current_timestamp),
                i,
                rec_personal_concepto.valcon,
                rec_personal.ucreac,
                rec_personal.uactua,
                rec_personal.fcreac,
                rec_personal.factua
            );

        END LOOP;

        rec_personal_cts.codban := o.get_number('codbancts');
        rec_personal_cts.tipcta := o.get_number('tipctacts');
        rec_personal_cts.codmon := o.get_string('codmoncts');
        rec_personal_cts.cuenta := o.get_string('cuentacts');
        IF
            rec_personal_cts.codban IS NOT NULL
            AND nvl(rec_personal_cts.tipcta, 0) <> 0
            AND rec_personal_cts.codmon IS NOT NULL
            AND rec_personal_cts.cuenta IS NOT NULL
        THEN
        -- PERSONAL CTS
            INSERT INTO personal_cts VALUES (
                rec_personal.id_cia,
                rec_personal.codper,
                rec_personal_cts.codban,
                rec_personal_cts.tipcta,
                rec_personal_cts.codmon,
                rec_personal_cts.cuenta,
                rec_personal.ucreac,
                rec_personal.uactua,
                rec_personal.fcreac,
                rec_personal.factua
            );

        END IF;
        -- PERSONAL CLASE
        rec_personal_clase.clase := 8;
        rec_personal_clase.codigo := o.get_string('tiptrasunat');
        INSERT INTO personal_clase VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            rec_personal_clase.clase,
            rec_personal_clase.codigo,
            'S',
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );

        rec_personal_clase.clase := 11;
        rec_personal_clase.codigo := o.get_string('regpensunat');
        INSERT INTO personal_clase VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            rec_personal_clase.clase,
            rec_personal_clase.codigo,
            'S',
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );

        rec_personal_clase.clase := 12;
        rec_personal_clase.codigo := o.get_string('tipcontsunat');
        INSERT INTO personal_clase VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            rec_personal_clase.clase,
            rec_personal_clase.codigo,
            'S',
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );

        rec_personal_clase.clase := 16;
        rec_personal_clase.codigo := o.get_string('tippagsunat');
        INSERT INTO personal_clase VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            rec_personal_clase.clase,
            rec_personal_clase.codigo,
            'S',
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );

        rec_personal_clase.clase := 24;
        rec_personal_clase.codigo := o.get_string('ocutrasunat');
        INSERT INTO personal_clase VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            rec_personal_clase.clase,
            rec_personal_clase.codigo,
            'S',
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );

        rec_personal_clase.clase := 1001;
        rec_personal_clase.codigo := o.get_string('tipdocafp');
        INSERT INTO personal_clase VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            rec_personal_clase.clase,
            rec_personal_clase.codigo,
            'S',
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );

        -- CONCEPTOS FIJOS
        rec_personal_concepto.codcon := '307';
        rec_personal_concepto.valcon := nvl(o.get_number('tipcom'), 0);
        FOR i IN 0..v_number LOOP
            INSERT INTO personal_concepto VALUES (
                rec_personal.id_cia,
                rec_personal.codper,
                rec_personal_concepto.codcon,
                EXTRACT(YEAR FROM current_timestamp),
                i,
                rec_personal_concepto.valcon,
                rec_personal.ucreac,
                rec_personal.uactua,
                rec_personal.fcreac,
                rec_personal.factua
            );

        END LOOP;
        -- CONCEPTOS FIJOS
        rec_personal_concepto.codcon := '308';
        rec_personal_concepto.valcon := nvl(o.get_number('afieps'), 0);
        FOR i IN 0..v_number LOOP
            INSERT INTO personal_concepto VALUES (
                rec_personal.id_cia,
                rec_personal.codper,
                rec_personal_concepto.codcon,
                EXTRACT(YEAR FROM current_timestamp),
                i,
                rec_personal_concepto.valcon,
                rec_personal.ucreac,
                rec_personal.uactua,
                rec_personal.fcreac,
                rec_personal.factua
            );

        END LOOP;
        -- CONCEPTOS FIJOS
        rec_personal_concepto.codcon := '026';
        rec_personal_concepto.valcon := nvl(o.get_number('essvid'), 0);
        FOR i IN 0..v_number LOOP
            INSERT INTO personal_concepto VALUES (
                rec_personal.id_cia,
                rec_personal.codper,
                rec_personal_concepto.codcon,
                EXTRACT(YEAR FROM current_timestamp),
                i,
                rec_personal_concepto.valcon,
                rec_personal.ucreac,
                rec_personal.uactua,
                rec_personal.fcreac,
                rec_personal.factua
            );

        END LOOP;
        -- CONCEPTOS FIJOS
        rec_personal_concepto.codcon := '210';
        rec_personal_concepto.valcon := nvl(o.get_number('retjud'), 0);
        FOR i IN 0..v_number LOOP
            INSERT INTO personal_concepto VALUES (
                rec_personal.id_cia,
                rec_personal.codper,
                rec_personal_concepto.codcon,
                EXTRACT(YEAR FROM current_timestamp),
                i,
                rec_personal_concepto.valcon,
                rec_personal.ucreac,
                rec_personal.uactua,
                rec_personal.fcreac,
                rec_personal.factua
            );

        END LOOP;
        -- CONCEPTOS FIJOS
        rec_personal_concepto.codcon := '020';
        rec_personal_concepto.valcon := nvl(o.get_number('modfij'), 0);
        FOR i IN 0..v_number LOOP
            INSERT INTO personal_concepto VALUES (
                rec_personal.id_cia,
                rec_personal.codper,
                rec_personal_concepto.codcon,
                EXTRACT(YEAR FROM current_timestamp),
                i,
                rec_personal_concepto.valcon,
                rec_personal.ucreac,
                rec_personal.uactua,
                rec_personal.fcreac,
                rec_personal.factua
            );

        END LOOP;
        -- CONCEPTOS FIJOS
        rec_personal_concepto.codcon := '082';
        rec_personal_concepto.valcon := nvl(o.get_number('comfij'), 0);
        FOR i IN 0..v_number LOOP
            INSERT INTO personal_concepto VALUES (
                rec_personal.id_cia,
                rec_personal.codper,
                rec_personal_concepto.codcon,
                EXTRACT(YEAR FROM current_timestamp),
                i,
                rec_personal_concepto.valcon,
                rec_personal.ucreac,
                rec_personal.uactua,
                rec_personal.fcreac,
                rec_personal.factua
            );

        END LOOP;
        -- CONCEPTOS FIJOS
        rec_personal_concepto.codcon := '120';
        rec_personal_concepto.valcon := nvl(o.get_number('aferet'), 0);
        FOR i IN 0..v_number LOOP
            INSERT INTO personal_concepto VALUES (
                rec_personal.id_cia,
                rec_personal.codper,
                rec_personal_concepto.codcon,
                EXTRACT(YEAR FROM current_timestamp),
                i,
                rec_personal_concepto.valcon,
                rec_personal.ucreac,
                rec_personal.uactua,
                rec_personal.fcreac,
                rec_personal.factua
            );

        END LOOP;
        --- PERSONAL CCOSTO
        rec_personal_ccosto.codcco := o.get_string('codcco');
        rec_personal_ccosto.prcdis := o.get_number('prcdis');
        INSERT INTO personal_ccosto VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            rec_personal_ccosto.codcco,
            rec_personal_ccosto.prcdis,
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );

        v_jubinv := nvl(o.get_number('jubinv'), 0);
        v_trab65 := nvl(o.get_number('trab65'), 0);
        v_jubret := nvl(o.get_number('jubret'), 0);
        v_jubpen := nvl(o.get_number('jubpen'), 0);
        FOR i IN 0..v_number LOOP
            INSERT INTO personal_concepto VALUES (
                rec_personal.id_cia,
                rec_personal.codper,
                pack_hr_planilla_plame.sp_concepto_tiptra(rec_personal.id_cia, '418', rec_personal.tiptra),
                EXTRACT(YEAR FROM current_timestamp),
                i,
                v_jubinv,
                rec_personal.ucreac,
                rec_personal.uactua,
                rec_personal.fcreac,
                rec_personal.factua
            );

            INSERT INTO personal_concepto VALUES (
                rec_personal.id_cia,
                rec_personal.codper,
                pack_hr_planilla_plame.sp_concepto_tiptra(rec_personal.id_cia, '420', rec_personal.tiptra),
                EXTRACT(YEAR FROM current_timestamp),
                i,
                v_trab65,
                rec_personal.ucreac,
                rec_personal.uactua,
                rec_personal.fcreac,
                rec_personal.factua
            );

            INSERT INTO personal_concepto VALUES (
                rec_personal.id_cia,
                rec_personal.codper,
                pack_hr_planilla_plame.sp_concepto_tiptra(rec_personal.id_cia, '423', rec_personal.tiptra),
                EXTRACT(YEAR FROM current_timestamp),
                i,
                v_jubret,
                rec_personal.ucreac,
                rec_personal.uactua,
                rec_personal.fcreac,
                rec_personal.factua
            );

            INSERT INTO personal_concepto VALUES (
                rec_personal.id_cia,
                rec_personal.codper,
                pack_hr_planilla_plame.sp_concepto_tiptra(rec_personal.id_cia, '425', rec_personal.tiptra),
                EXTRACT(YEAR FROM current_timestamp),
                i,
                v_jubpen,
                rec_personal.ucreac,
                rec_personal.uactua,
                rec_personal.fcreac,
                rec_personal.factua
            );

        END LOOP;

        -- PERSONAL CLASE
        rec_personal_clase.clase := 1100; -- ENVIO DE BOLETAS
        rec_personal_clase.codigo := o.get_string('recibebol');
        INSERT INTO personal_clase VALUES (
            rec_personal.id_cia,
            rec_personal.codper,
            rec_personal_clase.clase,
            rec_personal_clase.codigo,
            'S',
            rec_personal.ucreac,
            rec_personal.uactua,
            rec_personal.fcreac,
            rec_personal.factua
        );

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'El proceso completó correctamente.'
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

--            ROLLBACK;
        WHEN OTHERS THEN
            pin_mensaje := 'PERSONAL : '
                           || rec_personal.codper
                           || ' mensaje : '
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

            ROLLBACK;
    END sp_importar;

END;

/
