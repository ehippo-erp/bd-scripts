--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_M_DESTINO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_M_DESTINO" BEFORE
    INSERT ON "USR_TSI_SUITE".m_destino
    FOR EACH ROW
BEGIN
    :new.fcreac := current_date;
    :new.factua := current_date;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_M_DESTINO" ENABLE;
