--------------------------------------------------------
--  Ref Constraints for Table PLANILLA
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PLANILLA" ADD CONSTRAINT "FK_PLANILLA_TIPOPLANILLA" FOREIGN KEY ("ID_CIA", "TIPPLA")
	  REFERENCES "USR_TSI_SUITE"."TIPOPLANILLA" ("ID_CIA", "TIPPLA") ENABLE;
