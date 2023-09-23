--------------------------------------------------------
--  DDL for Function SP_SALDO_BANCARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_SALDO_BANCARIO" (
    pin_id_cia    IN   NUMBER,
    pin_periodo   IN   NUMBER,
    pin_mes       IN   NUMBER,
    pin_cuenta    IN   VARCHAR2
) RETURN tbl_saldo_bancario
    PIPELINED
AS

    r_saldo_bancario   rec_saldo_bancario := rec_saldo_bancario(NULL, NULL, NULL, NULL, NULL);
    v_saldo1           NUMERIC(16, 4) := 0;
    v_saldo2           NUMERIC(16, 4) := 0;
    v_saldomes         NUMERIC(16, 4) := 0;
BEGIN
    r_saldo_bancario.abonos_pendiente := 0;
    r_saldo_bancario.cargos_pendientes := 0;
    r_saldo_bancario.saldo_contable := 0;
    r_saldo_bancario.inicial_banco := 0;
    r_saldo_bancario.saldo_banco := 0;
    /*SACA CARGOS Y ABONOS PENDIENTES*/
    FOR registro IN (
        SELECT
            SUM(
                CASE
                    WHEN p.moneda01 = 'PEN' THEN
                        nvl(m.debe01, 0)
                    ELSE
                        nvl(m.debe02, 0)
                END
            ) AS abonos_pendiente,
            SUM(
                CASE
                    WHEN p.moneda01 = 'PEN' THEN
                        nvl(m.haber01, 0)
                    ELSE
                        nvl(m.haber02, 0)
                END
            ) AS cargos_pendientes
        FROM
            movimientos                m
            LEFT OUTER JOIN pcuentas                   p ON p.id_cia = m.id_cia
                                          AND p.cuenta = m.cuenta
            LEFT OUTER JOIN movimientos_conciliacion   c ON c.id_cia = m.id_cia
                                                          AND c.periodo = m.periodo
                                                          AND c.mes = m.mes
                                                          AND c.libro = m.libro
                                                          AND c.asiento = m.asiento
                                                          AND c.item = m.item
                                                          AND c.sitem = m.sitem
        WHERE
            m.id_cia = pin_id_cia
            AND c.periodocob = 0
            AND m.cuenta = pin_cuenta
    ) LOOP
        r_saldo_bancario.abonos_pendiente := registro.abonos_pendiente;
        r_saldo_bancario.cargos_pendientes := registro.cargos_pendientes;
    END LOOP;

    IF r_saldo_bancario.abonos_pendiente IS NULL THEN
        r_saldo_bancario.abonos_pendiente := 0;
    END IF;
    IF r_saldo_bancario.cargos_pendientes IS NULL THEN
        r_saldo_bancario.cargos_pendientes := 0;
    END IF;
    /*FIN CARGOS Y ABONOS PENDIENTES*/

    /*SACA SALDO BANCO*/
    BEGIN
        SELECT
            SUM(
                CASE
                    WHEN p.moneda01 = 'PEN' THEN
                        nvl(m.debe01, 0)
                    ELSE
                        nvl(m.debe02, 0)
                END
            ) - SUM(
                CASE
                    WHEN p.moneda01 = 'PEN' THEN
                        nvl(m.haber01, 0)
                    ELSE
                        nvl(m.haber02, 0)
                END
            ) AS saldo
        INTO v_saldo1
        FROM
            movimientos_conciliacion_a   m
            LEFT OUTER JOIN pcuentas                     p ON p.id_cia = m.id_cia
                                          AND p.cuenta = m.cuenta
        WHERE
            m.id_cia = pin_id_cia
            AND ( ( m.periodo = pin_periodo )
                  AND ( m.mes = 0 ) )
            AND ( m.cuenta = pin_cuenta );

    EXCEPTION
        WHEN no_data_found THEN
            v_saldo1 := 0;
    END;

    IF v_saldo1 IS NULL THEN
        v_saldo1 := 0;
    END IF;
    BEGIN
        SELECT
            SUM(
                CASE
                    WHEN p.moneda01 = 'PEN' THEN
                        nvl(m.debe01, 0)
                    ELSE
                        nvl(m.debe02, 0)
                END
            ) - SUM(
                CASE
                    WHEN p.moneda01 = 'PEN' THEN
                        nvl(m.haber01, 0)
                    ELSE
                        nvl(m.haber02, 0)
                END
            ) AS saldo
        INTO v_saldo2
        FROM
            movimientos                m
            LEFT OUTER JOIN pcuentas                   p ON p.id_cia = m.id_cia
                                          AND p.cuenta = m.cuenta
            LEFT OUTER JOIN movimientos_conciliacion   c ON c.id_cia = m.id_cia
                                                          AND c.periodo = m.periodo
                                                          AND c.mes = m.mes
                                                          AND c.libro = m.libro
                                                          AND c.asiento = m.asiento
                                                          AND c.item = m.item
                                                          AND c.sitem = m.sitem
        WHERE
            m.id_cia = pin_id_cia
            AND ( m.mes > 0 )
            AND ( ( c.mescob IS NULL )
                  OR ( c.mescob > 0 ) )
            AND ( ( ( ( m.periodo = pin_periodo )
                      AND ( m.mes > 0 )
                      AND ( m.mes < pin_mes ) )
                    AND ( ( ( ( c.periodocob * 100 ) + c.mescob ) IS NULL )
                          OR ( ( ( c.periodocob * 100 ) + c.mescob ) <= ( ( pin_periodo * 100 ) + pin_mes ) ) ) )
                  OR ( ( ( m.periodo * 100 ) + m.mes ) < ( ( pin_periodo * 100 ) + 0 ) )
                  AND ( ( c.periodocob = pin_periodo )
                        AND ( c.mescob > 0 )
                        AND ( c.mescob < pin_mes ) ) )
            AND m.cuenta = pin_cuenta;

    EXCEPTION
        WHEN no_data_found THEN
            v_saldo2 := 0;
    END;

    IF v_saldo2 IS NULL THEN
        v_saldo2 := 0;
    END IF;
    r_saldo_bancario.inicial_banco := nvl(v_saldo1,0) + nvl(v_saldo2,0);
    /*FIN SACA SALDO BANCO*/
    /*SACA SALDO CONTABLE*/
    BEGIN
        SELECT
            SUM(
                CASE
                    WHEN p.moneda01 = 'PEN' THEN
                        nvl(m.debe01, 0)
                    ELSE
                        nvl(m.debe02, 0)
                END
            ) - SUM(
                CASE
                    WHEN p.moneda01 = 'PEN' THEN
                        nvl(m.haber01, 0)
                    ELSE
                        nvl(m.haber02, 0)
                END
            ) AS saldo_contable
        INTO r_saldo_bancario.saldo_contable
        FROM
            movimientos   m
            LEFT OUTER JOIN pcuentas      p ON p.id_cia = m.id_cia
                                          AND p.cuenta = m.cuenta
        WHERE
            m.id_cia = pin_id_cia
            AND m.periodo = pin_periodo
            AND m.mes <= pin_mes 
            AND m.cuenta = pin_cuenta;

    EXCEPTION
        WHEN no_data_found THEN
            r_saldo_bancario.saldo_contable := 0;
    END;

    IF r_saldo_bancario.saldo_contable IS NULL THEN
        r_saldo_bancario.saldo_contable := 0;
    END IF;
   /*FIN SACA SALDO CONTABLE*/
   
    /*SACA SALDO DEL MES ACTUAL*/
    BEGIN
        SELECT
            SUM(
                CASE
                    WHEN p.moneda01 = 'PEN' THEN
                        nvl(m.debe01, 0)
                    ELSE
                        nvl(m.debe02, 0)
                END
            ) - SUM(
                CASE
                    WHEN p.moneda01 = 'PEN' THEN
                        nvl(m.haber01, 0)
                    ELSE
                        nvl(m.haber02, 0)
                END
            ) AS saldo_mes
        INTO v_saldomes
        FROM
            movimientos   m
            LEFT OUTER JOIN pcuentas      p ON p.id_cia = m.id_cia
                                          AND p.cuenta = m.cuenta
        WHERE
            m.id_cia = pin_id_cia
            AND m.periodo = pin_periodo
            AND m.mes = pin_mes 
            AND m.cuenta = pin_cuenta;

    EXCEPTION
        WHEN no_data_found THEN
            v_saldomes := 0;
    END;
      
      
    r_saldo_bancario.saldo_banco := nvl(r_saldo_bancario.inicial_banco,0) + nvl(v_saldomes,0);
    
    r_saldo_bancario.saldo_contable := nvl(r_saldo_bancario.inicial_banco,0) + nvl(v_saldomes,0)
     + (nvl(r_saldo_bancario.abonos_pendiente,0) - nvl(r_saldo_bancario.cargos_pendientes,0));
    
    PIPE ROW ( r_saldo_bancario );
    return;
END sp_saldo_bancario;

/
