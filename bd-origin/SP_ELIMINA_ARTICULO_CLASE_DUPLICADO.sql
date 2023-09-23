--------------------------------------------------------
--  DDL for Procedure SP_ELIMINA_ARTICULO_CLASE_DUPLICADO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ELIMINA_ARTICULO_CLASE_DUPLICADO" (
    pin_id_cia IN NUMBER
) AS
BEGIN
    FOR registro IN (
        SELECT
            ac1.tipinv,
            ac1.codart,
            ac1.clase,
            COUNT(ac1.clase)
        FROM
            articulos_clase ac1
        WHERE
            ac1.id_cia = pin_id_cia
        GROUP BY
            ac1.tipinv,
            ac1.codart,
            ac1.clase
        HAVING
            COUNT(ac1.clase) = 2
    ) LOOP
        DELETE FROM articulos_clase
        WHERE
                id_cia = pin_id_cia
            AND tipinv = registro.tipinv
            AND codart = registro.codart
            AND clase = registro.clase
            AND codigo = 'ND';

        COMMIT;
    END LOOP;
END sp_elimina_articulo_clase_duplicado;

/
