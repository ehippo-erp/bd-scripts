--------------------------------------------------------
--  Ref Constraints for Table ASISTENCIA_PLANILLA_TURNO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."ASISTENCIA_PLANILLA_TURNO" ADD CONSTRAINT "FK_ASISTENCIA_PLANILLA_TURNO_TIPO_TRABAJADOR" FOREIGN KEY ("ID_CIA", "TIPTRA")
	  REFERENCES "USR_TSI_SUITE"."TIPO_TRABAJADOR" ("ID_CIA", "TIPTRA") ENABLE;
