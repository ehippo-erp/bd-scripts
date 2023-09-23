--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_PROV100
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_PROV100" BEFORE
    UPDATE ON "USR_TSI_SUITE".prov100
    FOR EACH ROW
DECLARE
    v_conteo NUMBER;
BEGIN
-- 2014-06-10 - revizado y cambiado por CARLOS en reunion urgente - por problemas en BOYTON 


    DBMS_OUTPUT.PUT_LINE(:new.codban);
    DBMS_OUTPUT.PUT_LINE(':new.codban');

    IF ( :new.codban IS NOT NULL ) THEN
        :new.codban := 0;
    END IF;
-- para Anular 

    IF ( :new.situac = '9' ) THEN
        BEGIN
            SELECT
                COUNT(tipo)
            INTO v_conteo
            FROM
                prov101
            WHERE
                    id_cia = :old.id_cia
                AND tipo = :old.tipo
                AND docu = :old.docu;

        EXCEPTION
            WHEN no_data_found THEN
                v_conteo := 0;
        END;

        IF ( v_conteo > 0 ) THEN
            RAISE pkg_exceptionuser.ex_documento_tiene_pagos;
        END IF;
    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_documento_tiene_pagos THEN
        raise_application_error(pkg_exceptionuser.documento_tiene_pagos, 'El documento ya tiene pagos');
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_PROV100" ENABLE;
