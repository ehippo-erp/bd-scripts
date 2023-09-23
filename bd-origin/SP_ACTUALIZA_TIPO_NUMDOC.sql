--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_TIPO_NUMDOC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_TIPO_NUMDOC" 
(
  pin_id_cia IN number
) AS 
BEGIN


  FOR i IN (

    SELECT *
        FROM PROV105
    WHERE ID_CIA = pin_id_cia AND TIPO IS NULL AND DOCU IS NULL AND SITUAC='B'

  ) LOOP

            update prov105 set 
                tipo = TO_NUMBER(i.series, '9G999D99'), 
                docu  = i.numdoc
            where id_cia = pin_id_cia
            and tipdoc = i.tipdoc
            and series = i.series
            and numdoc = i.numdoc;

      END LOOP;

END SP_ACTUALIZA_TIPO_NUMDOC;

/
