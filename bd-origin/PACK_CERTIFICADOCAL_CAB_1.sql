--------------------------------------------------------
--  DDL for Package Body PACK_CERTIFICADOCAL_CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CERTIFICADOCAL_CAB" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_certificadocal_cab
        PIPELINED
    AS
        v_table datatable_certificadocal_cab;
    BEGIN
        SELECT
            p.id_cia,
            p.numint,
            p.femisi,
            p.situac,
            p.codcli,
            p.codestruc,
            p.referencia,
            p.opnumint,
            p.ucreac,
            p.fcreac,
            p.uactua,
            p.factua,
            p.ocfecha,
            p.usocantid,
            p.ocnumero,
            p.ufirma,
            s.dessit,
            c.razonc,
            c.tipdoc AS optipdoc,
            c.codmot AS opcodmot
        BULK COLLECT
        INTO v_table
        FROM
            certificadocal_cab p
            LEFT OUTER JOIN documentos_cab     c ON c.id_cia = p.id_cia
                                                AND c.numint = p.opnumint
            LEFT OUTER JOIN situacion          s ON s.id_cia = c.id_cia
                                           AND s.tipdoc = c.tipdoc
                                           AND s.situac = c.situac
        WHERE
                p.id_cia = pin_id_cia
            AND p.numint = pin_numint;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_fdesde  DATE,
        pin_fhasta  DATE,
        pin_situacs VARCHAR2
    ) RETURN datatable_certificadocal_cab
        PIPELINED
    IS
        v_table datatable_certificadocal_cab;
    BEGIN
        SELECT
            p.id_cia,
            p.numint,
            p.femisi,
            p.situac,
            p.codcli,
            p.codestruc,
            p.referencia,
            p.opnumint,
            p.ucreac,
            p.fcreac,
            p.uactua,
            p.factua,
            p.ocfecha,
            p.usocantid,
            p.ocnumero,
            p.ufirma,
            s.dessit,
            c.razonc,
            c.tipdoc AS optipdoc,
            c.codmot AS opcodmot
        BULK COLLECT
        INTO v_table
        FROM
            certificadocal_cab p
            LEFT OUTER JOIN documentos_cab     c ON c.id_cia = p.id_cia
                                                AND c.numint = p.opnumint
            LEFT OUTER JOIN situacion          s ON s.id_cia = c.id_cia
                                           AND s.tipdoc = c.tipdoc
                                           AND s.situac = c.situac
        WHERE
                p.id_cia = pin_id_cia
            AND trunc(p.femisi) BETWEEN pin_fdesde AND pin_fhasta
            AND ( p.situac IN (
                SELECT
                    regexp_substr(pin_situacs, '[^,]+', 1, level)
                FROM
                    dual
                CONNECT BY
                    regexp_substr(pin_situacs, '[^,]+', 1, level) IS NOT NULL
            )
                  OR pin_situacs IS NULL );

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
--  "numint": 2,
--  "femisi": "2023-01-01",
--  "situac": "B",
--  "codcli": "20159473148",
--  "codestruc": 5,
--  "referencia": "REFERENCIA DE PRUEBA V2",
--  "opnumint": 512823,
--  "ocfecha": "2023-01-31",
--  "usocantid": 5,
--  "ocnumero": "456",
--  "ucreac": "admin",
--  "uactua": "admin"
--}';
--    pack_certificadocal_cab.sp_save(66, cadjson, 1, mensaje);
--
--    dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_certificadocal_cab.sp_obtener(66,2);
--
--SELECT * FROM pack_certificadocal_cab.sp_buscar(66,to_date('01/01/22','DD/MM/YY'),to_date('01/01/24','DD/MM/YY'),'A,B,C,D,K');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                      json_object_t;
        rec_certificadocal_cab certificadocal_cab%rowtype;
        v_accion               VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_certificadocal_cab.id_cia := pin_id_cia;
        rec_certificadocal_cab.numint := o.get_number('numint');
        rec_certificadocal_cab.femisi := o.get_date('femisi');
        rec_certificadocal_cab.situac := o.get_string('situac');
        rec_certificadocal_cab.codcli := o.get_string('codcli');
        rec_certificadocal_cab.codestruc := o.get_number('codestruc');
        rec_certificadocal_cab.referencia := o.get_string('referencia');
        rec_certificadocal_cab.opnumint := o.get_number('opnumint');
        rec_certificadocal_cab.ocfecha := o.get_date('ocfecha');
        rec_certificadocal_cab.usocantid := o.get_number('usocantid');
        rec_certificadocal_cab.ocnumero := o.get_string('ocnumero');
        rec_certificadocal_cab.ufirma := o.get_string('ufirma');
        rec_certificadocal_cab.ucreac := o.get_string('ucreac');
        rec_certificadocal_cab.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                IF nvl(rec_certificadocal_cab.numint, 0) = 0 THEN
                    BEGIN
                        SELECT
                            numint + 1
                        INTO rec_certificadocal_cab.numint
                        FROM
                            certificadocal_cab
                        WHERE
                            id_cia = pin_id_cia
                        ORDER BY
                            numint DESC
                        FETCH NEXT 1 ROWS ONLY;

                    EXCEPTION
                        WHEN no_data_found THEN
                            rec_certificadocal_cab.numint := 1;
                    END;
                END IF;

                INSERT INTO certificadocal_cab (
                    id_cia,
                    numint,
                    femisi,
                    situac,
                    codcli,
                    codestruc,
                    referencia,
                    opnumint,
                    ocfecha,
                    usocantid,
                    ocnumero,
                    ufirma,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_certificadocal_cab.id_cia,
                    rec_certificadocal_cab.numint,
                    rec_certificadocal_cab.femisi,
                    rec_certificadocal_cab.situac,
                    rec_certificadocal_cab.codcli,
                    rec_certificadocal_cab.codestruc,
                    rec_certificadocal_cab.referencia,
                    rec_certificadocal_cab.opnumint,
                    rec_certificadocal_cab.ocfecha,
                    rec_certificadocal_cab.usocantid,
                    rec_certificadocal_cab.ocnumero,
                    rec_certificadocal_cab.ufirma,
                    rec_certificadocal_cab.ucreac,
                    rec_certificadocal_cab.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE certificadocal_cab
                SET
                    femisi = nvl(rec_certificadocal_cab.femisi, femisi),
                    situac = nvl(rec_certificadocal_cab.situac, situac),
                    codcli = nvl(rec_certificadocal_cab.codcli, codcli),
                    codestruc = nvl(rec_certificadocal_cab.codestruc, codestruc),
                    referencia = nvl(rec_certificadocal_cab.referencia, referencia),
                    opnumint = nvl(rec_certificadocal_cab.opnumint, opnumint),
                    ocfecha = nvl(rec_certificadocal_cab.ocfecha, ocfecha),
                    usocantid = nvl(rec_certificadocal_cab.usocantid, usocantid),
                    ocnumero = nvl(rec_certificadocal_cab.ocnumero, ocnumero),
                    ufirma = nvl(rec_certificadocal_cab.ufirma, ufirma),
                    uactua = rec_certificadocal_cab.uactua,
                    factua = current_timestamp
                WHERE
                        id_cia = rec_certificadocal_cab.id_cia
                    AND numint = rec_certificadocal_cab.numint;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM certificadocal_cab
                WHERE
                        id_cia = rec_certificadocal_cab.id_cia
                    AND numint = rec_certificadocal_cab.numint;

                COMMIT;
        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'EL REGISTRO CON EL NUMERO INTERNO [ '
                                    || rec_certificadocal_cab.numint
                                    || ' ] YA EXISTE Y NO PUEDE DUPLICARSE!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'EL REGISTRO EXECEDE EL LIMITE PERMITIDO POR EL CAMPO Y/O SE ENCUENTRA EN UN FORMATO INCORRECTO'
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

    END sp_save;

END;

/
