--------------------------------------------------------
--  DDL for Package Body PACK_HR_PLANILLA_CONCEPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PLANILLA_CONCEPTO" AS

    FUNCTION sp_buscar_personal (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_planilla_concepto_personal
        PIPELINED
    AS
        v_table datatable_planilla_concepto_personal;
    BEGIN
        SELECT
            pc.id_cia,
            pc.numpla,
            pc.codper,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre,
            p.codafp,
            afp.nombre,
            pl.finicio,
            pl.ffinal,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
            planilla_resumen                                                           pc
            LEFT OUTER JOIN planilla                                                                   l ON l.id_cia = pc.id_cia
                                          AND l.numpla = pc.numpla
            LEFT OUTER JOIN personal                                                                   p ON p.id_cia = pc.id_cia
                                          AND p.codper = pc.codper
            LEFT OUTER JOIN afp                                                                        afp ON afp.id_cia = p.id_cia
                                       AND afp.codafp = p.codafp
            LEFT OUTER JOIN pack_hr_personal.sp_periodolaboral(p.id_cia, l.empobr, l.fecini, l.fecfin) pl ON pl.id_cia = p.id_cia
                                                                                                             AND pl.codper = p.codper
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.numpla = pin_numpla
            AND ( pin_codper IS NULL
                  OR pc.codper = pin_codper )
        ORDER BY
            p.apepat ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_personal;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2,
        pin_codcon VARCHAR2
    ) RETURN datatable_obtener
        PIPELINED
    AS
        v_table datatable_obtener;
    BEGIN
        SELECT
            pc.id_cia,
            pc.numpla,
            pc.codper,
            pc.codcon,
            pc.valcon
        BULK COLLECT
        INTO v_table
        FROM
            planilla_concepto pc
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.numpla = pin_numpla
            AND pc.codper = pin_codper
            AND pc.codcon = pin_codcon;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2,
        pin_ingdes VARCHAR2,
        pin_fijvar VARCHAR2,
        pin_idliq  VARCHAR2,
        pin_codcon VARCHAR2
    ) RETURN datatable_planilla_concepto
        PIPELINED
    AS
        v_table datatable_planilla_concepto;
    BEGIN
        SELECT
            pc.id_cia,
            pc.numpla,
            pc.codper,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre,
            pc.codcon,
            c.abrevi,
            c.nombre,
            c.ingdes,
            c1.dingdes,
            c.fijvar,
            c2.dfijvar,
            c.idliq,
            c3.didliq,
            pc.valcon,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
            planilla_concepto                              pc
            LEFT OUTER JOIN personal                                       p ON p.id_cia = pc.id_cia
                                          AND p.codper = pc.codper
            LEFT OUTER JOIN concepto                                       c ON c.id_cia = pc.id_cia
                                          AND c.codcon = pc.codcon
            LEFT OUTER JOIN pack_hr_concepto.sp_buscar_ingdes ( c.id_cia ) c1 ON c1.id_cia = c.id_cia
                                                                                 AND c1.ingdes = c.ingdes
            LEFT OUTER JOIN pack_hr_concepto.sp_buscar_fijvar ( c.id_cia ) c2 ON c2.id_cia = c.id_cia
                                                                                 AND c2.fijvar = c.fijvar
            LEFT OUTER JOIN pack_hr_concepto.sp_buscar_idliq ( c.id_cia )  c3 ON c3.id_cia = c.id_cia
                                                                                AND c3.idliq = c.idliq
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.numpla = pin_numpla
            AND ( pin_codper IS NULL
                  OR pc.codper = pin_codper )
            AND ( pin_ingdes IS NULL
                  OR c.ingdes = pin_ingdes )
            AND ( pin_fijvar IS NULL
                  OR c.fijvar = pin_fijvar )
            AND ( pin_idliq IS NULL
                  OR c.idliq = pin_idliq )
            AND ( pin_codcon IS NULL
                  OR pc.codcon = pin_codcon );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_json (
        pin_json VARCHAR2
    ) RETURN datatable_json
        PIPELINED
    AS
        --{"C004":0,"C011":10,"C012":0,"C036":0,"C027":3,"C306":0}
        rec_json datarecord_json;
        v_go     VARCHAR2(1 CHAR) := '';
        v_notgo  VARCHAR2(1 CHAR) := '';
        v_char   VARCHAR2(1 CHAR) := '';
        v_aux    NUMBER := 0;
        v_codcon concepto.codcon%TYPE;
        v_valcon VARCHAR2(10 CHAR) := '';
    BEGIN
        FOR i IN 1..length(pin_json) LOOP
            v_char := substr(pin_json, i, 1);
            IF v_char = ',' OR v_char = '}' THEN
                v_notgo := 'N';
                rec_json.codcon := v_codcon;
                rec_json.valcon := TO_NUMBER ( v_valcon, '999999999999999999.99999' );
                PIPE ROW ( rec_json );
                v_codcon := '';
                v_valcon := '';
            END IF;

            IF v_char = '"' THEN
                v_aux := v_aux + 1;
                IF v_aux = 2 THEN
                    v_go := 'N';
                    v_notgo := 'N';
                    v_aux := 0;
                END IF;

            END IF;

            IF v_go = 'S' THEN
                v_codcon := v_codcon || v_char;
            END IF;
            IF v_notgo = 'S' THEN
                v_valcon := v_valcon || v_char;
            END IF;
            IF
                v_aux = 1
                AND v_char = 'C'
            THEN
                v_go := 'S';
            END IF;
            IF v_char = ':' THEN
                v_notgo := 'S';
            END IF;
        END LOOP;
    END sp_json;

    FUNCTION sp_prevalida_objeto (
        pin_id_cia   NUMBER,
        pin_numpla   NUMBER,
        pin_personal VARCHAR2,
        pin_concepto VARCHAR2
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores  r_errores := r_errores(NULL, NULL);
        m            json_object_t;
        pout_mensaje VARCHAR2(1000);
        v_mensaje    VARCHAR2(1000) := '';
    BEGIN
        pack_hr_planilla.sp_planilla_cerrada(pin_id_cia, pin_numpla, v_mensaje);
        m := json_object_t.parse(v_mensaje);
        IF ( m.get_number('status') <> 1.0 ) THEN
            reg_errores.valor := 'PLANILLA CERRADA';
            reg_errores.deserror := m.get_string('message');
            PIPE ROW ( reg_errores );
        END IF;

        FOR j IN (
            SELECT
                c.codcon,
                COUNT(*)
            FROM
                (
                    SELECT
                        ( 'C'
                          || codcon ) AS codcon
                    FROM
                        pack_hr_planillon.sp_columnado(pin_id_cia, pin_numpla)
                    UNION ALL
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_concepto) )
                ) c
            GROUP BY
                c.codcon
            HAVING
                COUNT(*) <> 2
        ) LOOP
            reg_errores.valor := substr(j.codcon, 2, 5);
            reg_errores.deserror := 'El Concepto [ '
                                    || substr(j.codcon, 2, 5)
                                    || ' ] no existe o fue eliminado de la planilla [ '
                                    || pin_numpla
                                    || ' ]';

            PIPE ROW ( reg_errores );
        END LOOP;

        FOR h IN (
            SELECT
                h.codper,
                COUNT(*)
            FROM
                (
                    SELECT
                        codper
                    FROM
                        pack_hr_planillon.sp_buscar(pin_id_cia, pin_numpla)
                    UNION ALL
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_personal) )
                ) h
            GROUP BY
                h.codper
            HAVING
                COUNT(*) <> 2
        ) LOOP
            reg_errores.valor := h.codper;
            reg_errores.deserror := 'El Personal con Codigo [ '
                                    || h.codper
                                    || ' ] no existe o fue eliminado de la planilla [ '
                                    || pin_numpla
                                    || ' ]';

            PIPE ROW ( reg_errores );
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
--            reg_errores.valor := to_char('ERROR');
--            reg_errores.deserror := 'mensaje : '
--                                    || sqlerrm
--                                    || ' fijvar :'
--                                    || sqlcode;
--            PIPE ROW ( reg_errores );
            NULL;
    END sp_prevalida_objeto;

    FUNCTION sp_valida_objeto (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR,
        pin_datos  CLOB
    ) RETURN datatable
        PIPELINED
    AS
        reg_errores r_errores := r_errores(NULL, NULL);
        o           json_object_t;
    BEGIN
        o := json_object_t.parse(pin_datos);
        FOR i IN (
            SELECT
                codcon,
                valcon
            FROM
                sp_json ( pin_datos )
                --{"C004":0,"C011":10,"C012":0,"C036":0,"C027":3,"C306":0}
        ) LOOP
            IF i.valcon < 0 THEN
                reg_errores.valor := to_char(i.valcon);
                reg_errores.deserror := 'El Valor del Concepto [ '
                                        || i.codcon
                                        || ' ] no puede ser Negativo [ '
                                        || to_char(i.valcon)
                                        || ' ]';

                PIPE ROW ( reg_errores );
            END IF;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
