--------------------------------------------------------
--  DDL for Procedure SP_STOCKFISICO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_STOCKFISICO" (
    pin_id_cia         IN   INTEGER,
    pin_tipinv         IN   INTEGER,
    pin_codart         IN   VARCHAR2,
    pin_codalm         IN   INTEGER,
    pin_anio           IN   INTEGER,
    pin_mes            IN   INTEGER,
    pout_stockinicial  OUT  NUMERIC,
    pout_stockfinal    OUT  NUMERIC
) AS

    v_periodofin    INTEGER;
    v_periodoini    INTEGER;
    v_stockinicial  NUMERIC(18, 2) := 0;
    v_stockfinal    NUMERIC(18, 2) := 0;
BEGIN
--Stock Final
    BEGIN
        SELECT
            SUM(nvl(ingreso, 0)) - SUM(nvl(salida, 0))
        INTO v_stockfinal
        FROM
            articulos_almacen
        WHERE
                id_cia = pin_id_cia
            AND tipinv = pin_tipinv
            AND codart = pin_codart
            AND ( ( pin_codalm = - 1 )
                  OR ( ( codalm = pin_codalm ) ) )
            AND periodo >= ( pin_anio * 100 )
            AND periodo <= ( ( pin_anio * 100 ) + pin_mes );

    EXCEPTION
        WHEN no_data_found THEN
            v_stockfinal := 0;
    END;

--Stock inicial

    BEGIN
        SELECT
            SUM(nvl(ingreso, 0)) - SUM(nvl(salida, 0))
        INTO v_stockinicial
        FROM
            articulos_almacen
        WHERE
                id_cia = pin_id_cia
            AND tipinv = pin_tipinv
            AND codart = pin_codart
            AND ( ( pin_codalm = - 1 )
                  OR ( ( codalm = pin_codalm ) ) )
            AND periodo >= ( pin_anio * 100 )
            AND periodo <= ( ( pin_anio * 100 ) + ( pin_mes - 1 ) );

    EXCEPTION
        WHEN no_data_found THEN
            v_stockinicial := 0;
    END;

    pout_stockinicial := v_stockinicial;
    pout_stockfinal := v_stockfinal;
END sp_stockfisico;

/
