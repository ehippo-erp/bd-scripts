--------------------------------------------------------
--  Ref Constraints for Table CLASE_PCUENTAS_CODIGO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."CLASE_PCUENTAS_CODIGO" ADD CONSTRAINT "FK_CLASE_PCUENTAS_CODIGO_CLASE_PCUENTAS" FOREIGN KEY ("ID_CIA", "CLASE")
	  REFERENCES "USR_TSI_SUITE"."CLASE_PCUENTAS" ("ID_CIA", "CLASE") ENABLE;
