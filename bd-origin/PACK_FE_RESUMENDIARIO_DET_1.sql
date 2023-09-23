--------------------------------------------------------
--  DDL for Package Body PACK_FE_RESUMENDIARIO_DET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_FE_RESUMENDIARIO_DET" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_idres  VARCHAR2,
        pin_numint VARCHAR2
    ) RETURN datatable_fe_resumendiario_det
        PIPELINED
    AS
        v_table datatable_fe_resumendiario_det;
    BEGIN
        SELECT
            pa.id_cia,
            pa.idres,
            pa.numint,
            pa.tipdoc,
            dt.descri AS destipdoc,
            pa.series,
            pa.numdoc,
            c.femisi,
            rdc.fgenera,
            c.codcli,
            c.razonc,
            c.tipmon,
            c.preven,
            pa.estado AS codest,
            CASE
                WHEN pa.estado = 'A' THEN
                    'Emitido'
                WHEN pa.estado = 'F' THEN
                    'Aceptado'
                WHEN pa.estado = 'J' THEN
                    'Observado'
                WHEN pa.estado = 'R' THEN
                    'Rechazado'
                WHEN pa.estado = 'B' THEN
                    'Baja'
                ELSE
                    'ND'
            END       AS desest
        BULK COLLECT
        INTO v_table
        FROM
            fe_resumendiario_det pa
            LEFT OUTER JOIN documentos_tipo      dt ON dt.id_cia = pa.id_cia
                                                  AND dt.tipdoc = pa.tipdoc
            LEFT OUTER JOIN documentos_cab       c ON c.id_cia = pa.id_cia
                                                AND c.numint = pa.numint
            LEFT OUTER JOIN fe_resumendiario_cab rdc ON rdc.id_cia = pa.id_cia
                                                        AND rdc.idres = pa.idres
        WHERE
                pa.id_cia = pin_id_cia
            AND pa.idres = pin_idres
            AND pa.numint = pin_numint;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_idres  VARCHAR2
    ) RETURN datatable_fe_resumendiario_det
        PIPELINED
    AS
        v_table datatable_fe_resumendiario_det;
    BEGIN
        SELECT
            pa.id_cia,
            pa.idres,
            pa.numint,
            pa.tipdoc,
            dt.descri AS destipdoc,
            pa.series,
            pa.numdoc,
            c.femisi,
            rdc.fgenera,
            c.codcli,
            c.razonc,
            c.tipmon,
            c.preven,
            pa.estado AS codest,
            CASE
                WHEN pa.estado = 'A' THEN
                    'Emitido'
                WHEN pa.estado = 'F' THEN
                    'Aceptado'
                WHEN pa.estado = 'J' THEN
                    'Observado'
                WHEN pa.estado = 'R' THEN
                    'Rechazado'
                WHEN pa.estado = 'B' THEN
                    'Baja'
                ELSE
                    'ND'
            END       AS desest
        BULK COLLECT
        INTO v_table
        FROM
            fe_resumendiario_det pa
            LEFT OUTER JOIN documentos_tipo      dt ON dt.id_cia = pa.id_cia
                                                  AND dt.tipdoc = pa.tipdoc
            LEFT OUTER JOIN documentos_cab       c ON c.id_cia = pa.id_cia
                                                AND c.numint = pa.numint
            LEFT OUTER JOIN fe_resumendiario_cab rdc ON rdc.id_cia = pa.id_cia
                                                        AND rdc.idres = pa.idres
        WHERE
                pa.id_cia = pin_id_cia
            AND pa.idres = pin_idres;

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
--                "idres":"102",
--                "numint":"98765431",
--                "series":"Admin",
--                "numdoc":"Admin"
--                }';
--pack_fe_resumendiario_det.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_fe_resumendiario_det.sp_obtener(66,'102','98765431');
--
--SELECT * FROM pack_fe_resumendiario_det.sp_buscar(66,'102');
--
--SELECT * FROM pack_fe_resumendiario_det.sp_obtener(66,'102','98765431');


