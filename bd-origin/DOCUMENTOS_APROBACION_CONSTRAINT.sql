--------------------------------------------------------
--  Constraints for Table DOCUMENTOS_APROBACION
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."DOCUMENTOS_APROBACION" ADD CONSTRAINT "PK_DOCUMENTOS_APROBACION" PRIMARY KEY ("ID_CIA", "NUMINT")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;
