--------------------------------------------------------
--  DDL for Procedure SP_INSERTA_CLASES_OBLIGATORIAS_IC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_INSERTA_CLASES_OBLIGATORIAS_IC" 
(
  PIN_ID_CIA IN NUMBER 
, pin_tipcli IN VARCHAR2 
, PIN_CODCLI IN VARCHAR2 
) AS 
BEGIN


   INSERT INTO cliente_clase (
                id_cia,
                tipcli,
                codcli,
                clase,
                codigo,
                situac
            )   select
                   pin_id_cia,
                   pin_tipcli,
                   PIN_CODCLI,
                   c.clase,
                   case when cc.codigo is null then cast('ND' as varchar(20)) else cc.codigo end as codigo,
                   'S'
                from clase_cliente c
                left outer join clase_cliente_codigo cc on cc.id_cia = c.id_cia and cc.tipcli=c.tipcli and cc.clase=c.clase and cc.swdefaul='S'
                where c.id_cia = PIN_ID_CIA
                and c.tipcli = pin_tipcli 
                and c.obliga = 'S'
                and not exists(
                     select * from cliente_clase
                     where id_cia = pin_id_cia
                     and tipcli = pin_tipcli
                     and codcli = PIN_CODCLI
                     and clase = c.clase     
                );

END SP_INSERTA_CLASES_OBLIGATORIAS_IC;

/
