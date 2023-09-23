--------------------------------------------------------
--  DDL for Procedure SP000_TIENE_CREDITO_CERRADO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_TIENE_CREDITO_CERRADO" (
    pid_cia        IN   NUMBER,
    ptipcli        IN   VARCHAR2,
    pcodcli        IN   VARCHAR2,
    pswmuestramsj  IN   VARCHAR2,
    pswresultado   OUT  VARCHAR2,
    pmessage       OUT  VARCHAR2
) IS
    wxcodcli  cliente.codcli%TYPE;
    wxrazonc  cliente.razonc%TYPE;
BEGIN
    pswresultado := 'N';
    pmessage := '';
    BEGIN
        SELECT
            c.codcli,
            c.razonc
        INTO
            wxcodcli,
            wxrazonc
        FROM
            cliente        c
            LEFT OUTER JOIN cliente_clase  cc ON cc.id_cia = cc.id_cia
                                                AND cc.tipcli =C.tipcli
                                                AND cc.codcli = c.codcli
                                                AND cc.clase = 26
        WHERE
                c.id_cia = pid_cia
            AND c.codcli = pcodcli
            AND c.codpag = 0
            AND ( ( cc.codigo IS NULL )
                  OR ( upper(cc.codigo) <> 'N' ) );

    EXCEPTION
        WHEN no_data_found THEN
            wxcodcli := '';
            wxrazonc := '';
    END;

    IF ( wxcodcli IS NOT NULL ) THEN
        pswresultado := 'S';
        IF ( upper(pswmuestramsj) = 'S' ) THEN
            pmessage := 'El Cliente '
                        || wxcodcli
                        || '-'
                        || wxrazonc
                        || ' Tiene Credito Cerrado - Verificar ';
        END IF;

    END IF;

END sp000_tiene_credito_cerrado;


/
