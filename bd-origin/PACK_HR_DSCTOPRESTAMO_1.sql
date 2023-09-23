--------------------------------------------------------
--  DDL for Package Body PACK_HR_DSCTOPRESTAMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_DSCTOPRESTAMO" AS

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_id_pre NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        SELECT
            d.id_cia,
            d.id_pre,
            d.numpla,
            pr.codper,
            d.fecdes,
            d.valcuo,
            d.aplica,
            CASE
                WHEN d.aplica = 'S' THEN
                    'SISTEMA'
                WHEN d.aplica = 'M' THEN
                    'MANUAL'
                ELSE
                    'ELIMINADO'
            END           AS desaplica,
            d.observ,
            ( p.tippla
              || p.empobr
              || '-'
              || p.anopla
              || '/'
              || TRIM(to_char(p.mespla, '00'))
              || '-'
              || p.sempla ) AS planilla,
            p.tippla,
            p.empobr,
            p.anopla,
            p.mespla,
            p.sempla,
            p.situac,
            pe.apepat
            || ' '
            || pe.apemat
            || ' '
            || pe.nombre  AS nomper,
            pr.fecpre,
            pr.monpre,
            pr.monpag,
            pr.codmon,
            pr.cancuo,
            pr.valcuo,
            pr.salpre,
            d.ucreac,
            d.uactua,
            d.fcreac,
            d.factua,
            uc.nombres    AS nomucreac,
            ua.nombres    AS nomuactua
        BULK COLLECT
        INTO v_table
        FROM
            dsctoprestamo d
            LEFT OUTER JOIN prestamo      pr ON d.id_cia = pr.id_cia
                                           AND d.id_pre = pr.id_pre
            LEFT OUTER JOIN personal      pe ON pr.id_cia = pe.id_cia
                                           AND pr.codper = pe.codper
            INNER JOIN planilla      p ON p.id_cia = d.id_cia
                                     AND p.numpla = d.numpla
            LEFT OUTER JOIN usuarios      uc ON uc.id_cia = d.id_cia
                                           AND uc.coduser = d.ucreac
            LEFT OUTER JOIN usuarios      ua ON ua.id_cia = d.id_cia
                                           AND ua.coduser = d.uactua
        WHERE
                d.id_cia = pin_id_cia
            AND ( pin_id_pre IS NULL
                  OR pr.id_pre = pin_id_pre )
            AND ( pin_numpla IS NULL
                  OR p.numpla = pin_numpla )
            AND ( pin_codper IS NULL
                  OR pe.codper = pin_codper )
        ORDER BY
            d.fecdes;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    PROCEDURE sp_registrar (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_id_pre  IN NUMBER,
        pin_codper  IN VARCHAR2,
        pin_fdesde  IN DATE,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_valcuo     NUMERIC(15, 4);
        v_cancuo     SMALLINT;
        v_totpre     NUMERIC(15, 4);
        v_salpre     NUMERIC(15, 4);
        v_candes     SMALLINT;
        v_mondes     NUMERIC(15, 4);
        v_conpre     VARCHAR(5);
        v_codper     VARCHAR(8);
        v_tiptra     VARCHAR(1);
        v_tippla     VARCHAR(1);
        pout_mensaje VARCHAR2(1000 CHAR);
        v_planilla   VARCHAR2(100 CHAR);
    BEGIN
        -- CANDES=CANTIDAD DE CUOTAS 
        -- MONDES=TOTAL DESCONTADO
        BEGIN
            SELECT
                nvl(COUNT(nvl(valcuo, 0)),
                    0),
                nvl(SUM(nvl(valcuo, 0)),
                    0)
            INTO
                v_candes,
                v_mondes
            FROM
                dsctoprestamo
            WHERE
                    id_cia = pin_id_cia
                AND id_pre = pin_id_pre;

        EXCEPTION
            WHEN no_data_found THEN
                v_candes := 0;
                v_mondes := 0;
        END;

        BEGIN
            SELECT
                codper,
                cancuo,
                valcuo,
                salpre
            INTO
                v_codper,
                v_cancuo,
                v_valcuo,
                v_salpre
            FROM
                prestamo
            WHERE
                    id_cia = pin_id_cia
                AND id_pre = pin_id_pre;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'ERROR, ID DEL PRESTAMO [ '
                                || pin_id_pre
                                || ' ] NO LOCALIZADO, REFRESCAR LA PLANILLA Y REPROCESAR';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                p.empobr,
                p.tippla,
                ( p.tippla
                  || p.empobr
                  || '-'
                  || p.anopla
                  || '/'
                  || TRIM(to_char(p.mespla, '00'))
                  || '-'
                  || p.sempla ) AS planilla
            INTO
                v_tiptra,
                v_tippla,
                v_planilla
            FROM
                planilla p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.numpla = pin_numpla;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'ERROR, PLANILLA NO LOCALIZADA, REFRESCAR LA PLANILLA Y REPROCESAR';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        IF v_tippla = 'L' THEN -- SI ES UNA PLANILLA DE LIQUIDACION LA CUOTA ES IGUAL AL SALDO PENDIENTE
            v_valcuo := v_salpre;
        ELSE
            IF v_candes + 1 >= v_cancuo THEN -- LA ULTIMO CUOTA SIEMPRE ES IGUAL AL SALDO PENDIENTE
                v_valcuo := v_salpre;
            ELSE
                IF v_salpre >= v_valcuo THEN
                    v_salpre := v_salpre - v_valcuo;
                ELSE -- SI EL SALDO PENDIENTE ES MENOR QUE LA CUOTA, SE ASIGNA EL SALDO PENDIENTE COMO CUOTA
                    v_valcuo := v_salpre;
                END IF;
            END IF;
        END IF;

        UPDATE prestamo
        SET
            modifi = 'N'
        WHERE
                id_cia = pin_id_cia
            AND id_pre = pin_id_pre;
        
        /* REGISTRANDO LA NUEVA CUOTA A DESCONTAR ...*/
        MERGE INTO dsctoprestamo dp
        USING dual ddd ON ( dp.id_cia = pin_id_cia
                            AND dp.id_pre = pin_id_pre
                            AND dp.numpla = pin_numpla )
        WHEN MATCHED THEN UPDATE
        SET fecdes = pin_fdesde,
            valcuo = v_valcuo,
            uactua = pin_coduser,
            factua = current_timestamp
        WHERE
                id_cia = pin_id_cia
            AND id_pre = pin_id_pre
            AND numpla = pin_numpla
            AND aplica = 'S'
        WHEN NOT MATCHED THEN
        INSERT (
            id_cia,
            id_pre,
            numpla,
            codper,
            fecdes,
            valcuo,
            aplica,
            observ,
            ucreac,
            uactua,
            fcreac,
            factua )
        VALUES
            ( pin_id_cia,
              pin_id_pre,
              pin_numpla,
              pin_codper,
              pin_fdesde,
              v_valcuo,
            'S',
              v_planilla,
              pin_coduser,
              pin_coduser,
              current_timestamp,
              current_timestamp );

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
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
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

    END sp_registrar;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "id_pre":1,
--                "numpla":1,
--                "valcuo":2000,
--                "observ":"Prestamo de Prueba - Actualizado",
--                "uactua":"admin"
--                }';
--pack_hr_dsctoprestamo.sp_save(66, cadjson, 2, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_dsctoprestamo.sp_buscar(66,1,1,null);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                 json_object_t;
        m                 json_object_t;
        rec_dsctoprestamo dsctoprestamo%rowtype;
        v_accion          VARCHAR2(50) := '';
        pout_mensaje      VARCHAR2(1000) := '';
        v_mensaje         VARCHAR2(1000) := '';
        v_mondes          dsctoprestamo.valcuo%TYPE;
        v_totpre          dsctoprestamo.valcuo%TYPE;
        v_codper          personal.codper%TYPE;
        v_tiptra          personal.tiptra%TYPE;
        v_valcuo          dsctoprestamo.valcuo%TYPE;
        v_salpre          dsctoprestamo.valcuo%TYPE;
        v_conpre          tipo_trabajador.conpre%TYPE;
        v_formula         VARCHAR2(1000) := '';
        v_aux_formula     VARCHAR2(1000) := '';
        v_valor           VARCHAR2(1000) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_dsctoprestamo.id_cia := pin_id_cia;
        rec_dsctoprestamo.id_pre := o.get_number('id_pre');
        rec_dsctoprestamo.numpla := o.get_number('numpla');
        v_codper := o.get_string('codper');
        rec_dsctoprestamo.fecdes := current_timestamp;
        rec_dsctoprestamo.valcuo := o.get_number('valcuo');
        rec_dsctoprestamo.observ := o.get_string('observ');
        rec_dsctoprestamo.uactua := o.get_string('uactua');
        CASE
            WHEN pin_opcdml = 2 THEN
                BEGIN
                    SELECT
                        p.codper,
                        ( p.salpre + d.valcuo )
                    INTO
                        v_codper,
                        v_salpre
                    FROM
                        prestamo      p
                        LEFT OUTER JOIN dsctoprestamo d ON d.id_cia = p.id_cia
                                                           AND d.id_pre = p.id_pre
                                                           AND d.numpla = rec_dsctoprestamo.numpla
                    WHERE
                            p.id_cia = rec_dsctoprestamo.id_cia
                        AND p.id_pre = rec_dsctoprestamo.id_pre;

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'ERROR, ID DEL PRESTAMO [ '
                                        || rec_dsctoprestamo.id_pre
                                        || ' ] NO LOCALIZADO, REFRESCAR LA PLANILLA Y REPROCESAR';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                IF ( rec_dsctoprestamo.valcuo > v_salpre ) THEN
                    pout_mensaje := 'EL VALOR DE LA CUOTA [ '
                                    || rec_dsctoprestamo.valcuo
                                    || ' ] NO PUEDE SUPERAR EL SALDO PENDIENTE [ '
                                    || v_salpre
                                    || ']';

                    RAISE pkg_exceptionuser.ex_error_inesperado;
                -- REAJUSTAMOS LA CUOTA SI ES EXCESIVO
--                    rec_dsctoprestamo.valcuo := v_salpre;
                END IF;

                UPDATE dsctoprestamo
                SET
                    fecdes = rec_dsctoprestamo.fecdes,
                    valcuo = rec_dsctoprestamo.valcuo,
                    aplica = 'M',
                    observ = rec_dsctoprestamo.observ,
                    uactua = rec_dsctoprestamo.uactua,
                    factua = current_date
                WHERE
                        id_cia = rec_dsctoprestamo.id_cia
                    AND id_pre = rec_dsctoprestamo.id_pre
                    AND numpla = rec_dsctoprestamo.numpla;

                -- PROCESANDO CONCEPTO DE PRESTAMO
                FOR k IN (
                    SELECT
                        pc.numpla,
                        pc.codper,
                        pc.codcon
                    FROM
                             planilla_concepto pc
                        INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                                 AND c.codcon = pc.codcon
                                                 AND c.fijvar = 'P'
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.numpla = rec_dsctoprestamo.numpla
                        AND pc.codper = v_codper
                ) LOOP
                    pack_hr_planilla_formula.sp_decodificar_cprestamo(pin_id_cia, k.numpla, k.codper, k.codcon, 'S',
                                                                     rec_dsctoprestamo.uactua, k.codcon, v_formula, v_aux_formula, v_valor
                                                                     ,
                                                                     v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END LOOP;

            WHEN pin_opcdml = 3 THEN
            -- NO
                NULL;
        END CASE;

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
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con el ID de Prestamo [ '
                                    || rec_dsctoprestamo.id_pre
                                    || ' ]  para la Planilla [ '
                                    || rec_dsctoprestamo.numpla
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

    END sp_save;

END;

/
