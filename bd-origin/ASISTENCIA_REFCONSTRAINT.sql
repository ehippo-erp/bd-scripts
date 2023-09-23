--------------------------------------------------------
--  Ref Constraints for Table ASISTENCIA
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."ASISTENCIA" ADD CONSTRAINT "FK_ASISTENCIA_USUARIOS" FOREIGN KEY ("ID_CIA", "USUARI")
	  REFERENCES "USR_TSI_SUITE"."USUARIOS" ("ID_CIA", "CODUSER") ENABLE;
