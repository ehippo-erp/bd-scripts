--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_PLANILLA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_PLANILLA" BEFORE
    INSERT ON "USR_TSI_SUITE"."PLANILLA"
    FOR EACH ROW
DECLARE
    v_conteo NUMBER;
BEGIN
    sp000_verifica_mes_cerrado_hr_planilla(:new.id_cia, :new.anopla, :new.mespla, '', '');

    :new.fcreac := current_date;
    :new.factua := current_date;

--EXCEPTION
--    WHEN pkg_exceptionuser.ex_numero_repetido_doccab THEN
--        raise_application_error(pkg_exceptionuser.numero_repetido_doccab, 'Número repetido en la cabecera del documento - '
--                                                                          || :new.tipdoc
--                                                                          || '-'
--                                                                          || :new.series
--                                                                          || '-'
--                                                                          || :new.numdoc);
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_PLANILLA" DISABLE;
