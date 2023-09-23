--------------------------------------------------------
--  Constraints for Table DOCUMENTOS_CAB_IMAGEN
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."DOCUMENTOS_CAB_IMAGEN" MODIFY ("ID_CIA" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."DOCUMENTOS_CAB_IMAGEN" MODIFY ("NUMINT" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."DOCUMENTOS_CAB_IMAGEN" ADD CONSTRAINT "DOCUMENTOS_CAB_IMAGEN" PRIMARY KEY ("ID_CIA", "NUMINT")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;