--------------------------------------------------------
--  DDL for Package Body PACK_HR_PLANILLA_RANGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PLANILLA_RANGO" AS

    FUNCTION sp_reporte (
        pin_id_cia  NUMBER,
        pin_tiptra  VARCHAR2,
        pin_periodo NUMBER,
        pin_mdesde  NUMBER,
        pin_mhasta  NUMBER,
        pin_codper  VARCHAR2,
        pin_codcon  VARCHAR2
    ) RETURN datatable_reporte
        PIPELINED
    AS
        v_table datatable_reporte;
    BEGIN
        SELECT
            pr.id_cia,
            pr.numpla,
            ( pl.tippla
              || pl.empobr
              || '-'
              || pl.anopla
              || '/'
              || TRIM(to_char(pl.mespla, '00'))
              || '-'
              || pl.sempla )                       AS planilla,
            pl.empobr,
            tt.nombre                            AS destiptra,
            p.codper,
            p.apepat
            || ' '
            || p.apemat
            || ', '
            || p.nombre                          AS nomper,
            pr.codcon,
            c.nombre                             AS descom,
            pr.item,
            pl.anopla                            AS periodo,
            to_char(TO_DATE(pl.mespla, 'MM'),
                    'MONTH',
                    'NLS_DATE_LANGUAGE=SPANISH') AS mes,
            pr.finicio,
            pr.ffinal,
            pr.dias,
            pr.clase,
            cp.descri                            AS desclase,
            pr.codigo,
            ccc.descri                           AS descodigo,
            pr.refere
        BULK COLLECT
        INTO v_table
        FROM
                 planilla_rango pr
            INNER JOIN personal        p ON p.id_cia = pr.id_cia
                                     AND p.codper = pr.codper
            INNER JOIN planilla        pl ON pl.id_cia = pr.id_cia
                                      AND pl.numpla = pr.numpla
            LEFT OUTER JOIN tipo_trabajador tt ON tt.id_cia = pl.id_cia
                                                  AND tt.tiptra = pl.empobr
            INNER JOIN concepto        c ON c.id_cia = pr.id_cia
                                     AND c.codcon = pr.codcon
            LEFT OUTER JOIN clase_personal  cp ON cp.id_cia = c.id_cia
                                                 AND cp.clase = pr.clase
            LEFT OUTER JOIN motivo_planilla ccc ON ccc.id_cia = pr.id_cia
                                                   AND ccc.codrel = pr.codigo
        WHERE
                p.id_cia = pin_id_cia
            AND ( pin_codper IS NULL
                  OR p.codper = pin_codper )
            AND pr.codcon = pin_codcon
            AND EXISTS (
                SELECT
                    pl1.*
                FROM
                    planilla pl1
                WHERE
                        pl1.id_cia = pl.id_cia
                    AND pl1.numpla = pl.numpla
                    AND pl1.empobr = pin_tiptra
                    AND pl1.anopla = pin_periodo
                    AND pl1.mespla BETWEEN pin_mdesde AND pin_mhasta
            )
        ORDER BY
            p.apepat,
            p.apemat,
            p.nombre,
            pl.anopla,
            pl.mespla,
            pr.codcon,
            pr.item;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2,
        pin_codcon VARCHAR2,
        pin_item   NUMBER
    ) RETURN datatable_planilla_rango
        PIPELINED
    AS
        v_table datatable_planilla_rango;
    BEGIN
        SELECT
            pr.id_cia,
            pr.numpla,
            ( p.tippla
              || p.empobr
              || '-'
              || p.anopla
              || '/'
              || TRIM(to_char(p.mespla, '00'))
              || '-'
              || p.sempla ) AS planilla,
            pr.codper,
            pe.apepat
            || ' '
            || pe.apemat
            || ' '
            || pe.nombre  AS nomper,
            pr.codcon,
            c.nombre      AS descon,
            pr.item,
            pr.finicio,
            pr.ffinal,
            pr.dias,
            pr.clase,
            cp.descri     AS desclase,
            pr.codigo,
            ccc.descri    AS descodigo,
            pr.refere,
            pr.ucreac,
            pr.uactua,
            pr.fcreac,
            pr.factua
        BULK COLLECT
        INTO v_table
        FROM
                 planilla_rango pr
            INNER JOIN planilla        p ON p.id_cia = pr.id_cia
                                     AND p.numpla = pr.numpla
            INNER JOIN concepto        c ON c.id_cia = pr.id_cia
                                     AND c.codcon = pr.codcon
            INNER JOIN personal        pe ON pe.id_cia = pr.id_cia
                                      AND pe.codper = pr.codper
            LEFT OUTER JOIN motivo_planilla ccc ON ccc.id_cia = pr.id_cia
                                                   AND ccc.codrel = pr.codigo
