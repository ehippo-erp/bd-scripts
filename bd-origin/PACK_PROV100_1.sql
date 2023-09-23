--------------------------------------------------------
--  DDL for Package Body PACK_PROV100
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_PROV100" AS

    FUNCTION sp_buscar_pago (
        pin_id_cia    NUMBER,
        pin_codcli    VARCHAR2,
        pin_tipo      VARCHAR2,
        pin_fhasta    DATE,
        pin_moneda    VARCHAR2,
        pin_mediopago VARCHAR2
    ) RETURN datatable_prov100
        PIPELINED
    AS
        v_table datatable_prov100;
    BEGIN
        SELECT
            d.id_cia,
            d.tipo,
            d.docu,
            c.tident,
            c.dident,
            d.codcli,
            c.razonc,
            d.tipdoc,
            d.docume,
            d.serie,
            d.numero,
            d.periodo,
            d.mes,
            d.femisi,
            d.fvenci,
            d.fcance,
            d.codban,
            d.numbco,
            d.refere01,
            d.refere02,
            d.tipmon,
            d.importe,
            d.importemn,
            d.importeme,
            d.saldo,
            d.saldomn,
            d.saldome,
            d.concpag,
            d.codcob,
            d.codven,
            d.comisi,
            d.codsuc,
            d.cancelado,
            d.fcreac,
            d.factua,
            d.usuari,
            d.situac,
            d.cuenta,
            d.dh,
            d.tipcam,
            d.operac,
            d.protes,
            CASE
                WHEN sysdate > d.fvenci THEN
                    sysdate - d.fvenci
                ELSE
                    0
            END AS diasmora
        BULK COLLECT
        INTO v_table
        FROM
            prov100        d
            LEFT OUTER JOIN tdocume        td ON td.id_cia = d.id_cia
                                          AND td.codigo = d.tipdoc
            LEFT OUTER JOIN tdocume_clases tdc ON tdc.id_cia = d.id_cia
                                                  AND tdc.tipdoc = d.tipdoc
                                                  AND tdc.clase = 3
                                                  AND tdc.moneda = tipmon
                                                  AND upper(tdc.codigo) = 'S'
            LEFT OUTER JOIN cliente        c ON c.id_cia = d.id_cia
                                         AND c.codcli = d.codcli
            INNER JOIN cliente_clase  cc ON cc.id_cia = d.id_cia
                                           AND cc.tipcli = 'B'
                                           AND cc.codcli = d.codcli
                                           AND cc.clase = 13
                                           AND cc.codigo = pin_mediopago
        WHERE
                d.id_cia = pin_id_cia
            AND abs(d.operac) <= 1
            AND d.saldo <> 0
            AND d.situac NOT IN ( '0', '8', '9' )
            AND ( pin_codcli IS NULL
                  OR d.codcli = pin_codcli )
            AND d.fvenci <= pin_fhasta
            AND d.tipmon = pin_moneda
            AND ( pin_tipo = 'N'
                  AND c.codtpe < 3 )
            OR ( pin_tipo = 'E'
                 AND c.codtpe = 3 )
            AND d.docume IS NOT NULL
            AND d.tipdoc IS NOT NULL
            AND d.tipdoc NOT IN ( 'AB', 'AA', '0' )
        ORDER BY
            c.razonc,
            d.tipdoc,
            d.docume;

        FOR i IN 1..v_table.count LOOP
            PIPE ROW ( v_table(i) );
        END LOOP;

        RETURN;
    END sp_buscar_pago;

END;

/
