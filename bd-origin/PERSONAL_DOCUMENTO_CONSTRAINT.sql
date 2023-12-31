--------------------------------------------------------
--  Constraints for Table PERSONAL_DOCUMENTO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DOCUMENTO" MODIFY ("ID_CIA" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DOCUMENTO" MODIFY ("CODPER" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DOCUMENTO" MODIFY ("CODTIP" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DOCUMENTO" MODIFY ("CODITE" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERSONAL_DOCUMENTO" ADD CONSTRAINT "PK_PERSONAL_DOCUMENTO" PRIMARY KEY ("ID_CIA", "CODPER", "CODTIP", "CODITE")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;
