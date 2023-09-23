--------------------------------------------------------
--  DDL for Function SP000_COMAS_EN_FILAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_COMAS_EN_FILAS" (
    inputstr IN VARCHAR2
) RETURN tbl_comas_en_filas
    PIPELINED
IS
    rcomas_en_filas  rec_comas_en_filas := rec_comas_en_filas(NULL, NULL);
    v_winput         VARCHAR2(500);
    v_posi           NUMBER;
BEGIN
    v_winput := inputstr;
    BEGIN
        SELECT
            instr(v_winput, ',')
        INTO v_posi
        FROM
            dual;

    EXCEPTION
        WHEN no_data_found THEN
            v_posi := NULL;
    END;

    rcomas_en_filas.orden := 0;
    IF ( ( v_posi IS NULL ) OR ( v_posi = 0 ) ) THEN
        rcomas_en_filas.campo := to_number(substr(v_winput, 1, length(v_winput)), '999');

        rcomas_en_filas.orden := rcomas_en_filas.orden + 1;
        PIPE ROW ( rcomas_en_filas );
    ELSE
        WHILE ( v_posi > 0 ) LOOP
            BEGIN
                SELECT
                    instr(v_winput, ',')
                INTO v_posi
                FROM
                    dual;

            EXCEPTION
                WHEN no_data_found THEN
                    v_posi := NULL;
            END;

            IF ( ( v_posi IS NULL ) OR ( v_posi = 0 ) ) THEN
                rcomas_en_filas.campo := to_number(substr(v_winput, 1, length(v_winput)), '999');

            ELSE
                rcomas_en_filas.campo := to_number(substr(v_winput, 1, v_posi - 1), '999');
            END IF;

            v_winput := substr(v_winput, v_posi + 1, length(v_winput));
            rcomas_en_filas.orden := rcomas_en_filas.orden + 1;
            PIPE ROW ( rcomas_en_filas );
        END LOOP;
    END IF;

END sp000_comas_en_filas;

/
