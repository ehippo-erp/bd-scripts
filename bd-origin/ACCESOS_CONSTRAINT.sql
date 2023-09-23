--------------------------------------------------------
--  Constraints for Table ACCESOS
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."ACCESOS" MODIFY ("CODMOD" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."ACCESOS" MODIFY ("CODACC" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."ACCESOS" ADD CONSTRAINT "PK_ACCESOS" PRIMARY KEY ("CODMOD", "CODACC")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;
