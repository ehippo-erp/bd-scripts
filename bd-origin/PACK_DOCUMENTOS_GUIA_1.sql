--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_GUIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_GUIA" AS

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_inggui NUMBER
    ) RETURN datatable_buscar
        PIPELINED
    AS

        v_gr    NUMBER := 0;
        v_gi    NUMBER := 0;
        v_table datatable_buscar;
        v_rec   datarecord_buscar;
        /* select cabecera */
        CURSOR documentos_cab IS
        SELECT
            c.id_cia,
            c.numint,
--            c.tipdoc,
            c.series,
            c.numdoc,
            c.codcli,
            c.razonc,
            c.femisi
        FROM
            documentos_cab c
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 102
            AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
            AND c.situac IN ( 'F', 'C', 'G', 'H' )
            AND c.codmot = 17
        ORDER BY
            c.femisi DESC;

    BEGIN
        IF pin_inggui <= 0 OR pin_inggui IS NULL THEN
            FOR k IN documentos_cab LOOP
                SELECT
                    t.*
                BULK COLLECT
                INTO v_table
                FROM
                    (
                        SELECT
                            k.id_cia,
                            k.numint,
                            k.series,
                            k.numdoc,
                            k.codcli,
                            k.razonc,
                            k.femisi,
                            d1.tipdoc,
                            'G.REMISION' AS dtipdoc,
                            'GR'         AS atipdoc,
                            k.numint     AS ginumint,
                            k.series     AS giseries,
                            k.numdoc     AS ginumdoc,
                            k.femisi     AS gifemisi,
                            d1.tipinv,
                            d1.codart,
                            a1.descri,
                            d1.cantid,
                            d1.etiqueta,
                            d1.ancho,
                            d1.nrocarrete,
                            d1.lote,
                            d1.fvenci
                        FROM
                            documentos_det d1
                            LEFT OUTER JOIN articulos      a1 ON a1.id_cia = d1.id_cia
                                                            AND a1.tipinv = d1.tipinv
                                                            AND a1.codart = d1.codart
                        WHERE
                                d1.id_cia = k.id_cia
                            AND d1.numint = k.numint
                        UNION ALL
                        SELECT
                            k.id_cia,
                            k.numint,
                            k.series,
                            k.numdoc,
                            k.codcli,
                            k.razonc,
                            k.femisi,
                            d1.tipdoc,
                            'G.INTERNA' AS dtipdoc,
                            'GI'        AS atipdoc,
                            c2.numint   AS ginumint,
                            c2.series   AS giseries,
                            c2.numdoc   AS ginumdoc,
                            c2.femisi   AS gifemisi,
                            d1.tipinv,
                            d1.codart,
                            a1.descri,
                            d1.cantid,
                            d1.etiqueta,
                            d1.ancho,
                            d1.nrocarrete,
                            d1.lote,
                            d1.fvenci
                        FROM
                            documentos_relacion t
                            LEFT OUTER JOIN documentos_cab      c2 ON c2.id_cia = t.id_cia
                                                                 AND c2.numint = t.numint
                            LEFT OUTER JOIN documentos_det      d1 ON d1.id_cia = t.id_cia
                                                                 AND d1.numint = t.numint
                            LEFT OUTER JOIN articulos           a1 ON a1.id_cia = t.id_cia
                                                            AND a1.tipinv = d1.tipinv
                                                            AND a1.codart = d1.codart
                        WHERE
                                t.id_cia = k.id_cia
                            AND t.numintre = k.numint
                            AND c2.situac <> 'J'
                            AND c2.tipdoc = 103
                            AND c2.id = 'I'
                            AND c2.codmot = 10
                    ) t
                ORDER BY
                    k.femisi DESC,
                    k.series DESC,
                    k.numdoc DESC,
                    t.atipdoc DESC,
                    t.ginumint DESC;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

            END LOOP;

            RETURN;
        ELSIF pin_inggui = 1 THEN
            FOR k IN documentos_cab LOOP
