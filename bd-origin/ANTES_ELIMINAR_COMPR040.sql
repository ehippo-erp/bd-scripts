--------------------------------------------------------
--  DDL for Trigger ANTES_ELIMINAR_COMPR040
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_COMPR040" BEFORE
    DELETE ON "USR_TSI_SUITE".compr040
    FOR EACH ROW
DECLARE
    v_conteo    NUMBER;
    v_conteo20  NUMBER;
BEGIN
    sp000_verifica_mes_cerrado_compr040(:old.id_cia, :old.periodo, :old.mes, :old.situac, :old.situac);
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_COMPR040" ENABLE;
