--------------------------------------------------------
--  DDL for Package Body PACK_COMPR010GUIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_COMPR010GUIA" AS

    FUNCTION sp_buscar_documentos_no_asignados (
        pin_id_cia IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_series IN VARCHAR2,
        pin_numdoc IN NUMBER
    ) RETURN datatable_documentos_no_asignados
        PIPELINED
    AS
        v_table datatable_documentos_no_asignados;
    BEGIN
        SELECT
            d1.id_cia,
            d1.tipdoc,
            dt.descri              AS desdoc,
            d1.series,
            d1.numdoc,
            d1.numint,
            d1.femisi,
            d1.codcli,
            d1.razonc,
            d1.ruc,
            d1.situac,
            d1.id,
            d1.opnumdoc,
            d1.observ,
            s1.dessit,
            m1.desmot,
            d1.codalm,
            al.descri              AS desalm,
            d1.optipinv,
            t1.dtipinv             AS destinv,
            d1.tipmon,
            d1.tipcam,
            d1.porigv,
            d1.preven,
            d1.facpro,
            d1.ffacpro,
            d1.guipro,
            d1.fguipro,
            cl.direc1              AS dircli1,
            cl.direc2              AS dircli2,
            dr.numintre,
            dc.series              AS seriesre,
            dc.numdoc              AS numdocre,
            dc.series || dc.numdoc AS documre,
            tm.desmon,
            tm.simbolo,
            d1.numped
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab      d1
            LEFT OUTER JOIN documentos_tipo     dt ON dt.id_cia = d1.id_cia
                                                  AND dt.tipdoc = d1.tipdoc
            LEFT OUTER JOIN situacion           s1 ON s1.id_cia = d1.id_cia
                                            AND s1.tipdoc = d1.tipdoc
                                            AND s1.situac = d1.situac
            LEFT OUTER JOIN motivos             m1 ON m1.id_cia = d1.id_cia
                                          AND m1.id = d1.id
                                          AND m1.codmot = d1.codmot
                                          AND m1.tipdoc = d1.tipdoc
            LEFT OUTER JOIN almacen             al ON al.id_cia = d1.id_cia
                                          AND al.tipinv = d1.optipinv
                                          AND al.codalm = d1.codalm
            LEFT OUTER JOIN t_inventario        t1 ON t1.id_cia = d1.id_cia
                                               AND t1.tipinv = d1.optipinv
            LEFT OUTER JOIN cliente             cl ON cl.id_cia = d1.id_cia
                                          AND cl.codcli = d1.codcli
            LEFT OUTER JOIN documentos_relacion dr ON dr.id_cia = d1.id_cia
                                                      AND dr.numint = d1.numint
            LEFT OUTER JOIN documentos_cab      dc ON dc.id_cia = d1.id_cia
                                                 AND dc.numint = dr.numintre
            LEFT OUTER JOIN tmoneda             tm ON tm.id_cia = d1.id_cia
                                          AND tm.codmon = d1.tipmon
        WHERE
                d1.id_cia = pin_id_cia
            AND ( ( d1.tipdoc = 103
                    AND d1.situac = 'F' )
                  OR ( d1.tipdoc = 122
                       AND d1.situac = 'B' ) )
            AND d1.id = 'I'
            AND ( nvl(pin_codsuc, - 1) = - 1
                  OR d1.codsuc = pin_codsuc )
            AND ( pin_codcli IS NULL
                  OR d1.codcli = pin_codcli )
            AND ( pin_series IS NULL
                  OR d1.series = pin_series )
            AND ( nvl(pin_numdoc, - 1) = - 1
                  OR d1.numdoc = pin_numdoc )
            AND NOT EXISTS (
                SELECT
                    g.numint
                FROM
                    compr010guia g
                WHERE
                        g.id_cia = d1.id_cia
                    AND g.numint = d1.numint
            )
        ORDER BY
            d1.femisi DESC,
            d1.series,
            d1.numdoc;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_documentos_no_asignados;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tipo   NUMBER,
        pin_docume NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_compr010guia
        PIPELINED
    AS
        v_table datatable_compr010guia;
    BEGIN
        SELECT
            pa.id_cia,
            pa.tipo,
            pa.docume,
            pa.numint,
            pa.tipdoc,
            pa.series,
            pa.numdoc,
            pa.usuari,
            pa.usuari,
            pa.fcreac,
            pa.factua
        BULK COLLECT
        INTO v_table
        FROM
            compr010guia pa
        WHERE
                pa.id_cia = pin_id_cia
            AND pa.docume = pin_docume
            AND pa.tipo = pin_tipo
            AND pa.numint = pin_numint;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipo   NUMBER,
        pin_docume NUMBER,
        pin_numint NUMBER,
        pin_tipdoc NUMBER,
        pin_series VARCHAR2,
        pin_numdoc NUMBER
    ) RETURN datatable_compr010guia
        PIPELINED
    AS
        v_table datatable_compr010guia;
    BEGIN
        SELECT
            pa.id_cia,
            pa.tipo,
            pa.docume,
            pa.numint,
            pa.tipdoc,
            pa.series,
            pa.numdoc,
            pa.usuari,
            pa.usuari,
            pa.fcreac,
            pa.factua
        BULK COLLECT
        INTO v_table
        FROM
            compr010guia pa
        WHERE
                pa.id_cia = pin_id_cia
            AND ( nvl(pin_tipo, - 1) = - 1
                  OR pa.tipo = pin_tipo )
            AND ( nvl(pin_docume, - 1) = - 1
                  OR pa.docume = pin_docume )
            AND ( nvl(pin_numint, - 1) = - 1
                  OR pa.numint = pin_numint )
            AND ( nvl(pin_tipdoc, - 1) = - 1
                  OR pa.tipdoc = pin_tipdoc )
            AND ( pin_series IS NULL
                  OR pa.series = pin_series )
            AND ( nvl(pin_numdoc, - 1) = - 1
                  OR pa.numdoc = pin_numdoc );

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
--                "tipo":601,
--                "docume":35429,
--                "numint":143658,
--                "tipdoc":103,
--                "series":"111",
--                "numdoc":157,
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--pack_compr010guia.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_compr010guia.sp_obtener(66,601,35429,143658);
--
--SELECT * FROM pack_compr010guia.sp_buscar(66,NULL,NULL,NULL,NULL,NULL,NULL);


    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                json_object_t;
        rec_compr010guia compr010guia%rowtype;
        v_accion         VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_compr010guia.id_cia := pin_id_cia;
        rec_compr010guia.tipo := o.get_number('tipo');
        rec_compr010guia.docume := o.get_number('docume');
        rec_compr010guia.numint := o.get_number('numint');
        rec_compr010guia.tipdoc := o.get_number('tipdoc');
        rec_compr010guia.series := o.get_string('series');
        rec_compr010guia.numdoc := o.get_number('numdoc');
        rec_compr010guia.usuari := o.get_string('ucreac');
        rec_compr010guia.usuari := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO compr010guia (
                    id_cia,
                    tipo,
                    docume,
                    numint,
                    tipdoc,
                    series,
                    numdoc,
                    usuari,
                    fcreac,
                    factua
                ) VALUES (
                    rec_compr010guia.id_cia,
                    rec_compr010guia.tipo,
                    rec_compr010guia.docume,
                    rec_compr010guia.numint,
                    rec_compr010guia.tipdoc,
                    rec_compr010guia.series,
                    rec_compr010guia.numdoc,
                    rec_compr010guia.usuari,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE compr010guia
                SET
                    usuari = rec_compr010guia.usuari,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_compr010guia.id_cia
                    AND tipo = rec_compr010guia.tipo
                    AND docume = rec_compr010guia.docume
                    AND numint = rec_compr010guia.numint;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM compr010guia
                WHERE
                        id_cia = rec_compr010guia.id_cia
                    AND tipo = rec_compr010guia.tipo
                    AND docume = rec_compr010guia.docume
                    AND numint = rec_compr010guia.numint;

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
                    'message' VALUE 'El registro con codigo de personal [ '
                                    || rec_compr010guia.docume
                                    || ' ] y con el Concepto [ '
                                    || rec_compr010guia.tipo
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
                        'message' VALUE 'No se insertar o modificar este registro porque el Concepto [ '
                                        || rec_compr010guia.tipo
                                        || ' ] o porque el Codigo de Personal [ '
                                        || rec_compr010guia.docume
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
