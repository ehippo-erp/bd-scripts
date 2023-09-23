--------------------------------------------------------
--  DDL for Function SP00_COSTOS_FOB_ORDEN_IMPORTACION_02
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP00_COSTOS_FOB_ORDEN_IMPORTACION_02" (
    pin_id_cia IN NUMBER,
    pin_tipdoc IN NUMBER,
    pin_series IN VARCHAR2,
    pin_numdoc IN NUMBER
) RETURN tbl_costos_fob_orden_importacion_02
    PIPELINED
AS

    rcostos_fob rec_costos_fob_orden_importacion_02 := rec_costos_fob_orden_importacion_02(NULL, NULL, NULL, NULL, NULL,
                                                                                          NULL, NULL, NULL, NULL, NULL,
                                                                                          NULL, NULL, NULL, NULL, NULL,
                                                                                          NULL, NULL, NULL, NULL, NULL, NULL);
    CURSOR cur_rcostos_fob (
        pmon1 VARCHAR2,
        pmon2 VARCHAR2
    ) IS
    SELECT
        g.numint,
        g.numite,
        g.tipinv,
        g.codart,
        a.descri                                      AS desart,
        g.cantid,
        c.tipcam,
        tc.venta                                      AS tipcam2,
        CAST(od.monafe + od.monina + od.monexo AS NUMERIC(16, 5)) AS wneto,
        oc.tipmon,
        od.cantid * (
            CASE
                WHEN cl.vreal IS NULL THEN
                    1
                ELSE
                    cl.vreal
            END
        )                                             AS wodcantid,
        ic.numdoc                                     AS dinumdoc,
        id.numite                                     AS dinumite,
        oc.numdoc                                     AS ocnumdoc,
        oc.numint                                         AS ocnumint,
        od.numite                                     AS ocnumite,
        oc.flete                                      AS ocflete,
        oc.seguro                                     AS ocseguro,
        CASE
            WHEN car.vreal IS NULL THEN
                0
            ELSE
                car.vreal
        END                                           AS arancel
    FROM
             documentos_det g
        INNER JOIN documentos_cab              c ON c.id_cia = pin_id_cia
                                       AND c.numint = g.numint                                /* GUIA INTERNA */
        INNER JOIN tcambio                     tc ON tc.id_cia = pin_id_cia
                                 AND tc.fecha = c.femisi
                                 AND tc.hmoneda = pmon1
                                 AND tc.moneda = pmon2  /* TIPO DE CAMBIO DOLARES */
        INNER JOIN articulos                   a ON a.id_cia = pin_id_cia
                                  AND a.tipinv = g.tipinv
                                  AND a.codart = g.codart
        INNER JOIN documentos_ent              e ON e.id_cia = pin_id_cia
                                       AND e.orinumint = g.numint
                                       AND e.orinumite = g.numite
        INNER JOIN documentos_cab              ic ON ic.id_cia = pin_id_cia
                                        AND ic.numint = e.opnumdoc /* DOCUMENTO DE IMPORTACION */
        INNER JOIN documentos_det              id ON id.id_cia = pin_id_cia
                                        AND id.numint = e.opnumdoc
                                        AND id.numite = e.opnumite    /* DOCUMENTO DE IMPORTACION */
        INNER JOIN documentos_cab              oc ON oc.id_cia = pin_id_cia
                                        AND oc.numint = id.opnumdoc
        INNER JOIN documentos_det              od ON od.id_cia = pin_id_cia
                                        AND od.numint = id.opnumdoc
                                        AND od.numite = id.opnumite  /* ORDEN DE COMPRA */
        LEFT OUTER JOIN articulos_clase_alternativo cl ON cl.id_cia = pin_id_cia
                                                          AND cl.tipinv = od.tipinv
                                                          AND cl.codart = od.codart
                                                          AND cl.clase = 2
                                                          AND cl.codigo = od.codund
        LEFT OUTER JOIN documentos_det_clase        car ON car.id_cia = pin_id_cia
                                                    AND car.numint = od.numint
                                                    AND car.numite = od.numite
                                                    AND car.clase = 9
    WHERE
            g.id_cia = pin_id_cia
        AND c.tipdoc = pin_tipdoc
        AND c.series = pin_series
        AND c.numdoc = pin_numdoc
        AND ( upper(c.situac) <> 'J' )
        AND ( upper(c.situac) <> 'K' );

    CURSOR cur_rcostos_fob_seguro_flete (
        pmon1    VARCHAR2,
        pmon2    VARCHAR2,
        v_numdoc NUMBER
    ) IS
    SELECT
        g.numint,
        g.numite,
        CAST(od.monafe + od.monina + od.monexo AS NUMERIC(16, 5)) AS wneto,
        oc.numdoc                                     AS ocnumdoc,
        od.numite                                     AS ocnumite,
        oc.flete                                      AS ocflete,
        oc.seguro                                     AS ocseguro,
        CASE
            WHEN car.vreal IS NULL THEN
                0
            ELSE
                car.vreal
        END                                           AS arancel
    FROM
             documentos_det g
        INNER JOIN documentos_cab              c ON c.id_cia = pin_id_cia
                                       AND c.numint = g.numint                                /* GUIA INTERNA */
        INNER JOIN tcambio                     tc ON tc.id_cia = pin_id_cia
                                 AND tc.fecha = c.femisi
                                 AND tc.hmoneda = pmon1
                                 AND tc.moneda = pmon2  /* TIPO DE CAMBIO DOLARES */
        INNER JOIN articulos                   a ON a.id_cia = pin_id_cia
                                  AND a.tipinv = g.tipinv
                                  AND a.codart = g.codart
        INNER JOIN documentos_ent              e ON e.id_cia = pin_id_cia
                                       AND e.orinumint = g.numint
                                       AND e.orinumite = g.numite
        INNER JOIN documentos_cab              ic ON ic.id_cia = pin_id_cia
                                        AND ic.numint = e.opnumdoc /* DOCUMENTO DE IMPORTACION */
        INNER JOIN documentos_det              id ON id.id_cia = pin_id_cia
                                        AND id.numint = e.opnumdoc
                                        AND id.numite = e.opnumite    /* DOCUMENTO DE IMPORTACION */
        INNER JOIN documentos_cab              oc ON oc.id_cia = pin_id_cia
                                        AND oc.numint = id.opnumdoc
        INNER JOIN documentos_det              od ON od.id_cia = pin_id_cia
                                        AND od.numint = id.opnumdoc
                                        AND od.numite = id.opnumite  /* ORDEN DE COMPRA */
        LEFT OUTER JOIN articulos_clase_alternativo cl ON cl.id_cia = pin_id_cia
                                                          AND cl.tipinv = od.tipinv
                                                          AND cl.codart = od.codart
                                                          AND cl.clase = 2
                                                          AND cl.codigo = od.codund
        LEFT OUTER JOIN documentos_det_clase        car ON car.id_cia = pin_id_cia
                                                    AND car.numint = od.numint
                                                    AND car.numite = od.numite
                                                    AND car.clase = 9
    WHERE
            g.id_cia = pin_id_cia
        AND c.tipdoc = pin_tipdoc
        AND c.series = pin_series
        AND c.numdoc = pin_numdoc
        AND oc.numdoc = v_numdoc
        AND ( upper(c.situac) <> 'J' )
        AND ( upper(c.situac) <> 'K' );

    v_mon1      VARCHAR2(5) := '';
    v_mon2      VARCHAR2(5) := '';
    v_tmp       NUMERIC(16, 5) := '';
    v_tmpflete  NUMBER(16, 2) := '';
    v_tmpseguro NUMBER(16, 2) := '';
    v_totalsol  NUMBER(16, 2) := '';
    v_totaldol  NUMBER(16, 2) := '';
    v_seguro    NUMBER(16, 2) := '';
    v_flete     NUMBER(16, 2) := '';
    v_totalneto NUMBER(16, 2) := '';
