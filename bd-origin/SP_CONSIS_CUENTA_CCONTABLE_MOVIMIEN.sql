--------------------------------------------------------
--  DDL for Function SP_CONSIS_CUENTA_CCONTABLE_MOVIMIEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_CONSIS_CUENTA_CCONTABLE_MOVIMIEN" (
    pin_id_cia IN NUMBER
) RETURN tbl_rec_sp_consis_cuenta_ccontable_movimien
    PIPELINED
AS

    registro rec_sp_consis_cuenta_ccontable_movimien := rec_sp_consis_cuenta_ccontable_movimien(NULL, NULL, NULL, NULL);
    CURSOR cur_sp_consis_cuenta_ccontable_movimien IS
    SELECT
        t1.codigo AS centrodecosto,
        t1.destin AS destino,
        CASE
            WHEN ( p1.cuenta IS NULL ) THEN
                'N'
            ELSE
                'S'
        END       AS ccostoenpcuentas,
        CASE
            WHEN ( p2.cuenta IS NULL ) THEN
                'N'
            ELSE
                'S'
        END       AS destinoenpcuentas
    FROM
        tccostos t1
        LEFT OUTER JOIN pcuentas p1 ON p1.id_cia = t1.id_cia and   p1.cuenta = t1.codigo
        LEFT OUTER JOIN pcuentas p2 ON p2.id_cia = t1.id_cia and  p2.cuenta = t1.destin
    WHERE
            t1.id_cia = pin_id_cia
        AND ( ( p1.cuenta IS NULL )
              OR ( length(p1.cuenta) <= 2 ) )
        OR ( ( p2.cuenta IS NULL )
             OR ( length(p2.cuenta) <= 2 ) )
    ORDER BY
        t1.codigo;

BEGIN
    FOR j IN cur_sp_consis_cuenta_ccontable_movimien LOOP
        registro.centrodecosto := j.centrodecosto;
        registro.destino := j.destino;
        registro.ccostoenpcuentas := j.ccostoenpcuentas;
        registro.destinoenpcuentas := j.destinoenpcuentas;
        PIPE ROW ( registro );
    END LOOP;
END sp_consis_cuenta_ccontable_movimien;

/
