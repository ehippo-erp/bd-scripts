--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_TOTALES
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_TOTALES" 
(
  PIN_ID_CIA IN NUMBER 
) AS 
BEGIN

    -- actualzia el detalle

    FOR i IN (

        select 

            c.id_cia,c.numint,c.incigv,d.numite,d.cantid,d.preuni,d.importe,
            cast(d.cantid*d.preuni as number(16,2)) as importe_calc,
            cast(d.cantid*d.preuni as number(16,2)) as monafe_calc,
            cast(cast((d.cantid*d.preuni) as number(16,2))*0.18 as number(16,2)) as monigv_calc ,



            cast(d.cantid*d.preuni as number(16,2)) as importe_calc_incigv,
            cast(cast(d.cantid*d.preuni as number(16,2))/1.18 as number(16,2)) as monafe_calc_incigv,
            cast(d.cantid*d.preuni as number(16,2)) - cast(cast(d.cantid*d.preuni as number(16,2))/1.18 as number(16,2)) as monigv_calc_incigv



        from documentos_cab c
        left outer join documentos_det d on d.id_cia=c.id_cia and d.numint=c.numint
        where c.id_cia = PIN_ID_CIA 
        and c.tipdoc = 108 

        and c.situac in ('C','F','G','H')


    ) LOOP

            if i.incigv = 'S' then


                update documentos_det set 
                importe = i.importe_calc_incigv,
                monafe = i.monafe_calc_incigv,
                monigv = i.monigv_calc_incigv
              where id_cia = pin_id_cia
              and numint = i.numint 
              and numite = i.numite;

            else 


                       update documentos_det set 
                importe = i.importe_calc,
                monafe = i.monafe_calc,
                monigv = i.monigv_calc
              where id_cia = pin_id_cia
              and numint = i.numint 
              and numite = i.numite;

            end if;



        END LOOP;


        COMMIT;



        -- actualiza cabecera

         FOR i IN (

        select 
                c.numint,    
                sum(d.monafe) as monafe,
                sum(d.monigv) as monigv,
                sum(d.monafe + d.monigv ) as preven
        from documentos_cab c
        left outer join documentos_det d on d.id_cia=c.id_cia and d.numint=c.numint
        where c.id_cia = PIN_ID_CIA 
        and c.tipdoc = 108 
        and c.situac in ('C','F','G','H')
        group by c.numint

    ) LOOP

              update documentos_cab set  
                monafe = i.monafe,
                monigv = i.monigv,
                preven = i.preven
              where id_cia = pin_id_cia
              and numint = i.numint;


        END LOOP;


        COMMIT; 




END SP_ACTUALIZA_TOTALES;

/
