--------------------------------------------------------
--  Ref Constraints for Table USUARIO_MODULOS
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."USUARIO_MODULOS" ADD CONSTRAINT "FK_USUARIO_MODULOS_EMPRESA_MODULOS" FOREIGN KEY ("ID_CIA", "CODMOD")
	  REFERENCES "USR_TSI_SUITE"."EMPRESA_MODULOS" ("ID_CIA", "CODMOD") ENABLE;
  ALTER TABLE "USR_TSI_SUITE"."USUARIO_MODULOS" ADD CONSTRAINT "FK_USUARIO_MODULOS_USUARIOS" FOREIGN KEY ("ID_CIA", "CODUSER")
	  REFERENCES "USR_TSI_SUITE"."USUARIOS" ("ID_CIA", "CODUSER") ENABLE;
