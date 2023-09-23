--------------------------------------------------------
--  Ref Constraints for Table PERSONAL_NOAFECTO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_NOAFECTO" ADD CONSTRAINT "FK_PERSONAL_NOAFECTO_PERSONAL" FOREIGN KEY ("ID_CIA", "CODPER")
	  REFERENCES "USR_TSI_SUITE"."PERSONAL" ("ID_CIA", "CODPER") ENABLE;
