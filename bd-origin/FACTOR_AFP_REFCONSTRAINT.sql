--------------------------------------------------------
--  Ref Constraints for Table FACTOR_AFP
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."FACTOR_AFP" ADD CONSTRAINT "FK_FACTOR_AFP_AFP" FOREIGN KEY ("ID_CIA", "CODAFP")
	  REFERENCES "USR_TSI_SUITE"."AFP" ("ID_CIA", "CODAFP") ENABLE;
