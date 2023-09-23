--------------------------------------------------------
--  Ref Constraints for Table CONCEPTO_CLASE
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."CONCEPTO_CLASE" ADD CONSTRAINT "FK_CONCEPTO_CLASE_CLASE_CONCEPTO_CODIGO" FOREIGN KEY ("ID_CIA", "CLASE", "CODIGO")
	  REFERENCES "USR_TSI_SUITE"."CLASE_CONCEPTO_CODIGO" ("ID_CIA", "CLASE", "CODIGO") ENABLE;
