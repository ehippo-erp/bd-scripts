--------------------------------------------------------
--  DDL for Procedure SP002_ACTUALIZA_SITUACION_DOCUMENTO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP002_ACTUALIZA_SITUACION_DOCUMENTO" (
    pid_cia         IN   NUMBER,
    pnumint         IN   NUMBER,
    psituac         IN   VARCHAR2,
    pswacti         IN   VARCHAR2,
    pswmuestramsje  IN   VARCHAR2,
    pcoduser        IN   VARCHAR2,
    strswresult     OUT  VARCHAR2,
    strresult       OUT  VARCHAR2
) AS

    v_result   VARCHAR2(1);
    v_message  VARCHAR2(1000);
    wdesdoc    VARCHAR2(30);
    wdessit    VARCHAR2(30);
    wtipdoc    NUMBER;
    wseries    VARCHAR2(5);
    wnumdoc    NUMBER;
BEGIN
    v_result := 'S';
    v_message := '';
  /*-- SI TODO ESTA OK.. ENTONCES PROCEDE --*/
    IF ( v_result = 'S' ) THEN
        IF ( upper(pswacti) = 'S' ) THEN
            UPDATE documentos_cab
            SET
                swacti = psituac,
                usuari = pcoduser
            WHERE
                ( id_cia = pid_cia )
                AND ( numint = pnumint );

        ELSE
            UPDATE documentos_cab
            SET
                situac = psituac,
                usuari = pcoduser
            WHERE
                ( id_cia = pid_cia )
                AND ( numint = pnumint );

        END IF;

        UPDATE documentos_det
        SET
            situac = psituac
        WHERE
            ( id_cia = pid_cia )
            AND ( numint = pnumint );

        v_result := 'S';
        IF ( upper(pswmuestramsje) = 'S' ) THEN
            BEGIN
                SELECT
                    d.descri,
                    dc.tipdoc,
                    dc.series,
                    dc.numdoc,
                    s.dessit
                INTO
                    wdesdoc,
                    wtipdoc,
                    wseries,
                    wnumdoc,
                    wdessit
                FROM
                    documentos_cab  dc
                    LEFT OUTER JOIN documentos      d ON ( d.id_cia = dc.id_cia )
                                                    AND d.codigo = dc.tipdoc
                                                    AND d.series = dc.series
                    LEFT OUTER JOIN situacion       s ON ( s.id_cia = dc.id_cia )
                                                   AND s.tipdoc = dc.tipdoc
                                                   AND s.situac = psituac
                WHERE
                        dc.id_cia = pid_cia
                    AND dc.numint = pnumint;

            EXCEPTION
                WHEN no_data_found THEN
                    wdesdoc := '';
                    wtipdoc := 0;
                    wnumdoc := 0;
                    wseries := '';
                    wdessit := '';
            END;

            v_message := v_message
                         || chr(13)
                         || 'Al documento '
                         || wdesdoc
                         || ' '
                         || wseries
                         || '-'
                         || to_char(wnumdoc)
                         || ' se le cambio la situacion a '
                         || wdessit;

        END IF;

    END IF;

    strswresult := v_result;
    strresult := v_message;
END sp002_actualiza_situacion_documento;

/