--            LEFT OUTER JOIN clase_concepto_codigo ccc ON ccc.id_cia = pr.id_cia
--                                                         AND ccc.clase = 14
--                                                         AND ccc.codigo = pr.codigo
            LEFT OUTER JOIN clase_personal  cp ON cp.id_cia = c.id_cia
                                                 AND cp.clase = pr.clase
        WHERE
                pr.id_cia = pin_id_cia
            AND pr.numpla = pin_numpla
            AND pr.codper = pin_codper
            AND pr.codcon = pin_codcon
            AND pr.item = pin_item;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2,
        pin_codcon VARCHAR2
    ) RETURN datatable_planilla_rango
        PIPELINED
    AS
        v_table datatable_planilla_rango;
    BEGIN
        SELECT
            pr.id_cia,
            pr.numpla,
            ( p.tippla
              || p.empobr
              || '-'
              || p.anopla
              || '/'
              || TRIM(to_char(p.mespla, '00'))
              || '-'
              || p.sempla ) AS planilla,
            pr.codper,
            pe.apepat
            || ' '
            || pe.apemat
            || ' '
            || pe.nombre  AS nomper,
            pr.codcon,
            c.nombre      AS descon,
            pr.item,
            pr.finicio,
            pr.ffinal,
            pr.dias,
            pr.clase,
            cp.descri     AS desclase,
            pr.codigo,
            ccc.descri    AS descodigo,
            pr.refere,
            pr.ucreac,
            pr.uactua,
            pr.fcreac,
            pr.factua
        BULK COLLECT
        INTO v_table
        FROM
                 planilla_rango pr
            INNER JOIN planilla        p ON p.id_cia = pr.id_cia
                                     AND p.numpla = pr.numpla
            INNER JOIN concepto        c ON c.id_cia = pr.id_cia
                                     AND c.codcon = pr.codcon
            INNER JOIN personal        pe ON pe.id_cia = pr.id_cia
                                      AND pe.codper = pr.codper
            LEFT OUTER JOIN motivo_planilla ccc ON ccc.id_cia = pr.id_cia
                                                   AND ccc.codrel = pr.codigo
