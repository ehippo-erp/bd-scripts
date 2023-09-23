--------------------------------------------------------
--  Constraints for Table PERSONAL_DEPENDIENTE
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DEPENDIENTE" MODIFY ("ID_CIA" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DEPENDIENTE" MODIFY ("CODPER" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DEPENDIENTE" MODIFY ("ITEM" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DEPENDIENTE" MODIFY ("CLAS03" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DEPENDIENTE" MODIFY ("CODI03" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DEPENDIENTE" MODIFY ("CLAS19" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DEPENDIENTE" MODIFY ("CODI19" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DEPENDIENTE" ADD CONSTRAINT "PK_PERSONAL_DEPENDIENTE" PRIMARY KEY ("ID_CIA", "CODPER", "ITEM")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;