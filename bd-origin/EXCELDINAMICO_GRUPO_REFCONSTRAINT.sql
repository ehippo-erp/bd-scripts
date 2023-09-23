--------------------------------------------------------
--  Ref Constraints for Table EXCELDINAMICO_GRUPO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."EXCELDINAMICO_GRUPO" ADD CONSTRAINT "FK_EXCELDINAMICO_GRUPO_GRUPO_USUARIO" FOREIGN KEY ("ID_CIA", "CODGRUPO")
	  REFERENCES "USR_TSI_SUITE"."GRUPO_USUARIO" ("ID_CIA", "CODGRUPO") ENABLE;
