--------------------------------------------------------
--  Ref Constraints for Table TBANCOS_CHEQUES
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."TBANCOS_CHEQUES" ADD CONSTRAINT "FK_TBANCOS_CHEQUES_TBANCOS" FOREIGN KEY ("ID_CIA", "CODBAN")
	  REFERENCES "USR_TSI_SUITE"."TBANCOS" ("ID_CIA", "CODBAN") ENABLE;
