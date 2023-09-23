--------------------------------------------------------
--  DDL for Function SP000_SACA_STOCK_COSTO_ARTICULOS_ALMACEN_COSTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_STOCK_COSTO_ARTICULOS_ALMACEN_COSTO" (
    pin_id_cia    NUMBER,
    pin_tipinv    NUMBER,
    pin_codalm    NUMBER,
    pin_codart    VARCHAR2,
    pin_periodo   NUMBER,
    pin_meshasstk NUMBER
) RETURN tbl_stk_costo_art_almacen
    PIPELINED
AS

    stock_costo_art_almacen_costo rec_stk_costo_art_almacen := rec_stk_costo_art_almacen(NULL, NULL, NULL, NULL, NULL);
    v_periododes                  NUMBER := ( pin_periodo * 100 ) + 00;
    v_periodohas                  NUMBER := ( pin_periodo * 100 ) + pin_meshasstk;
    v_stock                       NUMERIC(16, 4) := 0;
    v_cantid_1                    NUMERIC(16, 4) := 0;
    v_costot01_1                  NUMERIC(16, 4) := 0;
    v_costot02_1                  NUMERIC(16, 4) := 0;
    v_cantid_2                    NUMERIC(16, 4) := 0;
    v_costot01_2                  NUMERIC(16, 4) := 0;
    v_costot02_2                  NUMERIC(16, 4) := 0;
    v_saldo_com                   NUMERIC(16, 4) := 0;
    v_femisi                      DATE;
BEGIN
    BEGIN
        SELECT
            nvl(SUM(nvl(ingreso, 0)) - SUM(nvl(salida, 0)),
                0)
        INTO v_stock
        FROM
            articulos_almacen
        WHERE
                id_cia = pin_id_cia
            AND tipinv = pin_tipinv
            AND ( nvl(pin_codalm, 0) <= 0
                  OR codalm = pin_codalm )
            AND codart = pin_codart
            AND periodo >= v_periododes
            AND periodo <= v_periodohas;

    EXCEPTION
        WHEN no_data_found THEN
            v_stock := 0;
    END;

    IF v_stock <> 0 OR nvl(pin_codalm, 0) <= 0 THEN
        BEGIN
            SELECT
                nvl(SUM(nvl(cantid, 0)),
                    0),
                nvl(SUM(nvl(costo01, 0)),
                    0),
                nvl(SUM(nvl(costo02, 0)),
                    0)
            INTO
                v_cantid_1,
                v_costot01_1,
                v_costot02_1
            FROM
                articulos_costo
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND periodo = v_periodohas
                AND ( cantid <> 0
                      OR ( costo01 <> 0
                           OR costo02 <> 0 ) );

        EXCEPTION
            WHEN no_data_found THEN
                v_cantid_1 := 0;
                v_costot01_1 := 0;
                v_costot02_1 := 0;
        END;

        BEGIN
            SELECT
                nvl(SUM(nvl(cantid, 0)),
                    0),
                nvl(SUM(nvl(costo01, 0)),
                    0),
                nvl(SUM(nvl(costo02, 0)),
                    0)
            INTO
                v_cantid_2,
                v_costot01_2,
                v_costot02_2
            FROM
                articulos_costo_codadd
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND periodo = v_periodohas
                AND ( cantid <> 0
                      OR ( costo01 <> 0
                           OR costo02 <> 0 ) );

        EXCEPTION
            WHEN no_data_found THEN
                v_cantid_2 := 0;
                v_costot01_2 := 0;
                v_costot02_2 := 0;
        END;

        v_stock := v_stock - v_saldo_com;
        stock_costo_art_almacen_costo.stock := v_stock;
        stock_costo_art_almacen_costo.costot01 := v_costot01_1 + v_costot01_2;
        stock_costo_art_almacen_costo.costot02 := v_costot02_1 + v_costot02_2;
        IF ( ( v_cantid_1 + v_cantid_2 ) <> 0 ) THEN
            stock_costo_art_almacen_costo.cosuni01 := stock_costo_art_almacen_costo.costot01 / ( v_cantid_1 + v_cantid_2 );
        END IF;

        IF ( ( v_cantid_1 + v_cantid_2 ) <> 0 ) THEN
            stock_costo_art_almacen_costo.cosuni02 := stock_costo_art_almacen_costo.costot02 / ( v_cantid_1 + v_cantid_2 );
        END IF;

    END IF;

    PIPE ROW ( stock_costo_art_almacen_costo );
END sp000_saca_stock_costo_articulos_almacen_costo;

/
