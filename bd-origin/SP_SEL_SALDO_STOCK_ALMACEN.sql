--------------------------------------------------------
--  DDL for Function SP_SEL_SALDO_STOCK_ALMACEN
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_SEL_SALDO_STOCK_ALMACEN" (
    pin_id_cia    NUMBER,
    pin_femisi    DATE,
    pin_tipinv    NUMBER,
    pin_codalm    NUMBER,
    pin_codart    VARCHAR2,
    pin_consto    NUMBER,
    pin_etiqueta  VARCHAR2
) RETURN tbl_saldo_stock_almacen
    PIPELINED
AS

    r_saldo_stock_almacen  rec_saldo_stock_almacen := rec_saldo_stock_almacen(NULL, NULL);
    v_anopro               NUMBER;
    v_mespro               NUMBER;
    v_periodoinicio        NUMBER;
    v_periodofin           NUMBER;
BEGIN

/* 2014-09-17 - Procedure creado en una Reunion con CARLOS + LUIS + FRANCO + OSCAR */
    SELECT
        EXTRACT(YEAR FROM CAST(pin_femisi AS DATE)) AS ano
    INTO v_anopro
    FROM
        dual;

    SELECT
        EXTRACT(MONTH FROM CAST(pin_femisi AS DATE)) AS mes
    INTO v_mespro
    FROM
        dual;

    v_periodoinicio := ( v_anopro * 100 );
    v_periodofin := ( v_anopro * 100 ) + v_mespro;
    r_saldo_stock_almacen.saldo := 0;
    r_saldo_stock_almacen.saldo_ori := 0;
    IF ( pin_consto = 1 ) THEN /* solo unidades */
        BEGIN
            SELECT
                SUM(ingreso) - SUM(salida) AS saldo
            INTO r_saldo_stock_almacen.saldo
            FROM
                articulos_almacen
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codalm = pin_codalm
                AND periodo >= v_periodoinicio
                AND periodo <= v_periodofin;

        EXCEPTION
            WHEN no_data_found THEN
                r_saldo_stock_almacen.saldo := 0;
        END;
    END IF;

    IF ( pin_consto IN (
        2,
        3,
        4
    ) ) THEN /* Carretes, Alambres, Estrobos,Eslingas */
        BEGIN
            SELECT
                SUM(ingreso) - SUM(salida) AS saldo
            INTO r_saldo_stock_almacen.saldo
            FROM
                kardex001
            WHERE
                    id_cia = pin_id_cia
                AND etiqueta = pin_etiqueta
                AND tipinv = pin_tipinv
                AND codart = pin_codart
                AND codalm = pin_codalm;

        EXCEPTION
            WHEN no_data_found THEN
                r_saldo_stock_almacen.saldo := 0;
        END;
    END IF;

    IF ( pin_consto IN (
        5,
        6,
        7,
        8
    ) ) THEN /* Por Royos , Etiquetas manuales y etiquetas generador (NABILA)*/
        BEGIN
            SELECT
                SUM(ingreso) - SUM(salida)        AS salso,
                SUM(cantid_ori)                   AS saldo_ori
            INTO
                r_saldo_stock_almacen.saldo,
                r_saldo_stock_almacen.saldo_ori
            FROM
                kardex001
            WHERE
                    id_cia = pin_id_cia
                AND etiqueta = pin_etiqueta
                AND codalm = pin_codalm;

        EXCEPTION
            WHEN no_data_found THEN
                r_saldo_stock_almacen.saldo := 0;
        END;
    END IF;

    IF ( r_saldo_stock_almacen.saldo IS NULL ) THEN
        r_saldo_stock_almacen.saldo := 0;
    END IF;

    IF ( r_saldo_stock_almacen.saldo_ori IS NULL ) THEN
        r_saldo_stock_almacen.saldo_ori := 0;
    END IF;

    PIPE ROW ( r_saldo_stock_almacen );
END sp_sel_saldo_stock_almacen;

/
