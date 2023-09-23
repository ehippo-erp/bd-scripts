--------------------------------------------------------
--  DDL for Table MD_APPLICATIONS
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."MD_APPLICATIONS" 
   (	"ID" NUMBER, 
	"NAME" VARCHAR2(4000 BYTE), 
	"DESCRIPTION" VARCHAR2(4000 BYTE), 
	"BASE_DIR" VARCHAR2(4000 BYTE), 
	"OUTPUT_DIR" VARCHAR2(4000 BYTE), 
	"BACKUP_DIR" VARCHAR2(4000 BYTE), 
	"INPLACE" NUMBER, 
	"PROJECT_ID_FK" NUMBER, 
	"SECURITY_GROUP_ID" NUMBER DEFAULT 0, 
	"CREATED_ON" DATE DEFAULT sysdate, 
	"CREATED_BY" VARCHAR2(255 BYTE), 
	"LAST_UPDATED_ON" DATE, 
	"LAST_UPDATED_BY" VARCHAR2(255 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

   COMMENT ON COLUMN "USR_TSI_SUITE"."MD_APPLICATIONS"."NAME" IS 'Name of the application suite  //OBJECTNAME';
   COMMENT ON TABLE "USR_TSI_SUITE"."MD_APPLICATIONS"  IS 'This is the base table for application projects.  It holds the base information for applications associated with a database';
   COMMENT ON COLUMN "USR_TSI_SUITE"."MD_APPLICATIONS"."ID" IS 'Primary Key';
   COMMENT ON COLUMN "USR_TSI_SUITE"."MD_APPLICATIONS"."DESCRIPTION" IS 'Overview of what the application does.';
   COMMENT ON COLUMN "USR_TSI_SUITE"."MD_APPLICATIONS"."BASE_DIR" IS 'This is the base src directory for the application.  It could be an svn checkout, a clearcase view or something similar';
   COMMENT ON COLUMN "USR_TSI_SUITE"."MD_APPLICATIONS"."OUTPUT_DIR" IS 'This is the output directory where the scanner will present the converted files, if there are converted or modified.';
   COMMENT ON COLUMN "USR_TSI_SUITE"."MD_APPLICATIONS"."BACKUP_DIR" IS 'This is the directory in which the application files are backed up if a backp is chosen';
   COMMENT ON COLUMN "USR_TSI_SUITE"."MD_APPLICATIONS"."INPLACE" IS 'Designates whether the changes have been made inplace, in the source directory or not';
   COMMENT ON COLUMN "USR_TSI_SUITE"."MD_APPLICATIONS"."PROJECT_ID_FK" IS 'project of the database(s) this application relates to';
