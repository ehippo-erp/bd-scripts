--------------------------------------------------------
--  Constraints for Table EXCELDINAMICO_GENERICO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."EXCELDINAMICO_GENERICO" ADD CONSTRAINT "PK_EXCELDINAMICO_GENERICO" PRIMARY KEY ("ID_CIA", "CODEXC")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;
