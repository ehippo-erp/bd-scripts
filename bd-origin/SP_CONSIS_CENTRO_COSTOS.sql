--------------------------------------------------------
--  DDL for Function SP_CONSIS_CENTRO_COSTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_CONSIS_CENTRO_COSTOS" (
    pin_id_cia  IN NUMBER,
    pin_periodo IN NUMBER
) RETURN tbl_sp_consis_centro_costos
    PIPELINED
AS

    registro rec_sp_consis_centro_costos := rec_sp_consis_centro_costos(NULL, NULL, NULL, NULL, NULL,
                                                                       NULL, NULL);
    CURSOR cur_sp_consis_centro_costos IS
    SELECT
        m1.periodo,
        m1.mes,
        m1.libro,
        m1.asiento,
        m1.item,
        m1.cuenta AS cuentaenmovimiento,
        CASE
            WHEN ( p1.cuenta IS NULL ) THEN
                'N'
            ELSE
                'S'
        END       AS cuentaenpcuentas
    FROM
        movimientos m1
        LEFT OUTER JOIN pcuentas    p1 ON p1.id_cia = m1.id_cia and p1.cuenta = m1.cuenta
    WHERE
            m1.id_cia = pin_id_cia
        AND ( m1.periodo = pin_periodo )
        AND ( ( p1.cuenta IS NULL )
              OR ( length(p1.cuenta) <= 2 ) )
    ORDER BY
        m1.periodo,
        m1.mes,
        m1.libro,
        m1.asiento,
        m1.item;

BEGIN
    FOR j IN cur_sp_consis_centro_costos LOOP
        registro.periodo := j.periodo;
        registro.mes := j.mes;
        registro.libro := j.libro;
        registro.asiento := j.asiento;
        registro.item := j.item;
        registro.cuentaenmovimiento := j.cuentaenmovimiento;
        registro.cuentaenpcuentas := j.cuentaenpcuentas;
        PIPE ROW ( registro );
    END LOOP;
END sp_consis_centro_costos;

/
