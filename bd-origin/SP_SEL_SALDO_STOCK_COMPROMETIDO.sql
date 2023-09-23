--------------------------------------------------------
--  DDL for Function SP_SEL_SALDO_STOCK_COMPROMETIDO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_SEL_SALDO_STOCK_COMPROMETIDO" (
    wid_cia    IN  NUMBER,
    wtipinv    IN  NUMBER,
    wcodart    VARCHAR2,
    wcodadd01  VARCHAR2,
    wcodadd02  VARCHAR2,
    wcodalm    VARCHAR2,
    wifemisi   DATE
) RETURN tbl_saldo_stk_comprometido
    PIPELINED
AS

    saldo_stock_comprometido  rec_saldo_stk_comprometido := rec_saldo_stk_comprometido(0, 0);
    wanopro                   NUMBER;
    wmespro                   NUMBER;
    wperiodoinicio            NUMBER;
    wperiodofin               NUMBER;
    v_saldo                   NUMERIC(16, 4);
    v_saldo_alm               NUMERIC(16, 4);
BEGIN
    SELECT
        EXTRACT(YEAR FROM CAST(wifemisi AS DATE)) AS ano
    INTO wanopro
    FROM
        dual;

    SELECT
        EXTRACT(MONTH FROM CAST(wifemisi AS DATE)) AS mes
    INTO wmespro
    FROM
        dual;

    wperiodoinicio := ( wanopro * 100 );
    wperiodofin := ( wanopro * 100 ) + wmespro;
    v_saldo := 0;
    v_saldo_alm := 0;
    BEGIN
        SELECT
            SUM(ingreso) - SUM(salida)
        INTO v_saldo_alm
        FROM
            articulos_almacen
        WHERE
                id_cia = wid_cia
            AND tipinv = wtipinv
            AND codart = wcodart
            AND ( ( wcodalm IS NULL )
                  OR ( wcodalm <= 0 )
                  OR ( codalm = wcodalm ) )
            AND periodo >= wperiodoinicio
            AND periodo <= wperiodofin;

    EXCEPTION
        WHEN no_data_found THEN
            v_saldo_alm := 0;
    END;

    BEGIN
        SELECT
            SUM(ingreso) - SUM(salida)
        INTO v_saldo
        FROM
            comprometido_almacen
        WHERE
                id_cia = wid_cia
            AND tipinv = wtipinv
            AND codart = wcodart
            AND codadd01 = nvl(wcodadd01, '')
            AND codadd02 = nvl(wcodadd02, '')
            AND ( ( wcodalm IS NULL )
                  OR ( wcodalm <= 0 )
                  OR ( codalm = wcodalm ) );

    EXCEPTION
        WHEN no_data_found THEN
            v_saldo := 0;
    END;

    saldo_stock_comprometido.saldo := v_saldo;
    saldo_stock_comprometido.saldo_alm :=v_saldo_alm;
    PIPE ROW ( saldo_stock_comprometido );
END sp_sel_saldo_stock_comprometido;

/
