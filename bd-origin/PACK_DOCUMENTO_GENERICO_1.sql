--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTO_GENERICO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTO_GENERICO" AS

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN datatable_documento_generico
        PIPELINED
    AS
        v_table datatable_documento_generico;
    BEGIN
        SELECT
            c.*,
            s.dessit     AS dessituac,
            d.codcli     AS dd_codcli,
            d.numint     AS dd_numint,
            d.numite     AS dd_numite,
            d.tipinv     AS dd_tipinv,
            d.codart     AS dd_codart,
            a.descri     AS dd_desart,
            d.preuni     AS dd_preuni,
            d.importe    AS dd_importe,
            d.observ     AS dd_observ,
            d.cantid     AS dd_cantid,
            d.acabado    AS dd_acabado,
            d.nrocarrete AS dd_nrocarrete,
            d.chasis AS dd_chasis,
            d.motor AS dd_motor,
            d.codadd01   AS dd_codadd01,
            cc1.descri   AS dd_descodadd01,
            d.codadd02   AS dd_codadd02,
            cc2.descri   AS dd_descodadd02,
            d.etiqueta   AS dd_etiqueta,
            cp.despag    AS descodcpag,
            v.desven     AS desven,
            mo.simbolo,
            us.nombres   AS usuario,
            da.situac    AS situacioncredito,
            CASE
                WHEN da.situac = 'B' THEN
                    'Aprobado'
                ELSE
                    CASE
                        WHEN da.situac = 'J' THEN
                                'Desaprobado'
                        ELSE
                            'no asignado'
                    END
            END          situacioncreditonombre,
            k.dam        AS dam,
            k.placa      AS placa
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab          c
            LEFT OUTER JOIN c_pago                  cp ON cp.id_cia = c.id_cia
                                         AND cp.codpag = c.codcpag
            LEFT OUTER JOIN tmoneda                 mo ON mo.id_cia = c.id_cia
                                          AND mo.codmon = c.tipmon
            LEFT OUTER JOIN vendedor                v ON v.id_cia = c.id_cia
                                          AND v.codven = c.codven
            LEFT OUTER JOIN documentos_det          d ON d.id_cia = c.id_cia
                                                AND d.numint = c.numint
            LEFT OUTER JOIN articulos               a ON a.id_cia = d.id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
            LEFT OUTER JOIN cliente_articulos_clase cc1 ON cc1.id_cia = a.id_cia
                                                           AND cc1.tipcli = 'B'
                                                           AND cc1.codcli = a.codprv
                                                           AND cc1.clase = 1
                                                           AND cc1.codigo = d.codadd01
            LEFT OUTER JOIN cliente_articulos_clase cc2 ON cc2.id_cia = a.id_cia
                                                           AND cc2.tipcli = 'B'
                                                           AND cc2.codcli = a.codprv
                                                           AND cc2.clase = 2
                                                           AND cc2.codigo = d.codadd02
            LEFT OUTER JOIN cliente                 cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codcli
            LEFT OUTER JOIN usuarios                us ON us.id_cia = c.id_cia
                                           AND us.coduser = c.usuari
            LEFT OUTER JOIN documentos_aprobacion   da ON da.id_cia = c.id_cia
                                                        AND da.numint = c.numint
            LEFT OUTER JOIN situacion               s ON s.id_cia = c.id_cia
                                           AND s.tipdoc = c.tipdoc
                                           AND s.situac = c.situac
            LEFT OUTER JOIN kardex000               k ON k.id_cia = c.id_cia
                                           AND k.etiqueta = d.etiqueta
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

END;

/
