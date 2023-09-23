--------------------------------------------------------
--  DDL for Trigger DESPUES_ACTUALIZAR_ARTICULOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ACTUALIZAR_ARTICULOS" AFTER
    UPDATE ON "USR_TSI_SUITE".articulos
    FOR EACH ROW
DECLARE
    v_conteo INTEGER;
BEGIN
/* INSERTA LAS CLASES OBLIGATORIAS */
    INSERT INTO articulos_clase (
        id_cia,
        tipinv,
        codart,
        clase,
        codigo,
        situac
    )
        SELECT
            :new.id_cia,
            c.tipinv,
            :new.codart,
            c.clase,
            'ND',
            'S'
        FROM
            clase c
        WHERE
                c.id_cia = :new.id_cia
            AND c.tipinv = :new.tipinv
            AND upper(c.obliga) = 'S'
            AND NOT ( EXISTS (
                SELECT
                    a2.clase
                FROM
                    articulos_clase a2
                WHERE
                        a2.id_cia = :new.id_cia
                    AND a2.tipinv = c.tipinv
                    AND a2.codart = :new.codart
                    AND a2.clase = c.clase
            ) );

    INSERT INTO articulos_clase_global (
        id_cia,
        tipinv,
        codart,
        clase,
        codigo,
        situac
    )
        SELECT
            :new.id_cia,
            :new.tipinv,
            :new.codart,
            c.clase,
            'ND',
            c.situac
        FROM
            clase_global c
        WHERE
                id_cia = :new.id_cia
            AND upper(c.obliga) = 'S'
            AND NOT ( EXISTS (
                SELECT
                    a2.clase
                FROM
                    articulos_clase_global a2
                WHERE
                        a2.id_cia = :new.id_cia
                    AND a2.tipinv = :new.tipinv
                    AND a2.codart = :new.codart
                    AND a2.clase = c.clase
            ) );

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ACTUALIZAR_ARTICULOS" ENABLE;
