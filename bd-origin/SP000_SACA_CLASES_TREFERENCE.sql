--------------------------------------------------------
--  DDL for Function SP000_SACA_CLASES_TREFERENCE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_CLASES_TREFERENCE" (
    pid_cia IN NUMBER
) RETURN tbl_clases_treference
    PIPELINED
AS

    rclases_treference  rec_clases_treference := rec_clases_treference(NULL, NULL, NULL, NULL, NULL,
                      NULL);
    CURSOR cur_select IS
    SELECT
        clase
    FROM
        treference
    WHERE
            id_cia = pid_cia
        AND swacti = 'S'
    FETCH FIRST 6 ROW ONLY;

    v_clasetmp          NUMBER;
    v_tmp               NUMBER;
BEGIN
    rclases_treference.clase1 := NULL;
    rclases_treference.clase2 := NULL;
    rclases_treference.clase3 := NULL;
    rclases_treference.clase4 := NULL;
    rclases_treference.clase5 := NULL;
    rclases_treference.clase6 := NULL;
    v_tmp := 1;
    FOR registro IN cur_select LOOP
        IF ( v_tmp = 1 ) THEN
            rclases_treference.clase1 := registro.clase;
        END IF;

        IF ( v_tmp = 2 ) THEN
            rclases_treference.clase2 := registro.clase;
        END IF;

        IF ( v_tmp = 3 ) THEN
            rclases_treference.clase3 := registro.clase;
        END IF;

        IF ( v_tmp = 4 ) THEN
            rclases_treference.clase4 := registro.clase;
        END IF;

        IF ( v_tmp = 5 ) THEN
            rclases_treference.clase5 := registro.clase;
        END IF;

        IF ( v_tmp = 6 ) THEN
            rclases_treference.clase6 := registro.clase;
        END IF;

        v_tmp := v_tmp + 1;
    END LOOP;

    PIPE ROW ( rclases_treference );
END sp000_saca_clases_treference;

/
