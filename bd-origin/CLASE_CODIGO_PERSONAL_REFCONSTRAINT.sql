--------------------------------------------------------
--  Ref Constraints for Table CLASE_CODIGO_PERSONAL
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."CLASE_CODIGO_PERSONAL" ADD CONSTRAINT "FK_CLASE_PERSONAL" FOREIGN KEY ("ID_CIA", "CLASE")
	  REFERENCES "USR_TSI_SUITE"."CLASE_PERSONAL" ("ID_CIA", "CLASE") ENABLE;
