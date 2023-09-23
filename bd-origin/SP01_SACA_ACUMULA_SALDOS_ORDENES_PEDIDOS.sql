--------------------------------------------------------
--  DDL for Function SP01_SACA_ACUMULA_SALDOS_ORDENES_PEDIDOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP01_SACA_ACUMULA_SALDOS_ORDENES_PEDIDOS" (
    pin_id_cia  NUMBER,
    pin_tipinv  NUMBER,
    pin_codart  VARCHAR2,
    pin_codalm  NUMBER
) RETURN tbl_saldos_ordenes_pedidos
    PIPELINED
AS

    acumula_saldos_ordenes_pedidos  rec_saldos_ordenes_pedidos := rec_saldos_ordenes_pedidos(NULL, NULL, NULL, NULL, NULL,
                           NULL);
    CURSOR cr_select (
        pid_cia  NUMBER,
        ptipinv  NUMBER,
        pcodart  VARCHAR2,
        pcodalm  NUMBER
    ) IS
    SELECT
        tipinv,
        codart,
        codalm,
        SUM(cantidad)     AS cantidad,
        SUM(entrega)      AS entrega,
        SUM(saldo)        AS saldo
    FROM
        TABLE ( sp00_saca_saldos_ordenes_pedidos(pid_cia, ptipinv, pcodart, pcodalm) )
    GROUP BY
        tipinv,
        codart,
        codalm
    ORDER BY
        tipinv,
        codart,
        codalm;

BEGIN
    FOR registro IN cr_select(pin_id_cia, pin_tipinv, pin_codart, pin_codalm) LOOP
        acumula_saldos_ordenes_pedidos.tipinv := nvl(registro.tipinv, -1);
        acumula_saldos_ordenes_pedidos.codart := nvl(registro.codart, '-1');
        acumula_saldos_ordenes_pedidos.codalm := nvl(registro.codalm, -1);
        acumula_saldos_ordenes_pedidos.cantidad := nvl(registro.cantidad, 0);
        acumula_saldos_ordenes_pedidos.entrega := nvl(registro.entrega, 0);
        acumula_saldos_ordenes_pedidos.saldo := nvl(registro.cantidad, 0) - nvl(registro.entrega, 0);

        PIPE ROW ( acumula_saldos_ordenes_pedidos );
    END LOOP;
END sp01_saca_acumula_saldos_ordenes_pedidos;

/
