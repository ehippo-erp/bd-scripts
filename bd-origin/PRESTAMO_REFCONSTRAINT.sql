--------------------------------------------------------
--  Ref Constraints for Table PRESTAMO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PRESTAMO" ADD CONSTRAINT "FK_PRESTAMO_PERSONAL" FOREIGN KEY ("ID_CIA", "CODPER")
	  REFERENCES "USR_TSI_SUITE"."PERSONAL" ("ID_CIA", "CODPER") ENABLE;
