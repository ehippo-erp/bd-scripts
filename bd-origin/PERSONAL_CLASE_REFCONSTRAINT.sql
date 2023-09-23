--------------------------------------------------------
--  Ref Constraints for Table PERSONAL_CLASE
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_CLASE" ADD CONSTRAINT "FK_PERSONAL_CLASE_PERSONAL" FOREIGN KEY ("ID_CIA", "CODPER")
	  REFERENCES "USR_TSI_SUITE"."PERSONAL" ("ID_CIA", "CODPER") ENABLE;
