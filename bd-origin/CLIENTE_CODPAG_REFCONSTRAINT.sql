--------------------------------------------------------
--  Ref Constraints for Table CLIENTE_CODPAG
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."CLIENTE_CODPAG" ADD CONSTRAINT "FK_CLIENTE_CODPAG_CLIENTE" FOREIGN KEY ("ID_CIA", "CODCLI")
	  REFERENCES "USR_TSI_SUITE"."CLIENTE" ("ID_CIA", "CODCLI") ENABLE;
