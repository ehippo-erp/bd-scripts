--------------------------------------------------------
--  DDL for Package Body PACK_TR_TAREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_TR_TAREA" AS

    FUNCTION sp_proyecto_grupo_usuario (
        pin_id_cia        NUMBER,
        pin_numint_proyec NUMBER
    ) RETURN datatable_grupo_usuario
        PIPELINED
    AS
        v_table datatable_grupo_usuario;
    BEGIN
        SELECT
            t.id_cia,
            t.codgrupo,
            u.desgrupo
        BULK COLLECT
        INTO v_table
        FROM
            proyecto_tarea_grupo t
            LEFT OUTER JOIN grupo_usuario        u ON u.id_cia = t.id_cia
                                               AND u.codgrupo = t.codgrupo
        WHERE
                t.id_cia = pin_id_cia
            AND t.numint_proyec = pin_numint_proyec;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_proyecto_grupo_usuario;

    FUNCTION sp_count_subtareas (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN NUMBER AS
        v_number NUMBER := 0;
    BEGIN
        SELECT
            nvl(COUNT(0),
                0)
        INTO v_number
        FROM
            tarea st
        WHERE
                st.id_cia = pin_id_cia
            AND st.numint_tpadre = pin_numint;

        RETURN v_number;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN 0;
    END sp_count_subtareas;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_tarea
        PIPELINED
    AS
        v_table datatable_tarea;
    BEGIN
        SELECT
            t.id_cia,
            t.numint                         AS numint,
            t.numtta                         AS numero,
            t.usuari                         AS uactua,
            u.nombres                        AS nomuactua,
            u.cargo                          AS cargo,
            t.titulo                         AS titulo,
            t.codtta                         AS codtta,
            t.codacc                         AS codacc,
            acc.nomacc                       AS codaccdesc,
            t.codpri                         AS codpri,
            p.nompri                         AS codpridesc,
            t.fvisita                        AS fvisita,
            to_char(t.hinicio, 'HH24:MI:SS') AS hinicio,
            t.ffinal                         AS ffinal,
            to_char(t.hfinal, 'HH24:MI:SS')  AS hfinal,
            t.observacion                    AS observacion,
            t.situac                         AS situac,
            s.dessit                         AS situacdesc,
            t.fcreac                         AS fcreac,
            t.factua                         AS factua,
            t.tipcli                         AS tipcli,
            cl.codcli                        AS codcli,
            cl.razonc                        AS razonc,
            cl.telefono                      AS telefono,
            cl.email                         AS email,
            cl.direc1                        AS direccion,
            c.codcont                        AS codcont,
            c.nomcont                        AS nomcont,
            c.telefono                       AS cont_telefono,
            c.email                          AS cont_email,
            t.numint_tpadre,
            t.numint_proyec,
            pt.titulo                        AS proyecto,
            t.coduserori                     AS coduser,
            ua.nombres                       AS nomcoduser,
            ua.cargo                         AS ua_cargo
        BULK COLLECT
        INTO v_table
        FROM
            tarea          t
            LEFT OUTER JOIN usuarios       u ON u.id_cia = t.id_cia
                                          AND u.coduser = t.usuari
            LEFT OUTER JOIN usuarios       ua ON ua.id_cia = t.id_cia
                                           AND ua.coduser = t.coduserori
            LEFT OUTER JOIN cliente        cl ON cl.id_cia = t.id_cia
                                          AND cl.codcli = t.codcli
            LEFT OUTER JOIN contacto       c ON c.id_cia = t.id_cia
                                          AND c.codcont = t.codcon
            LEFT OUTER JOIN situacion      s ON s.id_cia = t.id_cia
                                           AND s.situac = t.situac
                                           AND s.tipdoc = 222
            LEFT OUTER JOIN tipotarea      tt ON tt.id_cia = t.id_cia
                                            AND tt.codtta = t.codtta
            LEFT OUTER JOIN acciontarea    acc ON acc.id_cia = t.id_cia
                                               AND acc.codacc = t.codacc
            LEFT OUTER JOIN prioridad      p ON p.id_cia = t.id_cia
                                           AND p.codpri = t.codpri
            LEFT OUTER JOIN proyecto_tarea pt ON pt.id_cia = t.id_cia
                                                 AND pt.numint = t.numint_proyec
        WHERE
                t.id_cia = pin_id_cia
            AND t.numint = pin_numint;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_coduser VARCHAR2,
        pin_fdesde  DATE,
        pin_fhasta  DATE,
        pin_situac  VARCHAR2,
        pin_codtta  NUMBER,
        pin_codcli  VARCHAR2,
        pin_offset  NUMBER,
        pin_limit   NUMBER
    ) RETURN datatable_buscar_tarea
        PIPELINED
    AS
        v_table datatable_buscar_tarea;
    BEGIN
        SELECT
            t.id_cia,
            t.numint                                             AS numint,
            t.numtta                                             AS numero,
            t.titulo                                             AS titulo,
            t.ffinal                                             AS fecha,
            t.hfinal                                             AS hora,
            t.codpri                                             AS prioridad,
            decode(t.situac, 'D', 'true', 'false')               AS completado,
            pack_tr_tarea.sp_count_subtareas(t.id_cia, t.numint) AS subtareas,
            t.usuari                                             AS coduser,
            t.coduserori                                         AS asignado,
            t.situac                                             AS situac,
            t.factua
        BULK COLLECT
        INTO v_table
        FROM
            tarea t
        WHERE
                t.id_cia = pin_id_cia
            AND ( pin_coduser IS NULL
                  OR t.coduserori = pin_coduser )
            AND ( ( pin_fdesde IS NULL
                    AND pin_fhasta IS NULL )
                  OR ( t.fvisita BETWEEN pin_fdesde AND pin_fhasta ) )
            AND ( pin_situac IS NULL
                  OR t.situac = pin_situac )
            AND ( nvl(pin_codtta, - 1) = - 1
                  OR t.codtta = pin_codtta )
            AND ( pin_codcli IS NULL
                  OR t.codcli = pin_codcli )
        ORDER BY
            t.numint DESC
        OFFSET nvl(pin_offset, 0) ROWS FETCH NEXT nvl(pin_limit, 1000) ROWS ONLY;

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
--  "numint": "",
--  "tipdoc": 222,
--  "codtta": 004,
--  "numtta": 2018030023,
--  "codcli": 20506982465,
--  "codcon": 145,
--  "codven": 0,
--  "codpri": 1,
--  "codacc": 16,
--  "fvisita": "2022-01-01",
--  "hinicio": "15:00:45",
--  "hfinal": "18:00:45",
--  "tiempo": 0,
--  "observacion": "TEST",
--  "usuari": "admin",
--  "situac": "D",
--  "razonc": "GRUPO TSI S.A.C.",
--  "email": "",
--  "direccion": "AV. LA ALBORADA 1577 - CERCADO DE LIMA",
--  "nomcont": "Franco Cabanillas Gomez",
--  "telefono": "9392323274",
--  "coduserori": "",
--  "ideventogoogle": "",
--  "ffinal": "2022-01-02",
--  "tipcli": "A",
--  "titulo": "Soporte - Agregar detalle de soporte y adjuntos",
--  "numint_tpadre": 0,
--  "numint_proyec": 0
--}';
--    pack_tr_tarea.sp_save(25, cadjson, 1, mensaje);
--
--    dbms_output.put_line(mensaje);
--
--END;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o         json_object_t;
        rec_tarea tarea%rowtype;
        v_accion  VARCHAR2(50) := '';
        v_hinicio VARCHAR2(50) := '';
        v_hfinal  VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_tarea.id_cia := pin_id_cia;
        rec_tarea.numint := o.get_number('numint');
        rec_tarea.tipdoc := 222;
        rec_tarea.codtta := o.get_string('codtta');
        rec_tarea.numtta := o.get_string('numtta');
        rec_tarea.codcli := o.get_string('codcli');
        rec_tarea.codcon := o.get_number('codcon');
        rec_tarea.codven := o.get_number('codven');
        rec_tarea.codpri := o.get_number('codpri');
        rec_tarea.codacc := o.get_number('codacc');
        rec_tarea.fvisita := o.get_date('fvisita');
        rec_tarea.ffinal := o.get_date('ffinal');
        v_hinicio := o.get_string('hinicio');
        v_hfinal := o.get_string('hfinal');
        IF v_hinicio IS NOT NULL THEN
            rec_tarea.hinicio := TO_TIMESTAMP ( to_char(rec_tarea.fvisita, 'DD/MM/YY')
                                                || ' '
                                                || o.get_string('hinicio'), 'DD/MM/YY HH24:MI:SS' );
        END IF;

        IF v_hfinal IS NOT NULL THEN
            rec_tarea.hfinal := TO_TIMESTAMP ( to_char(rec_tarea.ffinal, 'DD/MM/YY')
                                               || ' '
                                               || o.get_string('hfinal'), 'DD/MM/YY HH24:MI:SS' );
        END IF;

        rec_tarea.tiempo := o.get_number('tiempo');
        rec_tarea.observacion := o.get_string('observacion');
        rec_tarea.usuari := o.get_string('uactua');
        rec_tarea.situac := o.get_string('situac');
        rec_tarea.razonc := o.get_string('razonc');
        rec_tarea.email := o.get_string('email');
        rec_tarea.direccion := o.get_string('direccion');
        rec_tarea.nomcont := o.get_string('nomcont');
        rec_tarea.telefono := o.get_string('telefono');
        rec_tarea.coduserori := o.get_string('coduser');
        rec_tarea.ideventogoogle := o.get_string('ideventogoogle');
        rec_tarea.tipcli := o.get_string('tipcli');
        rec_tarea.titulo := o.get_string('titulo');
        rec_tarea.numint_tpadre := o.get_number('numint_tpadre');
        rec_tarea.numint_proyec := o.get_number('numint_proyec');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                IF nvl(rec_tarea.numint, 0) = 0 THEN
                    BEGIN
                        SELECT
                            MAX(numint)
                        INTO rec_tarea.numint
                        FROM
                            tarea
                        WHERE
                            id_cia = pin_id_cia;

                    EXCEPTION
                        WHEN no_data_found THEN
                            rec_tarea.numint := 0;
                    END;

                    rec_tarea.numint := nvl(rec_tarea.numint, 0) + 1;
                END IF;

                v_accion := 'La inserción';
                INSERT INTO tarea (
                    id_cia,
                    numint,
                    tipdoc,
                    codtta,
                    numtta,
                    codcli,
                    codcon,
                    codven,
                    codpri,
                    codacc,
                    fvisita,
                    hinicio,
                    hfinal,
                    tiempo,
                    observacion,
                    fcreac,
                    factua,
                    usuari,
                    situac,
                    razonc,
                    email,
                    direccion,
                    nomcont,
                    telefono,
                    coduserori,
                    ideventogoogle,
                    ffinal,
                    tipcli,
                    titulo,
                    numint_tpadre,
                    numint_proyec
                ) VALUES (
                    rec_tarea.id_cia,
                    rec_tarea.numint,
                    rec_tarea.tipdoc,
                    rec_tarea.codtta,
                    rec_tarea.numtta,
                    rec_tarea.codcli,
                    rec_tarea.codcon,
                    rec_tarea.codven,
                    rec_tarea.codpri,
                    rec_tarea.codacc,
                    rec_tarea.fvisita,
                    rec_tarea.hinicio,
                    rec_tarea.hfinal,
                    rec_tarea.tiempo,
                    rec_tarea.observacion,
                    current_timestamp,
                    current_timestamp,
                    rec_tarea.usuari,
                    rec_tarea.situac,
                    rec_tarea.razonc,
                    rec_tarea.email,
                    rec_tarea.direccion,
                    rec_tarea.nomcont,
                    rec_tarea.telefono,
                    rec_tarea.coduserori,
                    rec_tarea.ideventogoogle,
                    rec_tarea.ffinal,
                    rec_tarea.tipcli,
                    rec_tarea.titulo,
                    rec_tarea.numint_tpadre,
                    rec_tarea.numint_proyec
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE tarea
                SET
                    tipdoc = nvl(rec_tarea.tipdoc, tipdoc),
                    codtta = nvl(rec_tarea.codtta, codtta),
                    numtta = nvl(rec_tarea.numtta, numtta),
                    codcli = nvl(rec_tarea.codcli, codcli),
                    codcon = nvl(rec_tarea.codcon, codcon),
                    codven = nvl(rec_tarea.codven, codven),
                    codpri = nvl(rec_tarea.codpri, codpri),
                    codacc = nvl(rec_tarea.codacc, codacc),
                    fvisita = nvl(rec_tarea.fvisita, fvisita),
                    hinicio = nvl(rec_tarea.hinicio, hinicio),
                    hfinal = nvl(rec_tarea.hfinal, hfinal),
                    tiempo = nvl(rec_tarea.tiempo, tiempo),
                    observacion = nvl(rec_tarea.observacion, observacion),
                    situac = nvl(rec_tarea.situac, situac),
                    razonc = nvl(rec_tarea.razonc, razonc),
                    email = nvl(rec_tarea.email, email),
                    direccion = nvl(rec_tarea.direccion, rec_tarea.direccion),
                    nomcont = nvl(rec_tarea.nomcont, nomcont),
                    telefono = nvl(rec_tarea.telefono, telefono),
                    coduserori = nvl(rec_tarea.coduserori, coduserori),
                    ideventogoogle = nvl(rec_tarea.ideventogoogle, ideventogoogle),
                    ffinal = nvl(rec_tarea.ffinal, ffinal),
                    tipcli = nvl(rec_tarea.tipcli, tipcli),
                    titulo = nvl(rec_tarea.titulo, titulo),
                    numint_tpadre = nvl(rec_tarea.numint_tpadre, numint_tpadre),
                    numint_proyec = nvl(rec_tarea.numint_proyec, numint_proyec),
                    usuari = rec_tarea.usuari,
                    factua = current_timestamp
                WHERE
                        id_cia = rec_tarea.id_cia
                    AND numint = rec_tarea.numint;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM tarea
                WHERE
                        id_cia = rec_tarea.id_cia
                    AND numint = rec_tarea.numint
                    AND situac = 'A';

        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!'
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
                    'message' VALUE 'LA TAREA CON EL NUMINT [ '
                                    || rec_tarea.numint
                                    || ' ] YA EXISTE Y NO PUEDE DUPLICARSE'
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
--            IF sqlcode = -2291 THEN
--                SELECT
--                    JSON_OBJECT(
--                        'status' VALUE 1.1,
--                        'message' VALUE 'No se insertar o modificar este registro porque el Banco [ '
--                                        || rec_tarea.codban
--                                        || ' ] no existe ...! '
--                    )
--                INTO pin_mensaje
--                FROM
--                    dual;
--
--            ELSE
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

--            END IF;
    END sp_save;

    FUNCTION sp_tarea_pendiente (
        pin_id_cia        NUMBER,
        pin_coduser       VARCHAR2,
        pin_numint_proyec NUMBER
    ) RETURN datatable_tarea_pendiente
        PIPELINED
    AS
        v_table datatable_tarea_pendiente;
    BEGIN
        SELECT
            t.id_cia,
            t.numint                                             AS numint,
            t.numtta                                             AS numero,
            t.titulo                                             AS titulo,
            t.ffinal                                             AS fecha,
            t.hfinal                                             AS hora,
            t.codpri                                             AS prioridad,
            decode(t.situac, 'D', 'true', 'false')               AS completado,
            pack_tr_tarea.sp_count_subtareas(t.id_cia, t.numint) AS subtareas,
            t.usuari                                             AS coduser,
            t.coduserori                                         AS asignado
        BULK COLLECT
        INTO v_table
        FROM
            tarea t
        WHERE
                t.id_cia = pin_id_cia
            AND t.usuari = pin_coduser
            AND ( nvl(pin_numint_proyec, - 1) = - 1
                  OR t.numint_proyec = pin_numint_proyec )
            AND t.situac = 'A'
            AND nvl(t.numint_tpadre, 0) = 0
        ORDER BY
            t.fvisita DESC,
            t.hinicio DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_tarea_pendiente;

    FUNCTION sp_tarea_completada (
        pin_id_cia        NUMBER,
        pin_coduser       VARCHAR2,
        pin_numint_proyec NUMBER,
        pin_offset        NUMBER,
        pin_limit         NUMBER
    ) RETURN datatable_tarea_pendiente
        PIPELINED
    AS
        v_table datatable_tarea_pendiente;
    BEGIN
        SELECT
            t.id_cia,
            t.numint                                             AS numint,
            t.numtta                                             AS numero,
            t.titulo                                             AS titulo,
            t.ffinal                                             AS fecha,
            t.hfinal                                             AS hora,
            t.codpri                                             AS prioridad,
            decode(t.situac, 'D', 'true', 'false')               AS completado,
            pack_tr_tarea.sp_count_subtareas(t.id_cia, t.numint) AS subtareas,
            t.usuari                                             AS coduser,
            t.coduserori                                         AS asignado
        BULK COLLECT
        INTO v_table
        FROM
            tarea t
        WHERE
                t.id_cia = pin_id_cia
            AND t.usuari = pin_coduser
            AND ( nvl(pin_numint_proyec, - 1) = - 1
                  OR t.numint_proyec = pin_numint_proyec )
            AND t.situac = 'D'
            AND nvl(t.numint_tpadre, 0) = 0
        ORDER BY
            t.factua DESC
        OFFSET nvl(pin_offset, 0) ROWS FETCH NEXT nvl(pin_limit, 1000) ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_tarea_completada;

    FUNCTION sp_buscar_subtareas (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_tarea_pendiente
        PIPELINED
    AS
        v_table datatable_tarea_pendiente;
    BEGIN
        SELECT
            t.id_cia,
            t.numint                                             AS numint,
            t.numtta                                             AS numero,
            t.titulo                                             AS titulo,
            t.ffinal                                             AS fecha,
            t.hfinal                                             AS hora,
            t.codpri                                             AS prioridad,
            decode(t.situac, 'D', 'true', 'false')               AS completado,
            pack_tr_tarea.sp_count_subtareas(t.id_cia, t.numint) AS subtareas,
            t.usuari                                             AS coduser,
            t.coduserori                                         AS asignado
        BULK COLLECT
        INTO v_table
        FROM
            tarea t
        WHERE
                t.id_cia = pin_id_cia
            AND t.numint_tpadre = pin_numint
        ORDER BY
            t.fvisita DESC,
            t.hinicio DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_subtareas;

    FUNCTION sp_tarea_pendiente_proyecto (
        pin_id_cia        NUMBER,
        pin_numint_proyec NUMBER,
        pin_offset        NUMBER,
        pin_limit         NUMBER
    ) RETURN datatable_tarea_pendiente
        PIPELINED
    AS
        v_table datatable_tarea_pendiente;
    BEGIN
        SELECT
            t.id_cia,
            t.numint                                             AS numint,
            t.numtta                                             AS numero,
            t.titulo                                             AS titulo,
            t.ffinal                                             AS fecha,
            t.hfinal                                             AS hora,
            t.codpri                                             AS prioridad,
            decode(t.situac, 'D', 'true', 'false')               AS completado,
            pack_tr_tarea.sp_count_subtareas(t.id_cia, t.numint) AS subtareas,
            t.usuari                                             AS coduser,
            t.coduserori                                         AS asignado
        BULK COLLECT
        INTO v_table
        FROM
            tarea t
        WHERE
                t.id_cia = pin_id_cia
            AND t.numint_proyec = pin_numint_proyec
            AND t.situac = 'A'
            AND nvl(t.numint_tpadre, 0) = 0
        ORDER BY
            t.fvisita DESC,
            t.hinicio DESC
        OFFSET nvl(pin_offset, 0) ROWS FETCH NEXT nvl(pin_limit, 1000) ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_tarea_pendiente_proyecto;

    FUNCTION sp_tarea_completada_proyecto (
        pin_id_cia        NUMBER,
        pin_numint_proyec NUMBER,
        pin_offset        NUMBER,
        pin_limit         NUMBER
    ) RETURN datatable_tarea_pendiente
        PIPELINED
    AS
        v_table datatable_tarea_pendiente;
    BEGIN
        SELECT
            t.id_cia,
            t.numint                                             AS numint,
            t.numtta                                             AS numero,
            t.titulo                                             AS titulo,
            t.ffinal                                             AS fecha,
            t.hfinal                                             AS hora,
            t.codpri                                             AS prioridad,
            decode(t.situac, 'D', 'true', 'false')               AS completado,
            pack_tr_tarea.sp_count_subtareas(t.id_cia, t.numint) AS subtareas,
            t.usuari                                             AS coduser,
            t.coduserori                                         AS asignado
        BULK COLLECT
        INTO v_table
        FROM
            tarea t
        WHERE
                t.id_cia = pin_id_cia
            AND t.numint_proyec = pin_numint_proyec
            AND t.situac = 'D'
            AND nvl(t.numint_tpadre, 0) = 0
        ORDER BY
            t.fvisita DESC,
            t.hinicio DESC
        OFFSET nvl(pin_offset, 0) ROWS FETCH NEXT nvl(pin_limit, 1000) ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_tarea_completada_proyecto;

    FUNCTION sp_proyecto_asignado_usuario (
        pin_id_cia  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN datatable_proyecto_asignado_usuario
        PIPELINED
    AS
        v_table datatable_proyecto_asignado_usuario;
    BEGIN
        SELECT DISTINCT
            p.id_cia,
            p.numint,
            p.titulo,
            p.color
        BULK COLLECT
        INTO v_table
        FROM
            proyecto_tarea         p
            LEFT OUTER JOIN proyecto_tarea_grupo   ptg ON ptg.id_cia = p.id_cia
                                                        AND ptg.numint_proyec = p.numint
            LEFT OUTER JOIN usuario_grupo          ug ON ug.id_cia = p.id_cia
                                                AND ug.codgrupo = ptg.codgrupo
            LEFT OUTER JOIN proyecto_tarea_usuario ptu ON ptu.id_cia = p.id_cia
                                                          AND ptu.numint_proyec = p.numint
        WHERE
                p.id_cia = pin_id_cia
            AND ( p.ucreac = pin_coduser
                  OR ug.coduser = pin_coduser
                  OR ptu.coduser = pin_coduser );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_proyecto_asignado_usuario;

END;

/
