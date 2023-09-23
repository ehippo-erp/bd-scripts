--------------------------------------------------------
--  Ref Constraints for Table PLANILLA_RESUMEN
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PLANILLA_RESUMEN" ADD CONSTRAINT "FK_PLANILLA_RESUMEN_PERSONAL" FOREIGN KEY ("ID_CIA", "CODPER")
	  REFERENCES "USR_TSI_SUITE"."PERSONAL" ("ID_CIA", "CODPER") ENABLE;
