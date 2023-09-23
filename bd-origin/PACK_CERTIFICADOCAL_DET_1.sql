--------------------------------------------------------
--  DDL for Package Body PACK_CERTIFICADOCAL_DET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CERTIFICADOCAL_DET" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_certificadocal_det
        PIPELINED
    AS
        v_table datatable_certificadocal_det;
    BEGIN
        SELECT
            p.id_cia,
            p.numint,
            p.numite,
            p.opnumint,
            p.opnumite,
            p.periodo,
            p.agrupa,
            p.numero,
            p.xml,
            p.ucreac,
            p.fcreac,
            p.uactua,
            p.factua,
            p.uimpri,
            p.fimpri,
            p.etiqueta,
            d.tipinv,
            d.codart,
            a.descri AS articulo,
            d.cantid,
            d.largo
        BULK COLLECT
        INTO v_table
        FROM
            certificadocal_det p
            LEFT OUTER JOIN documentos_det     d ON d.id_cia = p.id_cia
                                                AND d.numint = p.opnumint
                                                AND d.numite = p.opnumite
            LEFT OUTER JOIN articulos          a ON a.id_cia = d.id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
        WHERE
                p.id_cia = pin_id_cia
            AND p.numint = pin_numint
            AND p.numite = pin_numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_certificadocal_det
        PIPELINED
    IS
        v_table datatable_certificadocal_det;
    BEGIN
        SELECT
            p.id_cia,
            p.numint,
            p.numite,
            p.opnumint,
            p.opnumite,
            p.periodo,
            p.agrupa,
            p.numero,
            p.xml,
            p.ucreac,
            p.fcreac,
            p.uactua,
            p.factua,
            p.uimpri,
            p.fimpri,
            p.etiqueta,
            d.tipinv,
            d.codart,
            a.descri AS articulo,
            d.cantid,
            d.largo
        BULK COLLECT
        INTO v_table
        FROM
            certificadocal_det p
            LEFT OUTER JOIN documentos_det     d ON d.id_cia = p.id_cia
                                                AND d.numint = p.opnumint
                                                AND d.numite = p.opnumite
            LEFT OUTER JOIN articulos          a ON a.id_cia = d.id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
        WHERE
                p.id_cia = pin_id_cia
            AND p.numint = pin_numint;

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
--  "numite": 6,
--  "opnumint": 519582,
--  "opnumite": 2,
--  "periodo": 2023,
--  "agrupa": 6,
--  "numero": 209,
--  "xml": "",
--  "uimpri": "PRUEBA V2",
--  "fimpri": "2023-01-01",
--  "etiqueta": "PPP",
--  "ucreac": "admin",
--  "uactua": "admin"
--}
--';
--    pack_certificadocal_det.sp_save(66,NULL, cadjson, 1, mensaje);
--
--    dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_certificadocal_det.sp_obtener(66,2,1);
--
--SELECT * FROM pack_certificadocal_det.sp_buscar(66,2);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_xml     IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                      json_object_t;
        rec_certificadocal_det certificadocal_det%rowtype;
        v_accion               VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_certificadocal_det.id_cia := pin_id_cia;
        rec_certificadocal_det.numint := o.get_number('numint');
        rec_certificadocal_det.numite := o.get_number('numite');
        rec_certificadocal_det.opnumint := o.get_number('opnumint');
        rec_certificadocal_det.opnumite := o.get_number('opnumite');
        rec_certificadocal_det.periodo := o.get_number('periodo');
        rec_certificadocal_det.agrupa := o.get_number('agrupa');
        rec_certificadocal_det.numero := o.get_number('numero');
        rec_certificadocal_det.uimpri := o.get_string('uimpri');
        rec_certificadocal_det.fimpri := o.get_date('fimpri');
        rec_certificadocal_det.etiqueta := o.get_string('etiqueta');
        rec_certificadocal_det.ucreac := o.get_string('ucreac');
        rec_certificadocal_det.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                IF nvl(rec_certificadocal_det.numite, 0) = 0 THEN
                    BEGIN
                        SELECT
                            numite + 1
                        INTO rec_certificadocal_det.numite
                        FROM
                            certificadocal_det
                        WHERE
                                id_cia = pin_id_cia
                            AND numint = rec_certificadocal_det.numint
                        ORDER BY
                            numite DESC
                        FETCH NEXT 1 ROWS ONLY;

                    EXCEPTION
                        WHEN no_data_found THEN
                            rec_certificadocal_det.numite := 1;
                    END;
                END IF;

                INSERT INTO certificadocal_det (
                    id_cia,
                    numint,
                    numite,
                    opnumint,
                    opnumite,
                    periodo,
                    agrupa,
                    numero,
                    xml,
                    uimpri,
                    fimpri,
                    etiqueta,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_certificadocal_det.id_cia,
                    rec_certificadocal_det.numint,
                    rec_certificadocal_det.numite,
                    rec_certificadocal_det.opnumint,
                    rec_certificadocal_det.opnumite,
                    rec_certificadocal_det.periodo,
                    rec_certificadocal_det.agrupa,
                    rec_certificadocal_det.numero,
                    pin_xml,
                    rec_certificadocal_det.uimpri,
                    rec_certificadocal_det.fimpri,
                    rec_certificadocal_det.etiqueta,
                    rec_certificadocal_det.ucreac,
                    rec_certificadocal_det.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE certificadocal_det
                SET
                    numite = nvl(rec_certificadocal_det.numite, numite),
                    opnumint = nvl(rec_certificadocal_det.opnumint, opnumint),
                    opnumite = nvl(rec_certificadocal_det.opnumite, opnumite),
                    periodo = nvl(rec_certificadocal_det.periodo, periodo),
                    agrupa = nvl(rec_certificadocal_det.agrupa, agrupa),
                    numero = nvl(rec_certificadocal_det.numero, numero),
                    xml = pin_xml,
                    uimpri = nvl(rec_certificadocal_det.uimpri, uimpri),
                    fimpri = nvl(rec_certificadocal_det.fimpri, fimpri),
                    etiqueta = nvl(rec_certificadocal_det.etiqueta, etiqueta),
                    uactua = rec_certificadocal_det.uactua,
                    factua = current_timestamp
                WHERE
                        id_cia = rec_certificadocal_det.id_cia
                    AND numint = rec_certificadocal_det.numint
                    AND numite = rec_certificadocal_det.numite;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM certificadocal_det
                WHERE
                        id_cia = rec_certificadocal_det.id_cia
                    AND numint = rec_certificadocal_det.numint
                    AND numite = rec_certificadocal_det.numite;

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
                                    || rec_certificadocal_det.numint
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
