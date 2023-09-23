--------------------------------------------------------
--  DDL for Package Body PACK_ETIQUETAS_TSIPRINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ETIQUETAS_TSIPRINT" AS
    FUNCTION sp_info_cliente (
        pin_id_cia  NUMBER,
        pin_codcli  VARCHAR2
    ) RETURN datatable_info_cliente
        PIPELINED
    AS
        v_table datatable_info_cliente;
    BEGIN
        SELECT
            codcli,
            razonc
        BULK COLLECT
        INTO v_table
        FROM
            cliente
        WHERE
                id_cia = pin_id_cia
            AND codcli = pin_codcli;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

    END sp_info_cliente;

    FUNCTION sp_info_guia (
        pin_id_cia  NUMBER,
        pin_numdoc  NUMBER
    ) RETURN datatable_info_guia
        PIPELINED
    AS
        v_table datatable_info_guia;
    BEGIN
        SELECT
            numint,
            razonc,
            codcli
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab
        WHERE
                id_cia = pin_id_cia
            AND tipdoc = 103
            AND situac IN (
                'A',
                'F',
                'E',
                'G',
                'H'
            )
            AND id = 'I'
            AND codmot IN (
                1,
                28,
                6,
                7,
                8
            )
            AND numdoc = pin_numdoc;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

    END sp_info_guia;

    PROCEDURE sp_insertar_etiquetas (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   IN   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) AS
        o              json_object_t;
        rec_etiquetas  kardex001_impr%rowtype;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_etiquetas.id_cia := pin_id_cia;
        rec_etiquetas.tipinv := o.get_number('tipinv');
        rec_etiquetas.codart := o.get_string('codart');
        rec_etiquetas.etiqueta := o.get_string('etiqueta');
        rec_etiquetas.coment := o.get_string('coment');
        rec_etiquetas.coduser := o.get_string('coduser');
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO kardex001_impr (
                    id_cia,
                    tipinv,
                    codart,
                    etiqueta,
                    fcreac,
                    coduser,
                    coment
                ) VALUES (
                    pin_id_cia,
                    rec_etiquetas.tipinv,
                    rec_etiquetas.codart,
                    rec_etiquetas.etiqueta,
                    current_timestamp,
                    rec_etiquetas.coduser,
                    rec_etiquetas.coment
                );

        END CASE;

        SELECT
            JSON_OBJECT (
                'status' VALUE 1.0,
                'message' VALUE 'La inserción' || ' se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN dup_val_on_index THEN
--            SELECT
--                JSON_OBJECT(
--                    'status' VALUE 1.1,
--                    'message' VALUE 'El registro con codigo de AFP [ '
--                                    || rec_afp.codafp
--                                    || ' ] ya existe y no puede duplicarse ...!'
--                )
--            INTO pin_mensaje
--            FROM
--                dual;
            NULL;
    END sp_insertar_etiquetas;

FUNCTION sp_buscar_tipo_etiqueta (
    pin_id_cia      NUMBER,
    pin_tipinv      NUMBER,
    pin_codart      VARCHAR2,
    pin_etiqueta01  VARCHAR2,
    pin_etiqueta02  VARCHAR2
) RETURN datatable_tipo_guiainterna
    PIPELINED
AS
    v_table datatable_tipo_guiainterna;
BEGIN IF
    pin_etiqueta01 IS NOT NULL AND pin_etiqueta01 IS NOT NULL
        THEN SELECT
         k1.numint,
         k1.numite,
         dc.series,
         dc.numdoc,
         a.descri                                AS desart,
         k1.tipinv,
         k1.codart,
         k1.etiqueta,
         k1.lote,
         k1.codadd01,
         k1.codadd02,
         dc.codcli,
         dc.razonc,
         ( k1.ingreso - k1.salida )              AS cantid,
         k1.ubica,
         au.descri                               AS desubica,
         dc.femisi,
         k1.nrocarrete,
         k1.combina,
         k1.empalme,
         ce.vstrg                                AS prvabv,
         k1.ancho,
         k1.largo,
         dc.ordcom,
         dc.facpro,
         dc.numped,
         CAST(dp.femisi AS VARCHAR(10))          fimporta,
         k1.diseno,
         k1.acabado,
         k1.codalm,
         al.descri                               AS desalm,
         ca1.descri                              AS desadd01,
         ca2.descri                              AS desadd02,
         en.codigo                               AS codenc,
         u.abrevi                                AS abreviuni,
         (
             SELECT
                 coalesce(COUNT(0), 0)
             FROM
                 kardex001_impr
             WHERE
                     id_cia = k1.id_cia
                 AND tipinv = k1.tipinv
                 AND codart = k1.codart
                 AND etiqueta = k1.etiqueta
         ) AS swimpr,
         NULL                                    AS desclase3,
         NULL                                    AS desclase6,
         ac8.codigo                              AS codcapmega,
         cc8.descri                              AS descapmega,
         ac13.codigo                             AS codcappro,
         cc13.descri                             AS descappro,
         cc91.codigo                             AS codclase91,
         cc91.descodigo                          AS desresmingar,
         cc93.codigo                             AS codclase93,
         cc93.descodigo                          AS desmaterial,
         cc96.codigo                             AS codclase96,
         cc96.descodigo                          AS desfactordis,
         cc97.codigo                             AS codclase97,
         cc97.descodigo                          AS desanchocin,
         cc98.codigo                             AS codclase98,
         cc98.descodigo                          AS descolorcin,
         cc92.descodigo                          AS capaciver,
         cc100.descodigo                         AS capacienu,
         cc102.descodigo                         AS capacilaz,
         ''                                      AS numerocert,
         0                                       AS cert_agrupa,
         0                                       AS cert_periodo,
         0                                       AS cert_numero,
         0                                       AS usocantid,
         ''                                      AS razonccert,
         ''                                      AS tipo_terminal,
         ''                                      AS abrevi_tipo_terminal,
         ''                                      AS nro_orcom,
         0                                       AS nro_ramales,
         0                                       AS capacidad60,
         0                                       AS capacidad45,
         0                                       AS capacidad30,
         ''                                      AS serie_op,
         0                                       AS numdoc_op,
         k1.cantid_ori,
         NULL                                    AS positi_op

--         cer.agrupa
--         || '' - ''
--         || cer.periodo
--         || '' - ''
--         || cer.numero AS numerocert,
--         cer.agrupa                              AS cert_agrupa,
--         cer.periodo                             AS cert_periodo,
--         cer.numero                              AS cert_numero,
--         cec.usocantid,
--         NULL                                    AS razonccert,
--         NULL                                    AS tipo_terminal,
--         NULL                                    AS abrevi_tipo_terminal,
--         dco.numero                              AS nro_orcom,
--         ddc.ventero                             AS nro_ramales,
--         ddc08.vreal                             AS capacidad60,
--         ddc09.vreal                             AS capacidad45,
--         ddc10.vreal                             AS capacidad30,
--         dpr.series                              AS serie_op,
--         dpr.numdoc                              AS numdoc_op,
--         k1.cantid_ori,
--         NULL                                    AS positi_op 
     BULK COLLECT
     INTO v_table
     FROM
         kardex001             k1
         LEFT OUTER JOIN documentos_cab        dc ON dc.id_cia = k1.id_cia
                                              AND dc.numint = k1.numint
         LEFT OUTER JOIN documentos_cab_clase  en ON en.id_cia = k1.id_cia
                                                    AND en.numint = dc.numint
                                                    AND en.clase = 10
         LEFT OUTER JOIN pack_trazabilidad.sp_trazabilidad( k1.id_cia, dc.numint)             sp ON 1 = 1
                                                                                              AND sp.tipdoc = 115
                LEFT OUTER JOIN documentos_cab                                                      dp ON dp.id_cia = k1.id_cia
                                                     AND dp.numint = sp.numint
                LEFT OUTER JOIN documentos_det                                                      d ON d.id_cia = k1.id_cia
                                                    AND d.numint = k1.numint
                                                    AND d.numite = k1.numite
                INNER JOIN articulos                                                           a ON a.id_cia = k1.id_cia
                                          AND a.tipinv = k1.tipinv
                                          AND a.codart = k1.codart
                LEFT OUTER JOIN almacen                                                             al ON al.id_cia = k1.id_cia
                                              AND al.tipinv = d.tipinv
                                              AND al.codalm = k1.codalm
                LEFT OUTER JOIN unidad                                                              u ON u.id_cia = k1.id_cia
                                            AND u.coduni = a.coduni
                LEFT OUTER JOIN almacen_ubicacion                                                   au ON au.id_cia = k1.id_cia
                                                        AND au.tipinv = d.tipinv
                                                        AND au.codalm = k1.codalm
                                                        AND au.codigo = k1.ubica
                LEFT OUTER JOIN clientes_especificacion                                             ce ON ce.id_cia = k1.id_cia
                                                              AND ce.tipcli = 'B'
                                                              AND ce.codcli = a.codprv
                                                              AND ce.codesp = 3
                LEFT OUTER JOIN cliente_articulos_clase                                             ca1 ON ca1.id_cia = k1.id_cia
                                                               AND ca1.tipcli = 'B'
                                                               AND ca1.codcli = a.codprv
                                                               AND ca1.clase = 1
                                                               AND ca1.codigo = k1.codadd01
                LEFT OUTER JOIN cliente_articulos_clase                                             ca2 ON ca2.id_cia = k1.id_cia
                                                               AND ca2.tipcli = 'B'
                                                               AND ca2.codcli = a.codprv
                                                               AND ca2.clase = 2
                                                               AND ca2.codigo = k1.codadd02
                LEFT OUTER JOIN articulos_clase                                                     ac8 ON ac8.id_cia = k1.id_cia
                                                       AND ac8.tipinv = a.tipinv
                                                       AND ac8.codart = a.codart
                                                       AND ac8.clase = 8
                LEFT OUTER JOIN clase_codigo                                                        cc8 ON cc8.id_cia = k1.id_cia
                                                    AND cc8.tipinv = ac8.tipinv
                                                    AND cc8.clase = ac8.clase
                                                    AND cc8.codigo = ac8.codigo
                LEFT OUTER JOIN articulos_clase                                                     ac13 ON ac13.id_cia = k1.id_cia
                                                        AND ac13.tipinv = a.tipinv
                                                        AND ac13.codart = a.codart
                                                        AND ac13.clase = 13
                LEFT OUTER JOIN clase_codigo                                                        cc13 ON cc13.id_cia = k1.id_cia
                                                     AND cc13.tipinv = ac13.tipinv
                                                     AND cc13.clase = ac13.clase
                                                     AND cc13.codigo = ac13.codigo
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, a.tipinv, a.codart, 91)         cc91 ON 0 = 0
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, d.tipinv, d.codart, 92)         cc92 ON 0 = 0
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, a.tipinv, a.codart, 93)         cc93 ON 0 = 0
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, d.tipinv, d.codart, 96)         cc96 ON 0 = 0
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, d.tipinv, d.codart, 97)         cc97 ON 0 = 0
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, d.tipinv, d.codart, 98)         cc98 ON 0 = 0
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, d.tipinv, d.codart, 100)        cc100 ON 0 = 0
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, d.tipinv, d.codart, 102)        cc102 ON 0 = 0    
--                LEFT OUTER JOIN pack_trazabilidad.sp_trazabilidad_tipdoc(k1.id_cia, k1.numint, 104) tr ON 0 = 0
--                LEFT OUTER JOIN documentos_cab_ordcom                                               dco ON dco.id_cia = k1.id_cia
--                                                             AND dco.numint = tr.numint
--                LEFT OUTER JOIN documentos_cab                                                      dpr ON dpr.id_cia = k1.id_cia
--                                                      AND dpr.numint = tr.numint
--                LEFT OUTER JOIN certificadocal_det                                                  cer ON cer.id_cia = k1.id_cia
--                                                          AND cer.etiqueta = k1.etiqueta
--                LEFT OUTER JOIN certificadocal_cab                                                  cec ON cec.id_cia = k1.id_cia
--                                                          AND cec.numint = cer.numint
--                LEFT OUTER JOIN documentos_det_clase                                                ddc ON ddc.id_cia = k1.id_cia
--                                                            AND ddc.numint = k1.numint
--                                                            AND ddc.numite = k1.numite
--                                                            AND ddc.clase = 4
--                LEFT OUTER JOIN documentos_det_clase                                                ddc08 ON ddc08.id_cia = k1.id_cia
--                                                              AND ddc08.numint = k1.numint
--                                                              AND ddc08.numite = k1.numite
--                                                              AND ddc08.clase = 8
--                LEFT OUTER JOIN documentos_det_clase                                                ddc09 ON ddc09.id_cia = k1.id_cia
--                                                              AND ddc09.numint = k1.numint
--                                                              AND ddc09.numite = k1.numite
--                                                              AND ddc09.clase = 9
--                LEFT OUTER JOIN documentos_det_clase                                                ddc10 ON ddc10.id_cia = k1.id_cia
--                                                              AND ddc10.numint = k1.numint
--                                                              AND ddc10.numite = k1.numite
--                                                              AND ddc10.clase = 10
            WHERE
                    k1.id_cia = pin_id_cia
                AND ( k1.ingreso - k1.salida ) <> 0
                AND k1.tipinv = pin_tipinv
                AND ( ( pin_codart IS NULL )
                      OR ( k1.codart = pin_codart ) )
                AND ( k1.etiqueta BETWEEN pin_etiqueta01 AND pin_etiqueta02 );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        ELSE
            SELECT
                k1.numint,
                k1.numite,
                dc.series,
                dc.numdoc,
                a.descri                       AS desart,
                k1.tipinv,
                k1.codart,
                k1.etiqueta,
                k1.lote,
                k1.codadd01,
                k1.codadd02,
                dc.codcli,
                dc.razonc,
                ( k1.ingreso - k1.salida )     AS cantid,
                k1.ubica,
                au.descri                      AS desubica,
                dc.femisi,
                k1.nrocarrete,
                k1.combina,
                k1.empalme,
                ce.vstrg                       AS prvabv,
                k1.ancho,
                k1.largo,
                dc.ordcom,
                dc.facpro,
                dc.numped,
                CAST(dp.femisi AS VARCHAR(10)) fimporta,
                k1.diseno,
                k1.acabado,
                k1.codalm,
                al.descri                      AS desalm,
                ca1.descri                     AS desadd01,
                ca2.descri                     AS desadd02,
                en.codigo                      AS codenc,
                u.abrevi                       AS abreviuni,
                (
                    SELECT
                        coalesce(COUNT(0), 0)
                    FROM
                        kardex001_impr
                    WHERE
                            id_cia = k1.id_cia
                        AND tipinv = k1.tipinv
                        AND codart = k1.codart
                        AND etiqueta = k1.etiqueta
                )                              AS swimpr,
                NULL                           AS desclase3,
                NULL                           AS desclase6,
                ac8.codigo                     AS codcapmega,
                cc8.descri                     AS descapmega,
                ac13.codigo                    AS codcappro,
                cc13.descri                    AS descappro,
                cc91.codigo                    AS codclase91,
                cc91.descodigo                 AS desresmingar,
                cc93.codigo                    AS codclase93,
                cc93.descodigo                 AS desmaterial,
                cc96.codigo                    AS codclase96,
                cc96.descodigo                 AS desfactordis,
                cc97.codigo                    AS codclase97,
                cc97.descodigo                 AS desanchocin,
                cc98.codigo                    AS codclase98,
                cc98.descodigo                 AS descolorcin,
                cc92.descodigo                 AS capaciver,
                cc100.descodigo                AS capacienu,
                cc102.descodigo                AS capacilaz,
                cer.agrupa
                || '' - ''
                || cer.periodo
                || '' - ''
                || cer.numero                  AS numerocert,
                cer.agrupa                     AS cert_agrupa,
                cer.periodo                    AS cert_periodo,
                cer.numero                     AS cert_numero,
                cec.usocantid,
                NULL                           AS razonccert,
                NULL                           AS tipo_terminal,
                NULL                           AS abrevi_tipo_terminal,
                dco.numero                     AS nro_orcom,
                ddc.ventero                    AS nro_ramales,
                ddc08.vreal                    AS capacidad60,
                ddc09.vreal                    AS capacidad45,
                ddc10.vreal                    AS capacidad30,
                dpr.series                     AS serie_op,
                dpr.numdoc                     AS numdoc_op,
                k1.cantid_ori,
                NULL                           AS positi_op
            BULK COLLECT
            INTO v_table
            FROM
                kardex001                                                           k1
                LEFT OUTER JOIN documentos_cab                                                      dc ON dc.id_cia = k1.id_cia
                                                     AND dc.numint = k1.numint
                LEFT OUTER JOIN documentos_cab_clase                                                en ON en.id_cia = k1.id_cia
                                                           AND en.numint = dc.numint
                                                           AND en.clase = 10
                LEFT OUTER JOIN pack_trazabilidad.sp_trazabilidad(k1.id_cia, dc.numint)             sp ON 1 = 1
                                                                                              AND sp.tipdoc = 115
                LEFT OUTER JOIN documentos_cab                                                      dp ON dp.id_cia = k1.id_cia
                                                     AND dp.numint = sp.numint
                LEFT OUTER JOIN documentos_det                                                      d ON d.id_cia = k1.id_cia
                                                    AND d.numint = k1.numint
                                                    AND d.numite = k1.numite
                INNER JOIN articulos                                                           a ON a.id_cia = k1.id_cia
                                          AND a.tipinv = k1.tipinv
                                          AND a.codart = k1.codart
                LEFT OUTER JOIN almacen                                                             al ON al.id_cia = k1.id_cia
                                              AND al.tipinv = d.tipinv
                                              AND al.codalm = k1.codalm
                LEFT OUTER JOIN unidad                                                              u ON u.id_cia = k1.id_cia
                                            AND u.coduni = a.coduni
                LEFT OUTER JOIN almacen_ubicacion                                                   au ON au.id_cia = k1.id_cia
                                                        AND au.tipinv = d.tipinv
                                                        AND au.codalm = k1.codalm
                                                        AND au.codigo = k1.ubica
                LEFT OUTER JOIN clientes_especificacion                                             ce ON ce.id_cia = k1.id_cia
                                                              AND ce.tipcli = 'B'
                                                              AND ce.codcli = a.codprv
                                                              AND ce.codesp = 3
                LEFT OUTER JOIN cliente_articulos_clase                                             ca1 ON ca1.id_cia = k1.id_cia
                                                               AND ca1.tipcli = 'B'
                                                               AND ca1.codcli = a.codprv
                                                               AND ca1.clase = 1
                                                               AND ca1.codigo = k1.codadd01
                LEFT OUTER JOIN cliente_articulos_clase                                             ca2 ON ca2.id_cia = k1.id_cia
                                                               AND ca2.tipcli = 'B'
                                                               AND ca2.codcli = a.codprv
                                                               AND ca2.clase = 2
                                                               AND ca2.codigo = k1.codadd02
                LEFT OUTER JOIN articulos_clase                                                     ac8 ON ac8.id_cia = k1.id_cia
                                                       AND ac8.tipinv = a.tipinv
                                                       AND ac8.codart = a.codart
                                                       AND ac8.clase = 8
                LEFT OUTER JOIN clase_codigo                                                        cc8 ON cc8.id_cia = k1.id_cia
                                                    AND cc8.tipinv = ac8.tipinv
                                                    AND cc8.clase = ac8.clase
                                                    AND cc8.codigo = ac8.codigo
                LEFT OUTER JOIN articulos_clase                                                     ac13 ON ac13.id_cia = k1.id_cia
                                                        AND ac13.tipinv = a.tipinv
                                                        AND ac13.codart = a.codart
                                                        AND ac13.clase = 13
                LEFT OUTER JOIN clase_codigo                                                        cc13 ON cc13.id_cia = k1.id_cia
                                                     AND cc13.tipinv = ac13.tipinv
                                                     AND cc13.clase = ac13.clase
                                                     AND cc13.codigo = ac13.codigo
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, a.tipinv, a.codart, 91)         cc91 ON 0 = 0
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, d.tipinv, d.codart, 92)         cc92 ON 0 = 0
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, a.tipinv, a.codart, 93)         cc93 ON 0 = 0
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, d.tipinv, d.codart, 96)         cc96 ON 0 = 0
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, d.tipinv, d.codart, 97)         cc97 ON 0 = 0
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, d.tipinv, d.codart, 98)         cc98 ON 0 = 0
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, d.tipinv, d.codart, 100)        cc100 ON 0 = 0
                LEFT OUTER JOIN sp_select_articulo_clase(k1.id_cia, d.tipinv, d.codart, 102)        cc102 ON 0 = 0
                LEFT OUTER JOIN pack_trazabilidad.sp_trazabilidad_tipdoc(k1.id_cia, k1.numint, 104) tr ON 0 = 0
                LEFT OUTER JOIN documentos_cab_ordcom                                               dco ON dco.id_cia = k1.id_cia
                                                             AND dco.numint = tr.numint
                LEFT OUTER JOIN documentos_cab                                                      dpr ON dpr.id_cia = k1.id_cia
                                                      AND dpr.numint = tr.numint
                LEFT OUTER JOIN certificadocal_det                                                  cer ON cer.id_cia = k1.id_cia
                                                          AND cer.etiqueta = k1.etiqueta
                LEFT OUTER JOIN certificadocal_cab                                                  cec ON cec.id_cia = k1.id_cia
                                                          AND cec.numint = cer.numint
                LEFT OUTER JOIN documentos_det_clase                                                ddc ON ddc.id_cia = k1.id_cia
                                                            AND ddc.numint = k1.numint
                                                            AND ddc.numite = k1.numite
                                                            AND ddc.clase = 4
                LEFT OUTER JOIN documentos_det_clase                                                ddc08 ON ddc08.id_cia = k1.id_cia
                                                              AND ddc08.numint = k1.numint
                                                              AND ddc08.numite = k1.numite
                                                              AND ddc08.clase = 8
                LEFT OUTER JOIN documentos_det_clase                                                ddc09 ON ddc09.id_cia = k1.id_cia
                                                              AND ddc09.numint = k1.numint
                                                              AND ddc09.numite = k1.numite
                                                              AND ddc09.clase = 9
                LEFT OUTER JOIN documentos_det_clase                                                ddc10 ON ddc10.id_cia = k1.id_cia
                                                              AND ddc10.numint = k1.numint
                                                              AND ddc10.numite = k1.numite
                                                              AND ddc10.clase = 10
            WHERE
                    k1.id_cia = pin_id_cia
                AND ( k1.ingreso - k1.salida ) <> 0
                AND k1.tipinv = pin_tipinv
                AND ( ( pin_codart IS NULL )
                      OR ( k1.codart = pin_codart ) )
                AND ( k1.etiqueta = pin_etiqueta01 );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        END IF;
    END sp_buscar_tipo_etiqueta;

    FUNCTION sp_buscar_tipo_tomainventario (
        pin_id_cia   NUMBER,
        pin_numint   NUMBER,
        pin_codadd01 VARCHAR2,
        pin_codadd02 VARCHAR2,
        pin_ubica    VARCHAR2
    ) RETURN datatable_tipo_guiainterna
        PIPELINED
    AS
        v_table datatable_tipo_guiainterna;
    BEGIN
        SELECT
            d.numint,
            d.numite,
            d.series,
            dc.numdoc,
            a.descri        AS desart,
            d.tipinv,
            d.codart,
            d.etiqueta,
            d.lote,
            d.codadd01,
            d.codadd02,
            dc.codcli,
            dc.razonc,
            d.cantid,
            d.ubica,
            au.descri       AS desubica,
            dc.femisi,
            d.nrocarrete,
            d.combina,
            d.empalme,
            ce.vstrg        AS prvabv,
            d.ancho,
            d.largo,
            dc.ordcom,
            NULL            AS facpro, --NO
            NULL            AS numped, --NO
            NULL            AS fimporta,--NO
            d.diseno,
            d.acabado,
            d.codalm,
            al.descri       AS desalm,
            ca1.descri      AS desadd01,
            ca2.descri      AS desadd02,
            en.codigo       AS codenc,
            u.abrevi        AS abreviuni,
            (
                SELECT
                    coalesce(COUNT(0), 0)
                FROM
                    kardex001_impr
                WHERE
                        id_cia = d.id_cia
                    AND tipinv = d.tipinv
                    AND codart = d.codart
                    AND etiqueta = d.etiqueta
            )               AS swimpr,
            NULL            AS desclase3,
            NULL            AS desclase6,
            ac8.codigo      AS codcapmega,
            cc8.descri      AS descapmega,
            ac13.codigo     AS codcappro,
            cc13.descri     AS descappro,
            cc91.codigo     AS codclase91,
            cc91.descodigo  AS desresmingar,
            cc93.codigo     AS codclase93,
            cc93.descodigo  AS desmaterial,
            cc96.codigo     AS codclase96,
            cc96.descodigo  AS desfactordis,
            cc97.codigo     AS codclase97,
            cc97.descodigo  AS desanchocin,
            cc98.codigo     AS codclase98,
            cc98.descodigo  AS descolorcin,
            cc92.descodigo  AS capaciver,
            cc100.descodigo AS capacienu,
            cc102.descodigo AS capacilaz,
            '' AS numerocert,
            0 AS cert_agrupa,
            0 AS cert_periodo,
            0 AS cert_numero,
            0 as usocantid,
            '' AS razonccert,
            '' AS tipo_terminal,
            '' AS abrevi_tipo_terminal,
            '' AS nro_orcom,
            0 AS nro_ramales,
            0 AS capacidad60,
            0 AS capacidad45,
            0 AS capacidad30,
            '' AS serie_op,
            0  AS numdoc_op,
            NULL            AS cantid_ori,
            NULL            AS positi_op           
