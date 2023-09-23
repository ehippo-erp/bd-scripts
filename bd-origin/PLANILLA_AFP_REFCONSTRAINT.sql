--------------------------------------------------------
--  Ref Constraints for Table PLANILLA_AFP
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PLANILLA_AFP" ADD CONSTRAINT "FK_PLANILLA_AFP_PERSONAL" FOREIGN KEY ("ID_CIA", "CODPER")
	  REFERENCES "USR_TSI_SUITE"."PERSONAL" ("ID_CIA", "CODPER") ENABLE;
