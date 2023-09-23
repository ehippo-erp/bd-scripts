--------------------------------------------------------
--  DDL for Function SP000_SACA_SALDO_DCTA106
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_SALDO_DCTA106" (
    pin_id_cia  NUMBER,
    pin_numint  NUMBER
) RETURN tbl_saldo_dcta106
    PIPELINED
AS

    r_saldo_dcta106  rec_saldo_dcta106 := rec_saldo_dcta106(NULL, NULL, NULL);
    v_limportemn             NUMERIC(16, 2) := 0;
    v_limporteme             NUMERIC(16, 2) := 0;
    v_saldo                  NUMERIC(16, 4) := 0;
    v_tipmon                 VARCHAR(3) := '';
    CURSOR cur_select IS
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
        AND ( ( d.numint = pin_numint )
              OR ( pin_numint <= 0 ) )
    GROUP BY
        d.numint;

BEGIN
    FOR registro IN cur_select LOOP
        v_limportemn := nvl(registro.limportemn, 0);
        v_limporteme := nvl(registro.limporteme, 0);
        BEGIN
            SELECT
                tipmon
            INTO v_tipmon
            FROM
                dcta106
            WHERE
                    id_cia = pin_id_cia
                AND numint = registro.numint
                AND item = 0
                AND id = 'I';

        EXCEPTION
            WHEN no_data_found THEN
                v_tipmon := 'PEN';
        END;

        IF ( v_tipmon = 'PEN' ) THEN
            v_saldo := v_limportemn;
        ELSE
            v_saldo := v_limporteme;
        END IF;

        r_saldo_dcta106.numint := registro.numint;
        r_saldo_dcta106.tipmon := v_tipmon;
        r_saldo_dcta106.saldo := v_saldo;
        PIPE ROW ( r_saldo_dcta106 );
    END LOOP;
END sp000_saca_saldo_dcta106;

/
