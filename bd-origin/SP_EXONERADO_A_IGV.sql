--------------------------------------------------------
--  DDL for Function SP_EXONERADO_A_IGV
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_EXONERADO_A_IGV" (
    pid_cia  NUMBER,
    ptipcli  VARCHAR2,
    pcodcli  VARCHAR2,
    pnumint  NUMBER
) RETURN VARCHAR2 IS
    wvclie  cliente_clase.codigo%TYPE;
    wvmoti  motivos_clase.valor%TYPE;
    valor   VARCHAR2(1);
BEGIN
    BEGIN
        SELECT
            codigo
        INTO wvclie
        FROM
            cliente_clase
        WHERE
                id_cia = pid_cia
            AND tipcli = ptipcli
            AND codcli = pcodcli
            AND clase = 22;

    EXCEPTION
        WHEN no_data_found THEN
            wvclie := 'N';
    END;

    BEGIN
        SELECT
            m.valor
        INTO wvmoti
        FROM
            documentos_cab  d
            LEFT OUTER JOIN motivos_clase   m ON m.id_cia = d.id_cia
                                               AND m.tipdoc = d.tipdoc
                                               AND m.id = d.id
                                               AND m.codmot = d.codmot
                                               AND m.codigo = 21
        WHERE
                d.id_cia = pid_cia
            AND d.numint = pnumint;

    EXCEPTION
        WHEN no_data_found THEN
            wvmoti := 'N';
    END;

    IF ( ( upper(wvclie) = 'S' ) OR ( upper(wvmoti) = 'S' ) ) THEN
        valor := 'S';
    ELSE
        valor := 'N';
    END IF;
    RETURN valor;
END sp_exonerado_a_igv;

/
