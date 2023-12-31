--------------------------------------------------------
--  Ref Constraints for Table PERSONAL_CCOSTO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_CCOSTO" ADD CONSTRAINT "FK_PERSONAL_CCOSTO_TCCOSTOS" FOREIGN KEY ("ID_CIA", "CODCCO")
	  REFERENCES "USR_TSI_SUITE"."TCCOSTOS" ("ID_CIA", "CODIGO") ENABLE;
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_CCOSTO" ADD CONSTRAINT "FK_PERSONAL_CCOSTO_PERSONAL" FOREIGN KEY ("ID_CIA", "CODPER")
	  REFERENCES "USR_TSI_SUITE"."PERSONAL" ("ID_CIA", "CODPER") ENABLE;
