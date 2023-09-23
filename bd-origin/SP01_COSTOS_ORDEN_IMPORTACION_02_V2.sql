--------------------------------------------------------
--  DDL for Function SP01_COSTOS_ORDEN_IMPORTACION_02_V2
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP01_COSTOS_ORDEN_IMPORTACION_02_V2" (
    pin_id_cia IN NUMBER,
    pin_tipdoc IN NUMBER,
    pin_series IN VARCHAR2,
    pin_numdoc IN NUMBER
) RETURN tbl_costos_orden_importacion_02_v2
    PIPELINED
AS

    rcostos_orden_importacion rec_costos_orden_importacion_02_v2 := rec_costos_orden_importacion_02_v2(NULL, NULL, NULL, NULL, NULL,
                                                                                                      NULL, NULL, NULL, NULL, NULL,
                                                                                                      NULL, NULL, NULL, NULL, NULL,
                                                                                                      NULL, NULL, NULL, NULL, NULL,
                                                                                                      NULL, NULL, NULL, NULL, NULL,
                                                                                                      NULL, NULL, NULL, NULL, NULL,
                                                                                                      NULL, NULL, NULL, NULL, NULL);
    CURSOR cur_costos_orden_importacion IS
    SELECT
        c.numint,
        c.numite,
        c.tipinv,
        c.codart,
        c.desart,
        c.cantid,
        c.tfobsol,
        c.tfobdol,
        c.dinumdoc,
        c.dinumite,
        c.ocnumdoc,
        c.ocnumite,
        c.arancel AS poraran
    FROM
        TABLE ( sp00_costos_fob_orden_importacion_02(pin_id_cia, pin_tipdoc, pin_series, pin_numdoc) ) c;

    v_monimpo                 VARCHAR2(5);
    v_mon1                    VARCHAR2(5);
    v_mon2                    VARCHAR2(5);
    v_totfob                  NUMERIC(16, 3);
    v_flete                   NUMERIC(16, 3);
    v_seguro                  NUMERIC(16, 3);
BEGIN

