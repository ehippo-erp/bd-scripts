--------------------------------------------------------
--  Ref Constraints for Table ACCESOS
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."ACCESOS" ADD CONSTRAINT "FK_ACCESOS_MODULOS" FOREIGN KEY ("CODMOD")
	  REFERENCES "USR_TSI_SUITE"."MODULOS" ("CODMOD") ENABLE;
