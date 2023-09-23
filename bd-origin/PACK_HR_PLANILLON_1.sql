--------------------------------------------------------
--  DDL for Package Body PACK_HR_PLANILLON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PLANILLON" AS

    FUNCTION sp_buscar_conceptos_personal (
        pin_id_cia IN NUMBER,
        pin_numpla IN NUMBER,
        pin_codper IN VARCHAR2,
        pin_varfij VARCHAR2
    ) RETURN datatable_buscar_conceptos_personal
        PIPELINED
    AS
        v_table datatable_buscar_conceptos_personal;
    BEGIN
        SELECT
            'C' || pc.codcon,
            pc.valcon
        BULK COLLECT
        INTO v_table
        FROM
                 planilla_concepto pc
            INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                     AND c.codcon = pc.codcon
                                     AND c.fijvar = pin_varfij
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.numpla = pin_numpla
            AND pc.codper = pin_codper
            AND pc.situac = 'S';

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_conceptos_personal;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numpla NUMBER
    ) RETURN datatable_planillon
        PIPELINED
    AS
        v_table datatable_planillon;
    BEGIN
        SELECT DISTINCT
            pc.id_cia,
            pc.numpla,
            srp.cantid  AS indfec,
            sp.cantid   AS indpre,
            pc.codper,
            p.apepat,
            p.apemat,
            p.nombre,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre AS nomper,
            (
                SELECT
                    JSON_OBJECTAGG(cc.codcon VALUE cc.valcon ABSENT ON NULL)
                FROM
                    pack_hr_planillon.sp_buscar_conceptos_personal(pin_id_cia, pin_numpla, p.codper, 'V') cc
            )           AS concepto
        BULK COLLECT
        INTO v_table
        FROM
                 planilla_concepto pc
            INNER JOIN personal                                                             p ON p.id_cia = pc.id_cia
                                     AND p.codper = pc.codper
            LEFT OUTER JOIN pack_hr_planillon.sp_prestamo(pc.id_cia, pc.numpla, pc.codper)       sp ON 0 = 0
            LEFT OUTER JOIN pack_hr_planillon.sp_planilla_rango(pc.id_cia, pc.numpla, pc.codper) srp ON 0 = 0
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.numpla = pin_numpla
            AND pc.situac = 'S'
        ORDER BY
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_columnado (
        pin_id_cia NUMBER,
        pin_numpla NUMBER
    ) RETURN datatable_concepto
        PIPELINED
    AS
        v_table datatable_concepto;
    BEGIN
        SELECT DISTINCT
            pc.id_cia,
            pc.numpla,
            c.codcon,
            c.abrevi,
            c.nombre
        BULK COLLECT
        INTO v_table
        FROM
                 planilla_concepto pc
            INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                     AND pc.codcon = c.codcon
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.numpla = pin_numpla
            AND c.fijvar = 'V';

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_columnado;

    FUNCTION sp_prestamo (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_prestamo
        PIPELINED
    AS
        v_rec datarecord_prestamo := datarecord_prestamo(NULL);
    BEGIN
        SELECT
            COUNT(0)
        INTO v_rec.cantid
        FROM
            planilla_saldoprestamo psp
        WHERE
                psp.id_cia = pin_id_cia
            AND psp.numpla = pin_numpla
            AND psp.codper = pin_codper
            AND psp.situac = 'S';

        PIPE ROW ( v_rec );
        RETURN;
    END sp_prestamo;

    FUNCTION sp_planilla_rango (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_planilla_rango
        PIPELINED
    AS
        v_rec datarecord_planilla_rango := datarecord_planilla_rango(NULL);
    BEGIN
        SELECT
            COUNT(0)
        INTO v_rec.cantid
        FROM
            planilla_rango psp
        WHERE
                psp.id_cia = pin_id_cia
            AND psp.numpla = pin_numpla
            AND psp.codper = pin_codper;

        PIPE ROW ( v_rec );
        RETURN;
    END sp_planilla_rango;

    PROCEDURE sp_eliminar (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_codper  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        pout_mensaje  VARCHAR2(1000 CHAR);
        v_formula     VARCHAR2(1000 CHAR);
        v_aux_formula VARCHAR2(1000 CHAR);
        v_valor       VARCHAR2(1000 CHAR);
        v_mensaje     VARCHAR2(1000) := '';
        m             json_object_t;
    BEGIN
--        UPDATE planilla_concepto
--        SET
--            situac = 'N',
--            uactua = pin_coduser,
--            factua = current_timestamp
--        WHERE
--                id_cia = pin_id_cia
--            AND numpla = pin_numpla
--            AND codper = pin_codper;
--
--        UPDATE planilla_resumen
--        SET
--            situac = 'N',
--            uactua = pin_coduser,
--            factua = current_timestamp
--        WHERE
--                id_cia = pin_id_cia
--            AND numpla = pin_numpla
--            AND codper = pin_codper;
--
--        UPDATE planilla_saldoprestamo
--        SET
--            situac = 'N',
--            uactua = pin_coduser,
--            factua = current_timestamp
--        WHERE
--                id_cia = pin_id_cia
--            AND numpla = pin_numpla
--            AND codper = pin_codper;
--
--        UPDATE dsctoprestamo
--        SET
--            aplica = 'N',
--            uactua = pin_coduser,
--            factua = current_timestamp
--        WHERE
--                id_cia = pin_id_cia
--            AND numpla = pin_numpla
--            AND codper = pin_codper;
--
--        UPDATE planilla_auxiliar
--        SET
--            situac = 'N',
--            uactua = pin_coduser,
--            factua = current_timestamp
--        WHERE
--                id_cia = pin_id_cia
--            AND numpla = pin_numpla
--            AND codper = pin_codper;
--
--        UPDATE planilla_afp
--        SET
--            situac = 'N',
--            uactua = pin_coduser,
--            factua = current_timestamp
--        WHERE
--                id_cia = pin_id_cia
--            AND numpla = pin_numpla
--            AND codper = pin_codper;

        -- PROCESANDO CONCEPTO DE PRESTAMO
        FOR k IN (
            SELECT
                pc.codper,
                pc.codcon
            FROM
                     planilla_concepto pc
                INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                         AND c.codcon = pc.codcon
                                         AND c.fijvar = 'P'
            WHERE
                    pc.id_cia = pin_id_cia
                AND pc.numpla = pin_numpla
                AND pc.codper = pin_codper
        ) LOOP
            pack_hr_planilla_formula.sp_decodificar_cprestamo(pin_id_cia, pin_numpla, k.codper, k.codcon, 'S',
                                                             pin_coduser, k.codcon, v_formula, v_aux_formula, v_valor,
                                                             v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END LOOP;

        DELETE planilla_concepto
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla
            AND codper = pin_codper;

        DELETE planilla_resumen
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla
            AND codper = pin_codper;

        DELETE planilla_saldoprestamo
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla
            AND codper = pin_codper;

        DELETE dsctoprestamo
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla
            AND codper = pin_codper;

        DELETE planilla_auxiliar
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla
            AND codper = pin_codper;

        DELETE planilla_afp
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla
            AND codper = pin_codper;

        DELETE planilla_rango
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla
            AND codper = pin_codper;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Succes ...!'
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
    END sp_eliminar;

END;

/
