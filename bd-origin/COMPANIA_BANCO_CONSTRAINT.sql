--------------------------------------------------------
--  Constraints for Table COMPANIA_BANCO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."COMPANIA_BANCO" MODIFY ("ID_CIA" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."COMPANIA_BANCO" MODIFY ("CODBAN" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."COMPANIA_BANCO" MODIFY ("TIPCTA" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."COMPANIA_BANCO" MODIFY ("CODMON" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."COMPANIA_BANCO" ADD CONSTRAINT "PK_COMPANIA_BANCO" PRIMARY KEY ("ID_CIA", "CODBAN", "TIPCTA", "CODMON")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;
