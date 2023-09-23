--------------------------------------------------------
--  DDL for Trigger DESPUES_INSERTAR_DCTA100
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_INSERTAR_DCTA100" AFTER
    INSERT ON "USR_TSI_SUITE".dcta100
    FOR EACH ROW
BEGIN
  /*2015-06-19 ESTA TABLA GUARDAR ESTOS DATOS QUE SERVIRAN COMO RESPALDO
  PARA DATA QUE PASO POR MIGRACION Y LOS QUE NACEN CON ALGUNOS DATOS ADICIONALES*/
    INSERT INTO dcta100_ori (
        id_cia,
        numint,
        operac,
        codban,
        numbco,
        protes
    ) VALUES (
        :new.id_cia,
        :new.numint,
        :new.operac,
        :new.codban,
        :new.numbco,
        :new.protes
    );

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_INSERTAR_DCTA100" ENABLE;
