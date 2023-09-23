--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_ARTICULOS_ALMACEN_CODADD
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_ARTICULOS_ALMACEN_CODADD" BEFORE
    UPDATE ON "USR_TSI_SUITE".ARTICULOS_ALMACEN_CODADD
    FOR EACH ROW
BEGIN
    IF ( :new.ingreso IS NULL ) THEN
        :new.ingreso := 0;
    END IF;

    IF ( :new.salida IS NULL ) THEN
        :new.salida := 0;
    END IF;

    IF ( :new.cosing01 IS NULL ) THEN
        :new.cosing01 := 0;
    END IF;

    IF ( :new.cosing02 IS NULL ) THEN
        :new.cosing02 := 0;
    END IF;

    IF ( :new.cossal01 IS NULL ) THEN
        :new.cossal01 := 0;
    END IF;

    IF ( :new.cossal02 IS NULL ) THEN
        :new.cossal02 := 0;
    END IF;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_ARTICULOS_ALMACEN_CODADD" ENABLE;
