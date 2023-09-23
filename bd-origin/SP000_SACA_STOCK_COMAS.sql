--------------------------------------------------------
--  DDL for Function SP000_SACA_STOCK_COMAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_STOCK_COMAS" (
    pin_id_cia    NUMBER,
    pin_tipinv    NUMBER,
    pin_codart    VARCHAR2,
    pin_almacenes VARCHAR2,
    pin_fdesde    NUMBER,
    pin_fhasta    NUMBER
) RETURN VARCHAR2 IS

    CURSOR cur_filas (
        palmacenes VARCHAR2
    ) IS
    SELECT
        column_value AS almacen
    FROM
        TABLE ( split_string(palmacenes) );

    CURSOR cur_stock_costo (
        palmacen VARCHAR2,
        pperiodo NUMBER,
        pmes     NUMBER
    ) IS
    SELECT
        stock
    FROM
        TABLE ( sp000_saca_stock_costo_articulos_almacen(pin_id_cia, pin_tipinv, palmacen, pin_codart, pperiodo,
                                                         pmes, pmes) );

    v_codalm  NUMBER;
    v_result  VARCHAR2(200);
    v_stock   VARCHAR2(30);
    v_periodo NUMBER;
    v_mes     NUMBER;
BEGIN
    v_stock := '0';
    v_result := '';
    v_periodo := trunc(pin_fhasta / 100);
    v_mes := pin_fhasta - ( v_periodo * 100 );
    FOR reg_filas IN cur_filas(pin_almacenes) LOOP
        FOR reg_stock_costo IN cur_stock_costo(reg_filas.almacen, v_periodo, v_mes) LOOP
            v_stock := reg_stock_costo.stock;
            IF ( reg_stock_costo.stock IS NULL ) THEN
                v_stock := 0;
            END IF;
            v_result := v_stock
                        || ','
                        || v_result;
        END LOOP;

--        v_result := substr(v_result, 1, length(v_result) - 1);
    END LOOP;

    v_result := substr(v_result, 1, length(v_result) - 1);
    RETURN v_result;
END sp000_saca_stock_comas;

/
