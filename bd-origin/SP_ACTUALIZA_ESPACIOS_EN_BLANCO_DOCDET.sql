--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_ESPACIOS_EN_BLANCO_DOCDET
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_ESPACIOS_EN_BLANCO_DOCDET" 
(
  PIN_ID_CIA IN NUMBER 
) AS 
BEGIN


  -- ELIMINA ESPACIO EN BLANCO DE CODIGO ARTICULO EN DOCUMENTOS_DET

  FOR i IN (

    select id_cia, numint, numite, tipinv, codart from documentos_det 
    where id_cia = pin_id_cia 
    and INSTR(codart,' ',1,1)>0

  ) LOOP
        update documentos_det 
            set codart  = trim(i.codart)
            where id_cia = pin_id_cia
            and numint = i.numint
            and numite = i.numite
            and tipinv = i.tipinv
            and codart = i.codart;
      END LOOP;


END SP_ACTUALIZA_ESPACIOS_EN_BLANCO_DOCDET;

/
