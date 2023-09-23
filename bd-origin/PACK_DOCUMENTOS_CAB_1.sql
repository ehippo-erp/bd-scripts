--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_CAB
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_CAB" AS

    FUNCTION sp_cotizaciones_padre (
        pin_id_cia NUMBER,
        pin_fhasta DATE,
        pin_tipmon VARCHAR2,
        pin_codsuc NUMBER,
        pin_codcli VARCHAR2
    ) RETURN datatable_cotizaciones_padre
        PIPELINED
    AS
        v_table datatable_cotizaciones_padre;
    BEGIN
        SELECT
            c.numint,
            c.codsuc,
            'ND'      AS sucursal,
            /*s.sucursal,*/
            c.tipdoc,
            c.series,
            c.numdoc,
            c.femisi,
            c.numped,
            c.presen,
            c.tipmon,
            c.preven,
            c.codcli,
            c.razonc,
            c.situac,
            st.dessit AS situacdesc,
            'ND'      AS docrelpen,
            /*(
                SELECT
                    sp_trazabilidad_doc_ae(c.id_cia, c.numint)
                FROM
                    dual
            )         AS docrelpen,*/
            cv.despag AS despagven,
            c.codmot,
            m.desmot
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab c
            LEFT OUTER JOIN motivos        m ON m.id_cia = c.id_cia
                                         AND m.tipdoc = c.tipdoc
                                         AND m.id = c.id
                                         AND m.codmot = c.codmot
            LEFT OUTER JOIN c_pago         cv ON cv.id_cia = c.id_cia
                                         AND cv.codpag = c.codcpag
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN situacion      st ON st.id_cia = c.id_cia
                                            AND st.tipdoc = c.tipdoc
                                            AND st.situac = c.situac
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 100
            AND c.situac IN ( 'O', 'G' )
            AND femisi <= pin_fhasta
            AND ( pin_codsuc = - 1
                  OR c.codsuc = pin_codsuc )
            AND ( pin_codcli IS NULL
                  OR c.codcli = pin_codcli )
            AND ( tipmon = pin_tipmon )
        ORDER BY
            c.numdoc DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

    END sp_cotizaciones_padre;

    FUNCTION sp_guias_remision_padre (
        pin_id_cia  NUMBER,
        pin_fhasta  DATE,
        pin_codsuc  NUMBER,
        pin_codcli  VARCHAR2,
        pin_tipmon  VARCHAR2,
        pin_codmot  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_guias_remision_padre
        PIPELINED
    AS
        v_table datatable_guias_remision_padre;
    BEGIN
        SELECT
            c.numint,
            c.series,
            c.numdoc,
            c.tident,
            c.ruc,
            c.codcli,
            c.razonc    AS razonsocial,
            c.direc1    AS direccion,
            cl.telefono AS telefono,
            c.femisi,
            c.fentreg   AS fentreg,
            c.lugemi,
            c.situac,
            s.dessit    AS situacnombre,
            c.id,
            c.codmot,
            c.codven,
            c.codsuc,
            c.tipmon    AS moneda,
            c.tipcam,
            c.fecter    AS fecter,
            c.horter    AS horapactada,
            c.observ    AS observacion,
            c.codveh    AS codigovehiculo,
            c.codalm    AS codalm,
            c.almdes    AS codalmdestino,
            c.codpunpar AS codigopuntopartida,
            c.ubigeopar AS ubigeopuntopartida,
            c.direccpar AS direccpuntopartida,
            c.presen    AS comentario,
            c.codtra    AS codigotransportista1,
            c.codtec    AS codigotransportista2,
            c.porigv,
            c.numped    AS referencia,
            c.totbru    AS importebruto,
            c.preven    AS importe,
            c.totcan    AS cantidadtotal,
            c.fordcom   AS fordcom,
            c.ordcom    AS ordcom,
            cp.despag   AS condicionpago,
            v.desven    AS vendedor,
            c.codcpag,
            c.usuari    AS coduser,
            us.nombres  AS usuario,
            CASE
                WHEN c.incigv = 'S' THEN
                    'true'
                ELSE
                    'false'
            END         AS incigv,
            su.sucursal,
            m1.desmot   AS motivo
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab             c
            LEFT OUTER JOIN c_pago                     cp ON cp.id_cia = c.id_cia
                                         AND cp.codpag = c.codcpag
            LEFT OUTER JOIN vendedor                   v ON v.id_cia = c.id_cia
                                          AND v.codven = c.codven
            LEFT OUTER JOIN cliente                    cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codcli
            LEFT OUTER JOIN usuarios                   us ON us.id_cia = c.id_cia
                                           AND us.coduser = c.usuari
            LEFT OUTER JOIN documentos_aprobacion      da ON da.id_cia = c.id_cia
                                                        AND da.numint = c.numint
            LEFT OUTER JOIN situacion                  s ON s.id_cia = c.id_cia
                                           AND s.tipdoc = c.tipdoc
                                           AND s.situac = c.situac
            LEFT OUTER JOIN motivos                    m1 ON m1.id_cia = c.id_cia
                                          AND m1.tipdoc = c.tipdoc
                                          AND m1.id = c.id
                                          AND m1.codmot = c.codmot
            LEFT OUTER JOIN sucursal                   su ON su.id_cia = c.id_cia
                                           AND su.codsuc = c.codsuc
            LEFT OUTER JOIN documentos                 doc ON doc.id_cia = c.id_cia
                                              AND doc.codigo = c.tipdoc
                                              AND doc.series = c.series
            LEFT OUTER JOIN documentos_cab_envio_sunat ss ON ss.id_cia = c.id_cia
                                                             AND ss.numint = c.numint
            LEFT OUTER JOIN factor                     ff ON ff.id_cia = c.id_cia
                                         AND ff.codfac = 440
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 102
            AND ( pin_codcli IS NULL
                  OR c.codcli = pin_codcli )
            AND ( c.situac IN ( 'F', 'G' )
                  OR ( pin_codmot <= 0
                       AND c.situac = 'C' ) )
            AND ( pin_codsuc = - 1
                  OR c.codsuc = pin_codsuc )
            AND c.femisi <= pin_fhasta
            AND c.tipmon = pin_tipmon
            AND ( nvl(ff.vstrg, 'N') = 'N' -- SI EL FACTOR ESTA EN N, SIEMPRE SALDRA LA GUIA ESTE ACEPTADO O NO
                  OR ( nvl(doc.docelec, 'N') = 'N'
                       OR ( doc.docelec = 'S' -- SI LA SERIE ES ELECTRONICA, SOLO SE MUESTRAN LAS GUIAS DE REMISION ACEPTADAS POR SUNAT
                            AND ss.estado = 1 ) ) )
            AND ( pin_codmot <= 0
                  OR c.codmot = pin_codmot )
            AND ( nvl(pin_periodo, - 1) = - 1
                  OR EXTRACT(YEAR FROM c.femisi) = pin_periodo )
            AND ( nvl(pin_mes, - 1) = - 1
                  OR EXTRACT(MONTH FROM c.femisi) = pin_mes )
        ORDER BY
            c.numdoc DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_guias_remision_padre;

    FUNCTION sp_ordenes_pedido_padre (
        pin_id_cia NUMBER,
        pin_fhasta DATE,
        pin_codsuc NUMBER,
        pin_codcli VARCHAR2,
        pin_tipmon VARCHAR2,
        pin_codmot NUMBER,
        pin_docdes INTEGER
    ) RETURN datatable_ordenes_pedido_padre
        PIPELINED
    AS
        v_table  datatable_ordenes_pedido_padre;
        v_docdes VARCHAR(10 CHAR);
    BEGIN
        IF nvl(pin_docdes, -1) = -1 THEN
            SELECT
                c.numint,
                c.codsuc,
                s.sucursal,
                c.tipdoc,
                c.series,
                c.numdoc,
                c.femisi,
                c.numped,
                c.presen,
                c.tipmon,
                c.preven,
                c.codcli,
                c.razonc,
                c.situac,
                st.dessit AS situacdesc,
                'ND'      AS docrelpen,
            /*(
                SELECT
                    sp_trazabilidad_doc_ae(c.id_cia, c.numint)
                FROM
                    dual
            )         AS docrelpen,*/
                cv.despag AS despagven,
                c.codmot,
                m.desmot
            BULK COLLECT
            INTO v_table
            FROM
                documentos_cab        c
                LEFT OUTER JOIN sucursal              s ON s.id_cia = c.id_cia
                                              AND s.codsuc = c.codsuc
                LEFT OUTER JOIN motivos               m ON m.id_cia = c.id_cia
                                             AND m.tipdoc = c.tipdoc
                                             AND m.id = c.id
                                             AND m.codmot = c.codmot
                LEFT OUTER JOIN c_pago                cv ON cv.id_cia = c.id_cia
                                             AND ( cv.codpag = c.codcpag )
                                             AND upper(cv.swacti) = 'S'
                LEFT OUTER JOIN situacion             st ON st.id_cia = c.id_cia
                                                AND st.tipdoc = c.tipdoc
                                                AND st.situac = c.situac
                LEFT OUTER JOIN documentos_aprobacion a ON a.id_cia = c.id_cia
                                                           AND a.numint = c.numint
                LEFT OUTER JOIN motivos_clase         mt ON mt.id_cia = m.id_cia
                                                    AND mt.tipdoc = m.tipdoc
                                                    AND mt.id = m.id
                                                    AND mt.codmot = m.codmot
                                                    AND mt.codigo = 30
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = 101
                AND c.femisi <= pin_fhasta
                AND c.situac IN ( 'B', 'G', 'Q' )
                AND ( a.situac = 'B'
                      OR ( upper(mt.valor) <> 'S' ) )
                AND c.tipmon = pin_tipmon
                AND ( nvl(pin_codmot, - 1) = - 1
                      OR c.codmot = pin_codmot )
                AND ( nvl(pin_codsuc, - 1) = - 1
                      OR c.codsuc = pin_codsuc )
                AND ( pin_codcli IS NULL
                      OR c.codcli = pin_codcli )
            ORDER BY
                c.numdoc DESC;

        ELSE
            SELECT
                c.numint,
                c.codsuc,
                s.sucursal,
                c.tipdoc,
                c.series,
                c.numdoc,
                c.femisi,
                c.numped,
                c.presen,
                c.tipmon,
                c.preven,
                c.codcli,
                c.razonc,
                c.situac,
                st.dessit AS situacdesc,
                'ND'      AS docrelpen,
            /*(
                SELECT
                    sp_trazabilidad_doc_ae(c.id_cia, c.numint)
                FROM
                    dual
            )         AS docrelpen,*/
                cv.despag AS despagven,
                c.codmot,
                m.desmot
            BULK COLLECT
            INTO v_table
            FROM
                documentos_cab        c
                LEFT OUTER JOIN sucursal              s ON s.id_cia = c.id_cia
                                              AND s.codsuc = c.codsuc
                LEFT OUTER JOIN motivos               m ON m.id_cia = c.id_cia
                                             AND m.tipdoc = c.tipdoc
                                             AND m.id = c.id
                                             AND m.codmot = c.codmot
                LEFT OUTER JOIN c_pago                cv ON cv.id_cia = c.id_cia
                                             AND ( cv.codpag = c.codcpag )
                                             AND upper(cv.swacti) = 'S'
                LEFT OUTER JOIN situacion             st ON st.id_cia = c.id_cia
                                                AND st.tipdoc = c.tipdoc
                                                AND st.situac = c.situac
                LEFT OUTER JOIN documentos_aprobacion a ON a.id_cia = c.id_cia
                                                           AND a.numint = c.numint
                LEFT OUTER JOIN motivos_clase         mt ON mt.id_cia = m.id_cia
                                                    AND mt.tipdoc = m.tipdoc
                                                    AND mt.id = m.id
                                                    AND mt.codmot = m.codmot
                                                    AND mt.codigo = 30
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = 101
                AND c.femisi <= pin_fhasta
                AND c.situac IN ( 'B', 'G', 'Q' )
                AND ( a.situac = 'B'
                      OR ( upper(mt.valor) <> 'S' ) )
                AND c.tipmon = pin_tipmon
                AND ( nvl(pin_codmot, - 1) = - 1
                      OR c.codmot = pin_codmot
                      OR pin_docdes IN (
                    SELECT
                        regexp_substr(m.filtrodocu, '\d+', 1, level) AS numero
                    FROM
                        dual
                    CONNECT BY
                        regexp_substr(m.filtrodocu, '\d+', 1, level) IS NOT NULL
                ) )
                AND ( nvl(pin_codsuc, - 1) = - 1
                      OR c.codsuc = pin_codsuc )
                AND ( pin_codcli IS NULL
                      OR c.codcli = pin_codcli )
            ORDER BY
                c.numdoc DESC;

        END IF;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END;

    FUNCTION sp_ordenes_produccion_padre (
        pin_id_cia NUMBER,
        pin_fhasta DATE,
        pin_codsuc NUMBER,
        pin_codcli VARCHAR2,
        pin_tipmon VARCHAR2,
        pin_codmot NUMBER
    ) RETURN datatable_ordenes_pedido_padre
        PIPELINED
    AS
        v_table datatable_ordenes_pedido_padre;
    BEGIN
        SELECT
            c.numint,
            c.codsuc,
            s.sucursal,
            c.tipdoc,
            c.series,
            c.numdoc,
            c.femisi,
            c.numped,
            c.presen,
            c.tipmon,
            c.preven,
            c.codcli,
            c.razonc,
            c.situac,
            st.dessit AS situacdesc,
            'ND'      AS docrelpen,
            /*(
                SELECT
                    sp_trazabilidad_doc_ae(c.id_cia, c.numint)
                FROM
                    dual
            )         AS docrelpen,*/
            cv.despag AS despagven,
            c.codmot,
            m.desmot
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab c
            LEFT OUTER JOIN sucursal       s ON s.id_cia = c.id_cia
                                          AND s.codsuc = c.codsuc
            LEFT OUTER JOIN motivos        m ON m.id_cia = c.id_cia
                                         AND m.tipdoc = c.tipdoc
                                         AND m.id = c.id
                                         AND m.codmot = c.codmot
            LEFT OUTER JOIN c_pago         cv ON cv.id_cia = c.id_cia
                                         AND ( cv.codpag = c.codcpag )
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN situacion      st ON st.id_cia = c.id_cia
                                            AND st.tipdoc = c.tipdoc
                                            AND st.situac = c.situac
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 104
            AND c.femisi <= pin_fhasta
            AND c.situac IN ( 'B', 'G', 'Q' )
            AND ( pin_tipmon IS NULL
                  OR pin_tipmon = ''
                  OR c.tipmon = pin_tipmon )
            AND ( pin_codmot IS NULL
                  OR pin_codmot = - 1
                  OR c.codmot = pin_codmot )
            AND ( pin_codsuc IS NULL
                  OR pin_codsuc = - 1
                  OR c.codsuc = pin_codsuc )
            AND ( pin_codcli IS NULL
                  OR c.codcli = pin_codcli )
        ORDER BY
            c.numdoc DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END;

    FUNCTION sp_ordenes_devolucion_padre (
        pin_id_cia NUMBER,
        pin_fhasta DATE,
        pin_codsuc NUMBER,
        pin_codcli VARCHAR2,
        pin_tipmon VARCHAR2,
        pin_codmot NUMBER
    ) RETURN datatable_ordenes_pedido_padre
        PIPELINED
    AS
        v_table datatable_ordenes_pedido_padre;
    BEGIN
        SELECT
            c.numint,
            c.codsuc,
            s.sucursal,
            c.tipdoc,
            c.series,
            c.numdoc,
            c.femisi,
            c.numped,
            c.presen,
            c.tipmon,
            c.preven,
            c.codcli,
            c.razonc,
            c.situac,
            st.dessit AS situacdesc,
            'ND'      AS docrelpen,
            /*(
                SELECT
                    sp_trazabilidad_doc_ae(c.id_cia, c.numint)
                FROM
                    dual
            )         AS docrelpen,*/
            cv.despag AS despagven,
            c.codmot,
            m.desmot
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab        c
            LEFT OUTER JOIN sucursal              s ON s.id_cia = c.id_cia
                                          AND s.codsuc = c.codsuc
            LEFT OUTER JOIN motivos               m ON m.id_cia = c.id_cia
                                         AND m.tipdoc = c.tipdoc
                                         AND m.id = c.id
                                         AND m.codmot = c.codmot
            LEFT OUTER JOIN c_pago                cv ON cv.id_cia = c.id_cia
                                         AND ( cv.codpag = c.codcpag )
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN situacion             st ON st.id_cia = c.id_cia
                                            AND st.tipdoc = c.tipdoc
                                            AND st.situac = c.situac
            LEFT OUTER JOIN documentos_aprobacion a ON a.id_cia = c.id_cia
                                                       AND a.numint = c.numint
            LEFT OUTER JOIN motivos_clase         mt ON mt.id_cia = m.id_cia
                                                AND mt.tipdoc = m.tipdoc
                                                AND mt.id = m.id
                                                AND mt.codmot = m.codmot
                                                AND mt.codigo = 30
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 201 -- Ordenes de Pedido
            AND ( pin_codcli IS NULL
                  OR c.codcli = pin_codcli )
            AND c.femisi <= pin_fhasta
            AND c.situac IN ( 'B', 'G', 'Q' )
            AND ( ( (
                CASE
                    WHEN a.situac IS NULL THEN
                        ''
                    ELSE
                        a.situac
                END
            ) = 'B' )
                  OR ( ( upper(mt.valor) <> 'S' ) ) )
            AND c.tipmon = pin_tipmon
            AND ( pin_codmot IS NULL
                  OR pin_codmot = - 1
                  OR c.codmot = pin_codmot )
            AND ( pin_codsuc IS NULL
                  OR pin_codsuc = - 1
                  OR c.codsuc = pin_codsuc )
        ORDER BY
            c.numdoc DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ordenes_devolucion_padre;

    FUNCTION sp_facturas_padre (
        pin_id_cia  NUMBER,
        pin_fhasta  DATE,
        pin_codsuc  NUMBER,
        pin_codcli  VARCHAR2,
        pin_tipmon  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_facturas_padre
        PIPELINED
    AS
        v_table datatable_facturas_padre;
    BEGIN
        SELECT
            c.numint,
            c.codsuc,
            s.sucursal,
            c.tipdoc,
            c.series  AS serie,
            c.numdoc  AS numero,
            c.femisi,
            c.numped,
            c.presen,
            c.tipmon  AS moneda,
            c.preven  AS importe,
            c.codcli,
            c.razonc,
            c.situac,
            st.dessit AS situacdesc,
            'ND'      AS docrelpen,
            /*(
                SELECT
                    sp_trazabilidad_doc_ae(c.id_cia, c.numint)
                FROM
                    dual
            )         AS docrelpen,*/
            cv.despag AS despagven,
            c.codmot,
            c.monisc  AS monisc,
            m.desmot
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab             c
            LEFT OUTER JOIN sucursal                   s ON s.id_cia = c.id_cia
                                          AND s.codsuc = c.codsuc
            LEFT OUTER JOIN motivos                    m ON m.id_cia = c.id_cia
                                         AND m.tipdoc = c.tipdoc
                                         AND m.id = c.id
                                         AND m.codmot = c.codmot
            LEFT OUTER JOIN c_pago                     cv ON cv.id_cia = c.id_cia
                                         AND cv.codpag = c.codcpag
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN situacion                  st ON st.id_cia = c.id_cia
                                            AND st.tipdoc = c.tipdoc
                                            AND st.situac = c.situac
            LEFT OUTER JOIN documentos_aprobacion      a ON a.id_cia = c.id_cia
                                                       AND a.numint = c.numint
            LEFT OUTER JOIN documentos                 doc ON doc.id_cia = c.id_cia
                                              AND doc.codigo = c.tipdoc
                                              AND doc.series = c.series
            LEFT OUTER JOIN documentos_cab_envio_sunat ss ON ss.id_cia = c.id_cia
                                                             AND ss.numint = c.numint
            LEFT OUTER JOIN factor                     ff ON ff.id_cia = c.id_cia
                                         AND ff.codfac = 439
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 1
            AND ( pin_codcli IS NULL
                  OR c.codcli = pin_codcli )
            AND ( c.femisi <= pin_fhasta )
            AND c.tipmon = pin_tipmon
            AND ( pin_codsuc IS NULL
                  OR pin_codsuc = - 1
                  OR c.codsuc = pin_codsuc )
            AND c.situac IN ( 'F', 'C' )
            AND ( a.situac NOT IN ( 'H', 'J', 'K' )
                  OR a.situac IS NULL )
            AND ( nvl(ff.vstrg, 'N') = 'N' -- SI EL FACTOR ESTA EN N, SIEMPRE SALDRA LA FACTURA ESTE ACEPTADA O NO 
                  OR ( nvl(doc.docelec, 'N') = 'N'
                       OR ( doc.docelec = 'S' -- SI LA SERIE ES ELECTRONICA, SOLO SE MUESTRAN LAS FACTURAS ACEPTADAS POR SUNAT
                            AND ss.estado = 1 ) ) )
            AND ( nvl(pin_periodo, - 1) = - 1
                  OR EXTRACT(YEAR FROM c.femisi) = pin_periodo )
            AND ( nvl(pin_mes, - 1) = - 1
                  OR EXTRACT(MONTH FROM c.femisi) = pin_mes )
        ORDER BY
            c.numdoc DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_facturas_padre;

    FUNCTION sp_facturas_devolucion_padre (
        pin_id_cia  NUMBER,
        pin_fhasta  DATE,
        pin_codsuc  NUMBER,
        pin_codcli  VARCHAR2,
        pin_tipmon  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_facturas_padre
        PIPELINED
    AS
        v_table datatable_facturas_padre;
    BEGIN
        SELECT
            c.numint,
            c.codsuc,
            s.sucursal,
            c.tipdoc,
            c.series  AS serie,
            c.numdoc  AS numero,
            c.femisi,
            c.numped,
            c.presen,
            c.tipmon  AS moneda,
            c.preven  AS importe,
            c.codcli,
            c.razonc,
            c.situac,
            st.dessit AS situacdesc,
            'ND'      AS docrelpen,
            /*(
                SELECT
                    sp_trazabilidad_doc_ae(c.id_cia, c.numint)
                FROM
                    dual
            )         AS docrelpen,*/
            cv.despag AS despagven,
            c.codmot,
            c.monisc  AS monisc,
            m.desmot
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab        c
            LEFT OUTER JOIN sucursal              s ON s.id_cia = c.id_cia
                                          AND s.codsuc = c.codsuc
            LEFT OUTER JOIN motivos               m ON m.id_cia = c.id_cia
                                         AND m.tipdoc = c.tipdoc
                                         AND m.id = c.id
                                         AND m.codmot = c.codmot
            LEFT OUTER JOIN c_pago                cv ON cv.id_cia = c.id_cia
                                         AND cv.codpag = c.codcpag
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN situacion             st ON st.id_cia = c.id_cia
                                            AND st.tipdoc = c.tipdoc
                                            AND st.situac = c.situac
            LEFT OUTER JOIN documentos_aprobacion a ON a.id_cia = c.id_cia
                                                       AND a.numint = c.numint
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 1
            AND ( pin_codcli IS NULL
                  OR c.codcli = pin_codcli )
            AND ( c.femisi <= pin_fhasta )
            AND c.tipmon = pin_tipmon
            AND ( pin_codsuc IS NULL
                  OR pin_codsuc = - 1
                  OR c.codsuc = pin_codsuc )
            AND c.situac IN ( 'F', 'C' )
            AND nvl(a.situac_dev, 'G') = 'G'
            AND ( nvl(pin_periodo, - 1) = - 1
                  OR EXTRACT(YEAR FROM c.femisi) = pin_periodo )
            AND ( nvl(pin_mes, - 1) = - 1
                  OR EXTRACT(MONTH FROM c.femisi) = pin_mes )
        ORDER BY
            c.numdoc DESC
        FETCH NEXT 1000 ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END;

    FUNCTION sp_boleta_padre (
        pin_id_cia  NUMBER,
        pin_fhasta  DATE,
        pin_codsuc  NUMBER,
        pin_codcli  VARCHAR2,
        pin_tipmon  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_boleta_padre
        PIPELINED
    AS
        v_table datatable_boleta_padre;
    BEGIN
        SELECT
            c.numint,
            c.codsuc,
            s.sucursal,
            c.tipdoc,
            c.series  AS serie,
            c.numdoc  AS numero,
            c.femisi,
            c.numped,
            c.presen,
            c.tipmon  AS moneda,
            c.preven  AS importe,
            c.codcli,
            c.razonc,
            c.situac,
            st.dessit AS situacdesc,
            'ND'      AS docrelpen,
            /*(
                SELECT
                    sp_trazabilidad_doc_ae(c.id_cia, c.numint)
                FROM
                    dual
            )         AS docrelpen,*/
            cv.despag AS despagven,
            c.codmot,
            m.desmot
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab             c
            LEFT OUTER JOIN sucursal                   s ON s.id_cia = c.id_cia
                                          AND s.codsuc = c.codsuc
            LEFT OUTER JOIN motivos                    m ON m.id_cia = c.id_cia
                                         AND m.tipdoc = c.tipdoc
                                         AND m.id = c.id
                                         AND m.codmot = c.codmot
            LEFT OUTER JOIN c_pago                     cv ON cv.id_cia = c.id_cia
                                         AND cv.codpag = c.codcpag
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN situacion                  st ON st.id_cia = c.id_cia
                                            AND st.tipdoc = c.tipdoc
                                            AND st.situac = c.situac
            LEFT OUTER JOIN documentos_aprobacion      a ON a.id_cia = c.id_cia
                                                       AND a.numint = c.numint
            LEFT OUTER JOIN documentos                 doc ON doc.id_cia = c.id_cia
                                              AND doc.codigo = c.tipdoc
                                              AND doc.series = c.series
            LEFT OUTER JOIN documentos_cab_envio_sunat ss ON ss.id_cia = c.id_cia
                                                             AND ss.numint = c.numint
            LEFT OUTER JOIN factor                     ff ON ff.id_cia = c.id_cia
                                         AND ff.codfac = 439
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 3
            AND c.femisi <= pin_fhasta
            AND c.tipmon = pin_tipmon
            AND ( pin_codsuc IS NULL
                  OR pin_codsuc = - 1
                  OR c.codsuc = pin_codsuc )
            AND ( pin_codcli IS NULL
                  OR c.codcli = pin_codcli )
            AND ( c.situac IN ( 'F', 'C' ) )
            AND ( ( a.situac NOT IN ( 'H', 'J', 'K' ) )
                  OR ( a.situac IS NULL ) )
            AND ( nvl(ff.vstrg, 'N') = 'N' -- SI EL FACTOR ESTA EN N, SIEMPRE SALDRA LA BOLETAS ESTE ACEPTADA O NO 
                  OR ( nvl(doc.docelec, 'N') = 'N'
                       OR ( doc.docelec = 'S' -- SI LA SERIE ES ELECTRONICA, SOLO SE MUESTRAN LAS BOLETAS ACEPTADAS POR SUNAT
                            AND ss.estado = 1 ) ) )
            AND ( nvl(pin_periodo, - 1) = - 1
                  OR EXTRACT(YEAR FROM c.femisi) = pin_periodo )
            AND ( nvl(pin_mes, - 1) = - 1
                  OR EXTRACT(MONTH FROM c.femisi) = pin_mes )
        ORDER BY
            c.numdoc DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_boleta_padre;

    FUNCTION sp_boleta_devolucion_padre (
        pin_id_cia  NUMBER,
        pin_fhasta  DATE,
        pin_codsuc  NUMBER,
        pin_codcli  VARCHAR2,
        pin_tipmon  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_boleta_padre
        PIPELINED
    AS
        v_table datatable_boleta_padre;
    BEGIN
        SELECT
            c.numint,
            c.codsuc,
            s.sucursal,
            c.tipdoc,
            c.series  AS serie,
            c.numdoc  AS numero,
            c.femisi,
            c.numped,
            c.presen,
            c.tipmon  AS moneda,
            c.preven  AS importe,
            c.codcli,
            c.razonc,
            c.situac,
            st.dessit AS situacdesc,
            'ND'      AS docrelpen,
            /*(
                SELECT
                    sp_trazabilidad_doc_ae(c.id_cia, c.numint)
                FROM
                    dual
            )         AS docrelpen,*/
            cv.despag AS despagven,
            c.codmot,
            m.desmot
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab c
            LEFT OUTER JOIN sucursal       s ON s.id_cia = c.id_cia
                                          AND s.codsuc = c.codsuc
            LEFT OUTER JOIN motivos        m ON m.id_cia = c.id_cia
                                         AND m.tipdoc = c.tipdoc
                                         AND m.id = c.id
                                         AND m.codmot = c.codmot
            LEFT OUTER JOIN c_pago         cv ON cv.id_cia = c.id_cia
                                         AND cv.codpag = c.codcpag
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN situacion      st ON st.id_cia = c.id_cia
                                            AND st.tipdoc = c.tipdoc
                                            AND st.situac = c.situac
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 3
            AND c.femisi <= pin_fhasta
            AND c.tipmon = pin_tipmon
            AND ( pin_codsuc IS NULL
                  OR pin_codsuc = - 1
                  OR c.codsuc = pin_codsuc )
            AND ( pin_codcli IS NULL
                  OR c.codcli = pin_codcli )
            AND ( c.situac IN ( 'F', 'C' ) )
            AND ( nvl(pin_periodo, - 1) = - 1
                  OR EXTRACT(YEAR FROM c.femisi) = pin_periodo )
            AND ( nvl(pin_mes, - 1) = - 1
                  OR EXTRACT(MONTH FROM c.femisi) = pin_mes )
        ORDER BY
            c.numdoc DESC
        FETCH NEXT 1000 ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_boleta_devolucion_padre;

    FUNCTION sp_req_compras_padre (
        pin_id_cia NUMBER,
        pin_fhasta DATE,
        pin_codsuc NUMBER,
        pin_codcli VARCHAR2,
        pin_tipmon VARCHAR2
    ) RETURN datatable_req_compras_padre
        PIPELINED
    AS
        v_table datatable_req_compras_padre;
    BEGIN
        SELECT
            c.numint,
            c.codsuc,
            s.sucursal,
            c.tipdoc,
            c.series,
            c.numdoc,
            c.femisi,
            c.numped,
            c.presen,
            c.tipmon,
            c.preven,
            c.codcli,
            c.razonc,
            c.situac,
            st.dessit AS situacdesc,
            (
                SELECT
                    sp_trazabilidad_doc_ae(c.id_cia, c.numint)
                FROM
                    dual
            )         AS docrelpen,
            cv.despag AS despagven,
            c.codmot,
            m.desmot
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab c
            LEFT OUTER JOIN sucursal       s ON s.id_cia = c.id_cia
                                          AND s.codsuc = c.codsuc
            LEFT OUTER JOIN motivos        m ON m.id_cia = c.id_cia
                                         AND m.tipdoc = c.tipdoc
                                         AND m.id = c.id
                                         AND m.codmot = c.codmot
            LEFT OUTER JOIN c_pago         cv ON cv.id_cia = c.id_cia
                                         AND cv.codpag = c.codcpag
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN situacion      st ON st.id_cia = c.id_cia
                                            AND st.tipdoc = c.tipdoc
                                            AND st.situac = c.situac
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 125
            AND c.femisi <= pin_fhasta
            AND c.situac IN ( 'B', 'G' )
            AND c.tipmon = pin_tipmon
            AND ( pin_codsuc IS NULL
                  OR pin_codsuc <= 0
                  OR c.codsuc = pin_codsuc )
            AND ( pin_codcli IS NULL
                  OR c.codcli = pin_codcli )
        ORDER BY
            c.numdoc DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_req_compras_padre;

    FUNCTION sp_orden_compras_padre (
        pin_id_cia NUMBER,
        pin_fhasta DATE,
        pin_codsuc NUMBER,
        pin_codcli VARCHAR2,
        pin_tipmon VARCHAR2,
        pin_destin NUMBER
    ) RETURN datatable_orden_compras_padre
        PIPELINED
    AS
        v_table datatable_orden_compras_padre;
    BEGIN
        SELECT
            c.numint,
            c.codsuc,
            s.sucursal,
            c.tipdoc,
            c.series,
            c.numdoc,
            c.femisi,
            c.numped,
            c.presen,
            c.tipmon,
            c.preven,
            c.codcli,
            c.razonc,
            c.situac,
            st.dessit AS situacdesc,
            (
                SELECT
                    sp_trazabilidad_doc_ae(c.id_cia, c.numint)
                FROM
                    dual
            )         AS docrelpen,
            cv.despag AS despagven,
            c.codmot,
            m.desmot
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab c
            LEFT OUTER JOIN sucursal       s ON s.id_cia = c.id_cia
                                          AND s.codsuc = c.codsuc
            LEFT OUTER JOIN motivos        m ON m.id_cia = c.id_cia
                                         AND m.tipdoc = c.tipdoc
                                         AND m.id = c.id
                                         AND m.codmot = c.codmot
            LEFT OUTER JOIN c_pago         cv ON cv.id_cia = c.id_cia
                                         AND cv.codpag = c.codcpag
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN situacion      st ON st.id_cia = c.id_cia
                                            AND st.tipdoc = c.tipdoc
                                            AND st.situac = c.situac
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 105
            AND c.femisi <= pin_fhasta
            AND c.situac IN ( 'B', 'G' )
            AND c.tipmon = pin_tipmon
            AND ( pin_codsuc IS NULL
                  OR pin_codsuc <= 0
                  OR c.codsuc = pin_codsuc )
            AND ( pin_codcli IS NULL
                  OR c.codcli = pin_codcli )
            AND ( pin_destin IS NULL
                  OR pin_destin <= 0
                  OR c.destin = pin_destin )
        ORDER BY
            c.numdoc DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_orden_compras_padre;

    FUNCTION sp_guias_interna_padre (
        pin_id_cia NUMBER,
        pin_fhasta DATE,
        pin_codcli VARCHAR2,
        pin_codmot NUMBER,
        pin_id     NUMBER
    ) RETURN datatable_guias_interna_padre
        PIPELINED
    AS
        v_table datatable_guias_interna_padre;
    BEGIN
        SELECT
            c.numint,
            c.series,
            c.numdoc,
            c.tident,
            c.ruc,
            c.codcli,
            c.razonc     AS razonsocial,
            c.direc1     AS direccion,
            c.fentreg    AS fentreg,
            c.femisi,
            c.lugemi,
            c.situac,
            s.dessit     AS situacnombre,
            c.id,
            c.codmot,
            c.codven,
            c.codsuc,
            c.tipmon     AS moneda,
            c.monisc     AS monisc,
            c.tipcam,
            coc.numint   AS coc_numint,
            coc.fecha    AS coc_fecha,
            coc.numero   AS coc_numero,
            coc.contacto AS coc_contacto,
            cp.despag    AS condicionpago,
            v.desven     AS vendedor,
            c.codcpag,
            c.usuari     AS coduser,
            us.nombres   AS usuario,
            CASE
                WHEN c.incigv = 'S' THEN
                    'true'
                ELSE
                    'false'
            END          AS incigv,
            c.porigv,
            c.numped     AS referencia,
            c.observ     AS observacion,
            c.monafe,
            c.monina,
            c.monigv,
            c.preven,
            c.totbru     AS importebruto,
            c.preven     AS importe,
            dcc.vchar    AS situacimp,
            CASE
                WHEN dcc.vchar = 'S' THEN
                    'Liquidado'
                ELSE
                    'En proceso'
            END          AS dessituacimp,
            c.flete,
            c.countadj,
            c.seguro
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab        c
            LEFT OUTER JOIN documentos_cab_ordcom coc ON coc.id_cia = c.id_cia
                                                         AND coc.numint = c.numint
            LEFT OUTER JOIN documentos_cab_clase  dcc ON dcc.id_cia = c.id_cia
                                                        AND dcc.numint = c.numint
                                                        AND dcc.clase = 1
            LEFT OUTER JOIN c_pago                cp ON cp.id_cia = c.id_cia
                                         AND cp.codpag = c.codcpag
            LEFT OUTER JOIN vendedor              v ON v.id_cia = c.id_cia
                                          AND v.codven = c.codven
            LEFT OUTER JOIN cliente               cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codcli
            LEFT OUTER JOIN usuarios              us ON us.id_cia = c.id_cia
                                           AND us.coduser = c.usuari
            LEFT OUTER JOIN situacion             s ON s.id_cia = c.id_cia
                                           AND s.tipdoc = c.tipdoc
                                           AND s.situac = c.situac
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 103
            AND c.situac IN ( 'F', 'G' )
            AND ( pin_codcli IS NULL
                  OR c.codcli = pin_codcli )
            AND ( pin_fhasta IS NULL
                  OR c.femisi <= pin_fhasta )
            AND ( pin_id IS NULL
                  OR c.id = pin_id )
            AND ( pin_codmot IS NULL
                  OR pin_codmot <= 0
                  OR c.codmot = pin_codmot )
        ORDER BY
            c.numdoc DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_guias_interna_padre;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o          json_object_t;
        rec_doccab documentos_cab%rowtype;
        v_accion   VARCHAR2(50) := '';
    BEGIN

    -- TAREA: Se necesita implantación para PROCEDURE PACK_DOCUMENTO_CAB.sp_save
        o := json_object_t.parse(pin_datos);
        rec_doccab.id_cia := pin_id_cia;
        rec_doccab.numint := o.get_number('numint');
        rec_doccab.tipdoc := o.get_number('tipdoc');
        rec_doccab.series := o.get_string('series');
        rec_doccab.numdoc := o.get_number('numdoc');
        rec_doccab.femisi := o.get_date('femisi');
        rec_doccab.lugemi := o.get_number('lugemi');
        rec_doccab.situac := o.get_string('situac');
        rec_doccab.id := o.get_string('id');
        rec_doccab.codmot := o.get_number('codmot');
        rec_doccab.motdoc := o.get_number('motdoc');
        rec_doccab.codalm := o.get_number('codalm');
        rec_doccab.almdes := o.get_number('almdes');
        rec_doccab.codcli := o.get_string('codcli');
        rec_doccab.tident := o.get_string('tident');
        rec_doccab.ruc := o.get_string('ruc');
        rec_doccab.razonc := o.get_string('razonc');
        rec_doccab.direc1 := o.get_string('direc1');
        rec_doccab.codenv := o.get_number('codenv');
        rec_doccab.codcpag := o.get_number('codcpag');
        rec_doccab.codtra := o.get_number('codtra');
        rec_doccab.codven := o.get_number('codven');
        rec_doccab.comisi := o.get_number('comisi');
        rec_doccab.incigv := o.get_string('incigv');
        rec_doccab.destin := o.get_number('destin');
        rec_doccab.totbru := o.get_number('totbru');
        rec_doccab.descue := o.get_number('descue');
        rec_doccab.desesp := o.get_number('desesp');
        rec_doccab.monafe := o.get_number('monafe');
        rec_doccab.monina := o.get_number('monina');
        rec_doccab.porigv := o.get_number('porigv');
        rec_doccab.monigv := o.get_number('monigv');
        rec_doccab.preven := o.get_number('preven');
        rec_doccab.costo := o.get_number('costo');
        rec_doccab.tipmon := o.get_string('tipmon');
        rec_doccab.tipcam := o.get_number('tipcam');
        rec_doccab.observ := o.get_string('observ');
        rec_doccab.atenci := o.get_string('atenci');
        rec_doccab.valide := o.get_string('valide');
        rec_doccab.plaent := o.get_string('plaent');
        rec_doccab.ordcom := o.get_string('ordcom');
        rec_doccab.numped := o.get_string('numped');
        rec_doccab.gasvin := o.get_number('gasvin');
        rec_doccab.seguro := o.get_number('seguro');
        rec_doccab.flete := o.get_number('flete');
        rec_doccab.desfle := o.get_string('desfle');
        rec_doccab.desexp := o.get_number('desexp');
        rec_doccab.gasadu := o.get_number('gasadu');
        rec_doccab.pesbru := o.get_number('pesbru');
        rec_doccab.pesnet := o.get_number('pesnet');
        rec_doccab.bultos := o.get_number('bultos');
        rec_doccab.presen := o.get_string('presen');
        rec_doccab.marcas := o.get_string('marcas');
        rec_doccab.numdue := o.get_string('numdue');
        rec_doccab.fnumdue := o.get_date('fnumdue');
        rec_doccab.fembarq := o.get_date('fembarq');
        rec_doccab.fentreg := o.get_date('fentreg');
        rec_doccab.valfob := o.get_number('valfob');
        rec_doccab.guipro := o.get_string('guipro');
        rec_doccab.fguipro := o.get_date('fguipro');
        rec_doccab.facpro := o.get_string('facpro');
        rec_doccab.ffacpro := o.get_date('ffacpro');
        rec_doccab.cargo := o.get_string('cargo');
        rec_doccab.codsuc := o.get_number('codsuc');
        rec_doccab.fcreac := o.get_date('fcreac');
        rec_doccab.factua := o.get_date('factua');
        rec_doccab.acuenta := o.get_number('acuenta');
        rec_doccab.ucreac := o.get_string('ucreac');
        rec_doccab.usuari := o.get_string('usuari');
        rec_doccab.swacti := o.get_string('swacti');
        rec_doccab.codarea := o.get_number('codarea');
        rec_doccab.coduso := o.get_number('coduso');
        rec_doccab.opnumdoc := o.get_number('opnumdoc');
        rec_doccab.opcargo := o.get_string('opcargo');
        rec_doccab.opnumite := o.get_number('opnumite');
        rec_doccab.opcodart := o.get_string('opcodart');
        rec_doccab.optipinv := o.get_number('optipinv');
        rec_doccab.totcan := o.get_number('totcan');
        rec_doccab.fordcom := o.get_date('fordcom');
        rec_doccab.ordcomni := o.get_number('ordcomni');
        rec_doccab.motvarios := o.get_number('motvarios');
        rec_doccab.horing := o.get_date('horing');
        rec_doccab.fecter := o.get_date('fecter');
        rec_doccab.horter := o.get_date('horter');
        rec_doccab.codtec := o.get_number('codtec');
        rec_doccab.guiarefe := o.get_string('guiarefe');
        rec_doccab.desenv := o.get_string('desenv');
        rec_doccab.codaux := o.get_string('codaux');
        rec_doccab.codetapauso := o.get_number('codetapauso');
        rec_doccab.codsec := o.get_number('codsec');
        rec_doccab.numvale := o.get_number('numvale');
        rec_doccab.fecvale := o.get_date('fecvale');
        rec_doccab.swtrans := o.get_number('swtrans');
        rec_doccab.desseg := o.get_string('desseg');
        rec_doccab.desgasa := o.get_string('desgasa');
        rec_doccab.desnetx := o.get_string('desnetx');
        rec_doccab.despreven := o.get_string('despreven');
        rec_doccab.codcob := o.get_number('codcob');
        rec_doccab.codveh := o.get_number('codveh');
        rec_doccab.codpunpar := o.get_number('codpunpar');
        rec_doccab.ubigeopar := o.get_string('ubigeopar');
        rec_doccab.direccpar := o.get_string('direccpar');
        rec_doccab.monisc := o.get_number('monisc');
        rec_doccab.monexo := o.get_number('monexo');
        rec_doccab.monotr := o.get_number('monotr');
        rec_doccab.countadj := o.get_number('countadj');
        rec_doccab.numintper := o.get_number('numintper');
        rec_doccab.moncredito := o.get_number('moncredito');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO documentos_cab (
                    id_cia,
                    numint,
                    tipdoc,
                    series,
                    numdoc,
                    femisi,
                    lugemi,
                    situac,
                    id,
                    codmot,
                    motdoc,
                    codalm,
                    almdes,
                    codcli,
                    tident,
                    ruc,
                    razonc,
                    direc1,
                    codenv,
                    codcpag,
                    codtra,
                    codven,
                    comisi,
                    incigv,
                    destin,
                    totbru,
                    descue,
                    desesp,
                    monafe,
                    monina,
                    porigv,
                    monigv,
                    preven,
                    costo,
                    tipmon,
                    tipcam,
                    observ,
                    atenci,
                    valide,
                    plaent,
                    ordcom,
                    numped,
                    gasvin,
                    seguro,
                    flete,
                    desfle,
                    desexp,
                    gasadu,
                    pesbru,
                    pesnet,
                    bultos,
                    presen,
                    marcas,
                    numdue,
                    fnumdue,
                    fembarq,
                    fentreg,
                    valfob,
                    guipro,
                    fguipro,
                    facpro,
                    ffacpro,
                    cargo,
                    codsuc,
                    fcreac,
                    factua,
                    acuenta,
                    ucreac,
                    usuari,
                    swacti,
                    codarea,
                    coduso,
                    opnumdoc,
                    opcargo,
                    opnumite,
                    opcodart,
                    optipinv,
                    totcan,
                    fordcom,
                    ordcomni,
                    motvarios,
                    horing,
                    fecter,
                    horter,
                    codtec,
                    guiarefe,
                    desenv,
                    codaux,
                    codetapauso,
                    codsec,
                    numvale,
                    fecvale,
                    swtrans,
                    desseg,
                    desgasa,
                    desnetx,
                    despreven,
                    codcob,
                    codveh,
                    codpunpar,
                    ubigeopar,
                    direccpar,
                    monisc,
                    monexo,
                    monotr,
                    countadj,
                    numintper,
                    moncredito
                ) VALUES (
                    rec_doccab.id_cia,
                    rec_doccab.numint,
                    rec_doccab.tipdoc,
                    rec_doccab.series,
                    rec_doccab.numdoc,
                    rec_doccab.femisi,
                    rec_doccab.lugemi,
                    rec_doccab.situac,
                    rec_doccab.id,
                    rec_doccab.codmot,
                    rec_doccab.motdoc,
                    rec_doccab.codalm,
                    rec_doccab.almdes,
                    rec_doccab.codcli,
                    rec_doccab.tident,
                    rec_doccab.ruc,
                    rec_doccab.razonc,
                    rec_doccab.direc1,
                    rec_doccab.codenv,
                    rec_doccab.codcpag,
                    rec_doccab.codtra,
                    rec_doccab.codven,
                    rec_doccab.comisi,
                    rec_doccab.incigv,
                    rec_doccab.destin,
                    rec_doccab.totbru,
                    rec_doccab.descue,
                    rec_doccab.desesp,
                    rec_doccab.monafe,
                    rec_doccab.monina,
                    rec_doccab.porigv,
                    rec_doccab.monigv,
                    rec_doccab.preven,
                    rec_doccab.costo,
                    rec_doccab.tipmon,
                    rec_doccab.tipcam,
                    rec_doccab.observ,
                    rec_doccab.atenci,
                    rec_doccab.valide,
                    rec_doccab.plaent,
                    rec_doccab.ordcom,
                    rec_doccab.numped,
                    rec_doccab.gasvin,
                    rec_doccab.seguro,
                    rec_doccab.flete,
                    rec_doccab.desfle,
                    rec_doccab.desexp,
                    rec_doccab.gasadu,
                    rec_doccab.pesbru,
                    rec_doccab.pesnet,
                    rec_doccab.bultos,
                    rec_doccab.presen,
                    rec_doccab.marcas,
                    rec_doccab.numdue,
                    rec_doccab.fnumdue,
                    rec_doccab.fembarq,
                    rec_doccab.fentreg,
                    rec_doccab.valfob,
                    rec_doccab.guipro,
                    rec_doccab.fguipro,
                    rec_doccab.facpro,
                    rec_doccab.ffacpro,
                    rec_doccab.cargo,
                    rec_doccab.codsuc,
                    current_timestamp,
                    current_timestamp,
                    rec_doccab.acuenta,
                    rec_doccab.ucreac,
                    rec_doccab.usuari,
                    rec_doccab.swacti,
                    rec_doccab.codarea,
                    rec_doccab.coduso,
                    rec_doccab.opnumdoc,
                    rec_doccab.opcargo,
                    rec_doccab.opnumite,
                    rec_doccab.opcodart,
                    rec_doccab.optipinv,
                    rec_doccab.totcan,
                    rec_doccab.fordcom,
                    rec_doccab.ordcomni,
                    rec_doccab.motvarios,
                    rec_doccab.horing,
                    rec_doccab.fecter,
                    rec_doccab.horter,
                    rec_doccab.codtec,
                    rec_doccab.guiarefe,
                    rec_doccab.desenv,
                    rec_doccab.codaux,
                    rec_doccab.codetapauso,
                    rec_doccab.codsec,
                    rec_doccab.numvale,
                    rec_doccab.fecvale,
                    rec_doccab.swtrans,
                    rec_doccab.desseg,
                    rec_doccab.desgasa,
                    rec_doccab.desnetx,
                    rec_doccab.despreven,
                    rec_doccab.codcob,
                    rec_doccab.codveh,
                    rec_doccab.codpunpar,
                    rec_doccab.ubigeopar,
                    rec_doccab.direccpar,
                    rec_doccab.monisc,
                    rec_doccab.monexo,
                    rec_doccab.monotr,
                    rec_doccab.countadj,
                    rec_doccab.numintper,
                    rec_doccab.moncredito
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE documentos_cab
                SET
                    tipdoc = rec_doccab.tipdoc,
                    series = rec_doccab.series,
                    numdoc = rec_doccab.numdoc,
                    femisi = rec_doccab.femisi,
                    lugemi = rec_doccab.lugemi,
                    situac = rec_doccab.situac,
                    id = rec_doccab.id,
                    codmot = rec_doccab.codmot,
                    motdoc = rec_doccab.motdoc,
                    codalm = rec_doccab.codalm,
                    almdes = rec_doccab.almdes,
                    codcli = rec_doccab.codcli,
                    tident = rec_doccab.tident,
                    ruc = rec_doccab.ruc,
                    razonc = rec_doccab.razonc,
                    direc1 = rec_doccab.direc1,
                    codenv = rec_doccab.codenv,
                    codcpag = rec_doccab.codcpag,
                    codtra = rec_doccab.codtra,
                    codven = rec_doccab.codven,
                    comisi = rec_doccab.comisi,
                    incigv = rec_doccab.incigv,
                    destin = rec_doccab.destin,
                    totbru = rec_doccab.totbru,
                    descue = rec_doccab.descue,
                    desesp = rec_doccab.desesp,
                    monafe = rec_doccab.monafe,
                    monina = rec_doccab.monina,
                    porigv = rec_doccab.porigv,
                    monigv = rec_doccab.monigv,
                    preven = rec_doccab.preven,
                    costo = rec_doccab.costo,
                    tipmon = rec_doccab.tipmon,
                    tipcam = rec_doccab.tipcam,
                    observ = rec_doccab.observ,
                    atenci = rec_doccab.atenci,
                    valide = rec_doccab.valide,
                    plaent = rec_doccab.plaent,
                    ordcom = rec_doccab.ordcom,
                    numped = rec_doccab.numped,
                    gasvin = rec_doccab.gasvin,
                    seguro = rec_doccab.seguro,
                    flete = rec_doccab.flete,
                    desfle = rec_doccab.desfle,
                    desexp = rec_doccab.desexp,
                    gasadu = rec_doccab.gasadu,
                    pesbru = rec_doccab.pesbru,
                    pesnet = rec_doccab.pesnet,
                    bultos = rec_doccab.bultos,
                    presen = rec_doccab.presen,
                    marcas = rec_doccab.marcas,
                    numdue = rec_doccab.numdue,
                    fnumdue = rec_doccab.fnumdue,
                    fembarq = rec_doccab.fembarq,
                    fentreg = rec_doccab.fentreg,
                    valfob = rec_doccab.valfob,
                    guipro = rec_doccab.guipro,
                    fguipro = rec_doccab.fguipro,
                    facpro = rec_doccab.facpro,
                    ffacpro = rec_doccab.ffacpro,
                    cargo = rec_doccab.cargo,
                    codsuc = rec_doccab.codsuc,
                    fcreac = rec_doccab.fcreac,
                    factua = rec_doccab.factua,
                    acuenta = rec_doccab.acuenta,
                    ucreac = rec_doccab.ucreac,
                    usuari = rec_doccab.usuari,
                    swacti = rec_doccab.swacti,
                    codarea = rec_doccab.codarea,
                    coduso = rec_doccab.coduso,
                    opnumdoc = rec_doccab.opnumdoc,
                    opcargo = rec_doccab.opcargo,
                    opnumite = rec_doccab.opnumite,
                    opcodart = rec_doccab.opcodart,
                    optipinv = rec_doccab.optipinv,
                    totcan = rec_doccab.totcan,
                    fordcom = rec_doccab.fordcom,
                    ordcomni = rec_doccab.ordcomni,
                    motvarios = rec_doccab.motvarios,
                    horing = rec_doccab.horing,
                    fecter = rec_doccab.fecter,
                    horter = rec_doccab.horter,
                    codtec = rec_doccab.codtec,
                    guiarefe = rec_doccab.guiarefe,
                    desenv = rec_doccab.desenv,
                    codaux = rec_doccab.codaux,
                    codetapauso = rec_doccab.codetapauso,
                    codsec = rec_doccab.codsec,
                    numvale = rec_doccab.numvale,
                    fecvale = rec_doccab.fecvale,
                    swtrans = rec_doccab.swtrans,
                    desseg = rec_doccab.desseg,
                    desgasa = rec_doccab.desgasa,
                    desnetx = rec_doccab.desnetx,
                    despreven = rec_doccab.despreven,
                    codcob = rec_doccab.codcob,
                    codveh = rec_doccab.codveh,
                    codpunpar = rec_doccab.codpunpar,
                    ubigeopar = rec_doccab.ubigeopar,
                    direccpar = rec_doccab.direccpar,
                    monisc = rec_doccab.monisc,
                    monexo = rec_doccab.monexo,
                    monotr = rec_doccab.monotr,
                    countadj = rec_doccab.countadj,
                    numintper = rec_doccab.numintper,
                    moncredito = rec_doccab.moncredito
                WHERE
                        id_cia = rec_doccab.id_cia
                    AND numint = rec_doccab.numint;

            WHEN 3 THEN
                dbms_output.put_line('Good');
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    END sp_save;

    FUNCTION sp_conforme_para_anular (
        pin_id_cia  IN NUMBER,
        pin_tipdoc  IN NUMBER,
        pin_coduser VARCHAR2
    ) RETURN VARCHAR2 AS

        v_propiedad     NUMBER := 0;
        v_sn            VARCHAR2(1) := 'N';
        v_response_code NUMBER := 0;
    BEGIN
        CASE pin_tipdoc
            WHEN 1 THEN
                v_propiedad := 130; -- PROPIEDAD ANULAR FACTURA 
            WHEN 3 THEN
                v_propiedad := 131;   -- PROPIEDAD ANULAR COMPROBANTE
            WHEN 7 THEN
                v_propiedad := 132;   -- PROPIEDAD ANULAR NOTA CREDITO
            WHEN 8 THEN
                v_propiedad := 133;   -- PROPIEDAD ANULAR NOTA DEBITO
            WHEN 100 THEN
                v_propiedad := 134;   -- PROPIEDAD ANULAR COTIZACION
            WHEN 101 THEN
                v_propiedad := 135;   -- PROPIEDAD ANULAR ORDEN PEDIDO
            WHEN 102 THEN
                v_propiedad := 136;   -- PROPIEDAD ANULAR GUIA DE REMISION
            WHEN 125 THEN
                v_propiedad := 137;   -- PROPIEDAD ANULAR REQ. DE COMPRA
            WHEN 105 THEN
                v_propiedad := 138;   -- PROPIEDAD ANULAR ORDEN COMPRA
            WHEN 115 THEN
                v_propiedad := 139;   -- PROPIEDAD ANULAR DOC. DE IMPORTACIÓN
            WHEN 103 THEN
                v_propiedad := 140;   -- PROPIEDAD ANULAR GUIA INTERNA
            WHEN 111 THEN
                v_propiedad := 141;   -- PROPIEDAD ANULAR TOMA DE INVENTARIO
            WHEN 108 THEN
                v_propiedad := 142;   -- PROPIEDAD ANULAR GUIA DE RECEPCIÓN

            ELSE
                NULL;
        END CASE;

        IF v_propiedad > 0 THEN
            DECLARE BEGIN
                SELECT
                    swflag
                INTO v_sn
                FROM
                    usuarios_propiedades
                WHERE
                        id_cia = pin_id_cia
                    AND coduser = pin_coduser
                    AND codigo = v_propiedad;

            EXCEPTION
                WHEN no_data_found THEN
                    v_sn := 'N';
            END;

        END IF;

        RETURN v_sn;
    END sp_conforme_para_anular;

    FUNCTION sp_obtener_comprobante (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN datatable_obtener_comprobante
        PIPELINED
    AS
        v_table datatable_obtener_comprobante;
    BEGIN
        SELECT
            c.tipdoc            AS tipdoc,
            dc.descri           AS nomdoc,
            c.numint            AS numint,
            d.numite            AS numite,
            c.series            AS series,
            c.numdoc            AS numdoc,
            c.femisi            AS femisi,
            c.codcli            AS codcli,
            c.razonc            AS razonc,
            c.direc1            AS direc1,
            c.codsuc,
            c.ruc               AS ruc,
            c1.direc1           AS dircli1,
            c1.direc2           AS dircli2,
            c1.telefono         AS tlfcli,
            c1.fax              AS faxcli,
            c1.dident           AS dident,
            c.tident            AS tident_cab,
            i.descri            AS destident,
            i.abrevi            AS abrtident,
            ct.nrodni           AS nrodni,
            c.guiarefe          AS guiarefe,
            c.almdes            AS codalmdes,
            ald.descri          AS desalmdes,
            ald.abrevi          AS abralmdes,
            c.marcas            AS marcas,
            c.presen            AS presen,
            c.codsec            AS codsec,
            c.facpro            AS facpro,
            c.ffacpro           AS ffacpro,
            c.codven            AS codven,
            c.observ            AS obscab,
            c.tipcam            AS tipcam,
            c.tipmon            AS tipmon,
            c.totbru            AS totbru,
            c.desesp            AS desesp,
            c.descue            AS descue,
            c.monafe            AS monafe,
            CASE
                WHEN ( c.destin = 2
                       AND c.monina > 0 )
                     OR ( c1.codtpe <> 3
                          AND c22.codigo = 'S' ) THEN
                    CAST(0 AS NUMERIC(12, 2))
                ELSE
                    c.monina
            END                 AS monina,
            c.monafe + c.monina AS monneto,
            c.monigv            AS monigv,
            (
                CASE
                    WHEN ( mt16.valor IS NULL )
                         OR ( upper(mt16.valor) <> 'S' ) THEN
                        c.preven
                    ELSE
                        CAST(0 AS NUMERIC(12, 2))
                END
            )                   AS preven,
            (
                CASE
                    WHEN ( dct4.vreal IS NULL ) THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct4.vreal
                END
            )                   AS percep,
            (
                CASE
                    WHEN ( mt16.valor IS NULL )
                         OR ( upper(mt16.valor) <> 'S' ) THEN
                        c.preven
                    ELSE
                        CAST(0 AS NUMERIC(12, 2))
                END
            ) + (
                CASE
                    WHEN ( dct4.vreal IS NULL ) THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct4.vreal
                END
            )                   AS totpag,
            mt19.valor          AS relcossalprod,
            c.flete             AS flete,
            c.seguro            AS seguro,
            c.porigv            AS porigv,
            c.comisi            AS comiven,
            c.codmot            AS codmot,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                 AS numped,
            cv.despag           AS despagven,
            cvc.valor           AS enctacte,
            c.ordcom            AS ordcom,
            c.fordcom           AS fordcom,
            m1.simbolo          AS simbolo,
            m1.desmon           AS desmon,
            c.opnumdoc          AS opnumdoc,
            c.horing            AS horing,
            c.fecter            AS fecter,
            c.horter            AS horter,
            c.desnetx           AS desnetx,
            c.despreven         AS despreven,
            c.desfle            AS desfle,
            c.desseg            AS desseg,
            c.desgasa           AS desgasa,
            c.gasadu            AS gasadu,
            c.situac            AS situac,
            c.destin            AS destin,
            c.id                AS id,
            mt.desmot           AS desmot,
            mt.docayuda         AS docayuda,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                    'S'
                ELSE
                    'N'
            END                 AS swdocpercep,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                        ccc.codigo
                ELSE
                    CAST('0.00' AS VARCHAR(10))
            END
            || ' %'             AS porpercep,
            (
                SELECT
                    sp_exonerado_a_igv(c.id_cia, 'A', c.codcli, c.numint)
                FROM
                    dual
            )                   AS exoimp,
            cv.diaven           AS diaven,
            s1.sucursal         AS dessuc,
            s1.nomdis           AS dissuc,
            v1.desven           AS desven,
            t1.descri           AS destra,
            t1.domici           AS dirtra,
            t1.ruc              AS ructra,
            t1.punpar           AS punpartra,
            NULL                AS desenv01,
            NULL                AS desenv02,
            d.codalm            AS codalm,
            al.descri           AS desalm,
            d.tipinv            AS tipinv,
            d.codart            AS codart,
            CASE
                WHEN c33.codigo <> 'S' THEN
                    a.descri
                ELSE
                    CASE
                        WHEN lpa33.desart <> '' THEN
                                lpa33.desart
                        ELSE
                            CASE
                                WHEN lp33.desart <> '' THEN
                                            lp33.desart
                                ELSE
                                    a.descri
                            END
                    END
            END                 AS desart,
            a.faccon            AS faccon,
            a.consto            AS consto,
            d.largo * a.faccon  AS peslar,
            ( d.cantid * a.faccon ) + CAST(
                CASE
                    WHEN cc2.abrevi IS NULL THEN
                        CAST('0' AS VARCHAR(10))
                    ELSE
                        cc2.abrevi
                END
            AS NUMERIC(16,
     5))                 AS pesdet,
            cc2.abrevi          AS taraadic,
            a.codart
            || ' '
            || a.descri         AS coddesart,
            agl.observ          AS desglosa,
				--D.NUMITE,
            d.cantid            AS cantid,
            d.canref            AS canref,
            d.piezas            AS piezas,
            d.tara              AS tara,
            d.largo             AS largo,
            d.etiqueta          AS etiqueta,
            d.etiqueta          AS etiqueta2,
            a.coduni            AS codund,
            d.codadd01          AS codcalid,
            d.codadd02          AS codcolor,
            d.opronumdoc        AS opronumdoc,
            d.opnumdoc          AS dopnumdoc,
            d.opcargo           AS dopcargo,
            d.opnumite          AS dopnumite,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.preuni * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.preuni
            END                 AS preuni,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.importe_bruto * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe_bruto
            END                 AS importe_bruto,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.importe * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe
            END                 AS importe,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    ( d.importe_bruto - d.importe ) * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe_bruto - d.importe
            END                 AS descdet,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    ( d.importe /
                      CASE
                          WHEN d.cantid IS NULL
                               OR d.cantid = 0 THEN
                                1
                          ELSE
                              d.cantid
                      END
                    ) * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    ( d.importe /
                      CASE
                          WHEN d.cantid IS NULL
                               OR d.cantid = 0 THEN
                                1
                          ELSE
                              d.cantid
                      END
                    )
            END                 AS preuni02,
            d.preuni            AS preunireal,
            d.importe           AS importereal,
            d.codund            AS codunidet,
            d.pordes1           AS pordes1,
            d.pordes2           AS pordes2,
            d.pordes3           AS pordes3,
            d.pordes4           AS pordes4,
            d.monafe + d.monina AS monlinneto,
            d.monafe            AS monafedet,
            d.monigv            AS monigvdet,
            d.monisc            AS moniscdet,
            d.monotr            AS monotrdet,
				--D.LARGO * A.FacCon as PesLar,
            d.nrocarrete        AS nrocarrete,
            d.acabado,
            d.lote              AS lote,
            d.fvenci            AS fvenci,
            d.ancho             AS ancho,
            CASE
                WHEN ( ( fap.vstrg IS NOT NULL )
                       AND ( upper(fap.vstrg) = 'S' )
                       AND ( ddp.vreal IS NOT NULL )
                       AND ( ddp.vreal > 0 ) ) THEN
                    '*'
                ELSE
                    ''
            END                 AS astpercep,
            CASE
                WHEN d.cantid IS NULL
                     OR d.cantid = 0 THEN
                    0
                ELSE
                    ( d.monafe + d.monina ) / d.cantid
            END                 AS monuni,
            d.observ            AS obsdet
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab               c
            LEFT OUTER JOIN documentos                   dc ON dc.id_cia = c.id_cia
                                             AND ( dc.codigo = c.tipdoc )
                                             AND ( dc.series = c.series )
            LEFT OUTER JOIN cliente                      c1 ON c1.id_cia = c.id_cia
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN cliente_tpersona             ct ON ct.id_cia = c.id_cia
                                                   AND ( ct.codcli = c.codcli )
            LEFT OUTER JOIN identidad                    i ON i.id_cia = c1.id_cia
                                           AND ( i.tident = c1.tident )
            LEFT OUTER JOIN almacen                      ald ON ald.id_cia = c.id_cia
                                           AND ( ald.tipinv = 1 )
                                           AND ( ald.codalm = c.almdes )
            LEFT OUTER JOIN documentos_cab_clase         cc ON cc.id_cia = c.id_cia
                                                       AND ( cc.numint = c.numint )
                                                       AND ( cc.clase = 6 )
            LEFT OUTER JOIN c_pago                       cv ON cv.id_cia = c.id_cia
                                         AND ( cv.codpag = c.codcpag )
                                         AND ( upper(cv.swacti) = 'S' )
            LEFT OUTER JOIN c_pago_clase                 cvc ON cvc.id_cia = c.id_cia
                                                AND ( cvc.codpag = c.codcpag )
                                                AND ( cvc.codigo = 1 )
            LEFT OUTER JOIN tmoneda                      m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN sucursal                     s1 ON s1.id_cia = c.id_cia
                                           AND ( s1.codsuc = c.codsuc )
            LEFT OUTER JOIN motivos                      mt ON mt.id_cia = c.id_cia
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( c.tipdoc = mt.tipdoc )
            LEFT OUTER JOIN motivos_clase                mt16 ON mt16.id_cia = c.id_cia
                                                  AND ( mt16.codmot = c.codmot )
                                                  AND ( mt16.id = c.id )
                                                  AND ( mt16.tipdoc = c.tipdoc )
                                                  AND ( mt16.codigo = 16 )
            LEFT OUTER JOIN motivos_clase                mt19 ON mt19.id_cia = c.id_cia
                                                  AND ( mt19.codmot = c.codmot )
                                                  AND ( mt19.id = c.id )
                                                  AND ( mt19.tipdoc = c.tipdoc )
                                                  AND ( mt19.codigo = 19 )
            LEFT OUTER JOIN documentos_cab_ordcom        doc ON c.id_cia = doc.id_cia
                                                         AND ( c.numint = doc.numint )
            LEFT OUTER JOIN transportista                t1 ON t1.id_cia = c.id_cia
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN documentos_cab_transportista dct ON dct.id_cia = c.id_cia
                                                                AND ( dct.numint = c.numint )
            LEFT OUTER JOIN vehiculos                    vh ON vh.id_cia = c.id_cia
                                            AND ( vh.codveh = c.codveh )
            LEFT OUTER JOIN documentos_cab_clase         dct4 ON dct4.id_cia = c.id_cia
                                                         AND dct4.numint = c.numint
                                                         AND dct4.clase = 4
            LEFT OUTER JOIN documentos_cab_clase         dcp ON dcp.id_cia = c.id_cia
                                                        AND dcp.numint = c.numint
                                                        AND dcp.clase = 3
            LEFT OUTER JOIN cliente_clase                ccc ON ccc.id_cia = c.id_cia
                                                 AND ( ccc.tipcli = 'A' )
                                                 AND ( ccc.codcli = c.codcli )
                                                 AND ( ccc.clase = 23 )
            LEFT OUTER JOIN cliente_clase                c33 ON c33.id_cia = c.id_cia
                                                 AND ( c33.tipcli = 'A' )
                                                 AND ( c33.codcli = c.codcli )
                                                 AND ( c33.clase = 33 )
            LEFT OUTER JOIN cliente_clase                c22 ON c22.id_cia = c.id_cia
                                                 AND c22.tipcli = 'A'
                                                 AND c22.codcli = c.codcli
                                                 AND c22.clase = 22
                                                 AND NOT ( c22.codigo = 'ND' )
            LEFT OUTER JOIN vendedor                     v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN factor                       fap ON fap.id_cia = c.id_cia
                                          AND ( fap.codfac = 332 )
            LEFT OUTER JOIN documentos_det               d ON d.id_cia = c.id_cia
                                                AND ( d.numint = c.numint )
            LEFT OUTER JOIN documentos_det_clase         ddp ON ddp.id_cia = d.id_cia
                                                        AND ( ddp.numint = d.numint )
                                                        AND ( ddp.numite = d.numite )
                                                        AND ( ddp.clase = 50 )
            LEFT OUTER JOIN almacen                      al ON al.id_cia = d.id_cia
                                          AND ( al.tipinv = d.tipinv )
                                          AND ( al.codalm = d.codalm )
            LEFT OUTER JOIN articulos                    a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN listaprecios                 lp33 ON lp33.id_cia = c1.id_cia
                                                 AND lp33.vencom = 1
                                                 AND lp33.codtit = c1.codtit
                                                 AND lp33.tipinv = d.tipinv
                                                 AND lp33.codart = d.codart
            LEFT OUTER JOIN listaprecios_alternativa     lpa33 ON lpa33.id_cia = c1.id_cia
                                                              AND lpa33.vencom = 1
                                                              AND lpa33.codtit = c1.codtit
                                                              AND lpa33.tipinv = d.tipinv
                                                              AND lpa33.codart = d.codart
                                                              AND lpa33.codadd01 = d.codadd01
                                                              AND lpa33.codadd02 = d.codadd02
            LEFT OUTER JOIN articulos_glosa              agl ON ( agl.tipo = 2 )
                                                   AND ( agl.tipinv = d.tipinv )
                                                   AND ( agl.codart = d.codart )
            LEFT OUTER JOIN articulos_clase              ac1 ON ac1.id_cia = d.id_cia
                                                   AND ( ac1.tipinv = d.tipinv )
                                                   AND ( ac1.codart = d.codart )
                                                   AND ( ac1.clase = 81 )
            LEFT OUTER JOIN clase_codigo                 cc2 ON cc2.id_cia = ac1.id_cia
                                                AND ( cc2.tipinv = ac1.tipinv )
                                                AND ( cc2.clase = ac1.clase )
                                                AND ( cc2.codigo = ac1.codigo )
            LEFT OUTER JOIN articulos_clase_alternativo  aca1 ON aca1.id_cia = d.id_cia
                                                                AND aca1.tipinv = d.tipinv
                                                                AND aca1.codart = d.codart
                                                                AND aca1.clase = 1
                                                                AND aca1.codigo = d.codund
            LEFT OUTER JOIN documentos_cab_envio_sunat   ds ON ds.id_cia = c.id_cia
                                                             AND ( ds.numint = c.numint )
            LEFT OUTER JOIN situacion                    s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN unidad                       und ON und.id_cia = d.id_cia
                                          AND und.coduni = d.codund
            LEFT OUTER JOIN t_inventario                 ti ON ti.id_cia = d.id_cia
                                               AND ti.tipinv = d.tipinv
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
            c.tipdoc,
            c.numint,
            d.positi,
            d.numite ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_comprobante;

    FUNCTION sp_obtener_factura (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN datatable_obtener_factura
        PIPELINED
    AS
        v_table datatable_obtener_factura;
    BEGIN
        SELECT
            c.tipdoc            AS tipdoc,
            dc.descri           AS nomdoc,
            c.numint            AS numint,
            d.numite            AS numite,
            c.series            AS series,
            c.numdoc            AS numdoc,
            c.femisi            AS femisi,
            c.codcli            AS codcli,
            c.razonc            AS razonc,
            c.direc1            AS direc1,
            c.codsuc,
            c.ruc               AS ruc,
            c1.direc1           AS dircli1,
            c1.direc2           AS dircli2,
            c1.telefono         AS tlfcli,
            c1.fax              AS faxcli,
            c1.dident           AS dident,
            c.tident            AS tident_cab,
            i.descri            AS destident,
            i.abrevi            AS abrtident,
            ct.nrodni           AS nrodni,
            c.guiarefe          AS guiarefe,
            c.almdes            AS codalmdes,
            ald.descri          AS desalmdes,
            ald.abrevi          AS abralmdes,
            c.marcas            AS marcas,
            c.presen            AS presen,
            c.codsec            AS codsec,
            c.facpro            AS facpro,
            c.ffacpro           AS ffacpro,
            c.codven            AS codven,
            c.observ            AS obscab,
            c.tipcam            AS tipcam,
            c.tipmon            AS tipmon,
            c.totbru            AS totbru,
            c.desesp            AS desesp,
            c.descue            AS descue,
            c.monafe            AS monafe,
            CASE
                WHEN ( c.destin = 2
                       AND c.monina > 0 )
                     OR ( c1.codtpe <> 3
                          AND c22.codigo = 'S' ) THEN
                    CAST(0 AS NUMERIC(12, 2))
                ELSE
                    c.monina
            END                 AS monina,
            c.monafe + c.monina AS monneto,
            c.monigv            AS monigv,
            (
                CASE
                    WHEN ( mt16.valor IS NULL )
                         OR ( upper(mt16.valor) <> 'S' ) THEN
                        c.preven
                    ELSE
                        CAST(0 AS NUMERIC(12, 2))
                END
            )                   AS preven,
            (
                CASE
                    WHEN ( dct4.vreal IS NULL ) THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct4.vreal
                END
            )                   AS percep,
            (
                CASE
                    WHEN ( mt16.valor IS NULL )
                         OR ( upper(mt16.valor) <> 'S' ) THEN
                        c.preven
                    ELSE
                        CAST(0 AS NUMERIC(12, 2))
                END
            ) + (
                CASE
                    WHEN ( dct4.vreal IS NULL ) THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct4.vreal
                END
            )                   AS totpag,
            mt19.valor          AS relcossalprod,
            c.flete             AS flete,
            c.seguro            AS seguro,
            c.porigv            AS porigv,
            c.comisi            AS comiven,
            c.codmot            AS codmot,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                 AS numped,
            cv.despag           AS despagven,
            cvc.valor           AS enctacte,
            c.ordcom            AS ordcom,
            c.fordcom           AS fordcom,
            m1.simbolo          AS simbolo,
            m1.desmon           AS desmon,
            c.opnumdoc          AS opnumdoc,
            c.horing            AS horing,
            c.fecter            AS fecter,
            c.horter            AS horter,
            c.desnetx           AS desnetx,
            c.despreven         AS despreven,
            c.desfle            AS desfle,
            c.desseg            AS desseg,
            c.desgasa           AS desgasa,
            c.gasadu            AS gasadu,
            c.situac            AS situac,
            c.destin            AS destin,
            c.id                AS id,
            mt.desmot           AS desmot,
            mt.docayuda         AS docayuda,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                    'S'
                ELSE
                    'N'
            END                 AS swdocpercep,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                        ccc.codigo
                ELSE
                    CAST('0.00' AS VARCHAR(10))
            END
            || ' %'             AS porpercep,
            (
                SELECT
                    sp_exonerado_a_igv(c.id_cia, 'A', c.codcli, c.numint)
                FROM
                    dual
            )                   AS exoimp,
            cv.diaven           AS diaven,
            s1.sucursal         AS dessuc,
            s1.nomdis           AS dissuc,
            v1.desven           AS desven,
            t1.descri           AS destra,
            t1.domici           AS dirtra,
            t1.ruc              AS ructra,
            t1.punpar           AS punpartra,
            dca.direc1          AS desenv01,
            dca.direc2          AS desenv02,
            d.codalm            AS codalm,
            al.descri           AS desalm,
            d.tipinv            AS tipinv,
            d.codart            AS codart,
            CASE
                WHEN c33.codigo <> 'S' THEN
                    a.descri
                ELSE
                    CASE
                        WHEN lpa33.desart <> '' THEN
                                lpa33.desart
                        ELSE
                            CASE
                                WHEN lp33.desart <> '' THEN
                                            lp33.desart
                                ELSE
                                    a.descri
                            END
                    END
            END                 AS desart,
            a.faccon            AS faccon,
            a.consto            AS consto,
            d.largo * a.faccon  AS peslar,
            ( d.cantid * a.faccon ) + CAST(
                CASE
                    WHEN cc2.abrevi IS NULL THEN
                        CAST('0' AS VARCHAR(10))
                    ELSE
                        cc2.abrevi
                END
            AS NUMERIC(16,
     5))                 AS pesdet,
            cc2.abrevi          AS taraadic,
            a.codart
            || ' '
            || a.descri         AS coddesart,
            agl.observ          AS desglosa,
				--D.NUMITE,
            d.cantid            AS cantid,
            d.canref            AS canref,
            d.piezas            AS piezas,
            d.tara              AS tara,
            d.largo             AS largo,
            d.etiqueta          AS etiqueta,
            d.etiqueta          AS etiqueta2,
            a.coduni            AS codund,
            d.codadd01          AS codcalid,
            d.codadd02          AS codcolor,
            d.opronumdoc        AS opronumdoc,
            d.opnumdoc          AS dopnumdoc,
            d.opcargo           AS dopcargo,
            d.opnumite          AS dopnumite,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.preuni * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.preuni
            END                 AS preuni,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.importe_bruto * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe_bruto
            END                 AS importe_bruto,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.importe * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe
            END                 AS importe,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    ( d.importe_bruto - d.importe ) * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe_bruto - d.importe
            END                 AS descdet,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    ( d.importe /
                      CASE
                          WHEN d.cantid IS NULL
                               OR d.cantid = 0 THEN
                                1
                          ELSE
                              d.cantid
                      END
                    ) * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    ( d.importe /
                      CASE
                          WHEN d.cantid IS NULL
                               OR d.cantid = 0 THEN
                                1
                          ELSE
                              d.cantid
                      END
                    )
            END                 AS preuni02,
            d.preuni            AS preunireal,
            d.importe           AS importereal,
            d.codund            AS codunidet,
            d.pordes1           AS pordes1,
            d.pordes2           AS pordes2,
            d.pordes3           AS pordes3,
            d.pordes4           AS pordes4,
            d.monafe + d.monina AS monlinneto,
            d.monafe            AS monafedet,
            d.monigv            AS monigvdet,
            d.monisc            AS moniscdet,
            d.monotr            AS monotrdet,
				--D.LARGO * A.FacCon as PesLar,
            d.nrocarrete        AS nrocarrete,
            d.acabado,
            d.lote              AS lote,
            d.fvenci            AS fvenci,
            d.ancho             AS ancho,
            CASE
                WHEN ( ( fap.vstrg IS NOT NULL )
                       AND ( upper(fap.vstrg) = 'S' )
                       AND ( ddp.vreal IS NOT NULL )
                       AND ( ddp.vreal > 0 ) ) THEN
                    '*'
                ELSE
                    ''
            END                 AS astpercep,
            CASE
                WHEN d.cantid IS NULL
                     OR d.cantid = 0 THEN
                    0
                ELSE
                    ( d.monafe + d.monina ) / d.cantid
            END                 AS monuni,
            d.observ            AS obsdet
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab               c
            LEFT OUTER JOIN documentos                   dc ON dc.id_cia = c.id_cia
                                             AND ( dc.codigo = c.tipdoc )
                                             AND ( dc.series = c.series )
            LEFT OUTER JOIN cliente                      c1 ON c1.id_cia = c.id_cia
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN cliente_tpersona             ct ON ct.id_cia = c.id_cia
                                                   AND ( ct.codcli = c.codcli )
            LEFT OUTER JOIN identidad                    i ON i.id_cia = c1.id_cia
                                           AND ( i.tident = c1.tident )
            LEFT OUTER JOIN almacen                      ald ON ald.id_cia = c.id_cia
                                           AND ( ald.tipinv = 1 )
                                           AND ( ald.codalm = c.almdes )
            LEFT OUTER JOIN documentos_cab_clase         cc ON cc.id_cia = c.id_cia
                                                       AND ( cc.numint = c.numint )
                                                       AND ( cc.clase = 6 )
            LEFT OUTER JOIN c_pago                       cv ON cv.id_cia = c.id_cia
                                         AND ( cv.codpag = c.codcpag )
                                         AND ( upper(cv.swacti) = 'S' )
            LEFT OUTER JOIN c_pago_clase                 cvc ON cvc.id_cia = c.id_cia
                                                AND ( cvc.codpag = c.codcpag )
                                                AND ( cvc.codigo = 1 )
            LEFT OUTER JOIN tmoneda                      m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN sucursal                     s1 ON s1.id_cia = c.id_cia
                                           AND ( s1.codsuc = c.codsuc )
            LEFT OUTER JOIN motivos                      mt ON mt.id_cia = c.id_cia
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( c.tipdoc = mt.tipdoc )
            LEFT OUTER JOIN motivos_clase                mt16 ON mt16.id_cia = c.id_cia
                                                  AND ( mt16.codmot = c.codmot )
                                                  AND ( mt16.id = c.id )
                                                  AND ( mt16.tipdoc = c.tipdoc )
                                                  AND ( mt16.codigo = 16 )
            LEFT OUTER JOIN motivos_clase                mt19 ON mt19.id_cia = c.id_cia
                                                  AND ( mt19.codmot = c.codmot )
                                                  AND ( mt19.id = c.id )
                                                  AND ( mt19.tipdoc = c.tipdoc )
                                                  AND ( mt19.codigo = 19 )
            LEFT OUTER JOIN documentos_cab_almacen       dca ON c.id_cia = dca.id_cia
                                                          AND ( c.numint = dca.numint )
            LEFT OUTER JOIN documentos_cab_ordcom        doc ON c.id_cia = doc.id_cia
                                                         AND ( c.numint = doc.numint )
            LEFT OUTER JOIN transportista                t1 ON t1.id_cia = c.id_cia
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN documentos_cab_transportista dct ON dct.id_cia = c.id_cia
                                                                AND ( dct.numint = c.numint )
            LEFT OUTER JOIN vehiculos                    vh ON vh.id_cia = c.id_cia
                                            AND ( vh.codveh = c.codveh )
            LEFT OUTER JOIN documentos_cab_clase         dct4 ON dct4.id_cia = c.id_cia
                                                         AND dct4.numint = c.numint
                                                         AND dct4.clase = 4
            LEFT OUTER JOIN documentos_cab_clase         dcp ON dcp.id_cia = c.id_cia
                                                        AND dcp.numint = c.numint
                                                        AND dcp.clase = 3
            LEFT OUTER JOIN cliente_clase                ccc ON ccc.id_cia = c.id_cia
                                                 AND ( ccc.tipcli = 'A' )
                                                 AND ( ccc.codcli = c.codcli )
                                                 AND ( ccc.clase = 23 )
            LEFT OUTER JOIN cliente_clase                c33 ON c33.id_cia = c.id_cia
                                                 AND ( c33.tipcli = 'A' )
                                                 AND ( c33.codcli = c.codcli )
                                                 AND ( c33.clase = 33 )
            LEFT OUTER JOIN cliente_clase                c22 ON c22.id_cia = c.id_cia
                                                 AND c22.tipcli = 'A'
                                                 AND c22.codcli = c.codcli
                                                 AND c22.clase = 22
                                                 AND NOT ( c22.codigo = 'ND' )
            LEFT OUTER JOIN vendedor                     v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN factor                       fap ON fap.id_cia = c.id_cia
                                          AND ( fap.codfac = 332 )
            LEFT OUTER JOIN documentos_det               d ON d.id_cia = c.id_cia
                                                AND ( d.numint = c.numint )
            LEFT OUTER JOIN documentos_det_clase         ddp ON ddp.id_cia = d.id_cia
                                                        AND ( ddp.numint = d.numint )
                                                        AND ( ddp.numite = d.numite )
                                                        AND ( ddp.clase = 50 )
            LEFT OUTER JOIN almacen                      al ON al.id_cia = d.id_cia
                                          AND ( al.tipinv = d.tipinv )
                                          AND ( al.codalm = d.codalm )
            LEFT OUTER JOIN articulos                    a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN listaprecios                 lp33 ON lp33.id_cia = c1.id_cia
                                                 AND lp33.vencom = 1
                                                 AND lp33.codtit = c1.codtit
                                                 AND lp33.tipinv = d.tipinv
                                                 AND lp33.codart = d.codart
            LEFT OUTER JOIN listaprecios_alternativa     lpa33 ON lpa33.id_cia = c1.id_cia
                                                              AND lpa33.vencom = 1
                                                              AND lpa33.codtit = c1.codtit
                                                              AND lpa33.tipinv = d.tipinv
                                                              AND lpa33.codart = d.codart
                                                              AND lpa33.codadd01 = d.codadd01
                                                              AND lpa33.codadd02 = d.codadd02
            LEFT OUTER JOIN articulos_glosa              agl ON ( agl.tipo = 2 )
                                                   AND ( agl.tipinv = d.tipinv )
                                                   AND ( agl.codart = d.codart )
            LEFT OUTER JOIN articulos_clase              ac1 ON ac1.id_cia = d.id_cia
                                                   AND ( ac1.tipinv = d.tipinv )
                                                   AND ( ac1.codart = d.codart )
                                                   AND ( ac1.clase = 81 )
            LEFT OUTER JOIN clase_codigo                 cc2 ON cc2.id_cia = ac1.id_cia
                                                AND ( cc2.tipinv = ac1.tipinv )
                                                AND ( cc2.clase = ac1.clase )
                                                AND ( cc2.codigo = ac1.codigo )
            LEFT OUTER JOIN articulos_clase_alternativo  aca1 ON aca1.id_cia = d.id_cia
                                                                AND aca1.tipinv = d.tipinv
                                                                AND aca1.codart = d.codart
                                                                AND aca1.clase = 1
                                                                AND aca1.codigo = d.codund
            LEFT OUTER JOIN documentos_cab_envio_sunat   ds ON ds.id_cia = c.id_cia
                                                             AND ( ds.numint = c.numint )
            LEFT OUTER JOIN situacion                    s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN unidad                       und ON und.id_cia = d.id_cia
                                          AND und.coduni = d.codund
            LEFT OUTER JOIN t_inventario                 ti ON ti.id_cia = d.id_cia
                                               AND ti.tipinv = d.tipinv
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
            c.tipdoc,
            c.numint,
            d.positi,
            d.numite ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_factura;

    FUNCTION sp_obtener_cotizacion (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN datatable_obtener_cotizacion
        PIPELINED
    AS
        v_table datatable_obtener_cotizacion;
    BEGIN
        SELECT
            c.tipdoc                    AS tipdoc,
            c.numint                    AS numint,
            c.series                    AS series,
            c.numdoc                    AS numdoc,
            c.femisi                    AS femisi,
            c.codcli                    AS codcli,
            c.razonc                    AS razonc,
            c.direc1                    AS direc1,
            c.ruc                       AS ruc,
            c.tipmon                    AS tipmon,
            c.tipcam                    AS tipcam,
            d.numite                    AS numite,
            d.positi                    AS positi,
            d.codund                    AS codunddet,
            d.cantid                    AS cantid,
            d.preuni                    AS preuni,
            d.importe                   AS importe,
            d.pordes1                   AS pordes1,
            d.pordes2                   AS pordes2,
            d.pordes3                   AS pordes3,
            d.pordes4                   AS pordes4,
            d.ubica                     AS ubica,
            d.importe_bruto - d.importe AS descdet,
            d.observ                    AS obsdet,
            d.swacti                    AS swacti,
            c.monafe + c.monina         AS monneto,
            c.monigv                    AS monigv,
            c.preven                    AS preven,
            (
                CASE
                    WHEN dct.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct.vreal
                END
            )                           AS percep,
            ( c.preven ) + (
                CASE
                    WHEN dct.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct.vreal
                END
            )                           AS totpag,
            c.porigv                    AS porigv,
            dcc.atenci                  AS atenci,
            c.incigv                    AS incigv,
            dcc.plaent                  AS plaent,
            dcc.valide                  AS valide,
            dcc.email                   AS mailcont,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                         AS numped,
            c.situac                    AS situac,
            c.observ                    AS obscab,
            c.fentreg                   AS fentreg,
            c.ffacpro                   AS ffacpro,
            c.ordcom                    AS ordcom,
            c.guiarefe                  AS guiarefe,
            c.marcas                    AS marcas,
            a.descri                    AS desart,
            a.coduni                    AS codund,
            a.codlin                    AS conlin,
            a.faccon                    AS faccon,
            a.conesp                    AS conesp,
            d.cantid * a.faccon         AS pesdet,
            c.codcpag                   AS codcpag,
            cv.despag                   AS despagven,
            CASE
                WHEN ac5.codigo IS NULL THEN
                    CAST('N' AS VARCHAR(20))
                ELSE
                    ac5.codigo
            END                         AS glosxdes,
            v1.desven                   AS desven,
            v1.cargo                    AS carven,
            v1.email                    AS mailven,
            v1.celular                  AS celuven,
            v1.telefo                   AS tlfven,
            v1.codven                   AS codvendedor,
            m1.simbolo                  AS simbolo,
            m1.desmon                   AS desmon,
            s2.alias                    AS aliassit,
            vcc.descri                  AS especialidad,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                    CAST('S' AS VARCHAR(20))
                ELSE
                    CAST('N' AS VARCHAR(20))
            END                         AS swdocpercep,
            CASE
                WHEN ( ( fap.vstrg IS NOT NULL )
                       AND ( upper(fap.vstrg) = 'S' )
                       AND ( ddp.vreal IS NOT NULL )
                       AND ( ddp.vreal > 0 ) ) THEN
                    '*'
                ELSE
                    ''
            END                         AS astpercep,
            gar.glosa                   AS glosagar,
            gap.glosa                   AS glosagap,
            gfp.glosa                   AS glosagfp,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                        ccc.codigo
                ELSE
                    CAST('0.00' AS VARCHAR(20))
            END
            || ' %'                     AS porpercep,
            (
                SELECT
                    glosa
                FROM
                    companias_glosa
                WHERE
                        id_cia = pin_id_cia
                    AND item = 9
            )                           AS gnotas,
            (
                CASE
                    WHEN aca1.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 6))
                    ELSE
                        aca1.vreal
                END
            )                           valundaltven,
            ( cc14.descri
              || ' - '
              || cc15.descri
              || ' - '
              || cc16.descri )            AS ubigeo,
            ( cc16.descri
              || ' -'
              || cc15.descri
              || ' - '
              || cc14.descri )            AS ubigeo_b,
            d.codart,
            dx.descri                   AS desdoc,
            un.abrevi                   AS abrunidad,
            dca.direc1                  AS desenv01,
            t1.descri                   AS destra,
            cia.ruc                     AS ruccia,
            c.codsuc
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab              c
            LEFT OUTER JOIN documentos_det              d ON ( d.id_cia = c.id_cia
                                                  AND d.numint = c.numint )
            LEFT OUTER JOIN unidad                      un ON un.id_cia = d.id_cia
                                         AND un.coduni = d.codund
            LEFT OUTER JOIN articulos                   a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN tmoneda                     m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN cliente_clase               ccc ON ccc.id_cia = c.id_cia
                                                 AND ( ccc.tipcli = 'A' )
                                                 AND ( ccc.codcli = c.codcli )
                                                 AND ( ccc.clase = 23 )
            LEFT OUTER JOIN cliente_clase               c14 ON c14.id_cia = c.id_cia
                                                 AND ( c14.tipcli = 'A' )
                                                 AND ( c14.codcli = c.codcli )
                                                 AND ( c14.clase = 14 )
            LEFT OUTER JOIN clase_cliente_codigo        cc14 ON cc14.id_cia = c14.id_cia
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase               c15 ON c15.id_cia = c.id_cia
                                                 AND ( c15.tipcli = 'A' )
                                                 AND ( c15.codcli = c.codcli )
                                                 AND ( c15.clase = 15 )
            LEFT OUTER JOIN clase_cliente_codigo        cc15 ON cc15.id_cia = c15.id_cia
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase               c16 ON c16.id_cia = c.id_cia
                                                 AND ( c16.tipcli = 'A' )
                                                 AND ( c16.codcli = c.codcli )
                                                 AND ( c16.clase = 16 )
            LEFT OUTER JOIN clase_cliente_codigo        cc16 ON cc16.id_cia = c16.id_cia
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN documentos_cab_almacen      dca ON c.id_cia = dca.id_cia
                                                          AND ( c.numint = dca.numint )
            LEFT OUTER JOIN documentos_cab_contacto     dcc ON ( c.id_cia = dcc.id_cia
                                                             AND c.numint = dcc.numint )
            LEFT OUTER JOIN documentos_cab_clase        cc ON cc.id_cia = c.id_cia
                                                       AND ( cc.numint = c.numint )
                                                       AND ( cc.clase = 6 )
            LEFT OUTER JOIN documentos_cab_clase        dcp ON dcp.id_cia = c.id_cia
                                                        AND ( dcp.numint = c.numint )
                                                        AND ( dcp.clase = 3 )
            LEFT OUTER JOIN documentos_cab_clase        dct ON dct.id_cia = c.id_cia
                                                        AND ( dct.numint = c.numint )
                                                        AND ( dct.clase = 4 )
            LEFT OUTER JOIN documentos_det_clase        ddp ON ddp.id_cia = d.id_cia
                                                        AND ( ddp.numint = d.numint )
                                                        AND ( ddp.numite = d.numite )
                                                        AND ( ddp.clase = 50 )
            LEFT OUTER JOIN factor                      far ON far.id_cia = c.id_cia
                                          AND ( far.codfac = 331 )
            LEFT OUTER JOIN factor                      fap ON fap.id_cia = c.id_cia
                                          AND ( fap.codfac = 332 )
            LEFT OUTER JOIN companias_glosa             gar ON gar.id_cia = far.id_cia
                                                   AND ( far.vstrg IS NOT NULL )
                                                   AND ( upper(far.vstrg) = 'S' )
                                                   AND ( gar.item = 15 )
            LEFT OUTER JOIN companias_glosa             gap ON gap.id_cia = fap.id_cia
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( gap.item = 13 )
            LEFT OUTER JOIN companias_glosa             gfp ON gfp.id_cia = fap.id_cia
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( dcp.codigo IS NOT NULL )
                                                   AND ( upper(dcp.codigo) = 'S' )
                                                   AND ( gfp.item = 14 )
            LEFT OUTER JOIN c_pago                      cv ON cv.id_cia = c.id_cia
                                         AND ( cv.codpag = c.codcpag )
                                         AND ( upper(cv.swacti) = 'S' )
            LEFT OUTER JOIN vendedor                    v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN vendedor_clase              vc ON vc.id_cia = c.id_cia
                                                 AND ( vc.codven = c.codven )
                                                 AND ( vc.clase = 3 )
            LEFT OUTER JOIN clase_vendedor_codigo       vcc ON vcc.id_cia = vc.id_cia
                                                         AND ( vcc.clase = vc.clase )
                                                         AND ( vcc.codigo = vc.codigo )
            LEFT OUTER JOIN situacion                   s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN articulos_clase             ac5 ON ac5.id_cia = d.id_cia
                                                   AND ( ac5.tipinv = d.tipinv )
                                                   AND ( ac5.codart = d.codart )
                                                   AND ( ac5.clase = 87 )
            LEFT OUTER JOIN articulos_clase_alternativo aca1 ON aca1.id_cia = d.id_cia
                                                                AND aca1.tipinv = d.tipinv
                                                                AND aca1.codart = d.codart
                                                                AND aca1.clase = 1
                                                                AND aca1.codigo = d.codund
            LEFT OUTER JOIN documentos                  dx ON dx.id_cia = c.id_cia
                                             AND ( dx.codigo = c.tipdoc )
                                             AND ( dx.series = c.series )
            LEFT OUTER JOIN transportista               t1 ON t1.id_cia = c.id_cia
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN companias                   cia ON cia.cia = pin_id_cia
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
            AND c.tipdoc = 100
        ORDER BY
            c.tipdoc,
            c.numint,
            d.positi,
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_cotizacion;

    FUNCTION sp_obtener_guia_remision (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN datatable_obtener_guia_remision
        PIPELINED
    AS
        v_table datatable_obtener_guia_remision;
    BEGIN
        SELECT
            c.tipdoc,
            dc.descri           AS nomdoc,
            c.numint,
            c.id,
            c.series,
            c.numdoc,
            c.femisi,
            c.destin,
            c.codcli,
            c.razonc,
            c.direc1,
            c.ruc,
            c.tipcam,
            c.tipmon,
            c.codven,
            d.numite,
            d.positi,
            d.tipinv,
            d.codart,
            d.observ            AS obsdet,
            d.codund            AS codund,
            d.codund            AS codunidet,
            CASE
                WHEN (
                    CASE
                        WHEN aca1.vreal IS NULL THEN
                            0
                        ELSE
                            aca1.vreal
                    END
                ) > 0 THEN
                    d.cantid * aca1.vreal
                ELSE
                    d.cantid
            END                 AS cantid,
            d.cantid            AS cantidbase,
            d.canref,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.preuni * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.preuni
            END                 AS preuni,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.importe_bruto * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe_bruto
            END                 AS importe_bruto,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    d.importe * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe
            END                 AS importe,
            CASE
                WHEN ( ( c.tipdoc = 3 )
                       AND ( c.incigv = 'N' ) ) THEN
                    ( d.importe_bruto - d.importe ) * ( 1 + ( d.porigv / 100 ) )
                ELSE
                    d.importe_bruto - d.importe
            END                 AS descdet,
            d.opronumdoc,
            d.swacti,
            d.piezas,
            d.largo,
            d.ancho,
            d.altura,
            d.etiqueta,
            d.etiqueta2,
			--D.CODUND AS CODUNIDET,
            d.tara,
            d.royos,
            d.pordes1,
            d.pordes2,
            d.pordes3,
            d.pordes4,
            d.opnumdoc          AS dopnumdoc,
            d.opcargo           AS dopcargo,
            d.opnumite          AS dopnumite,
            d.codalm,
            d.monafe            AS monafedet,
            d.monigv            AS monigvdet,
            d.lote              AS lote,
            d.fvenci            AS fvenci,
            d.nrocarrete        AS nrocarrete,
            d.acabado           AS acabado,
            c.descue,
            c.totbru,
            c.monafe,
            c.monina,
            c.monafe + c.monina AS monneto,
            c.monigv,
            c.preven,
            c.porigv,
            c.codsuc,
            c.incigv,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                 AS numped,
            c.codmot,
            c.situac,
            c.observ            AS obscab,
            c.fentreg,
            c.codarea,
            c.coduso,
            c.totcan,
            dca.codenv,
            c.horing,
            c.fecter,
            c.horter,
            c.codtec,
            c.opnumdoc,
            c.ordcom,
            c.fordcom,
            c.guiarefe,
            dca.direc1          AS desenv01,
            dca.direc2          AS desenv02,
            c.marcas,
            c.presen,
            c.codsec,
            c.facpro,
            c.ffacpro,
            c.numvale,
            c.fecvale,
            c.desnetx,
            c.despreven,
            c.desfle,
            c.flete,
            c.desseg,
            c.seguro,
            c.desgasa,
            c.gasadu,
            CASE
                WHEN c33.codigo <> 'S' THEN
                    a.descri
                ELSE
                    CASE
                        WHEN lpa33.desart <> '' THEN
                                lpa33.desart
                        ELSE
                            CASE
                                WHEN lp33.desart <> '' THEN
                                            lp33.desart
                                ELSE
                                    a.descri
                            END
                    END
            END                 AS desart,
            a.codbar,
            a.codart
            || ' '
            || a.descri         AS coddesart,
            a.codlin,
            a.faccon,
            a.consto,
            d.largo * a.faccon  AS peslar,
            ( d.cantid * a.faccon ) + CAST(
                CASE
                    WHEN cc2.abrevi IS NULL THEN
                        '0'
                    ELSE
                        cc2.abrevi
                END
            AS NUMERIC(16, 5))  AS pesdet,
            cc2.abrevi          AS taraadic,
            cv.despag           AS despagven,
            cvc.valor           AS enctacte,
            cv.diaven,
            s1.sucursal         AS dessuc,
            s1.nomdis           AS dissuc,
            c1.direc1           AS dircli1,
            c1.direc2           AS dircli2,
            c1.email            AS emailcli,
            c1.fax              AS faxcli,
            c1.telefono         AS tlfcli,
            c1.dident,
            c1.tident           AS tident,
            v1.desven,
            c.comisi            AS comiven,
            v1.codven           AS codvendedor,
            m1.simbolo,
            m1.desmon,
            c.codtra,
            t1.swdattra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.destra
                ELSE
                    t1.razonc
            END                 AS razonctra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.chofer
                ELSE
                    t1.descri
            END                 AS destra,
            t1.domici           AS dirtra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.ruc
                ELSE
                    t1.ruc
            END                 AS ructra,
            t1.punpar           AS punpartra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.licenc
                ELSE
                    t1.licenc
            END                 AS licenciatra,
            t1.placa            AS placatra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.certif
                ELSE
                    t1.certif
            END                 AS certiftra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.telef1
                ELSE
                    t1.telef1
            END                 AS fonotra,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.desveh
                ELSE
                    vh.descri
            END                 AS desveh,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.tipo
                ELSE
                    vh.tipo
            END                 AS tipoveh,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.marca
                ELSE
                    vh.marca
            END                 AS marcaveh,
            CASE
                WHEN t1.swdattra = 'S' THEN
                    dct.placa
                ELSE
                    CASE
                        WHEN vh.placa IS NOT NULL
                             OR vh.placa <> '' THEN
                                vh.placa
                        ELSE
                            t1.placa
                    END
            END                 AS placaveh,
            mt.desmot,
            c.direccpar         AS direccpar,
            c.ubigeopar         AS ubigeopar,
            CASE
                WHEN length(
                    CASE
                        WHEN t1.swdattra = 'S' THEN
                            dct.ruc
                        ELSE
                            t1.ruc
                    END
                ) = 11 THEN
                    '6'
                ELSE
                    '0'
            END                 AS tidentra,
            CASE
                WHEN t1.chofer_tident IS NULL THEN
                    dct.chofer_tident
                ELSE
                    t1.chofer_tident
            END                 AS tidentconductor,
            CASE
                WHEN t1.chofer_tident IS NULL THEN
                    (
                        SELECT
                            descri
                        FROM
                            identidad
                        WHERE
                                id_cia = dct.id_cia
                            AND tident = dct.chofer_tident
                    )
                ELSE
                    (
                        SELECT
                            descri
                        FROM
                            identidad
                        WHERE
                                id_cia = t1.id_cia
                            AND tident = t1.chofer_tident
                    )
            END                 AS destidentconductor
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab                c
            LEFT OUTER JOIN documentos_cab                cr ON cr.id_cia = c.id_cia
                                                 AND ( cr.numint = c.ordcomni )
            LEFT OUTER JOIN documentos_cab_envio_sunat    ds ON ( ds.numint = c.numint )
                                                             AND ds.id_cia = c.id_cia
            LEFT OUTER JOIN documentos_cab_ordcom         doc ON c.id_cia = doc.id_cia
                                                         AND ( c.numint = doc.numint )
            LEFT OUTER JOIN tdoccobranza                  tdr ON tdr.id_cia = cr.id_cia
                                                AND ( tdr.tipdoc = cr.tipdoc )
            LEFT OUTER JOIN documentos_cab_clase          cc ON cc.id_cia = c.id_cia
                                                       AND ( cc.numint = c.numint
                                                             AND cc.clase = 6 )
            LEFT OUTER JOIN documentos_det                d ON d.id_cia = c.id_cia
                                                AND ( d.numint = c.numint )
            LEFT OUTER JOIN unidad                        und ON und.id_cia = d.id_cia
                                          AND und.coduni = d.codund
            LEFT OUTER JOIN documentos                    dc ON dc.id_cia = c.id_cia
                                             AND ( dc.codigo = c.tipdoc )
                                             AND ( dc.series = c.series )
            LEFT OUTER JOIN articulos                     a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN articulos_clase               ac1 ON ac1.id_cia = d.id_cia
                                                   AND ( ac1.tipinv = d.tipinv
                                                         AND ac1.codart = d.codart
                                                         AND ac1.clase = 81 )
            LEFT OUTER JOIN clase_codigo                  cc2 ON cc2.id_cia = ac1.id_cia
                                                AND ( cc2.tipinv = ac1.tipinv
                                                      AND cc2.clase = ac1.clase
                                                      AND cc2.codigo = ac1.codigo )
            LEFT OUTER JOIN c_pago                        cv ON cv.id_cia = c.id_cia
                                         AND ( cv.codpag = c.codcpag )
                                         AND upper(cv.swacti) = 'S'
            LEFT OUTER JOIN c_pago_clase                  cvc ON cvc.id_cia = c.id_cia
                                                AND ( cvc.codpag = c.codcpag )
                                                AND ( cvc.codigo = 1 )
            LEFT OUTER JOIN sucursal                      s1 ON s1.id_cia = c.id_cia
                                           AND ( s1.codsuc = c.codsuc )
            LEFT OUTER JOIN cliente                       c1 ON c1.id_cia = c.id_cia
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN cliente_clase                 c33 ON c33.id_cia = c.id_cia
                                                 AND ( c33.tipcli = 'A' )
                                                 AND ( c33.codcli = c.codcli )
                                                 AND ( c33.clase = 33 )
            LEFT OUTER JOIN listaprecios                  lp33 ON lp33.id_cia = c1.id_cia
                                                 AND lp33.vencom = 1
                                                 AND lp33.codtit = c1.codtit
                                                 AND lp33.tipinv = d.tipinv
                                                 AND lp33.codart = d.codart
            LEFT OUTER JOIN listaprecios_alternativa      lpa33 ON lpa33.id_cia = c1.id_cia
                                                              AND lpa33.vencom = 1
                                                              AND lpa33.codtit = c1.codtit
                                                              AND lpa33.tipinv = d.tipinv
                                                              AND lpa33.codart = d.codart
                                                              AND lpa33.codadd01 = d.codadd01
                                                              AND lpa33.codadd02 = d.codadd02
            LEFT OUTER JOIN cliente_tpersona              ct ON ct.id_cia = c.id_cia
                                                   AND ( ct.codcli = c.codcli )
            LEFT OUTER JOIN vendedor                      v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN tmoneda                       m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN transportista                 t1 ON ( t1.id_cia = c.id_cia
                                                  AND t1.codtra = c.codtra )
            LEFT OUTER JOIN motivos                       mt ON mt.id_cia = c.id_cia
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( mt.tipdoc = c.tipdoc )
            LEFT OUTER JOIN documentos_cab_almacen        dca ON ( c.id_cia = dca.id_cia
                                                            AND c.numint = dca.numint )
            LEFT OUTER JOIN clientes_almacen_clase        cac16 ON cac16.id_cia = c.id_cia
                                                            AND cac16.codcli = c.codcli
                                                            AND cac16.codenv = dca.codenv
                                                            AND cac16.clase = 16
            LEFT OUTER JOIN clase_clientes_almacen_codigo ca16 ON ca16.id_cia = cac16.id_cia
                                                                  AND ca16.clase = cac16.clase
                                                                  AND ca16.codigo = cac16.codigo
            LEFT OUTER JOIN clientes_almacen              ca ON ca.id_cia = c.id_cia
                                                   AND ( ca.codcli = c.codcli )
                                                   AND ( ca.codenv = dca.codenv )
            LEFT OUTER JOIN documentos_cab_transportista  dct ON dct.id_cia = c.id_cia
                                                                AND ( dct.numint = c.numint )
            LEFT OUTER JOIN vehiculos                     vh ON vh.id_cia = c.id_cia
                                            AND ( vh.codveh = c.codveh )
            LEFT OUTER JOIN articulos_clase_alternativo   aca1 ON aca1.id_cia = d.id_cia
                                                                AND aca1.tipinv = d.tipinv
                                                                AND aca1.codart = d.codart
                                                                AND aca1.clase = 1
                                                                AND aca1.codigo = d.codund
        WHERE
            ( c.id_cia = pin_id_cia )
            AND ( c.numint = pin_numint )
        ORDER BY
            c.tipdoc,
            c.numint,
            d.numite ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_guia_remision;

    FUNCTION sp_obtener_pedido (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN datatable_obtener_pedido
        PIPELINED
    AS
        v_table datatable_obtener_pedido;
    BEGIN
        SELECT
            c.numint                            AS numint,
            d.numite                            AS numite,
            c.series                            AS series,
            c.numdoc                            AS numdoc,
            c.femisi                            AS femisi,
            c.opnumdoc                          AS opnumdoc,
            c.razonc                            AS razonc,
            c.direc1                            AS direc1,
            c.ruc                               AS ruc,
            c.tipmon                            AS tipmon,
            c.fentreg                           AS fentreg,
            c.fecter                            AS fecter,
            c.horter                            AS horter,
            c.observ                            AS obscab,
            c.monafe                            AS monafe,
            c.monina                            AS monina,
            c.monafe + c.monina + c.monexo      AS monneto,
            c.monexo                            AS monexo,
            c.monigv                            AS monigv,
            c.monisc                            AS monisc,
            c.monotr                            AS monotr,
            c.preven                            AS preven,
            (
                CASE
                    WHEN dct.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct.vreal
                END
            )                                   AS percep,
            ( c.preven ) + (
                CASE
                    WHEN dct.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct.vreal
                END
            )                                   AS totpag,
            c.porigv                            AS porigv,
            c.desesp                            AS desesp,
            c1.fax                              AS faxcli,
            c1.telefono                         AS tlfcli,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                                 AS numped,
            CASE
                WHEN ac5.codigo IS NULL THEN
                    CAST('N' AS VARCHAR(20))
                ELSE
                    ac5.codigo
            END                                 AS glosxdes,
            dca.direc1                          AS desenv01,
            t1.descri                           AS destra,
            t2.descri                           AS destra2,
            dcc.atenci                          AS atenci,
            v1.desven                           AS desven,
            CASE
                WHEN dap.situac = 'B' THEN
                    CAST('Aprobado' AS VARCHAR(50))
                ELSE
                    CASE
                        WHEN dap.situac = 'J' THEN
                                CAST('Desaprobado' AS VARCHAR(50))
                        ELSE
                            s2.alias
                    END
            END                                 AS aliassit,
            s2.dessit                           AS dessit,
            mt.desmot                           AS desmot,
            d.codart                            AS codart,
            a.descri                            AS desart,
            a.consto                            AS consto,
            d.codalm                            AS codalm,
            d.observ                            AS obsdet,
            d.monafe                            AS monafedet,
            d.monina                            AS moninadet,
            d.monisc                            AS moniscdet,
            d.monigv                            AS monigvdet,
            d.monotr                            AS monotrdet,
            d.codund                            AS codunddet,
            a.coduni                            AS codund,
            d.cantid                            AS cantid,
            d.piezas                            AS piezas,
            d.largo                             AS largo,
            d.ancho                             AS ancho,
            d.preuni                            AS preuni,
            d.importe                           AS importe,
            d.importe_bruto                     AS importe_bruto,
            d.pordes1                           AS pordes1,
            d.pordes2                           AS pordes2,
            d.pordes3                           AS pordes3,
            d.pordes4                           AS pordes4,
            d.opronumdoc                        AS opronumdoc,
            d.etiqueta                          AS etiqueta,
            d.acabado                           AS acabado,
            d.nrocarrete                        AS nrocarrete,
            ( k.ingreso - k.salida )            AS stockk001,
            ( k.ingreso - k.salida ) - d.cantid AS saldok001,
            m1.simbolo                          AS simbolo,
            m1.desmon                           AS desmon,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                        ccc.codigo
                ELSE
                    CAST('0.00' AS VARCHAR(20))
            END
            || ' %'                             AS porpercep,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                    's'
                ELSE
                    'n'
            END                                 AS swdocpercep,
            CASE
                WHEN ( ( fap.vstrg IS NOT NULL )
                       AND ( upper(fap.vstrg) = 'S' )
                       AND ( ddp.vreal IS NOT NULL )
                       AND ( ddp.vreal > 0 ) ) THEN
                    '*'
                ELSE
                    ''
            END                                 AS astpercep,
            gar.glosa                           AS glosagar,
            gap.glosa                           AS glosagap,
            gfp.glosa                           AS glosagfp,
            dc2.vstrg                           AS codpiepagforf01,
            dc3.vstrg                           AS codpiepagforf02,
            (
                CASE
                    WHEN aca1.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 6))
                    ELSE
                        aca1.vreal
                END
            )                                   AS valundaltven,
            sv.usuari                           AS c_visadopor,
            uv.nombres                          AS visadopor,
            se.usuari                           AS c_emitidopor,
            ue.nombres                          AS emitidopor,
            dap.uactua                          AS c_aprobadopor,
            ua.nombres                          AS aprobadopor,
            (
                CASE
                    WHEN dap.situac IS NULL THEN
                        CAST('E' AS CHAR(1))
                    ELSE
                        dap.situac
                END
            )                                   AS situac_aprob,
            ( cc14.descri
              || ','
              || cc15.descri
              || ','
              || cc16.descri )                    AS ubigeo,
            ( cc16.descri
              || ' - '
              || cc15.descri
              || '- '
              || cc14.descri )                    AS ubigeo_b,
            doc.fecha                           AS fecha_dcorcom,
            doc.numero                          AS numero_dcorcom,
            doc.contacto                        AS contacto_dcorcom,
            un.abrevi                           AS abrunidad,
            d.codadd01,
            cl1.descri                          AS descodadd01,
            d.codadd02,
            cl2.descri                          AS descodadd02,
            c.codsuc
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab              c
            LEFT OUTER JOIN cliente                     c1 ON c1.id_cia = c.id_cia
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN vendedor                    v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN situacion                   s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN transportista               t1 ON t1.id_cia = c.id_cia
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN transportista               t2 ON t2.id_cia = c.id_cia
                                                AND ( t2.codtra = c.codtec )
            LEFT OUTER JOIN motivos                     mt ON mt.id_cia = c.id_cia
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( mt.tipdoc = c.tipdoc )
            LEFT OUTER JOIN cliente_clase               ccc ON ccc.id_cia = c.id_cia
                                                 AND ( ccc.tipcli = 'A' )
                                                 AND ( ccc.codcli = c.codcli )
                                                 AND ( ccc.clase = 23 )
            LEFT OUTER JOIN cliente_clase               c14 ON c14.id_cia = c.id_cia
                                                 AND ( c14.tipcli = 'A' )
                                                 AND ( c14.codcli = c.codcli )
                                                 AND ( c14.clase = 14 )
            LEFT OUTER JOIN clase_cliente_codigo        cc14 ON cc14.id_cia = c14.id_cia
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase               c15 ON c15.id_cia = c.id_cia
                                                 AND ( c15.tipcli = 'A' )
                                                 AND ( c15.codcli = c.codcli )
                                                 AND ( c15.clase = 15 )
            LEFT OUTER JOIN clase_cliente_codigo        cc15 ON cc15.id_cia = c15.id_cia
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase               c16 ON c16.id_cia = c.id_cia
                                                 AND ( c16.tipcli = 'A' )
                                                 AND ( c16.codcli = c.codcli )
                                                 AND ( c16.clase = 16 )
            LEFT OUTER JOIN clase_cliente_codigo        cc16 ON cc16.id_cia = c16.id_cia
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN documentos_cab_ordcom       doc ON doc.id_cia = c.id_cia
                                                         AND doc.numint = c.numint
            LEFT OUTER JOIN documentos_cab_almacen      dca ON dca.id_cia = c.id_cia
                                                          AND ( dca.numint = c.numint )
            LEFT OUTER JOIN documentos_cab_contacto     dcc ON dcc.id_cia = c.id_cia
                                                           AND ( dcc.numint = c.numint )
            LEFT OUTER JOIN documentos_cab_clase        cc ON cc.id_cia = c.id_cia
                                                       AND ( cc.numint = c.numint )
                                                       AND ( cc.clase = 6 )
            LEFT OUTER JOIN factor                      far ON far.id_cia = c.id_cia
                                          AND ( far.codfac = 331 )
            LEFT OUTER JOIN factor                      fap ON fap.id_cia = c.id_cia
                                          AND ( fap.codfac = 332 )
            LEFT OUTER JOIN documentos_det              d ON d.id_cia = c.id_cia
                                                AND ( d.numint = c.numint )
            LEFT OUTER JOIN unidad                      un ON un.id_cia = d.id_cia
                                         AND un.coduni = d.codund
            LEFT OUTER JOIN kardex001                   k ON k.id_cia = d.id_cia
                                           AND ( k.tipinv = d.tipinv )
                                           AND ( k.codart = d.codart )
                                           AND ( k.codalm = d.codalm )
                                           AND ( k.etiqueta = d.etiqueta )
            LEFT OUTER JOIN documentos_cab_clase        dcp ON dcp.id_cia = c.id_cia
                                                        AND ( dcp.numint = c.numint )
                                                        AND ( dcp.clase = 3 )
            LEFT OUTER JOIN documentos_cab_clase        dct ON dct.id_cia = c.id_cia
                                                        AND ( dct.numint = c.numint )
                                                        AND ( dct.clase = 4 )
            LEFT OUTER JOIN documentos_det_clase        ddp ON ddp.id_cia = d.id_cia
                                                        AND ( ddp.numint = d.numint )
                                                        AND ( ddp.numite = d.numite )
                                                        AND ( ddp.clase = 50 )
            LEFT OUTER JOIN articulos                   a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN cliente_articulos_clase     cl1 ON cl1.id_cia = a.id_cia
                                                           AND ( cl1.tipcli = 'B' )
                                                           AND ( cl1.codcli = a.codprv )
                                                           AND ( cl1.clase = 1 )
                                                           AND ( cl1.codigo = d.codadd01 )
            LEFT OUTER JOIN cliente_articulos_clase     cl2 ON cl2.id_cia = a.id_cia
                                                           AND ( cl2.tipcli = 'B' )
                                                           AND ( cl2.codcli = a.codprv )
                                                           AND ( cl2.clase = 2 )
                                                           AND ( cl2.codigo = d.codadd02 )
            LEFT OUTER JOIN tmoneda                     m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN documentos_clase            dc2 ON dc2.id_cia = c.id_cia
                                                    AND dc2.codigo = c.tipdoc
                                                    AND dc2.series = c.series
                                                    AND dc2.clase = 14
            LEFT OUTER JOIN documentos_clase            dc3 ON dc3.id_cia = c.id_cia
                                                    AND dc3.codigo = c.tipdoc
                                                    AND dc3.series = c.series
                                                    AND dc3.clase = 15
            LEFT OUTER JOIN companias_glosa             gar ON ( gar.id_cia = c.id_cia )
                                                   AND ( far.vstrg IS NOT NULL )
                                                   AND ( upper(far.vstrg) = 'S' )
                                                   AND ( gar.item = 15 )
            LEFT OUTER JOIN companias_glosa             gap ON ( gap.id_cia = c.id_cia )
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( gap.item = 13 )
            LEFT OUTER JOIN companias_glosa             gfp ON ( gfp.id_cia = c.id_cia )
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( dcp.codigo IS NOT NULL )
                                                   AND ( upper(dcp.codigo) = 'S' )
                                                   AND ( gfp.item = 14 )
            LEFT OUTER JOIN articulos_clase_alternativo aca1 ON aca1.id_cia = d.id_cia
                                                                AND aca1.tipinv = d.tipinv
                                                                AND aca1.codart = d.codart
                                                                AND aca1.clase = 1
                                                                AND aca1.codigo = d.codund
            LEFT OUTER JOIN articulos_clase             ac5 ON ac5.id_cia = d.id_cia
                                                   AND ( ac5.tipinv = d.tipinv )
                                                   AND ( ac5.codart = d.codart )
                                                   AND ( ac5.clase = 87 )
            LEFT OUTER JOIN documentos_situac_max       sv ON sv.id_cia = c.id_cia
                                                        AND sv.numint = c.numint
                                                        AND sv.situac = 'B'
            LEFT OUTER JOIN usuarios                    uv ON uv.id_cia = sv.id_cia
                                           AND uv.coduser = sv.usuari
            LEFT OUTER JOIN documentos_situac_max       se ON se.id_cia = c.id_cia
                                                        AND se.numint = c.numint
                                                        AND se.situac = 'A'
            LEFT OUTER JOIN usuarios                    ue ON ue.id_cia = se.id_cia
                                           AND ue.coduser = se.usuari
            LEFT OUTER JOIN documentos_aprobacion       dap ON dap.id_cia = c.id_cia
                                                         AND dap.numint = c.numint
            LEFT OUTER JOIN usuarios                    ua ON ua.id_cia = dap.id_cia
                                           AND ua.coduser = dap.uactua
        WHERE
            ( c.id_cia = pin_id_cia )
            AND ( c.numint = pin_numint )
        ORDER BY
            c.tipdoc,
            c.numint,
            d.positi,
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_pedido;

END pack_documentos_cab;

/
