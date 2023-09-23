--------------------------------------------------------
--  Ref Constraints for Table EXCELDINAMICO_USUARIO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."EXCELDINAMICO_USUARIO" ADD CONSTRAINT "FK_EXCELDINAMICO_USUARIO_USUARIOS" FOREIGN KEY ("ID_CIA", "CODUSER")
	  REFERENCES "USR_TSI_SUITE"."USUARIOS" ("ID_CIA", "CODUSER") ENABLE;
