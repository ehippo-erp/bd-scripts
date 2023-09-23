--------------------------------------------------------
--  DDL for Package Body PACK_ASISTENCIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ASISTENCIA" AS

    FUNCTION sp_reporte (
        pin_id_cia  NUMBER,
        pin_coduser VARCHAR2,
        pin_fdesde  DATE,
        pin_fhasta  DATE
    ) RETURN datatable_reporte
        PIPELINED
    AS
        v_table datatable_reporte;
    BEGIN
        SELECT
            pin_id_cia,
            to_char(t.fecha, 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH') AS mes,
            to_char(t.fecha, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')   AS diasemana,
            t.fecha                                                AS fecha,
            u1.coduser,
            u1.nombres                                             AS nombres,
            u1.coduser,
            NULL,
            NULL,
            u1.cargo                                               AS descar,
            CASE
                WHEN a1.fcreac IS NOT NULL
                     OR a2.fcreac IS NOT NULL THEN
                    'Jornada Laboral'
                ELSE
                    ' '
            END,
            CASE
                WHEN a1.fcreac IS NOT NULL
                     OR a2.fcreac IS NOT NULL THEN
                    'Diurno'
                ELSE
                    ' '
            END,
            8,
            1,
            a1.usuari                                              AS uentrada,
            to_char(a1.fcreac, 'HH24:MI:SS')                       AS fentrada,
            a2.usuari                                              AS usalida,
            to_char(a2.fcreac, 'HH24:MI:SS')                       AS fsalida,
            NULL,
            NULL,
            NULL,
            NULL
        BULK COLLECT
        INTO v_table
        FROM
            tiempo     t
            LEFT OUTER JOIN usuarios   u1 ON u1.id_cia = pin_id_cia
                                           AND u1.swacti = 'S'
            LEFT OUTER JOIN asistencia a1 ON a1.id_cia = pin_id_cia
                                             AND a1.usuari = u1.coduser
                                             AND trunc(a1.fcreac) = t.fecha
                                             AND a1.codturno = 1
            LEFT OUTER JOIN asistencia a2 ON a2.id_cia = pin_id_cia
                                             AND a2.usuari = u1.coduser
                                             AND trunc(a2.fcreac) = t.fecha
                                             AND a2.codturno = 2
        WHERE
            t.fecha BETWEEN pin_fdesde AND pin_fhasta
            AND ( pin_coduser IS NULL
                  OR u1.coduser = pin_coduser )
        ORDER BY
            u1.coduser,
            t.fecha ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte;

    FUNCTION sp_obtener (
        pin_id_cia   NUMBER,
        pin_codasist NUMBER
    ) RETURN datatable_asistencia
        PIPELINED
    AS
        v_table datatable_asistencia;
    BEGIN
        SELECT
            a.codasist  AS codasist,
            a.usuari    AS coduser,
            a.codsuc,
            s.sucursal,
            a.direccion AS direccion,
            a.latitud   AS latitud,
            a.longitud  AS longitud,
            a.fcreac    AS fcreac,
            a.codturno  AS codturno,
            u.nombres,
            tua.descri  AS descturno
        BULK COLLECT
        INTO v_table
        FROM
            asistencia       a
            LEFT OUTER JOIN usuarios         u ON u.id_cia = a.id_cia
                                          AND u.coduser = a.usuari
            LEFT OUTER JOIN turno_asistencia tua ON tua.id_cia = a.id_cia
                                                    AND tua.codturno = a.codturno
            LEFT OUTER JOIN tarea_asistencia ta ON ta.id_cia = a.id_cia
                                                   AND ta.codasist = a.codasist
            LEFT OUTER JOIN sucursal         s ON s.id_cia = a.id_cia
                                          AND s.codsuc = a.codsuc
        WHERE
                a.id_cia = pin_id_cia
            AND a.codasist = pin_codasist
        ORDER BY
            a.codasist;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_codtar  NUMBER,
        pin_codturn NUMBER,
        pin_coduser VARCHAR2,
        pin_fdesde  DATE,
        pin_fhasta  DATE
    ) RETURN datatable_asistencia
        PIPELINED
    AS
        v_table datatable_asistencia;
    BEGIN
        SELECT
            a.codasist  AS codasist,
            a.usuari    AS coduser,
            a.codsuc,
            s.sucursal,
            a.direccion AS direccion,
            a.latitud   AS latitud,
            a.longitud  AS longitud,
            a.fcreac    AS fcreac,
            a.codturno  AS codturno,
            u.nombres,
            tua.descri  AS descturno
        BULK COLLECT
        INTO v_table
        FROM
            asistencia       a
            LEFT OUTER JOIN usuarios         u ON u.id_cia = a.id_cia
                                          AND u.coduser = a.usuari
            LEFT OUTER JOIN turno_asistencia tua ON tua.id_cia = a.id_cia
                                                    AND tua.codturno = a.codturno
            LEFT OUTER JOIN tarea_asistencia ta ON ta.id_cia = a.id_cia
                                                   AND ta.codasist = a.codasist
            LEFT OUTER JOIN sucursal         s ON s.id_cia = a.id_cia
                                          AND s.codsuc = a.codsuc
        WHERE
                a.id_cia = pin_id_cia
            AND ( trunc(a.fcreac) BETWEEN pin_fdesde AND pin_fhasta )
            AND ( pin_codtar IS NULL
                  OR pin_codtar = - 1
                  OR ta.numinttar = pin_codtar )
            AND ( pin_codturn IS NULL
                  OR pin_codturn = - 1
                  OR a.codturno = pin_codturn )
            AND ( pin_coduser IS NULL
                  OR a.usuari = pin_coduser )
        ORDER BY
            a.codasist;

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
--                "coduser":"CALV",
--                "codsuc":2,
--                "direccion":"DIRECCION DE S2",
--                "latitud":0,
--                "longitud":0,
--                "codturno":1
--                }';
--pack_asistencia .sp_save(25, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_asistencia.sp_obtener(25,8021);
--
--SELECT * FROM pack_asistencia.sp_buscar(25,-1,-1,NULL,
--to_date('01/12/2022','DD/MM/YYYY'),to_date('01/12/2023','DD/MM/YYYY'));
--
--SELECT * FROM pack_asistencia.sp_reporte(25,NULL,
--to_date('01/11/2022','DD/MM/YYYY'),to_date('01/12/2022','DD/MM/YYYY'));

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o               json_object_t;
        rec_asistencia  asistencia%rowtype;
        v_namegenerador VARCHAR2(60);
        v_codasist      asistencia.codasist%TYPE;
        v_accion        VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_asistencia.id_cia := pin_id_cia;
        rec_asistencia.codasist := o.get_number('codasist');
        rec_asistencia.usuari := o.get_string('coduser');
        rec_asistencia.codsuc := o.get_string('codsuc');
        rec_asistencia.direccion := o.get_string('direccion');
        rec_asistencia.latitud := o.get_string('latitud');
        rec_asistencia.longitud := o.get_string('longitud');
        rec_asistencia.codturno := o.get_number('codturno');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO asistencia (
                    id_cia,
                    codasist,
                    usuari,
                    fcreac,
                    codsuc,
                    direccion,
                    latitud,
                    longitud,
                    codturno
                ) VALUES (
                    rec_asistencia.id_cia,
                    - 1,
                    rec_asistencia.usuari,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    rec_asistencia.codsuc,
                    rec_asistencia.direccion,
                    rec_asistencia.latitud,
                    rec_asistencia.longitud,
                    rec_asistencia.codturno
                );

                BEGIN
                    v_namegenerador := upper('GEN_ASISTENCIA_PLANILLA_')
                                       || pin_id_cia;
                    EXECUTE IMMEDIATE 'select '
                                      || v_namegenerador
                                      || '.CURRVAL FROM DUAL'
                    INTO v_codasist;
                END;

            WHEN 2 THEN
                v_accion := 'La actualización';
--                UPDATE asistencia 
--                SET
--                    uactua =
--                        CASE
--                            WHEN rec_asistencia .uactua IS NULL THEN
--                                uactua
--                            ELSE
--                                rec_asistencia .uactua
--                        END,
--                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
--                WHERE
--                        id_cia = rec_asistencia .id_cia
--                    AND codasist = rec_asistencia .codasist;

                NULL;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                v_codasist := rec_asistencia.codasist;
                DELETE FROM asistencia
                WHERE
                        id_cia = rec_asistencia.id_cia
                    AND codasist = rec_asistencia.codasist;

        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!',
                'codasist' VALUE v_codasist
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
                    'message' VALUE 'El registro con el ID del Turno de Asistencia [ '
                                    || rec_asistencia.codasist
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
                        'message' VALUE 'No se insertar o modificar este registro porque el Usuario [ '
                                        || rec_asistencia.usuari
                                        || ' ] no existe ...! '
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
    END sp_save;

END;

/
