--------------------------------------------------------
--  DDL for Package Body PACK_HR_PRESTAMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PRESTAMO" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_id_pre NUMBER
    ) RETURN datatable_prestamo
        PIPELINED
    AS
        v_table datatable_prestamo;
    BEGIN
        SELECT
            pr.id_cia,
            pr.id_pre,
            pr.codper,
            pe.apepat
            || ' '
            || pe.apemat
            || ' '
            || pe.nombre AS nomper,
            pr.fecpre,
            pr.monpre,
            pr.monpag,
            pr.codmon,
            pr.cancuo,
            pr.valcuo,
            pr.salpre,
            pr.observ,
            pr.modifi,
            pr.situac,
            pr.ucreac,
            pr.uactua,
            pr.fcreac,
            pr.factua,
            uc.nombres   AS nomucreac,
            ua.nombres   AS nomuactua
        BULK COLLECT
        INTO v_table
        FROM
                 prestamo pr
            INNER JOIN personal pe ON pe.id_cia = pr.id_cia
                                      AND pe.codper = pr.codper
            LEFT OUTER JOIN usuarios uc ON uc.id_cia = pr.id_cia
                                           AND uc.coduser = pr.ucreac
            LEFT OUTER JOIN usuarios ua ON ua.id_cia = pr.id_cia
                                           AND ua.coduser = pr.uactua
        WHERE
                pr.id_cia = pin_id_cia
            AND pr.id_pre = pin_id_pre;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tiptra VARCHAR2,
        pin_codper VARCHAR2,
        pin_codmon VARCHAR2,
        pin_mdesde NUMBER,
        pin_mhasta NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_prestamo
        PIPELINED
    AS
        v_table datatable_prestamo;
    BEGIN
        SELECT
            pr.id_cia,
            pr.id_pre,
            pr.codper,
            pe.apepat
            || ' '
            || pe.apemat
            || ' '
            || pe.nombre AS nomper,
            pr.fecpre,
            pr.monpre,
            pr.monpag,
            pr.codmon,
            pr.cancuo,
            pr.valcuo,
            pr.salpre,
            pr.observ,
            pr.modifi,
            pr.situac,
            pr.ucreac,
            pr.uactua,
            pr.fcreac,
            pr.factua,
            uc.nombres   AS nomucreac,
            ua.nombres   AS nomuactua
        BULK COLLECT
        INTO v_table
        FROM
                 prestamo pr
            INNER JOIN personal pe ON pe.id_cia = pr.id_cia
                                      AND pe.codper = pr.codper
            LEFT OUTER JOIN usuarios uc ON uc.id_cia = pr.id_cia
                                           AND uc.coduser = pr.ucreac
            LEFT OUTER JOIN usuarios ua ON ua.id_cia = pr.id_cia
                                           AND ua.coduser = pr.uactua
        WHERE
                pr.id_cia = pin_id_cia
            AND ( pin_tiptra IS NULL
                  OR pe.tiptra = pin_tiptra )
            AND ( pin_codper IS NULL
                  OR pr.codper = pin_codper )
            AND ( pin_codmon IS NULL
                  OR pr.codmon = pin_codmon )
            AND ( ( pin_fdesde IS NULL
                    AND pin_fhasta IS NULL )
                  OR ( pr.fecpre BETWEEN pin_fdesde AND pin_fhasta ) )
            AND ( ( pin_mdesde IS NULL
                    AND pin_mhasta IS NULL )
                  OR ( pr.monpre BETWEEN pin_mdesde AND pin_mhasta ) );

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
--                "codper":"80238132",
--                "fecpre":"2022-01-01",
--                "monpre":1500,
--                "codmon":"PEN",
--                "cancuo":5,
--                "valcuo":300,
--                "salpre":1200,
--                "observ":"Prueba Funcional",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_prestamo.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_prestamo.sp_obtener(66,1);
--
--SELECT * FROM pack_hr_prestamo.sp_buscar(66,NULL,NULL,NULL,NULL,NULL,NULL);
    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o            json_object_t;
        rec_prestamo prestamo%rowtype;
        v_accion     VARCHAR2(50) := '';
        v_planilla   VARCHAR2(1000 CHAR) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_prestamo.id_cia := pin_id_cia;
        rec_prestamo.id_pre := o.get_number('id_pre');
        rec_prestamo.codper := o.get_string('codper');
        rec_prestamo.fecpre := o.get_date('fecpre');
        rec_prestamo.monpre := o.get_number('monpre');
        rec_prestamo.monpag := nvl(o.get_number('monpag'),0);
        rec_prestamo.codmon := o.get_string('codmon');
        rec_prestamo.cancuo := o.get_number('cancuo');
        rec_prestamo.valcuo := o.get_number('valcuo');
        rec_prestamo.salpre := o.get_number('salpre');
        rec_prestamo.observ := o.get_string('observ');
        rec_prestamo.situac := 'S';
        rec_prestamo.modifi := 'S';
        rec_prestamo.ucreac := o.get_string('ucreac');
        rec_prestamo.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                BEGIN
                    SELECT
                        ( nvl(id_pre, 0) + 1 )
                    INTO rec_prestamo.id_pre
                    FROM
                        prestamo
                    WHERE
                        id_cia = rec_prestamo.id_cia
                    ORDER BY
                        id_pre DESC
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec_prestamo.id_pre := 1;
                END;

                rec_prestamo.salpre := rec_prestamo.monpre - nvl(rec_prestamo.monpag, 0);
                v_accion := 'La insercion';
                INSERT INTO prestamo (
                    id_cia,
                    id_pre,
                    codper,
                    fecpre,
                    monpre,
                    monpag,
                    codmon,
                    cancuo,
                    valcuo,
                    salpre,
                    observ,
                    modifi,
                    situac,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_prestamo.id_cia,
                    rec_prestamo.id_pre,
                    rec_prestamo.codper,
                    rec_prestamo.fecpre,
                    rec_prestamo.monpre,
                    rec_prestamo.monpag,
                    rec_prestamo.codmon,
                    rec_prestamo.cancuo,
                    rec_prestamo.valcuo,
                    rec_prestamo.salpre,
                    rec_prestamo.observ,
                    rec_prestamo.modifi,
                    rec_prestamo.situac,
                    rec_prestamo.ucreac,
                    rec_prestamo.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                INSERT INTO prestamo_tipoplanilla (
                    id_cia,
                    id_pre,
                    tippla,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_prestamo.id_cia,
                    rec_prestamo.id_pre,
                    'N',
                    rec_prestamo.ucreac,
                    rec_prestamo.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                INSERT INTO prestamo_tipoplanilla (
                    id_cia,
                    id_pre,
                    tippla,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_prestamo.id_cia,
                    rec_prestamo.id_pre,
                    'L',
                    rec_prestamo.ucreac,
                    rec_prestamo.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE prestamo
                SET
                    fecpre =
                        CASE
                            WHEN rec_prestamo.fecpre IS NULL THEN
                                fecpre
                            ELSE
                                rec_prestamo.fecpre
                        END,
                    monpre =
                        CASE
                            WHEN rec_prestamo.monpre IS NULL THEN
                                monpre
                            ELSE
                                rec_prestamo.monpre
                        END,
                    codmon =
                        CASE
                            WHEN rec_prestamo.codmon IS NULL THEN
                                codmon
                            ELSE
                                rec_prestamo.codmon
                        END,
                    cancuo =
                        CASE
                            WHEN rec_prestamo.cancuo IS NULL THEN
                                cancuo
                            ELSE
                                rec_prestamo.cancuo
                        END,
                    valcuo =
                        CASE
                            WHEN rec_prestamo.valcuo IS NULL THEN
                                valcuo
                            ELSE
                                rec_prestamo.valcuo
                        END,
                    salpre =
                        CASE
                            WHEN rec_prestamo.salpre IS NULL THEN
                                salpre
                            ELSE
                                rec_prestamo.salpre
                        END,
                    observ =
                        CASE
                            WHEN rec_prestamo.observ IS NULL THEN
                                observ
                            ELSE
                                rec_prestamo.observ
                        END,
                    uactua = rec_prestamo.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_prestamo.id_cia
                    AND id_pre = rec_prestamo.id_pre;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM prestamo_tipoplanilla
                WHERE
                        id_cia = rec_prestamo.id_cia
                    AND id_pre = rec_prestamo.id_pre;

                DELETE FROM prestamo
                WHERE
                        id_cia = rec_prestamo.id_cia
                    AND id_pre = rec_prestamo.id_pre;

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
                    'message' VALUE 'El registro con el ID [ '
                                    || rec_prestamo.id_pre
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

        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se INSERTAR O MODIFICAR este registro porque el PERSONAL [ '
                                        || rec_prestamo.codper
                                        || ' ] NO EXISTE'
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSIF sqlcode = -2292 THEN
                BEGIN
                    SELECT
                        LISTAGG(t.planilla, ',')
                    INTO v_planilla
                    FROM
                        (
                            SELECT
                                ( pl.tippla
                                  || pl.empobr
                                  || '-'
                                  || pl.anopla
                                  || '/'
                                  || TRIM(to_char(pl.mespla, '00'))
                                  || '-'
                                  || pl.sempla ) AS planilla
                            FROM
                                     prestamo p
                                INNER JOIN dsctoprestamo d ON d.id_cia = p.id_cia
                                                              AND d.id_pre = p.id_pre
                                INNER JOIN planilla      pl ON pl.id_cia = d.id_cia
                                                          AND pl.numpla = d.numpla
                            WHERE
                                    p.id_cia = pin_id_cia
                                AND d.id_pre = rec_prestamo.id_pre
                        ) t;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_planilla := 'ND';
                END;

                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se puede ELIMINAR este registro porque tiene PLANILLAS RELACIONADAS [ '
                                        || v_planilla
                                        || ' ]'
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

END;

/
