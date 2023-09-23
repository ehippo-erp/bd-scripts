--------------------------------------------------------
--  DDL for Function SP01_SACA_ACUMULA_SALDOS_DOCUMENTOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP01_SACA_ACUMULA_SALDOS_DOCUMENTOS" (
    pin_id_cia  NUMBER,
    pin_tipinv  NUMBER,
    pin_codart  VARCHAR2,
    pin_codalm  NUMBER,
    pin_tipdoc  NUMBER,
    pin_sitdoc  VARCHAR2,
    pin_codmot  NUMBER,
    pin_id      VARCHAR2
) RETURN tbl_acumula_saldos_documentos
    PIPELINED
AS

    v_acumula_saldos_documentos rec_acumula_saldos_documentos := rec_acumula_saldos_documentos(NULL, NULL, NULL, NULL, NULL,
                              NULL);
    CURSOR cur_saca_saldos_documentos IS
    SELECT
        tipinv,
        codart,
        codalm,
        SUM(cantidad)     AS cantidad,
        SUM(entrega)      AS entrega,
        SUM(saldo)        AS saldo
    FROM
        TABLE ( sp00_saca_saldos_documentos(pin_id_cia, pin_tipinv, pin_codart, pin_codalm, pin_tipdoc,
                                            pin_sitdoc, pin_codmot, pin_id) )
    GROUP BY
        tipinv,
        codart,
        codalm
    ORDER BY
        tipinv,
        codart,
        codalm;

BEGIN
    FOR registro IN cur_saca_saldos_documentos LOOP
        v_acumula_saldos_documentos.tipinv := registro.tipinv;
        v_acumula_saldos_documentos.codart := registro.codart;
        v_acumula_saldos_documentos.codalm := registro.codalm;
        v_acumula_saldos_documentos.cantidad := registro.cantidad;
        v_acumula_saldos_documentos.entrega := nvl(registro.entrega, 0);
        v_acumula_saldos_documentos.saldo := nvl(registro.saldo, 0);
        PIPE ROW ( v_acumula_saldos_documentos );
    END LOOP;
END sp01_saca_acumula_saldos_documentos;

/
