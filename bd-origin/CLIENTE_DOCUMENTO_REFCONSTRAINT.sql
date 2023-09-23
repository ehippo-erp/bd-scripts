--------------------------------------------------------
--  Ref Constraints for Table CLIENTE_DOCUMENTO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."CLIENTE_DOCUMENTO" ADD CONSTRAINT "FK_CLIENTE_DOCUMENTO_CLIENTE" FOREIGN KEY ("ID_CIA", "CODCLI")
	  REFERENCES "USR_TSI_SUITE"."CLIENTE" ("ID_CIA", "CODCLI") ENABLE;
