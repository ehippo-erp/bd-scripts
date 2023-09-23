--------------------------------------------------------
--  Ref Constraints for Table CLIENTE_CLASE
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."CLIENTE_CLASE" ADD CONSTRAINT "FK_CLIENTE_CLASE_CLIENTE" FOREIGN KEY ("ID_CIA", "CODCLI")
	  REFERENCES "USR_TSI_SUITE"."CLIENTE" ("ID_CIA", "CODCLI") ENABLE;
