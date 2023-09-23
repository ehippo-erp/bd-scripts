--------------------------------------------------------
--  Ref Constraints for Table PERSONAL_LEGAJO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_LEGAJO" ADD CONSTRAINT "FK_PERSONAL_LEGAJO_PERSONAL" FOREIGN KEY ("ID_CIA", "CODPER")
	  REFERENCES "USR_TSI_SUITE"."PERSONAL" ("ID_CIA", "CODPER") ENABLE;
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_LEGAJO" ADD CONSTRAINT "FK_PERSONAL_LEGAJO_TIPOITEM" FOREIGN KEY ("ID_CIA", "CODTIP", "CODITE")
	  REFERENCES "USR_TSI_SUITE"."TIPOITEM" ("ID_CIA", "CODTIP", "CODITE") ENABLE;