--    PROCEDURE sp_save (
--        pin_id_cia  IN NUMBER,
--        pin_datos   IN VARCHAR2,
--        pin_opcdml  IN INTEGER,
--        pin_mensaje OUT VARCHAR2
--    ) AS
--        o                     json_object_t;
--        rec_fe_resumendiario_det fe_resumendiario_det%rowtype;
--        v_accion              VARCHAR2(50) := '';
--    BEGIN
--        o := json_object_t.parse(pin_datos);
--        rec_fe_resumendiario_det.id_cia := pin_id_cia;
--        rec_fe_resumendiario_det.idres := o.get_string('idres');
--        rec_fe_resumendiario_det.numint := o.get_string('numint');
--        rec_fe_resumendiario_det.series := o.get_string('series');
--        rec_fe_resumendiario_det.numdoc := o.get_string('numdoc');
--        v_accion := '';
--        CASE pin_opcdml
--            WHEN 1 THEN
--                v_accion := 'La inserción';
--                INSERT INTO fe_resumendiario_det (
--                    id_cia,
--                    idres,
--                    numint,
--                    series,
--                    numdoc,
--                    codcli,
--                    estado
--                ) VALUES (
--                    rec_fe_resumendiario_det.id_cia,
--                    rec_fe_resumendiario_det.idres,
--                    rec_fe_resumendiario_det.numint,
--                    rec_fe_resumendiario_det.series,
--                    rec_fe_resumendiario_det.numdoc,
--                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
--                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
--                );
--
--            WHEN 2 THEN
--                v_accion := 'La actualización';
----                UPDATE fe_resumendiario_det
----                SET
----                    numdoc =
----                        CASE
----                            WHEN rec_fe_resumendiario_det.numdoc IS NULL THEN
----                                numdoc
----                            ELSE
----                                rec_fe_resumendiario_det.numdoc
----                        END,
----                    estado = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
----                WHERE
----                        id_cia = rec_fe_resumendiario_det.id_cia
----                    AND numint = rec_fe_resumendiario_det.numint
----                    AND idres = rec_fe_resumendiario_det.idres;
--                NULL;
--            WHEN 3 THEN
--                v_accion := 'La eliminación';
--                DELETE FROM fe_resumendiario_det
--                WHERE
--                        id_cia = rec_fe_resumendiario_det.id_cia
--                    AND idres = rec_fe_resumendiario_det.idres
--                    AND numint = rec_fe_resumendiario_det.numint;
--
--        END CASE;
--
--        SELECT
--            JSON_OBJECT(
--                'status' VALUE 1.0,
--                'message' VALUE v_accion || ' se realizó satisfactoriamente...!'
--            )
--        INTO pin_mensaje
--        FROM
--            dual;
--
--        COMMIT;
--    EXCEPTION
--        WHEN dup_val_on_index THEN
--            SELECT
--                JSON_OBJECT(
--                    'status' VALUE 1.1,
--                    'message' VALUE 'El registro con codigo de personal [ '
--                                    || rec_fe_resumendiario_det.numint
--                                    || ' ] y con el Concepto [ '
--                                    || rec_fe_resumendiario_det.idres
--                                    || ' ] ya existe y no puede duplicarse ...!'
--                )
--            INTO pin_mensaje
--            FROM
--                dual;
--
--        WHEN value_error THEN
--            SELECT
--                JSON_OBJECT(
--                    'status' VALUE 1.2,
--                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
--                )
--            INTO pin_mensaje
--            FROM
--                dual;
--
--        WHEN OTHERS THEN
--            IF sqlcode = -2291 THEN
--                SELECT
--                    JSON_OBJECT(
--                        'status' VALUE 1.1,
--                        'message' VALUE 'No se insertar o modificar este registro porque el Concepto [ '
--                                        || rec_fe_resumendiario_det.idres
--                                        || ' ] o porque el Codigo de Personal [ '
--                                        || rec_fe_resumendiario_det.numint
--                                        || ' ] no existe ...! '
--                    )
--                INTO pin_mensaje
--                FROM
--                    dual;
--
--            ELSE
--                pin_mensaje := 'mensaje : '
--                               || sqlerrm
--                               || ' codigo :'
--                               || sqlcode;
--                SELECT
--                    JSON_OBJECT(
--                        'status' VALUE 1.2,
--                        'message' VALUE pin_mensaje
--                    )
--                INTO pin_mensaje
--                FROM
--                    dual;
--
--            END IF;
--    END sp_save;

END;

/
