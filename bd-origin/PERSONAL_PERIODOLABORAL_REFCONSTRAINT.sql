--------------------------------------------------------
--  Ref Constraints for Table PERSONAL_PERIODOLABORAL
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_PERIODOLABORAL" ADD CONSTRAINT "FK_PERSONA_PERIODOLABORA_PERSONAL" FOREIGN KEY ("ID_CIA", "CODPER")
	  REFERENCES "USR_TSI_SUITE"."PERSONAL" ("ID_CIA", "CODPER") ENABLE;
