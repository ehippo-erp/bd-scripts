--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_PRODUCCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_PRODUCCION" AS

    FUNCTION sp_motivo_guia_salida (
        pin_id_cia IN NUMBER
    ) RETURN datatable_motivo_guia_salida
        PIPELINED
    AS
        v_table datatable_motivo_guia_salida;
    BEGIN
        SELECT
            m.id_cia,
            m.tipdoc,
            m.id,
            m.codmot,
            m.desmot,
            m.abrevi,
            mc.codigo AS clase6,
            mc.valor  AS clase6valor,
            (
                CASE
                    WHEN c18.valor IS NULL THEN
                        'N'
                    ELSE
                        c18.valor
                END
            )         AS motoblidocpadre,
            c19.valor AS relcossalprod,
            CASE
                WHEN ( c36.valor IS NULL )
                     OR ( upper(c36.valor) <> 'S' ) THEN
                    'N'
                ELSE
                    'S'
            END       AS motdevfacbol,
            c41.valor AS noimportadetalle,
            c45.valor AS reclasifica,
            c01.valor AS clase01moneda,
            c10.valor AS clase10incigv
        BULK COLLECT
        INTO v_table
        FROM
            motivos       m
            LEFT OUTER JOIN motivos_clase mc ON mc.id_cia = m.id_cia
                                                AND mc.tipdoc = m.tipdoc
                                                AND mc.id = m.id
                                                AND mc.codmot = m.codmot
                                                AND mc.codigo = 6
            LEFT OUTER JOIN motivos_clase c18 ON c18.id_cia = m.id_cia
                                                 AND c18.tipdoc = m.tipdoc
                                                 AND c18.id = m.id
                                                 AND c18.codmot = m.codmot
                                                 AND c18.codigo = 18
            LEFT OUTER JOIN motivos_clase c19 ON c19.id_cia = m.id_cia
                                                 AND c19.tipdoc = m.tipdoc
                                                 AND c19.id = m.id
                                                 AND c19.codmot = m.codmot
                                                 AND c19.codigo = 19
            LEFT OUTER JOIN motivos_clase c36 ON c36.id_cia = m.id_cia
                                                 AND c36.tipdoc = m.tipdoc
                                                 AND c36.id = m.id
                                                 AND c36.codmot = m.codmot
                                                 AND c36.codigo = 36
            LEFT OUTER JOIN motivos_clase c41 ON c41.id_cia = m.id_cia
                                                 AND c41.tipdoc = m.tipdoc
                                                 AND c41.id = m.id
                                                 AND c41.codmot = m.codmot
                                                 AND c41.codigo = 41
            LEFT OUTER JOIN motivos_clase c45 ON c45.id_cia = m.id_cia
                                                 AND c45.tipdoc = m.tipdoc
                                                 AND c45.id = m.id
                                                 AND c45.codmot = m.codmot
                                                 AND c45.codigo = 45
            LEFT OUTER JOIN motivos_clase c01 ON c01.id_cia = m.id_cia
                                                 AND c01.tipdoc = m.tipdoc
                                                 AND c01.id = m.id
                                                 AND c01.codmot = m.codmot
                                                 AND c01.codigo = 01
            LEFT OUTER JOIN motivos_clase c10 ON c10.id_cia = m.id_cia
                                                 AND c10.tipdoc = m.tipdoc
                                                 AND c10.id = m.id
                                                 AND c10.codmot = m.codmot
                                                 AND c10.codigo = 10
        WHERE
                m.id_cia = pin_id_cia
            AND m.tipdoc = 103
            AND m.swacti = 'S'
            AND m.id = 'S'
            AND c19.valor >= 199
            AND c19.valor <= 205
        ORDER BY
            m.codmot;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_motivo_guia_salida;

    FUNCTION sp_motivo_guia_ingreso (
        pin_id_cia IN NUMBER
    ) RETURN datatable_motivo_guia_salida
        PIPELINED
    AS
        v_table datatable_motivo_guia_salida;
    BEGIN
        SELECT
            m.id_cia,
            m.tipdoc,
            m.id,
            m.codmot,
            m.desmot,
            m.abrevi,
            mc.codigo AS clase6,
            mc.valor  AS clase6valor,
            (
                CASE
                    WHEN c18.valor IS NULL THEN
                        'N'
                    ELSE
                        c18.valor
                END
            )         AS motoblidocpadre,
            c19.valor AS relcossalprod,
            CASE
                WHEN ( c36.valor IS NULL )
                     OR ( upper(c36.valor) <> 'S' ) THEN
                    'N'
                ELSE
                    'S'
            END       AS motdevfacbol,
            c41.valor AS noimportadetalle,
            c45.valor AS reclasifica,
            c01.valor AS clase01moneda,
            c10.valor AS clase10incigv
        BULK COLLECT
        INTO v_table
        FROM
            motivos       m
            LEFT OUTER JOIN motivos_clase mc ON mc.id_cia = m.id_cia
                                                AND mc.tipdoc = m.tipdoc
                                                AND mc.id = m.id
                                                AND mc.codmot = m.codmot
                                                AND mc.codigo = 6
            LEFT OUTER JOIN motivos_clase c18 ON c18.id_cia = m.id_cia
                                                 AND c18.tipdoc = m.tipdoc
                                                 AND c18.id = m.id
                                                 AND c18.codmot = m.codmot
                                                 AND c18.codigo = 18
            LEFT OUTER JOIN motivos_clase c19 ON c19.id_cia = m.id_cia
                                                 AND c19.tipdoc = m.tipdoc
                                                 AND c19.id = m.id
                                                 AND c19.codmot = m.codmot
                                                 AND c19.codigo = 19
            LEFT OUTER JOIN motivos_clase c36 ON c36.id_cia = m.id_cia
                                                 AND c36.tipdoc = m.tipdoc
                                                 AND c36.id = m.id
                                                 AND c36.codmot = m.codmot
                                                 AND c36.codigo = 36
            LEFT OUTER JOIN motivos_clase c41 ON c41.id_cia = m.id_cia
                                                 AND c41.tipdoc = m.tipdoc
                                                 AND c41.id = m.id
                                                 AND c41.codmot = m.codmot
                                                 AND c41.codigo = 41
            LEFT OUTER JOIN motivos_clase c45 ON c45.id_cia = m.id_cia
                                                 AND c45.tipdoc = m.tipdoc
                                                 AND c45.id = m.id
                                                 AND c45.codmot = m.codmot
                                                 AND c45.codigo = 45
            LEFT OUTER JOIN motivos_clase c01 ON c01.id_cia = m.id_cia
                                                 AND c01.tipdoc = m.tipdoc
                                                 AND c01.id = m.id
                                                 AND c01.codmot = m.codmot
                                                 AND c01.codigo = 01
            LEFT OUTER JOIN motivos_clase c10 ON c10.id_cia = m.id_cia
                                                 AND c10.tipdoc = m.tipdoc
                                                 AND c10.id = m.id
                                                 AND c10.codmot = m.codmot
                                                 AND c10.codigo = 10
        WHERE
                m.id_cia = pin_id_cia
            AND m.swacti = 'S'
            AND m.tipdoc = '103'
            AND m.id = 'I'
            AND m.docayuda >= 199
            AND m.docayuda <= 210
        ORDER BY
            m.codmot;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_motivo_guia_ingreso;

    FUNCTION sp_motivo_guia_ingreso_dev (
        pin_id_cia IN NUMBER
    ) RETURN datatable_motivo_guia_salida
        PIPELINED
    AS
        v_table datatable_motivo_guia_salida;
    BEGIN
        SELECT
            m.id_cia,
            m.tipdoc,
            m.id,
            m.codmot,
            m.desmot,
            m.abrevi,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            c01.valor AS clase01moneda,
            c10.valor AS clase10incigv
        BULK COLLECT
        INTO v_table
        FROM
            motivos       m
            LEFT OUTER JOIN motivos_clase c22 ON c22.id_cia = m.id_cia
                                                 AND c22.tipdoc = m.tipdoc
                                                 AND c22.id = m.id
                                                 AND c22.codmot = m.codmot
                                                 AND c22.codigo = 22
            LEFT OUTER JOIN motivos_clase c01 ON c01.id_cia = m.id_cia
                                                 AND c01.tipdoc = m.tipdoc
                                                 AND c01.id = m.id
                                                 AND c01.codmot = m.codmot
                                                 AND c01.codigo = 01
            LEFT OUTER JOIN motivos_clase c10 ON c10.id_cia = m.id_cia
                                                 AND c10.tipdoc = m.tipdoc
                                                 AND c10.id = m.id
                                                 AND c10.codmot = m.codmot
                                                 AND c10.codigo = 10
        WHERE
                m.id_cia = pin_id_cia
            AND m.swacti = 'S'
            AND c22.valor = 'S';

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_motivo_guia_ingreso_dev;

    FUNCTION sp_motivo_guia_ingreso_materiales (
        pin_id_cia IN NUMBER
    ) RETURN datatable_motivo_guia_salida
        PIPELINED
    AS
        v_table datatable_motivo_guia_salida;
    BEGIN
        SELECT
            m.id_cia,
            m.tipdoc,
            m.id,
            m.codmot,
            m.desmot,
            m.abrevi,
            mc.codigo AS clase6,
            mc.valor  AS clase6valor,
            (
                CASE
                    WHEN c18.valor IS NULL THEN
                        'N'
                    ELSE
                        c18.valor
                END
            )         AS motoblidocpadre,
            c19.valor AS relcossalprod,
            CASE
                WHEN ( c36.valor IS NULL )
                     OR ( upper(c36.valor) <> 'S' ) THEN
                    'N'
                ELSE
                    'S'
            END       AS motdevfacbol,
            c41.valor AS noimportadetalle,
            c45.valor AS reclasifica,
            c01.valor AS clase01moneda,
            c10.valor AS clase10incigv
        BULK COLLECT
        INTO v_table
        FROM
            motivos       m
            LEFT OUTER JOIN motivos_clase mc ON mc.id_cia = m.id_cia
                                                AND mc.tipdoc = m.tipdoc
                                                AND mc.id = m.id
                                                AND mc.codmot = m.codmot
                                                AND mc.codigo = 6
            LEFT OUTER JOIN motivos_clase c18 ON c18.id_cia = m.id_cia
                                                 AND c18.tipdoc = m.tipdoc
                                                 AND c18.id = m.id
                                                 AND c18.codmot = m.codmot
                                                 AND c18.codigo = 18
            LEFT OUTER JOIN motivos_clase c19 ON c19.id_cia = m.id_cia
                                                 AND c19.tipdoc = m.tipdoc
                                                 AND c19.id = m.id
                                                 AND c19.codmot = m.codmot
                                                 AND c19.codigo = 19
            LEFT OUTER JOIN motivos_clase c36 ON c36.id_cia = m.id_cia
                                                 AND c36.tipdoc = m.tipdoc
                                                 AND c36.id = m.id
                                                 AND c36.codmot = m.codmot
                                                 AND c36.codigo = 36
            LEFT OUTER JOIN motivos_clase c41 ON c41.id_cia = m.id_cia
                                                 AND c41.tipdoc = m.tipdoc
                                                 AND c41.id = m.id
                                                 AND c41.codmot = m.codmot
                                                 AND c41.codigo = 41
            LEFT OUTER JOIN motivos_clase c45 ON c45.id_cia = m.id_cia
                                                 AND c45.tipdoc = m.tipdoc
                                                 AND c45.id = m.id
                                                 AND c45.codmot = m.codmot
                                                 AND c45.codigo = 45
            LEFT OUTER JOIN motivos_clase c01 ON c01.id_cia = m.id_cia
                                                 AND c01.tipdoc = m.tipdoc
                                                 AND c01.id = m.id
                                                 AND c01.codmot = m.codmot
                                                 AND c01.codigo = 01
            LEFT OUTER JOIN motivos_clase c10 ON c10.id_cia = m.id_cia
                                                 AND c10.tipdoc = m.tipdoc
                                                 AND c10.id = m.id
                                                 AND c10.codmot = m.codmot
                                                 AND c10.codigo = 10
        WHERE
                m.id_cia = pin_id_cia
            AND m.swacti = 'S'
            AND m.tipdoc = '103'
            AND m.id = 'I'
            AND c19.valor >= 199
            AND c19.valor <= 205
        ORDER BY
            m.codmot;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_motivo_guia_ingreso_materiales;

    FUNCTION sp_detalle_items (
        pin_id_cia NUMBER,
        pin_series VARCHAR2,
        pin_numdoc NUMBER
    ) RETURN datatable_detalle_items
        PIPELINED
    AS
        v_table datatable_detalle_items;
    BEGIN
        SELECT
            dc.id_cia,
            dc.series,
            dc.numdoc,
            d1.numint,
            d1.numite,
            d1.codalm,
            d1.tipinv,
            d1.codart,
            a1.descri AS desart,
            d1.cantid,
            d1.codund,
            d1.preuni,
            d1.etiqueta,
            d1.codadd01,
            d1.codadd02,
            d1.numintpre,
            d1.numitepre
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab dc
            LEFT OUTER JOIN documentos_det d1 ON d1.id_cia = dc.id_cia
                                                 AND d1.numint = dc.numint
            LEFT OUTER JOIN articulos      a1 ON a1.id_cia = d1.id_cia
                                            AND a1.tipinv = d1.tipinv
                                            AND a1.codart = d1.codart
        WHERE
                dc.id_cia = pin_id_cia
            AND dc.tipdoc = 104
            AND dc.series = pin_series
            AND dc.numdoc = pin_numdoc
            AND nvl(d1.swacti, 0) = 0
        ORDER BY
            dc.numdoc,
            d1.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle_items;

    PROCEDURE sp_visar_ordpro (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_mensaje    VARCHAR2(1000) := '';
        o            json_object_t;
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
        dbms_output.put_line('PASO 1 EXISTE EL DOCUMENTO?');
        IF pack_documentos_anulados.sp_documentos_obtener(pin_id_cia, pin_numint, 104) = 0 THEN
            pout_mensaje := 'LA ORDEN DE PRODUCCION CON EL NUMERO INTERNO [ '
                            || pin_numint
                            || ' ] NO EXISTE Y/O ESTA EN UNA SITUACION NO VALIDA';
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 2 TIENE DETALLE?');
        BEGIN
            SELECT
                'S'
            INTO pout_mensaje
            FROM
                documentos_det
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'LA ORDEN DE PRODUCCION NO TIENE DETALLE';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        dbms_output.put_line('PASO 4 ACTUALIZA SITUACION');
        pack_documentos_produccion.sp_reordena_positi(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 4 ACTUALIZA SITUACION');
        pack_documentos_anulados.sp_actualiza_situacion(pin_id_cia, pin_numint, 'B', pin_coduser, v_mensaje,
                                                       'N', 'S', 'N', 'N', 'S');

        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'ORDEN DE PRODUCCION VISADA'
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
    END sp_visar_ordpro;

    PROCEDURE sp_anular_ordpro (
        pin_id_cia     IN NUMBER,
        pin_numint     IN NUMBER,
        pin_coduser    IN VARCHAR2,
        pin_comentario IN VARCHAR2,
        pin_mensaje    OUT VARCHAR2
    ) AS

        c_ordcomni   NUMBER;
        v_mensaje    VARCHAR2(1000) := '';
        o            json_object_t;
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
        dbms_output.put_line('PASO 1 EXISTE EL DOCUMENTO?');
        IF pack_documentos_anulados.sp_documentos_obtener(pin_id_cia, pin_numint, 104) = 0 THEN
            pout_mensaje := 'LA ORDEN DE PRODUCCION N° '
                            || pin_numint
                            || ' NO EXISTE Y/O ESTA EN UNA SITUACION NO VALIDA';
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        -- PASO 2 ESTA RELACIONADO?  -- DOCUMENTOS RELACIONADOS CON SITUACION DIFERENTE DE 'J' O 'K'
        dbms_output.put_line('PASO 2 ESTA RELACIONADO? -- Modificado');
        IF pack_documentos_anulados.sp_documentos_relacionados(pin_id_cia, pin_numint) > 0 THEN
            pout_mensaje := 'LA ORDEN DE PRODUCCION N° '
                            || pin_numint
                            || ' TIENE DOCUMENTOS RELACIONADOS, REVISE LA TRAZABILIDAD DEL DOCUMENTO';
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 2 ACTUALIZA SITUACION');
        pack_documentos_anulados.sp_actualiza_situacion(pin_id_cia, pin_numint, 'J', pin_coduser, v_mensaje,
                                                       'N', 'S', 'N', 'N', 'S');

        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 3 ACTUALIZA SITUACION DOCUMENTOS RELACIONADOS');
        pack_documentos_anulados.sp_actualiza_situacion_documentos_relacionados(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 4 ACTUALIZA SITUACION DOCUMENTO SEGUN SALDO');
        BEGIN
            SELECT
                ordcomni
            INTO c_ordcomni
            FROM
                documentos_cab
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint
                AND ordcomni IS NOT NULL;

            pack_documentos_anulados.sp_actualiza_situacion_segun_saldo(pin_id_cia, c_ordcomni, pin_coduser, v_mensaje);
            o := json_object_t.parse(v_mensaje);
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := o.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        EXCEPTION
            WHEN no_data_found THEN
                c_ordcomni := NULL;
        END;

        dbms_output.put_line('PASO 5 ELIMINA DOCUMENTO RELACION - J, K');
        DELETE FROM documentos_relacion
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'ORDEN DE PRODUCCION ANULADA'
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
    END sp_anular_ordpro;

    PROCEDURE sp_reordena_positi (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_positi INTEGER := 1;
    BEGIN
        FOR i IN (
            SELECT
                numite
            FROM
                documentos_det
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint
            ORDER BY
                numite
        ) LOOP
            UPDATE documentos_det
            SET
                positi = v_positi
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint
                AND numite = i.numite;

            v_positi := v_positi + 1;
        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'SUCCESS!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
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
    END sp_reordena_positi;

    FUNCTION sp_movimiento (
        pin_id_cia NUMBER,
        pin_ingsal VARCHAR,
        pin_codcli VARCHAR,
        pin_codmot NUMBER,
        pin_codart VARCHAR,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_serie  VARCHAR2,
        pin_numdoc NUMBER
    ) RETURN datatable_movimiento
        PIPELINED
    AS
        v_table datatable_movimiento;
    BEGIN
        IF
            pin_serie IS NULL
            AND nvl(pin_numdoc, 0) <= 0
        THEN
            SELECT
                c.id_cia,
                c.numint,
                c.series,
                c.numdoc,
                c.codcli,
                c.razonc,
                dr.numint     AS numintre,
                dr.series     AS seriesre,
                dr.numdoc     AS numdocre,
                dr.codcli     AS codclire,
                dr.razonc     AS razoncre,
                d.nomser      AS abrevi,
                k.femisi,
                k.numite,
                k.tipinv,
                k.codart,
                a.descri      AS desart,
                k.cantid *
                CASE
                    WHEN k.id = pin_ingsal THEN
                            1
                    ELSE
                        1
                END
                AS cantid,
                k.id,
                CASE
                    WHEN k.cantid = 0 THEN
                            0
                    ELSE
                        k.costot01 / k.cantid
                END
                *
                CASE
                    WHEN k.id = pin_ingsal THEN
                            1
                    ELSE
                        1
                END
                AS cosunisol,
                CASE
                    WHEN k.cantid = 0 THEN
                            0
                    ELSE
                        k.costot02 / k.cantid
                END
                *
                CASE
                    WHEN k.id = pin_ingsal THEN
                            1
                    ELSE
                        1
                END
                AS cosunidol,
                k.costot01 *
                CASE
                    WHEN k.id = pin_ingsal THEN
                            1
                    ELSE
                        1
                END
                AS costotsol,
                k.costot02 *
                CASE
                    WHEN k.id = pin_ingsal THEN
                            1
                    ELSE
                        1
                END
                AS costotdol,
                k.codadd01    AS codcalid,
                ca1.descri    AS dcalidad,
                k.codadd02    AS codcolor,
                k.codadd02
                || ' - '
                || ca2.descri AS dcolor,
                k.etiqueta,
                dot.numint    AS numintop,
                dot.numite    AS numiteop,
                dot.tipinv    AS tipinvop,
                dot.codart    AS codartop,
                da.descri     AS desartop,
                ka.cantid     AS cantidop,
                ka.id,
                nvl(k.cosmat01, 0),
                nvl(k.cosmob01, 0),
                nvl(k.cosfab01, 0),
                CASE
                    WHEN ka.cantid = 0 THEN
                        0
                    ELSE
                        ka.costot01 / ka.cantid
                END           AS cosunisolop,
                CASE
                    WHEN ka.cantid = 0 THEN
                        0
                    ELSE
                        ka.costot02 / ka.cantid
                END           AS cosunidolop,
                ka.costot01   AS costotsolop,
                ka.costot02   AS costotdolop,
                m.abrevi      AS abrevmot,
                dot.codadd01  AS codadd01op,
                cd1.descri    AS dcalidadop,
                dot.codadd02  AS codadd02op,
                cd2.descri    AS dcolorop
            BULK COLLECT
            INTO v_table
            FROM
                documentos_cab          c
                LEFT OUTER JOIN documentos_det          d ON d.id_cia = c.id_cia
                                                    AND d.numint = c.numint
                LEFT OUTER JOIN documentos_det          dt ON dt.id_cia = d.id_cia
                                                     AND dt.opnumdoc = d.numint
                                                     AND dt.opnumite = d.numite
                LEFT OUTER JOIN documentos_cab          dr ON dr.id_cia = dt.id_cia
                                                     AND dr.numint = dt.numint
                LEFT OUTER JOIN kardex                  k ON k.id_cia = dt.id_cia
                                            AND k.numint = dt.numint
                                            AND k.numite = dt.numite
                LEFT OUTER JOIN articulos               a ON a.id_cia = k.id_cia
                                               AND a.tipinv = k.tipinv
                                               AND a.codart = k.codart
                LEFT OUTER JOIN documentos_det          dot ON dot.id_cia = c.id_cia
                                                      AND dot.numint = c.numint
                                                      AND dot.numite = dt.opnumite
                LEFT OUTER JOIN kardex                  ka ON ka.id_cia = dot.id_cia
                                             AND ka.numint = dot.numint
                                             AND ka.numite = dot.numite
                LEFT OUTER JOIN articulos               da ON da.id_cia = c.id_cia
                                                AND da.tipinv = dot.tipinv
                                                AND da.codart = dot.codart
                LEFT OUTER JOIN cliente_articulos_clase cd1 ON cd1.id_cia = c.id_cia
                                                               AND cd1.tipcli = 'B'
                                                               AND cd1.codcli = da.codprv
                                                               AND cd1.clase = 1
                                                               AND cd1.codigo = dot.codadd01
                LEFT OUTER JOIN cliente_articulos_clase cd2 ON cd2.id_cia = c.id_cia
                                                               AND cd2.tipcli = 'B'
                                                               AND cd2.codcli = da.codprv
                                                               AND cd2.clase = 2
                                                               AND cd2.codigo = dot.codadd02
                LEFT OUTER JOIN cliente_articulos_clase ca1 ON ca1.id_cia = k.id_cia
                                                               AND ca1.tipcli = 'B'
                                                               AND ca1.codcli = a.codprv
                                                               AND ca1.clase = 1
                                                               AND ca1.codigo = k.codadd01
                LEFT OUTER JOIN cliente_articulos_clase ca2 ON ca2.id_cia = k.id_cia
                                                               AND ca2.tipcli = 'B'
                                                               AND ca2.codcli = a.codprv
                                                               AND ca2.clase = 2
                                                               AND ca2.codigo = k.codadd02
                LEFT OUTER JOIN documentos              d ON d.id_cia = k.id_cia
                                                AND d.codigo = dr.tipdoc
                                                AND d.series = dr.series
                LEFT OUTER JOIN motivos                 m ON m.id_cia = k.id_cia
                                             AND m.tipdoc = k.tipdoc
                                             AND m.id = k.id
                                             AND m.codmot = k.codmot
                LEFT OUTER JOIN motivos_clase           mc ON mc.id_cia = k.id_cia
                                                    AND mc.tipdoc = k.tipdoc
                                                    AND mc.id = k.id
                                                    AND mc.codmot = k.codmot
                                                    AND mc.codigo = 22
                LEFT OUTER JOIN almacen                 al ON al.id_cia = k.id_cia
                                              AND al.tipinv = k.tipinv
                                              AND al.codalm = k.codalm
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = 104
                AND ( pin_codmot = - 1
                      OR c.codmot = pin_codmot )
                AND ( k.id = pin_ingsal
                      OR nvl(mc.valor, 'N') = 'S' )
                AND k.femisi BETWEEN pin_fdesde AND pin_fhasta
                AND ( pin_codcli IS NULL
                      OR c.codcli = pin_codcli
                      OR dr.codcli = pin_codcli )
                AND ( pin_codart IS NULL
                      OR k.codart = pin_codart )
            ORDER BY
                c.razonc,
                c.numint,
                dot.numite,
                k.femisi,
                k.numint,
                k.numite;

        ELSE
            SELECT
                c.id_cia,
                c.numint,
                c.series,
                c.numdoc,
                c.codcli,
                c.razonc,
                dr.numint     AS numintre,
                dr.series     AS seriesre,
                dr.numdoc     AS numdocre,
                dr.codcli     AS codclire,
                dr.razonc     AS razoncre,
                d.nomser      AS abrevi,
                k.femisi,
                k.numite,
                k.tipinv,
                k.codart,
                a.descri      AS desart,
                k.cantid *
                CASE
                    WHEN k.id = pin_ingsal THEN
                            1
                    ELSE
                        1
                END
                AS cantid,
                k.id,
                CASE
                    WHEN k.cantid = 0 THEN
                            0
                    ELSE
                        k.costot01 / k.cantid
                END
                *
                CASE
                    WHEN k.id = pin_ingsal THEN
                            1
                    ELSE
                        1
                END
                AS cosunisol,
                CASE
                    WHEN k.cantid = 0 THEN
                            0
                    ELSE
                        k.costot02 / k.cantid
                END
                *
                CASE
                    WHEN k.id = pin_ingsal THEN
                            1
                    ELSE
                        1
                END
                AS cosunidol,
                k.costot01 *
                CASE
                    WHEN k.id = pin_ingsal THEN
                            1
                    ELSE
                        1
                END
                AS costotsol,
                k.costot02 *
                CASE
                    WHEN k.id = pin_ingsal THEN
                            1
                    ELSE
                        1
                END
                AS costotdol,
                k.codadd01    AS codcalid,
                ca1.descri    AS dcalidad,
                k.codadd02    AS codcolor,
                k.codadd02
                || ' - '
                || ca2.descri AS dcolor,
                k.etiqueta,
                dot.numint    AS numintop,
                dot.numite    AS numiteop,
                dot.tipinv    AS tipinvop,
                dot.codart    AS codartop,
                da.descri     AS desartop,
                ka.cantid     AS cantidop,
                ka.id,
                nvl(k.cosmat01, 0),
                nvl(k.cosmob01, 0),
                nvl(k.cosfab01, 0),
                CASE
                    WHEN ka.cantid = 0 THEN
                        0
                    ELSE
                        ka.costot01 / ka.cantid
                END           AS cosunisolop,
                CASE
                    WHEN ka.cantid = 0 THEN
                        0
                    ELSE
                        ka.costot02 / ka.cantid
                END           AS cosunidolop,
                ka.costot01   AS costotsolop,
                ka.costot02   AS costotdolop,
                m.abrevi      AS abrevmot,
                dot.codadd01  AS codadd01op,
                cd1.descri    AS dcalidadop,
                dot.codadd02  AS codadd02op,
                cd2.descri    AS dcolorop
            BULK COLLECT
            INTO v_table
            FROM
                documentos_cab          c
                LEFT OUTER JOIN documentos_det          d ON d.id_cia = c.id_cia
                                                    AND d.numint = c.numint
                LEFT OUTER JOIN documentos_det          dt ON dt.id_cia = d.id_cia
                                                     AND dt.opnumdoc = d.numint
                                                     AND dt.opnumite = d.numite
                LEFT OUTER JOIN documentos_cab          dr ON dr.id_cia = dt.id_cia
                                                     AND dr.numint = dt.numint
                LEFT OUTER JOIN kardex                  k ON k.id_cia = dt.id_cia
                                            AND k.numint = dt.numint
                                            AND k.numite = dt.numite
                LEFT OUTER JOIN articulos               a ON a.id_cia = k.id_cia
                                               AND a.tipinv = k.tipinv
                                               AND a.codart = k.codart
                LEFT OUTER JOIN documentos_det          dot ON dot.id_cia = c.id_cia
                                                      AND dot.numint = c.numint
                                                      AND dot.numite = dt.opnumite
                LEFT OUTER JOIN kardex                  ka ON ka.id_cia = dot.id_cia
                                             AND ka.numint = dot.numint
                                             AND ka.numite = dot.numite
                LEFT OUTER JOIN articulos               da ON da.id_cia = c.id_cia
                                                AND da.tipinv = dot.tipinv
                                                AND da.codart = dot.codart
                LEFT OUTER JOIN cliente_articulos_clase cd1 ON cd1.id_cia = c.id_cia
                                                               AND cd1.tipcli = 'B'
                                                               AND cd1.codcli = da.codprv
                                                               AND cd1.clase = 1
                                                               AND cd1.codigo = dot.codadd01
                LEFT OUTER JOIN cliente_articulos_clase cd2 ON cd2.id_cia = c.id_cia
                                                               AND cd2.tipcli = 'B'
                                                               AND cd2.codcli = da.codprv
                                                               AND cd2.clase = 2
                                                               AND cd2.codigo = dot.codadd02
                LEFT OUTER JOIN cliente_articulos_clase ca1 ON ca1.id_cia = k.id_cia
                                                               AND ca1.tipcli = 'B'
                                                               AND ca1.codcli = a.codprv
                                                               AND ca1.clase = 1
                                                               AND ca1.codigo = k.codadd01
                LEFT OUTER JOIN cliente_articulos_clase ca2 ON ca2.id_cia = k.id_cia
                                                               AND ca2.tipcli = 'B'
                                                               AND ca2.codcli = a.codprv
                                                               AND ca2.clase = 2
                                                               AND ca2.codigo = k.codadd02
                LEFT OUTER JOIN documentos              d ON d.id_cia = k.id_cia
                                                AND d.codigo = dr.tipdoc
                                                AND d.series = dr.series
                LEFT OUTER JOIN motivos                 m ON m.id_cia = k.id_cia
                                             AND m.tipdoc = k.tipdoc
                                             AND m.id = k.id
                                             AND m.codmot = k.codmot
                LEFT OUTER JOIN motivos_clase           mc ON mc.id_cia = k.id_cia
                                                    AND mc.tipdoc = k.tipdoc
                                                    AND mc.id = k.id
                                                    AND mc.codmot = k.codmot
                                                    AND mc.codigo = 22
                LEFT OUTER JOIN almacen                 al ON al.id_cia = k.id_cia
                                              AND al.tipinv = k.tipinv
                                              AND al.codalm = k.codalm
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = 104
                AND c.series = pin_serie
                AND c.numdoc = pin_numdoc
                AND ( nvl(pin_codmot, - 1) = - 1
                      OR c.codmot = pin_codmot )
                AND ( k.id = pin_ingsal
                      OR nvl(mc.valor, 'N') = 'S' )
            ORDER BY
                c.razonc,
                c.numint,
                dot.numite,
                k.femisi,
                k.numint,
                k.numite;

        END IF;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_movimiento;

    FUNCTION sp_distribucion_costo (
        pin_id_cia NUMBER,
        pin_codmot NUMBER,
        pin_tipinv NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_distribucion_costo
        PIPELINED
    AS
        v_table datatable_distribucion_costo;
    BEGIN
        SELECT
            dd.id_cia,
            dd.opnumdoc      AS opnumdoc,
            dd.opnumite,
            k.femisi,
            dd.opnumdoc      AS keyopnumdoc,
            dc.series,
            dc.numdoc        AS numdoc,
            k.numint         AS numint,
            k.tipinv,
            ti.dtipinv,
            k.codart,
            a.descri         AS desart,
            nvl(dd.largo, 0) AS metraje,
            k.cantid,
            k.cosmat01       AS cosmatsol,
            k.cosmob01       AS cosmobsol,
            k.cosfab01       AS cosfabsol,
            CASE
                WHEN k.cantid = 0 THEN
                    0
                ELSE
                    k.costot01 / k.cantid
            END              AS cosunisol,
            CASE
                WHEN k.cantid = 0 THEN
                    0
                ELSE
                    k.costot02 / k.cantid
            END              AS cosunidol,
            k.costot01       AS costotsol,
            k.costot02       AS costotdol,
            CASE
                WHEN k.id = 'I' THEN
                        'ING'
                ELSE
                    'SAL'
            END
            || ' por '
            || dm.descri
            || ' - '
            || mt.desmot     AS concepto,
            k.id
        BULK COLLECT
        INTO v_table
        FROM
                 kardex k
            INNER JOIN documentos_cab dc ON dc.id_cia = k.id_cia
                                            AND dc.numint = k.numint
            LEFT OUTER JOIN documentos     dm ON dm.id_cia = dc.id_cia
                                             AND dm.codigo = dc.tipdoc
                                             AND dm.series = dc.series
                                             AND dm.codsuc = 1
            INNER JOIN documentos_det dd ON dd.id_cia = k.id_cia
                                            AND dd.numint = k.numint
                                            AND dd.numite = k.numite
            LEFT OUTER JOIN almacen        al ON al.id_cia = k.id_cia
                                          AND al.codalm = k.codalm
                                          AND al.tipinv = k.tipinv
            LEFT OUTER JOIN motivos        mt ON mt.id_cia = k.id_cia
                                          AND mt.tipdoc = k.tipdoc
                                          AND mt.id = k.id
                                          AND mt.codmot = k.codmot
            LEFT OUTER JOIN t_inventario   ti ON ti.id_cia = k.id_cia
                                               AND ti.tipinv = k.tipinv
            LEFT OUTER JOIN articulos      a ON a.id_cia = k.id_cia
                                           AND a.tipinv = k.tipinv
                                           AND a.codart = k.codart
            LEFT OUTER JOIN kardex001      k1 ON k1.id_cia = k.id_cia
                                            AND k1.tipinv = k.tipinv
                                            AND k1.codart = k.codart
                                            AND k1.codalm = k.codalm
                                            AND k1.etiqueta = k.etiqueta
        WHERE
                k.id_cia = pin_id_cia
            AND k.tipdoc = 103
            AND k.id = 'I'
            AND ( nvl(pin_codmot, - 1) = - 1
                  OR k.codmot = pin_codmot )
            AND k.tipinv = pin_tipinv
            AND k.femisi BETWEEN pin_fdesde AND pin_fhasta
        ORDER BY
                CASE
                    WHEN k.id = 'I' THEN
                        'ING'
                    ELSE
                        'SAL'
                END
                || ' por '
                || dm.descri
                || ' - '
                || mt.desmot,
                dd.opnumdoc,
                dd.opnumite,
                k.femisi,
                dc.series,
                dc.numdoc;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_distribucion_costo;

    FUNCTION sp_reporte_detallado (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_reporte_detallado
        PIPELINED
    AS
        v_table datatable_reporte_detallado;
    BEGIN
        SELECT
            c.id_cia,
            cm.ruc                                  AS ciaruc,
            cm.razsoc                               AS ciarazonc,
            c.numint                                AS numint,
            d.numite                                AS numite,
            c.series                                AS series,
            c.numdoc                                AS numdoc,
            c.femisi                                AS femisi,
            c.fentreg                               AS fentreg,
            c.codcli                                AS codcli,
            c.razonc                                AS razonc,
            c.ruc                                   AS ruc,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                                     AS numped,
            dx.descri                               AS desdoc,
            dx.nomser                               AS nomser,
            mt.desmot                               AS desmot,
            s2.dessit                               AS dessit,
            s2.alias                                AS aliassit,
            d.tipinv                                AS tipinv,
            d.codart                                AS codart,
            a.descri
            || '-'
            ||
            CASE
                WHEN cdc.abrevi IS NOT NULL
                     AND cdc.abrevi <> '' THEN
                        cdc.abrevi
                ELSE
                    CASE
                        WHEN cdc.descri IS NULL THEN
                                    ' '
                        ELSE
                            cdc.descri
                    END
            END
            AS desartclase,
            d.cantid                                AS cantid,
            decode(d.piezas, 0, d.cantid, d.piezas) AS piezas,
            d.largo                                 AS largo,
            d.codalm                                AS codalm,
            d.observ                                AS obsdet,
            a.coduni                                AS coduni,
            a.descri                                AS desart,
            c.fecter                                AS fmeta,
            t1.series
            || '-'
            || t1.numdoc                            AS nropedido
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab                                                    c
            LEFT OUTER JOIN pack_trazabilidad.sp_trazabilidad_tipdoc(c.id_cia, c.numint, 101) t1 ON 0 = 0
            LEFT OUTER JOIN documentos                                                        dx ON dx.id_cia = c.id_cia
                                             AND dx.codigo = c.tipdoc
                                             AND dx.series = c.series
            LEFT OUTER JOIN documentos_cab_clase                                              cc ON cc.id_cia = c.id_cia
                                                       AND cc.numint = c.numint
                                                       AND cc.clase = 6
            LEFT OUTER JOIN motivos                                                           mt ON mt.id_cia = c.id_cia
                                          AND mt.codmot = c.codmot
                                          AND mt.id = c.id
                                          AND mt.tipdoc = c.tipdoc
            LEFT OUTER JOIN situacion                                                         s2 ON s2.id_cia = c.id_cia
                                            AND s2.situac = c.situac
                                            AND s2.tipdoc = c.tipdoc
            LEFT OUTER JOIN documentos_det                                                    d ON d.id_cia = c.id_cia
                                                AND d.numint = c.numint
            LEFT OUTER JOIN articulos                                                         a ON a.id_cia = d.id_cia
                                           AND a.codart = d.codart
                                           AND a.tipinv = d.tipinv
            LEFT OUTER JOIN documentos_det_clase                                              dc ON dc.id_cia = c.id_cia
                                                       AND dc.numint = c.numint
                                                       AND dc.numite = d.numite
                                                       AND dc.clase = 1
            LEFT OUTER JOIN clase_documentos_det_codigo                                       cdc ON cdc.id_cia = c.id_cia
                                                               AND cdc.tipdoc = c.tipdoc
                                                               AND cdc.clase = dc.clase
                                                               AND cdc.codigo = dc.codigo
            LEFT OUTER JOIN companias                                                         cm ON cm.cia = c.id_cia
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
            c.numint,
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_detallado;

    FUNCTION sp_reporte_resumen (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_reporte_resumen
        PIPELINED
    AS
        v_table datatable_reporte_resumen;
    BEGIN
        SELECT
            c.id_cia,
            cm.ruc                                AS ciaruc,
            d.numint                              AS numint,
--            d.numite                              AS numite,
            0                                     AS numite,
            c.series                              AS series,
            c.numdoc                              AS numdoc,
            c.femisi                              AS femisi,
            c.codcli                              AS codcli,
            c.razonc                              AS razonc,
            c.direc1                              AS direc1,
            c.ruc                                 AS ruc,
            a1.desarea                            AS desarea,
            mt.desmot                             AS desmot,
            s2.dessit                             AS dessit,
            s2.alias                              AS aliassit,
            d.tipinv                              AS tipinv,
            d.codart                              AS codart,
            a.descri                              AS desart,
            decode(nvl(d.largo, 0),
                   0,
                   1,
                   d.largo)                       AS largo,
            SUM(d.cantid * decode(nvl(d.largo, 0),
                                  0,
                                  1,
                                  d.largo))                             AS cantid,
            a.coduni                              AS coduni,
            SUM(
                CASE
                    WHEN a.consto = 2 THEN
                        d.cantid * decode(nvl(d.largo, 0),
                                          0,
                                          1,
                                          d.largo)
                    ELSE
                        0
                END
                / decode(dd.piezas, 0, 1, dd.piezas)) AS medida,
            SUM(
                CASE
                    WHEN a.consto = 2 THEN
                        d.cantid * decode(nvl(d.largo, 0),
                                          0,
                                          1,
                                          d.largo)
                    ELSE
                        0
                END
            )                                     AS total,
            d.codalm,
            d.observ                              AS obsdet
        BULK COLLECT
        INTO v_table
        FROM
            documentos_materiales d
            LEFT OUTER JOIN documentos_cab        c ON c.id_cia = d.id_cia
                                                AND c.numint = d.numint
            LEFT OUTER JOIN documentos_det        dd ON dd.id_cia = c.id_cia
                                                 AND dd.numint = c.numint
                                                 AND dd.numite = d.numite
            LEFT OUTER JOIN articulos             a ON a.id_cia = d.id_cia
                                           AND a.codart = d.codart
                                           AND a.tipinv = d.tipinv
            LEFT OUTER JOIN motivos               mt ON mt.id_cia = c.id_cia
                                          AND mt.codmot = c.codmot
                                          AND mt.id = c.id
                                          AND mt.tipdoc = c.tipdoc
            LEFT OUTER JOIN areas                 a1 ON a1.id_cia = c.id_cia
                                        AND a1.codarea = c.codarea
            LEFT OUTER JOIN situacion             s2 ON s2.id_cia = c.id_cia
                                            AND s2.situac = c.situac
                                            AND s2.tipdoc = c.tipdoc
            LEFT OUTER JOIN companias             cm ON cm.cia = c.id_cia
        WHERE
                d.id_cia = pin_id_cia
            AND d.numint = pin_numint
        GROUP BY
            c.id_cia,
            cm.ruc,
            d.numint,
            0,
            c.series,
            c.numdoc,
            c.femisi,
            c.codcli,
            c.razonc,
            c.direc1,
            c.ruc,
            a1.desarea,
            mt.desmot,
            s2.dessit,
            s2.alias,
            d.tipinv,
            d.codart,
            d.largo,
            a.coduni,
            a.descri,
            d.codalm,
            d.observ
        ORDER BY
            d.tipinv,
            d.codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_resumen;

    FUNCTION sp_reporte_frabricacion_material (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_reporte_frabricacion_material
        PIPELINED
    AS
        v_table datatable_reporte_frabricacion_material;
    BEGIN
        SELECT
            'D',
            d.id_cia,
            d.numint,
            d.numite,
            d.numsec,
            d.tipinv,
            t.dtipinv,
            d.codalm,
            l.descri                                      AS desalm,
            d.codart,
            a.descri                                      AS desart,
            a.consto,
            a.coduni                                      AS coduni,
            d.observ                                      AS obsdet,
            SUM(nvl(d.cantid, 0))                         AS piezas,
            SUM(decode(nvl(d.largo, 0),
                       0,
                       1,
                       d.largo))                                     AS largo,
            SUM(
                CASE
                    WHEN a.consto = 2 THEN
                        decode(dd.piezas, 0, dd.cantid, dd.piezas)
                    ELSE
                        d.cantid * decode(nvl(d.largo, 0),
                                          0,
                                          1,
                                          d.largo)
                END
            )                                             AS cantid,
            SUM(
                CASE
                    WHEN a.consto = 2 THEN
                        d.cantid * decode(nvl(d.largo, 0),
                                          0,
                                          1,
                                          d.largo)
                    ELSE
                        0
                END
                / decode(dd.piezas, 0, dd.cantid, dd.piezas)) AS medida,
            SUM(
                CASE
                    WHEN a.consto = 2 THEN
                        d.cantid * decode(nvl(d.largo, 0),
                                          0,
                                          1,
                                          d.largo)
                    ELSE
                        0
                END
            )                                             AS total
        BULK COLLECT
        INTO v_table
        FROM
            documentos_materiales d
            LEFT OUTER JOIN documentos_det        dd ON dd.id_cia = d.id_cia
                                                 AND dd.numint = d.numint
                                                 AND dd.numite = d.numite
            LEFT OUTER JOIN t_inventario          t ON t.id_cia = d.id_cia
                                              AND t.tipinv = d.tipinv
            LEFT OUTER JOIN articulos             a ON a.id_cia = d.id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
            LEFT OUTER JOIN almacen               l ON l.id_cia = d.id_cia
                                         AND l.tipinv = d.tipinv
                                         AND l.codalm = d.codalm
        WHERE
                d.id_cia = pin_id_cia
            AND d.numint = pin_numint
            AND ( pin_numite IS NULL
                  OR d.numite = pin_numite )
        GROUP BY
            'D',
            d.id_cia,
            d.numint,
            d.numite,
            d.numsec,
            d.tipinv,
            t.dtipinv,
            d.codalm,
            l.descri,
            d.codart,
            a.descri,
            a.consto,
            a.coduni,
            d.observ
        ORDER BY
            d.numite,
            d.numsec;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_frabricacion_material;

    FUNCTION sp_reporte_frabricacion_documento (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_reporte_frabricacion_documento
        PIPELINED
    AS
        v_table datatable_reporte_frabricacion_documento;
    BEGIN
        SELECT
            cm.cia                                  AS id_cia,
            cm.ruc                                  AS ciaruc,
            cm.razsoc                               AS ciarazonc,
            c.numint                                AS numint,
            d.numite                                AS numite,
            c.series                                AS series,
            c.numdoc                                AS numdoc,
            c.femisi                                AS femisi,
            c.fentreg                               AS fentreg,
            c.codcli                                AS codcli,
            c.razonc                                AS razonc,
            c.ruc                                   AS ruc,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                                     AS numped,
            dx.descri                               AS desdoc,
            dx.nomser                               AS nomser,
            mt.desmot                               AS desmot,
            s.dessit                                AS dessit,
            s.alias                                 AS aliassit,
            d.tipinv                                AS tipinv,
            d.codart                                AS codart,
            a.descri
            || '-'
            ||
            CASE
                WHEN cdc.abrevi IS NOT NULL
                     AND cdc.abrevi <> '' THEN
                        cdc.abrevi
                ELSE
                    CASE
                        WHEN cdc.descri IS NULL THEN
                                    ' '
                        ELSE
                            cdc.descri
                    END
            END
            AS desartclase,
            d.cantid                                AS cantid,
            decode(d.piezas, 0, d.cantid, d.piezas) AS piezas,
            d.largo                                 AS largo,
            d.codalm                                AS codalm,
            d.observ                                AS obsdet,
            a.coduni                                AS coduni,
            a.descri                                AS desart,
            c.fecter                                AS fmeta,
            t1.series
            || '-'
            || t1.numdoc                            AS nropedido
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab                                                    c
            LEFT OUTER JOIN pack_trazabilidad.sp_trazabilidad_tipdoc(c.id_cia, c.numint, 101) t1 ON 0 = 0
            LEFT OUTER JOIN documentos                                                        dx ON dx.id_cia = pin_id_cia
                                             AND dx.codigo = c.tipdoc
                                             AND dx.series = c.series
            LEFT OUTER JOIN documentos_cab_clase                                              cc ON cc.id_cia = c.id_cia
                                                       AND cc.numint = c.numint
                                                       AND cc.clase = 6
            LEFT OUTER JOIN motivos                                                           mt ON mt.id_cia = c.id_cia
                                          AND mt.codmot = c.codmot
                                          AND mt.id = c.id
                                          AND mt.tipdoc = c.tipdoc
            LEFT OUTER JOIN situacion                                                         s ON s.id_cia = c.id_cia
                                           AND s.situac = c.situac
                                           AND s.tipdoc = c.tipdoc
            LEFT OUTER JOIN documentos_det                                                    d ON d.id_cia = c.id_cia
                                                AND d.numint = c.numint
            LEFT OUTER JOIN articulos                                                         a ON a.id_cia = d.id_cia
                                           AND a.codart = d.codart
                                           AND a.tipinv = d.tipinv
            LEFT OUTER JOIN documentos_det_clase                                              dc ON dc.id_cia = c.id_cia
                                                       AND dc.numint = c.numint
                                                       AND dc.numite = d.numite
                                                       AND dc.clase = 1
            LEFT OUTER JOIN clase_documentos_det_codigo                                       cdc ON cdc.id_cia = d.id_cia
                                                               AND cdc.tipdoc = d.tipdoc
                                                               AND cdc.clase = dc.clase
                                                               AND cdc.codigo = dc.codigo
            LEFT OUTER JOIN companias                                                         cm ON cm.cia = c.id_cia
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
            c.numint,
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_frabricacion_documento;

    FUNCTION sp_reporte_frabricacion_material_final (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_reporte_frabricacion_material
        PIPELINED
    AS
        v_table datatable_reporte_frabricacion_material;
        v_rec   datarecord_reporte_frabricacion_material;
    BEGIN
        FOR i IN (
            SELECT
                'C' AS cabdet,
                id_cia,
                numint,
                numite,
                tipinv,
                ''  AS dtipinv,
                codalm,
                ''  AS desalm,
                codart,
                desart,
                0   AS consto,
                coduni,
                obsdet,
                piezas,
                largo,
                cantid,
                0   AS medida,
                0   AS total
            FROM
                pack_documentos_produccion.sp_reporte_detallado(pin_id_cia, pin_numint)
        ) LOOP
            v_rec.cabdet := i.cabdet;
            v_rec.id_cia := i.id_cia;
            v_rec.numint := i.numint;
            v_rec.numite := i.numite;
            v_rec.tipinv := i.tipinv;
            v_rec.dtipinv := i.dtipinv;
            v_rec.codalm := i.codalm;
            v_rec.desalm := i.desalm;
            v_rec.codart := i.codart;
            v_rec.desart := i.desart;
            v_rec.consto := i.consto;
            v_rec.coduni := i.coduni;
            v_rec.obsdet := i.obsdet;
            v_rec.piezas := i.piezas;
            v_rec.largo := i.largo;
            v_rec.cantid := i.cantid;
            v_rec.medida := i.medida;
            v_rec.total := i.total;
            PIPE ROW ( v_rec );
            SELECT
                *
            BULK COLLECT
            INTO v_table
            FROM
                pack_documentos_produccion.sp_reporte_frabricacion_material(pin_id_cia, pin_numint, i.numite);

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        END LOOP;

        RETURN;
    END sp_reporte_frabricacion_material_final;

END;

/
