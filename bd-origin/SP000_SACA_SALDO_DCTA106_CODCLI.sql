--------------------------------------------------------
--  DDL for Function SP000_SACA_SALDO_DCTA106_CODCLI
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_SALDO_DCTA106_CODCLI" (
    pin_id_cia IN NUMBER,
    pin_codcli IN VARCHAR2
) RETURN tbl_sp000_saca_saldo_dcta106_codcli
    PIPELINED
AS

    v_limportemn NUMERIC(16, 2);
    v_limporteme NUMERIC(16, 2);
    v_tipmon     VARCHAR2(3);
    rec          rec_sp000_saca_saldo_dcta106_codcli := rec_sp000_saca_saldo_dcta106_codcli(NULL, NULL, NULL);
BEGIN
    FOR i IN (
        SELECT
            d.numint,
            SUM(d.importemn *
                CASE
                    WHEN upper(d.id) = 'S' THEN
                        - 1
                    ELSE
                        1
                END
            ) AS limportemn,
            SUM(d.importeme *
                CASE
                    WHEN upper(d.id) = 'S' THEN
                        - 1
                    ELSE
                        1
                END
            ) AS limporteme
        FROM
            dcta106 d
        WHERE
                d.id_cia = pin_id_cia
            AND d.codcli = pin_codcli
        GROUP BY
            d.numint
    ) LOOP
        rec.numint := i.numint;
        v_limportemn := i.limportemn;
        v_limporteme := i.limporteme;
        BEGIN
            SELECT
                tipmon
            INTO v_tipmon
            FROM
                dcta106
            WHERE
                    id_cia = pin_id_cia
                AND numint = i.numint
                AND item = 0
                AND id = 'I';

            rec.tipmon := v_tipmon;
            IF ( rec.tipmon = 'PEN' ) THEN
                rec.saldo := v_limportemn;
            ELSE
                rec.saldo := v_limporteme;
            END IF;

            PIPE ROW ( rec );
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

    END LOOP;
END sp000_saca_saldo_dcta106_codcli;

/
