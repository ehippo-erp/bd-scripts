--------------------------------------------------------
--  DDL for Procedure SP000_VERIFICA_MES_CERRADO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_VERIFICA_MES_CERRADO" (
    pid_cia     IN      NUMBER,
    psistema    IN      NUMBER,
    pperiodo    IN      NUMBER,
    pmes        IN      NUMBER,
    strresult   IN OUT  VARCHAR2,
    strmessaje  IN OUT  VARCHAR2
) AS

    CURSOR cselect (
        wid_cia   NUMBER,
        wsistema  NUMBER,
        wperiodo  NUMBER,
        wmes      NUMBER
    ) IS
    SELECT
        COUNT(0) AS valor
    FROM
        cierre
    WHERE
            id_cia = wid_cia
        AND sistema = wsistema
        AND periodo = wperiodo
        AND mes = wmes
        AND cierre = 0;

BEGIN
    strresult := 'S';
    strmessaje := '';
    FOR registro IN cselect(pid_cia, psistema, pperiodo, pmes) LOOP
        IF ( registro.valor > 0 ) THEN
            strresult := 'N';
            strmessaje := '';
        ELSE
            strresult := 'S';
            strmessaje := '';
        END IF;
    END LOOP;

END sp000_verifica_mes_cerrado;

/
