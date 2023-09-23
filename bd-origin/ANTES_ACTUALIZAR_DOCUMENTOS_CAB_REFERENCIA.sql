--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_DOCUMENTOS_CAB_REFERENCIA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_DOCUMENTOS_CAB_REFERENCIA" BEFORE
    UPDATE ON "USR_TSI_SUITE".documentos_cab_referencia
    FOR EACH ROW
BEGIN
    IF ( ( :new.femisi IS NULL ) OR ( :new.femisi <= TO_DATE('01/01/1995', 'DD/MM/YYYY') ) ) THEN
        RAISE pkg_exceptionuser.ex_fecha_no_valida;
    END IF;
EXCEPTION
    WHEN pkg_exceptionuser.ex_fecha_no_valida THEN
        raise_application_error(pkg_exceptionuser.fecha_no_valida, ' La fecha no es válida');
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_DOCUMENTOS_CAB_REFERENCIA" ENABLE;
