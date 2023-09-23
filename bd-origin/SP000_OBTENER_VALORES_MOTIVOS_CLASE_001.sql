--------------------------------------------------------
--  DDL for Procedure SP000_OBTENER_VALORES_MOTIVOS_CLASE_001
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_OBTENER_VALORES_MOTIVOS_CLASE_001" (
    pid_cia  IN   NUMBER,
    ptipdoc  IN   NUMBER,
    pid      IN   VARCHAR2,
    pcodmot  IN   NUMBER,
    pcodigo  IN   NUMBER,
    pdescri  OUT  VARCHAR2,
    pvalor   OUT  VARCHAR2
) IS
    wconteo NUMBER;
BEGIN
    SELECT
        descri,
        valor
    INTO
        pdescri,
        pvalor
    FROM
        motivos_clase
    WHERE
        ( id_cia = pid_cia )
        AND ( tipdoc = ptipdoc )
        AND ( id = pid )
        AND ( codmot = pcodmot )
        AND ( codigo = pcodigo );

EXCEPTION
    WHEN no_data_found THEN
        pdescri := '';
        pvalor := '';
END sp000_obtener_valores_motivos_clase_001;

/