BEGIN

/* EJEMPLO DE USO
  SELECT * FROM TABLE(SP00_COSTOS_FOB_ORDEN_IMPORTACION_02(5,102,'111',2008080002));
*/
    BEGIN
        SELECT
            upper(moneda01),
            upper(moneda02)
        INTO
            v_mon1,
            v_mon2
        FROM
            companias
        WHERE
            cia = pin_id_cia;

    EXCEPTION
        WHEN no_data_found THEN
            v_mon1 := NULL;
            v_mon2 := NULL;
    END;

    FOR registro IN cur_rcostos_fob(v_mon1, v_mon2) LOOP
        rcostos_fob.numint := registro.numint;
        rcostos_fob.numite := registro.numite;
        rcostos_fob.tipinv := registro.tipinv;
        rcostos_fob.codart := registro.codart;
        rcostos_fob.desart := registro.desart;
        rcostos_fob.cantid := registro.cantid;
        rcostos_fob.tipcam := registro.tipcam;
        rcostos_fob.tipcam2 := registro.tipcam2;
        --rcostos_fob.wneto := registro.wneto;
        rcostos_fob.wtipmon := registro.tipmon;
        rcostos_fob.wodcantid := registro.wodcantid;
        rcostos_fob.dinumdoc := registro.dinumdoc;
        rcostos_fob.dinumite := registro.dinumite;
        rcostos_fob.ocnumdoc := registro.ocnumdoc;
        rcostos_fob.ocnumint := registro.ocnumint;
        rcostos_fob.ocnumite := registro.ocnumite;
        --rcostos_fob.ocflete  := NVL(registro.ocflete,0);
        --rcostos_fob.ocseguro := NVL(registro.ocseguro,0);
        rcostos_fob.arancel := registro.arancel;
        rcostos_fob.tfobsol := 0;
        rcostos_fob.tfobdol := 0;
        IF ( rcostos_fob.wneto IS NULL ) THEN
            rcostos_fob.wneto := 0;
        END IF;

        IF ( nvl(registro.ocflete, 0) <> 0 OR nvl(registro.ocseguro, 0) <> 0 ) THEN
            v_totalneto := 0;
            v_flete := 0;
            v_seguro := 0;
            FOR registro_anidado IN cur_rcostos_fob_seguro_flete(v_mon1, v_mon2, registro.ocnumdoc) LOOP
                v_totalneto := v_totalneto + registro_anidado.wneto;
            END LOOP;

            IF ( nvl(registro.ocseguro, 0) <> 0 ) THEN
                v_seguro := ( registro.wneto / v_totalneto ) * nvl(registro.ocseguro, 0);
            ELSE
                v_seguro := 0;
            END IF;

            IF ( nvl(registro.ocflete, 0) <> 0 ) THEN
                v_flete := ( registro.wneto / v_totalneto ) * nvl(registro.ocflete, 0);
            ELSE
                v_flete := 0;
            END IF;

            rcostos_fob.wneto := registro.wneto + v_flete + v_seguro;
            rcostos_fob.ocflete := v_flete;
            rcostos_fob.ocseguro := v_seguro;
        ELSE
            rcostos_fob.wneto := registro.wneto;
            rcostos_fob.ocflete := nvl(registro.ocflete, 0);
            rcostos_fob.ocseguro := nvl(registro.ocseguro, 0);
        END IF;

        IF ( rcostos_fob.wtipmon = v_mon1 ) THEN
            rcostos_fob.tfobsol := ( ( rcostos_fob.wneto) / rcostos_fob.wodcantid ) * rcostos_fob.
            cantid;
        ELSE
            v_tmp := rcostos_fob.wneto * rcostos_fob.tipcam;
            rcostos_fob.tfobsol := ( ( v_tmp ) / rcostos_fob.wodcantid ) * rcostos_fob.cantid;

        END IF;

        IF ( rcostos_fob.wtipmon <> v_mon1 ) THEN
            IF ( rcostos_fob.wtipmon = v_mon2 ) THEN
                rcostos_fob.tfobdol := ( ( rcostos_fob.wneto) / rcostos_fob.wodcantid ) *
                rcostos_fob.cantid;

            ELSE
                IF ( rcostos_fob.wtipmon = v_mon1 ) THEN
                    rcostos_fob.tfobdol := ( ( ( rcostos_fob.wneto ) / rcostos_fob.tipcam ) /
                    rcostos_fob.wodcantid ) * rcostos_fob.cantid;

                ELSE
                    v_tmp := rcostos_fob.wneto * ( rcostos_fob.tipcam / rcostos_fob.tipcam2 );
                    rcostos_fob.tfobdol := ( ( v_tmp ) / rcostos_fob.wodcantid ) * rcostos_fob.cantid;

                END IF;
            END IF;
        END IF;

        PIPE ROW ( rcostos_fob );
    END LOOP;

END sp00_costos_fob_orden_importacion_02;

/
