--------------------------------------------------------
--  Constraints for Table COMPR010_CLASE
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."COMPR010_CLASE" ADD CONSTRAINT "PK_COMPR010_CLASE" PRIMARY KEY ("ID_CIA", "TIPO", "DOCUME", "CLASE")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;
