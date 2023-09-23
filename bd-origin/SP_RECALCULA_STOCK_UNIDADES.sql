--------------------------------------------------------
--  DDL for Procedure SP_RECALCULA_STOCK_UNIDADES
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_RECALCULA_STOCK_UNIDADES" (
    pin_id_cia  IN  NUMBER,
    wperiodo    IN  NUMBER,
    wmesdes     IN  NUMBER,
    wmeshas     IN  NUMBER,
    wtipinv     IN  NUMBER,
    pout_mensaje  OUT  VARCHAR2
) AS
BEGIN
null;
--  /*PASO 1 : ELIMIANMOS REGISTROS DEL PERIODO ACTUAL*/
--
--    DELETE FROM articulos_almacen
--    WHERE id_cia = pin_id_cia AND ( ( wtipinv IS NULL ) OR ( wtipinv <= 0 ) OR ( tipinv = wtipinv ) )
--    AND ( periodo >= ( ( wperiodo * 100 ) + wmesdes ) )
--    AND ( periodo <= ( ( wperiodo * 100 ) + wmeshas ) );
--
--
--  /*PASO 2 : OBTENMOS SUMATORIA DE KARDEX DE PERIODO ACTUAL (INGRESOS) */
--
--    INSERT INTO articulos_almacen (
--        id_cia, tipinv, codart, codalm, periodo, ingreso, salida, cosing01, cossal01, cosing02, cossal02
--    )SELECT
--            k.id_cia,
--            k.tipinv,
--            k.codart,
--            k.codalm,
--            k.periodo,
--            SUM( CASE WHEN k.id = 'I' THEN k.cantid ELSE 0 END )  AS ingreso,
--            SUM( CASE WHEN k.id = 'S' THEN k.cantid ELSE 0 END )  AS salida,
--            SUM( CASE WHEN k.id = 'I' THEN k.costot01 ELSE 0 END )  AS cosing01,
--            SUM( CASE WHEN k.id = 'S' THEN k.costot01 ELSE 0 END )  AS cossal01,
--            SUM( CASE WHEN k.id = 'I' THEN k.costot02 ELSE 0 END )  AS cosing02,
--            SUM( CASE WHEN k.id = 'S' THEN k.costot02 ELSE 0 END )  AS cossal02
--        FROM kardex k
--        WHERE id_cia = pin_id_cia
--        AND ( ( wtipinv IS NULL ) OR ( wtipinv <= 0 ) OR ( k.tipinv = wtipinv ) )
--        AND ( k.periodo >= ( ( wperiodo * 100 ) + wmesdes ) )
--        AND ( k.periodo <= ( ( wperiodo * 100 ) + wmeshas ) )
--        GROUP BY k.id_cia,k.tipinv, k.codart, k.codalm, k.periodo;    
--
--
--     /*PASO 1 : ELIMIANMOS REGISTROS DEL PERIODO ACTUAL*/
--      DELETE FROM articulos_almacen_codadd
--      WHERE  id_cia = pin_id_cia 
--      AND ( ( wtipinv IS NULL ) OR ( wtipinv <= 0 ) OR ( tipinv = wtipinv ) )
--      AND ( periodo >= ( ( wperiodo * 100 ) + wmesdes ) )
--      AND ( periodo <= ( ( wperiodo * 100 ) + wmeshas ) );
--
--    /*PASO 2 : OBTENMOS SUMATORIA DE KARDEX DE PERIODO ACTUAL (INGRESOS) */
--     INSERT INTO ARTICULOS_ALMACEN_CODADD  (
--     id_cia, TIPINV,CODART,CODADD01,CODADD02,CODALM,PERIODO,INGRESO,SALIDA,COSING01,COSSAL01,COSING02,COSSAL02
--     )SELECT 
--          K.id_cia,
--          k.TIPINV,
--          K.CODART,
--          K.CODADD01,K.CODADD02,K.CODALM,K.PERIODO,
--          SUM(CASE WHEN K.ID='I' THEN K.CANTID   ELSE 0 END) AS INGRESO,
--          SUM(CASE WHEN K.ID='S' THEN K.CANTID   ELSE 0 END) AS SALIDA,
--          SUM(CASE WHEN K.ID='I' THEN K.COSTOT01 ELSE 0 END) AS COSING01,
--          SUM(CASE WHEN K.ID='S' THEN K.COSTOT01 ELSE 0 END) AS COSSAL01,
--          SUM(CASE WHEN K.ID='I' THEN K.COSTOT02 ELSE 0 END) AS COSING02,
--          SUM(CASE WHEN K.ID='S' THEN K.COSTOT02 ELSE 0 END) AS COSSAL02
--      FROM KARDEX K
--      WHERE k.id_cia = pin_id_cia 
--      and ((WTIPINV IS NULL)OR(WTIPINV<=0)OR(K.TIPINV=WTIPINV)) 
--      AND (K.PERIODO>=((WPERIODO*100)+WMESDES)) 
--      AND (K.PERIODO<=((WPERIODO*100)+WMESHAS)) 
--      AND (K.CODADD01<>'')AND(K.CODADD02<>'')
--      GROUP BY k.id_cia, K.TIPINV,K.CODART,K.CODADD01,K.CODADD02,K.CODALM,K.PERIODO;


END sp_recalcula_stock_unidades;

/
