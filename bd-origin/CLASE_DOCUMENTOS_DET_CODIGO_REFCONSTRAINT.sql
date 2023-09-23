--------------------------------------------------------
--  Ref Constraints for Table CLASE_DOCUMENTOS_DET_CODIGO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."CLASE_DOCUMENTOS_DET_CODIGO" ADD CONSTRAINT "FK_CLASE_DOCUMENTOS_DET_CODIGO_CLASE_DOCUMENTOS_DET" FOREIGN KEY ("ID_CIA", "TIPDOC", "CLASE")
	  REFERENCES "USR_TSI_SUITE"."CLASE_DOCUMENTOS_DET" ("ID_CIA", "TIPDOC", "CLASE") ENABLE;
