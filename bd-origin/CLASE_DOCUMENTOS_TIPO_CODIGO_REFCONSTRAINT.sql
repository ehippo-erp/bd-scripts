--------------------------------------------------------
--  Ref Constraints for Table CLASE_DOCUMENTOS_TIPO_CODIGO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."CLASE_DOCUMENTOS_TIPO_CODIGO" ADD CONSTRAINT "FK_CLASE_DOCUMENTOS_TIPO_CODIGO_CLASE_DOCUMENTOS_TIPO" FOREIGN KEY ("ID_CIA", "CLASE")
	  REFERENCES "USR_TSI_SUITE"."CLASE_DOCUMENTOS_TIPO" ("ID_CIA", "CLASE") ENABLE;
