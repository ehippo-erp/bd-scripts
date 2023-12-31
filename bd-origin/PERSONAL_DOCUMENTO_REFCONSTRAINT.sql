--------------------------------------------------------
--  Ref Constraints for Table PERSONAL_DOCUMENTO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DOCUMENTO" ADD CONSTRAINT "FK_PERSONAL_DOCUMENTO_TIPOITEM" FOREIGN KEY ("ID_CIA", "CODTIP", "CODITE")
	  REFERENCES "USR_TSI_SUITE"."TIPOITEM" ("ID_CIA", "CODTIP", "CODITE") ENABLE;
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DOCUMENTO" ADD CONSTRAINT "FK_PERSONAL_DOCUMENTO_PERSONAL" FOREIGN KEY ("ID_CIA", "CODPER")
	  REFERENCES "USR_TSI_SUITE"."PERSONAL" ("ID_CIA", "CODPER") ENABLE;
