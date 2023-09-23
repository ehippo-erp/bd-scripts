--------------------------------------------------------
--  DDL for Package Body PACK_CUBO_KARDEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CUBO_KARDEX" AS

    FUNCTION sp_cubo_kardex001 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_kardex001
        PIPELINED
    AS
        pin_pdesde NUMBER := 0;
        pin_phasta NUMBER := 0;
        v_table    datatable_cubo_kardex001;
    BEGIN
        pin_pdesde := extract(YEAR FROM pin_fdesde) * 100 + extract(MONTH FROM pin_fdesde);

        pin_phasta := extract(YEAR FROM pin_fhasta) * 100 + extract(MONTH FROM pin_fhasta);

        SELECT
            k.id_cia,
            CAST(substr(TRIM(to_char(k.periodo, '000000')), 0, 4) AS NUMBER) AS periodo,
            CAST(substr(TRIM(to_char(k.periodo, '000000')), 5, 2) AS NUMBER) AS idmes,
            CASE
                WHEN substr(TRIM(to_char(k.periodo, '000000')), 5, 2) = '00' THEN
                    '00 - APERTURA'
                ELSE
                    substr(TRIM(to_char(k.periodo, '000000')), 5, 2)
                    || ' - '
                    || to_char(to_date('01/'
                                       || substr(TRIM(to_char(k.periodo, '000000')), 5, 2)
                                       || '/00', 'DD/MM/YY'), 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH')
            END                                                              AS mes,
            c.numdoc                                                         AS numdoc,
            c.series                                                         AS series,
            d.descri                                                         AS dtipdoc,
            k.codalm,
            al.descri                                                        AS desalm,
            k.ubica                                                          AS codubi,
            au.descri                                                        AS desubi,
            k.tipinv,
            ti.dtipinv,
            k.codart,
            a.descri                                                         AS desart,
            k.cantid,
            k.codadd01,
            c1.descri                                                        AS dcodadd01,
            k.codadd02,
            c2.descri                                                        AS dcodadd02,
            CAST((
                CASE
                    WHEN a.faccon > 0 THEN
                        (k.cantid * a.faccon / 1000)
                    ELSE
                        (
                            CASE
                                WHEN ks.kilosunit IS NULL THEN
                                    0
                                ELSE
                                    (ks.kilosunit * k.cantid) / 1000
                            END
                        )
                END
            ) AS NUMERIC(10, 3))                                             AS toneladas,
            k.codcli,
            cl.razonc,
            k.codmot,
            k.cosfab01,
            k.cosmat01,
            k.cosmob01,
            k.costot01,
            k.costot02,
            CASE
                WHEN nvl(k.cantid, 0) <> 0 THEN
                    k.costot01 / k.cantid
                ELSE
                    0
            END                                                              AS cosuni01,
            CASE
                WHEN nvl(k.cantid, 0) <> 0 THEN
                    k.costot02 / k.cantid
                ELSE
                    0
            END                                                              AS cosuni02,
            k.etiqueta,
            k.factua,
            k.fcreac,
            k.femisi,
            k.fobtot01,
            k.fobtot02,
            k.id,
            k.movimiento,
            k.numint,
            k.numite,
            k.opcargo,
            k.opcodart,
            k.opnumdoc,
            k.opnumite,
            k.optipinv,
            k.optramo,
            k.royos,
            k.situac,
            k.swacti,
            k.tipcam,
            k.tipdoc,
            k.usuari,
            k1.ancho,
            m.desmot                                                         AS motivo
        BULK COLLECT
        INTO v_table
        FROM
            kardex                  k
            LEFT OUTER JOIN documentos_cab          c ON c.id_cia = k.id_cia
                                                AND c.numint = k.numint
            LEFT OUTER JOIN kardex001               k1 ON k1.id_cia = k.id_cia
                                            AND k1.tipinv = k.tipinv
                                            AND k1.codart = k.codart
                                            AND k1.codalm = k.codalm
                                            AND k1.etiqueta = k.etiqueta
            LEFT OUTER JOIN almacen                 al ON al.id_cia = k.id_cia
                                          AND al.tipinv = k.tipinv
                                          AND al.codalm = k.codalm
            LEFT OUTER JOIN t_inventario            ti ON ti.id_cia = k.id_cia
                                               AND ti.tipinv = k.tipinv
            LEFT OUTER JOIN articulos               a ON a.id_cia = k.id_cia
                                           AND a.tipinv = k.tipinv
                                           AND a.codart = k.codart
            LEFT OUTER JOIN documentos_tipo         d ON d.id_cia = k.id_cia
                                                 AND d.tipdoc = k.tipdoc
            LEFT OUTER JOIN motivos                 m ON m.id_cia = k.id_cia
                                         AND m.tipdoc = k.tipdoc
                                         AND m.codmot = k.codmot
                                         AND m.id = k.id
            LEFT OUTER JOIN kilos_unitario          ks ON ks.id_cia = k.id_cia
                                                 AND ks.tipinv = k.tipinv
                                                 AND ks.codart = k.codart
                                                 AND ks.etiqueta = k.etiqueta
            LEFT OUTER JOIN cliente                 cl ON cl.id_cia = k.id_cia
                                          AND cl.codcli = k.codcli
            LEFT OUTER JOIN cliente_articulos_clase c1 ON c1.id_cia = k.id_cia
                                                          AND c1.tipcli = 'B'
                                                          AND c1.codcli = a.codprv
                                                          AND c1.clase = 1
                                                          AND c1.codigo = k.codadd01
            LEFT OUTER JOIN cliente_articulos_clase c2 ON c2.id_cia = k.id_cia
                                                          AND c2.tipcli = 'B'
                                                          AND c2.codcli = a.codprv
                                                          AND c2.clase = 2
                                                          AND c2.codigo = k.codadd02
            LEFT OUTER JOIN almacen_ubicacion       au ON au.id_cia = k.id_cia
                                                    AND au.tipinv = k.tipinv
                                                    AND au.codalm = k.codalm
                                                    AND au.codigo = k.ubica
        WHERE
                k.id_cia = pin_id_cia
            AND k.femisi BETWEEN pin_fdesde AND pin_fhasta;
--            AND k.periodo BETWEEN pin_pdesde AND pin_phasta;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cubo_kardex001;

    FUNCTION sp_cubo_kardex002 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_kardex002
        PIPELINED
    AS
        pin_pdesde NUMBER := 0;
        pin_phasta NUMBER := 0;
        v_table    datatable_cubo_kardex002;
    BEGIN
        pin_pdesde := extract(YEAR FROM pin_fdesde) * 100 + extract(MONTH FROM pin_fdesde);

        pin_phasta := extract(YEAR FROM pin_fhasta) * 100 + extract(MONTH FROM pin_fhasta);

        SELECT
--            k.id_cia,
            CAST(substr(TRIM(to_char(k.periodo, '000000')), 0, 4) AS NUMBER) AS periodo,
            CAST(substr(TRIM(to_char(k.periodo, '000000')), 5, 2) AS NUMBER) AS idmes,
            CASE
                WHEN substr(TRIM(to_char(k.periodo, '000000')), 5, 2) = '00' THEN
                    '00 - APERTURA'
                ELSE
                    substr(TRIM(to_char(k.periodo, '000000')), 5, 2)
                    || ' - '
                    || to_char(to_date('01/'
                                       || substr(TRIM(to_char(k.periodo, '000000')), 5, 2)
                                       || '/00', 'DD/MM/YY'), 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH')
            END                                                              AS mes,
            to_char(k.femisi, 'DD/MM/YYYY'),
            c.numdoc                                                         AS numdoc,
            c.series                                                         AS series,
            d.descri                                                         AS dtipdoc,
            k.codalm,
            al.descri                                                        AS desalm,
            k.ubica                                                          AS codubi,
            au.descri                                                        AS desubi,
            k.codcli,
            cl.razonc,
            k.tipinv,
            ti.dtipinv,
            k.codart,
            a.descri                                                         AS desart,
            k.codmot,
            m.desmot                                                         AS motivo,
            k.id,
            CASE
                WHEN k.id = 'I' THEN
                    'INGRESO'
                WHEN k.id = 'S' THEN
                    'SALIDA'
            END                                                              AS tipo,
            k.cantid,
            k.costot01,
            k.costot02,
            CASE
                WHEN nvl(k.cantid, 0) <> 0 THEN
                    k.costot01 / k.cantid
                ELSE
                    0
            END                                                              AS cosuni01,
            CASE
                WHEN nvl(k.cantid, 0) <> 0 THEN
                    k.costot02 / k.cantid
                ELSE
                    0
            END                                                              AS cosuni02,
            k.etiqueta,
            k1.nrocarrete,
            k1.lote,
            k1.ancho                                                         AS dioptria,
            to_char(k1.fvenci, 'DD/MM/YYYY'),
            k.numint,
            k.numite,
            k.tipcam,
            k.usuari
        BULK COLLECT
        INTO v_table
        FROM
            kardex            k
            LEFT OUTER JOIN documentos_cab    c ON c.id_cia = k.id_cia
                                                AND c.numint = k.numint
            LEFT OUTER JOIN kardex001         k1 ON k1.id_cia = k.id_cia
                                            AND k1.tipinv = k.tipinv
                                            AND k1.codart = k.codart
                                            AND k1.codalm = k.codalm
                                            AND k1.etiqueta = k.etiqueta
            LEFT OUTER JOIN almacen           al ON al.id_cia = k.id_cia
                                          AND al.tipinv = k.tipinv
                                          AND al.codalm = k.codalm
            LEFT OUTER JOIN t_inventario      ti ON ti.id_cia = k.id_cia
                                               AND ti.tipinv = k.tipinv
            LEFT OUTER JOIN articulos         a ON a.id_cia = k.id_cia
                                           AND a.tipinv = k.tipinv
                                           AND a.codart = k.codart
            LEFT OUTER JOIN documentos_tipo   d ON d.id_cia = k.id_cia
                                                 AND d.tipdoc = k.tipdoc
            LEFT OUTER JOIN motivos           m ON m.id_cia = k.id_cia
                                         AND m.tipdoc = k.tipdoc
                                         AND m.codmot = k.codmot
                                         AND m.id = k.id
--            LEFT OUTER JOIN kilos_unitario          ks ON ks.id_cia = k.id_cia
--                                                 AND ks.tipinv = k.tipinv
--                                                 AND ks.codart = k.codart
--                                                 AND ks.etiqueta = k.etiqueta
            LEFT OUTER JOIN cliente           cl ON cl.id_cia = k.id_cia
                                          AND cl.codcli = k.codcli
            LEFT OUTER JOIN almacen_ubicacion au ON au.id_cia = k.id_cia
                                                    AND au.tipinv = k.tipinv
                                                    AND au.codalm = k.codalm
                                                    AND au.codigo = k.ubica
        WHERE
                k.id_cia = pin_id_cia
            AND k.femisi BETWEEN pin_fdesde AND pin_fhasta;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cubo_kardex002;

    FUNCTION sp_cubo_kardex003 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_kardex003
        PIPELINED
    AS
        pin_pdesde NUMBER := 0;
        pin_phasta NUMBER := 0;
        v_table    datatable_cubo_kardex003;
    BEGIN
        pin_pdesde := extract(YEAR FROM pin_fdesde) * 100 + extract(MONTH FROM pin_fdesde);

        pin_phasta := extract(YEAR FROM pin_fhasta) * 100 + extract(MONTH FROM pin_fhasta);

        SELECT
--            k.id_cia,
            CAST(substr(TRIM(to_char(k.periodo, '000000')), 0, 4) AS NUMBER) AS periodo,
            CAST(substr(TRIM(to_char(k.periodo, '000000')), 5, 2) AS NUMBER) AS idmes,
            CASE
                WHEN substr(TRIM(to_char(k.periodo, '000000')), 5, 2) = '00' THEN
                    '00 - APERTURA'
                ELSE
                    substr(TRIM(to_char(k.periodo, '000000')), 5, 2)
                    || ' - '
                    || to_char(to_date('01/'
                                       || substr(TRIM(to_char(k.periodo, '000000')), 5, 2)
                                       || '/00', 'DD/MM/YY'), 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH')
            END                                                              AS mes,
            to_char(k.femisi, 'DD/MM/YYYY'),
            c.numdoc                                                         AS numdoc,
            c.series                                                         AS series,
            d.descri                                                         AS dtipdoc,
            k.codalm,
            al.descri                                                        AS desalm,
            k.ubica                                                          AS codubi,
            au.descri                                                        AS desubi,
            k.codcli,
            cl.razonc,
            k.tipinv,
            ti.dtipinv,
            k.codart,
            a.descri                                                         AS desart,
            k.codmot,
            m.desmot                                                         AS motivo,
            k.id,
            CASE
                WHEN k.id = 'I' THEN
                    'INGRESO'
                WHEN k.id = 'S' THEN
                    'SALIDA'
            END                                                              AS tipo,
            k.cantid,
            k.costot01,
            k.costot02,
            CASE
                WHEN nvl(k.cantid, 0) <> 0 THEN
                    k.costot01 / k.cantid
                ELSE
                    0
            END                                                              AS cosuni01,
            CASE
                WHEN nvl(k.cantid, 0) <> 0 THEN
                    k.costot02 / k.cantid
                ELSE
                    0
            END                                                              AS cosuni02,
            k.etiqueta,
            k1.chasis,
            k1.motor,
            k.numint,
            k.numite,
            k.tipcam,
            k.usuari
        BULK COLLECT
        INTO v_table
        FROM
            kardex            k
            LEFT OUTER JOIN documentos_cab    c ON c.id_cia = k.id_cia
                                                AND c.numint = k.numint
            LEFT OUTER JOIN kardex001         k1 ON k1.id_cia = k.id_cia
                                            AND k1.tipinv = k.tipinv
                                            AND k1.codart = k.codart
                                            AND k1.codalm = k.codalm
                                            AND k1.etiqueta = k.etiqueta
            LEFT OUTER JOIN almacen           al ON al.id_cia = k.id_cia
                                          AND al.tipinv = k.tipinv
                                          AND al.codalm = k.codalm
            LEFT OUTER JOIN t_inventario      ti ON ti.id_cia = k.id_cia
                                               AND ti.tipinv = k.tipinv
            LEFT OUTER JOIN articulos         a ON a.id_cia = k.id_cia
                                           AND a.tipinv = k.tipinv
                                           AND a.codart = k.codart
            LEFT OUTER JOIN documentos_tipo   d ON d.id_cia = k.id_cia
                                                 AND d.tipdoc = k.tipdoc
            LEFT OUTER JOIN motivos           m ON m.id_cia = k.id_cia
                                         AND m.tipdoc = k.tipdoc
                                         AND m.codmot = k.codmot
                                         AND m.id = k.id
--            LEFT OUTER JOIN kilos_unitario          ks ON ks.id_cia = k.id_cia
--                                                 AND ks.tipinv = k.tipinv
--                                                 AND ks.codart = k.codart
--                                                 AND ks.etiqueta = k.etiqueta
            LEFT OUTER JOIN cliente           cl ON cl.id_cia = k.id_cia
                                          AND cl.codcli = k.codcli
            LEFT OUTER JOIN almacen_ubicacion au ON au.id_cia = k.id_cia
                                                    AND au.tipinv = k.tipinv
                                                    AND au.codalm = k.codalm
                                                    AND au.codigo = k.ubica
        WHERE
                k.id_cia = pin_id_cia
            AND k.femisi BETWEEN pin_fdesde AND pin_fhasta;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cubo_kardex003;

    FUNCTION sp_cubo_kardex004 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_kardex004
        PIPELINED
    AS
        pin_pdesde NUMBER := 0;
        pin_phasta NUMBER := 0;
        v_table    datatable_cubo_kardex004;
    BEGIN
        pin_pdesde := extract(YEAR FROM pin_fdesde) * 100 + extract(MONTH FROM pin_fdesde);

        pin_phasta := extract(YEAR FROM pin_fhasta) * 100 + extract(MONTH FROM pin_fhasta);

        SELECT
--            k.id_cia,
            CAST(substr(TRIM(to_char(k.periodo, '000000')), 0, 4) AS NUMBER) AS periodo,
            CAST(substr(TRIM(to_char(k.periodo, '000000')), 5, 2) AS NUMBER) AS idmes,
            CASE
                WHEN substr(TRIM(to_char(k.periodo, '000000')), 5, 2) = '00' THEN
                    '00 - APERTURA'
                ELSE
                    substr(TRIM(to_char(k.periodo, '000000')), 5, 2)
                    || ' - '
                    || to_char(to_date('01/'
                                       || substr(TRIM(to_char(k.periodo, '000000')), 5, 2)
                                       || '/00', 'DD/MM/YY'), 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH')
            END                                                              AS mes,
            to_char(k.femisi, 'DD/MM/YYYY'),
            c.numdoc                                                         AS numdoc,
            c.series                                                         AS series,
            d.descri                                                         AS dtipdoc,
            k.codalm,
            al.descri                                                        AS desalm,
            k.ubica                                                          AS codubi,
            au.descri                                                        AS desubi,
            k.codcli,
            cl.razonc,
            k.tipinv,
            ti.dtipinv,
            k.codart,
            a.descri                                                         AS desart,
            k.codmot,
            m.desmot                                                         AS motivo,
            k.id,
            CASE
                WHEN k.id = 'I' THEN
                    'INGRESO'
                WHEN k.id = 'S' THEN
                    'SALIDA'
            END                                                              AS tipo,
            k.cantid,
            k.costot01,
            k.costot02,
            CASE
                WHEN nvl(k.cantid, 0) <> 0 THEN
                    k.costot01 / k.cantid
                ELSE
                    0
            END                                                              AS cosuni01,
            CASE
                WHEN nvl(k.cantid, 0) <> 0 THEN
                    k.costot02 / k.cantid
                ELSE
                    0
            END                                                              AS cosuni02,
            k.etiqueta,
            k.numint,
            k.numite,
            k.tipcam,
            k.usuari
        BULK COLLECT
        INTO v_table
        FROM
            kardex            k
            LEFT OUTER JOIN documentos_cab    c ON c.id_cia = k.id_cia
                                                AND c.numint = k.numint
            LEFT OUTER JOIN kardex001         k1 ON k1.id_cia = k.id_cia
                                            AND k1.tipinv = k.tipinv
                                            AND k1.codart = k.codart
                                            AND k1.codalm = k.codalm
                                            AND k1.etiqueta = k.etiqueta
            LEFT OUTER JOIN almacen           al ON al.id_cia = k.id_cia
                                          AND al.tipinv = k.tipinv
                                          AND al.codalm = k.codalm
            LEFT OUTER JOIN t_inventario      ti ON ti.id_cia = k.id_cia
                                               AND ti.tipinv = k.tipinv
            LEFT OUTER JOIN articulos         a ON a.id_cia = k.id_cia
                                           AND a.tipinv = k.tipinv
                                           AND a.codart = k.codart
            LEFT OUTER JOIN documentos_tipo   d ON d.id_cia = k.id_cia
                                                 AND d.tipdoc = k.tipdoc
            LEFT OUTER JOIN motivos           m ON m.id_cia = k.id_cia
                                         AND m.tipdoc = k.tipdoc
                                         AND m.codmot = k.codmot
                                         AND m.id = k.id
            LEFT OUTER JOIN cliente           cl ON cl.id_cia = k.id_cia
                                          AND cl.codcli = k.codcli
            LEFT OUTER JOIN almacen_ubicacion au ON au.id_cia = k.id_cia
                                                    AND au.tipinv = k.tipinv
                                                    AND au.codalm = k.codalm
                                                    AND au.codigo = k.ubica
        WHERE
                k.id_cia = pin_id_cia
            AND k.femisi BETWEEN pin_fdesde AND pin_fhasta;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cubo_kardex004;

END;

/
