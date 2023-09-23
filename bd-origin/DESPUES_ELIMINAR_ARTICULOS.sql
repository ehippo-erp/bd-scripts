--------------------------------------------------------
--  DDL for Trigger DESPUES_ELIMINAR_ARTICULOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_ARTICULOS" AFTER
    DELETE ON "USR_TSI_SUITE".articulos
    FOR EACH ROW
BEGIN
    DELETE FROM articulos_clase
    WHERE
            id_cia = :new.id_cia
        AND tipinv = :old.tipinv
        AND codart = :old.codart;

    DELETE FROM articulos_adjunto
    WHERE
            id_cia = :new.id_cia
        AND tipinv = :old.tipinv
        AND codart = :old.codart;

    DELETE FROM articulo_especificacion
    WHERE
            id_cia = :new.id_cia
        AND tipinv = :old.tipinv
        AND codart = :old.codart;

    DELETE FROM articulos_glosa
    WHERE
            id_cia = :new.id_cia
        AND tipinv = :old.tipinv
        AND codart = :old.codart;

    DELETE FROM articulos_imagen
    WHERE
            id_cia = :new.id_cia
        AND tipinv = :old.tipinv
        AND codart = :old.codart;

    DELETE FROM articulos_muebles
    WHERE
            id_cia = :new.id_cia
        AND tipinv = :old.tipinv
        AND codart = :old.codart;

    DELETE FROM listaprecios
    WHERE
            id_cia = :new.id_cia
        AND tipinv = :old.tipinv
        AND codart = :old.codart;

    DELETE FROM articulos_clase_alternativo
    WHERE
            id_cia = :new.id_cia
        AND tipinv = :old.tipinv
        AND codart = :old.codart;

    DELETE FROM articulos_combos
    WHERE
            id_cia = :new.id_cia
        AND tipinv = :old.tipinv
        AND codart = :old.codart;

    DELETE FROM articulos_clase_global
    WHERE
            id_cia = :new.id_cia
        AND tipinv = :old.tipinv
        AND codart = :old.codart;

END;
/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ELIMINAR_ARTICULOS" ENABLE;
