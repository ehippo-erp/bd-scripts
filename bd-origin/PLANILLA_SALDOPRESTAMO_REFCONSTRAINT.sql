--------------------------------------------------------
--  Ref Constraints for Table PLANILLA_SALDOPRESTAMO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PLANILLA_SALDOPRESTAMO" ADD CONSTRAINT "FK_PLANILLA_SALDOPRESTAMO_PERSONAL" FOREIGN KEY ("ID_CIA", "CODPER")
	  REFERENCES "USR_TSI_SUITE"."PERSONAL" ("ID_CIA", "CODPER") ENABLE;
  ALTER TABLE "USR_TSI_SUITE"."PLANILLA_SALDOPRESTAMO" ADD CONSTRAINT "FK_PLASALPRE_PLA" FOREIGN KEY ("ID_CIA", "NUMPLA")
	  REFERENCES "USR_TSI_SUITE"."PLANILLA" ("ID_CIA", "NUMPLA") ENABLE;
  ALTER TABLE "USR_TSI_SUITE"."PLANILLA_SALDOPRESTAMO" ADD CONSTRAINT "FK_PLASALPRE_TIPTRA" FOREIGN KEY ("ID_CIA", "TIPTRA")
	  REFERENCES "USR_TSI_SUITE"."TIPO_TRABAJADOR" ("ID_CIA", "TIPTRA") ENABLE;
