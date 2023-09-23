--------------------------------------------------------
--  DDL for Package Body PACK_HR_FACTOR_AFP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_FACTOR_AFP" AS

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_anio   IN NUMBER,
        pin_mes    IN NUMBER,
        pin_codafp IN VARCHAR2,
        pin_codfac IN VARCHAR2
    ) RETURN factorafpdatatable
        PIPELINED
    AS
        v_table factorafpdatatable;
    BEGIN
        SELECT
            fa.id_cia,
            fa.anio,
            fa.mes,
            fa.codafp,
            fa.codfac,
            fa.valfa1,
            fa.valfa2,
            fa.ucreac,
            fa.uactua,
            fa.fcreac,
            fa.factua,
            f.nombre AS nomfac,
            a.nombre AS nomafp
        BULK COLLECT
        INTO v_table
        FROM
            factor_afp      fa
            LEFT JOIN afp             a ON a.id_cia = fa.id_cia
                               AND a.codafp = fa.codafp
            LEFT JOIN factor_planilla f ON f.id_cia = fa.id_cia
                                           AND f.codfac = fa.codfac
        WHERE
                fa.id_cia = pin_id_cia
            AND ( ( pin_anio IS NULL )
                  OR ( fa.anio = pin_anio ) )
            AND ( ( pin_mes IS NULL )
                  OR ( fa.mes = pin_mes ) )
            AND ( ( pin_codafp IS NULL )
                  OR ( fa.codafp = pin_codafp ) )
            AND ( ( pin_codfac IS NULL )
                  OR ( fa.codfac = pin_codfac ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

--DECLARE
--    mensaje VARCHAR2(250);
--    cadjson VARCHAR2(1000);
--BEGIN
--    cadjson := '{
--            "anio":2022,
--            "mes":10,
--            "codafp":"P",
--            "codfac":"P",
--            "valfa1":100,
--            "valfa2":100,
--            "ucreac":"admin",
--            "uactua":"admin"
--        }';
--    PACK_FACTOR_AFP.SP_SAVE(100,cadjson,1,mensaje);
--    DBMS_OUTPUT.PUT_LINE(mensaje);
--END;
--
--SELECT * FROM PACK_FACTOR_AFP.SP_BUSCAR(100,2022,10,'P','P');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o              json_object_t;
        rec_factor_afp factor_afp%rowtype;
        v_accion       VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_factor_afp.id_cia := pin_id_cia;
        rec_factor_afp.anio := o.get_number('anio');
        rec_factor_afp.mes := o.get_number('mes');
        rec_factor_afp.codafp := o.get_string('codafp');
        rec_factor_afp.codfac := o.get_string('codfac');
        rec_factor_afp.valfa1 := o.get_number('valfa1');
        rec_factor_afp.valfa2 := o.get_number('valfa2');
        rec_factor_afp.ucreac := o.get_string('ucreac');
        rec_factor_afp.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO factor_afp (
                    id_cia,
                    anio,
                    mes,
                    codafp,
                    codfac,
                    valfa1,
                    valfa2,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_factor_afp.id_cia,
                    rec_factor_afp.anio,
                    rec_factor_afp.mes,
                    rec_factor_afp.codafp,
                    rec_factor_afp.codfac,
                    rec_factor_afp.valfa1,
                    rec_factor_afp.valfa2,
                    rec_factor_afp.ucreac,
                    rec_factor_afp.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE factor_afp
                SET
                    valfa1 = rec_factor_afp.valfa1,
                    valfa2 = rec_factor_afp.valfa2,
                    uactua = rec_factor_afp.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_factor_afp.id_cia
                    AND anio = rec_factor_afp.anio
                    AND mes = rec_factor_afp.mes
                    AND codafp = rec_factor_afp.codafp
                    AND codfac = rec_factor_afp.codfac;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM factor_afp
                WHERE
                        id_cia = rec_factor_afp.id_cia
                    AND anio = rec_factor_afp.anio
                    AND mes = rec_factor_afp.mes
                    AND codafp = rec_factor_afp.codafp
                    AND codfac = rec_factor_afp.codfac;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            pin_mensaje := 'El código : ['
                           || rec_factor_afp.codfac
                           || '] ya existe.';
        WHEN OTHERS THEN
            IF sqlcode = -2292 THEN
                pin_mensaje := 'No es posible eliminar el codigo de factor ['
                               || rec_factor_afp.codfac
                               || '] por restricción de integridad';
            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' codigo :'
                               || sqlcode;
            END IF;
    END sp_save;

    PROCEDURE sp_genera_factor_afp (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_codafp  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
    BEGIN
        INSERT INTO factor_afp (
            id_cia,
            anio,
            mes,
            codfac,
            codafp,
            valfa1,
            fcreac,
            factua
        )
            SELECT
                pin_id_cia,
                pin_periodo,
                pin_mes,
                f.codfac,
                pin_codafp,
                0,
                TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                             'YYYY-MM-DD HH24:MI:SS'),
                TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                             'YYYY-MM-DD HH24:MI:SS')
            FROM
                factor_planilla f
            WHERE
                    f.id_cia = pin_id_cia
                AND f.indafp = 'S'
                AND NOT EXISTS (
                    SELECT
                        fa.codfac
                    FROM
                        factor_afp fa
                    WHERE
                        ( fa.id_cia = f.id_cia )
                        AND ( fa.anio = pin_periodo )
                        AND ( fa.mes = pin_mes )
                        AND ( fa.codafp = pin_codafp )
                );

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'La actualización se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
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
    END sp_genera_factor_afp;

    PROCEDURE sp_replica_factor_afp (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_codafp  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_mes  NUMBER;
        v_anio NUMBER;
        v_aux  NUMBER;
        v_date DATE;
    BEGIN
        IF ( pin_mes = 1 ) THEN
            v_mes := ( 12 );
            v_anio := ( pin_periodo - 1 );
        ELSE
            v_mes := ( pin_mes - 1 );
            v_anio := pin_periodo;
        END IF;

        v_date := TO_DATE ( to_char('01'
                                    || '/'
                                    || v_mes
                                    || '/'
                                    || v_anio), 'DD/MM/YYYY' );

        INSERT INTO factor_afp (
            id_cia,
            anio,
            mes,
            codfac,
            codafp,
            valfa1,
            fcreac,
            factua
        )
            SELECT
                pin_id_cia,
                pin_periodo,
                pin_mes,
                codfac,
                codafp,
                valfa1,
                TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                             'YYYY-MM-DD HH24:MI:SS'),
                TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                             'YYYY-MM-DD HH24:MI:SS')
            FROM
                factor_afp f
            WHERE
                    f.id_cia = pin_id_cia
                AND ( f.anio = v_anio )
                AND ( f.mes = v_mes )
                AND ( f.codafp = pin_codafp )
                AND NOT EXISTS (
                    SELECT
                        f1.codfac
                    FROM
                        factor_afp f1
                    WHERE
                        ( f1.id_cia = f.id_cia )
                        AND ( f1.anio = pin_periodo )
                        AND ( f1.mes = pin_mes )
                        AND ( f1.codafp = pin_codafp )
                );

        SELECT
            f.id_cia
        INTO v_aux
        FROM
            factor_afp f
        WHERE
                f.id_cia = pin_id_cia
            AND ( f.anio = pin_periodo )
            AND ( f.mes = pin_mes )
            AND ( f.codafp = pin_codafp )
        FETCH NEXT 1 ROWS ONLY;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'La actualización se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN no_data_found THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                            'message' VALUE 'No existen registro para replicar del mes anterior [ '
                                            || to_char(v_date, 'Month', 'nls_date_language=spanish')
                                            || '] para la AFP [ '
                                            || pin_codafp
                                            || ' ]'
                )
            INTO pin_mensaje
            FROM
                dual;

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
    END sp_replica_factor_afp;

    PROCEDURE sp_clonar (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_mes  NUMBER;
        v_anio NUMBER;
        v_aux  NUMBER;
        v_date DATE;
    BEGIN
        IF ( pin_mes = 1 ) THEN
            v_mes := ( 12 );
            v_anio := ( pin_periodo - 1 );
        ELSE
            v_mes := ( pin_mes - 1 );
            v_anio := pin_periodo;
        END IF;

        INSERT INTO factor_afp (
            id_cia,
            anio,
            mes,
            codfac,
            codafp,
            valfa1,
            fcreac,
            factua
        )
            SELECT
                pin_id_cia,
                pin_periodo,
                pin_mes,
                codfac,
                codafp,
                valfa1,
                TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                             'YYYY-MM-DD HH24:MI:SS'),
                TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                             'YYYY-MM-DD HH24:MI:SS')
            FROM
                factor_afp f
            WHERE
                    f.id_cia = pin_id_cia
                AND f.anio = v_anio
                AND f.mes = v_mes
                AND NOT EXISTS (
                    SELECT
                        f1.codfac
                    FROM
                        factor_afp f1
                    WHERE
                            f1.id_cia = f.id_cia
                        AND f1.anio = pin_periodo
                        AND f1.mes = pin_mes
                        AND f1.codafp = f.codafp
                        AND f1.codfac = f.codfac
                );

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'La actualización se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
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
    END sp_clonar;

    FUNCTION sp_factor_afp_periodo (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_factor_afp_periodo
        PIPELINED
    AS
        v_table datatable_factor_afp_periodo;
    BEGIN
        SELECT
            pafp.id_cia,
            pafp.numpla,
            pafp.codper,
            pafp.codafp,
            afp.nombre,
            pc307.valcon,
            nvl(decode(pc307.valcon, 0, fp305.nombre, fp308.nombre),
                0),
            nvl(decode(pafp.codafp, '0000', f301.valfa1, 0),
                0),
            CASE
                WHEN pc1.valcon = 1
                     OR pc2.valcon = 1
                     OR pc3.valcon = 1
                     OR pc4.valcon = 1 THEN
                    0
                ELSE
                    nvl(f303.valfa1, 0)
            END,
            CASE
                WHEN pc1.valcon = 1
                     OR pc2.valcon = 1
                     OR pc3.valcon = 1
                     OR pc4.valcon = 1 THEN
                    0
                ELSE
                    nvl(f304.valfa1, 0)
            END,
            CASE
                WHEN pc1.valcon = 1
                     OR pc2.valcon = 1
                     OR pc3.valcon = 1
                     OR pc4.valcon = 1 THEN
                    0
                ELSE
                    nvl(decode(pc307.valcon, 0, f305.valfa1, f308.valfa1),
                        0)
            END,
            CASE
                WHEN pc1.valcon = 1
                     OR pc2.valcon = 1
                     OR pc3.valcon = 1
                     OR pc4.valcon = 1 THEN
                    0
                ELSE
                    nvl(decode(pafp.codafp,
                               '0000',
                               f301.valfa1,
                               nvl(f303.valfa1, 0) + nvl(f304.valfa1, 0) + nvl(decode(pc307.valcon, 0, f305.valfa1, f308.valfa1),
                                                                               0)),
                        0)
            END
--            nvl(f303.valfa1, 0),
--            nvl(f304.valfa1, 0),
--            nvl(decode(pc307.valcon, 0, f305.valfa1, f308.valfa1),
--                0),
--            nvl(decode(pafp.codafp,
--                       '0000',
--                       f301.valfa1,
--                       nvl(f303.valfa1, 0) + nvl(f304.valfa1, 0) + nvl(decode(pc307.valcon, 0, f305.valfa1, f308.valfa1),
--                                                                       0)),
--                0)
        BULK COLLECT
        INTO v_table
        FROM
                 planilla pl
            INNER JOIN planilla_afp          pafp ON pafp.id_cia = pl.id_cia
                                            AND pafp.numpla = pl.numpla
            LEFT OUTER JOIN afp                   afp ON afp.id_cia = pafp.id_cia
                                       AND afp.codafp = pafp.codafp
            LEFT OUTER JOIN factor_planilla       f301 ON f301.id_cia = pafp.id_cia
                                                    AND f301.codfac = '301'
            LEFT OUTER JOIN factor_afp            f303 ON f303.id_cia = pafp.id_cia
                                               AND f303.codafp = pafp.codafp
                                               AND f303.anio = pl.anopla
                                               AND f303.mes = pl.mespla
                                               AND f303.codfac = '303'
            LEFT OUTER JOIN factor_afp            f304 ON f304.id_cia = pafp.id_cia
                                               AND f304.codafp = pafp.codafp
                                               AND f304.anio = pl.anopla
                                               AND f304.mes = pl.mespla
                                               AND f304.codfac = '304'
            LEFT OUTER JOIN factor_afp            f305 ON f305.id_cia = pafp.id_cia
                                               AND f305.codafp = pafp.codafp
                                               AND f305.anio = pl.anopla
                                               AND f305.mes = pl.mespla
                                               AND f305.codfac = '305'
            LEFT OUTER JOIN factor_planilla       fp305 ON fp305.id_cia = pafp.id_cia
                                                     AND fp305.codfac = '305'
            LEFT OUTER JOIN factor_afp            f308 ON f308.id_cia = pafp.id_cia
                                               AND f308.codafp = pafp.codafp
                                               AND f308.anio = pl.anopla
                                               AND f308.mes = pl.mespla
                                               AND f308.codfac = '308'
            LEFT OUTER JOIN factor_planilla       fp308 ON fp308.id_cia = pafp.id_cia
                                                     AND fp308.codfac = '308'
            LEFT OUTER JOIN planilla_concepto     pc307 ON pc307.id_cia = pafp.id_cia
                                                       AND pc307.numpla = pafp.numpla
                                                       AND pc307.codper = pafp.codper
                                                       AND pc307.codcon = '307'
            LEFT OUTER JOIN factor_clase_planilla fcp418 ON fcp418.id_cia = pl.id_cia
                                                            AND fcp418.codfac = '418'
                                                            AND fcp418.tipcla = 1
                                                            AND fcp418.codcla = pl.empobr
            LEFT OUTER JOIN factor_clase_planilla fcp420 ON fcp420.id_cia = pl.id_cia
                                                            AND fcp420.codfac = '420'
                                                            AND fcp420.tipcla = 1
                                                            AND fcp420.codcla = pl.empobr
            LEFT OUTER JOIN factor_clase_planilla fcp423 ON fcp423.id_cia = pl.id_cia
                                                            AND fcp423.codfac = '423'
                                                            AND fcp423.tipcla = 1
                                                            AND fcp423.codcla = pl.empobr
            LEFT OUTER JOIN factor_clase_planilla fcp425 ON fcp425.id_cia = pl.id_cia
                                                            AND fcp425.codfac = '425'
                                                            AND fcp425.tipcla = 1
                                                            AND fcp425.codcla = pl.empobr
            LEFT OUTER JOIN planilla_concepto     pc1 ON pc1.id_cia = pafp.id_cia
                                                     AND pc1.numpla = pafp.numpla
                                                     AND pc1.codper = pafp.codper
                                                     AND pc1.codcon = fcp418.vstrg
            LEFT OUTER JOIN planilla_concepto     pc2 ON pc2.id_cia = pafp.id_cia
                                                     AND pc2.numpla = pafp.numpla
                                                     AND pc2.codper = pafp.codper
                                                     AND pc2.codcon = fcp420.vstrg
            LEFT OUTER JOIN planilla_concepto     pc3 ON pc3.id_cia = pafp.id_cia
                                                     AND pc3.numpla = pafp.numpla
                                                     AND pc3.codper = pafp.codper
                                                     AND pc3.codcon = fcp423.vstrg
            LEFT OUTER JOIN planilla_concepto     pc4 ON pc4.id_cia = pafp.id_cia
                                                     AND pc4.numpla = pafp.numpla
                                                     AND pc4.codper = pafp.codper
                                                     AND pc4.codcon = fcp425.vstrg
        WHERE
                pl.id_cia = pin_id_cia
            AND pl.numpla = pin_numpla
            AND ( pin_codper IS NULL
                  OR pafp.codper = pin_codper );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_factor_afp_periodo;

END;

/
