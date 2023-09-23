--------------------------------------------------------
--  DDL for Function SP00_SEL_CUENTAS_CENTRO_COSTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP00_SEL_CUENTAS_CENTRO_COSTO" (
    pin_id_cia NUMBER
) RETURN tbl_cuentas_centro_costo
    PIPELINED
AS

    v_cuentas_centro_costo rec_cuentas_centro_costo := rec_cuentas_centro_costo(NULL, NULL, NULL, NULL);
    CURSOR cur_select IS
    SELECT DISTINCT
        p.cuenta    AS codigo,
        p.nombre    AS descri,
        c.destin,
        c.swacti
    FROM
             pcuentas p
        INNER JOIN tccostos c ON c.id_cia = pin_id_cia
                                 AND c.codigo LIKE p.cuenta || '%'
    ORDER BY
        p.cuenta;

BEGIN
    FOR registro IN cur_select LOOP
        v_cuentas_centro_costo.codigo := registro.codigo;
        v_cuentas_centro_costo.descri := registro.descri;
        v_cuentas_centro_costo.destin := registro.destin;
        v_cuentas_centro_costo.swacti := registro.swacti;
        PIPE ROW ( v_cuentas_centro_costo );
    END LOOP;
END sp00_sel_cuentas_centro_costo;

/
