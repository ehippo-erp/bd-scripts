--------------------------------------------------------
--  DDL for Function SP000_SACA_STOCK_COSTO_ARTICULOS_ALMACEN
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_STOCK_COSTO_ARTICULOS_ALMACEN" (
    pin_id_cia     NUMBER,
    pin_tipinv     NUMBER,
    pin_codalm     NUMBER,
    pin_codart     VARCHAR2,
    pin_periodo    NUMBER,
    pin_meshasstk  NUMBER,
    pin_meshascos  NUMBER
) RETURN tbl_stk_costo_art_almacen
    PIPELINED
AS

    stock_costo_art_almacen  rec_stk_costo_art_almacen := rec_stk_costo_art_almacen(NULL, NULL, NULL, NULL, NULL);
    v_periododes             NUMBER := ( NVL(pin_periodo,EXTRACT(YEAR FROM sysdate)) * 100 ) + 00;
    v_periodohas             NUMBER := ( NVL(pin_periodo,EXTRACT(YEAR FROM sysdate)) * 100 ) + NVL(pin_meshascos,EXTRACT(MONTH FROM sysdate));
    v_cosing01               NUMERIC(16, 4) := 0;
    v_cosing02               NUMERIC(16, 4) := 0;
    v_cossal01               NUMERIC(16, 4) := 0;
    v_cossal02               NUMERIC(16, 4) := 0;
    v_saldo_com              NUMERIC(16, 4);
    v_femisi                 DATE;
    v_costot01               NUMERIC(16, 4) := 0;
    v_costot02               NUMERIC(16, 4) := 0;
    v_cosuni01               NUMERIC(16, 4) := 0;
    v_cosuni02               NUMERIC(16, 4) := 0;
    v_stock                  NUMERIC(16, 4) := 0;
BEGIN
    BEGIN
        SELECT
            SUM(nvl(ingreso, 0)) - SUM(nvl(salida, 0)),
            SUM(nvl(cosing01, 0)),
            SUM(nvl(cosing02, 0)),
            SUM(nvl(cossal01, 0)),
            SUM(nvl(cossal02, 0))
        INTO
            v_stock,
            v_cosing01,
            v_cosing02,
            v_cossal01,
            v_cossal02
        FROM
            articulos_almacen
        WHERE
                id_cia = pin_id_cia
            AND tipinv = pin_tipinv
            AND ( ( pin_codalm IS NULL )
                  OR ( pin_codalm <= 0 )
                  OR ( codalm = pin_codalm ) )
            AND codart = pin_codart
            AND periodo >= v_periododes
            AND periodo <= v_periodohas;

    EXCEPTION
        WHEN no_data_found THEN
            v_stock := 0;
            v_cosing01 := 0;
            v_cosing02 := 0;
            v_cossal01 := 0;
            v_cossal02 := 0;
    END;

    v_femisi := to_date('01/'
                        || to_char(NVL(pin_meshasstk,01))
                        || '/'
                        || to_char(NVL(pin_periodo,EXTRACT(YEAR FROM sysdate))), 'DD/MM/YYYY');

    BEGIN
        SELECT
            saldo,
            saldo_alm
        INTO
            v_saldo_com,
            v_stock
        FROM
            TABLE ( sp_sel_saldo_stock_comprometido(pin_id_cia, pin_tipinv, pin_codart, '', '',
                                                    pin_codalm, v_femisi) );

    EXCEPTION
        WHEN no_data_found THEN
            v_saldo_com := 0;
            v_stock := 0;
    END;

    v_stock := nvl(v_stock, 0) - nvl(v_saldo_com, 0);
    v_costot01 := nvl(v_cosing01, 0) - nvl(v_cossal01, 0);
    v_costot02 := nvl(v_cosing02, 0) - nvl(v_cossal02, 0);

  /* 2011-10-03 - CARLOS SI EL COSTO <>0 Y EL STOCK=0 EL COSUNI=0 */
    IF ( v_stock <> 0 ) THEN
        v_cosuni01 := nvl(v_costot01, 0) / nvl(v_stock, 0);
    END IF;

    IF ( v_stock <> 0 ) THEN
        v_cosuni02 := nvl(v_costot02, 0) / nvl(v_stock, 0);
    END IF;

    IF ( pin_meshasstk <> pin_meshascos ) THEN
        v_stock := 0;
        v_saldo_com := 0;
        v_femisi := to_date('01/'
                            || to_char(NVL(pin_meshasstk,01))
                            || '/'
                            || to_char(NVL(pin_periodo,EXTRACT(YEAR FROM sysdate))), 'DD/MM/YYYY');

        BEGIN
            SELECT
                saldo,
                saldo_alm
            INTO
                v_saldo_com,
                v_stock
            FROM
                TABLE ( sp_sel_saldo_stock_comprometido(pin_id_cia, pin_tipinv, pin_codart, '', '',
                                                        pin_codalm, v_femisi) );

        EXCEPTION
            WHEN no_data_found THEN
                v_stock := 0;
                v_saldo_com := 0;
        END;

        IF ( v_stock IS NULL ) THEN
            v_stock := 0;
        END IF;
        IF ( v_saldo_com IS NULL ) THEN
            v_saldo_com := 0;
        END IF;
        v_stock := nvl(v_stock, 0) - nvl(v_saldo_com, 0);
        v_costot01 := nvl(v_cosuni01, 0) * nvl(v_stock, 0);
        v_costot02 := nvl(v_cosuni02, 0) * nvl(v_stock, 0);
    /* 2011-10-03 - CARLOS SI EL COSTO <>0 Y EL STOCK=0 EL COSUNI=0 */
        IF ( v_stock = 0 ) THEN
            v_cosuni01 := 0;
        END IF;
        IF ( v_stock = 0 ) THEN
            v_cosuni02 := 0;
        END IF;
    END IF;

    stock_costo_art_almacen.stock := v_stock;
    stock_costo_art_almacen.costot01 := v_costot01;
    stock_costo_art_almacen.costot02 := v_costot02;
    stock_costo_art_almacen.cosuni01 := v_cosuni01;
    stock_costo_art_almacen.cosuni02 := v_cosuni02;
    PIPE ROW ( stock_costo_art_almacen );
END sp000_saca_stock_costo_articulos_almacen;

/
