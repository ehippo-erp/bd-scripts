--------------------------------------------------------
--  Ref Constraints for Table LICENCIA_PRODUCTO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."LICENCIA_PRODUCTO" ADD CONSTRAINT "FK_LICENCIA_PRODUCTO_PRODUCTO_LICENCIA" FOREIGN KEY ("CODPRO")
	  REFERENCES "USR_TSI_SUITE"."PRODUCTO_LICENCIA" ("CODPRO") ENABLE;
