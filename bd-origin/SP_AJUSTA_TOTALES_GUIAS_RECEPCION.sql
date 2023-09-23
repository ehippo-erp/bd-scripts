--------------------------------------------------------
--  DDL for Procedure SP_AJUSTA_TOTALES_GUIAS_RECEPCION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_AJUSTA_TOTALES_GUIAS_RECEPCION" 
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

        for i in (
        select 
            C1.numint,C1.series,C1.numdoc,c1.codcli,c1.femisi,
            count(distinct d2.numint) as count_items,
            max(c2.numint) as ult_guia_rep,
            sum(d2.cantid*d2.preuni) as importe,
            sum(d2.monafe) as monafe,
            sum(d2.monigv) as monigv,
            max(C1.monafe) as monafe_fac,
            max(C1.monigv) as monigv_fac,
            max(C1.preven) as preven_fac,
            sum(d2.monafe)-max(C1.monafe) as monafe_calc,
            sum(d2.monigv)-max(C1.monigv) as monigv_calc
        from documentos_cab c1
        left outer join documentos_relacion r on r.id_cia = c1.id_cia and r.numint=c1.numint
        left outer join documentos_cab c2 on c2.id_cia = r.id_cia and c2.numint=r.numintre
        left outer join documentos_det d2 on d2.id_cia=c1.id_cia and d2.numint=c2.numint
        where c1.id_cia= PIN_ID_CIA
        and c1.TIPDOC IN (1) AND C1.SITUAC='F' and c1.lugemi=7
        group by C1.numint,C1.series,C1.numdoc,c1.codcli,c1.femisi) 
        LOOP
            update documentos_det set  
                monafe = monafe + (i.monafe_calc * -1),
                monigv = monigv + (i.monigv_calc * -1)
              where id_cia = pin_id_cia
              and numint = i.ult_guia_rep
              and numite = 1;
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

END SP_AJUSTA_TOTALES_GUIAS_RECEPCION;

/
