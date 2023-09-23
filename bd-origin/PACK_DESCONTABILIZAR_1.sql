--------------------------------------------------------
--  DDL for Package Body PACK_DESCONTABILIZAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DESCONTABILIZAR" AS

    FUNCTION sp_existe_asiento_cxc (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER
    ) RETURN VARCHAR2 AS
        v_mensaje VARCHAR2(1) := 'N';
    BEGIN
        BEGIN
            SELECT
                'S' AS count
            INTO v_mensaje
            FROM
                dcta102
            WHERE
                    id_cia = pin_id_cia
                AND libro = pin_libro
                AND periodo = pin_periodo
                AND mes = pin_mes
                AND ( secuencia = pin_secuencia
                      AND secuencia > 0 );

        EXCEPTION
            WHEN no_data_found THEN
                v_mensaje := 'N';
            WHEN OTHERS THEN
                v_mensaje := 'N';
        END;

        RETURN v_mensaje;
    END sp_existe_asiento_cxc;

    FUNCTION sp_existe_asiento_cxp (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER
    ) RETURN VARCHAR2 AS
        v_mensaje VARCHAR2(1) := 'N';
    BEGIN
        BEGIN
            SELECT
                'S' AS count
            INTO v_mensaje
            FROM
                prov102
            WHERE
                    id_cia = pin_id_cia
                AND libro = pin_libro
                AND periodo = pin_periodo
                AND mes = pin_mes
                AND ( secuencia = pin_secuencia
                      AND secuencia > 0 );

        EXCEPTION
            WHEN no_data_found THEN
                v_mensaje := 'N';
            WHEN OTHERS THEN
                v_mensaje := 'N';
        END;

        RETURN v_mensaje;
    END sp_existe_asiento_cxp;

    PROCEDURE sp_planilla_cxc (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_coduser   IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    ) AS
        v_actualizar VARCHAR2(1) := 'S';
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
    -- LA PLANILLA TIENE ASIGNADO NUMERO DE ASIENTO???? - DCTA102
        dbms_output.put_line('LA PLANILLA TIENE ASIGNADO NUMERO DE ASIENTO????');
        IF pack_descontabilizar.sp_existe_asiento_cxc(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia) = 'N' THEN
            pout_mensaje := 'La Planilla no Tiene Numero de Asiento ...!';
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;
    --PROCESO DE DESCONTABILZIAR PLANILLA
        dbms_output.put_line('PROCESO DE DESCONTABILZIAR PLANILLA');
        BEGIN
            UPDATE dcta102
            SET
                situac = 'A',
                usuari = pin_coduser,
                tippla = 100
            WHERE
                    id_cia = pin_id_cia
                AND libro = pin_libro
                AND periodo = pin_periodo
                AND mes = pin_mes
                AND secuencia = pin_secuencia;

        EXCEPTION
            WHEN OTHERS THEN
                v_actualizar := 'N';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        IF v_actualizar = 'S' THEN
            BEGIN
                -- ACTUALIZANDO DOCUMENTOS CLIENTES
                dbms_output.put_line('ACTUALIZANDO DOCUMENTOS CLIENTES');
                UPDATE dcta103
                SET
                    situac = 'A'
                WHERE
                        id_cia = pin_id_cia
                    AND libro = pin_libro
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND secuencia = pin_secuencia;
                -- ACTUALIZANDO DOCUMENTOS APLIACIONES
                dbms_output.put_line('ACTUALIZANDO DOCUMENTOS APLIACIONES');
                UPDATE dcta113
                SET
                    situac = 'A'
                WHERE
                        id_cia = pin_id_cia
                    AND libro = pin_libro
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND secuencia = pin_secuencia;
                -- ACTUALIZANDO DOCUMENTOS PROVEEDORES
                dbms_output.put_line('ACTUALIZANDO DOCUMENTOS PROVEEDORES');
                UPDATE prov103
                SET
                    situac = 'A'
                WHERE
                        id_cia = pin_id_cia
                    AND libro = pin_libro
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND secuencia = pin_secuencia;
                -- ACTUALIZANDO DEPOSITOS
                dbms_output.put_line('ACTUALIZANDO DEPOSITOS');
                UPDATE dcta104
                SET
                    situac = 'A'
                WHERE
                        id_cia = pin_id_cia
                    AND libro = pin_libro
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND secuencia = pin_secuencia;

            END;

                -- ELIMINANDO DCTA101
            dbms_output.put_line('ELIMINANDO DCTA101');
            DELETE FROM dcta101
            WHERE
                    id_cia = pin_id_cia
                AND libro = pin_libro
                AND periodo = pin_periodo
                AND mes = pin_mes
                AND secuencia = pin_secuencia;

            BEGIN
                -- ANULANDO ...
                dbms_output.put_line('ANULANDO ...');
                UPDATE asienhea
                SET
                    situac = 9,
                    factua = current_date,
                    usuari = pin_coduser
                WHERE
                        id_cia = pin_id_cia
                    AND libro = pin_libro
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND asiento = pin_secuencia;

                DELETE FROM asiendet
                WHERE
                        id_cia = pin_id_cia
                    AND libro = pin_libro
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND asiento = pin_secuencia;

                DELETE FROM movimientos
                WHERE
                        id_cia = pin_id_cia
                    AND libro = pin_libro
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND asiento = pin_secuencia;

            END;
            -- ACTUALIZA SALDOS PLANILLA
            dbms_output.put_line('ACTUALIZA SALDOS PLANILLA');
            sp_actualiza_saldo_from_planilla(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia);
            COMMIT;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Proceso completado correctamente ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

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
    END sp_planilla_cxc;

    PROCEDURE sp_planilla_cxp (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_coduser   IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    ) AS
        v_actualizar VARCHAR2(1) := 'S';
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
    -- LA PLANILLA TIENE ASIGNADO NUMERO DE ASIENTO????
        IF pack_descontabilizar.sp_existe_asiento_cxp(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia) = 'N' THEN
            pout_mensaje := 'La Planilla no Tiene Numero de Asiento ...!';
            v_actualizar := 'N';
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        BEGIN
            UPDATE prov102
            SET
                situac = 'A',
                usuari = pin_coduser,
                tippla = 100
            WHERE
                    id_cia = pin_id_cia
                AND libro = pin_libro
                AND periodo = pin_periodo
                AND mes = pin_mes
                AND secuencia = pin_secuencia;

        EXCEPTION
            WHEN OTHERS THEN
                v_actualizar := 'N';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        IF v_actualizar = 'S' THEN
            BEGIN
                FOR i IN (
                    SELECT
                        *
                    FROM
                        prov105
                    WHERE
                            id_cia = pin_id_cia
                        AND libro = pin_libro
                        AND periodo = pin_periodo
                        AND mes = pin_mes
                        AND secuencia = pin_secuencia
                ) LOOP
                    DELETE FROM prov100
                    WHERE
                            id_cia = pin_id_cia
                        AND tipo = i.tipo
                        AND docu = i.docu;

                END LOOP;

                UPDATE prov105
                SET
                    situac = 'A',
                    usuari = pin_coduser
                WHERE
                        id_cia = pin_id_cia
                    AND libro = pin_libro
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND secuencia = pin_secuencia;

            END;

            BEGIN
            -- DELETE
                DELETE FROM prov101
                WHERE
                        id_cia = pin_id_cia
                    AND libro = pin_libro
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND secuencia = pin_secuencia;

            END;

            BEGIN
            -- ANULAR
                UPDATE asienhea
                SET
                    situac = 9,
                    factua = current_date,
                    usuari = pin_coduser
                WHERE
                        id_cia = pin_id_cia
                    AND libro = pin_libro
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND asiento = pin_secuencia;

                DELETE FROM asiendet
                WHERE
                        id_cia = pin_id_cia
                    AND libro = pin_libro
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND asiento = pin_secuencia;

                DELETE FROM movimientos
                WHERE
                        id_cia = pin_id_cia
                    AND libro = pin_libro
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND asiento = pin_secuencia;

            END;

            sp_actualiza_saldo_from_planilla(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia);
            COMMIT;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Proceso completado correctamente ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

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
    END sp_planilla_cxp;

    PROCEDURE sp_asiento (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,--asiento
        pin_usuario   IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    ) AS
        pout_mensaje VARCHAR2(1000 CHAR);
        v_aux        VARCHAR2(1 CHAR);
    BEGIN
        UPDATE asienhea
        SET
            situac = 1,
            factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS'),
            usuari = pin_usuario
        WHERE
                id_cia = pin_id_cia
            AND libro = TRIM(pin_libro)
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND asiento = pin_secuencia;

        DELETE FROM movimientos
        WHERE
                id_cia = pin_id_cia
            AND libro = TRIM(pin_libro)
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND asiento = pin_secuencia;

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
    END sp_asiento;

END;

/
