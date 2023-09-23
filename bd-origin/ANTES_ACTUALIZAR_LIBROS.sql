--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_LIBROS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_LIBROS" BEFORE
    INSERT ON "USR_TSI_SUITE".libros
    FOR EACH ROW
BEGIN
    :new.factua := current_date;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_LIBROS" ENABLE;
