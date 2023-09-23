--------------------------------------------------------
--  DDL for Procedure SP_COSTO_PROMEDIO02
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_COSTO_PROMEDIO02" (
    pin_id_cia     IN    NUMBER,
    pin_periodo    IN    NUMBER,
    pin_tipinv     IN    NUMBER,
    pout_mensaje   OUT   VARCHAR2
) AS

    old_codart      VARCHAR(40);
    swcostxetique   VARCHAR(20);
    wpuni1          DOUBLE PRECISION;
    wpuni2          DOUBLE PRECISION;
    wcostot01       NUMERIC(16, 2);
    wcostot02       NUMERIC(16, 2);
    old_wcostot01   NUMERIC(16, 2);
    old_wcostot02   NUMERIC(16, 2);
    wcantid2        NUMERIC(16, 4);
    wlocali2        INTEGER;
    tipo_costeo     VARCHAR(5);
    worden          INTEGER;
    v_count1        NUMBER;
    v_count2        NUMBER;
    v_count3        NUMBER;
    wopnumdoc       INTEGER;
    wopnumite       INTEGER;
    CURSOR rec_kardex (
        v_id_cia    NUMBER,
        v_periodo   NUMBER,
        v_tipinv    NUMBER
    ) IS
    SELECT
        CASE
            WHEN mc3.valor IS NULL THEN
                k.codmot
            ELSE
                CAST(mc3.valor AS INTEGER)
        END AS worden,
        k.locali     AS klocali,
        k.tipinv     AS ktipinv,
        k.codart     AS kcodart,
        k.codalm     AS kcodalm,
        k.etiqueta   AS ketiqueta,
        k.periodo    AS kperiodo,
        k.id         AS kid,
        k.femisi     AS kfemisi,
        k.costot01   AS kcostot01,
        k.costot02   AS kcostot02,
        k.cantid     AS kcantid,
        m.cospro     AS kcospro,
        m.costea     AS kcostea,
        CASE
            WHEN k.id = 'S' THEN
                - 1
            ELSE
                1
        END AS kfactor,
        k.codmot     AS kcodmot,
        m.desmot     AS kdesmot,
        k.numint     AS knumint,
        k.numite     AS knumite,
        mc1.valor    AS kswdevprod,
        mc2.valor    AS kswhercosori,
        m36.valor    AS kswmotdevventa
    FROM
        kardex          k
        INNER JOIN motivos         m ON m.id_cia = k.id_cia
                                AND m.tipdoc = k.tipdoc
                                AND m.id = k.id
                                AND m.codmot = k.codmot
        LEFT OUTER JOIN motivos_clase   mc1 ON mc1.id_cia = k.id_cia
                                             AND mc1.tipdoc = k.tipdoc
                                             AND mc1.id = k.id
                                             AND mc1.codmot = k.codmot
                                             AND mc1.codigo = 22  /* 22- DEVOLUCION DE PRODUCCION */
        LEFT OUTER JOIN motivos_clase   mc2 ON mc2.id_cia = k.id_cia
                                             AND mc2.tipdoc = k.tipdoc
                                             AND mc2.id = k.id
                                             AND mc2.codmot = k.codmot
                                             AND mc2.codigo = 32  /* 32- HEREDA COSTO UNITARIO POR RELACION DE ITEM */
        LEFT OUTER JOIN motivos_clase   m36 ON m36.id_cia = k.id_cia
                                             AND m36.tipdoc = k.tipdoc
                                             AND m36.id = k.id
                                             AND m36.codmot = k.codmot
                                             AND m36.codigo = 36  /* 32- HEREDA COSTO UNITARIO POR RELACION DE ITEM */
        LEFT OUTER JOIN motivos_clase   mc3 ON mc3.id_cia = k.id_cia
                                             AND mc3.tipdoc = k.tipdoc
                                             AND mc3.id = k.id
                                             AND mc3.codmot = k.codmot
                                             AND mc3.codigo = 49  /* 49- ORDEN PARA PROCESO DE COSTEO */
    WHERE
        k.id_cia = v_id_cia
        AND k.periodo = v_periodo
        AND k.tipinv = v_tipinv
        AND ( length(TRIM(k.codadd01)) IS NULL
              OR ( length(TRIM(k.codadd01)) = 0 ) )
        AND ( length(TRIM(k.codadd02)) IS NULL
              OR ( length(TRIM(k.codadd02)) = 0 ) )
    ORDER BY
        k.codart,
        k.femisi,
        k.id,
        worden;

BEGIN

    /* 2014-09-22 CAMBIOS REALIZADOS POR CARLOS  POR PROBLEMAS EN BOYTON    */
    /*PASO 1: ELIMINAMOS DATOS DE ARTICULOS_COSTO DEL PERIODO ACTUAL*/
    DELETE FROM articulos_costo
    WHERE
        id_cia = pin_id_cia
        AND periodo = pin_periodo
        AND tipinv = pin_tipinv;

   /*PASO 2: INSERTAMOS REGISTROS DE ARTICULOS_COSTO DEL PERIODO ANTERIOR AL PERIODO ACTUAL*/

    INSERT INTO articulos_costo
        SELECT
            a.id_cia,
            a.tipinv,
            a.codart,
            pin_periodo,
            a.costo01,
            a.costo02,
            a.cantid
        FROM
            articulos_costo a
        WHERE
            a.id_cia = pin_id_cia
            AND a.tipinv = pin_tipinv
            AND a.periodo = pin_periodo - 1;

    INSERT INTO articulos_costo (
        id_cia,
        tipinv,
        codart,
        periodo,
        costo01,
        costo02,
        cantid
    )
        SELECT DISTINCT
            a.id_cia,
            a.tipinv,
            a.codart,
            a.periodo,
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
                    articulos_costo c
                WHERE
                    c.id_cia = a.id_cia
                    AND c.tipinv = a.tipinv
                    AND c.codart = a.codart
                    AND c.periodo = pin_periodo
            );   

   /* 1 - COSTO PROMEDIO
      2 - COSTO MIXTO   */


            /*PASO3: OBTENEMOS DATOS DEL KARDEX DEL PERIODO ACTUAL*/

    FOR record IN rec_kardex(pin_id_cia, pin_periodo, pin_tipinv) LOOP 
    IF record.kid = 'S' THEN
        UPDATE articulos_costo
        SET
            costo01 = costo01 + record.kcostot01,
            costo02 = costo02 + record.kcostot02,
            cantid = cantid + record.kcantid
        WHERE
            id_cia = pin_id_cia
            AND periodo = record.kperiodo
            AND tipinv = record.ktipinv
            AND codart = record.kcodart;

    ELSE
        UPDATE articulos_costo
        SET
            costo01 = costo01 - record.kcostot01,
            costo02 = costo02 - record.kcostot02,
            cantid = cantid - record.kcantid
        WHERE
            id_cia = pin_id_cia
            AND periodo = record.kperiodo
            AND tipinv = record.ktipinv
            AND codart = record.kcodart;

    END IF;
    END LOOP;

    pout_mensaje := 'Success';
END sp_costo_promedio02;

/
