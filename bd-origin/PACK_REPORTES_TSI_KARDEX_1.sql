--------------------------------------------------------
--  DDL for Package Body PACK_REPORTES_TSI_KARDEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_REPORTES_TSI_KARDEX" AS

    FUNCTION sp_resumen_detallado_kardex (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_swacti  VARCHAR2
    ) RETURN datatable_resumen_detallado_kardex
        PIPELINED
    AS

        v_table  datatable_resumen_detallado_kardex;
        v_pdesde NUMBER := pin_periodo * 100;
        v_phasta NUMBER := pin_periodo * 100 + 12;
    BEGIN
        IF pin_swacti = 'S' THEN
            v_pdesde := pin_periodo * 100;
            v_phasta := pin_periodo * 100;
        END IF;

        SELECT
            id_cia,
            pin_periodo,
            tipinv,
            codart,
            codalm,
            SUM(
                CASE
                    WHEN id = 'I' THEN
                        1
                    ELSE
                        - 1
                END
                * costot01),
            SUM(
                CASE
                    WHEN id = 'I' THEN
                        1
                    ELSE
                        - 1
                END
                * costot02),
            SUM(
                CASE
                    WHEN id = 'I' THEN
                        1
                    ELSE
                        - 1
                END
                * cantid)
        BULK COLLECT
        INTO v_table
        FROM
            kardex
        WHERE
                id_cia = pin_id_cia
            AND periodo BETWEEN v_pdesde AND v_phasta
        GROUP BY
            id_cia,
            pin_periodo,
            tipinv,
            codart,
            codalm;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_resumen_detallado_kardex;

    FUNCTION sp_resumen_kardex (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_swacti  VARCHAR2
    ) RETURN datatable_resumen_kardex
        PIPELINED
    AS

        v_table  datatable_resumen_kardex;
        v_pdesde NUMBER := pin_periodo * 100;
        v_phasta NUMBER := pin_periodo * 100 + 12;
    BEGIN
        IF pin_swacti = 'S' THEN
            v_pdesde := pin_periodo * 100;
            v_phasta := pin_periodo * 100;
        END IF;

        SELECT
            id_cia,
            pin_periodo,
            tipinv,
            codalm,
            SUM(
                CASE
                    WHEN id = 'I' THEN
                        1
                    ELSE
                        - 1
                END
                * costot01),
            SUM(
                CASE
                    WHEN id = 'I' THEN
                        1
                    ELSE
                        - 1
                END
                * costot02),
            SUM(
                CASE
                    WHEN id = 'I' THEN
                        1
                    ELSE
                        - 1
                END
                * cantid)
        BULK COLLECT
        INTO v_table
        FROM
            kardex
        WHERE
                id_cia = pin_id_cia
            AND periodo BETWEEN v_pdesde AND v_phasta
        GROUP BY
            id_cia,
            pin_periodo,
            tipinv,
            codalm;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_resumen_kardex;

    FUNCTION sp_apertura_consistencia_resumen (
        pin_id_cia NUMBER,
        pin_pdesde NUMBER,
        pin_phasta NUMBER
    ) RETURN datatable_apertura_consistencia_resumen
        PIPELINED
    AS
        v_table datatable_apertura_consistencia_resumen;
    BEGIN
        SELECT
            pd.tipinv,
            t.dtipinv,
            pd.codalm,
            al.descri AS desalm,
            pd.periodo,
            nvl(pd.costot01, 0),
            nvl(pd.costot02, 0),
            nvl(pd.cantid, 0),
            ph.periodo,
--            ph.tipinv,
--            ph.codalm,
            nvl(ph.costot01, 0),
            nvl(ph.costot02, 0),
            nvl(ph.cantid, 0)
        BULK COLLECT
        INTO v_table
        FROM
            pack_reportes_tsi_kardex.sp_resumen_kardex(pin_id_cia, pin_pdesde, 'N') pd
            LEFT OUTER JOIN pack_reportes_tsi_kardex.sp_resumen_kardex(pin_id_cia, pin_phasta, 'S') ph ON ph.id_cia = pd.id_cia
                                                                                                          AND ph.tipinv = pd.tipinv
                                                                                                          AND ph.codalm = pd.codalm
            LEFT OUTER JOIN t_inventario                                                            t ON t.id_cia = pd.id_cia
                                              AND t.tipinv = pd.tipinv
            LEFT OUTER JOIN almacen                                                                 al ON al.id_cia = pd.id_cia
                                          AND al.tipinv = pd.tipinv
                                          AND al.codalm = pd.codalm
        ORDER BY
            pd.tipinv,
            pd.codalm;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_apertura_consistencia_resumen;

    FUNCTION sp_apertura_consistencia_detallado (
        pin_id_cia NUMBER,
        pin_pdesde NUMBER,
        pin_phasta NUMBER
    ) RETURN datatable_apertura_consistencia_detallado
        PIPELINED
    AS
        v_table datatable_apertura_consistencia_detallado;
    BEGIN
        SELECT
            pd.tipinv,
            t.dtipinv,
            pd.codalm,
            al.descri AS desalm,
            pd.codart,
            a.descri  AS desart,
            pd.periodo,
            nvl(pd.costot01, 0),
            nvl(pd.costot02, 0),
            nvl(pd.cantid, 0),
            nvl(ph.periodo,pin_phasta),
