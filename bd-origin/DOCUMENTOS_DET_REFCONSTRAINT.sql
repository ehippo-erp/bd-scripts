--------------------------------------------------------
--  Ref Constraints for Table DOCUMENTOS_DET
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."DOCUMENTOS_DET" ADD CONSTRAINT "DOCUMENTOS_DET_FK1" FOREIGN KEY ("ID_CIA", "TIPINV", "CODART")
	  REFERENCES "USR_TSI_SUITE"."ARTICULOS" ("ID_CIA", "TIPINV", "CODART") ENABLE;
