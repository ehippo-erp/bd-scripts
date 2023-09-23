--------------------------------------------------------
--  Ref Constraints for Table CLASE_VENDEDOR_CODIGO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."CLASE_VENDEDOR_CODIGO" ADD CONSTRAINT "FK_CLASE_VENDEDOR_CODIGO_CLASE_VENDEDOR" FOREIGN KEY ("ID_CIA", "CLASE")
	  REFERENCES "USR_TSI_SUITE"."CLASE_VENDEDOR" ("ID_CIA", "CLASE") ENABLE;