--            ph.tipinv,
--            ph.codalm,
--            ph.codart,
            nvl(ph.costot01, 0),
            nvl(ph.costot02, 0),
            nvl(ph.cantid, 0)
        BULK COLLECT
        INTO v_table
        FROM
            pack_reportes_tsi_kardex.sp_resumen_detallado_kardex(pin_id_cia, pin_pdesde, 'N') pd
            LEFT OUTER JOIN pack_reportes_tsi_kardex.sp_resumen_detallado_kardex(pin_id_cia, pin_phasta, 'S') ph ON ph.id_cia = pd.id_cia
                                                                                                                    AND ph.tipinv = pd.tipinv
                                                                                                                    AND ph.codalm = pd.codalm
                                                                                                                    AND ph.codart = pd.codart
            LEFT OUTER JOIN t_inventario                                                                      t ON t.id_cia = pd.id_cia
                                              AND t.tipinv = pd.tipinv
            LEFT OUTER JOIN almacen                                                                           al ON al.id_cia = pd.id_cia
                                          AND al.tipinv = pd.tipinv
                                          AND al.codalm = pd.codalm
            LEFT OUTER JOIN articulos                                                                         a ON a.id_cia = pd.id_cia
                                           AND a.tipinv = pd.tipinv
                                           AND a.codart = pd.codart
        ORDER BY
            pd.tipinv,
            pd.codalm,
            pd.codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_apertura_consistencia_detallado;

    FUNCTION sp_chasis_motor (
        pin_id_cia NUMBER,
        pin_codcli VARCHAR2,
        pin_chasis VARCHAR2,
        pin_motor  VARCHAR2
    ) RETURN datatable_chasis_motor
        PIPELINED
    AS
        v_table datatable_chasis_motor;
    BEGIN
        SELECT
            upper(nvl(d2.descri, dt.descri))       AS tipo_documento,
            to_char(c.femisi, 'DD/MM/YY')          AS fecha_emision,
            c.series,
            c.numdoc,
            c.codcli                               AS cliente,
            c.razonc                               AS razonsocial,
            decode(c.id, 'I', 'INGRESO', 'SALIDA') AS tipo,
            m.desmot                               AS motivo,
            upper(ss.dessit)                       AS situacion,
            c.numint                               AS numero_interno,
            d.numite                               AS item,
            d.codart,
            a.descri                               AS desart,
            d.cantid                               AS cantidad,
            d.etiqueta,
            d.chasis,
            d.motor
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab  c
            LEFT OUTER JOIN documentos_det  d ON d.id_cia = c.id_cia
                                                AND d.numint = c.numint
            LEFT OUTER JOIN articulos       a ON a.id_cia = d.id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
            LEFT OUTER JOIN cliente         cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codcli
            LEFT OUTER JOIN tdoccobranza    d2 ON d2.id_cia = c.id_cia
                                               AND d2.tipdoc = c.tipdoc
            LEFT OUTER JOIN documentos_tipo dt ON dt.id_cia = c.id_cia
                                                  AND dt.tipdoc = c.tipdoc
            LEFT OUTER JOIN documentos      doc ON doc.id_cia = c.id_cia
                                              AND doc.codigo = c.tipdoc
                                              AND doc.series = c.series
            LEFT OUTER JOIN sucursal        sss ON sss.id_cia = c.id_cia
                                            AND sss.codsuc = c.codsuc
            LEFT OUTER JOIN motivos         m ON m.id_cia = c.id_cia
                                         AND m.tipdoc = c.tipdoc
                                         AND m.id = c.id
                                         AND m.codmot = c.codmot
            LEFT OUTER JOIN situacion       ss ON ss.id_cia = c.id_cia
                                            AND ss.tipdoc = c.tipdoc
                                            AND ss.situac = c.situac
        WHERE
                c.id_cia = pin_id_cia
            AND d.etiqueta IS NOT NULL
            AND ( nvl(pin_codcli, '-1') = '-1'
                  OR c.codcli = pin_codcli )
            AND ( nvl(pin_chasis, '-1') = '-1'
                  OR d.chasis = pin_chasis )
            AND ( nvl(pin_motor, '-1') = '-1'
                  OR d.motor = pin_motor )
            AND c.situac NOT IN ( 'J', 'K' )
            AND c.tipdoc IN ( 1, 3, 7, 8, 102,
                              103 )
        ORDER BY
            c.femisi DESC,
            c.tipdoc DESC,
            c.series DESC,
            c.numdoc;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_chasis_motor;

END;

/
