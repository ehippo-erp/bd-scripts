--------------------------------------------------------
--  DDL for Function SP_LIBDIARIORESUMIDO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_LIBDIARIORESUMIDO" (
    pin_id_cia   IN  NUMBER,
    pin_periodo  IN  NUMBER,
    pin_mes      IN  NUMBER,
    pin_libro    VARCHAR2
) RETURN tbl_sp_libdiarioresumido
    PIPELINED
AS

    rec rec_sp_libdiarioresumido := rec_sp_libdiarioresumido(NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL);
BEGIN
    FOR i IN (
        SELECT
            CAST(substr(m.cuenta, 1, 2) AS VARCHAR(2)) AS ncuenta,
            m.periodo,
            m.mes,
            m.libro,
            m.cuenta,
            pc.nombre,
            m.dh,
            m.debe01,
            m.haber01,
            m.debe02,
            m.haber02,
            m.asiento,
            m.concep,
            m.ccosto,
            m.subcco,
            m.codigo,
            m.serie,
            m.tdocum,
            m.numero,
            m.fdocum,
            (
                SELECT
                    pcc.nombre
                FROM
                    pcuentas pcc
                WHERE
                        pcc.id_cia = m.id_cia
                    AND pcc.cuenta = CAST(substr(m.cuenta, 1, 2) AS VARCHAR(2))
            ) AS cuepad
        FROM
            movimientos  m,
            pcuentas     pc
        WHERE
                m.id_cia = pin_id_cia
            AND pc.id_cia = pin_id_cia
            AND m.periodo = pin_periodo
            AND m.mes = pin_mes
            AND m.libro = pin_libro
            AND pc.cuenta = m.cuenta
        ORDER BY
            ncuenta,
            m.cuenta,
            m.periodo,
            m.mes,
            m.libro,
            m.tdocum,
            m.serie,
            m.numero
    ) LOOP
        rec.ncuenta := i.ncuenta;
        rec.periodo := i.periodo;
        rec.mes := i.mes;
        rec.libro := i.libro;
        rec.cuenta := i.cuenta;
        rec.nombre := i.nombre;
        rec.dh := i.dh;
        rec.debe01 := i.debe01;
        rec.haber01 := i.haber01;
        rec.debe02 := i.debe02;
        rec.haber02 := i.haber02;
        rec.asiento := i.asiento;
        rec.concep := i.concep;
        rec.ccosto := i.ccosto;
        rec.subcco := i.subcco;
        rec.codigo := i.codigo;
        rec.serie := i.serie;
        rec.tdocum := i.tdocum;
        rec.numero := i.numero;
        rec.fdocum := i.fdocum;
        rec.cuepad := i.cuepad;
        PIPE ROW ( rec );
    END LOOP;
END sp_libdiarioresumido;

/
