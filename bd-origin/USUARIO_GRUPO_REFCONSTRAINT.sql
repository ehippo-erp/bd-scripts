--------------------------------------------------------
--  Ref Constraints for Table USUARIO_GRUPO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."USUARIO_GRUPO" ADD CONSTRAINT "FK_USUARIO_GRUPO_GRUPO_USUARIO" FOREIGN KEY ("ID_CIA", "CODGRUPO")
	  REFERENCES "USR_TSI_SUITE"."GRUPO_USUARIO" ("ID_CIA", "CODGRUPO") ENABLE;
