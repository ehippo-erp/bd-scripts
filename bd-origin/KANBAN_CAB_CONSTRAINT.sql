--------------------------------------------------------
--  Constraints for Table KANBAN_CAB
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."KANBAN_CAB" ADD CONSTRAINT "PK_KANBAN_CAB" PRIMARY KEY ("ID_CIA", "CODKAN", "TIPINV", "CODALM")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;
