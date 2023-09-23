--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_DELETE" AS

    PROCEDURE sp_registro_compras (
        pin_id_cia       IN NUMBER,
        pin_fimportacion IN DATE,
        pin_coduser      IN VARCHAR2,
        pin_mensaje      OUT VARCHAR2
    ) AS

        pin_libro     VARCHAR2(10 CHAR) := '04';
        pout_mensaje  VARCHAR2(1000 CHAR) := '';
        v_mensaje     VARCHAR2(1000 CHAR) := '';
        v_correlativo NUMBER := 0;
        v_id_log      NUMBER := 0;
        v_aux         VARCHAR2(1 CHAR) := 'S';
    BEGIN
        BEGIN
            SELECT
                nvl(id_log, 1)
            INTO v_id_log
            FROM
                log_import_delete
            WHERE
                id_cia = pin_id_cia
            ORDER BY
                id_log DESC
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                v_id_log := 1;
        END;

        INSERT INTO log_import_delete VALUES (
            pin_id_cia,
            v_id_log,
            1,
            'ELIMINACION DE LA IMPORTACION DEL REGISTRO DE COMPRAS',
            'N',
            NULL,
            pin_coduser,
            pin_coduser,
            current_timestamp,
            current_timestamp
        );

        COMMIT; -- INDEPENDIENTEMENTE SI LA TRANSACCION FALLA O NO, SE REGISTRA SIEMPRE EL LOG

        BEGIN
            SELECT
                'S'
            INTO v_aux
            FROM
                compr010
            WHERE
                    id_cia = pin_id_cia
                AND trunc(fcreac) = trunc(pin_fimportacion)
                AND libro = pin_libro
                AND swmigra = 'S'
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'NO EXISTE NINGUN REGISTRO DE COMPRAS IMPORTADO EL ' || to_char(pin_fimportacion, 'DD/MM/YY');
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        FOR i IN (
            SELECT
                *
            FROM
                compr010
            WHERE
                    id_cia = pin_id_cia
                AND trunc(fcreac) = trunc(pin_fimportacion)
                AND libro = pin_libro
                AND swmigra = 'S'
        ) LOOP
            DELETE FROM movimientos
            WHERE
                    id_cia = i.id_cia
                AND libro = i.libro
                AND periodo = i.periodo
                AND mes = i.mes
                AND asiento = i.asiento;

            DELETE FROM asiendet
            WHERE
                    id_cia = i.id_cia
                AND libro = i.libro
                AND periodo = i.periodo
                AND mes = i.mes
                AND asiento = i.asiento;

            DELETE FROM asienhea
            WHERE
                    id_cia = i.id_cia
                AND libro = i.libro
                AND periodo = i.periodo
                AND mes = i.mes
                AND asiento = i.asiento;

            DELETE FROM prov100
            WHERE
                    id_cia = i.id_cia
                AND tipo = i.tipo
                AND docu = i.docume;

        END LOOP;

        FOR j IN (
            SELECT DISTINCT
                periodo,
                mes
            FROM
                compr010
            WHERE
                    id_cia = pin_id_cia
                AND trunc(fcreac) = trunc(pin_fimportacion)
                AND libro = pin_libro
                AND swmigra = 'S'
        ) LOOP
            BEGIN
                SELECT
                    nvl(asiento, 0)
                INTO v_correlativo
                FROM
                    asienhea
                WHERE
                        id_cia = pin_id_cia
                    AND libro = pin_libro
                    AND periodo = j.periodo
                    AND mes = j.mes
                ORDER BY
                    asiento DESC
                FETCH NEXT 1 ROWS ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    v_correlativo := 0;
            END;

            UPDATE libros
            SET
                secuencia = v_correlativo
            WHERE
                    id_cia = pin_id_cia
                AND codlib = pin_libro
                AND anno = j.periodo
                AND mes = j.mes;

        END LOOP;

        DELETE FROM compr010
        WHERE
                id_cia = pin_id_cia
            AND trunc(fcreac) = trunc(pin_fimportacion)
            AND libro = pin_libro
            AND swmigra = 'S';

        v_mensaje := 'LA IMPORTACION DEL REGISTRO DE COMPRAS DE LA FECHA '
                     || to_char(pin_fimportacion, 'DD/MM/YY')
                     || ' SE ELIMINO CORRECTAMENTE';
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_mensaje
            )
        INTO pin_mensaje
        FROM
            dual;

        UPDATE log_import_delete
        SET
            situac = 'S',
            mensaje = upper(v_mensaje)
        WHERE
                id_cia = pin_id_cia
            AND id_log = v_id_log;

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

            ROLLBACK;
            UPDATE log_import_delete
            SET
                situac = 'N',
                mensaje = upper(pout_mensaje)
            WHERE
                    id_cia = pin_id_cia
                AND id_log = v_id_log;

            COMMIT;
        WHEN OTHERS THEN
            v_mensaje := 'mensaje : '
                         || sqlerrm
                         || ' fijvar : '
                         || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE v_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
            UPDATE log_import_delete
            SET
                situac = 'N',
                mensaje = upper(v_mensaje)
            WHERE
                    id_cia = pin_id_cia
                AND id_log = v_id_log;

            COMMIT;
    END sp_registro_compras;

END;

/
