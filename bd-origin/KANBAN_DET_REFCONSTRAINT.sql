--------------------------------------------------------
--  Ref Constraints for Table KANBAN_DET
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."KANBAN_DET" ADD CONSTRAINT "FK_KANBAN_DET_KANBAN_CAB" FOREIGN KEY ("ID_CIA", "CODKAN", "TIPINV", "CODALM")
	  REFERENCES "USR_TSI_SUITE"."KANBAN_CAB" ("ID_CIA", "CODKAN", "TIPINV", "CODALM") ENABLE;
  ALTER TABLE "USR_TSI_SUITE"."KANBAN_DET" ADD CONSTRAINT "FK_KANBAN_DET_ARTICULOS" FOREIGN KEY ("ID_CIA", "TIPINV", "CODART")
	  REFERENCES "USR_TSI_SUITE"."ARTICULOS" ("ID_CIA", "TIPINV", "CODART") ENABLE;
