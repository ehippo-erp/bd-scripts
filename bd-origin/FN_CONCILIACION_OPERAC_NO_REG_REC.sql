--------------------------------------------------------
--  DDL for Type FN_CONCILIACION_OPERAC_NO_REG_REC
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."FN_CONCILIACION_OPERAC_NO_REG_REC" AS OBJECT 
( /* TODO enter attribute and method declarations here */ 

                      periodo NUMBER,   
         mes NUMBER,       
         libro VARCHAR2(250),     
         asiento VARCHAR2(250),   
         item NUMBER,      
         sitem VARCHAR2(250),     
         fecha DATE,     
         codigo VARCHAR2(250),    
         razon VARCHAR2(250),     
         numero VARCHAR2(250),    
         cuenta VARCHAR2(250),    
         moneda01 VARCHAR2(250), 
         debe NUMBER,  
         haber NUMBER, 
         saldo NUMBER, 
         tipcam NUMBER, 
         concep VARCHAR2(250),    
         topera VARCHAR2(250),    
         destopera VARCHAR2(250),  
         periodocob VARCHAR2(250), 
         mescob VARCHAR2(250),
         referencia VARCHAR2(250),      
         numeroref VARCHAR2(250), 
         coduser VARCHAR2(250), 
         usuario VARCHAR2(250)


);

/
