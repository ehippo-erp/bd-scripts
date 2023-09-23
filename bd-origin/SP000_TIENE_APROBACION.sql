--------------------------------------------------------
--  DDL for Procedure SP000_TIENE_APROBACION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_TIENE_APROBACION" (
    pid_cia        IN   NUMBER,
    pnumint        IN   NUMBER,
    pswmuestramsj  IN   VARCHAR2,
    pswresultado   OUT  VARCHAR2,
    pmessage       OUT  VARCHAR2
) IS

    wconteo  NUMBER;
    wdescri  VARCHAR2(30);
    wtipdoc  NUMBER;
    wseries  VARCHAR2(5);
    wnumdoc  NUMBER;
BEGIN
    pswresultado := 'N';
    pmessage := '';
    wconteo := 0;
    BEGIN
        SELECT
            COUNT(0) AS conteo,
            d.descri,
            dc.tipdoc,
            dc.series,
            dc.numdoc
        INTO
            wconteo,
            wdescri,
            wtipdoc,
            wseries,
            wnumdoc
        FROM
            documentos_aprobacion  da
            LEFT OUTER JOIN documentos_cab         dc ON dc.id_cia = da.id_cia
                                                 AND dc.numint = da.numint
            LEFT OUTER JOIN documentos             d ON d.id_cia = dc.id_cia
                                            AND d.codigo = dc.tipdoc
                                            AND d.series = dc.series
        WHERE
                da.id_cia = pid_cia
            AND da.numint = pnumint
            AND da.situac = 'B' /* B =APROBADO */
        GROUP BY
            d.descri,
            dc.tipdoc,
            dc.series,
            dc.numdoc;

    EXCEPTION
        WHEN no_data_found THEN
            wconteo := 0;
            wdescri := '';
            wtipdoc := 0;
            wnumdoc := 0;
            wseries := '';
    END;

    IF ( wconteo > 0 ) THEN
        pswresultado := 'S';
        IF ( upper(pswmuestramsj) = 'S' ) THEN
            pmessage := 'El Documento '
                        || wdescri
                        || ' '
                        || wseries
                        || '-'
                        || to_char(wnumdoc)
                        || ' Esta Aprobado ';

        END IF;

    END IF;

END sp000_tiene_aprobacion;

/
