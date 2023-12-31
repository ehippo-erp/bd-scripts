--------------------------------------------------------
--  DDL for Type REC_SP_SELECT_MOV_ARTICULO_GUIA_INGRESO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP_SELECT_MOV_ARTICULO_GUIA_INGRESO" AS OBJECT 
( 
    
 NUMINT NUMBER, 
 SERIES VARCHAR(16), 
 NUMDOC NUMBER, 
 GUIPRO VARCHAR(20), 
 FGUIPRO DATE, 
 FACPRO VARCHAR(20), 
 FFACPRO DATE, 
 NUMPED VARCHAR(25), 
 CODMOT NUMBER, 
 FEMISI DATE, 
 TIPINV NUMBER, 
 CODART VARCHAR(100), 
 DESART VARCHAR(220), 
 CODCALID VARCHAR(60), 
 DESCALID VARCHAR(120), 
 CODCOLOR VARCHAR(60), 
 DESCOLOR VARCHAR(120), 
 ANCHO NUMBER, 
 CANTROLLOS NUMBER, 
 CANTID NUMBER, 
 CODUNI VARCHAR(16), 
 SIMBOLO VARCHAR(16), 
 COSTOT_IN NUMBER, 
 COSTOT_CON NUMBER, 
 COSTOSIN NUMBER, 
 COSTOCON NUMBER 

);

/
