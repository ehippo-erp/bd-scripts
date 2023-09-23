--------------------------------------------------------
--  DDL for Procedure SP003_ACTUALIZA_SITUACION_DOCUMENTO_SEGUN_SALDO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP003_ACTUALIZA_SITUACION_DOCUMENTO_SEGUN_SALDO" (
    pid_cia        IN   NUMBER,
    pnumint        IN   NUMBER,
    pswmuestramsj  IN   VARCHAR2,
    pcoduser       IN   VARCHAR2,
    pswresultado   OUT  VARCHAR2,
    pmessage       OUT  VARCHAR2
) AS

    wtipdoc      NUMBER;
    wseries      VARCHAR2(5);
    wsaldo       NUMBER(16, 5);
    wpendiente   NUMBER;
    wtotal       NUMBER;
    wsituac      VARCHAR2(1);
    v_resultado  VARCHAR2(1);
    v_message    VARCHAR2(1000);
    CURSOR cselect (
        wid_cia  NUMBER,
        wnumint  NUMBER
    ) IS
    SELECT
        c.series,
        d.tipdoc,
        d.saldo
    FROM
        TABLE ( sp_saldo_documentos_det_001(wid_cia, wnumint, 0) )       d
        LEFT OUTER JOIN documentos_cab                                                   c ON c.id_cia = wid_cia
                                            AND c.numint = wnumint;

BEGIN
 ---------------------
    v_resultado := 'S';
    v_message := '';
    wsituac := 'A';
    IF (
        ( pnumint IS NOT NULL ) AND ( pnumint <> 0 )
    ) THEN
        wtotal := 0;
        wpendiente := 0;
        FOR registro IN cselect(pid_cia, pnumint) LOOP
            wseries := registro.series;
            wtipdoc := registro.tipdoc;
            wsaldo := nvl(registro.saldo, 0);
            wtotal := wtotal + 1;
            IF ( wsaldo > 0 ) THEN
                wpendiente := wpendiente + 1;
            END IF;
        END LOOP;

        wsituac := 'B';
        IF (
            ( wtotal > 0 ) AND ( wpendiente = 0 )
        ) THEN

            sp000_marca_completo_parcial(pid_cia, pnumint, wtipdoc, wseries, 'C',  /* COMPLETO */
                                         wtotal, wpendiente, pcoduser,wsituac);
        ELSE
            IF ( wtotal >= wpendiente ) THEN

                sp000_marca_completo_parcial(pid_cia, pnumint, wtipdoc, wseries, 'P',  /* PARCIAL */
                                             wtotal, wpendiente, pcoduser,wsituac);

            ELSE
                sp000_marca_completo_parcial(pid_cia, pnumint, wtipdoc, wseries, 'C',  /* COMPLETO */
                                             wtotal, wpendiente, pcoduser,wsituac);
            END IF;
        END IF;

    END IF;

    IF ( wsituac = 'X' ) THEN /* ESTA X VIENE DE SP000_MARCA_COMPLETO_PARCIAL   */
        v_resultado := 'N';
        IF (
            ( v_resultado = 'N' ) AND ( pswmuestramsj = 'S' )
        ) THEN
            v_message := v_message
                         || chr(13)
                         || ' No se realizo el cambio de situacion';
        END IF;

    ELSE
        sp002_actualiza_situacion_documento(pid_cia, pnumint, wsituac,
            CASE
                WHEN wtipdoc IN(
                    1, 3
                ) THEN
                    'S'
                ELSE 'N'
            END,
                                            pswmuestramsj, pcoduser,v_resultado, v_message);

        IF ( v_resultado IS NULL ) THEN
            v_resultado := 'N';
        END IF;
    END IF;

    pswresultado := v_resultado;
    pmessage := v_message;
END sp003_actualiza_situacion_documento_segun_saldo;

/
