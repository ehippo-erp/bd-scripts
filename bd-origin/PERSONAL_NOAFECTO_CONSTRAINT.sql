--------------------------------------------------------
--  Constraints for Table PERSONAL_NOAFECTO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_NOAFECTO" MODIFY ("ID_CIA" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_NOAFECTO" MODIFY ("CODCON" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_NOAFECTO" MODIFY ("CODPER" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_NOAFECTO" ADD CONSTRAINT "PK_PERSONAL_NOAFECTO" PRIMARY KEY ("ID_CIA", "CODCON", "CODPER")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;
