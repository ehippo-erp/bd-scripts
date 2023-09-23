--------------------------------------------------------
--  DDL for Procedure SP_GENERA_ASIENTO_DIFERENCIA_CAMBIO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_GENERA_ASIENTO_DIFERENCIA_CAMBIO" (
    pin_id_cia  IN NUMBER,
    pin_periodo IN NUMBER,
    pin_libro   IN VARCHAR2,
    pin_mes     IN NUMBER,
    pin_asiento IN NUMBER,
    pin_coduser IN VARCHAR2
) AS

    moneda01 VARCHAR(5);
    moneda02 VARCHAR(5);
    cdifdeb  VARCHAR(16);
    cdifhab  VARCHAR(16);
    cuenta   VARCHAR(16);
    dh       VARCHAR(1);
    fecha    DATE;
    total01  NUMERIC(16, 2);
    total02  NUMERIC(16, 2);
    maxitem  INTEGER;
    importe  NUMERIC(16, 2);
    impor01  NUMERIC(16, 2);
    impor02  NUMERIC(16, 2);
    debe     NUMERIC(16, 2);
    debe01   NUMERIC(16, 2);
    debe02   NUMERIC(16, 2);
    haber    NUMERIC(16, 2);
    haber01  NUMERIC(16, 2);
    haber02  NUMERIC(16, 2);
