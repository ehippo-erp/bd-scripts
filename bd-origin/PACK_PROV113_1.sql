--------------------------------------------------------
--  DDL for Package Body PACK_PROV113
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_PROV113" AS

    FUNCTION sp_buscar (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER
    ) RETURN datatable_prov113
        PIPELINED
    AS
        v_table datatable_prov113;
    BEGIN
        SELECT
            d.*,
            d1.importe AS doc_importe,
            d1.tipmon  AS doc_moneda,
            d1.saldo   AS doc_saldo,
            d1.femisi  AS doc_femisi,
            d1.fvenci  AS doc_fvenci,
            d1.serie   AS doc_serie,
            d1.numero  AS doc_numero,
            d1.docume  AS doc_docume,
            d1.codcli  AS doc_codcli,
            cl.razonc  AS doc_razonc
        BULK COLLECT
        INTO v_table
        FROM
            prov113 d
            LEFT OUTER JOIN prov100 d1 ON d1.id_cia = d.id_cia
                                          AND d1.tipo = d.tipo
                                          AND d1.docu = d.docu
            LEFT OUTER JOIN cliente cl ON cl.id_cia = d.id_cia
                                          AND cl.codcli = d1.codcli
        WHERE
                d.id_cia = pin_id_cia
            AND d.libro = pin_libro
            AND d.periodo = pin_periodo
            AND d.mes = pin_mes
            AND d.secuencia = pin_secuencia
            AND ( nvl(pin_item, - 1) = - 1
                  OR item = pin_item );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_buscar_deposito (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER
    ) RETURN datatable_prov113
        PIPELINED
    AS
        v_table datatable_prov113;
    BEGIN
        SELECT
            p113.id_cia,
            p113.libro,
            p113.periodo,
            p113.mes,
            p113.secuencia,
            p113.item,
            p113.tipo,
            p113.docu,
            p113.tipcan,
            p113.cuenta,
            p113.dh,
            p113.tipmon,
            p113.doccan,
            p113.docume,
            p113.tipcam,
            p113.amorti,
            p113.tcamb01,
            p113.tcamb02,
            (
                CASE
                    WHEN p113.dh = 'H' THEN
                        1
                    ELSE
                        - 1
                END
            ) * p113.impor01 AS import01,
            (
                CASE
                    WHEN p113.dh = 'H' THEN
                        1
                    ELSE
                        - 1
                END
            ) * p113.impor02 AS import02,
            p113.pagomn,
            p113.pagome,
            p113.situac,
            p113.numbco,
            p113.deposito,
            p113.swchksepaga,
            p113.swchkretiene,
            p113.concep,
            p113.retcodcli,
            p113.retserie,
            p113.retnumero,
            p113.swchkajuscen,
            p113.refere01,
            p113.refere02,
            d1.importe       AS doc_importe,
            d1.tipmon        AS doc_moneda,
            d1.saldo         AS doc_saldo,
            d1.femisi        AS doc_femisi,
            d1.fvenci        AS doc_fvenci,
            d1.serie         AS doc_serie,
            d1.numero        AS doc_numero,
            d1.docume        AS doc_docume,
            d1.codcli        AS doc_codcli,
            cl.razonc        AS doc_razonc
        BULK COLLECT
        INTO v_table
        FROM
            prov113 p113
            LEFT OUTER JOIN prov100 d1 ON d1.id_cia = p113.id_cia
                                          AND d1.tipo = p113.tipo
                                          AND d1.docu = p113.docu
            LEFT OUTER JOIN cliente cl ON cl.id_cia = d1.id_cia
                                          AND cl.codcli = d1.codcli
        WHERE
                p113.id_cia = pin_id_cia
            AND p113.libro = pin_libro
            AND p113.periodo = pin_periodo
            AND p113.mes = pin_mes
            AND p113.secuencia = pin_secuencia
            AND ( nvl(pin_item, - 1) = - 1
                  OR p113.item = pin_item );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_deposito;

END;

/
