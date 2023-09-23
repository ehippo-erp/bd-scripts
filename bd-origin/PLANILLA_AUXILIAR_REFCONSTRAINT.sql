--------------------------------------------------------
--  Ref Constraints for Table PLANILLA_AUXILIAR
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PLANILLA_AUXILIAR" ADD CONSTRAINT "FK_PLANILLA_AUXILIAR_PERSONAL" FOREIGN KEY ("ID_CIA", "CODPER")
	  REFERENCES "USR_TSI_SUITE"."PERSONAL" ("ID_CIA", "CODPER") ENABLE;