--            reg_errores.valor := to_char(pin_datos);
--            reg_errores.deserror := 'mensaje : '
--                                    || sqlerrm
--                                    || ' fijvar :'
--                                    || sqlcode;
--            PIPE ROW ( reg_errores );
            NULL;
    END sp_valida_objeto;

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_codper  IN VARCHAR2,
        pin_datos   IN CLOB, -- Json en una Fila
        pin_opcdml  IN INTEGER,
        pin_coduser IN VARCHAR2
    ) AS
        o json_object_t;
    BEGIN
        o := json_object_t.parse(pin_datos);
        FOR i IN (
            SELECT
                codcon,
                valcon
            FROM
                sp_json ( pin_datos )
                --{"C004":0,"C011":10,"C012":0,"C036":0,"C027":3,"C306":0}
        ) LOOP
            INSERT INTO planilla_concepto VALUES (
                pin_id_cia,
                pin_numpla,
                pin_codper,
                i.codcon,
                NVL(i.valcon,0),
                'S',
                0,
                pin_coduser,
                pin_coduser,
                current_date,
                current_date
            );

        END LOOP;

    END sp_importar;

    PROCEDURE sp_elimina (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_coduser IN VARCHAR2
    ) AS
    BEGIN
        DELETE FROM planilla_concepto_respaldo
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla;

        FOR i IN (
            SELECT
                pc.id_cia,
                pc.codcon
            FROM
                     planilla_concepto pc
                INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                         AND c.codcon = pc.codcon
            WHERE
                    pc.id_cia = pin_id_cia
                AND pc.numpla = pin_numpla
                AND c.fijvar = 'V'
        ) LOOP
            INSERT INTO planilla_concepto_respaldo
                (
                    SELECT
                        *
                    FROM
                        planilla_concepto
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = pin_numpla
                        AND codcon = i.codcon
                );

            DELETE FROM planilla_concepto
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla
                AND codcon = i.codcon;

        END LOOP;

        COMMIT;
    END sp_elimina;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "numpla":20,
