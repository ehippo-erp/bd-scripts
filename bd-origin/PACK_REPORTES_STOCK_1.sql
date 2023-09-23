--------------------------------------------------------
--  DDL for Package Body PACK_REPORTES_STOCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_REPORTES_STOCK" AS

    FUNCTION sp_etiquetas_familia_linea (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codalm NUMBER,
        pin_ubica  NUMBER,
        pin_codart VARCHAR2,
        pin_codfam VARCHAR2,
        pin_codlin VARCHAR2,
        pin_codprv VARCHAR2,
        pin_solneg VARCHAR2
    ) RETURN datatable_etiquetas_familia_linea
        PIPELINED
    AS
        v_table datatable_etiquetas_familia_linea;
    BEGIN
        SELECT
            k01.id_cia,
            k01.tipinv,
            t.dtipinv,
            k01.codalm,
            al.descri                                AS desalm,
            k01.ubica,
            au.descri                                AS desubi,
            k01.codart,
            a.descri                                 AS desart,
            cc2.codigo,
            cc2.descodigo,
            cc3.codigo,
            cc3.descodigo,
            k01.codadd01,
            ca1.descri,
            k01.codadd02,
            ca2.descri,
            SUM(k01.ingreso - k01.salida)            AS stock,
            COUNT(k01.etiqueta),
            a.coduni,
            k01.ancho,
            k01.largo,
            k01.codcli,
            cl.razonc,
            SUM((
                CASE
                    WHEN length(TRIM(k01.codadd01)) IS NULL
                         OR length(TRIM(k01.codadd02)) IS NULL THEN
                        decode(nvl(ac.cantid, 0), 0, 0, ac.costo01 / ac.cantid)
                    ELSE
                        decode(nvl(acc.cantid, 0), 0, 0, acc.costo01 / acc.cantid)
                END
            ) *(k01.ingreso - k01.salida))           AS costot01,
            SUM((
                CASE
                    WHEN length(TRIM(k01.codadd01)) IS NULL
                         OR length(TRIM(k01.codadd02)) IS NULL THEN
                        decode(nvl(ac.cantid, 0), 0, 0, ac.costo02 / ac.cantid)
                    ELSE
                        decode(nvl(acc.cantid, 0), 0, 0, acc.costo02 / acc.cantid)
                END
            ) *(k01.ingreso - k01.salida))           AS costot02,
            current_date                             AS dia,
            to_char(current_timestamp, 'HH24:MI:SS') AS hora
        BULK COLLECT
        INTO v_table
        FROM
            kardex001                                                                    k01
            LEFT OUTER JOIN cliente                                                                      cl ON cl.id_cia = k01.id_cia
                                          AND cl.codcli = k01.codcli
            LEFT OUTER JOIN t_inventario                                                                 t ON t.id_cia = k01.id_cia
                                              AND t.tipinv = k01.tipinv
            LEFT OUTER JOIN articulos                                                                    a ON a.id_cia = k01.id_cia
                                           AND a.tipinv = k01.tipinv
                                           AND a.codart = k01.codart
            LEFT OUTER JOIN almacen                                                                      al ON al.id_cia = k01.id_cia
                                          AND al.tipinv = k01.tipinv
                                          AND al.codalm = k01.codalm
            LEFT OUTER JOIN almacen_ubicacion                                                            au ON au.id_cia = k01.id_cia
                                                    AND au.tipinv = k01.tipinv
                                                    AND au.codalm = k01.codalm
                                                    AND au.codigo = k01.ubica
            LEFT OUTER JOIN cliente_articulos_clase                                                      ca1 ON ca1.id_cia = k01.id_cia
                                                           AND ca1.tipcli = 'B'
                                                           AND ca1.codcli = a.codprv
                                                           AND ca1.clase = 1
                                                           AND ca1.codigo = k01.codadd01
            LEFT OUTER JOIN cliente_articulos_clase                                                      ca2 ON ca2.id_cia = k01.id_cia
                                                           AND ca2.tipcli = 'B'
                                                           AND ca2.codcli = a.codprv
                                                           AND ca2.clase = 2
                                                           AND ca2.codigo = k01.codadd02
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(k01.id_cia, k01.tipinv, k01.codart, 2) cc2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(k01.id_cia, k01.tipinv, k01.codart, 3) cc3 ON 0 = 0
            LEFT OUTER JOIN articulos_costo                                                              ac ON ac.id_cia = k01.id_cia
                                                  AND ac.tipinv = k01.tipinv
                                                  AND ac.codart = k01.codart
                                                  AND ac.periodo = EXTRACT(YEAR FROM current_date) * 100 + EXTRACT(MONTH FROM current_date)
            LEFT OUTER JOIN articulos_costo_codadd                                                       acc ON acc.id_cia = k01.id_cia
                                                         AND acc.tipinv = k01.tipinv
                                                         AND acc.codart = k01.codart
                                                         AND acc.codadd01 = k01.codadd01
                                                         AND acc.codadd02 = k01.codadd02
                                                         AND acc.periodo = EXTRACT(YEAR FROM current_date) * 100 + EXTRACT(MONTH FROM current_date)
        WHERE
                k01.id_cia = pin_id_cia
            AND ( nvl(pin_tipinv, - 1) = - 1
                  OR k01.tipinv = pin_tipinv )
            AND ( pin_codart IS NULL
                  OR k01.codart = pin_codart )
            AND ( nvl(pin_codalm, - 1) = - 1
                  OR k01.codalm = pin_codalm )
            AND ( nvl(pin_ubica, - 1) = - 1
                  OR k01.ubica = pin_ubica )
            AND ( ( k01.ingreso - k01.salida ) <> 0 )
            AND ( k01.swacti = 0 )
            AND ( pin_codprv IS NULL
                  OR a.codprv = pin_codprv )
            AND ( pin_codfam IS NULL
                  OR cc2.codigo = pin_codfam )
            AND ( pin_codlin IS NULL
                  OR cc3.codigo = pin_codlin )
        GROUP BY
            k01.id_cia,
            k01.tipinv,
            t.dtipinv,
            k01.codalm,
            al.descri,
            k01.ubica,
            au.descri,
            k01.codart,
            a.descri,
            cc2.codigo,
            cc2.descodigo,
            cc3.codigo,
            cc3.descodigo,
            k01.codadd01,
            ca1.descri,
            k01.codadd02,
            ca2.descri,
            a.coduni,
            k01.ancho,
            k01.largo,
            k01.codcli,
            cl.razonc,
            current_date,
            to_char(current_timestamp, 'HH24:MI:SS');

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_etiquetas_familia_linea;

END;

/
