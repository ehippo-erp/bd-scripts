--------------------------------------------------------
--  DDL for Package Body PACK_PROV103
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_PROV103" AS

    FUNCTION sp_buscar (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER
    ) RETURN datatable_prov103
        PIPELINED
    AS
        v_table datatable_prov103;
    BEGIN
        SELECT
            d.*,
            d1.importe AS doc_importe,
            d1.tipmon  AS doc_moneda,
            d1.saldo   AS doc_saldo,
            d1.femisi  AS doc_femisi,
            d1.fvenci  AS doc_fvenci,
            td.abrevi  AS doc_tipdoc_abrevi,
            td.signo   AS doc_signo,
            d1.tipdoc  AS doc_tipdoc,
            d1.serie   AS doc_serie,
            d1.numero  AS doc_numero,
            d1.docume  AS doc_docume,
            d1.codcli  AS doc_codcli,
            cl.razonc  AS doc_razonc
        BULK COLLECT
        INTO v_table
        FROM
            prov103 d
            LEFT OUTER JOIN prov100 d1 ON d1.id_cia = d.id_cia
                                          AND d1.tipo = d.tipo
                                          AND d1.docu = d.docu
            LEFT OUTER JOIN cliente cl ON cl.id_cia = d.id_cia
                                          AND cl.codcli = d1.codcli
            LEFT OUTER JOIN tdocume td ON td.id_cia = d.id_cia
                                          AND td.codigo = d1.tipdoc
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
    ) RETURN datatable_prov103
        PIPELINED
    AS
        v_table datatable_prov103;
    BEGIN
        SELECT
            p103.id_cia,
            p103.libro,
            p103.periodo,
            p103.mes,
            p103.secuencia,
            p103.item,
            p103.tipo,
            p103.docu,
            p103.tipcan,
            p103.cuenta,
            p103.dh,
            p103.tipmon,
            p103.doccan,
            p103.docume,
            p103.tipcam,
            p103.amorti,
            p103.tcamb01,
            p103.tcamb02,
            (
                CASE
                    WHEN p103.dh = 'H' THEN
                        1
                    ELSE
                        - 1
                END
            ) * p103.impor01 AS import01,
            (
                CASE
                    WHEN p103.dh = 'H' THEN
                        1
                    ELSE
                        - 1
                END
            ) * p103.impor02 AS import02,
            p103.pagomn,
            p103.pagome,
            p103.situac,
            p103.numbco,
            p103.deposito,
            p103.swchksepaga,
            p103.swchkretiene,
            p103.concep,
            p103.retcodcli,
            p103.retserie,
            p103.retnumero,
            p103.swchkajuscen,
            p103.refere01,
            p103.refere02,
            d1.importe       AS doc_importe,
            d1.tipmon        AS doc_moneda,
            d1.saldo         AS doc_saldo,
            d1.femisi        AS doc_femisi,
            d1.fvenci        AS doc_fvenci,
            td.abrevi        AS doc_tipdoc_abrevi,
            td.signo         AS doc_signo,
            d1.tipdoc        AS doc_tipdoc,
            d1.serie         AS doc_serie,
            d1.numero        AS doc_numero,
            d1.docume        AS doc_docume,
            d1.codcli        AS doc_codcli,
            cl.razonc        AS doc_razonc
        BULK COLLECT
        INTO v_table
        FROM
            prov103 p103
            LEFT OUTER JOIN prov100 d1 ON d1.id_cia = p103.id_cia
                                          AND d1.tipo = p103.tipo
                                          AND d1.docu = p103.docu
            LEFT OUTER JOIN cliente cl ON cl.id_cia = d1.id_cia
                                          AND cl.codcli = d1.codcli
            LEFT OUTER JOIN tdocume td ON td.id_cia = d1.id_cia
                                          AND td.codigo = d1.tipdoc
        WHERE
                p103.id_cia = pin_id_cia
            AND p103.libro = pin_libro
            AND p103.periodo = pin_periodo
            AND p103.mes = pin_mes
            AND p103.secuencia = pin_secuencia
            AND ( nvl(pin_item, - 1) = - 1
                  OR p103.item = pin_item );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_deposito;

END;

/
