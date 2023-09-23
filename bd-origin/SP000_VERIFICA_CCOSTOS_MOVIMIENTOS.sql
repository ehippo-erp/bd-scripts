--------------------------------------------------------
--  DDL for Function SP000_VERIFICA_CCOSTOS_MOVIMIENTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_VERIFICA_CCOSTOS_MOVIMIENTOS" (
    pin_id_cia  IN NUMBER,
    pin_periodo IN NUMBER
) RETURN tbl_sp000_verifica_ccostos_movimientos
    PIPELINED
AS

    wconteo  NUMBER := 0;
    registro rec_sp000_verifica_ccostos_movimientos := rec_sp000_verifica_ccostos_movimientos(NULL, NULL, NULL, NULL, NULL,
                                                                                             NULL, NULL);
    CURSOR cursor_sp IS
    SELECT
        m1.periodo,
        m1.mes,
        m1.libro,
        m1.asiento,
        m1.item,
        m1.cuenta AS cuentaenmovimiento,
        m1.ccosto AS ccostoenmovimiento
    FROM
        movimientos m1
    WHERE
        ( m1.id_cia = pin_id_cia )
        AND ( m1.periodo = pin_periodo )
        AND ( substr(m1.cuenta, 1, 2) IN ( '62', '63', '64',
                                           '65', '66', '67', '68' ) )
        AND ( m1.ccosto IS NOT NULL )
        AND ( length(m1.ccosto) > 2 )
    ORDER BY
        m1.periodo,
        m1.mes,
        m1.libro,
        m1.asiento,
        m1.item;

BEGIN
    FOR rec IN cursor_sp LOOP
        registro.periodo := rec.periodo;
        registro.mes := rec.mes;
        registro.libro := rec.libro;
        registro.asiento := rec.asiento;
        registro.item := rec.item;
        registro.cuentamovi := rec.cuentaenmovimiento;
        registro.ccostomovi := rec.ccostoenmovimiento;
        PIPE ROW ( registro );
        SELECT
            COUNT(0)
        INTO wconteo
        FROM
            movimientos m2
        WHERE
                m2.id_cia = pin_id_cia
            AND m2.periodo = registro.periodo
            AND m2.mes = registro.mes
            AND m2.libro = registro.libro
            AND m2.asiento = registro.asiento
            AND m2.item = registro.item
            AND m2.sitem > 0
            AND m2.cuenta = registro.ccostomovi;

        IF ( wconteo = 0 ) THEN
            RETURN;
        END IF;
    END LOOP;
END sp000_verifica_ccostos_movimientos;

/