--                SELECT
--                    t.*
--                BULK COLLECT
--                INTO v_table
--                FROM
--                    (
--                        SELECT
--                            k.id_cia     AS id_cia,
--                            k.numint,
--                            k.series,
--                            k.numdoc,
--                            k.codcli,
--                            k.razonc,
--                            k.femisi,
--                            d1.tipdoc,
--                            'G.REMISION' AS dtipdoc,
--                            'GR'         AS atipdoc,
--                            k.numint     AS ginumint,
--                            k.series     AS giseries,
--                            k.numdoc     AS ginumdoc,
--                            k.femisi     AS gifemisi,
--                            d1.tipinv,
--                            d1.codart,
--                            a1.descri,
--                            d1.cantid,
--                            d1.etiqueta,
--                            d1.ancho,
--                            d1.nrocarrete,
--                            d1.lote,
--                            d1.fvenci
--                        FROM
--                            documentos_det d1
--                            LEFT OUTER JOIN articulos      a1 ON a1.id_cia = d1.id_cia
--                                                            AND a1.tipinv = d1.tipinv
--                                                            AND a1.codart = d1.codart
--                        WHERE
--                                d1.id_cia = k.id_cia
--                            AND d1.numint = k.numint
--                        UNION ALL
--                        SELECT
--                            k.id_cia    AS id_cia,
--                            k.numint,
--                            k.series,
--                            k.numdoc,
--                            k.codcli,
--                            k.razonc,
--                            k.femisi,
--                            d1.tipdoc,
--                            'G.INTERNA' AS dtipdoc,
--                            'GI'        AS atipdoc,
--                            c2.numint   AS ginumint,
--                            c2.series   AS giseries,
--                            c2.numdoc   AS ginumdoc,
--                            c2.femisi   AS gifemisi,
--                            d1.tipinv,
--                            d1.codart,
--                            a1.descri,
--                            d1.cantid,
--                            d1.etiqueta,
--                            d1.ancho,
--                            d1.nrocarrete,
--                            d1.lote,
--                            d1.fvenci
--                        FROM
--                            documentos_relacion t
--                            LEFT OUTER JOIN documentos_cab      c2 ON c2.id_cia = t.id_cia
--                                                                 AND c2.numint = t.numint
--                            LEFT OUTER JOIN documentos_det      d1 ON d1.id_cia = t.id_cia
--                                                                 AND d1.numint = t.numint
--                            LEFT OUTER JOIN articulos           a1 ON a1.id_cia = t.id_cia
--                                                            AND a1.tipinv = d1.tipinv
--                                                            AND a1.codart = d1.codart
--                        WHERE
--                                t.id_cia = k.id_cia
--                            AND t.numintre = k.numint
--                            AND c2.tipdoc = 103
--                            AND c2.id = 'I'
--                            AND c2.codmot = 10
--                    ) t
--                WHERE
--                    NOT EXISTS (
--                        SELECT
--                            dr.*
--                        FROM
--                            documentos_relacion dr
--                            LEFT OUTER JOIN documentos_cab      cc2 ON cc2.id_cia = dr.id_cia
--                                                                  AND cc2.numint = dr.numint
--                        WHERE
--                                dr.id_cia = k.id_cia
--                            AND dr.numintre = k.numint
--                            AND cc2.tipdoc = 103
--                            AND cc2.id = 'I'
--                            AND cc2.codmot = 10
--                    )
--                ORDER BY
--                    k.femisi DESC,
--                    k.series DESC,
--                    k.numdoc DESC,
--                    t.atipdoc DESC;
--
--                FOR registro IN 1..v_table.count LOOP
--                    PIPE ROW ( v_table(registro) );
--                END LOOP;
--
--            END LOOP;
--            
--                RETURN;

                BEGIN
                    SELECT
                        nvl(COUNT(d1.numite),
                            0) AS gr
                    INTO v_gr
                    FROM
                        documentos_det d1
                    WHERE
                            d1.id_cia = k.id_cia
                        AND d1.numint = k.numint;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_gr := 0;
                END;

                BEGIN
                    SELECT
                        nvl(COUNT(d1.numite),
                            0) AS gi
                    INTO v_gi
                    FROM
                        documentos_relacion t
                        LEFT OUTER JOIN documentos_cab      c2 ON c2.id_cia = t.id_cia
                                                             AND c2.numint = t.numint
                        LEFT OUTER JOIN documentos_det      d1 ON d1.id_cia = t.id_cia
                                                             AND d1.numint = t.numint
                    WHERE
                            t.id_cia = k.id_cia
                        AND t.numintre = k.numint
                        AND c2.situac <> 'J'
                        AND c2.tipdoc = 103
                        AND c2.id = 'I'
                        AND c2.codmot = 10;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_gi := 0;
                END;

                IF v_gi < v_gr THEN
                    SELECT
                        t.*
                    BULK COLLECT
                    INTO v_table
                    FROM
                        (
                            SELECT
                                k.id_cia     AS id_cia,
                                k.numint,
                                k.series,
                                k.numdoc,
                                k.codcli,
                                k.razonc,
                                k.femisi,
                                d1.tipdoc,
                                'G.REMISION' AS dtipdoc,
                                'GR'         AS atipdoc,
                                k.numint     AS ginumint,
                                k.series     AS giseries,
                                k.numdoc     AS ginumdoc,
                                k.femisi     AS gifemisi,
                                d1.tipinv,
                                d1.codart,
                                a1.descri,
                                d1.cantid,
                                d1.etiqueta,
                                d1.ancho,
                                d1.nrocarrete,
                                d1.lote,
                                d1.fvenci
                            FROM
                                documentos_det d1
                                LEFT OUTER JOIN articulos      a1 ON a1.id_cia = d1.id_cia
                                                                AND a1.tipinv = d1.tipinv
                                                                AND a1.codart = d1.codart
                            WHERE
                                    d1.id_cia = k.id_cia
                                AND d1.numint = k.numint
                            UNION ALL
                            SELECT
                                k.id_cia    AS id_cia,
                                k.numint,
                                k.series,
                                k.numdoc,
                                k.codcli,
                                k.razonc,
                                k.femisi,
                                d1.tipdoc,
                                'G.INTERNA' AS dtipdoc,
                                'GI'        AS atipdoc,
                                c2.numint   AS ginumint,
                                c2.series   AS giseries,
                                c2.numdoc   AS ginumdoc,
                                c2.femisi   AS gifemisi,
                                d1.tipinv,
                                d1.codart,
                                a1.descri,
                                d1.cantid,
                                d1.etiqueta,
                                d1.ancho,
                                d1.nrocarrete,
                                d1.lote,
                                d1.fvenci
                            FROM
                                documentos_relacion t
                                LEFT OUTER JOIN documentos_cab      c2 ON c2.id_cia = t.id_cia
                                                                     AND c2.numint = t.numint
                                LEFT OUTER JOIN documentos_det      d1 ON d1.id_cia = t.id_cia
                                                                     AND d1.numint = t.numint
                                LEFT OUTER JOIN articulos           a1 ON a1.id_cia = t.id_cia
                                                                AND a1.tipinv = d1.tipinv
                                                                AND a1.codart = d1.codart
                            WHERE
                                    t.id_cia = k.id_cia
                                AND t.numintre = k.numint
                                AND c2.situac <> 'J'
                                AND c2.tipdoc = 103
                                AND c2.id = 'I'
                                AND c2.codmot = 10
                        ) t
                    ORDER BY
                        k.femisi DESC,
                        k.series DESC,
                        k.numdoc DESC,
                        t.atipdoc DESC,
                        t.ginumint DESC;

                    FOR registro IN 1..v_table.count LOOP
                        PIPE ROW ( v_table(registro) );
                    END LOOP;

                END IF;

            END LOOP;

            RETURN;
        ELSE
            FOR k IN documentos_cab LOOP
                BEGIN
                    SELECT
                        nvl(COUNT(d1.numite),
                            0) AS gr
                    INTO v_gr
                    FROM
                        documentos_det d1
                    WHERE
                            d1.id_cia = k.id_cia
                        AND d1.numint = k.numint;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_gr := 0;
                END;

                BEGIN
                    SELECT
                        nvl(COUNT(d1.numite),
                            0) AS gi
                    INTO v_gi
                    FROM
                        documentos_relacion t
                        LEFT OUTER JOIN documentos_cab      c2 ON c2.id_cia = t.id_cia
                                                             AND c2.numint = t.numint
                        LEFT OUTER JOIN documentos_det      d1 ON d1.id_cia = t.id_cia
                                                             AND d1.numint = t.numint
                    WHERE
                            t.id_cia = k.id_cia
                        AND t.numintre = k.numint
                        AND c2.situac <> 'J'
                        AND c2.tipdoc = 103
                        AND c2.id = 'I'
                        AND c2.codmot = 10;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_gi := 0;
                END;

                IF v_gi >= v_gr THEN
                    SELECT
                        t.*
                    BULK COLLECT
                    INTO v_table
                    FROM
                        (
                            SELECT
                                k.id_cia     AS id_cia,
                                k.numint,
                                k.series,
                                k.numdoc,
                                k.codcli,
                                k.razonc,
                                k.femisi,
                                d1.tipdoc,
                                'G.REMISION' AS dtipdoc,
                                'GR'         AS atipdoc,
                                k.numint     AS ginumint,
                                k.series     AS giseries,
                                k.numdoc     AS ginumdoc,
                                k.femisi     AS gifemisi,
                                d1.tipinv,
                                d1.codart,
                                a1.descri,
                                d1.cantid,
                                d1.etiqueta,
                                d1.ancho,
                                d1.nrocarrete,
                                d1.lote,
                                d1.fvenci
                            FROM
                                documentos_det d1
                                LEFT OUTER JOIN articulos      a1 ON a1.id_cia = d1.id_cia
                                                                AND a1.tipinv = d1.tipinv
                                                                AND a1.codart = d1.codart
                            WHERE
                                    d1.id_cia = k.id_cia
                                AND d1.numint = k.numint
                            UNION ALL
                            SELECT
                                k.id_cia    AS id_cia,
                                k.numint,
                                k.series,
                                k.numdoc,
                                k.codcli,
                                k.razonc,
                                k.femisi,
                                d1.tipdoc,
                                'G.INTERNA' AS dtipdoc,
                                'GI'        AS atipdoc,
                                c2.numint   AS ginumint,
                                c2.series   AS giseries,
                                c2.numdoc   AS ginumdoc,
                                c2.femisi   AS gifemisi,
                                d1.tipinv,
                                d1.codart,
                                a1.descri,
                                d1.cantid,
                                d1.etiqueta,
                                d1.ancho,
                                d1.nrocarrete,
                                d1.lote,
                                d1.fvenci
                            FROM
                                documentos_relacion t
                                LEFT OUTER JOIN documentos_cab      c2 ON c2.id_cia = t.id_cia
                                                                     AND c2.numint = t.numint
                                LEFT OUTER JOIN documentos_det      d1 ON d1.id_cia = t.id_cia
                                                                     AND d1.numint = t.numint
                                LEFT OUTER JOIN articulos           a1 ON a1.id_cia = t.id_cia
                                                                AND a1.tipinv = d1.tipinv
                                                                AND a1.codart = d1.codart
                            WHERE
                                    t.id_cia = k.id_cia
                                AND t.numintre = k.numint
                                AND c2.tipdoc = 103
                                AND c2.id = 'I'
                                AND c2.codmot = 10
                                AND c2.situac <> 'J'
                        ) t
                    ORDER BY
                        k.femisi DESC,
                        k.series DESC,
                        k.numdoc DESC,
                        t.atipdoc DESC,
                        t.ginumint DESC;

                    FOR registro IN 1..v_table.count LOOP
                        PIPE ROW ( v_table(registro) );
                    END LOOP;

                END IF;

            END LOOP;

            RETURN;
        END IF;
    END sp_buscar;

    PROCEDURE sp_update_guiarem_cv (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_tipdoc     NUMBER;
        v_serie      VARCHAR2(5 CHAR);
        v_numdoc     NUMBER;
        v_femisi     DATE;
        pout_mensaje VARCHAR2(1000);
    BEGIN
        SELECT
            tipdoc,
            series,
            numdoc,
            femisi
        INTO
            v_tipdoc,
            v_serie,
            v_numdoc,
            v_femisi
        FROM
            documentos_cab
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        IF v_tipdoc IN ( 1, 3 ) THEN
            FOR i IN (
                SELECT
                    series,
                    numdoc,
                    femisi
                FROM
                    pack_trazabilidad.sp_trazabilidad_tipdoc(pin_id_cia, pin_numint, 102)
                FETCH NEXT 1 ROWS ONLY
            ) LOOP
                UPDATE documentos_cab
                SET
                    guipro = i.series
                             || '-'
                             || i.numdoc,
                    fguipro = i.femisi
                WHERE
                        id_cia = pin_id_cia
                    AND numint = pin_numint;

            END LOOP;

        ELSIF v_tipdoc = 102 THEN
            FOR i IN (
                SELECT
                    series,
                    numintre
                FROM
                    documentos_relacion
                WHERE
                        id_cia = pin_id_cia
                    AND numint = pin_numint
            ) LOOP
                UPDATE documentos_cab
                SET
                    guipro = v_serie
                             || '-'
                             || v_numdoc,
                    fguipro = v_femisi
                WHERE
                        id_cia = pin_id_cia
                    AND numint = i.numintre;

            END LOOP;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
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

END;

/
