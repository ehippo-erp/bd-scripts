--------------------------------------------------------
--  Ref Constraints for Table PCUENTAS
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PCUENTAS" ADD CONSTRAINT "FK_PCUENTAS_TANALITICA" FOREIGN KEY ("ID_CIA", "CODTANA")
	  REFERENCES "USR_TSI_SUITE"."TANALITICA" ("ID_CIA", "CODTANA") ENABLE;