BEGIN
    DECLARE BEGIN
        SELECT
            TRIM(moneda01),
            TRIM(moneda02)
        INTO
            moneda01,
            moneda02
        FROM
            companias
        WHERE
            cia = pin_id_cia;

    EXCEPTION
        WHEN no_data_found THEN
            moneda01 := NULL;
            moneda02 := NULL;
    END;

    SELECT
        cdifdeb,
        cdifhab
    INTO
        cdifdeb,
        cdifhab
    FROM
        tmoneda
    WHERE
            id_cia = pin_id_cia
        AND codmon = moneda01;

    SELECT
        MAX(item) AS item
    INTO maxitem
    FROM
        movimientos
    WHERE
            id_cia = pin_id_cia
        AND ( periodo = pin_periodo )
        AND ( mes = pin_mes )
        AND ( libro = pin_libro )
        AND ( asiento = pin_asiento );

    FOR i IN (
        SELECT
            MAX(fecha)            AS fecha,
            SUM(debe01 - haber01) AS total01,
            SUM(debe02 - haber02) AS total02
        FROM
            movimientos
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_libro
            AND asiento = pin_asiento
    ) LOOP
        fecha := i.fecha;
        total01 := i.total01;
        total02 := i.total02;
        IF ( (
            total01 > 0
            AND total02 > 0
        ) OR (
            total01 < 0
            AND total02 < 0
        ) ) THEN
            maxitem := maxitem + 1;
            importe := 0;
            impor01 := 0;
            impor02 := 0;
            debe := 0;
            debe01 := 0;
            debe02 := 0;
            haber := 0;
            haber01 := 0;
            haber02 := 0;
            IF ( total01 > 0 ) THEN
                dh := 'H';
                cuenta := cdifhab;
                importe := abs(total01);
                impor01 := abs(total01);
                haber01 := abs(total01);
            ELSE
                dh := 'D';
                cuenta := cdifdeb;
                importe := abs(total01);
                impor01 := abs(total01);
                debe01 := abs(total01);
            END IF;

            IF ( total02 > 0 ) THEN
                dh := 'H';
                cuenta := cdifhab;
                importe := abs(total02);
                impor02 := abs(total02);
                haber02 := abs(total02);
            ELSE
                dh := 'D';
                cuenta := cdifdeb;
                importe := abs(total02);
                impor02 := abs(total02);
                debe02 := abs(total02);
            END IF;

                importe := 0;

            INSERT INTO movimientos (
                id_cia,
                periodo,
                mes,
                libro,
                asiento,
                item,
                sitem,
                concep,
                fecha,
                tasien,
                topera,
                cuenta,
                dh,
                moneda,
                importe,
                impor01,
                impor02,
                debe,
                debe01,
                debe02,
                haber,
                haber01,
                haber02,
                tcambio01,
                tcambio02,
                ccosto,
                proyec,
                subcco,
                tipo,
                docume,
                codigo,
                razon,
                tident,
                dident,
                tdocum,
                serie,
                numero,
                fdocum,
                usuari,
                fcreac,
                factua,
                regcomcol,
                swprovicion,
                saldo,
                swgasoper,
                codporret,
                swchkconcilia,
                ctaalternativa
            ) VALUES (
                pin_id_cia,
                pin_periodo,
                pin_mes,
                pin_libro,
                pin_asiento,
                maxitem,
                0,
                'Diferencia de cambio',
                fecha,
                99,
                NULL,
                cuenta,
                dh,
                moneda01,
                importe,
                impor01,
                impor02,
                debe,
                debe01,
                debe02,
                haber,
                haber01,
                haber02,
                0,
                0,
                NULL,
                NULL,
                NULL,
                0,
                0,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                pin_coduser,
                current_timestamp,
                current_timestamp,
                0,
                'N',
                0,
                1,
                '',
                'N',
                ''
            );

        ELSE
            IF ( total01 <> 0 ) THEN
                maxitem := maxitem + 1;
                importe := 0;
                impor01 := 0;
                impor02 := 0;
                debe := 0;
                debe01 := 0;
                debe02 := 0;
                haber := 0;
                haber01 := 0;
                haber02 := 0;
                IF ( total01 > 0 ) THEN
                    dh := 'H';
                    cuenta := cdifhab;
                    importe := abs(total01);
                    impor01 := abs(total01);
                    haber01 := abs(total01);
                ELSE
                    dh := 'D';
                    cuenta := cdifdeb;
                    importe := abs(total01);
                    impor01 := abs(total01);
                    debe01 := abs(total01);
                END IF;

                INSERT INTO movimientos (
                    id_cia,
                    periodo,
                    mes,
                    libro,
                    asiento,
                    item,
                    sitem,
                    concep,
                    fecha,
                    tasien,
                    topera,
                    cuenta,
                    dh,
                    moneda,
                    importe,
                    impor01,
                    impor02,
                    debe,
                    debe01,
                    debe02,
                    haber,
                    haber01,
                    haber02,
                    tcambio01,
                    tcambio02,
                    ccosto,
                    proyec,
                    subcco,
                    tipo,
                    docume,
                    codigo,
                    razon,
                    tident,
                    dident,
                    tdocum,
                    serie,
                    numero,
                    fdocum,
                    usuari,
                    fcreac,
                    factua,
                    regcomcol,
                    swprovicion,
                    saldo,
                    swgasoper,
                    codporret,
                    swchkconcilia,
                    ctaalternativa
                ) VALUES (
                    pin_id_cia,
                    pin_periodo,
                    pin_mes,
                    pin_libro,
                    pin_asiento,
                    maxitem,
                    0,
                    'Diferencia de cambio',
                    fecha,
                    99,
                    NULL,
                    cuenta,
                    dh,
                    moneda01,
                    importe,
                    impor01,
                    impor02,
                    debe,
                    debe01,
                    debe02,
                    haber,
                    haber01,
                    haber02,
                    0,
                    0,
                    NULL,
                    NULL,
                    NULL,
                    0,
                    0,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp,
                    0,
                    'N',
                    0,
                    1,
                    '',
                    'N',
                    ''
                );

            END IF;

            IF ( total02 <> 0 ) THEN
                maxitem := maxitem + 1;
                importe := 0;
                impor01 := 0;
                impor02 := 0;
                debe := 0;
                debe01 := 0;
                debe02 := 0;
                haber := 0;
                haber01 := 0;
                haber02 := 0;
                IF ( total02 > 0 ) THEN
                    dh := 'H';
                    cuenta := cdifhab;
                    importe := abs(total02);
                    impor02 := abs(total02);
                    haber02 := abs(total02);
                ELSE
                    dh := 'D';
                    cuenta := cdifdeb;
                    importe := abs(total02);
                    impor02 := abs(total02);
                    debe02 := abs(total02);
                END IF;

                INSERT INTO movimientos (
                    id_cia,
                    periodo,
                    mes,
                    libro,
                    asiento,
                    item,
                    sitem,
                    concep,
                    fecha,
                    tasien,
                    topera,
                    cuenta,
                    dh,
                    moneda,
                    importe,
                    impor01,
                    impor02,
                    debe,
                    debe01,
                    debe02,
                    haber,
                    haber01,
                    haber02,
                    tcambio01,
                    tcambio02,
                    ccosto,
                    proyec,
                    subcco,
                    tipo,
                    docume,
                    codigo,
                    razon,
                    tident,
                    dident,
                    tdocum,
                    serie,
                    numero,
                    fdocum,
                    usuari,
                    fcreac,
                    factua,
                    regcomcol,
                    swprovicion,
                    saldo,
                    swgasoper,
                    codporret,
                    swchkconcilia,
                    ctaalternativa
                ) VALUES (
                    pin_id_cia,
                    pin_periodo,
                    pin_mes,
                    pin_libro,
                    pin_asiento,
                    maxitem,
                    0,
                    'Diferencia de cambio',
                    fecha,
                    99,
                    NULL,
                    cuenta,
                    dh,
                    moneda01,
                    importe,
                    impor01,
                    impor02,
                    debe,
                    debe01,
                    debe02,
                    haber,
                    haber01,
                    haber02,
                    0,
                    0,
                    NULL,
                    NULL,
                    NULL,
                    0,
                    0,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp,
                    0,
                    'N',
                    0,
                    1,
                    '',
                    'N',
                    ''
                );

            END IF;

        END IF;

    END LOOP;

END sp_genera_asiento_diferencia_cambio;

/