--            cer.agrupa
--            || '-'
--            || cer.periodo
--            || '-'
--            || cer.numero   AS numerocert,
--            cer.agrupa      AS cert_agrupa,
--            cer.periodo     AS cert_periodo,
--            cer.numero      AS cert_numero,
--            cec.usocantid,
--            NULL            AS razonccert,
--            NULL            AS tipo_terminal,
--            NULL            AS abrevi_tipo_terminal,
--            dco.numero      AS nro_orcom,
--            ddc.ventero     AS nro_ramales,
--            ddc08.vreal     AS capacidad60,
--            ddc09.vreal     AS capacidad45,
--            ddc10.vreal     AS capacidad30,
--            dpr.series      AS serie_op,
--            dpr.numdoc      AS numdoc_op,
--            NULL            AS cantid_ori,
--            NULL            AS positi_op            

        BULK COLLECT
        INTO v_table
        FROM
            documentos_det                                                    d
            LEFT OUTER JOIN documentos_cab                                                    dc ON dc.id_cia = d.id_cia
                                                 AND dc.numint = d.numint
            LEFT OUTER JOIN documentos_cab_clase                                              en ON en.id_cia = d.id_cia
                                                       AND en.numint = dc.numint
                                                       AND en.clase = 10 /*ENCARGADO*/
            LEFT OUTER JOIN almacen                                                           al ON al.id_cia = d.id_cia
                                          AND al.tipinv = d.tipinv
                                          AND al.codalm = d.codalm
            LEFT OUTER JOIN almacen_ubicacion                                                 au ON au.id_cia = d.id_cia
                                                    AND au.tipinv = d.tipinv
                                                    AND au.codalm = d.codalm
                                                    AND au.codigo = d.ubica
            LEFT OUTER JOIN clientes_especificacion                                           ce ON ce.id_cia = d.id_cia
                                                          AND ce.tipcli = 'B'
                                                          AND ce.codcli = dc.codcli
                                                          AND ce.codesp = 3
            LEFT OUTER JOIN documentos_det_clase                                              dc1 ON dc1.id_cia = d.id_cia
                                                        AND dc1.numint = d.numint
                                                        AND dc1.numite = d.numite
                                                        AND dc1.clase = 1
                                                        AND dc.tipdoc = 111 /*GUIA TOMA DE INVENTARIO*/
            INNER JOIN articulos                                                         a ON a.id_cia = d.id_cia
                                      AND a.tipinv = d.tipinv
                                      AND a.codart = d.codart
            LEFT OUTER JOIN unidad                                                            u ON u.id_cia = d.id_cia
                                        AND u.coduni = a.coduni
            LEFT OUTER JOIN cliente_articulos_clase                                           ca1 ON ca1.id_cia = d.id_cia
                                                           AND ca1.tipcli = 'B'
                                                           AND ca1.codcli = a.codprv
                                                           AND ca1.clase = 1
                                                           AND ca1.codigo = d.codadd01
            LEFT OUTER JOIN cliente_articulos_clase                                           ca2 ON ca2.id_cia = d.id_cia
                                                           AND ca2.tipcli = 'B'
                                                           AND ca2.codcli = a.codprv
                                                           AND ca2.clase = 2
                                                           AND ca2.codigo = d.codadd02
            LEFT OUTER JOIN articulos_clase                                                   ac8 ON ac8.id_cia = d.id_cia
                                                   AND ac8.tipinv = a.tipinv
                                                   AND ac8.codart = a.codart
                                                   AND ac8.clase = 8
            LEFT OUTER JOIN clase_codigo                                                      cc8 ON cc8.id_cia = d.id_cia
                                                AND cc8.tipinv = ac8.tipinv
                                                AND cc8.clase = ac8.clase
                                                AND cc8.codigo = ac8.codigo
            LEFT OUTER JOIN articulos_clase                                                   ac13 ON ac13.id_cia = d.id_cia
                                                    AND ac13.tipinv = a.tipinv
                                                    AND ac13.codart = a.codart
                                                    AND ac13.clase = 13
            LEFT OUTER JOIN clase_codigo                                                      cc13 ON cc13.id_cia = d.id_cia
                                                 AND cc13.tipinv = ac13.tipinv
                                                 AND cc13.clase = ac13.clase
                                                 AND cc13.codigo = ac13.codigo
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, a.tipinv, a.codart, 91)        cc91 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 92)        cc92 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, a.tipinv, a.codart, 93)        cc93 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 96)        cc96 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 97)        cc97 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 98)        cc98 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 100)       cc100 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 102)       cc102 ON 0 = 0
--            LEFT OUTER JOIN pack_trazabilidad.sp_trazabilidad_tipdoc(d.id_cia, d.numint, 104) tr ON 0 = 0
--            LEFT OUTER JOIN documentos_cab_ordcom                                             dco ON dco.id_cia = d.id_cia
--                                                         AND dco.numint = tr.numint
--            LEFT OUTER JOIN documentos_cab                                                    dpr ON dpr.id_cia = d.id_cia
--                                                  AND dpr.numint = tr.numint
--            LEFT OUTER JOIN certificadocal_det                                                cer ON cer.id_cia = d.id_cia
--                                                      AND cer.etiqueta = d.etiqueta
--            LEFT OUTER JOIN certificadocal_cab                                                cec ON cec.id_cia = d.id_cia
--                                                      AND cec.numint = cer.numint
--            LEFT OUTER JOIN documentos_det_clase                                              ddc ON ddc.id_cia = d.id_cia
--                                                        AND ddc.numint = d.numint
--                                                        AND ddc.numite = d.numite
--                                                        AND ddc.clase = 4
--            LEFT OUTER JOIN documentos_det_clase                                              ddc08 ON ddc08.id_cia = d.id_cia
--                                                          AND ddc08.numint = d.numint
--                                                          AND ddc08.numite = d.numite
--                                                          AND ddc08.clase = 8
--            LEFT OUTER JOIN documentos_det_clase                                              ddc09 ON ddc09.id_cia = d.id_cia
--                                                          AND ddc09.numint = d.numint
--                                                          AND ddc09.numite = d.numite
--                                                          AND ddc09.clase = 9
--            LEFT OUTER JOIN documentos_det_clase                                              ddc10 ON ddc10.id_cia = d.id_cia
--                                                          AND ddc10.numint = d.numint
--                                                          AND ddc10.numite = d.numite
--                                                          AND ddc10.clase = 10    

        WHERE
                d.id_cia = pin_id_cia
            AND d.numint = pin_numint
            AND ( d.etiqueta IS NOT NULL )
            --AND ( d.etiqueta <> '' )
            AND ( length(TRIM(d.etiqueta)) > 0 )
            AND ( ( pin_codadd01 IS NULL )
                  OR ( d.codadd01 = pin_codadd01 ) )
            AND ( ( pin_codadd02 IS NULL )
                  OR ( d.codadd02 = pin_codadd02 ) )
            AND ( ( pin_ubica IS NULL )
                  OR ( d.ubica = pin_ubica ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

    END sp_buscar_tipo_tomainventario;

    FUNCTION sp_buscar_tipo_guiainterna (
        pin_id_cia   NUMBER,
        pin_numint   NUMBER,
        pin_codadd01 VARCHAR2,
        pin_codadd02 VARCHAR2,
        pin_ubica    VARCHAR2
    ) RETURN datatable_tipo_guiainterna
        PIPELINED
    AS
        v_table datatable_tipo_guiainterna;
    BEGIN
        SELECT
            d.numint,
            d.numite,
            d.series,
            dc.numdoc,
            a.descri                                              AS desart,
            d.tipinv,
            d.codart,
            d.etiqueta,
            d.lote,
            d.codadd01,
            d.codadd02,
            dc.codcli,
            dc.razonc,
            d.cantid,
            d.ubica,
            au.descri                                             AS desubica,
            dc.femisi,
            d.nrocarrete,
            d.combina,
            d.empalme,
            ce.vstrg                                              AS prvabv,
            d.ancho,
            d.largo,
            dc.ordcom,
            dc.facpro,
            dc.numped,
            CAST(to_char(dp.femisi, 'DD/MM/YYYY') AS VARCHAR(10)) fimporta,
            d.diseno,
            d.acabado,
            d.codalm,
            al.descri                                             AS desalm,
            ca1.descri                                            AS desadd01,
            ca2.descri                                            AS desadd02,
            en.codigo                                             AS codenc,
            u.abrevi                                              AS abreviuni,
            (
                SELECT
                    coalesce(COUNT(0), 0)
                FROM
                    kardex001_impr
                WHERE
                        id_cia = d.id_cia
                    AND tipinv = d.tipinv
                    AND codart = d.codart
                    AND etiqueta = d.etiqueta
            )                                                     AS swimpr,
            cc3.descodigo                                         AS desclase3,
            cc6.descodigo                                         AS desclase6,
            cc8.codigo                                            AS codcapmega,
            cc8.descodigo                                         AS descapmega,
            cc13.codigo                                           AS codcappro,
            cc13.descodigo                                        AS descappro,
            cc91.codigo                                           AS codclase91,
            cc91.descodigo                                        AS desresmingar,
            cc93.codigo                                           AS codclase93,
            cc93.descodigo                                        AS desmaterial,
            cc96.codigo                                           AS codclase96,
            cc96.descodigo                                        AS desfactordis,
            cc97.codigo                                           AS codclase97,
            cc97.descodigo                                        AS desanchocin,
            cc98.codigo                                           AS codclase98,
            cc98.descodigo                                        AS descolorcin,
            cc92.descodigo                                        AS capaciver,
            cc100.descodigo                                       AS capacienu,
            cc102.descodigo                                       AS capacilaz,
            '' AS numerocert,
            0 AS cert_agrupa,
            0 AS cert_periodo,
            0 AS cert_numero,
            0 as usocantid,
            '' AS razonccert,
            '' AS tipo_terminal,
            '' AS abrevi_tipo_terminal,
            '' AS nro_orcom,
            0 AS nro_ramales,
            0 AS capacidad60,
            0 AS capacidad45,
            0 AS capacidad30,
            '' AS serie_op,
            0  AS numdoc_op,
            NULL AS cantid_ori,
            0  AS positi_op                    
--            cer.agrupa
--            || '-'
--            || cer.periodo
--            || '-'
--            || cer.numero                                         AS numerocert,
--            cer.agrupa                                            AS cert_agrupa,
--            cer.periodo                                           AS cert_periodo,
--            cer.numero                                            AS cert_numero,
--            cec.usocantid,
--            cle.razonc                                            AS razonccert,
--            dct1.descri                                           AS tipo_terminal,
--            dct1.abrevi                                           AS abrevi_tipo_terminal,
--            dco.numero                                            AS nro_orcom,
--            ddc.ventero                                           AS nro_ramales,
--            ddc08.vreal                                           AS capacidad60,
--            ddc09.vreal                                           AS capacidad45,
--            ddc10.vreal                                           AS capacidad30,
--            dpr.series                                            AS serie_op,
--            dpr.numdoc                                            AS numdoc_op,
--            NULL                                                  AS cantid_ori,
--            dcpr.positi                                           AS positi_op
        BULK COLLECT
        INTO v_table
        FROM
            documentos_det                                                    d
            LEFT OUTER JOIN documentos_cab                                                    dc ON dc.id_cia = d.id_cia
                                                 AND dc.numint = d.numint
            LEFT OUTER JOIN pack_trazabilidad.sp_trazabilidad(dc.id_cia, dc.numint)           sp ON 1 = 1
                                                                                          AND sp.tipdoc = 115
            LEFT OUTER JOIN documentos_cab                                                    dp ON dp.id_cia = d.id_cia
                                                 AND dp.numint = sp.numint
            LEFT OUTER JOIN documentos_cab_clase                                              en ON en.id_cia = d.id_cia
                                                       AND en.numint = dc.numint
                                                       AND en.clase = 10
            LEFT OUTER JOIN almacen                                                           al ON al.id_cia = d.id_cia
                                          AND al.tipinv = d.tipinv
                                          AND al.codalm = d.codalm
            LEFT OUTER JOIN almacen_ubicacion                                                 au ON au.id_cia = d.id_cia
                                                    AND au.tipinv = d.tipinv
                                                    AND au.codalm = d.codalm
                                                    AND au.codigo = d.ubica
            LEFT OUTER JOIN clientes_especificacion                                           ce ON ce.id_cia = d.id_cia
                                                          AND ce.tipcli = 'B'
                                                          AND ce.codcli = dc.codcli
                                                          AND ce.codesp = 3
            INNER JOIN articulos                                                         a ON a.id_cia = d.id_cia
                                      AND a.tipinv = d.tipinv
                                      AND a.codart = d.codart
            LEFT OUTER JOIN unidad                                                            u ON u.id_cia = d.id_cia
                                        AND u.coduni = a.coduni
            LEFT OUTER JOIN cliente_articulos_clase                                           ca1 ON ca1.id_cia = d.id_cia
                                                           AND ca1.tipcli = 'B'
                                                           AND ca1.codcli = a.codprv
                                                           AND ca1.clase = 1
                                                           AND ca1.codigo = d.codadd01
            LEFT OUTER JOIN cliente_articulos_clase                                           ca2 ON ca2.id_cia = d.id_cia
                                                           AND ca2.tipcli = 'B'
                                                           AND ca2.codcli = a.codprv
                                                           AND ca2.clase = 2
                                                           AND ca2.codigo = d.codadd02
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 3)         cc3 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 6)         cc6 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 8)         cc8 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 13)        cc13 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 91)        cc91 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 92)        cc92 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, a.tipinv, a.codart, 93)        cc93 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 96)        cc96 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 97)        cc97 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 98)        cc98 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 100)       cc100 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 102)       cc102 ON 0 = 0
--            LEFT OUTER JOIN pack_trazabilidad.sp_trazabilidad_tipdoc(d.id_cia, d.numint, 104) tr ON 0 = 0
--            LEFT OUTER JOIN documentos_cab_ordcom                                             dco ON dco.id_cia = d.id_cia
--                                                         AND dco.numint = tr.numint
--            LEFT OUTER JOIN documentos_cab                                                    dpr ON dpr.id_cia = d.id_cia
--                                                  AND dpr.numint = tr.numint
--            LEFT OUTER JOIN certificadocal_det                                                cer ON cer.id_cia = d.id_cia
--                                                      AND cer.opnumint = tr.numint
--                                                      AND cer.opnumite = d.opnumite
--            LEFT OUTER JOIN certificadocal_cab                                                cec ON cec.id_cia = d.id_cia
--                                                      AND cec.numint = cer.numint
--            LEFT OUTER JOIN cliente                                                           cle ON cle.id_cia = d.id_cia
--                                           AND cle.codcli = cec.codcli
--            LEFT OUTER JOIN documentos_det                                                    dcpr ON dcpr.id_cia = d.id_cia
--                                                   AND dcpr.numint = tr.numint
--                                                   AND dcpr.numite = d.opnumite
--            LEFT OUTER JOIN documentos_det_clase                                              dct ON dct.id_cia = d.id_cia
--                                                        AND dct.numint = tr.numint
--                                                        AND dct.numite = d.opnumite
--            LEFT OUTER JOIN clase_documentos_det_codigo                                       dct1 ON dct1.id_cia = d.id_cia
--                                                                AND dct1.tipdoc = 104
--                                                                AND dct1.clase = 1
--                                                                AND dct1.codigo = dct.codigo
--            LEFT OUTER JOIN documentos_det_clase                                              ddc ON ddc.id_cia = d.id_cia
--                                                        AND ddc.numint = d.numint
--                                                        AND ddc.numite = d.numite
--                                                        AND ddc.clase = 4
--            LEFT OUTER JOIN documentos_det_clase                                              ddc08 ON ddc08.id_cia = d.id_cia
--                                                          AND ddc08.numint = dcpr.numint
--                                                          AND ddc08.numite = dcpr.numite
--                                                          AND ddc08.clase = 8
--            LEFT OUTER JOIN documentos_det_clase                                              ddc09 ON ddc09.id_cia = d.id_cia
--                                                          AND ddc09.numint = dcpr.numint
--                                                          AND ddc09.numite = dcpr.numite
--                                                          AND ddc09.clase = 9
--            LEFT OUTER JOIN documentos_det_clase                                              ddc10 ON ddc10.id_cia = d.id_cia
--                                                          AND ddc10.numint = dcpr.numint
--                                                          AND ddc10.numite = dcpr.numite
--                                                          AND ddc10.clase = 10
        WHERE
                d.id_cia = pin_id_cia
            AND d.numint = pin_numint
            AND ( d.etiqueta IS NOT NULL )
            --AND ( d.etiqueta <> '' )
            AND ( length(TRIM(d.etiqueta)) > 0 )
            AND ( ( pin_codadd01 IS NULL )
                  OR ( d.codadd01 = pin_codadd01 ) )
            AND ( ( pin_codadd02 IS NULL )
                  OR ( d.codadd02 = pin_codadd02 ) )
            AND ( ( pin_ubica IS NULL )
                  OR ( d.ubica = pin_ubica ) )
        ORDER BY
            d.tipinv,
            d.codart,
            d.codadd01,
            d.codadd02,
            d.lote,
            d.cantid,
            d.etiqueta;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

    END sp_buscar_tipo_guiainterna;

    FUNCTION sp_buscar (
        pin_id_cia     NUMBER,
        pin_tipo       NUMBER,
        pin_numint     NUMBER,
        pin_codadd01   VARCHAR2,
        pin_codadd02   VARCHAR2,
        pin_ubica      VARCHAR2,
        pin_tipinv     NUMBER,
        pin_codart     VARCHAR2,
        pin_etiqueta01 VARCHAR2,
        pin_etiqueta02 VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        CASE pin_tipo
            WHEN 0 THEN
                SELECT
                    *
                BULK COLLECT
                INTO v_table
                FROM
                    pack_etiquetas_tsiprint.sp_buscar_tipo_guiainterna(pin_id_cia, pin_numint, pin_codadd01, pin_codadd02, pin_ubica);

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

            WHEN 1 THEN
                SELECT
                    *
                BULK COLLECT
                INTO v_table
                FROM
                    pack_etiquetas_tsiprint.sp_buscar_tipo_etiqueta(pin_id_cia, pin_tipinv, pin_codart, pin_etiqueta01, pin_etiqueta02);

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

            WHEN 2 THEN
                SELECT
                    *
                BULK COLLECT
                INTO v_table
                FROM
    pack_etiquetas_tsiprint.sp_buscar_tipo_tomainventario(pin_id_cia, pin_numint, pin_codadd01, pin_codadd02, pin_ubica);
    FOR registro IN 1..v_table.count LOOP
        PIPE ROW ( v_table(registro) );
    END LOOP;

        END CASE;END;
    FUNCTION sp_buscar_doc (
        pin_id_cia  NUMBER,
        pin_tipdoc  NUMBER,
        pin_codmot  NUMBER,
        pin_femisi  DATE,
        pin_codcli  VARCHAR2
    ) RETURN datatable_buscar_doc
        PIPELINED
    AS
        v_table datatable_buscar_doc;
    BEGIN
        IF pin_tipdoc = 103 THEN
            SELECT
                d1.id_cia,
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
                d1.proyec,
                s1.dessit,
                d1.tipdoc,
                m1.desmot,
                d1.codalm,
                al.descri     AS desalm,
                d1.optipinv,
                t1.dtipinv    AS destinv,
                d1.tipmon,
                d1.tipcam,
                d1.porigv,
                d1.preven,
                cl.direc1     AS dircli1,
                cl.direc2     AS dircli2,
                tm.desmon,
                tm.simbolo,
                d1.numped,
                oc.fecha      AS oc_fecha,
                oc.numero     AS oc_numero,
                d1.presen
            BULK COLLECT
            INTO v_table
            FROM
                documentos_cab         d1
                LEFT OUTER JOIN documentos_cab_ordcom  oc ON ( oc.id_cia = d1.id_cia )
                                                            AND ( oc.numint = d1.numint )
                LEFT OUTER JOIN situacion              s1 ON ( s1.id_cia = d1.id_cia )
                                                AND ( s1.tipdoc = d1.tipdoc )
                                                    AND ( s1.situac = d1.situac )
                LEFT OUTER JOIN motivos                m1 ON ( m1.id_cia = d1.id_cia )
                                              AND ( m1.id = d1.id )
                                                  AND ( m1.codmot = d1.codmot )
                                                      AND ( m1.tipdoc = pin_tipdoc )
                LEFT OUTER JOIN almacen                al ON ( al.id_cia = d1.id_cia )
                                              AND ( al.tipinv = d1.optipinv )
                                                  AND ( al.codalm = d1.codalm )
                LEFT OUTER JOIN t_inventario           t1 ON ( t1.id_cia = d1.id_cia )
                                                   AND ( t1.tipinv = d1.optipinv )
                LEFT OUTER JOIN cliente                cl ON ( cl.id_cia = d1.id_cia )
                                              AND ( cl.codcli = d1.codcli )
                LEFT OUTER JOIN tmoneda                tm ON ( tm.id_cia = d1.id_cia )
                                              AND ( tm.codmon = d1.tipmon )
            WHERE
                    d1.id_cia = pin_id_cia
                AND ( d1.tipdoc = pin_tipdoc )
                    AND d1.femisi >= pin_femisi
                        AND ( d1.id = 'I' )
                            AND ( pin_codcli IS NULL
                                  OR d1.codcli = pin_codcli )
                                AND ( upper(d1.numdoc) LIKE upper('%') )
                                    AND ( d1.codmot = pin_codmot )
                                        AND ( d1.situac IN (
                    'A',
                    'F',
                    'E',
                    'G',
                    'H'
                ) )
            ORDER BY
                d1.femisi DESC,
                d1.series,
                d1.numdoc DESC;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            return;
        ELSIF pin_tipdoc = 111 THEN
            SELECT
                d1.id_cia,
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
                d1.proyec,
                s1.dessit,
                d1.tipdoc,
                m1.desmot,
                d1.codalm,
                al.descri     AS desalm,
                d1.optipinv,
                t1.dtipinv    AS destinv,
                d1.tipmon,
                d1.tipcam,
                d1.porigv,
                d1.preven,
                cl.direc1     AS dircli1,
                cl.direc2     AS dircli2,
                tm.desmon,
                tm.simbolo,
                d1.numped,
                oc.fecha      AS oc_fecha,
                oc.numero     AS oc_numero,
                d1.presen
            BULK COLLECT
            INTO v_table
            FROM
                documentos_cab         d1
                LEFT OUTER JOIN documentos_cab_ordcom  oc ON ( oc.id_cia = d1.id_cia )
                                                            AND ( oc.numint = d1.numint )
                LEFT OUTER JOIN situacion              s1 ON ( s1.id_cia = d1.id_cia )
                                                AND ( s1.tipdoc = d1.tipdoc )
                                                    AND ( s1.situac = d1.situac )
                LEFT OUTER JOIN motivos                m1 ON ( m1.id_cia = d1.id_cia )
                                              AND ( m1.id = d1.id )
                                                  AND ( m1.codmot = d1.codmot )
                                                      AND ( m1.tipdoc = pin_tipdoc )
                LEFT OUTER JOIN almacen                al ON ( al.id_cia = d1.id_cia )
                                              AND ( al.tipinv = d1.optipinv )
                                                  AND ( al.codalm = d1.codalm )
                LEFT OUTER JOIN t_inventario           t1 ON ( t1.id_cia = d1.id_cia )
                                                   AND ( t1.tipinv = d1.optipinv )
                LEFT OUTER JOIN cliente                cl ON ( cl.id_cia = d1.id_cia )
                                              AND ( cl.codcli = d1.codcli )
                LEFT OUTER JOIN tmoneda                tm ON ( tm.id_cia = d1.id_cia )
                                              AND ( tm.codmon = d1.tipmon )
            WHERE
                    d1.id_cia = pin_id_cia
                AND ( d1.tipdoc = pin_tipdoc )
                    AND ( d1.id = 'I' )
                        AND ( upper(d1.numdoc) LIKE upper('%') )
                            AND ( d1.codmot IN (
                    5,
                    6,
                    7
                ) )
                                AND ( d1.situac IN (
                    'A',
                    'F',
                    'E',
                    'G',
                    'H'
                ) )
            ORDER BY
                d1.femisi DESC,
                d1.series,
                d1.numdoc DESC;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            return;
        END IF;
    END sp_buscar_doc;

END;

/
