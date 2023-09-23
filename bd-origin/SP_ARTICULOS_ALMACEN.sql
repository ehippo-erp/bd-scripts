--------------------------------------------------------
--  DDL for Procedure SP_ARTICULOS_ALMACEN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ARTICULOS_ALMACEN" (
    pin_id_cia   IN NUMBER,
    pin_periodo  IN NUMBER,
    pin_tipinv   IN NUMBER,
    pout_mensaje OUT VARCHAR2
) AS
BEGIN

    /*PASO 1: ELIMINAMOS DATOS DE ARTICULOS_ALMACEN DEL PERIODO ACTUAL*/
    DELETE FROM articulos_almacen
    WHERE
            id_cia = pin_id_cia
        AND periodo = pin_periodo
        AND tipinv = pin_tipinv;

    COMMIT;
    
   /*PASO 2: INSERTAMOS REGISTROS DE ARTICULOS_ALMACEN DEL PERIODO ANTERIOR AL PERIODO ACTUAL*/
    INSERT INTO articulos_almacen (
        id_cia,
        periodo,
        tipinv,
        codalm,
        codart,
        ingreso,
        salida,
        cosing01,
        cosing02,
        cossal01,
        cossal02
    )
        SELECT
            a.id_cia,
            pin_periodo,
            a.tipinv,
            a.codalm,
            a.codart,
            0,
            0,
            0,
            0,
            0,
            0
        FROM
            articulos_almacen a
        WHERE
                a.id_cia = pin_id_cia
            AND a.periodo = ( pin_periodo - 1 )
            AND a.tipinv = pin_tipinv;

    COMMIT;
    
/*SE INSERTAN ARTICULOS NUEVOS DEL MES*/
    INSERT INTO articulos_almacen (
        id_cia,
        periodo,
        tipinv,
        codalm,
        codart,
        ingreso,
        salida,
        cosing01,
        cosing02,
        cossal01,
        cossal02
    )
        SELECT DISTINCT
            a.id_cia,
            a.periodo,
            a.tipinv,
            a.codalm,
            a.codart,
            0,
            0,
            0,
            0,
            0,
            0
        FROM
            kardex a
        WHERE
                a.id_cia = pin_id_cia
            AND a.tipinv = pin_tipinv
            AND a.periodo = pin_periodo
            AND NOT EXISTS (
                SELECT
                    c.codart
                FROM
                    articulos_almacen c
                WHERE
                        c.id_cia = a.id_cia
                    AND c.tipinv = a.tipinv
                    AND c.periodo = pin_periodo
                    AND c.codalm = a.codalm
                    AND c.codart = a.codart
            );

    COMMIT;
    FOR i IN (
        SELECT
            k.codalm,
            k.codart,
            SUM(
                CASE
                    WHEN k.id = 'I' THEN
                        k.cantid
                    ELSE
                        0
                END
            ) AS ingreso,
            SUM(
                CASE
                    WHEN k.id = 'S' THEN
                        k.cantid
                    ELSE
                        0
                END
            ) AS salida,
            SUM(
                CASE
                    WHEN k.id = 'I' THEN
                        k.costot01
                    ELSE
                        0
                END
            ) AS cosing01,
            SUM(
                CASE
                    WHEN k.id = 'I' THEN
                        k.costot02
                    ELSE
                        0
                END
            ) AS cosing02,
            SUM(
                CASE
                    WHEN k.id = 'S' THEN
                        k.costot01
                    ELSE
                        0
                END
            ) AS cossal01,
            SUM(
                CASE
                    WHEN k.id = 'S' THEN
                        k.costot02
                    ELSE
                        0
                END
            ) AS cossal02
        FROM
            kardex k
        WHERE
                k.id_cia = pin_id_cia
            AND k.periodo = pin_periodo
            AND k.tipinv = pin_tipinv
        GROUP BY
            k.codalm,
            k.codart
    ) LOOP
        UPDATE articulos_almacen aa
        SET
            aa.ingreso = i.ingreso,
            aa.salida = i.salida,
            aa.cosing01 = i.cosing01,
            aa.cosing02 = i.cosing02,
            aa.cossal01 = i.cossal01,
            aa.cossal02 = i.cossal02
        WHERE
                aa.id_cia = pin_id_cia
            AND aa.periodo = pin_periodo
            AND aa.tipinv = pin_tipinv
            AND aa.codalm = i.codalm
            AND aa.codart = i.codart;

    END LOOP;

    COMMIT;
    pout_mensaje := 'Success';
END sp_articulos_almacen;

/
