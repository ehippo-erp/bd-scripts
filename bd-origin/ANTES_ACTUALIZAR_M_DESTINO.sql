--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_M_DESTINO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_M_DESTINO" BEFORE
    UPDATE ON "USR_TSI_SUITE".m_destino
    FOR EACH ROW
BEGIN
    :new.factua := current_date;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_M_DESTINO" ENABLE;