--            LEFT OUTER JOIN clase_concepto_codigo ccc ON ccc.id_cia = pr.id_cia
--                                                         AND ccc.clase = 14
--                                                         AND ccc.codigo = pr.codigo
            LEFT OUTER JOIN clase_personal  cp ON cp.id_cia = c.id_cia
                                                 AND cp.clase = pr.clase
        WHERE
                pr.id_cia = pin_id_cia
            AND ( pin_numpla IS NULL
                  OR pr.numpla = pin_numpla )
            AND ( pin_codper IS NULL
                  OR pr.codper = pin_codper )
            AND ( pin_codcon IS NULL
                  OR pr.codcon = pin_codcon );

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
--                "numpla":1,
--                "codper":"42788135",
--                "codcon":"385",
--                "item":"",
--                "finicio":"2022-01-01",
--                "ffinal":"2023-01-01",
--                "dias":5,
--                "clase":8,
--                "codigo":"21",
--                "refere":"Prueba",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_planilla_rango.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_planilla_rango.sp_obtener(66,1,'42788135','385',1);
--
--SELECT * FROM pack_hr_planilla_rango.sp_buscar(66,1,'42788135','385');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                  json_object_t;
        rec_planilla_rango planilla_rango%rowtype;
        rec_planilla       planilla%rowtype;
        v_accion           VARCHAR2(50) := '';
        pout_mensaje       VARCHAR2(1000 CHAR) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_planilla_rango.id_cia := pin_id_cia;
        rec_planilla_rango.numpla := o.get_number('numpla');
        rec_planilla_rango.codper := o.get_string('codper');
        rec_planilla_rango.codcon := o.get_string('codcon');
        rec_planilla_rango.item := o.get_number('item');
        rec_planilla_rango.finicio := o.get_date('finicio');
        rec_planilla_rango.ffinal := o.get_date('ffinal');
        BEGIN
            SELECT
                fecini,
                fecfin
            INTO
                rec_planilla.fecini,
                rec_planilla.fecfin
            FROM
                planilla
            WHERE
                    id_cia = pin_id_cia
                AND numpla = rec_planilla_rango.numpla;

        END;

        IF trunc(rec_planilla_rango.finicio) < trunc(rec_planilla.fecini) OR trunc(rec_planilla_rango.ffinal) > trunc(rec_planilla.fecfin
        ) THEN
            pout_mensaje := 'LA FECHA de INICIO y FINAL del registro debe estar contenido en el RANGO DE LA PLANILLA [ '
                            || to_char(rec_planilla.fecini, 'DD/MM/YY')
                            || ' - '
                            || to_char(rec_planilla.fecfin, 'DD/MM/YY')
                            || ' ] ...!';

            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        rec_planilla_rango.dias := o.get_number('dias');
        IF rec_planilla_rango.dias < 0 THEN
            pout_mensaje := 'La FECHA DE INCIO [ '
                            || to_char(rec_planilla_rango.finicio, 'DD/MM/YY')
                            || ' ] no puede ser mayor que la FECHA DE SALIDA [ '
                            || to_char(rec_planilla_rango.ffinal, 'DD/MM/YY')
                            || ' ] ...!';

            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        rec_planilla_rango.clase := o.get_number('clase');
        rec_planilla_rango.codigo := o.get_string('codigo');
        rec_planilla_rango.refere := o.get_string('refere');
        rec_planilla_rango.ucreac := o.get_string('ucreac');
        rec_planilla_rango.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                BEGIN
                    SELECT
                        ( nvl(item, 0) + 1 )
                    INTO rec_planilla_rango.item
                    FROM
                        planilla_rango
                    WHERE
                            id_cia = rec_planilla_rango.id_cia
                        AND numpla = rec_planilla_rango.numpla
                        AND codper = rec_planilla_rango.codper
                        AND codcon = rec_planilla_rango.codcon
                        AND item IS NOT NULL
                    ORDER BY
                        item DESC
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec_planilla_rango.item := 1;
                END;

                v_accion := 'La insercion';
                INSERT INTO planilla_rango (
                    id_cia,
                    numpla,
                    codper,
                    codcon,
                    item,
                    finicio,
                    ffinal,
                    dias,
                    clase,
                    codigo,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_planilla_rango.id_cia,
                    rec_planilla_rango.numpla,
                    rec_planilla_rango.codper,
                    rec_planilla_rango.codcon,
                    rec_planilla_rango.item,
                    rec_planilla_rango.finicio,
                    rec_planilla_rango.ffinal,
                    rec_planilla_rango.dias,
                    rec_planilla_rango.clase,
                    rec_planilla_rango.codigo,
                    rec_planilla_rango.ucreac,
                    rec_planilla_rango.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                IF rec_planilla_rango.codcon NOT IN ( '004','038' ) THEN -- SIEMPRE SE ASIGNA DE FORMA MANUAL ( CONCEPTO DE INASISTENCIA )
                    UPDATE planilla_concepto
                    SET
                        valcon = nvl(valcon, 0) + rec_planilla_rango.dias
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = rec_planilla_rango.numpla
                        AND codper = rec_planilla_rango.codper
                        AND codcon = rec_planilla_rango.codcon;

                END IF;

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                FOR i IN (
                    SELECT
                        *
                    FROM
                        planilla_rango
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = rec_planilla_rango.numpla
                        AND codper = rec_planilla_rango.codper
                        AND codcon = rec_planilla_rango.codcon
                        AND item = rec_planilla_rango.item
                ) LOOP
                    UPDATE planilla_concepto
                    SET
                        valcon = nvl(valcon, 0) - i.dias
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = rec_planilla_rango.numpla
                        AND codper = rec_planilla_rango.codper
                        AND codcon = rec_planilla_rango.codcon;

                END LOOP;

                UPDATE planilla_rango
                SET
                    finicio =
                        CASE
                            WHEN rec_planilla_rango.finicio IS NULL THEN
                                finicio
                            ELSE
                                rec_planilla_rango.finicio
                        END,
                    ffinal =
                        CASE
                            WHEN rec_planilla_rango.ffinal IS NULL THEN
                                ffinal
                            ELSE
                                rec_planilla_rango.ffinal
                        END,
                    dias =
                        CASE
                            WHEN rec_planilla_rango.dias IS NULL THEN
                                dias
                            ELSE
                                rec_planilla_rango.dias
                        END,
                    clase =
                        CASE
                            WHEN rec_planilla_rango.clase IS NULL THEN
                                clase
                            ELSE
                                rec_planilla_rango.clase
                        END,
                    codigo =
                        CASE
                            WHEN rec_planilla_rango.codigo IS NULL THEN
                                codigo
                            ELSE
                                rec_planilla_rango.codigo
                        END,
                    refere =
                        CASE
                            WHEN rec_planilla_rango.refere IS NULL THEN
                                refere
                            ELSE
                                rec_planilla_rango.refere
                        END,
                    uactua = rec_planilla_rango.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_planilla_rango.id_cia
                    AND numpla = rec_planilla_rango.numpla
                    AND codper = rec_planilla_rango.codper
                    AND codcon = rec_planilla_rango.codcon
                    AND item = rec_planilla_rango.item;

                UPDATE planilla_concepto
                SET
                    valcon = nvl(valcon, 0) + rec_planilla_rango.dias
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = rec_planilla_rango.numpla
                    AND codper = rec_planilla_rango.codper
                    AND codcon = rec_planilla_rango.codcon;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM planilla_rango
                WHERE
                        id_cia = rec_planilla_rango.id_cia
                    AND numpla = rec_planilla_rango.numpla
                    AND codper = rec_planilla_rango.codper
                    AND codcon = rec_planilla_rango.codcon
                    AND item = rec_planilla_rango.item;

                UPDATE planilla_concepto
                SET
                    valcon = nvl(valcon, 0) - rec_planilla_rango.dias
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = rec_planilla_rango.numpla
                    AND codper = rec_planilla_rango.codper
                    AND codcon = rec_planilla_rango.codcon;

        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizo satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con la Planilla [ '
                                    || rec_planilla_rango.numpla
                                    || ' ], con el Personal [ '
                                    || rec_planilla_rango.codper
                                    || ' ], con Concepto ['
                                    || rec_planilla_rango.codcon
                                    || ' ] y Item [ '
                                    || rec_planilla_rango.item
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto ...!'
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
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se insertar o modificar este registro porque la Planilla [ '
                                        || rec_planilla_rango.numpla
                                        || ' ], con el Personal [ '
                                        || rec_planilla_rango.codper
                                        || ' ] y con Concepto ['
                                        || rec_planilla_rango.codcon
                                        || ' ] no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' codite :'
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

    FUNCTION sp_concepto (
        pin_id_cia NUMBER,
        pin_empobr VARCHAR2
    ) RETURN datatable_concepto
        PIPELINED
    AS
        v_table datatable_concepto;
    BEGIN
        SELECT
            c.id_cia,
            c.codcon,
            c.nombre,
            cc.codigo AS filtro,
            cp.clase,
            cp.descri AS descla
        BULK COLLECT
        INTO v_table
        FROM
                 concepto c
            INNER JOIN concepto_clase cc ON cc.id_cia = c.id_cia
                                            AND c.codcon = cc.codcon
                                            AND cc.clase = 14
            LEFT OUTER JOIN clase_personal cp ON cp.id_cia = c.id_cia
                                                 AND (
                CASE
                    WHEN cc.codigo = 'E' THEN
                        22
                    ELSE
                        21
                END
            ) = cp.clase
        WHERE
                c.id_cia = pin_id_cia
            AND c.empobr = pin_empobr;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_concepto;

    FUNCTION sp_motivo (
        pin_id_cia NUMBER,
        pin_tipo   VARCHAR2
    ) RETURN datatable_motivo
        PIPELINED
    AS
        v_table datatable_motivo;
    BEGIN
        SELECT
            id_cia,
            codmot,
            descri AS desmot,
            codrel AS codsunat
        BULK COLLECT
        INTO v_table
        FROM
            motivo_planilla
        WHERE
                id_cia = pin_id_cia
            AND tipo = pin_tipo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_motivo;

END;

/
