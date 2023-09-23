--------------------------------------------------------
--  DDL for Procedure SP_DISABLE_ENABLE_ALL_TRIGGERS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_DISABLE_ENABLE_ALL_TRIGGERS" (
    pin_id_log    IN NUMBER,
    pin_seguridad IN VARCHAR2,
    pin_mensaje   OUT VARCHAR2
) AS
    pout_mensaje VARCHAR2(1000) := '';
BEGIN

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(1000);
--BEGIN
--
--    sp_disable_enable_all_triggers(1,'TSI',mensaje);
--    DBMS_OUTPUT.PUT_LINE(mensaje);
--
--END;

    IF
        pin_id_log = 0
        AND pin_seguridad = 'TSI'
    THEN
        BEGIN
            FOR cur_rec IN (
                SELECT
                    object_name,
                    object_type
                FROM
                    user_objects
                WHERE
                    object_type IN ( 'TABLE' )
            ) LOOP
                BEGIN
                    IF cur_rec.object_type = 'TABLE' THEN
                        EXECUTE IMMEDIATE 'ALTER TABLE '
                                          || cur_rec.object_name
                                          || ' DISABLE ALL TRIGGERS';
                    END IF;

                EXCEPTION
                    WHEN OTHERS THEN
                        pin_mensaje := 'mensaje : '
                                       || sqlerrm
                                       || ' codigo :'
                                       || sqlcode;
                        pout_mensaje := 'Ocurrio un Error al Desactivar los Triggers [ '
                                        || pin_mensaje
                                        || ' ]';
                        dbms_output.put_line('FAILED: '
                                             || cur_rec.object_type
                                             || ' "'
                                             || cur_rec.object_name
                                             || '"');

                        RAISE pkg_exceptionuser.ex_error_inesperado;
                        ROLLBACK;
                END;
            END LOOP;

        END;
    ELSIF
        pin_id_log = 1
        AND pin_seguridad = 'TSI'
    THEN
        BEGIN
            FOR cur_rec IN (
                SELECT
                    object_name,
                    object_type
                FROM
                    user_objects
                WHERE
                    object_type IN ( 'TABLE' )
            ) LOOP
                BEGIN
                    IF cur_rec.object_type = 'TABLE' THEN
                        EXECUTE IMMEDIATE 'ALTER TABLE '
                                          || cur_rec.object_name
                                          || ' ENABLE ALL TRIGGERS';
                    END IF;

                EXCEPTION
                    WHEN OTHERS THEN
                        pin_mensaje := 'mensaje : '
                                       || sqlerrm
                                       || ' codigo :'
                                       || sqlcode;
                        pout_mensaje := 'Ocurrio un Error al Desactivar los Triggers [ '
                                        || pin_mensaje
                                        || ' ]';
                        dbms_output.put_line('FAILED: '
                                             || cur_rec.object_type
                                             || ' "'
                                             || cur_rec.object_name
                                             || '"');

                        RAISE pkg_exceptionuser.ex_error_inesperado;
                        ROLLBACK;
                END;
            END LOOP;
        END;

        pout_mensaje := ' Error ... Id Log o Pin de Seguridad Incorrectos, revise el procedimiento';
    ELSE
        RAISE pkg_exceptionuser.ex_error_inesperado;
    END IF;

    SELECT
        JSON_OBJECT(
            'status' VALUE 1.0,
            'message' VALUE 'Proceso culminado correctamente ...!'
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

    WHEN OTHERS THEN
        pout_mensaje := 'mensaje : '
                        || sqlerrm
                        || ' codigo :'
                        || sqlcode;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.2,
                'message' VALUE pout_mensaje
            )
        INTO pin_mensaje
        FROM
            dual;

        ROLLBACK;
END;

/
