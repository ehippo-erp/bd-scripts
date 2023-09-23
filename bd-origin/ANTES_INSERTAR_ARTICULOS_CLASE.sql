--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_ARTICULOS_CLASE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_ARTICULOS_CLASE" BEFORE
    INSERT ON "USR_TSI_SUITE".articulos_clase
    FOR EACH ROW
DECLARE
    v_conteo INTEGER := 0;
    v_codigo VARCHAR(20);
BEGIN
    v_codigo := :new.codigo;
    IF nvl(v_codigo, 'ND') = 'ND' THEN
        BEGIN
            SELECT
                nvl(codigo, 'ND')
            INTO v_codigo
            FROM
                clase_codigo
            WHERE
                    id_cia = :new.id_cia
                AND tipinv = :new.tipinv
                AND clase = :new.clase
                AND swdefaul = 'S';

        EXCEPTION
            WHEN too_many_rows THEN
                v_codigo := 'ND';
            WHEN no_data_found THEN
                v_codigo := 'ND';
        END;

        :new.codigo := v_codigo;
    END IF;

END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_ARTICULOS_CLASE" ENABLE;
