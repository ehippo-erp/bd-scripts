--------------------------------------------------------
--  DDL for Package Body PACK_KARDEX001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_KARDEX001" AS

    FUNCTION sp_buscar_eqtiquetas (
        pin_id_cia     IN NUMBER,
        pin_tipstock   IN NUMBER,
        pin_codprov    IN VARCHAR2,
        pin_etiqueta   IN VARCHAR2,
        pin_tipinv     IN NUMBER,
        pin_codart     IN VARCHAR2,
        pin_calidad    IN VARCHAR2,
        pin_color      IN VARCHAR2,
        pin_codalm     IN NUMBER,
        pin_ubica      IN VARCHAR2,
        pin_lote       IN VARCHAR2,
        pin_ancho      IN NUMBER,
        pin_largo      IN NUMBER,
        pin_nrocarrete VARCHAR2,
        pin_chasis     VARCHAR2,
        pin_motor      VARCHAR2,
        pin_fdesde     IN DATE,
        pin_fhasta     IN DATE
    ) RETURN tbl_kardex001
        PIPELINED
    AS
        v_table tbl_kardex001;
    BEGIN
        IF pin_tipstock = 0 THEN
            SELECT
                k01.tipinv,
                ti.dtipinv                 AS destipinv,
                k01.codart,
                CAST(k01.fingreso AS DATE) AS fingreso,
                CAST(k01.fsalida AS DATE)  AS fsalida,
                k01.ingreso - k01.salida   AS stock,
                k01.salida,
                k01.numint,
                k01.codalm,
                k01.codadd01               AS codcalid,
                ca1.descri                 AS descalid,
                k01.codadd02               AS codcolor,
                ca2.descri                 AS descolor,
                au.descri                  AS desubi,
                al.descri                  AS desalm,
                k01.ubica                  AS ubica,
                a.descri                   AS desart,
                a.coduni,
                a.codprv,
                CASE
                    WHEN k01.ancho IS NULL THEN
                        0
                    ELSE
                        k01.ancho
                END                        AS ancho,
                CASE
                    WHEN k01.largo IS NULL THEN
                        0
                    ELSE
                        k01.largo
                END                        AS largo,
                k01.lote,
                k01.etiqueta,
                k01.nrocarrete,
                k01.combina,
                k01.empalme,
                k01.cantid_ori,
                k01.swacti,
                k01.diseno,
                k01.acabado,
                k01.fvenci,
                k01.fmanuf,
                u.abrevi                   AS abrunidad,
                k01.chasis,
                k01.motor
            BULK COLLECT
            INTO v_table
            FROM
                kardex001               k01
                LEFT OUTER JOIN articulos               a ON a.id_cia = k01.id_cia --R
                                               AND a.tipinv = k01.tipinv
                                               AND a.codart = k01.codart
                LEFT OUTER JOIN unidad                  u ON u.id_cia = a.id_cia --R
                                            AND u.coduni = a.coduni
                LEFT OUTER JOIN t_inventario            ti ON ti.id_cia = k01.id_cia --R
                                                   AND ti.tipinv = k01.tipinv
                LEFT OUTER JOIN cliente_articulos_clase ca1 ON ca1.id_cia = a.id_cia
                                                               AND ca1.tipcli = 'B'
                                                               AND ca1.codcli = a.codprv
                                                               AND ca1.clase = 1
                                                               AND ca1.codigo = k01.codadd01
                LEFT OUTER JOIN cliente_articulos_clase ca2 ON ca2.id_cia = a.id_cia
                                                               AND ca2.tipcli = 'B'
                                                               AND ca2.codcli = a.codprv
                                                               AND ca2.clase = 2
                                                               AND ca2.codigo = k01.codadd02
                LEFT OUTER JOIN almacen                 al ON al.id_cia = k01.id_cia -- R
                                              AND al.tipinv = k01.tipinv
                                              AND al.codalm = k01.codalm
                LEFT OUTER JOIN almacen_ubicacion       au ON au.id_cia = k01.id_cia -- R
                                                        AND au.tipinv = k01.tipinv
                                                        AND au.codalm = k01.codalm
                                                        AND au.codigo = k01.ubica
            WHERE
                    k01.id_cia = pin_id_cia
                AND ( pin_codprov IS NULL
                      OR pin_codprov = '-1'
                      OR a.codprv = pin_codprov )
                AND ( pin_etiqueta IS NULL
                      OR pin_etiqueta = '-1'
                      OR k01.etiqueta = pin_etiqueta )
                AND ( pin_tipinv IS NULL
                      OR pin_tipinv = - 1
                      OR k01.tipinv = pin_tipinv )
                AND ( pin_codart IS NULL
                      OR pin_codart = '-1'
                      OR k01.codart = pin_codart )
                AND ( pin_calidad IS NULL
                      OR k01.codadd01 = pin_calidad )
                AND ( pin_color IS NULL
                      OR k01.codadd02 = pin_color )
                AND ( pin_codalm IS NULL
                      OR pin_codalm = - 1
                      OR k01.codalm = pin_codalm )
                AND ( pin_ubica IS NULL
                      OR pin_ubica = '-1'
                      OR k01.ubica = pin_ubica )
                AND ( pin_lote IS NULL
                      OR pin_lote = '-1'
                      OR k01.lote = pin_lote )
                AND ( pin_ancho IS NULL
                      OR pin_ancho = - 1
                      OR k01.ancho = pin_ancho )
                AND ( pin_largo IS NULL
                      OR pin_largo = - 1
                      OR k01.largo = pin_largo )
                AND ( k01.nrocarrete = pin_nrocarrete
                      OR pin_nrocarrete IS NULL )
                AND ( k01.chasis = pin_chasis
                      OR pin_chasis IS NULL )
                AND ( k01.motor = pin_motor
                      OR pin_motor IS NULL )
                AND ( ( pin_fdesde IS NULL
                        AND pin_fhasta IS NULL )
                      OR ( k01.fingreso BETWEEN pin_fdesde AND pin_fhasta ) )
                AND ( ( ( k01.ingreso - k01.salida ) = 0 )
                      OR ( nvl(k01.swacti, 0) = 1 ) )
            OFFSET 0 ROWS FETCH NEXT 1000 ROWS ONLY;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSIF pin_tipstock = 1 THEN
            SELECT
                k01.tipinv,
                ti.dtipinv                 AS destipinv,
                k01.codart,
                CAST(k01.fingreso AS DATE) AS fingreso,
                CAST(k01.fsalida AS DATE)  AS fsalida,
                k01.ingreso - k01.salida   AS stock,
                k01.salida,
                k01.numint,
                k01.codalm,
                k01.codadd01               AS codcalid,
                ca1.descri                 AS descalid,
                k01.codadd02               AS codcolor,
                ca2.descri                 AS descolor,
                au.descri                  AS desubi,
                al.descri                  AS desalm,
                k01.ubica                  AS ubica,
                a.descri                   AS desart,
                a.coduni,
                a.codprv,
                CASE
                    WHEN k01.ancho IS NULL THEN
                        0
                    ELSE
                        k01.ancho
                END                        AS ancho,
                CASE
                    WHEN k01.largo IS NULL THEN
                        0
                    ELSE
                        k01.largo
                END                        AS largo,
                k01.lote,
                k01.etiqueta,
                k01.nrocarrete,
                k01.combina,
                k01.empalme,
                k01.cantid_ori,
                k01.swacti,
                k01.diseno,
                k01.acabado,
                k01.fvenci,
                k01.fmanuf,
                u.abrevi                   AS abrunidad,
                k01.chasis,
                k01.motor
            BULK COLLECT
            INTO v_table
            FROM
                kardex001               k01
                LEFT OUTER JOIN articulos               a ON a.id_cia = k01.id_cia --R
                                               AND a.tipinv = k01.tipinv
                                               AND a.codart = k01.codart
                LEFT OUTER JOIN unidad                  u ON u.id_cia = a.id_cia --R
                                            AND u.coduni = a.coduni
                LEFT OUTER JOIN t_inventario            ti ON ti.id_cia = k01.id_cia --R
                                                   AND ti.tipinv = k01.tipinv
                LEFT OUTER JOIN cliente_articulos_clase ca1 ON ca1.id_cia = a.id_cia
                                                               AND ca1.tipcli = 'B'
                                                               AND ca1.codcli = a.codprv
                                                               AND ca1.clase = 1
                                                               AND ca1.codigo = k01.codadd01
                LEFT OUTER JOIN cliente_articulos_clase ca2 ON ca2.id_cia = a.id_cia
                                                               AND ca2.tipcli = 'B'
                                                               AND ca2.codcli = a.codprv
                                                               AND ca2.clase = 2
                                                               AND ca2.codigo = k01.codadd02
                LEFT OUTER JOIN almacen                 al ON al.id_cia = k01.id_cia -- R
                                              AND al.tipinv = k01.tipinv
                                              AND al.codalm = k01.codalm
                LEFT OUTER JOIN almacen_ubicacion       au ON au.id_cia = k01.id_cia -- R
                                                        AND au.tipinv = k01.tipinv
                                                        AND au.codalm = k01.codalm
                                                        AND au.codigo = k01.ubica
            WHERE
                    k01.id_cia = pin_id_cia
                AND ( pin_codprov IS NULL
                      OR pin_codprov = '-1'
                      OR a.codprv = pin_codprov )
                AND ( pin_etiqueta IS NULL
                      OR pin_etiqueta = '-1'
                      OR k01.etiqueta = pin_etiqueta )
                AND ( pin_tipinv IS NULL
                      OR pin_tipinv = - 1
                      OR k01.tipinv = pin_tipinv )
                AND ( pin_codart IS NULL
                      OR pin_codart = '-1'
                      OR k01.codart = pin_codart )
                AND ( pin_calidad IS NULL
                      OR k01.codadd01 = pin_calidad )
                AND ( pin_color IS NULL
                      OR k01.codadd02 = pin_color )
                AND ( pin_codalm IS NULL
                      OR pin_codalm = - 1
                      OR k01.codalm = pin_codalm )
                AND ( pin_ubica IS NULL
                      OR pin_ubica = '-1'
                      OR k01.ubica = pin_ubica )
                AND ( pin_lote IS NULL
                      OR pin_lote = '-1'
                      OR k01.lote = pin_lote )
                AND ( pin_ancho IS NULL
                      OR pin_ancho = - 1
                      OR k01.ancho = pin_ancho )
                AND ( pin_largo IS NULL
                      OR pin_largo = - 1
                      OR k01.largo = pin_largo )
                AND ( k01.nrocarrete = pin_nrocarrete
                      OR pin_nrocarrete IS NULL )
                AND ( k01.chasis = pin_chasis
                      OR pin_chasis IS NULL )
                AND ( k01.motor = pin_motor
                      OR pin_motor IS NULL )
                AND ( ( pin_fdesde IS NULL
                        AND pin_fhasta IS NULL )
                      OR ( k01.fingreso BETWEEN pin_fdesde AND pin_fhasta ) )
                AND ( ( ( k01.ingreso - k01.salida ) > 0 )
                      AND ( nvl(k01.swacti, 0) = 0 ) )
            OFFSET 0 ROWS FETCH NEXT 1000 ROWS ONLY;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSIF pin_tipstock = 2 THEN
            SELECT
                k01.tipinv,
                ti.dtipinv                 AS destipinv,
                k01.codart,
                CAST(k01.fingreso AS DATE) AS fingreso,
                CAST(k01.fsalida AS DATE)  AS fsalida,
                k01.ingreso - k01.salida   AS stock,
                k01.salida,
                k01.numint,
                k01.codalm,
                k01.codadd01               AS codcalid,
                ca1.descri                 AS descalid,
                k01.codadd02               AS codcolor,
                ca2.descri                 AS descolor,
                au.descri                  AS desubi,
                al.descri                  AS desalm,
                k01.ubica                  AS ubica,
                a.descri                   AS desart,
                a.coduni,
                a.codprv,
                CASE
                    WHEN k01.ancho IS NULL THEN
                        0
                    ELSE
                        k01.ancho
                END                        AS ancho,
                CASE
                    WHEN k01.largo IS NULL THEN
                        0
                    ELSE
                        k01.largo
                END                        AS largo,
                k01.lote,
                k01.etiqueta,
                k01.nrocarrete,
                k01.combina,
                k01.empalme,
                k01.cantid_ori,
                k01.swacti,
                k01.diseno,
                k01.acabado,
                k01.fvenci,
                k01.fmanuf,
                u.abrevi                   AS abrunidad,
                k01.chasis,
                k01.motor
            BULK COLLECT
            INTO v_table
            FROM
                kardex001               k01
                LEFT OUTER JOIN articulos               a ON a.id_cia = k01.id_cia --R
                                               AND a.tipinv = k01.tipinv
                                               AND a.codart = k01.codart
                LEFT OUTER JOIN unidad                  u ON u.id_cia = a.id_cia --R
                                            AND u.coduni = a.coduni
                LEFT OUTER JOIN t_inventario            ti ON ti.id_cia = k01.id_cia --R
                                                   AND ti.tipinv = k01.tipinv
                LEFT OUTER JOIN cliente_articulos_clase ca1 ON ca1.id_cia = a.id_cia
                                                               AND ca1.tipcli = 'B'
                                                               AND ca1.codcli = a.codprv
                                                               AND ca1.clase = 1
                                                               AND ca1.codigo = k01.codadd01
                LEFT OUTER JOIN cliente_articulos_clase ca2 ON ca2.id_cia = a.id_cia
                                                               AND ca2.tipcli = 'B'
                                                               AND ca2.codcli = a.codprv
                                                               AND ca2.clase = 2
                                                               AND ca2.codigo = k01.codadd02
                LEFT OUTER JOIN almacen                 al ON al.id_cia = k01.id_cia -- R
                                              AND al.tipinv = k01.tipinv
                                              AND al.codalm = k01.codalm
                LEFT OUTER JOIN almacen_ubicacion       au ON au.id_cia = k01.id_cia -- R
                                                        AND au.tipinv = k01.tipinv
                                                        AND au.codalm = k01.codalm
                                                        AND au.codigo = k01.ubica
            WHERE
                    k01.id_cia = pin_id_cia
                AND ( pin_codprov IS NULL
                      OR pin_codprov = '-1'
                      OR a.codprv = pin_codprov )
                AND ( pin_etiqueta IS NULL
                      OR pin_etiqueta = '-1'
                      OR k01.etiqueta = pin_etiqueta )
                AND ( pin_tipinv IS NULL
                      OR pin_tipinv = - 1
                      OR k01.tipinv = pin_tipinv )
                AND ( pin_codart IS NULL
                      OR pin_codart = '-1'
                      OR k01.codart = pin_codart )
                AND ( pin_calidad IS NULL
                      OR k01.codadd01 = pin_calidad )
                AND ( pin_color IS NULL
                      OR k01.codadd02 = pin_color )
                AND ( pin_codalm IS NULL
                      OR pin_codalm = - 1
                      OR k01.codalm = pin_codalm )
                AND ( pin_ubica IS NULL
                      OR pin_ubica = '-1'
                      OR k01.ubica = pin_ubica )
                AND ( pin_lote IS NULL
                      OR pin_lote = '-1'
                      OR k01.lote = pin_lote )
                AND ( pin_ancho IS NULL
                      OR pin_ancho = - 1
                      OR k01.ancho = pin_ancho )
                AND ( pin_largo IS NULL
                      OR pin_largo = - 1
                      OR k01.largo = pin_largo )
                AND ( k01.nrocarrete = pin_nrocarrete
                      OR pin_nrocarrete IS NULL )
                AND ( k01.chasis = pin_chasis
                      OR pin_chasis IS NULL )
                AND ( k01.motor = pin_motor
                      OR pin_motor IS NULL )
                AND ( ( pin_fdesde IS NULL
                        AND pin_fhasta IS NULL )
                      OR ( k01.fingreso BETWEEN pin_fdesde AND pin_fhasta ) )
                AND k01.ingreso - k01.salida < 0
            OFFSET 0 ROWS FETCH NEXT 1000 ROWS ONLY;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        END IF;
    END sp_buscar_eqtiquetas;

    FUNCTION sp_exportar_etiquetas (
        pin_id_cia     IN NUMBER,
        pin_tipstock   IN NUMBER,
        pin_codprov    IN VARCHAR2,
        pin_etiqueta   IN VARCHAR2,
        pin_tipinv     IN NUMBER,
        pin_codart     IN VARCHAR2,
        pin_calidad    IN VARCHAR2,
        pin_color      IN VARCHAR2,
        pin_codalm     IN NUMBER,
        pin_ubica      IN VARCHAR2,
        pin_lote       IN VARCHAR2,
        pin_ancho      IN NUMBER,
        pin_largo      IN NUMBER,
        pin_nrocarrete VARCHAR2,
        pin_chasis     VARCHAR2,
        pin_motor      VARCHAR2,
        pin_fdesde     IN DATE,
        pin_fhasta     IN DATE
    ) RETURN tbl_kardex001
        PIPELINED
    AS
        v_table tbl_kardex001;
    BEGIN
        IF pin_tipstock = 0 THEN
            SELECT
                k01.tipinv,
                ti.dtipinv                 AS destipinv,
                k01.codart,
                CAST(k01.fingreso AS DATE) AS fingreso,
                CAST(k01.fsalida AS DATE)  AS fsalida,
                k01.ingreso - k01.salida   AS stock,
                k01.salida,
                k01.numint,
                k01.codalm,
                k01.codadd01               AS codcalid,
                ca1.descri                 AS descalid,
                k01.codadd02               AS codcolor,
                ca2.descri                 AS descolor,
                au.descri                  AS desubi,
                al.descri                  AS desalm,
                k01.ubica                  AS ubica,
                a.descri                   AS desart,
                a.coduni,
                a.codprv,
                CASE
                    WHEN k01.ancho IS NULL THEN
                        0
                    ELSE
                        k01.ancho
                END                        AS ancho,
                CASE
                    WHEN k01.largo IS NULL THEN
                        0
                    ELSE
                        k01.largo
                END                        AS largo,
                k01.lote,
                k01.etiqueta,
                k01.nrocarrete,
                k01.combina,
                k01.empalme,
                k01.cantid_ori,
                k01.swacti,
                k01.diseno,
                k01.acabado,
                k01.fvenci,
                k01.fmanuf,
                u.abrevi                   AS abrunidad,
                k01.chasis,
                k01.motor
            BULK COLLECT
            INTO v_table
            FROM
                kardex001               k01
                LEFT OUTER JOIN articulos               a ON a.id_cia = k01.id_cia --R
                                               AND a.tipinv = k01.tipinv
                                               AND a.codart = k01.codart
                LEFT OUTER JOIN unidad                  u ON u.id_cia = a.id_cia --R
                                            AND u.coduni = a.coduni
                LEFT OUTER JOIN t_inventario            ti ON ti.id_cia = k01.id_cia --R
                                                   AND ti.tipinv = k01.tipinv
                LEFT OUTER JOIN cliente_articulos_clase ca1 ON ca1.id_cia = a.id_cia
                                                               AND ca1.tipcli = 'B'
                                                               AND ca1.codcli = a.codprv
                                                               AND ca1.clase = 1
                                                               AND ca1.codigo = k01.codadd01
                LEFT OUTER JOIN cliente_articulos_clase ca2 ON ca2.id_cia = a.id_cia
                                                               AND ca2.tipcli = 'B'
                                                               AND ca2.codcli = a.codprv
                                                               AND ca2.clase = 2
                                                               AND ca2.codigo = k01.codadd02
                LEFT OUTER JOIN almacen                 al ON al.id_cia = k01.id_cia -- R
                                              AND al.tipinv = k01.tipinv
                                              AND al.codalm = k01.codalm
                LEFT OUTER JOIN almacen_ubicacion       au ON au.id_cia = k01.id_cia -- R
                                                        AND au.tipinv = k01.tipinv
                                                        AND au.codalm = k01.codalm
                                                        AND au.codigo = k01.ubica
            WHERE
                    k01.id_cia = pin_id_cia
                AND ( pin_codprov IS NULL
                      OR pin_codprov = '-1'
                      OR a.codprv = pin_codprov )
                AND ( pin_etiqueta IS NULL
                      OR pin_etiqueta = '-1'
                      OR k01.etiqueta = pin_etiqueta )
                AND ( pin_tipinv IS NULL
                      OR pin_tipinv = - 1
                      OR k01.tipinv = pin_tipinv )
                AND ( pin_codart IS NULL
                      OR pin_codart = '-1'
                      OR k01.codart = pin_codart )
                AND ( pin_calidad IS NULL
                      OR k01.codadd01 = pin_calidad )
                AND ( pin_color IS NULL
                      OR k01.codadd02 = pin_color )
                AND ( pin_codalm IS NULL
                      OR pin_codalm = - 1
                      OR k01.codalm = pin_codalm )
                AND ( pin_ubica IS NULL
                      OR pin_ubica = '-1'
                      OR k01.ubica = pin_ubica )
                AND ( pin_lote IS NULL
                      OR pin_lote = '-1'
                      OR k01.lote = pin_lote )
                AND ( pin_ancho IS NULL
                      OR pin_ancho = - 1
                      OR k01.ancho = pin_ancho )
                AND ( pin_largo IS NULL
                      OR pin_largo = - 1
                      OR k01.largo = pin_largo )
                AND ( k01.nrocarrete = pin_nrocarrete
                      OR pin_nrocarrete IS NULL )
                AND ( k01.chasis = pin_chasis
                      OR pin_chasis IS NULL )
                AND ( k01.motor = pin_motor
                      OR pin_motor IS NULL )
                AND ( ( pin_fdesde IS NULL
                        AND pin_fhasta IS NULL )
                      OR ( k01.fingreso BETWEEN pin_fdesde AND pin_fhasta ) )
                AND ( ( ( k01.ingreso - k01.salida ) = 0 )
                      OR ( nvl(k01.swacti, 0) = 1 ) );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSIF pin_tipstock = 1 THEN
            SELECT
                k01.tipinv,
                ti.dtipinv                 AS destipinv,
                k01.codart,
                CAST(k01.fingreso AS DATE) AS fingreso,
                CAST(k01.fsalida AS DATE)  AS fsalida,
                k01.ingreso - k01.salida   AS stock,
                k01.salida,
                k01.numint,
                k01.codalm,
                k01.codadd01               AS codcalid,
                ca1.descri                 AS descalid,
                k01.codadd02               AS codcolor,
                ca2.descri                 AS descolor,
                au.descri                  AS desubi,
                al.descri                  AS desalm,
                k01.ubica                  AS ubica,
                a.descri                   AS desart,
                a.coduni,
                a.codprv,
                CASE
                    WHEN k01.ancho IS NULL THEN
                        0
                    ELSE
                        k01.ancho
                END                        AS ancho,
                CASE
                    WHEN k01.largo IS NULL THEN
                        0
                    ELSE
                        k01.largo
                END                        AS largo,
                k01.lote,
                k01.etiqueta,
                k01.nrocarrete,
                k01.combina,
                k01.empalme,
                k01.cantid_ori,
                k01.swacti,
                k01.diseno,
                k01.acabado,
                k01.fvenci,
                k01.fmanuf,
                u.abrevi                   AS abrunidad,
                k01.chasis,
                k01.motor
            BULK COLLECT
            INTO v_table
            FROM
                kardex001               k01
                LEFT OUTER JOIN articulos               a ON a.id_cia = k01.id_cia --R
                                               AND a.tipinv = k01.tipinv
                                               AND a.codart = k01.codart
                LEFT OUTER JOIN unidad                  u ON u.id_cia = a.id_cia --R
                                            AND u.coduni = a.coduni
                LEFT OUTER JOIN t_inventario            ti ON ti.id_cia = k01.id_cia --R
                                                   AND ti.tipinv = k01.tipinv
                LEFT OUTER JOIN cliente_articulos_clase ca1 ON ca1.id_cia = a.id_cia
                                                               AND ca1.tipcli = 'B'
                                                               AND ca1.codcli = a.codprv
                                                               AND ca1.clase = 1
                                                               AND ca1.codigo = k01.codadd01
                LEFT OUTER JOIN cliente_articulos_clase ca2 ON ca2.id_cia = a.id_cia
                                                               AND ca2.tipcli = 'B'
                                                               AND ca2.codcli = a.codprv
                                                               AND ca2.clase = 2
                                                               AND ca2.codigo = k01.codadd02
                LEFT OUTER JOIN almacen                 al ON al.id_cia = k01.id_cia -- R
                                              AND al.tipinv = k01.tipinv
                                              AND al.codalm = k01.codalm
                LEFT OUTER JOIN almacen_ubicacion       au ON au.id_cia = k01.id_cia -- R
                                                        AND au.tipinv = k01.tipinv
                                                        AND au.codalm = k01.codalm
                                                        AND au.codigo = k01.ubica
            WHERE
                    k01.id_cia = pin_id_cia
                AND ( pin_codprov IS NULL
                      OR pin_codprov = '-1'
                      OR a.codprv = pin_codprov )
                AND ( pin_etiqueta IS NULL
                      OR pin_etiqueta = '-1'
                      OR k01.etiqueta = pin_etiqueta )
                AND ( pin_tipinv IS NULL
                      OR pin_tipinv = - 1
                      OR k01.tipinv = pin_tipinv )
                AND ( pin_codart IS NULL
                      OR pin_codart = '-1'
                      OR k01.codart = pin_codart )
                AND ( pin_calidad IS NULL
                      OR k01.codadd01 = pin_calidad )
                AND ( pin_color IS NULL
                      OR k01.codadd02 = pin_color )
                AND ( pin_codalm IS NULL
                      OR pin_codalm = - 1
                      OR k01.codalm = pin_codalm )
                AND ( pin_ubica IS NULL
                      OR pin_ubica = '-1'
                      OR k01.ubica = pin_ubica )
                AND ( pin_lote IS NULL
                      OR pin_lote = '-1'
                      OR k01.lote = pin_lote )
                AND ( pin_ancho IS NULL
                      OR pin_ancho = - 1
                      OR k01.ancho = pin_ancho )
                AND ( pin_largo IS NULL
                      OR pin_largo = - 1
                      OR k01.largo = pin_largo )
                AND ( k01.nrocarrete = pin_nrocarrete
                      OR pin_nrocarrete IS NULL )
                AND ( k01.chasis = pin_chasis
                      OR pin_chasis IS NULL )
                AND ( k01.motor = pin_motor
                      OR pin_motor IS NULL )
                AND ( ( pin_fdesde IS NULL
                        AND pin_fhasta IS NULL )
                      OR ( k01.fingreso BETWEEN pin_fdesde AND pin_fhasta ) )
                AND ( ( ( k01.ingreso - k01.salida ) > 0 )
                      AND ( nvl(k01.swacti, 0) = 0 ) );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSIF pin_tipstock = 2 THEN
            SELECT
                k01.tipinv,
                ti.dtipinv                 AS destipinv,
                k01.codart,
                CAST(k01.fingreso AS DATE) AS fingreso,
                CAST(k01.fsalida AS DATE)  AS fsalida,
                k01.ingreso - k01.salida   AS stock,
                k01.salida,
                k01.numint,
                k01.codalm,
                k01.codadd01               AS codcalid,
                ca1.descri                 AS descalid,
                k01.codadd02               AS codcolor,
                ca2.descri                 AS descolor,
                au.descri                  AS desubi,
                al.descri                  AS desalm,
                k01.ubica                  AS ubica,
                a.descri                   AS desart,
                a.coduni,
                a.codprv,
                CASE
                    WHEN k01.ancho IS NULL THEN
                        0
                    ELSE
                        k01.ancho
                END                        AS ancho,
                CASE
                    WHEN k01.largo IS NULL THEN
                        0
                    ELSE
                        k01.largo
                END                        AS largo,
                k01.lote,
                k01.etiqueta,
                k01.nrocarrete,
                k01.combina,
                k01.empalme,
                k01.cantid_ori,
                k01.swacti,
                k01.diseno,
                k01.acabado,
                k01.fvenci,
                k01.fmanuf,
                u.abrevi                   AS abrunidad,
                k01.chasis,
                k01.motor
            BULK COLLECT
            INTO v_table
            FROM
                kardex001               k01
                LEFT OUTER JOIN articulos               a ON a.id_cia = k01.id_cia --R
                                               AND a.tipinv = k01.tipinv
                                               AND a.codart = k01.codart
                LEFT OUTER JOIN unidad                  u ON u.id_cia = a.id_cia --R
                                            AND u.coduni = a.coduni
                LEFT OUTER JOIN t_inventario            ti ON ti.id_cia = k01.id_cia --R
                                                   AND ti.tipinv = k01.tipinv
                LEFT OUTER JOIN cliente_articulos_clase ca1 ON ca1.id_cia = a.id_cia
                                                               AND ca1.tipcli = 'B'
                                                               AND ca1.codcli = a.codprv
                                                               AND ca1.clase = 1
                                                               AND ca1.codigo = k01.codadd01
                LEFT OUTER JOIN cliente_articulos_clase ca2 ON ca2.id_cia = a.id_cia
                                                               AND ca2.tipcli = 'B'
                                                               AND ca2.codcli = a.codprv
                                                               AND ca2.clase = 2
                                                               AND ca2.codigo = k01.codadd02
                LEFT OUTER JOIN almacen                 al ON al.id_cia = k01.id_cia -- R
                                              AND al.tipinv = k01.tipinv
                                              AND al.codalm = k01.codalm
                LEFT OUTER JOIN almacen_ubicacion       au ON au.id_cia = k01.id_cia -- R
                                                        AND au.tipinv = k01.tipinv
                                                        AND au.codalm = k01.codalm
                                                        AND au.codigo = k01.ubica
            WHERE
                    k01.id_cia = pin_id_cia
                AND ( pin_codprov IS NULL
                      OR pin_codprov = '-1'
                      OR a.codprv = pin_codprov )
                AND ( pin_etiqueta IS NULL
                      OR pin_etiqueta = '-1'
                      OR k01.etiqueta = pin_etiqueta )
                AND ( pin_tipinv IS NULL
                      OR pin_tipinv = - 1
                      OR k01.tipinv = pin_tipinv )
                AND ( pin_codart IS NULL
                      OR pin_codart = '-1'
                      OR k01.codart = pin_codart )
                AND ( pin_calidad IS NULL
                      OR k01.codadd01 = pin_calidad )
                AND ( pin_color IS NULL
                      OR k01.codadd02 = pin_color )
                AND ( pin_codalm IS NULL
                      OR pin_codalm = - 1
                      OR k01.codalm = pin_codalm )
                AND ( pin_ubica IS NULL
                      OR pin_ubica = '-1'
                      OR k01.ubica = pin_ubica )
                AND ( pin_lote IS NULL
                      OR pin_lote = '-1'
                      OR k01.lote = pin_lote )
                AND ( pin_ancho IS NULL
                      OR pin_ancho = - 1
                      OR k01.ancho = pin_ancho )
                AND ( pin_largo IS NULL
                      OR pin_largo = - 1
                      OR k01.largo = pin_largo )
                AND ( k01.nrocarrete = pin_nrocarrete
                      OR pin_nrocarrete IS NULL )
                AND ( k01.chasis = pin_chasis
                      OR pin_chasis IS NULL )
                AND ( k01.motor = pin_motor
                      OR pin_motor IS NULL )
                AND ( ( pin_fdesde IS NULL
                        AND pin_fhasta IS NULL )
                      OR ( k01.fingreso BETWEEN pin_fdesde AND pin_fhasta ) )
                AND k01.ingreso - k01.salida < 0;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        END IF;
    END sp_exportar_etiquetas;

    FUNCTION sp_buscar_etiquetas_resumen (
        pin_id_cia     IN NUMBER,
        pin_tipstock   IN NUMBER,
        pin_codprov    IN VARCHAR2,
        pin_etiqueta   IN VARCHAR2,
        pin_tipinv     IN NUMBER,
        pin_codart     IN VARCHAR2,
        pin_calidad    IN VARCHAR2,
        pin_color      IN VARCHAR2,
        pin_codalm     IN NUMBER,
        pin_ubica      IN VARCHAR2,
        pin_lote       IN VARCHAR2,
        pin_ancho      IN NUMBER,
        pin_largo      IN NUMBER,
        pin_nrocarrete VARCHAR2,
        pin_fdesde     IN DATE,
        pin_fhasta     IN DATE
    ) RETURN datatable_etiquetas_resumen
        PIPELINED
    AS
        v_table datatable_etiquetas_resumen;
    BEGIN
        SELECT
            k01.tipinv,
            ti.dtipinv                    AS destipinv,
            k01.codart,
            SUM(k01.ingreso - k01.salida) AS stock,
            SUM(k01.ingreso),
            SUM(k01.salida),
            k01.numint,
            k01.codalm,
            k01.codadd01                  AS codcalid,
            ca1.descri                    AS descalid,
            k01.codadd02                  AS codcolor,
            ca2.descri                    AS descolor,
            au.descri                     AS desubi,
            al.descri                     AS desalm,
            k01.ubica                     AS ubica,
            a.descri                      AS desart,
            a.coduni,
            a.codprv,
            k01.ancho,
            k01.largo,
            k01.lote,
            k01.nrocarrete,
            k01.combina,
            k01.empalme,
            k01.diseno,
            k01.acabado,
            k01.fvenci,
            k01.fmanuf,
            u.abrevi                      AS abrunidad
        BULK COLLECT
        INTO v_table
        FROM
            kardex001               k01
            LEFT OUTER JOIN articulos               a ON a.id_cia = k01.id_cia
                                           AND a.tipinv = k01.tipinv
                                           AND a.codart = k01.codart
            LEFT OUTER JOIN unidad                  u ON u.id_cia = a.id_cia
                                        AND u.coduni = a.coduni
            LEFT OUTER JOIN t_inventario            ti ON ti.id_cia = k01.id_cia
                                               AND ti.tipinv = k01.tipinv
            LEFT OUTER JOIN cliente_articulos_clase ca1 ON ca1.id_cia = a.id_cia
                                                           AND ca1.tipcli = 'B'
                                                           AND ca1.codcli = a.codprv
                                                           AND ca1.clase = 1
                                                           AND ca1.codigo = k01.codadd01
            LEFT OUTER JOIN cliente_articulos_clase ca2 ON ca2.id_cia = a.id_cia
                                                           AND ca2.tipcli = 'B'
                                                           AND ca2.codcli = a.codprv
                                                           AND ca2.clase = 2
                                                           AND ca2.codigo = k01.codadd02
            LEFT OUTER JOIN almacen                 al ON al.id_cia = k01.id_cia -- R
                                          AND al.tipinv = k01.tipinv
                                          AND al.codalm = k01.codalm
            LEFT OUTER JOIN almacen_ubicacion       au ON au.id_cia = k01.id_cia -- R
                                                    AND au.tipinv = k01.tipinv
                                                    AND au.codalm = k01.codalm
                                                    AND au.codigo = k01.ubica
        WHERE
                k01.id_cia = pin_id_cia
            AND ( pin_codprov IS NULL
                  OR a.codprv = pin_codprov )
            AND ( k01.tipinv = pin_tipinv )
            AND ( k01.codart = pin_codart )
            AND ( pin_calidad IS NULL
                  OR k01.codadd01 = pin_calidad )
            AND ( pin_color IS NULL
                  OR k01.codadd02 = pin_color )
            AND ( pin_codalm IS NULL
                  OR pin_codalm = - 1
                  OR k01.codalm = pin_codalm )
            AND ( pin_ubica IS NULL
                  OR k01.ubica = pin_ubica )
            AND ( pin_lote IS NULL
                  OR k01.lote = pin_lote )
            AND ( ( pin_ancho IS NULL
                    OR pin_ancho = - 1 )
                  OR k01.ancho = pin_ancho )
            AND ( ( pin_largo IS NULL
                    OR pin_largo = - 1 )
                  OR k01.largo = pin_largo )
            AND ( k01.nrocarrete = pin_nrocarrete
                  OR pin_nrocarrete IS NULL )
            AND ( ( pin_fdesde IS NULL
                    AND pin_fhasta IS NULL )
                  OR ( k01.fingreso BETWEEN pin_fdesde AND pin_fhasta ) )
        GROUP BY
            k01.tipinv,
            ti.dtipinv,
            k01.codart,
            k01.numint,
            k01.codalm,
            k01.codadd01,
            ca1.descri,
            k01.codadd02,
            ca2.descri,
            au.descri,
            al.descri,
            k01.ubica,
            a.descri,
            a.coduni,
            a.codprv,
            k01.ancho,
            k01.largo,
            k01.lote,
            k01.nrocarrete,
            k01.combina,
            k01.empalme,
            k01.diseno,
            k01.acabado,
            k01.fvenci,
            k01.fmanuf,
            u.abrevi
        HAVING
            SUM(k01.ingreso - k01.salida) > 0
        FETCH FIRST 1000 ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_etiquetas_resumen;

    FUNCTION sp_help_eqtiquetas (
        pin_id_cia IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_codart IN VARCHAR2,
        pin_codalm IN NUMBER
    ) RETURN tbl_help_kardex001
        PIPELINED
    AS
        v_table tbl_help_kardex001;
    BEGIN
        SELECT
            k.etiqueta,
            k.ingreso - k.salida     AS saldo,
            a.coduni,
            k.kanban,
            k.codcli,
            k.opnumdoc,
            k.optramo,
            k.sucursal,
            CAST(k.fingreso AS DATE) AS fingreso,
            k.codadd01,
            k.codadd02,
            k.tipinv,
            k.codart,
            a.descri                 AS desart,
            a.consto,
            a.codprv,
            CASE
                WHEN k.ancho IS NULL THEN
                    0
                ELSE
                    k.ancho
            END                      AS ancho,
            CASE
                WHEN k.largo IS NULL THEN
                    0
                ELSE
                    k.largo
            END                      AS largo,
            k.combina,
            k.codalm,
            k.ubica,
            k.swacti,
            k.cantid_ori,
            CASE
                WHEN k.lote IS NULL THEN
                    '0'
                ELSE
                    k.lote
            END                      AS lote,
            k.fvenci,
            k.fmanuf,
            CASE
                WHEN k.nrocarrete IS NULL THEN
                    '0'
                ELSE
                    k.nrocarrete
            END                      AS nrocarrete,
            CASE
                WHEN k.acabado IS NULL THEN
                    '0'
                ELSE
                    k.acabado
            END                      AS acabado,
            cl1.descri               AS desadd01,
            cl2.descri               AS desadd02,
            k.chasis,
            k.motor
        BULK COLLECT
        INTO v_table
        FROM
            kardex001               k
            LEFT OUTER JOIN articulos               a ON a.id_cia = k.id_cia
                                           AND a.codart = k.codart
                                           AND a.tipinv = k.tipinv
            LEFT OUTER JOIN cliente_articulos_clase cl1 ON cl1.id_cia = a.id_cia
                                                           AND ( cl1.tipcli = 'B' )
                                                           AND ( cl1.codcli = a.codprv )
                                                           AND ( cl1.clase = 1 )
                                                           AND ( cl1.codigo = k.codadd01 )
            LEFT OUTER JOIN cliente_articulos_clase cl2 ON cl2.id_cia = a.id_cia
                                                           AND ( cl2.tipcli = 'B' )
                                                           AND ( cl2.codcli = a.codprv )
                                                           AND ( cl2.clase = 2 )
                                                           AND ( cl2.codigo = k.codadd01 )
        WHERE
                k.id_cia = pin_id_cia
            AND ( nvl(k.swacti, 0) <> 1 )
            AND ( ( k.ingreso - k.salida ) <> 0 )
            AND ( k.tipinv = pin_tipinv )
            AND ( k.codart = pin_codart )
            AND ( k.codalm = pin_codalm );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_help_eqtiquetas;

    FUNCTION sp_help_etiquetasv2 (
        pin_id_cia     NUMBER,
        pin_tipinv     NUMBER,
        pin_codart     VARCHAR2,
        pin_codalm     NUMBER,
        pin_etiqueta   VARCHAR2,
        pin_lote       VARCHAR2,
        pin_ancho      NUMBER,
        pin_nrocarrete VARCHAR2,
        pin_acabado    VARCHAR2,
        pin_chasis     VARCHAR2,
        pin_motor      VARCHAR2
    ) RETURN tbl_help_kardex001
        PIPELINED
    AS
        v_table tbl_help_kardex001;
    BEGIN
        SELECT
            k.etiqueta,
            k.ingreso - k.salida     AS saldo,
            a.coduni,
            k.kanban,
            k.codcli,
            k.opnumdoc,
            k.optramo,
            k.sucursal,
            CAST(k.fingreso AS DATE) AS fingreso,
            k.codadd01,
            k.codadd02,
            k.tipinv,
            k.codart,
            a.descri                 AS desart,
            a.consto,
            a.codprv,
            CASE
                WHEN k.ancho IS NULL THEN
                    0
                ELSE
                    k.ancho
            END                      AS ancho,
            CASE
                WHEN k.largo IS NULL THEN
                    0
                ELSE
                    k.largo
            END                      AS largo,
            k.combina,
            k.codalm,
            k.ubica,
            k.swacti,
            k.cantid_ori,
            CASE
                WHEN k.lote IS NULL THEN
                    '0'
                ELSE
                    k.lote
            END                      AS lote,
            k.fvenci,
            k.fmanuf,
            CASE
                WHEN k.nrocarrete IS NULL THEN
                    '0'
                ELSE
                    k.nrocarrete
            END                      AS nrocarrete,
            CASE
                WHEN k.acabado IS NULL THEN
                    '0'
                ELSE
                    k.acabado
            END                      AS acabado,
            cl1.descri               AS desadd01,
            cl2.descri               AS desadd02,
            k.chasis,
            k.motor
        BULK COLLECT
        INTO v_table
        FROM
            kardex001               k
            LEFT OUTER JOIN articulos               a ON a.id_cia = k.id_cia
                                           AND a.codart = k.codart
                                           AND a.tipinv = k.tipinv
            LEFT OUTER JOIN cliente_articulos_clase cl1 ON cl1.id_cia = a.id_cia
                                                           AND ( cl1.tipcli = 'B' )
                                                           AND ( cl1.codcli = a.codprv )
                                                           AND ( cl1.clase = 1 )
                                                           AND ( cl1.codigo = k.codadd01 )
            LEFT OUTER JOIN cliente_articulos_clase cl2 ON cl2.id_cia = a.id_cia
                                                           AND ( cl2.tipcli = 'B' )
                                                           AND ( cl2.codcli = a.codprv )
                                                           AND ( cl2.clase = 2 )
                                                           AND ( cl2.codigo = k.codadd01 )
        WHERE
                k.id_cia = pin_id_cia
            AND ( nvl(k.swacti, 0) <> 1 )
            AND ( ( k.ingreso - k.salida ) <> 0 )
            AND ( k.tipinv = pin_tipinv )
            AND ( k.codart = pin_codart )
            AND ( k.codalm = pin_codalm )
            AND ( k.etiqueta = pin_etiqueta
                  OR pin_etiqueta IS NULL )
            AND ( k.lote = pin_lote
                  OR pin_lote IS NULL )
            AND ( k.ancho = pin_ancho
                  OR ( pin_ancho IS NULL
                       OR pin_ancho = - 1 ) )
            AND ( k.nrocarrete = pin_nrocarrete
                  OR pin_nrocarrete IS NULL )
            AND ( k.acabado = pin_acabado
                  OR pin_acabado IS NULL )
            AND ( k.chasis = pin_chasis
                  OR pin_chasis IS NULL )
            AND ( k.motor = pin_motor
                  OR pin_motor IS NULL );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_help_etiquetasv2;

    FUNCTION sp_help_etiquetas_incluye_saldo_cero (
        pin_id_cia IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_codart IN VARCHAR2,
        pin_codalm IN NUMBER
    ) RETURN tbl_help_kardex001
        PIPELINED
    AS
        v_table tbl_help_kardex001;
    BEGIN
        SELECT
            k.etiqueta,
            k.ingreso - k.salida     AS saldo,
            a.coduni,
            k.kanban,
            k.codcli,
            k.opnumdoc,
            k.optramo,
            k.sucursal,
            CAST(k.fingreso AS DATE) AS fingreso,
            k.codadd01,
            k.codadd02,
            k.tipinv,
            k.codart,
            a.descri                 AS desart,
            a.consto,
            a.codprv,
            CASE
                WHEN k.ancho IS NULL THEN
                    0
                ELSE
                    k.ancho
            END                      AS ancho,
            CASE
                WHEN k.largo IS NULL THEN
                    0
                ELSE
                    k.largo
            END                      AS largo,
            k.combina,
            k.codalm,
            k.ubica,
            k.swacti,
            k.cantid_ori,
            CASE
                WHEN k.lote IS NULL THEN
                    '0'
                ELSE
                    k.lote
            END                      AS lote,
            k.fvenci,
            k.fmanuf,
            CASE
                WHEN k.nrocarrete IS NULL THEN
                    '0'
                ELSE
                    k.nrocarrete
            END                      AS nrocarrete,
            CASE
                WHEN k.acabado IS NULL THEN
                    '0'
                ELSE
                    k.acabado
            END                      AS acabado,
            cl1.descri               AS desadd01,
            cl2.descri               AS desadd02,
            k.chasis,
            k.motor
        BULK COLLECT
        INTO v_table
        FROM
            kardex001               k
            LEFT OUTER JOIN articulos               a ON a.id_cia = k.id_cia
                                           AND a.codart = k.codart
                                           AND a.tipinv = k.tipinv
            LEFT OUTER JOIN cliente_articulos_clase cl1 ON cl1.id_cia = a.id_cia
                                                           AND ( cl1.tipcli = 'B' )
                                                           AND ( cl1.codcli = a.codprv )
                                                           AND ( cl1.clase = 1 )
                                                           AND ( cl1.codigo = k.codadd01 )
            LEFT OUTER JOIN cliente_articulos_clase cl2 ON cl2.id_cia = a.id_cia
                                                           AND ( cl2.tipcli = 'B' )
                                                           AND ( cl2.codcli = a.codprv )
                                                           AND ( cl2.clase = 2 )
                                                           AND ( cl2.codigo = k.codadd01 )
        WHERE
                k.id_cia = pin_id_cia
            AND ( nvl(k.swacti, 0) <> 1 )
            AND ( k.tipinv = pin_tipinv )
            AND ( k.codart = pin_codart )
            AND ( k.codalm = pin_codalm );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_help_etiquetas_incluye_saldo_cero;

    FUNCTION sp_obtener_etiquetas (
        pin_id_cia     IN NUMBER,
        pin_codalm     IN NUMBER,
        pin_etiqueta   VARCHAR2,
        pin_checksaldo VARCHAR2
    ) RETURN datatable_obtener_etiqueta
        PIPELINED
    AS
        v_table datatable_obtener_etiqueta;
    BEGIN
        IF pin_checksaldo = 'S' OR pin_checksaldo IS NULL THEN
            SELECT
                k.etiqueta,
                CAST(abs(k.ingreso) - abs(k.salida) AS NUMERIC(16,
                     5))                 AS saldo,
                a.coduni,
                CAST(k.fingreso AS DATE) AS fingreso,
                CAST(k.fsalida AS DATE)  AS fsalida,
                k.codadd01,
                cc1.descri               AS dcodadd01,
                k.codadd02,
                cc2.descri               AS dcodadd02,
                k.tipinv,
                k.codart,
                a.descri                 AS desart,
                a.consto,
                a.codprv,
                k.ancho,
                k.codalm,
                k.ubica,
                k.swacti,
                k.cantid_ori,
                k.nrocarrete,
                k.lote,
                k.combina,
                k.empalme,
                k.diseno,
                k.acabado,
                k.fvenci,
                k.fmanuf,
                CASE
                    WHEN ac.codigo = '1' THEN
                        'true'
                    ELSE
                        'false'
                END                      AS activo,
                CAST((
                    CASE
                        WHEN act.codigo IS NULL THEN
                            '0'
                        ELSE
                            act.codigo
                    END
                ) AS INTEGER)            portolvnt,
                k.chasis,
                k.motor
            BULK COLLECT
            INTO v_table
            FROM
                kardex001               k
                LEFT OUTER JOIN articulos               a ON a.id_cia = k.id_cia
                                               AND a.codart = k.codart
                                               AND a.tipinv = k.tipinv
                LEFT OUTER JOIN articulos_clase         ac ON ac.id_cia = k.id_cia
                                                      AND ac.tipinv = k.tipinv
                                                      AND ac.codart = k.codart
                                                      AND ac.clase = 9
                LEFT OUTER JOIN articulos_clase         act ON act.id_cia = a.id_cia
                                                       AND act.tipinv = a.tipinv
                                                       AND act.codart = a.codart
                                                       AND act.clase = 28
                                                       AND act.codigo <> 'ND'
                LEFT OUTER JOIN cliente_articulos_clase cc1 ON cc1.id_cia = a.id_cia
                                                               AND cc1.tipcli = 'B'
                                                               AND cc1.codcli = a.codprv
                                                               AND cc1.clase = 1
                                                               AND cc1.codigo = k.codadd01
                LEFT OUTER JOIN cliente_articulos_clase cc2 ON cc2.id_cia = a.id_cia
                                                               AND cc2.tipcli = 'B'
                                                               AND cc2.codcli = a.codprv
                                                               AND cc2.clase = 2
                                                               AND cc2.codigo = k.codadd02
            WHERE
                    k.id_cia = pin_id_cia
                AND ac.codigo IS NOT NULL
                AND ( k.codalm = pin_codalm )
                AND k.etiqueta = pin_etiqueta
                AND ( k.ingreso - k.salida <> 0 )
            FETCH NEXT 1 ROWS ONLY;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSIF pin_checksaldo = 'N' THEN
            SELECT
                k.etiqueta,
                CAST(abs(k.ingreso) - abs(k.salida) AS NUMERIC(16,
                     5))                 AS saldo,
                a.coduni,
                CAST(k.fingreso AS DATE) AS fingreso,
                CAST(k.fsalida AS DATE)  AS fsalida,
                k.codadd01,
                cc1.descri               AS dcodadd01,
                k.codadd02,
                cc2.descri               AS dcodadd02,
                k.tipinv,
                k.codart,
                a.descri                 AS desart,
                a.consto,
                a.codprv,
                k.ancho,
                k.codalm,
                k.ubica,
                k.swacti,
                k.cantid_ori,
                k.nrocarrete,
                k.lote,
                k.combina,
                k.empalme,
                k.diseno,
                k.acabado,
                k.fvenci,
                k.fmanuf,
                CASE
                    WHEN ac.codigo = '1' THEN
                        'true'
                    ELSE
                        'false'
                END                      AS activo,
                CAST((
                    CASE
                        WHEN act.codigo IS NULL THEN
                            '0'
                        ELSE
                            act.codigo
                    END
                ) AS INTEGER)            portolvnt,
                k.chasis,
                k.motor
            BULK COLLECT
            INTO v_table
            FROM
                kardex001               k
                LEFT OUTER JOIN articulos               a ON a.id_cia = k.id_cia
                                               AND a.codart = k.codart
                                               AND a.tipinv = k.tipinv
                LEFT OUTER JOIN articulos_clase         ac ON ac.id_cia = k.id_cia
                                                      AND ac.tipinv = k.tipinv
                                                      AND ac.codart = k.codart
                                                      AND ac.clase = 9
                LEFT OUTER JOIN articulos_clase         act ON act.id_cia = a.id_cia
                                                       AND act.tipinv = a.tipinv
                                                       AND act.codart = a.codart
                                                       AND act.clase = 28
                                                       AND act.codigo <> 'ND'
                LEFT OUTER JOIN cliente_articulos_clase cc1 ON cc1.id_cia = a.id_cia
                                                               AND cc1.tipcli = 'B'
                                                               AND cc1.codcli = a.codprv
                                                               AND cc1.clase = 1
                                                               AND cc1.codigo = k.codadd01
                LEFT OUTER JOIN cliente_articulos_clase cc2 ON cc2.id_cia = a.id_cia
                                                               AND cc2.tipcli = 'B'
                                                               AND cc2.codcli = a.codprv
                                                               AND cc2.clase = 2
                                                               AND cc2.codigo = k.codadd02
            WHERE
                    k.id_cia = pin_id_cia
                AND ac.codigo IS NOT NULL
                AND ( k.codalm = pin_codalm )
                AND k.etiqueta = pin_etiqueta
            FETCH NEXT 1 ROWS ONLY;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        END IF;
    END sp_obtener_etiquetas;

    FUNCTION sp_resumen_tipinv (
        pin_id_cia     NUMBER,
        pin_tipinv     NUMBER,
        pin_desart     VARCHAR2,
        pin_checksaldo VARCHAR2
    ) RETURN datatable_resumen_tipinv
        PIPELINED
    AS
        v_table datatable_resumen_tipinv;
    BEGIN
        IF pin_checksaldo IS NULL OR pin_checksaldo = 'S' THEN
            SELECT
                a.codart,
                a.descri                      AS desart,
                a.tipinv,
                ti.dtipinv                    AS destipinv,
                a.codprv,
                SUM(k01.ingreso - k01.salida) AS stock,
                SUM(k01.ingreso)              AS ingreso,
                SUM(k01.salida)               AS salida,
                a.coduni
            BULK COLLECT
            INTO v_table
            FROM
                kardex001    k01
                LEFT OUTER JOIN articulos    a ON a.id_cia = k01.id_cia
                                               AND a.tipinv = k01.tipinv
                                               AND a.codart = k01.codart
                LEFT OUTER JOIN t_inventario ti ON ti.id_cia = k01.id_cia
                                                   AND ti.tipinv = k01.tipinv
            WHERE
                    k01.id_cia = pin_id_cia
                AND a.tipinv = pin_tipinv
                AND ( ( instr(upper(a.descri),
                              upper(pin_desart)) >= 1 )
                      OR pin_desart IS NULL )
            GROUP BY
                a.codart,
                a.descri,
                a.tipinv,
                ti.dtipinv,
                a.coduni,
                a.codprv
            HAVING
                SUM(k01.ingreso - k01.salida) > 0
            FETCH FIRST 1000 ROWS ONLY;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSIF pin_checksaldo = 'N' THEN
            SELECT
                a.codart,
                a.descri                      AS desart,
                a.tipinv,
                ti.dtipinv                    AS destipinv,
                a.codprv,
                SUM(k01.ingreso - k01.salida) AS stock,
                SUM(k01.ingreso)              AS ingreso,
                SUM(k01.salida)               AS salida,
                a.coduni
            BULK COLLECT
            INTO v_table
            FROM
                kardex001    k01
                LEFT OUTER JOIN articulos    a ON a.id_cia = k01.id_cia
                                               AND a.tipinv = k01.tipinv
                                               AND a.codart = k01.codart
                LEFT OUTER JOIN t_inventario ti ON ti.id_cia = k01.id_cia
                                                   AND ti.tipinv = k01.tipinv
            WHERE
                    k01.id_cia = pin_id_cia
                AND a.tipinv = pin_tipinv
                AND ( ( instr(upper(a.descri),
                              upper(pin_desart)) >= 1 )
                      OR pin_desart IS NULL )
            GROUP BY
                a.codart,
                a.descri,
                a.tipinv,
                ti.dtipinv,
                a.coduni,
                a.codprv
            FETCH FIRST 1000 ROWS ONLY;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        END IF;
    END sp_resumen_tipinv;

    FUNCTION sp_resumen_ancho (
        pin_id_cia     NUMBER,
        pin_tipinv     NUMBER,
        pin_codart     VARCHAR2,
        pin_ancho      NUMBER,
        pin_checksaldo VARCHAR2
    ) RETURN datatable_resumen_ancho
        PIPELINED
    AS
        v_table datatable_resumen_ancho;
    BEGIN
        IF pin_checksaldo IS NULL OR pin_checksaldo = 'S' THEN
            SELECT
                a.codart,
                a.descri                      AS desart,
                a.tipinv,
                ti.dtipinv                    AS destipinv,
                a.codprv,
                k01.ancho,
                SUM(k01.ingreso - k01.salida) AS stock,
                SUM(k01.ingreso)              AS ingreso,
                SUM(k01.salida)               AS salida,
                a.coduni
            BULK COLLECT
            INTO v_table
            FROM
                kardex001    k01
                LEFT OUTER JOIN articulos    a ON a.id_cia = k01.id_cia
                                               AND a.tipinv = k01.tipinv
                                               AND a.codart = k01.codart
                LEFT OUTER JOIN t_inventario ti ON ti.id_cia = k01.id_cia
                                                   AND ti.tipinv = k01.tipinv
            WHERE
                    k01.id_cia = pin_id_cia
                AND ( pin_tipinv IS NULL
                      OR a.tipinv = pin_tipinv )
                AND ( pin_codart IS NULL
                      OR a.codart = pin_codart )
                AND ( pin_ancho = - 1
                      OR pin_ancho IS NULL
                      OR ancho = pin_ancho )
            GROUP BY
                a.codart,
                a.descri,
                a.tipinv,
                ti.dtipinv,
                a.coduni,
                a.codprv,
                k01.ancho
            HAVING
                SUM(k01.ingreso - k01.salida) > 0
            ORDER BY
                k01.ancho DESC
            FETCH FIRST 1000 ROWS ONLY;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSIF pin_checksaldo = 'N' THEN
            SELECT
                a.codart,
                a.descri                      AS desart,
                a.tipinv,
                ti.dtipinv                    AS destipinv,
                a.codprv,
                k01.ancho,
                SUM(k01.ingreso - k01.salida) AS stock,
                SUM(k01.ingreso)              AS ingreso,
                SUM(k01.salida)               AS salida,
                a.coduni
            BULK COLLECT
            INTO v_table
            FROM
                kardex001    k01
                LEFT OUTER JOIN articulos    a ON a.id_cia = k01.id_cia
                                               AND a.tipinv = k01.tipinv
                                               AND a.codart = k01.codart
                LEFT OUTER JOIN t_inventario ti ON ti.id_cia = k01.id_cia
                                                   AND ti.tipinv = k01.tipinv
            WHERE
                    k01.id_cia = pin_id_cia
                AND ( pin_tipinv IS NULL
                      OR a.tipinv = pin_tipinv )
                AND ( pin_codart IS NULL
                      OR a.codart = pin_codart )
                AND ( pin_ancho = - 1
                      OR pin_ancho IS NULL
                      OR ancho = pin_ancho )
            GROUP BY
                a.codart,
                a.descri,
                a.tipinv,
                ti.dtipinv,
                a.coduni,
                a.codprv,
                k01.ancho
            ORDER BY
                k01.ancho DESC
            FETCH FIRST 1000 ROWS ONLY;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        END IF;
    END sp_resumen_ancho;

    FUNCTION sp_movimientos_etiqueta (
        pin_id_cia   NUMBER,
        pin_etiqueta VARCHAR2
    ) RETURN datatable_movimientos_etiqueta
        PIPELINED
    AS
        v_table datatable_movimientos_etiqueta;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    c.tipdoc,
                    c.numint,
                    CAST(k.numite AS INTEGER) AS numite,
                    c.codmot,
                    c.femisi,
                    c.numdoc,
                    c.series,
                    c.codcli,
                    c.razonc,
                    k.tipinv,
                    k.codart,
                    ar.descri                 AS desart,
                    k.cantid,
                    k.codalm,
                    k.id,
                    CASE
                        WHEN k.id IS NULL THEN
                            'NUL'
                        ELSE
                            CASE
                                WHEN upper(k.id) = 'I' THEN
                                        'ING'
                                ELSE
                                    CASE
                                        WHEN upper(k.id) = 'S' THEN
                                                    'SAL'
                                        ELSE
                                            'ERR'
                                    END
                            END
                    END                       AS abringsal,
                    CASE
                        WHEN ( k.id IS NULL )
                             OR ( k.tipdoc IS NULL )
                             OR ( k.tipdoc = 116 )
                             OR ( upper(k.id) = 'S' ) THEN
                            0
                        ELSE
                            k.cantid
                    END                       AS ingresos,
                    CASE
                        WHEN ( k.id IS NULL )
                             OR ( k.tipdoc IS NULL )
                             OR ( k.tipdoc = 116 )
                             OR ( upper(k.id) = 'I' ) THEN
                            0
                        ELSE
                            k.cantid
                    END                       AS salidas,
                    d.preuni,
                    d.importe,
                    c.tipmon,
                    c.codven,
                    v.desven,
                    mo.simbolo,
                    al.descri                 AS desalm,
                    al.abrevi                 AS abralm,
                    c.ordcom,
                    td.descri                 AS desdoc,
                    td.abrevi                 AS abrdoc,
                    s.dessit,
                    m.desmot,
                    au.codigo                 AS codubi,
                    au.descri                 AS desubi
                FROM
                    kardex            k
                    LEFT OUTER JOIN articulos         ar ON ar.id_cia = k.id_cia
                                                    AND ( ar.tipinv = k.tipinv )
                                                    AND ( ar.codart = k.codart )
                    LEFT OUTER JOIN documentos_det    d ON d.id_cia = k.id_cia
                                                        AND ( d.numint = k.numint )
                                                        AND ( d.numite = k.numite )
                    INNER JOIN documentos_cab    c ON c.id_cia = k.id_cia
                                                   AND ( c.numint = k.numint )
                    LEFT OUTER JOIN documentos        dc ON dc.id_cia = k.id_cia
                                                     AND ( dc.codigo = k.tipdoc )
                                                     AND ( dc.series = c.series )
                    LEFT OUTER JOIN situacion         s ON s.id_cia = k.id_cia
                                                   AND ( s.tipdoc = k.tipdoc
                                                         AND s.situac = c.situac )
                    LEFT OUTER JOIN almacen           al ON al.id_cia = k.id_cia
                                                  AND ( al.tipinv = k.tipinv
                                                        AND al.codalm = k.codalm )
                    LEFT OUTER JOIN almacen_ubicacion au ON au.id_cia = k.id_cia
                                                            AND ( au.tipinv = al.tipinv
                                                                  AND au.codalm = al.codalm
                                                                  AND au.codigo = k.ubica )
                    LEFT OUTER JOIN documentos_tipo   td ON td.id_cia = k.id_cia
                                                          AND ( td.tipdoc = d.tipdoc )
                    LEFT OUTER JOIN motivos           m ON m.id_cia = k.id_cia
                                                 AND ( m.codmot = k.codmot
                                                       AND m.id = k.id
                                                       AND m.tipdoc = k.tipdoc )
                    LEFT OUTER JOIN vendedor          v ON v.id_cia = k.id_cia
                                                  AND ( v.codven = c.codven )
                    LEFT OUTER JOIN tmoneda           mo ON mo.id_cia = k.id_cia
                                                  AND ( mo.codmon = c.tipmon )
                WHERE
                        k.id_cia = pin_id_cia
                    AND ( k.etiqueta = pin_etiqueta )
                UNION
                SELECT
                    c.tipdoc,
                    c.numint,
                    CAST(d.numite AS INTEGER) AS numite,
                    c.codmot,
                    c.femisi,
                    c.numdoc,
                    c.series,
                    c.codcli,
                    c.razonc,
                    CAST(d.tipinv AS INTEGER) AS tipinv,
                    d.codart,
                    ar.descri                 AS desart,
                    d.cantid,
                    CAST(d.codalm AS INTEGER) AS codalm,
                    c.id,
                    CASE
                        WHEN c.id IS NULL THEN
                            'NUL'
                        ELSE
                            CASE
                                WHEN upper(c.id) = 'I' THEN
                                        'ING'
                                ELSE
                                    CASE
                                        WHEN upper(c.id) = 'S' THEN
                                                    'SAL'
                                        ELSE
                                            'ERR'
                                    END
                            END
                    END                       AS abringsal,
                    CASE
                        WHEN ( c.id IS NULL )
                             OR ( c.tipdoc IS NULL )
                             OR ( c.tipdoc = 116 )
                             OR ( upper(c.id) = 'S' ) THEN
                            0
                        ELSE
                            d.cantid
                    END                       AS ingresos,
                    CASE
                        WHEN ( c.id IS NULL )
                             OR ( c.tipdoc IS NULL )
                             OR ( c.tipdoc = 116 )
                             OR ( upper(c.id) = 'I' ) THEN
                            0
                        ELSE
                            d.cantid
                    END                       AS salidas,
                    d.preuni,
                    d.importe,
                    CAST('' AS VARCHAR(5))    AS tipmon,
                    CAST(0 AS SMALLINT)       AS codven,
                    CAST('' AS VARCHAR(50))   AS desven,
                    CAST('' AS CHAR(3))       AS simbolo,
                    al.descri                 AS desalm,
                    al.abrevi                 AS abralm,
                    c.ordcom,
                    td.descri                 AS desdoc,
                    td.abrevi                 AS abrdoc,
                    s.dessit,
                    m.desmot,
                    au.codigo                 AS codubi,
                    au.descri                 AS desubi
                FROM
                    documentos_cab    c
                    LEFT OUTER JOIN documentos_det    d ON d.id_cia = c.id_cia
                                                        AND ( d.numint = c.numint )
                    LEFT OUTER JOIN articulos         ar ON ar.id_cia = c.id_cia
                                                    AND ( ar.tipinv = d.tipinv )
                                                    AND ( ar.codart = d.codart )
                    LEFT OUTER JOIN documentos        dc ON dc.id_cia = c.id_cia
                                                     AND ( dc.codigo = c.tipdoc )
                                                     AND ( dc.series = c.series )
                    LEFT OUTER JOIN documentos_tipo   td ON td.id_cia = c.id_cia
                                                          AND ( td.tipdoc = c.tipdoc )
                    LEFT OUTER JOIN situacion         s ON s.id_cia = c.id_cia
                                                   AND ( s.tipdoc = c.tipdoc
                                                         AND s.situac = c.situac )
                    LEFT OUTER JOIN almacen           al ON al.id_cia = c.id_cia
                                                  AND ( al.tipinv = d.tipinv
                                                        AND al.codalm = d.codalm )
                    LEFT OUTER JOIN almacen_ubicacion au ON au.id_cia = c.id_cia
                                                            AND ( au.tipinv = al.tipinv
                                                                  AND au.codalm = al.codalm
                                                                  AND au.codigo = d.ubica )
                    LEFT OUTER JOIN motivos           m ON m.id_cia = c.id_cia
                                                 AND ( m.codmot = c.codmot
                                                       AND m.id = c.id
                                                       AND m.tipdoc = c.tipdoc )
                WHERE
                        c.id_cia = pin_id_cia
                    AND ( d.etiqueta = pin_etiqueta )
                    AND ( c.tipdoc = 116 )
                    AND ( c.situac IN ( 'F' ) )
                FETCH FIRST 1000 ROWS ONLY
            )
        ORDER BY
            femisi DESC,
            id ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END;

END pack_kardex001;

/
