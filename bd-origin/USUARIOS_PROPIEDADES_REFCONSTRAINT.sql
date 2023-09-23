--------------------------------------------------------
--  Ref Constraints for Table USUARIOS_PROPIEDADES
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."USUARIOS_PROPIEDADES" ADD CONSTRAINT "FK_USUARIOS_PROPIEDADES_PROPIEDADES_USUARIOS" FOREIGN KEY ("CODIGO")
	  REFERENCES "USR_TSI_SUITE"."PROPIEDADES_USUARIOS" ("CODIGO") ENABLE;
