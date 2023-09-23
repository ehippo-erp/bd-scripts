--------------------------------------------------------
--  Ref Constraints for Table PERSONAL_CONCEPTO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_CONCEPTO" ADD CONSTRAINT "FK_PERSONAL_CONCEPTO_PERSONAL" FOREIGN KEY ("ID_CIA", "CODPER")
	  REFERENCES "USR_TSI_SUITE"."PERSONAL" ("ID_CIA", "CODPER") ENABLE;
