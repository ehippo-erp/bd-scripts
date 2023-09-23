--------------------------------------------------------
--  Ref Constraints for Table PERSONAL_DEPENDIENTE
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DEPENDIENTE" ADD CONSTRAINT "FK_PERSONAL_DEPENDIENTE_PERSONAL" FOREIGN KEY ("ID_CIA", "CODPER")
	  REFERENCES "USR_TSI_SUITE"."PERSONAL" ("ID_CIA", "CODPER") ENABLE;
