--------------------------------------------------------
--  Ref Constraints for Table PERSONAL_TURNO_PLANILLA
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_TURNO_PLANILLA" ADD CONSTRAINT "FK_PERSONAL_TURNO_PLANILLA_ASISTENCIA_TURNO_PLANILLA" FOREIGN KEY ("ID_CIA", "ID_TURNO")
	  REFERENCES "USR_TSI_SUITE"."ASISTENCIA_PLANILLA_TURNO" ("ID_CIA", "ID_TURNO") ENABLE;