--                "codper":"10150382",
--                "codcon":"004",
--                "valcon":5,
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_planilla_concepto.sp_save(66, cadjson, 2, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_planillon.sp_columnado(66,20);
--
--SELECT * FROM pack_hr_planillon.sp_buscar(66,20);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                     json_object_t;
        m                     json_object_t;
        rec_planilla_concepto planilla_concepto%rowtype;
        v_accion              VARCHAR2(50) := '';
        pout_mensaje          VARCHAR2(1000);
        v_aux                 VARCHAR2(100) := '';
        v_mensaje             VARCHAR2(1000) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_planilla_concepto.id_cia := pin_id_cia;
        rec_planilla_concepto.numpla := o.get_number('numpla');
        rec_planilla_concepto.codper := o.get_string('codper');
        rec_planilla_concepto.codcon := o.get_string('codcon');
        rec_planilla_concepto.valcon := o.get_number('valcon');
        rec_planilla_concepto.ucreac := o.get_string('ucreac');
        rec_planilla_concepto.uactua := o.get_string('uactua');
        v_accion := '';
        pack_hr_planilla.sp_planilla_cerrada(pin_id_cia, rec_planilla_concepto.numpla, v_mensaje);
        m := json_object_t.parse(v_mensaje);
        IF ( m.get_number('status') <> 1.0 ) THEN
            pout_mensaje := m.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        CASE pin_opcdml
--            WHEN 1 THEN
--                v_accion := 'La inserción';
--                INSERT INTO planilla_concepto (
--                    id_cia,
--                    codcon,
--                    
--                    ucreac,
--                    uactua,
--                    fcreac,
--                    factua
--                ) VALUES (
--                    rec_planilla_concepto.id_cia,
--                    rec_planilla_concepto.codcon,
--                    
--                    rec_planilla_concepto.ucreac,
--                    rec_planilla_concepto.uactua,
--                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
--                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
--                );
--

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE planilla_concepto
                SET
                    valcon =
                        CASE
                            WHEN rec_planilla_concepto.valcon IS NULL THEN
                                valcon
                            ELSE
                                rec_planilla_concepto.valcon
                        END,
                    uactua = rec_planilla_concepto.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_planilla_concepto.id_cia
                    AND numpla = rec_planilla_concepto.numpla
                    AND codper = rec_planilla_concepto.codper
                    AND codcon = rec_planilla_concepto.codcon;

--            WHEN 3 THEN
--                v_accion := 'La eliminación no esta Imlementada';
--                DELETE FROM planilla_concepto
--                WHERE
--                        id_cia = rec_planilla_concepto.id_cia
--                    AND codcon = rec_planilla_concepto.codcon;

        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!'
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
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN dup_val_on_index THEN
            NULL;
--            SELECT
--                JSON_OBJECT(
--                    'status' VALUE 1.1,
--                    'message' VALUE 'El registro con codigo de planilla_concepto [ '
--                                    || rec_planilla_concepto.codcon
--                                    || ' ] ya existe y no puede duplicarse ...!'
--                )
--            INTO pin_mensaje
--            FROM
--                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -20049 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.2,
                        'message' VALUE 'Mes cerrado en el Módulo de Planilla'
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSIF sqlcode = -1400 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se insertar o modificar este registro porque no se han registrado todos los campos obligatorios'
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' fijvar :'
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
