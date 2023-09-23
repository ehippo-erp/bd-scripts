--------------------------------------------------------
--  DDL for Function SP000_SACA_STOCK_COSTO_ARTICULOS_POR_ALMACEN_COSTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_STOCK_COSTO_ARTICULOS_POR_ALMACEN_COSTO" (
    pin_id_cia     NUMBER,
    pin_tipinv     NUMBER,
    pin_codalm     NUMBER,
    pin_codart     VARCHAR2,
    pin_periodo    NUMBER,
    pin_meshasstk  NUMBER
) RETURN tbl_stk_costo_art_por_almacen
    PIPELINED
AS

    stock_costo_art_por_almacen_costo  rec_stk_costo_art_por_almacen := rec_stk_costo_art_por_almacen(NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL);
    CURSOR select_almacen (
        palmacen NUMBER
    ) IS
    SELECT
        codalm,
        descri AS desalm,
        abrevi
    FROM
        almacen
    WHERE
            id_cia = pin_id_cia
		AND ( tipinv = pin_tipinv )
        AND ( ( palmacen IS NULL )
              OR ( palmacen = - 1 )
              OR ( codalm = pin_codalm ) );

    CURSOR selec_stock (
        palmacen     NUMBER,
        pperiododes  NUMBER,
        pperiodohas  NUMBER
    ) IS
    SELECT
        codalm,
        SUM(nvl(ingreso, 0)) - SUM(nvl(salida, 0)) AS stock
    FROM
        articulos_almacen
    WHERE
            id_cia = pin_id_cia
        AND tipinv = pin_tipinv
        AND codalm = palmacen
        AND codart = pin_codart
        AND periodo >= pperiododes
        AND periodo <= pperiodohas
    GROUP BY
        codalm;

    v_periododes                       NUMBER := ( pin_periodo * 100 ) + 00;
    v_periodohas                       NUMBER := ( pin_periodo * 100 ) + pin_meshasstk;
    v_stock                            NUMERIC(16, 4) := 0;
    v_cantid_1                         NUMERIC(16, 4) := 0;
    v_costot01_1                       NUMERIC(16, 4) := 0;
    v_costot02_1                       NUMERIC(16, 4) := 0;
    v_cantid_2                         NUMERIC(16, 4) := 0;
    v_costot01_2                       NUMERIC(16, 4) := 0;
    v_costot02_2                       NUMERIC(16, 4) := 0;
    v_saldo_com                        NUMERIC(16, 4) := 0;
    v_femisi                           DATE;
BEGIN
    FOR reg_almacen IN select_almacen(pin_codalm) LOOP
        stock_costo_art_por_almacen_costo.codalm := reg_almacen.codalm;
        stock_costo_art_por_almacen_costo.desalm := reg_almacen.desalm;
        stock_costo_art_por_almacen_costo.abrevi := reg_almacen.abrevi;
        stock_costo_art_por_almacen_costo.stock := 0;
        stock_costo_art_por_almacen_costo.costot01 := 0;
        stock_costo_art_por_almacen_costo.costot02 := 0;
        stock_costo_art_por_almacen_costo.cosuni01 := 0;
        stock_costo_art_por_almacen_costo.cosuni02 := 0;
        FOR reg_stock IN selec_stock(reg_almacen.codalm, v_periododes, v_periodohas) LOOP
            stock_costo_art_por_almacen_costo.stock := reg_stock.stock;
            v_stock := reg_stock.stock;
            IF reg_stock.stock <> 0 THEN
                BEGIN
                    SELECT
                        SUM(nvl(cantid, 0)),
                        SUM(nvl(costo01, 0)),
                        SUM(nvl(costo02, 0))
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
                        AND periodo = v_periodohas;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cantid_1 := NULL;
                        v_costot01_1 := NULL;
                        v_costot02_1 := NULL;
                END;

                BEGIN
                    SELECT
                        SUM(nvl(cantid, 0)),
                        SUM(nvl(costo01, 0)),
                        SUM(nvl(costo02, 0))
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
                        AND periodo = v_periodohas;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cantid_2 := NULL;
                        v_costot01_2 := NULL;
                        v_costot02_2 := NULL;
                END;

                IF ( v_cantid_1 IS NULL ) THEN
                    v_cantid_1 := 0;
                END IF;
                IF ( v_costot01_1 IS NULL ) THEN
                    v_costot01_1 := 0;
                END IF;
                IF ( v_costot02_1 IS NULL ) THEN
                    v_costot02_1 := 0;
                END IF;
                IF ( v_cantid_2 IS NULL ) THEN
                    v_cantid_2 := 0;
                END IF;
                IF ( v_costot01_2 IS NULL ) THEN
                    v_costot01_2 := 0;
                END IF;
                IF ( v_stock IS NULL ) THEN
                    v_stock := 0;
                END IF;
                IF ( v_saldo_com IS NULL ) THEN
                    v_saldo_com := 0;
                END IF;
                v_stock := v_stock - v_saldo_com;
                stock_costo_art_por_almacen_costo.stock := v_stock;
                stock_costo_art_por_almacen_costo.costot01 := v_costot01_1 + v_costot01_2;
                stock_costo_art_por_almacen_costo.costot02 := v_costot02_1 + v_costot02_2;
                IF ( ( v_cantid_1 + v_cantid_2 ) <> 0 ) THEN
                    stock_costo_art_por_almacen_costo.cosuni01 := stock_costo_art_por_almacen_costo.costot01 / ( v_cantid_1 + v_cantid_2 );
                END IF;

                IF ( ( v_cantid_1 + v_cantid_2 ) <> 0 ) THEN
                    stock_costo_art_por_almacen_costo.cosuni02 := stock_costo_art_por_almacen_costo.costot02 / ( v_cantid_1 + v_cantid_2 );
                END IF;

            END IF;

        END LOOP;

        PIPE ROW ( stock_costo_art_por_almacen_costo );
    END LOOP;
END sp000_saca_stock_costo_articulos_por_almacen_costo;

/
