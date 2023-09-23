--------------------------------------------------------
--  DDL for Package Body PACK_REPORTES_TSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_REPORTES_TSI" AS

    PROCEDURE sp_importar (
        pin_id_cia      IN NUMBER,
        pin_id_cia_orig IN NUMBER
    ) AS
    BEGIN
        FOR i IN (
            SELECT
                pin_id_cia,
                ed.codigo,
                ed.descri,
                ed.cadsql,
                ed.observ,
                ed.nlibro,
                ed.tipbd,
                ed.params,
                ed.swtabd,
                ed.swsistema
            FROM
                exceldinamico ed
            WHERE
                ed.id_cia = pin_id_cia_orig
        ) LOOP
            INSERT INTO exceldinamico VALUES i;

        END LOOP;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
    END sp_importar;

    FUNCTION fecha_de_vencimiento_entre_fe (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codalm VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_fecha_de_vencimiento_entre_fe
        PIPELINED
    AS
        v_table datatable_fecha_de_vencimiento_entre_fe;
    BEGIN
        SELECT
            cc.descri,
            ti.dtipinv,
            k.codalm,
            al.descri,
            k.codart,
            ar.descri,
            SUM(
                CASE
                    WHEN k.id = 'I' THEN
                        1
                    ELSE
                        - 1
                END
                * k.cantid),
            k01.lote,
            k01.fvenci
        BULK COLLECT
        INTO v_table
        FROM
            kardex          k
            LEFT OUTER JOIN kardex001       k01 ON k01.id_cia = k.id_cia
                                             AND ( k01.tipinv = k.tipinv )
                                             AND ( k01.codart = k.codart )
                                             AND ( k01.codalm = k.codalm )
                                             AND ( k01.etiqueta = k.etiqueta )
            LEFT OUTER JOIN articulos       ar ON ar.id_cia = k.id_cia
                                            AND ( ar.tipinv = k.tipinv )
                                            AND ( ar.codart = k.codart )
            LEFT OUTER JOIN articulos_clase ac ON ac.id_cia = k.id_cia
                                                  AND ( ac.tipinv = k.tipinv )
                                                  AND ( ac.codart = k.codart )
                                                  AND ( ac.clase = 12 )
            LEFT OUTER JOIN clase           c1 ON c1.id_cia = k.id_cia
                                        AND ( c1.tipinv = ac.tipinv )
                                        AND ( c1.clase = ac.clase )
            LEFT JOIN clase_codigo    cc ON cc.id_cia = k.id_cia
                                         AND ( cc.tipinv = ac.tipinv
                                               AND cc.clase = ac.clase
                                               AND cc.codigo = ac.codigo )
            LEFT OUTER JOIN t_inventario    ti ON ti.id_cia = k.id_cia
                                               AND ( ti.tipinv = k.tipinv )
            LEFT OUTER JOIN almacen         al ON al.id_cia = k.id_cia
                                          AND al.tipinv = k.tipinv
                                          AND al.codalm = k.codalm
        WHERE
                k.id_cia = pin_id_cia
            AND ( k.tipinv = pin_tipinv )
            AND ( k.codalm = pin_codalm
                  OR pin_codalm = - 1 )
            AND ( EXTRACT(YEAR FROM k.femisi) = EXTRACT(YEAR FROM current_date) )
            AND ( k01.fvenci BETWEEN pin_fdesde AND pin_fhasta )
        GROUP BY
            cc.descri,
            ti.dtipinv,
            k.codalm,
            al.descri,
            k.codart,
            ar.descri,
            k01.lote,
            k01.fvenci
        HAVING
            SUM(
                CASE
                    WHEN k.id = 'I' THEN
                        1
                    ELSE
                        - 1
                END
                * k.cantid) <> 0;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END fecha_de_vencimiento_entre_fe;

    FUNCTION sp_transferencia_gratuita_cxc (
        pin_id_cia NUMBER
    ) RETURN datatable_transferencia_gratuita_cxc
        PIPELINED
    AS
        v_table datatable_transferencia_gratuita_cxc;
    BEGIN
        SELECT
            c.numint,
            c.tipdoc,
            c.series,
            c.numdoc,
            c.femisi,
            c.codmot,
            m.desmot,
            c.razonc,
            c.codcpag,
            cp.despag,
            cp1.valor
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab c
            LEFT OUTER JOIN motivos        m ON m.id_cia = c.id_cia
                                         AND m.codmot = c.codmot
                                         AND m.id = c.id
                                         AND m.tipdoc = c.tipdoc
            LEFT OUTER JOIN motivos_clase  m44 ON m44.id_cia = c.id_cia
                                                 AND m44.codmot = c.codmot
                                                 AND m44.id = c.id
                                                 AND m44.tipdoc = c.tipdoc
                                                 AND m44.codigo = 44
            LEFT OUTER JOIN c_pago         cp ON cp.id_cia = c.id_cia
                                         AND cp.codpag = c.codcpag
            LEFT OUTER JOIN c_pago_clase   cp1 ON cp1.id_cia = c.id_cia
                                                AND cp1.codpag = c.codcpag
                                                AND cp1.codigo = 1
            LEFT OUTER JOIN dcta100        d1 ON d1.id_cia = c.id_cia
                                          AND d1.numint = c.numint
        WHERE
                c.id_cia = pin_id_cia
            AND m44.valor = 'S'
            AND cp1.valor = 'N'
            AND d1.numint IS NOT NULL;

    END sp_transferencia_gratuita_cxc;

    FUNCTION sp_stock_kardex_detalle (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_stock_kardex_detalle
        PIPELINED
    AS

--        v_table    datatable_stock_kardex_detalle;
        v_rec      datarecord_stock_kardex_detalle;
        v_hperiodo NUMBER := ( pin_periodo * 100 ) + pin_mes;
        v_dperiodo NUMBER := pin_periodo * 100;
        CURSOR articulos IS
        SELECT DISTINCT
            r.id_cia,
            r.tipinv,
            i.dtipinv,
            r.codart,
            a.descri AS desart
        FROM
            kardex       r
            LEFT OUTER JOIN t_inventario i ON i.id_cia = r.id_cia
                                              AND i.tipinv = r.tipinv
            LEFT OUTER JOIN articulos    a ON a.id_cia = r.id_cia
                                           AND a.tipinv = r.tipinv
                                           AND a.codart = r.codart
        WHERE
                r.id_cia = pin_id_cia
            AND r.periodo BETWEEN v_dperiodo AND v_hperiodo
        ORDER BY
            tipinv ASC;

    BEGIN
        v_rec.stock := 0;
        FOR i IN articulos LOOP
            FOR j IN (
                SELECT
                    k.id_cia,
                    k.codart,
                    k.tipinv,
                    k.tipdoc,
                    k.numint,
                    k.numite,
                    k.femisi,
                    k.id,
                    k.cantid AS stock
                FROM
                    kardex k
                WHERE
                        k.id_cia = i.id_cia
                    AND k.tipinv = i.tipinv
                    AND k.codart = i.codart
                    AND k.periodo BETWEEN v_dperiodo AND v_hperiodo
                ORDER BY
                    k.femisi ASC,
                    k.id ASC
            ) LOOP
            -- GENERAL
                v_rec.id_cia := i.id_cia;
                v_rec.tipinv := i.tipinv;
                v_rec.dtipinv := i.dtipinv;
                v_rec.codart := i.codart;
                v_rec.desart := i.desart;
                CASE
                    WHEN j.id = 'I' THEN
                        v_rec.stock := v_rec.stock + j.stock;
                    ELSE
                        v_rec.stock := v_rec.stock - j.stock;
                END CASE;
            -- ESPECIFICO
                IF v_rec.stock < 0 THEN
                    v_rec.id := j.id;
                    v_rec.cantid := j.stock;
                    v_rec.tipdoc := j.tipdoc;
                    v_rec.numint := j.numint;
                    v_rec.numite := j.numite;
                    v_rec.femisi := j.femisi;
                    PIPE ROW ( v_rec );
                END IF;

            END LOOP;

            v_rec.stock := 0;
        END LOOP;

    END sp_stock_kardex_detalle;

    FUNCTION sp_stock_kardex (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_stock_kardex
        PIPELINED
    AS
        v_table    datatable_stock_kardex;
        v_dperiodo NUMBER;
        v_hperiodo NUMBER;
        v_operiodo NUMBER;
    BEGIN
        IF pin_mes IN ( 0, 1 ) THEN
            v_dperiodo := ( pin_periodo * 100 ) + pin_mes;
        ELSE
            v_dperiodo := ( pin_periodo * 100 ) + ( pin_mes - 1 );
        END IF;

        v_hperiodo := ( pin_periodo * 100 ) + pin_mes;
        v_operiodo := pin_periodo * 100;
        SELECT
            r.id_cia,
            r.tipinv,
            i.dtipinv,
            r.codart,
            a.descri AS desart,
            SUM(
                CASE
                    WHEN r.tip = 'S' THEN
                            CASE
                                WHEN r.id = 'I' THEN
                                    cantid
                                ELSE
                                    (cantid * - 1)
                            END
                    ELSE
                        0
                END
            )        AS stock_inicial,
            SUM(
                CASE
                    WHEN r.tip = 'A' THEN
                            CASE
                                WHEN r.id = 'I' THEN
                                    cantid
                                ELSE
                                    0
                            END
                    ELSE
                        0
                END
            )        AS ingresos,
            SUM(
                CASE
                    WHEN r.tip = 'A' THEN
                            CASE
                                WHEN r.id = 'I' THEN
                                    0
                                ELSE
                                    cantid
                            END
                    ELSE
                        0
                END
            )        AS salidas,
            SUM(
                CASE
                    WHEN r.tip = 'A' THEN
                            CASE
                                WHEN r.id = 'I' THEN
                                    cantid
                                ELSE
                                    (cantid * - 1)
                            END
                    ELSE
                        CASE
                            WHEN r.id = 'I' THEN
                                    cantid
                            ELSE
                                (cantid * - 1)
                        END
                END
            )        AS stock
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    k.id_cia,
                    k.tipinv,
                    k.codart,
                    k.id,
                    'A'           AS tip,
                    SUM(k.cantid) AS cantid
                FROM
                    kardex k
                WHERE
                        id_cia = pin_id_cia
                    AND periodo = v_hperiodo
                GROUP BY
                    k.id_cia,
                    k.tipinv,
                    k.codart,
                    k.id,
                    'A'
                UNION ALL
                SELECT
                    k.id_cia,
                    k.tipinv,
                    k.codart,
                    k.id,
                    'S'           AS tip,
                    SUM(k.cantid) AS cantid
                FROM
                    kardex k
                WHERE
                        id_cia = pin_id_cia
                    AND periodo BETWEEN v_operiodo AND v_dperiodo
                GROUP BY
                    k.id_cia,
                    k.tipinv,
                    k.codart,
                    k.id,
                    'S'
            )            r
            LEFT OUTER JOIN t_inventario i ON i.id_cia = r.id_cia
                                              AND i.tipinv = r.tipinv
            LEFT OUTER JOIN articulos    a ON a.id_cia = r.id_cia
                                           AND a.tipinv = r.tipinv
                                           AND a.codart = r.codart
        GROUP BY
            r.id_cia,
            r.tipinv,
            i.dtipinv,
            r.codart,
            a.descri
        ORDER BY
            r.tipinv ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_stock_kardex;

    FUNCTION sp_consistencia_tipo_documento (
        pin_id_cia NUMBER,
        pin_tipdoc NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_consistencia_tipo_documento
        PIPELINED
    AS
        rec         datarecord_consistencia_tipo_documento;
        v_maxnumdoc NUMBER;
        v_minnumdoc NUMBER;
        v_aux       NUMBER;
    BEGIN
        FOR i IN (
            SELECT DISTINCT
                series,
                MAX(numdoc) AS maxnumdoc,
                MIN(numdoc) AS minnumdoc
            FROM
                documentos_cab
            WHERE
                    id_cia = pin_id_cia
                AND tipdoc = pin_tipdoc
                AND situac IN ( 'F', 'C', 'G', 'H' )
                AND femisi BETWEEN pin_fdesde AND pin_fhasta
            GROUP BY
                series
        ) LOOP
--            rec.id_cia := pin_id_cia;
            rec.serie := i.series;
            v_maxnumdoc := i.maxnumdoc;
            v_minnumdoc := i.minnumdoc;
            FOR j IN (
                SELECT
                    c.numint,
                    n.id_numero,
                    c.series,
                    nvl(c.numdoc, n.id_numero)    AS numdoc,
                    CASE
                        WHEN c.numdoc IS NULL THEN
                            '¡ALERTA!'
                        ELSE
                            ''
                    END                           AS alerta,
                    c.tipdoc,
                    t.descri,
                    trunc(c.femisi)               AS fecha,
                    c.codcli,
                    c.razonc,
                    c.situac,
                    s.dessit,
                    c.id,
                    c.codmot,
                    m.desmot,
                    c.codven,
                    v.desven,
                    ua.nombres                    AS usuario_actualizacion,
                    uc.nombres                    AS usuario_creacion,
                    to_char(c.factua, 'DD/MM/YY') AS fecha_actualizacion,
                    to_char(c.fcreac, 'DD/MM/YY') AS fecha_creacion
                FROM
                    numero          n
                    LEFT OUTER JOIN documentos_cab  c ON c.id_cia = pin_id_cia
                                                        AND c.series = i.series
                                                        AND c.numdoc = n.id_numero
                                                        AND c.tipdoc = pin_tipdoc
                    LEFT OUTER JOIN documentos_tipo t ON t.id_cia = pin_id_cia
                                                         AND t.tipdoc = c.tipdoc
                    LEFT OUTER JOIN situacion       s ON s.id_cia = c.id_cia
                                                   AND s.tipdoc = c.tipdoc
                                                   AND s.situac = c.situac
                    LEFT OUTER JOIN motivos         m ON m.id_cia = c.id_cia
                                                 AND m.tipdoc = c.tipdoc
                                                 AND m.id = c.id
                                                 AND m.codmot = c.codmot
                    LEFT OUTER JOIN vendedor        v ON v.id_cia = c.id_cia
                                                  AND v.codven = c.codven
                    LEFT OUTER JOIN usuarios        ua ON ua.id_cia = c.id_cia
                                                   AND ua.coduser = c.usuari
                    LEFT OUTER JOIN usuarios        uc ON uc.id_cia = c.id_cia
                                                   AND uc.coduser = c.ucreac
                WHERE
                    n.id_numero BETWEEN v_minnumdoc AND v_maxnumdoc
                ORDER BY
                    n.id_numero DESC
            ) LOOP
                rec.numint := j.numint;
                rec.alerta := j.alerta;
                rec.numero := j.numdoc;
                rec.tipdoc := j.tipdoc;
                rec.tipo_documento := j.descri;
                rec.fecha := to_char(j.fecha, 'DD/MM/YY');
                rec.codcli := j.codcli;
                rec.razon_social := j.razonc;
                rec.codsit := j.situac;
                rec.situacion := j.dessit;
                rec.id := j.id;
                rec.codmot := j.codmot;
                rec.motivo := j.desmot;
                rec.codven := j.codven;
                rec.vendedor := j.desven;
                rec.usuario_actualizacion := j.usuario_actualizacion;
                rec.usuario_creacion := j.usuario_creacion;
                rec.fecha_actualizacion := j.fecha_actualizacion;
                rec.fecha_creacion := j.fecha_creacion;
                PIPE ROW ( rec );
            END LOOP;                                
        -- SEPARADOR DE SERIE
            rec.tipdoc := NULL;
            rec.tipo_documento := '-';
            rec.alerta := NULL;
            rec.serie := '-';
            rec.numero := NULL;
            rec.fecha := '-';
            rec.codcli := '-';
            rec.razon_social := 'INICIANDO UNA NUEVA SERIE';
            rec.codsit := '-';
            rec.situacion := '-';
            rec.id := '-';
            rec.codmot := NULL;
            rec.motivo := '-';
            rec.codven := NULL;
            rec.vendedor := '-';
            rec.usuario_actualizacion := '-';
            rec.usuario_creacion := '-';
            rec.fecha_actualizacion := '-';
            rec.fecha_creacion := '-';
            PIPE ROW ( rec );
        END LOOP;
    END sp_consistencia_tipo_documento;

    FUNCTION sp_sin_clase_articulo (
        pin_id_cia NUMBER,
        pin_clase  NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_clase_articulo
        PIPELINED
    AS
        v_table datatable_clase_articulo;
    BEGIN
        SELECT DISTINCT
            c.id_cia,
            d.tipinv,
            t.dtipinv,
            d.codart,
            a.descri AS desart,
            'Articulo con movimiento SIN CLASE [ '
            || pin_clase
            || ' - '
            || cc.descri
            || ' ] ASIGNADA ! '
        BULK COLLECT
        INTO v_table
        FROM
                 documentos_cab c
            INNER JOIN documentos_det d ON c.id_cia = d.id_cia
                                           AND c.numint = d.numint
            LEFT OUTER JOIN t_inventario   t ON t.id_cia = d.id_cia
                                              AND t.tipinv = d.tipinv
            INNER JOIN articulos      a ON a.id_cia = c.id_cia
                                      AND a.tipinv = d.tipinv
                                      AND a.codart = d.codart
            LEFT OUTER JOIN clase          cc ON cc.id_cia = a.id_cia
                                        AND cc.tipinv = a.tipinv
                                        AND cc.clase = pin_clase
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc IN ( 1, 3, 7, 8 )
            AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
            AND NOT EXISTS (
                SELECT
                    ac.codart
                FROM
                    articulos_clase ac
                WHERE
                        ac.id_cia = d.id_cia
                    AND ac.tipinv = d.tipinv
                    AND ac.codart = d.codart
                    AND ac.clase = pin_clase
            );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_sin_clase_articulo;

    FUNCTION sp_relacion_actaentrega (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_relacion_actaentrega
        PIPELINED
    AS
        v_table datatable_relacion_actaentrega;
    BEGIN
        SELECT
            dt.descri                                                AS tipo_documento,
            TO_NUMBER(to_char(dc.femisi, 'YYYY'))                    AS periodo,
            to_char(dc.femisi, 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH') AS mes,
            dc.numint                                                AS correlativo_de_ae,
            dc.series                                                AS serie,
            dc.numdoc                                                AS numdoc,
            to_char(dc.femisi, 'DD/MM/YY')                           AS fecha_emision,
            dc.ruc                                                   AS cliente_ruc,
            dc.razonc                                                AS cliente_razonc,
            m.codmot,
            m.desmot                                                 AS motivo,
            d.numite                                                 AS item,
            d.tipinv,
            t.dtipinv                                                AS tipo_inventario,
            d.codart,
            a.descri                                                 AS articulo,
            d.cantid                                                 AS cantidad,
            d.preuni                                                 AS importe_unitario,
            d.importe,
            d.etiqueta,
            d.chasis,
            d.motor,
            k.dam,
            k.placa,
            k.dam_item,
            acc2.descodigo                                           AS departamento,
            acc3.descodigo                                           AS clase,
            acc4.descodigo                                           AS subclase,
            acc12.descodigo                                          AS marca,
            ae11.ventero                                             AS año_modelo,
            ae12.ventero                                             AS año_fabricación,
            ae13.vstrg                                               AS color
        BULK COLLECT
        INTO v_table
        FROM
            documentos_det                                                          d
            LEFT OUTER JOIN documentos_cab                                                          dc ON dc.id_cia = d.id_cia
                                                 AND dc.numint = d.numint
            LEFT OUTER JOIN documentos_tipo                                                         dt ON dt.id_cia = dc.id_cia
                                                  AND dt.tipdoc = dc.tipdoc
            LEFT OUTER JOIN motivos                                                                 m ON m.id_cia = dc.id_cia
                                         AND m.tipdoc = dc.tipdoc
                                         AND m.id = dc.id
                                         AND m.codmot = dc.codmot
            LEFT OUTER JOIN kardex000                                                               k ON k.id_cia = d.id_cia
                                           AND k.etiqueta = d.etiqueta
            LEFT OUTER JOIN t_inventario                                                            t ON t.id_cia = d.id_cia
                                              AND t.tipinv = d.tipinv
            LEFT OUTER JOIN articulos                                                               a ON a.id_cia = d.id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 2)  acc2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 3)  acc3 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 4)  acc4 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 12) acc12 ON 0 = 0
            LEFT OUTER JOIN articulo_especificacion                                                 ae11 ON ae11.id_cia = a.id_cia
                                                            AND ae11.tipinv = a.tipinv
                                                            AND ae11.codart = a.codart
                                                            AND ae11.codesp = 11
            LEFT OUTER JOIN articulo_especificacion                                                 ae12 ON ae12.id_cia = a.id_cia
                                                            AND ae12.tipinv = a.tipinv
                                                            AND ae12.codart = a.codart
                                                            AND ae12.codesp = 12
            LEFT OUTER JOIN articulo_especificacion                                                 ae13 ON ae13.id_cia = a.id_cia
                                                            AND ae13.tipinv = a.tipinv
                                                            AND ae13.codart = a.codart
                                                            AND ae13.codesp = 13
        WHERE
                dc.id_cia = pin_id_cia
            AND dc.tipdoc = 102
            AND dc.id = 'S'
            AND dc.codmot = 1
            AND d.etiqueta IS NOT NULL
            AND dc.femisi BETWEEN pin_fdesde AND pin_fhasta
        ORDER BY
            dc.numint DESC,
            d.numite ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_relacion_actaentrega;

END;

/
