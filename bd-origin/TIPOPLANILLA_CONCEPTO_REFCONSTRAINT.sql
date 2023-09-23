--------------------------------------------------------
--  Ref Constraints for Table TIPOPLANILLA_CONCEPTO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."TIPOPLANILLA_CONCEPTO" ADD CONSTRAINT "FK_TIPOPLANILLA_CONCEPTO_CONCEPTO" FOREIGN KEY ("ID_CIA", "CODCON")
	  REFERENCES "USR_TSI_SUITE"."CONCEPTO" ("ID_CIA", "CODCON") ENABLE;
  ALTER TABLE "USR_TSI_SUITE"."TIPOPLANILLA_CONCEPTO" ADD CONSTRAINT "FK_TIPOPLANILLA_CONCEPTO_TIPOPLANILLA" FOREIGN KEY ("ID_CIA", "TIPPLA")
	  REFERENCES "USR_TSI_SUITE"."TIPOPLANILLA" ("ID_CIA", "TIPPLA") ENABLE;
