--------------------------------------------------------
--  DDL for Function SP00_SACA_SALDOS_ORDENES_PEDIDOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP00_SACA_SALDOS_ORDENES_PEDIDOS" (
    pin_id_cia  NUMBER,
    pin_tipinv  NUMBER,
    pin_codart  VARCHAR2,
    pin_codalm  NUMBER
) RETURN tbl_saldos_ordenes_pedidos
    PIPELINED
AS

    saldos_ordenes_pedidos rec_saldos_ordenes_pedidos := rec_saldos_ordenes_pedidos(NULL, NULL, NULL, NULL, NULL,
                           NULL);
    CURSOR cr_select001 (
        pid_cia NUMBER
    ) IS
    SELECT
        dc.numint
    FROM
        documentos_cab dc
    WHERE
        ( dc.id_cia = pid_cia )
        AND dc.tipdoc = 101
        AND ( dc.situac = 'B'
              OR dc.situac = 'D'
              OR situac = 'G' );

    CURSOR cr_select002 (
        pid_cia  NUMBER,
        pnumint  NUMBER,
        ptipinv  NUMBER,
        pcodart  VARCHAR2,
        pcodalm  NUMBER
    ) IS
    SELECT
        dd.tipinv,
        dd.codalm,
        dd.codart,
        dd.cantid,
        (
            SELECT
                SUM(de.entreg)
            FROM
                documentos_ent de
            WHERE
                    de.id_cia = pid_cia
                AND de.opnumdoc = pnumint
                AND de.opnumite = dd.numite
        ) AS entrega
    FROM
        documentos_det dd
    WHERE
            dd.id_cia = pin_id_cia
        AND dd.numint = pnumint
        AND ( ( ptipinv = 0 )
              OR ( dd.tipinv = ptipinv ) )
        AND ( ( pcodart = '' )
              OR ( dd.codart = pcodart ) )
        AND ( ( pcodalm = 0 )
              OR ( dd.codalm = pcodalm ) )
    ORDER BY
        dd.tipinv,
        dd.codart,
        dd.codalm;

BEGIN
    FOR regpadre IN cr_select001(pin_id_cia) LOOP
        FOR reghijo IN cr_select002(pin_id_cia, regpadre.numint, pin_tipinv, pin_codart, pin_codalm) LOOP
            saldos_ordenes_pedidos.tipinv := nvl(reghijo.tipinv, -1);
            saldos_ordenes_pedidos.codart := nvl(reghijo.codart, '-1');
            saldos_ordenes_pedidos.codalm := nvl(reghijo.codalm, -1);
            saldos_ordenes_pedidos.cantidad := nvl(reghijo.cantid, 0);
            saldos_ordenes_pedidos.entrega := nvl(reghijo.entrega, 0);
            saldos_ordenes_pedidos.saldo := nvl(reghijo.cantid, 0) - nvl(reghijo.entrega, 0);

            PIPE ROW ( saldos_ordenes_pedidos );
        END LOOP;
    END LOOP;
END sp00_saca_saldos_ordenes_pedidos;

/
