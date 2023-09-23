--------------------------------------------------------
--  DDL for Procedure SP003A_ACTUALIZA_SITUACION_DOCUMENTO_RELACIONADOS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP003A_ACTUALIZA_SITUACION_DOCUMENTO_RELACIONADOS" (
    pid_cia        IN      NUMBER,
    pnumintori     IN      NUMBER,
    pswmuestramsj  IN      VARCHAR2,
    pcoduser       IN      VARCHAR2,
    strresult      IN OUT  VARCHAR2,
    strmessaje     IN OUT  VARCHAR2
) IS

    v_result    VARCHAR2(1);
    v_messaje   VARCHAR2(1000);
    v_numintre  NUMBER;
    CURSOR cdocumentos_relacion (
        wpid_cia    NUMBER,
        wnumintori  NUMBER
    ) IS
    SELECT
        numintre
    FROM
        documentos_relacion
    WHERE
            id_cia = wpid_cia
        AND numint = wnumintori;

BEGIN
    v_result := 'S';
    v_messaje := '';
    FOR registro IN cdocumentos_relacion(pid_cia, pnumintori) LOOP
        IF ( v_result = 'S' ) THEN
            sp003_actualiza_situacion_documento_segun_saldo(pid_cia, registro.numintre, pswmuestramsj, pcoduser, v_result,
                                                            v_messaje);
            IF ( v_result IS NULL ) THEN
                v_result := 'N';
            END IF;
            IF (
                ( v_result = 'N' ) AND ( pswmuestramsj = 'S' )
            ) THEN
                v_messaje := v_messaje
                             || chr(13)
                             || ' No se actualizo el Num.Relacionado '
                             || to_char(registro.numintre);
            END IF;

        END IF;
    END LOOP;

    strresult := v_result;
    strmessaje := v_messaje;
END sp003a_actualiza_situacion_documento_relacionados;

/
