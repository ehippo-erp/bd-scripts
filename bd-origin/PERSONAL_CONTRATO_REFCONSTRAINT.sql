--------------------------------------------------------
--  Ref Constraints for Table PERSONAL_CONTRATO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_CONTRATO" ADD CONSTRAINT "FK_PERSONAL_CONTRATO_PERSONAL" FOREIGN KEY ("ID_CIA", "CODPER")
	  REFERENCES "USR_TSI_SUITE"."PERSONAL" ("ID_CIA", "CODPER") ENABLE;
