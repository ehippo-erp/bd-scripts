--------------------------------------------------------
--  Constraints for Table DOCUMENTOS_FORMATOS
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."DOCUMENTOS_FORMATOS" MODIFY ("TIPDOC" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."DOCUMENTOS_FORMATOS" MODIFY ("ITEM" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."DOCUMENTOS_FORMATOS" ADD CONSTRAINT "DOCUMENTOS_FORMATOS_PK" PRIMARY KEY ("TIPDOC", "ITEM")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;
