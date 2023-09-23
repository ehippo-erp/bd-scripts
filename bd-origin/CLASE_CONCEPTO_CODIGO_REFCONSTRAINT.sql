--------------------------------------------------------
--  Ref Constraints for Table CLASE_CONCEPTO_CODIGO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."CLASE_CONCEPTO_CODIGO" ADD CONSTRAINT "FK_CLASE_CONCEPTO_CLASE_CONCEPTO_CODIGO" FOREIGN KEY ("ID_CIA", "CLASE")
	  REFERENCES "USR_TSI_SUITE"."CLASE_CONCEPTO" ("ID_CIA", "CLASE") ENABLE;
