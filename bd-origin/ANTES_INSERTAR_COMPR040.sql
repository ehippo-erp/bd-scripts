--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_COMPR040
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_COMPR040" BEFORE
    INSERT ON "USR_TSI_SUITE".compr040
    FOR EACH ROW
DECLARE
    v_conteo   NUMBER;
    v_periodo  NUMBER;
BEGIN
    sp000_verifica_mes_cerrado_compr040(:new.id_cia, :new.periodo, :new.mes, :new.situac, :new.situac);

    IF ( :new.situac <> 9 ) THEN
        v_periodo := ( extract(YEAR FROM :new.femisi) * 100 ) + extract(MONTH FROM :new.femisi);

        IF ( v_periodo > ( ( :new.periodo * 100 ) + :new.mes ) ) THEN
            RAISE pkg_exceptionuser.ex_fecha_no_valida;
        END IF;

    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_fecha_no_valida THEN
        raise_application_error(pkg_exceptionuser.fecha_no_valida, '  La fecha no es válida ');
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_COMPR040" ENABLE;
