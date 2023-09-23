--------------------------------------------------------
--  Ref Constraints for Table ARTICULOS_EAN
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."ARTICULOS_EAN" ADD CONSTRAINT "FK_ARTICULOS_EAN_ARTICULOS" FOREIGN KEY ("ID_CIA", "TIPINV", "CODART")
	  REFERENCES "USR_TSI_SUITE"."ARTICULOS" ("ID_CIA", "TIPINV", "CODART") ENABLE;
