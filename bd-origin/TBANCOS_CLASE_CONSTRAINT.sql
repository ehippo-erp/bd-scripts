--------------------------------------------------------
--  Constraints for Table TBANCOS_CLASE
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."TBANCOS_CLASE" MODIFY ("ID_CIA" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."TBANCOS_CLASE" MODIFY ("CODBAN" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."TBANCOS_CLASE" MODIFY ("CLASE" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."TBANCOS_CLASE" ADD CONSTRAINT "TBANCOS_CLASE_PK" PRIMARY KEY ("ID_CIA", "CODBAN", "CLASE")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;