/* EJEMPLO DE USO
  SELECT * FROM TABLE(SP01_COSTOS_ORDEN_IMPORTACION_02_V2(5,115,'111',2008090001,223232));
*/
    rcostos_orden_importacion.segurosol := 0;
    rcostos_orden_importacion.fletesol := 0;
    rcostos_orden_importacion.segurodol := 0;
    rcostos_orden_importacion.fletedol := 0;
    rcostos_orden_importacion.gasvindol := 0;
    rcostos_orden_importacion.gasvinsol := 0;
    BEGIN
        SELECT
            TRIM(upper(moneda01)),
            TRIM(upper(moneda02))
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

    BEGIN
     /* ACUMULA LOS COSTOS FOB */
        SELECT
            SUM(tfobsol),
            SUM(tfobdol),
            AVG(tipcam),
            AVG(tipcam2)
        INTO
            rcostos_orden_importacion.totfobsol,
            rcostos_orden_importacion.totfobdol,
            rcostos_orden_importacion.tipcam,
            rcostos_orden_importacion.tipcam2
        FROM
            TABLE ( sp00_costos_fob_orden_importacion_02(pin_id_cia, pin_tipdoc, pin_series, pin_numdoc) );

    EXCEPTION
        WHEN no_data_found THEN
            rcostos_orden_importacion.totfobsol := 0;
            rcostos_orden_importacion.totfobdol := 0;
            rcostos_orden_importacion.tipcam := 0;
            rcostos_orden_importacion.tipcam2 := 0;
    END;

    BEGIN
      /*  SACA FLETE Y SEGURO */
        SELECT
            MAX(c.seguro),
            MAX(c.flete),
            MAX(c.tipmon)
        INTO
            v_seguro,
            v_flete,
            v_monimpo
        FROM
            documentos_cab c
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = pin_tipdoc
            AND c.series = pin_series
            AND c.numdoc = pin_numdoc
            AND ( upper(c.situac) <> 'J' )
            AND ( upper(c.situac) <> 'K' );

    EXCEPTION
        WHEN no_data_found THEN
            v_seguro := 0;
            v_flete := 0;
            v_monimpo := 0;
    END;

    IF ( v_monimpo = v_mon1 ) THEN /* SOLES */
        rcostos_orden_importacion.totsegsol := v_seguro;
        rcostos_orden_importacion.totsegdol := v_seguro / rcostos_orden_importacion.tipcam;
        rcostos_orden_importacion.totflesol := v_flete;
        rcostos_orden_importacion.totfledol := ( v_flete / rcostos_orden_importacion.tipcam );
    END IF;

    IF ( v_monimpo = v_mon2 ) THEN /* DOLARES */
        rcostos_orden_importacion.totsegsol := v_seguro * rcostos_orden_importacion.tipcam;
        rcostos_orden_importacion.totsegdol := v_seguro;
        rcostos_orden_importacion.totflesol := v_flete * rcostos_orden_importacion.tipcam;
        rcostos_orden_importacion.totfledol := v_flete;
    END IF;

    IF (
        ( v_monimpo <> v_mon1 )
        AND ( v_monimpo <> v_mon2 )
    ) THEN  /* OTRA MONEDA QUE NO SEA DOLARES PUEDE SER EUROS */
        rcostos_orden_importacion.totsegsol := v_seguro * rcostos_orden_importacion.tipcam;
        rcostos_orden_importacion.totsegdol := ( v_seguro / rcostos_orden_importacion.tipcam2 );
        rcostos_orden_importacion.totflesol := v_flete * rcostos_orden_importacion.tipcam;
        rcostos_orden_importacion.totfledol := ( v_flete / rcostos_orden_importacion.tipcam2 );
    END IF;

    BEGIN
     /*  SACA GASTOS VINCULADOS EN SOLES  */
        SELECT
            SUM(
                CASE
                    WHEN swgasoper = 1 THEN
                        tgeneral1
                    ELSE
                        0
                END
            )                               AS tgasvinsol,
            SUM(
                CASE
                    WHEN swgasoper = 1 THEN
                        tgeneral2
                    ELSE
                        0
                END
            )                               AS tgasvindol,
            SUM(tgeneral1) / SUM(tgeneral2) AS tipcam
        INTO
            rcostos_orden_importacion.tgasvinsol,
            rcostos_orden_importacion.tgasvindol,
            rcostos_orden_importacion.tipcam
        FROM
            TABLE ( sp00_gastos_vinculados_orden_importacion_v2(pin_id_cia, pin_tipdoc, pin_series, pin_numdoc) );

    EXCEPTION
        WHEN no_data_found THEN
            rcostos_orden_importacion.tgasvinsol := 0;
            rcostos_orden_importacion.tgasvindol := 0;
            rcostos_orden_importacion.tipcam := 0;/* SACA TIPO DE CAMBIO PROMEDIO DE LOS GASTOS VINCULADOS */
    END;

    IF ( v_monimpo = v_mon1 ) THEN
        v_totfob := rcostos_orden_importacion.totfobsol;
    ELSE
        v_totfob := rcostos_orden_importacion.totfobdol;
    END IF;

    CASE
        WHEN v_totfob = 0 THEN
            rcostos_orden_importacion.fletefac := 0;
            rcostos_orden_importacion.segurofac := 0;
        ELSE
            rcostos_orden_importacion.fletefac := ( ( v_flete + v_totfob ) / v_totfob );
            rcostos_orden_importacion.segurofac := ( ( v_seguro + v_totfob ) / v_totfob );
    END CASE;

    CASE
        WHEN rcostos_orden_importacion.totfobdol = 0 THEN
            rcostos_orden_importacion.gasvinfac := 0;
        ELSE
            rcostos_orden_importacion.gasvinfac := ( ( rcostos_orden_importacion.tgasvindol + rcostos_orden_importacion.totfobdol ) /
            rcostos_orden_importacion.totfobdol ); /* GASTOS VINCULADOS EN DOLARES */
    END CASE;

    FOR registro IN cur_costos_orden_importacion LOOP
        rcostos_orden_importacion.numint := registro.numint;
        rcostos_orden_importacion.numite := registro.numite;
        rcostos_orden_importacion.tipinv := registro.tipinv;
        rcostos_orden_importacion.codart := registro.codart;
        rcostos_orden_importacion.desart := registro.desart;
        rcostos_orden_importacion.cantid := registro.cantid;
        rcostos_orden_importacion.tfobsol := registro.tfobsol;
        rcostos_orden_importacion.tfobdol := registro.tfobdol;
        rcostos_orden_importacion.dinumdoc := registro.dinumdoc;
        rcostos_orden_importacion.dinumite := registro.dinumite;
        rcostos_orden_importacion.ocnumdoc := registro.ocnumdoc;
        rcostos_orden_importacion.ocnumite := registro.ocnumite;
        rcostos_orden_importacion.poraran := registro.poraran;
        rcostos_orden_importacion.segurosol := ( rcostos_orden_importacion.tfobsol * rcostos_orden_importacion.segurofac ) - rcostos_orden_importacion.
        tfobsol;

        rcostos_orden_importacion.segurodol := ( rcostos_orden_importacion.tfobdol * rcostos_orden_importacion.segurofac ) - rcostos_orden_importacion.
        tfobdol;

        rcostos_orden_importacion.fletesol := ( rcostos_orden_importacion.tfobsol * rcostos_orden_importacion.fletefac ) - rcostos_orden_importacion.
        tfobsol;

        rcostos_orden_importacion.fletedol := ( rcostos_orden_importacion.tfobdol * rcostos_orden_importacion.fletefac ) - rcostos_orden_importacion.
        tfobdol;

        rcostos_orden_importacion.gasvinsol := ( rcostos_orden_importacion.tfobsol * rcostos_orden_importacion.gasvinfac ) - rcostos_orden_importacion.
        tfobsol;

        rcostos_orden_importacion.gasvindol := ( rcostos_orden_importacion.tfobdol * rcostos_orden_importacion.gasvinfac ) - rcostos_orden_importacion.
        tfobdol;

        rcostos_orden_importacion.arancedol := ( ( ( rcostos_orden_importacion.tfobdol + rcostos_orden_importacion.fletedol + rcostos_orden_importacion.
        segurodol ) * rcostos_orden_importacion.poraran ) / 100 );

        rcostos_orden_importacion.tcostotdol := ( rcostos_orden_importacion.tfobdol + rcostos_orden_importacion.arancedol + rcostos_orden_importacion.
        gasvindol );

        rcostos_orden_importacion.tcostotsol := ( rcostos_orden_importacion.tcostotdol * rcostos_orden_importacion.tipcam );
        PIPE ROW ( rcostos_orden_importacion );
    END LOOP;

END sp01_costos_orden_importacion_02_v2;

/
