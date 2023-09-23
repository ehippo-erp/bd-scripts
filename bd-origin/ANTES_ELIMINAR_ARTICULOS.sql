--------------------------------------------------------
--  DDL for Trigger ANTES_ELIMINAR_ARTICULOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_ARTICULOS" BEFORE
    DELETE ON "USR_TSI_SUITE"."ARTICULOS"
    FOR EACH ROW
BEGIN
    DELETE FROM articulos_clase
    WHERE
            id_cia = :old.id_cia
        AND tipinv = :old.tipinv
        AND codart = :old.codart;

    DELETE FROM articulo_especificacion
    WHERE
            id_cia = :old.id_cia
        AND tipinv = :old.tipinv
        AND codart = :old.codart;

END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_ARTICULOS" ENABLE;
