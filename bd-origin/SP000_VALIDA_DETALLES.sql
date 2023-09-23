--------------------------------------------------------
--  DDL for Procedure SP000_VALIDA_DETALLES
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_VALIDA_DETALLES" (
    pid_cia        IN   NUMBER,
    pnumint        IN   NUMBER,
    pswmuestramsj  IN   VARCHAR2,
    pswcantid      IN   VARCHAR2,
    pswpreuni      IN   VARCHAR2,
    pswresultado   OUT  VARCHAR2,
    pmessage       OUT  VARCHAR2
) IS

    wid_cia              NUMBER;
    wconteo              NUMBER;
    wdescri              VARCHAR2(30);
    wtipdoc              NUMBER;
    wseries              VARCHAR2(5);
    wnumdoc              NUMBER;
    wcla017precanmaycer  VARCHAR2(1);
    wswcantid            VARCHAR2(1);
    wswpreuni            VARCHAR2(1);
BEGIN
    wid_cia := pid_cia;
    wswcantid := pswcantid;
    wswpreuni := pswpreuni;
    pswresultado := 'S';
    pmessage := '';
    wconteo := 0;
    wcla017precanmaycer := 'S';
    BEGIN
        SELECT
            m.valor
        INTO wcla017precanmaycer
        FROM
                 documentos_cab c
            INNER JOIN motivos_clase m ON m.id_cia = c.id_cia
                                          AND m.tipdoc = c.tipdoc
                                          AND m.codmot = c.codmot
                                          AND m.id = c.id
                                          AND m.codigo = 17 /* CLASE PARA VALIDAR PRECIOS Y CANTIDADES >0 */
        WHERE
                c.id_cia = pid_cia
            AND c.numint = pnumint;

    EXCEPTION
        WHEN no_data_found THEN
            wcla017precanmaycer := NULL;
    END;

    IF ( ( wcla017precanmaycer IS NULL ) OR ( upper(wcla017precanmaycer) <> 'N' ) ) THEN
        wcla017precanmaycer := 'S';
    END IF;

    IF ( upper(wcla017precanmaycer) <> 'S' ) THEN --SIMPLEMENTE YA NO LOS CONTROLA ASI VENGAN MARCADOS 
        wswcantid := 'N';
        wswpreuni := 'N';
    END IF;

    BEGIN
        SELECT
            COUNT(0) AS conteo
        INTO wconteo
        FROM
            documentos_det
        WHERE
                id_cia = pid_cia
            AND ( numint = pnumint )
            AND ( NOT ( situac IN (
                'J',
                'K'
            ) ) );

    EXCEPTION
        WHEN no_data_found THEN
            wconteo := 0;
    END;

    IF ( wconteo = 0 ) THEN
        pswresultado := 'N';
        IF ( upper(pswresultado) = 'S' ) THEN
            pmessage := pmessage || ' NO TIENE DETALLE';
        END IF;

    END IF;

    wconteo := 0;
------------
    IF ( upper(wswcantid) = 'S' ) THEN
        BEGIN
            SELECT
                COUNT(0) AS conteo
            INTO wconteo
            FROM
                documentos_det
            WHERE
                ( id_cia = pid_cia )
                AND ( numint = pnumint )
                AND ( NOT ( situac IN (
                    'J',
                    'K'
                ) ) )
                AND ( cantid = 0 ); /* VERIFICA CANTIDAD */

        EXCEPTION
            WHEN no_data_found THEN
                wconteo := 0;
        END;

        IF ( wconteo > 0 ) THEN
            pswresultado := 'N';
            IF ( upper(pswmuestramsj) = 'S' ) THEN
                pmessage := pmessage
                            || ', Tiene '
                            || to_char(wconteo)
                            || ' detalles con cantidades en cero';
            END IF;

        END IF;

    END IF;
----------

    wconteo := 0;
    IF ( upper(wswpreuni) = 'S' ) THEN
        BEGIN
            SELECT
                COUNT(0) AS conteo
            INTO wconteo
            FROM
                documentos_det
            WHERE
                ( id_cia = pid_cia )
                AND ( numint = pnumint )
                AND ( NOT ( situac IN (
                    'J',
                    'K'
                ) ) )
                AND ( preuni = 0 ); /* VERIFICA PRE-UNITARIO */

        EXCEPTION
            WHEN no_data_found THEN
                wconteo := 0;
        END;

        IF ( wconteo > 0 ) THEN
            pswresultado := 'N';
            IF ( upper(pswmuestramsj) = 'S' ) THEN
                pmessage := pmessage
                            || ', Tiene '
                            || to_char(wconteo)
                            || ' detalles con precio en cero';
            END IF;

        END IF;

    END IF;
   ------

    IF (
        ( pswresultado = 'N' ) AND ( upper(pswmuestramsj) = 'S' )
    ) THEN
        BEGIN
            SELECT
                d.descri,
                dc.tipdoc,
                dc.series,
                dc.numdoc
            INTO
                wdescri,
                wtipdoc,
                wseries,
                wnumdoc
            FROM
                documentos_cab  dc
                LEFT OUTER JOIN documentos      d ON d.id_cia = dc.id_cia
                                                AND d.codigo = dc.tipdoc
                                                AND d.series = dc.series
            WHERE
                    dc.id_cia = pid_cia
                AND dc.numint = pnumint;

        EXCEPTION
            WHEN no_data_found THEN
                wdescri := '';
                wtipdoc := 0;
                wnumdoc := 0;
                wseries := '';
        END;
    END IF;

    pmessage := 'El documento '
                || wdescri
                || ' '
                || wseries
                || '-'
                || to_char(wnumdoc)
                || ' '
                || pmessage;

END sp000_valida_detalles;

/
