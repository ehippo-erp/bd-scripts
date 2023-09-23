--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_RELACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_RELACION" AS

    FUNCTION sp_detalle_relacion (
        pin_id_cia  NUMBER,
        pin_numints VARCHAR2
    ) RETURN datatable_detalle_relacion
        PIPELINED
    AS
        v_rec datarecord_detalle_relacion;
    BEGIN
--        FOR k IN (
--            SELECT
--                column_value AS numint
--            FROM
--                TABLE ( convert_in(pin_numints) )
--        ) LOOP
        FOR i IN (
            SELECT DISTINCT
                c.numint as numintre,
                c.numdoc,
                c.series,
                c.tipdoc
            FROM
                documentos_cab c
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numint IN (
                    SELECT
                        column_value AS numint
                    FROM
                        TABLE ( convert_in(pin_numints) )
                )
        ) LOOP
            v_rec.id_cia := pin_id_cia;
            v_rec.numintre := i.numintre;
            v_rec.numdocre := i.numdoc;
            v_rec.seriesre := i.series;
            v_rec.tipdocre := i.tipdoc;
--      INTO :NUMINTRE,:NUMDOCRE,:SERIESRE,:TIPDOCRE DO
            FOR j IN (
                SELECT
--                        d.numint,
                    d.numite,
                    d.cantid            AS det_cantid,
                    abs(SUM(nvl(en.entreg,0))) AS cantid
                FROM
                    documentos_det d
                    LEFT OUTER JOIN documentos_ent en ON en.id_cia = d.id_cia
                                                         AND en.opnumdoc = d.numint
                                                         AND en.opnumite = d.numite
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.numint = v_rec.numintre
                GROUP BY
--                        d.numint,
                    d.numite,
                    d.cantid
                HAVING
                    ( d.cantid - abs(SUM(nvl(en.entreg,0))) ) > 0
            ) LOOP
                v_rec.numitere := j.numite;
--        v_rec.wcantid := j.cantid;
--            INTO :NUMITERE,:WCANTID
--        DO
                BEGIN
                    SELECT
                        d.tipinv,
                        t.dtipinv,
                        d.codart,
                        a.descri,
                        d.cantid,
                        d.cantid - j.cantid,
                        (
                            CASE
                                WHEN aca.vreal IS NULL THEN
                                    1
                                ELSE
                                    aca.vreal
                            END
                        ) * ( d.cantid - j.cantid ),
                        d.codund,
                        d.preuni,
                        d.pordes1,
                        d.pordes2,
                        d.pordes3,
                        d.pordes4,
                        d.codadd01,
                        ca1.descri,
                        d.codadd02,
                        ca2.descri
                    INTO
                        v_rec.tipinv,
                        v_rec.dtipinv,
                        v_rec.codart,
                        v_rec.desart,
                        v_rec.pedido,
                        v_rec.cantid,
                        v_rec.cantidalt,
                        v_rec.coduni,
                        v_rec.preuni,
                        v_rec.pordes1,
                        v_rec.pordes2,
                        v_rec.pordes3,
                        v_rec.pordes4,
                        v_rec.codadd01,
                        v_rec.dcodadd01,
                        v_rec.codadd02,
                        v_rec.dcodadd02
                    FROM
                        documentos_det              d
                        LEFT OUTER JOIN t_inventario                t ON t.id_cia = d.id_cia
                                                          AND t.tipinv = d.tipinv
                        LEFT OUTER JOIN articulos                   a ON a.id_cia = d.id_cia
                                                       AND a.tipinv = d.tipinv
                                                       AND a.codart = d.codart
                        LEFT OUTER JOIN cliente_articulos_clase     ca1 ON ca1.id_cia = d.id_cia
                                                                       AND ca1.tipcli = 'B'
                                                                       AND ca1.codcli = a.codprv
                                                                       AND ca1.clase = 1
                                                                       AND ca1.codigo = d.codadd01
                        LEFT OUTER JOIN cliente_articulos_clase     ca2 ON ca2.id_cia = d.id_cia
                                                                       AND ca2.tipcli = 'B'
                                                                       AND ca2.codcli = a.codprv
                                                                       AND ca2.clase = 2
                                                                       AND ca2.codigo = d.codadd02
                        LEFT OUTER JOIN articulos_clase_alternativo aca ON aca.id_cia = d.id_cia
                                                                           AND aca.tipinv = d.tipinv
                                                                           AND aca.codart = d.codart
                                                                           AND aca.clase = 2
                                                                           AND aca.codigo = d.codund
                    WHERE
--                    d.numint = :numintre
--                AND d.numite = :numitere;
                            d.id_cia = pin_id_cia
                        AND d.numint = v_rec.numintre
                        AND d.numite = v_rec.numitere;

                    PIPE ROW ( v_rec );
                END;
--      INTO :TIPINV,:CODART,
--           :PREUNI,:PORDES1,:PORDES2,:PORDES3,:PORDES4,
--           :CODADD01,:CODADD02,:DESART,:PEDIDO,:CANTID,:CANTIDALT,:DCODADD01,:DCODADD02,:CODUNI;

            END LOOP;

        END LOOP;
--        END LOOP;
    END sp_detalle_relacion;

END;

/
