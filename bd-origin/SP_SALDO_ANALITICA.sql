--------------------------------------------------------
--  DDL for Function SP_SALDO_ANALITICA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_SALDO_ANALITICA" (
    pin_id_cia  IN INTEGER,
    pin_periodo IN INTEGER,
    pin_mes     IN INTEGER,
    pin_codtana IN INTEGER,
    pin_cuenta  IN VARCHAR2,
    pin_codigo  IN VARCHAR2,
    pin_tdocum  IN VARCHAR2,
    pin_serie   IN VARCHAR2,
    pin_numero  IN VARCHAR2
) RETURN NUMERIC IS
    v_valor NUMERIC(16, 2) := 0;
BEGIN
    IF pin_codigo IS NULL OR pin_tdocum IS NULL OR pin_serie IS NULL OR pin_numero IS NULL THEN
        SELECT
            SUM((m1.debe01 - m1.haber01) +(
                CASE
                    WHEN(upper(pc.swflag) = 'S') THEN
                        m1.debe02 - m1.haber02
                    ELSE
                        0
                END
            ))
        INTO v_valor
        FROM
            saldos_tanalitica m1
            LEFT OUTER JOIN pcuentas_clase    pc ON pc.id_cia = m1.id_cia
                                                 AND pc.cuenta = m1.cuenta
                                                 AND pc.clase = 1
        WHERE
                m1.id_cia = pin_id_cia
            AND m1.periodo = pin_periodo
            AND m1.mes = pin_mes
            AND m1.codtana = pin_codtana
            AND m1.cuenta = pin_cuenta
            AND nvl(m1.codigo, 'XXXXXXXXXX') = nvl(pin_codigo, 'XXXXXXXXXX')
            AND nvl(m1.tdocum, 'XX') = nvl(pin_tdocum, 'XX')
            AND nvl(m1.serie, 'XXXXXXXXXXXXXXXXXXXX') = nvl(pin_serie, 'XXXXXXXXXXXXXXXXXXXX')
            AND nvl(m1.numero, 'XXXXXXXXXXXXXXXXXXXX') = nvl(pin_numero, 'XXXXXXXXXXXXXXXXXXXX');

    ELSE
        BEGIN
            SELECT
                SUM((m1.debe01 - m1.haber01) +(
                    CASE
                        WHEN(upper(pc.swflag) = 'S') THEN
                            m1.debe02 - m1.haber02
                        ELSE
                            0
                    END
                ))
            INTO v_valor
            FROM
                saldos_tanalitica m1
                LEFT OUTER JOIN pcuentas_clase    pc ON pc.id_cia = m1.id_cia
                                                     AND pc.cuenta = m1.cuenta
                                                     AND pc.clase = 1
            WHERE
                    m1.id_cia = pin_id_cia
                AND m1.periodo = pin_periodo
                AND m1.mes = pin_mes
                AND m1.codtana = pin_codtana
                AND m1.cuenta = pin_cuenta
                AND m1.codigo = pin_codigo
                AND m1.tdocum = pin_tdocum
                AND m1.serie = pin_serie
                AND m1.numero = pin_numero;

        EXCEPTION
            WHEN no_data_found THEN
                v_valor := 0;
        END;
    END IF;

    RETURN coalesce(v_valor, 0.0);
END sp_saldo_analitica;

/
