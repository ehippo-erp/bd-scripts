--------------------------------------------------------
--  DDL for Function SP000_GANANCIAS_PERDIDAS_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_GANANCIAS_PERDIDAS_001" (
    pin_id_cia  IN NUMBER,
    pin_periodo IN NUMBER,
    pin_meshas  IN NUMBER
) RETURN tbl_ganancias_perdidas_001
    PIPELINED
AS

    v_saldo  NUMERIC(16, 2) := 0;
    v_total1 NUMERIC(16, 2) := 0;
    v_cuenta VARCHAR(16) := '';
    registro rec_ganancias_perdidas_001 := rec_ganancias_perdidas_001(NULL, NULL, NULL, NULL, NULL);
    CURSOR cur_ganaperdihea IS
    SELECT
        h.codigo,
        h.titulo,
        h.tipo,
        h.signo
    FROM
        ganaperdihea h
    WHERE
        h.id_cia = pin_id_cia
    ORDER BY
        h.codigo;

    CURSOR cur_ganaperdidet (
        pcodigo SMALLINT
    ) IS
    SELECT
        d.cuenta
    FROM
        ganaperdidet d
    WHERE
            d.id_cia = pin_id_cia
        AND d.codigo = pcodigo
    ORDER BY
        cuenta;

BEGIN
/*
 Ejemplo de Uso

  Select * From SP000_Ganancias_Perdidas_001(2011,03);

 */

    FOR rec_hea IN cur_ganaperdihea LOOP
        registro.codigo := rec_hea.codigo;
        registro.titulo := rec_hea.titulo;
        registro.tipo := rec_hea.tipo;
        registro.signo := rec_hea.signo;
        registro.saldo := 0;
        FOR rec_cuenta IN cur_ganaperdidet(registro.codigo) LOOP
            v_cuenta := rec_cuenta.cuenta;
            BEGIN
                SELECT
                    SUM(
                        CASE
                            WHEN m.dh = 'H' THEN
                                m.haber01
                            ELSE
                                0
                        END
                    ) - SUM(
                        CASE
                            WHEN m.dh = 'D' THEN
                                m.debe01
                            ELSE
                                0
                        END
                    ) AS saldo
                INTO v_saldo
                FROM
                    movimientos m
                WHERE
                        m.id_cia = pin_id_cia
                    AND m.periodo = periodo
                    AND m.mes <= pin_meshas
                    AND m.cuenta = v_cuenta;

            EXCEPTION
                WHEN no_data_found THEN
                    v_saldo := NULL;
            END;

            IF ( v_saldo IS NULL ) THEN
                v_saldo := 0;
            END IF;
            registro.saldo := registro.saldo + v_saldo;
        END LOOP;

        v_total1 := v_total1 + registro.saldo;
        IF ( upper(registro.tipo) = 'D' ) THEN
            registro.titulo := '   ' || registro.titulo;
        END IF;

        IF ( upper(registro.tipo) = 'T' ) THEN
            registro.saldo := v_total1;
        END IF;

        PIPE ROW ( registro );
        IF ( upper(registro.tipo) = 'T' ) THEN
            registro.codigo := NULL;
            registro.titulo := '';
            registro.tipo := '';
            registro.saldo := NULL;
            PIPE ROW ( registro );
        END IF;

    END LOOP;
END sp000_ganancias_perdidas_001;


/
