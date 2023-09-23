--------------------------------------------------------
--  DDL for Package Body PACK_MOVIMIENTOS_ASIENTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_MOVIMIENTOS_ASIENTOS" AS

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_cuenta  VARCHAR2,
        pin_codigo  VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        SELECT DISTINCT
            m.cuenta,
            p.nombre,
            LTRIM(m.codigo),
            m.periodo,
            m.mes,
            m.libro,
            m.asiento,
            m.item,
            m.sitem,
            m.fdocum,
            TRIM(m.tdocum),
            m.proyec,
            TRIM(m.serie),
            TRIM(m.numero),
            m.debe01,
            m.haber01,
            m.debe02,
            m.haber02,
            a.periodo      AS aperiodo,
            a.mes          AS ames,
            a.libro        AS alibro,
            a.asiento      AS aasiento,
            a.item         AS aitem,
            a.sitem        AS asitem,
            TRIM(a.codigo) AS acodigo,
            a.fdocum       AS afdocum,
            TRIM(a.tdocum) AS atdocum,
            TRIM(a.serie)  AS aserie,
            TRIM(a.numero) AS anumero
        BULK COLLECT
        INTO v_table
        FROM
                 movimientos m
            INNER JOIN asiendet a ON a.id_cia = m.id_cia
                                     AND a.periodo = m.periodo
                                     AND a.mes = m.mes
                                     AND a.libro = m.libro
                                     AND a.asiento = m.asiento
                                     AND a.item = m.item
                                     AND a.sitem = m.sitem
            INNER JOIN pcuentas p ON p.id_cia = m.id_cia
                                     AND p.cuenta = m.cuenta
        WHERE
                m.id_cia = pin_id_cia
            AND m.periodo = pin_periodo
            AND ( pin_mes IS NULL
                  OR pin_mes = - 1
                  OR m.mes = pin_mes )
            AND m.cuenta = pin_cuenta
            AND ( nvl(m.codigo, 'XXXXXXXXXX') = nvl(pin_codigo, 'XXXXXXXXXX')
                  OR ( pin_codigo = 'CODIGONULL'
                       AND ( length(TRIM(m.codigo)) IS NULL
                             OR length(TRIM(m.tdocum)) IS NULL
                             OR length(TRIM(m.serie)) IS NULL
                             OR length(TRIM(m.numero)) IS NULL ) ) )
        ORDER BY
            m.cuenta,
            LTRIM(m.codigo),
            TRIM(m.tdocum),
            TRIM(m.serie),
            TRIM(m.numero),
            m.periodo,
            m.mes,
            m.libro,
            m.asiento;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    PROCEDURE sp_actualiza (
        pin_id_cia  NUMBER,
        pin_datos   VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        o            json_object_t;
        rec_asiendet asiendet%rowtype;
        v_proceso    VARCHAR2(1);
        pout_mensaje VARCHAR2(1000);
    BEGIN
        v_proceso := 'S';
        o := json_object_t.parse(pin_datos);
        rec_asiendet.id_cia := pin_id_cia;
        rec_asiendet.periodo := o.get_number('periodo');
        rec_asiendet.mes := o.get_number('mes');
        rec_asiendet.libro := o.get_string('libro');
        rec_asiendet.asiento := o.get_number('asiento');
        rec_asiendet.item := o.get_number('item');
        rec_asiendet.sitem := o.get_number('sitem');
        rec_asiendet.codigo := o.get_string('codigo');
        rec_asiendet.tdocum := o.get_string('tdocum');
        rec_asiendet.serie := o.get_string('serie');
        rec_asiendet.numero := o.get_string('numero');
        rec_asiendet.proyec := o.get_string('proyec');
        IF rec_asiendet.tdocum IS NOT NULL THEN
            BEGIN
                SELECT
                    codigo
                INTO rec_asiendet.tdocum
                FROM
                    tdocume
                WHERE
                        id_cia = pin_id_cia
                    AND codigo = rec_asiendet.tdocum;

            EXCEPTION
                WHEN no_data_found THEN
                    IF length(trim(rec_asiendet.tdocum)) = 1 THEN
                        pout_mensaje := 'El TIPO DE DOCUMENTO [ '
                                        || rec_asiendet.tdocum
                                        || ' ] no existe, SUGERENCIA [ '
                                        || trim(to_char(rec_asiendet.tdocum, '00'))
                                        || ' ]';
                    ELSE
                        pout_mensaje := 'El TIPO DE DOCUMENTO [ '
                                        || rec_asiendet.tdocum
                                        || ' ] no existe ...!';
                    END IF;

                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;
        END IF;

        IF (
            rec_asiendet.id_cia IS NOT NULL
            AND rec_asiendet.periodo IS NOT NULL
            AND rec_asiendet.mes IS NOT NULL
            AND rec_asiendet.libro IS NOT NULL
            AND rec_asiendet.asiento IS NOT NULL
            AND rec_asiendet.item IS NOT NULL
            AND rec_asiendet.sitem IS NOT NULL
        ) THEN
--            BEGIN
            UPDATE asiendet
            SET
                codigo =
                    CASE
                        WHEN rec_asiendet.codigo IS NULL THEN
                            ''
                        ELSE
                            rec_asiendet.codigo
                    END,
                tdocum =
                    CASE
                        WHEN rec_asiendet.tdocum IS NULL THEN
                            ''
                        ELSE
                            rec_asiendet.tdocum
                    END,
                serie =
                    CASE
                        WHEN rec_asiendet.serie IS NULL THEN
                            ''
                        ELSE
                            rec_asiendet.serie
                    END,
                numero =
                    CASE
                        WHEN rec_asiendet.numero IS NULL THEN
                            ''
                        ELSE
                            rec_asiendet.numero
                    END,
                proyec =
                    CASE
                        WHEN rec_asiendet.proyec IS NULL THEN
                            ''
                        ELSE
                            rec_asiendet.proyec
                    END,
                factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
            WHERE
                    id_cia = rec_asiendet.id_cia
                AND periodo = rec_asiendet.periodo
                AND mes = rec_asiendet.mes
                AND libro = rec_asiendet.libro
                AND asiento = rec_asiendet.asiento
                AND item = rec_asiendet.item
                AND sitem = rec_asiendet.sitem;

            UPDATE movimientos
            SET
                codigo =
                    CASE
                        WHEN rec_asiendet.codigo IS NULL THEN
                            ''
                        ELSE
                            rec_asiendet.codigo
                    END,
                tdocum =
                    CASE
                        WHEN rec_asiendet.tdocum IS NULL THEN
                            ''
                        ELSE
                            rec_asiendet.tdocum
                    END,
                serie =
                    CASE
                        WHEN rec_asiendet.serie IS NULL THEN
                            ''
                        ELSE
                            rec_asiendet.serie
                    END,
                numero =
                    CASE
                        WHEN rec_asiendet.numero IS NULL THEN
                            ''
                        ELSE
                            rec_asiendet.numero
                    END,
                proyec =
                    CASE
                        WHEN rec_asiendet.proyec IS NULL THEN
                            ''
                        ELSE
                            rec_asiendet.proyec
                    END,
                factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
            WHERE
                    id_cia = rec_asiendet.id_cia
                AND periodo = rec_asiendet.periodo
                AND mes = rec_asiendet.mes
                AND libro = rec_asiendet.libro
                AND asiento = rec_asiendet.asiento
                AND item = rec_asiendet.item
                AND sitem = rec_asiendet.sitem;

--            EXCEPTION
--                WHEN value_error THEN
--                    pout_mensaje := 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto ...!';
--                    RAISE pkg_exceptionuser.ex_error_inesperado;
--                WHEN OTHERS THEN
--                    v_proceso := 'N';
--                    pout_mensaje := 'mensaje : '
--                                    || sqlerrm
--                                    || ' codigo :'
--                                    || sqlcode;
--                    RAISE pkg_exceptionuser.ex_error_inesperado;
--                    ROLLBACK;
--            END;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'La actualización se realizó satisfactoriamente'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
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
    END sp_actualiza;

END;

/
