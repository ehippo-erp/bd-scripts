--------------------------------------------------------
--  DDL for Trigger ANTES_ELIMINAR_PROV100
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_PROV100" BEFORE
    DELETE ON "USR_TSI_SUITE".prov100
    FOR EACH ROW
DECLARE
    v_conteo INTEGER := 0;
BEGIN
    BEGIN
        SELECT
            COUNT(tipo)
        INTO v_conteo
        FROM
            prov101
        WHERE
                id_cia = :new.id_cia
            AND tipo = :old.tipo
            AND docu = :old.docu;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := 0;
    END;

    IF ( v_conteo > 0 ) THEN
        RAISE pkg_exceptionuser.ex_documento_tiene_pagos;
    END IF;
EXCEPTION
    WHEN pkg_exceptionuser.ex_documento_tiene_pagos THEN
        raise_application_error(pkg_exceptionuser.documento_tiene_pagos, 'El documento ya tiene pagos');
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_PROV100" ENABLE;
