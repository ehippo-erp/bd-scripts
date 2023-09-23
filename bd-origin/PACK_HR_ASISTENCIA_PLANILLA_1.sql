--------------------------------------------------------
--  DDL for Package Body PACK_HR_ASISTENCIA_PLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_ASISTENCIA_PLANILLA" AS
    FUNCTION sp_reporte_mtur (
        pin_id_cia  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN NUMBER AS
        v_aux NUMBER;
    BEGIN
        SELECT
            apt.mintur
        INTO v_aux
        FROM
            personal_turno_planilla   ptp
            LEFT OUTER JOIN asistencia_planilla_turno apt ON apt.id_cia = ptp.id_cia
                                                             AND apt.id_turno = ptp.id_turno
        WHERE
                ptp.id_cia = pin_id_cia
            AND ptp.codper = pin_coduser
        ORDER BY
            length(apt.dia) DESC
        FETCH NEXT 1 ROWS ONLY;

        RETURN v_aux;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN 0;
    END sp_reporte_mtur;

    FUNCTION sp_reporte_mref (
        pin_id_cia  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN NUMBER AS
        v_aux NUMBER;
    BEGIN
        SELECT
            apt.minref
        INTO v_aux
        FROM
            personal_turno_planilla   ptp
            LEFT OUTER JOIN asistencia_planilla_turno apt ON apt.id_cia = ptp.id_cia
                                                             AND apt.id_turno = ptp.id_turno
        WHERE
                ptp.id_cia = pin_id_cia
            AND ptp.codper = pin_coduser
        ORDER BY
            length(apt.dia) DESC
        FETCH NEXT 1 ROWS ONLY;

        RETURN v_aux;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN 0;
    END sp_reporte_mref;

    FUNCTION sp_reporte (
        pin_id_cia  NUMBER,
        pin_coduser VARCHAR2,
        pin_fdesde  DATE,
        pin_fhasta  DATE
    ) RETURN datatable_reporte
        PIPELINED
    AS

        v_table  datatable_reporte;
    BEGIN
        SELECT
            pin_id_cia,
            to_char(t.fecha, 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH') AS mes,
            to_char(t.fecha, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')   AS diasemana,
            t.fecha                                                AS fecha,
            p1.codper,
            p1.apepat
            || ' '
            || p1.apemat
            || ' '
            || p1.nombre                                           AS nomper,
            pd.nrodoc,
            ccp.descri                                             AS desdoc,
            p1.codcar,
            car.nombre                                             AS descar,
            nvl(mp.descri, ' '),
            apt.desturn,
            pack_hr_asistencia_planilla.sp_reporte_mtur(p1.id_cia,p1.codper) / 60                                               AS hortur,
            pack_hr_asistencia_planilla.sp_reporte_mref(p1.id_cia,p1.codper) / 60                                               AS horref,
            ap1.codper                                             AS uentrada,
            to_char(
                CASE
                    WHEN(dextra1.ajustado -(apt.toletur / 60)) < 0 THEN
                        TO_TIMESTAMP(to_char(ap1.fregis, 'DD/MM/YY')
                                     || ' '
                                     || to_char(apt.hingtur, 'HH24:MI:SS'),
                                     'DD/MM/YY HH24:MI:SS')
                    ELSE
                        ap1.fregis
                END,
                'HH24:MI:SS')                                  AS fentrada,
            ap2.codper                                             AS usalida,
            to_char(ap2.fregis, 'HH24:MI:SS')                      AS fsalida,
            to_char(apr1.fregis, 'HH24:MI:SS')                     AS rentrada,
            to_char(
                CASE
                    WHEN((rextra2.ajustado -(apt.toleref / 60)) < 0
                         AND apr2.fregis IS NOT NULL) THEN
                        TO_TIMESTAMP(to_char(apr2.fregis, 'DD/MM/YY')
                                     || ' '
                                     || to_char(apt.hsalref, 'HH24:MI:SS'),
                                     'DD/MM/YY HH24:MI:SS')
                    ELSE
                        apr2.fregis
                END,
                'HH24:MI:SS')                                  AS rsalida,
            CASE
                WHEN dextra2.ajustado > 0 THEN
                    (
                        SELECT
                            ajustado
                        FROM
                            pack_ayuda_general.sp_difhor_string(apt.hsaltur, ap2.fregis)
                    )
                ELSE
                    '00:00:00'
            END,
            CASE
                WHEN dextra2.ajustado > 0 THEN
                    dextra2.ajustado
                ELSE
                    0.00
            END
        BULK COLLECT
        INTO v_table
        FROM
            tiempo                                                        t
            LEFT OUTER JOIN personal                                                      p1 ON p1.id_cia = pin_id_cia
                                           AND p1.situac = '01'
            LEFT OUTER JOIN asistencia_planilla                                           ap1 ON ap1.id_cia = pin_id_cia
                                                       AND trunc(ap1.fregis) = t.fecha
                                                       AND ap1.tipo = 'I'
                                                       AND ap1.codper = p1.codper
                                                       AND ap1.codmot <> 2
            LEFT OUTER JOIN asistencia_planilla                                           ap2 ON ap2.id_cia = pin_id_cia
                                                       AND trunc(ap2.fregis) = t.fecha
                                                       AND ap2.codper = ap1.codper
                                                       AND ap2.id_turno = ap1.id_turno
                                                       AND ap2.tipo = 'S'
                                                       AND ap2.codmot <> 2
            LEFT OUTER JOIN asistencia_planilla_turno                                     apt ON apt.id_cia = pin_id_cia
                                                             AND apt.id_turno = ap1.id_turno
            LEFT OUTER JOIN asistencia_planilla                                           apr1 ON apr1.id_cia = pin_id_cia
                                                        AND trunc(apr1.fregis) = t.fecha
                                                        AND apr1.tipo = ap1.tipo
                                                        AND apr1.codper = ap1.codper
                                                        AND apr1.id_turno = ap1.id_turno
                                                        AND apt.incref = 'S'
                                                        AND apr1.codmot = 2
            LEFT OUTER JOIN asistencia_planilla                                           apr2 ON apr2.id_cia = pin_id_cia
                                                        AND trunc(apr2.fregis) = t.fecha
                                                        AND apr2.tipo = ap2.tipo
                                                        AND apr2.codper = ap1.codper
                                                        AND apr2.id_turno = ap1.id_turno
                                                        AND apt.incref = 'S'
                                                        AND apr2.codmot = 2
            LEFT OUTER JOIN motivo_planilla                                               mp ON mp.id_cia = pin_id_cia
                                                  AND mp.codmot = ap1.codmot
            LEFT OUTER JOIN cargo                                                         car ON car.id_cia = p1.id_cia
                                         AND car.codcar = p1.codcar
            LEFT OUTER JOIN pack_ayuda_general.sp_difhor_number(apt.hingtur, ap1.fregis)  dextra1 ON 0 = 0
            LEFT OUTER JOIN pack_ayuda_general.sp_difhor_number(apt.hsaltur, ap2.fregis)  dextra2 ON 0 = 0
            LEFT OUTER JOIN pack_ayuda_general.sp_difhor_number(apt.hsalref, apr2.fregis) rextra2 ON 0 = 0
            LEFT OUTER JOIN personal_documento                                            pd ON pd.id_cia = p1.id_cia
                                                     AND pd.codper = p1.codper
                                                     AND pd.codtip = 'DO'
                                                     AND pd.codite = 201 -- DOCUMENTO IDENTIDAD
            LEFT OUTER JOIN clase_codigo_personal                                         ccp ON ccp.id_cia = p1.id_cia
                                                         AND ccp.clase = 3
                                                         AND ccp.codigo = pd.codigo
        WHERE
            t.fecha BETWEEN pin_fdesde AND pin_fhasta
            AND ( pin_coduser IS NULL
                  OR p1.codper = pin_coduser )
        ORDER BY
            p1.apepat ASC,
            p1.apemat ASC,
            P1.nombre ASC,
            t.fecha ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte;

    FUNCTION sp_turno (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_turno
        PIPELINED
    AS
        v_table datatable_turno;
    BEGIN
        SELECT
            ptp.id_cia,
            ptp.id_turno,
            apt.desturn
        BULK COLLECT
        INTO v_table
        FROM
            personal_turno_planilla   ptp
            LEFT OUTER JOIN asistencia_planilla_turno apt ON apt.id_cia = ptp.id_cia
                                                             AND apt.id_turno = ptp.id_turno
        WHERE
                ptp.id_cia = pin_id_cia
            AND ptp.codper = pin_codper;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_turno;

    FUNCTION sp_obtener (
        pin_id_cia   NUMBER,
        pin_codasist NUMBER
    ) RETURN datatable_asistencia_planilla
        PIPELINED
    AS
        v_table datatable_asistencia_planilla;
    BEGIN
        SELECT
            ap.id_cia,
            ap.codasist,
            ap.codsuc,
            s.sucursal,
            ap.codper,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre AS nomper,
            ap.fecha,
            to_char(ap.hora, 'HH:MI:SS'),
            ap.fregis,
            ap.tipo,
            CASE
                WHEN ap.tipo = 'I' THEN
                    'INGRESO'
                WHEN ap.tipo = 'S' THEN
                    'SALIDA'
                ELSE
                    'ND'
            END         AS destipo,
            ap.codmot,
            mp.descri   AS desmot,
            ap.id_turno,
            apt.desturn,
            ap.flagmarca,
            CASE
                WHEN ap.flagmarca = 'A' THEN
                    'AUTOMATICO'
                WHEN ap.flagmarca = 'G' THEN
                    'GLOBAL'
                ELSE
                    'ND'
            END         AS desmarca,
            ap.situac,
            ap.direcc,
            ap.latitud,
            ap.longitud,
            ap.ucreac,
            ap.uactua,
            ap.fcreac,
            ap.factua
        BULK COLLECT
        INTO v_table
        FROM
            asistencia_planilla       ap
            LEFT OUTER JOIN personal                  p ON p.id_cia = ap.id_cia
                                          AND p.codper = ap.codper
            LEFT OUTER JOIN motivo_planilla           mp ON mp.id_cia = ap.id_cia
                                                  AND mp.codmot = ap.codmot
            LEFT OUTER JOIN asistencia_planilla_turno apt ON apt.id_cia = ap.id_cia
                                                             AND apt.id_turno = ap.id_turno
            LEFT OUTER JOIN sucursal                  s ON s.id_cia = ap.id_cia
                                          AND s.codsuc = ap.codsuc
        WHERE
                ap.id_cia = pin_id_cia
            AND ap.codasist = pin_codasist
            AND ap.situac = 'S';

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codsuc NUMBER,
        pin_codmot NUMBER,
        pin_tiptra VARCHAR2,
        pin_codper VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_asistencia_planilla
        PIPELINED
    AS
        v_table datatable_asistencia_planilla;
    BEGIN
        SELECT
            ap.id_cia,
            ap.codasist,
            ap.codsuc,
            s.sucursal,
            ap.codper,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre AS nomper,
            ap.fecha,
            to_char(ap.hora, 'HH:MI:SS'),
            ap.fregis,
            ap.tipo,
            CASE
                WHEN ap.tipo = 'I' THEN
                    'INGRESO'
                WHEN ap.tipo = 'S' THEN
                    'SALIDA'
                ELSE
                    'ND'
            END         AS destipo,
            ap.codmot,
            mp.descri   AS desmot,
            ap.id_turno,
            apt.desturn,
            ap.flagmarca,
            CASE
                WHEN ap.flagmarca = 'A' THEN
                    'AUTOMATICO'
                WHEN ap.flagmarca = 'G' THEN
                    'GLOBAL'
                ELSE
                    'ND'
            END         AS desmarca,
            ap.situac,
            ap.direcc,
            ap.latitud,
            ap.longitud,
            ap.ucreac,
            ap.uactua,
            ap.fcreac,
            ap.factua
        BULK COLLECT
        INTO v_table
        FROM
            asistencia_planilla       ap
            LEFT OUTER JOIN personal                  p ON p.id_cia = ap.id_cia
                                          AND p.codper = ap.codper
            LEFT OUTER JOIN motivo_planilla           mp ON mp.id_cia = ap.id_cia
                                                  AND mp.codmot = ap.codmot
            LEFT OUTER JOIN asistencia_planilla_turno apt ON apt.id_cia = ap.id_cia
                                                             AND apt.id_turno = ap.id_turno
            LEFT OUTER JOIN sucursal                  s ON s.id_cia = ap.id_cia
                                          AND s.codsuc = ap.codsuc
        WHERE
                ap.id_cia = pin_id_cia
            AND ( trunc(ap.fregis) BETWEEN pin_fdesde AND pin_fhasta )
            AND ap.situac = 'S'
            AND ( pin_codsuc IS NULL
                  OR pin_codsuc = - 1
                  OR ap.codsuc = pin_codsuc )
            AND ( pin_codmot IS NULL
                  OR pin_codmot = - 1
                  OR ap.codmot = pin_codmot )
            AND ( pin_codper IS NULL
                  OR ap.codper = pin_codper );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "codasist":2,
--                "codsuc":1,
--                "codper":"P008",
--                "fecha":"2022-11-07",
--                "hora":"2022-11-07T11:07:15.00",
--                "fregis":"2022-11-07T11:07:15.00",
--                "tipo":"I",
--                "codmot":1,
--                "id_turno":1,
--                "flagmarca":"A",
--                "direcc":"DIRECCION 01 LOTE 50",
--                "latitud":"",
--                "longitud":"",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--
--pack_hr_asistencia_planilla.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_asistencia_planilla.sp_obtener(66, 2);
--
--SELECT * FROM pack_hr_asistencia_planilla.sp_buscar(66, 1, 1, 'E', NULL,
--TO_DATE('01/01/2022', 'DD/MM/YYYY'), TO_DATE('01/01/2023', 'DD/MM/YYYY'));
--                                          
--SELECT * FROM pack_hr_asistencia_planilla.sp_reporte(25,NULL,
--to_date('08/11/2022','DD/MM/YYYY'),to_date('01/12/2022','DD/MM/YYYY'));

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                       json_object_t;
        rec_asistencia_planilla asistencia_planilla%rowtype;
        pout_mensaje            VARCHAR2(1000);
        v_codasist              asistencia_planilla.codasist%TYPE;
        v_desmot                motivo_planilla.descri%TYPE;
        v_desturn               asistencia_planilla_turno.desturn%TYPE;
        v_destip                VARCHAR2(20) := '';
        v_dessuc                VARCHAR2(200) := '';
        v_namegenerador         VARCHAR2(60);
        v_dias                  VARCHAR2(1000);
        v_aux                   VARCHAR2(1);
        v_accion                VARCHAR2(50) := '';
        v_diasemana             NUMBER;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_asistencia_planilla.id_cia := pin_id_cia;
        rec_asistencia_planilla.codasist := o.get_string('codasist');
        rec_asistencia_planilla.codsuc := o.get_number('codsuc');
        rec_asistencia_planilla.codper := o.get_string('codper');
        rec_asistencia_planilla.fecha := trunc(o.get_date('fecha'));
        rec_asistencia_planilla.hora := o.get_timestamp('hora');
        rec_asistencia_planilla.fregis := o.get_timestamp('fregis');
        rec_asistencia_planilla.tipo := o.get_string('tipo');
        rec_asistencia_planilla.codmot := o.get_number('codmot');
        rec_asistencia_planilla.id_turno := o.get_number('id_turno');
        rec_asistencia_planilla.flagmarca := o.get_string('flagmarca');
        rec_asistencia_planilla.situac := 'S';
        rec_asistencia_planilla.direcc := o.get_string('direcc');
        rec_asistencia_planilla.latitud := o.get_number('latitud');
        rec_asistencia_planilla.longitud := o.get_number('longitud');
        rec_asistencia_planilla.ucreac := o.get_string('ucreac');
        rec_asistencia_planilla.uactua := o.get_string('uactua');
        IF rec_asistencia_planilla.fecha IS NULL THEN
            rec_asistencia_planilla.fecha := trunc(current_timestamp);
        END IF;

        IF rec_asistencia_planilla.hora IS NULL THEN
            rec_asistencia_planilla.hora := current_timestamp;
        END IF;
        IF rec_asistencia_planilla.fregis IS NULL THEN
            rec_asistencia_planilla.fregis := current_timestamp;
        END IF;
        v_diasemana := TO_NUMBER ( to_char(TO_DATE(rec_asistencia_planilla.fecha, 'DD/MM/YYYY'),
                                           'D',
                                           'NLS_DATE_LANGUAGE=SPANISH') );

        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                IF rec_asistencia_planilla.id_turno = 0 THEN
                    pout_mensaje := 'Los campos CODIGO DEL PERSONAL, TIPO, MOTIVO y TURNO son obligatorios ...!';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

                BEGIN
                    SELECT
                        dia
                    INTO v_dias
                    FROM
                        asistencia_planilla_turno
                    WHERE
                            id_cia = pin_id_cia
                        AND id_turno = rec_asistencia_planilla.id_turno;

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'El TURNO ingresado no existe, revisar la configuración';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                BEGIN
                    SELECT
                        'S'
                    INTO v_aux
                    FROM
                        dual
                    WHERE
                        v_diasemana NOT IN (
                            SELECT
                                *
                            FROM
                                convert_in ( v_dias )
                        );

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'El TURNO selecionado no corresponde con el dia de semana actual [ '
                                        || upper(to_char(rec_asistencia_planilla.fecha, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH'))
                                        || ' ], revisar la configuracion';

--                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                v_accion := 'La inserción';
                INSERT INTO asistencia_planilla (
                    id_cia,
                    codasist,
                    codsuc,
                    codper,
                    fecha,
                    hora,
                    fregis,
                    tipo,
                    codmot,
                    id_turno,
                    flagmarca,
                    situac,
                    direcc,
                    latitud,
                    longitud,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_asistencia_planilla.id_cia,
                    - 1,
                    rec_asistencia_planilla.codsuc,
                    rec_asistencia_planilla.codper,
                    rec_asistencia_planilla.fecha,
                    rec_asistencia_planilla.hora,
                    rec_asistencia_planilla.fregis,
                    rec_asistencia_planilla.tipo,
                    rec_asistencia_planilla.codmot,
                    rec_asistencia_planilla.id_turno,
                    rec_asistencia_planilla.flagmarca,
                    rec_asistencia_planilla.situac,
                    rec_asistencia_planilla.direcc,
                    rec_asistencia_planilla.latitud,
                    rec_asistencia_planilla.longitud,
                    rec_asistencia_planilla.ucreac,
                    rec_asistencia_planilla.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                BEGIN
                    v_namegenerador := upper('GEN_ASISTENCIA_PLANILLA_')
                                       || pin_id_cia;
                    EXECUTE IMMEDIATE 'select '
                                      || v_namegenerador
                                      || '.CURRVAL FROM DUAL'
                    INTO v_codasist;
                END;

            WHEN 2 THEN
                v_accion := 'La actualización';
--                UPDATE ASISTENCIA_PLANILLA
--                SET
--                    uactua =
--                        CASE
--                            WHEN rec_ASISTENCIA_PLANILLA.uactua IS NULL THEN
--                                uactua
--                            ELSE
--                                rec_ASISTENCIA_PLANILLA.uactua
--                        END,
--                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
--                WHERE
--                        id_cia = rec_ASISTENCIA_PLANILLA.id_cia
--                    AND codasist = rec_ASISTENCIA_PLANILLA.codasist;
                NULL;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                v_codasist := rec_asistencia_planilla.codasist;
                UPDATE asistencia_planilla
                SET
                    situac = 'N',
                    uactua =
                        CASE
                            WHEN rec_asistencia_planilla.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_asistencia_planilla.uactua
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_asistencia_planilla.id_cia
                    AND codasist = rec_asistencia_planilla.codasist;

        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!',
                'codasist' VALUE v_codasist
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
        WHEN dup_val_on_index THEN
CASE
    WHEN rec_asistencia_planilla.tipo = 'I' THEN
        v_destip := 'INGRESO';
    WHEN rec_asistencia_planilla.tipo = 'S' THEN
        v_destip := 'SALIDA';
    ELSE
        v_destip := 'ND';
END CASE;

BEGIN
    SELECT
        descri
    INTO v_desmot
    FROM
        motivo_planilla
    WHERE
            id_cia = pin_id_cia
        AND codmot = rec_asistencia_planilla.codmot;

EXCEPTION
    WHEN no_data_found THEN
        v_desmot := 'ND';
END;

BEGIN
    SELECT
        sucursal
    INTO v_dessuc
    FROM
        sucursal
    WHERE
            id_cia = pin_id_cia
        AND codsuc = rec_asistencia_planilla.codsuc;

EXCEPTION
    WHEN no_data_found THEN
        v_desmot := 'ND';
        end;
        BEGIN
            SELECT
                desturn
            INTO v_desturn
            FROM
                asistencia_planilla_turno
            WHERE
                    id_cia = pin_id_cia
                AND id_turno = rec_asistencia_planilla.id_turno;

        EXCEPTION
            WHEN no_data_found THEN
                v_desturn := 'ND';
                end;
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                                'message' VALUE 'El registro de asistencia en la SUCURSAL [ '
                                                || v_dessuc
                                                   || ' ] del PERSONAL [ '
                                                      || rec_asistencia_planilla.codper
                                                         || ' ], para la FECHA [ '
                                                            || to_char(rec_asistencia_planilla.fecha, 'DD/MM/YYYY')
                                                               || ' ],  TIPO [ '
                                                                  || v_destip
                                                                     || ' ], MOTIVO [ '
                                                                        || v_desmot
                                                                           || ' ] y TURNO [ '
                                                                              || v_desturn
                                                                                 || ' ] ya existe y no puede duplicarse ...!'
                    )
                INTO pin_mensaje
                FROM
                    dual;

            WHEN value_error THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.2,
                        'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
                    )
                INTO pin_mensaje
                FROM
                    dual;

            WHEN pkg_exceptionuser.ex_error_inesperado THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE pout_mensaje
                    )
                INTO pin_mensaje
                FROM
                    dual;

            WHEN OTHERS THEN
                IF sqlcode = -1400 THEN
                    SELECT
                        JSON_OBJECT(
                            'status' VALUE 1.1,
                            'message' VALUE 'Los campos CODIGO DEL PERSONAL, TIPO, MOTIVO y TURNO son obligatorios ...!'
                        )
                    INTO pin_mensaje
                    FROM
                        dual;

                ELSIF sqlcode = -2291 THEN
                    SELECT
                        JSON_OBJECT(
                            'status' VALUE 1.1,
                            'message' VALUE 'No se insertar o modificar este registro porque el Concepto [ '
                                            || rec_asistencia_planilla.codasist
                                               || ' ] o porque el Codigo de Personal [ '
                                                  || rec_asistencia_planilla.codper
                                                     || ' ] no existe ...! '
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
        END sp_save;

END;

/
