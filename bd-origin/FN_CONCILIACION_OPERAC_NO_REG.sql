--------------------------------------------------------
--  DDL for Function FN_CONCILIACION_OPERAC_NO_REG
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."FN_CONCILIACION_OPERAC_NO_REG" 
(
   PIN_ID_CIA IN NUMBER, 
  PIN_CUENTA IN VARCHAR2,
  PIN_PERIODO IN NUMBER,
  PIN_MES IN NUMBER
) RETURN FN_CONCILIACION_OPERAC_NO_REG_TBL PIPELINED AS

    REC FN_CONCILIACION_OPERAC_NO_REG_REC := FN_CONCILIACION_OPERAC_NO_REG_REC(
    NULL,
NULL,
NULL,
NULL,
NULL, 
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL
    );

   cursor  cur_select_operac is 
   select 

         C.Periodo ,  
         C.Mes     ,  
         C.Libro   ,  
         C.Asiento ,  
         C.Item    ,  
         C.SItem   ,  
         M.Fecha   ,  
         M.Codigo  ,  
         M.Razon   ,  
         M.Numero  ,  
         M.Cuenta  ,  
         P.Moneda01, 
         Case When P.Moneda01='PEN' Then M.Debe01  Else M.Debe02  End as Debe,  
         Case When P.Moneda01='PEN' Then M.Haber01 Else M.Haber02 End as Haber, 
         Case When P.Moneda01='PEN' Then M.Debe01  Else M.Debe02  End -   
         Case When P.Moneda01='PEN' Then M.Haber01 Else M.Haber02 End as Saldo, 
         case when a.tcamb01<>0.0 and a.tcamb02<>0.0 then a.tcamb01/a.tcamb02 else 0.0 end tipcam, 
         M.Concep  ,  
         M.TOpera  ,  
         O.Descri as DesTOpera,  
         C.PeriodoCOB, 
         C.MesCOB,A.Referencia,      
         M.NUMERO AS NUMEROREF, 
         A.Usuari as Coduser, 
         U.Nombres as Usuario 
  From Movimientos_Conciliacion C 
   Inner Join Movimientos   M on 
                            M.id_cia=C.id_cia and M.Periodo=C.Periodo And 
                            M.Mes    =C.Mes     And 
                            M.Libro  =C.Libro   And 
                            M.Asiento=C.Asiento And 
                            M.Item   =C.Item    And 
                            M.SItem  =C.SItem   And 
                            M.Cuenta = PIN_CUENTA
   Left outer join AsienHea A on A.id_cia = M.id_cia and A.Periodo=M.Periodo and 
                                 A.Mes    =M.Mes and 
                                 A.Libro  =M.Libro and 
                                 A.Asiento = M.Asiento 
   Left outer join Usuarios u on u.id_cia = a.id_cia and u.coduser = a.usuari 
   Left outer Join Pcuentas P on P.id_cia = M.id_cia and P.Cuenta=M.Cuenta 
   Left Outer Join M_Pago O on O.ID_CIA = M.id_cia and (O.Codigo=((Case When (M.TOpera is Null) or 
                                                     (M.TOpera='') or 
                                                     Not(SubStr(M.TOpera,1,1) in ('0','1','2','3','4','5','6','7','8','9')) 
                                               Then 0  else Cast(M.TOpera as Smallint) End)) )
 Where C.ID_CIA = PIN_ID_CIA 
 AND (  ((C.Periodo    * 100)+C.Mes   )<=((PIN_PERIODO * 100)+PIN_MES)) And 
       ( (((C.PeriodoCOB * 100)+C.MesCob) Is Null) Or 
         (((C.PeriodoCOB * 100)+C.MesCob)=0)       Or 
         (((C.PeriodoCob * 100)+C.MesCob)>((PIN_PERIODO * 100)+PIN_MES) )
       ) 
 Order by M.Fecha,M.Libro,M.Asiento,M.Asiento,M.Item; 

BEGIN


    FOR i IN cur_select_operac LOOP
    rec.periodo := i.periodo;
rec.mes := i.mes;
rec.libro := i.libro;
rec.asiento := i.asiento;
rec.item := i.item;
rec.sitem := i.sitem;
rec.fecha := i.fecha;
rec.codigo := i.codigo;
rec.razon := i.razon;
rec.numero := i.numero;
rec.cuenta := i.cuenta;
rec.moneda01 := i.moneda01;
rec.debe := i.debe;
rec.haber := i.haber;
rec.saldo := i.saldo;
rec.tipcam := i.tipcam;
rec.concep := i.concep;
rec.topera := i.topera;
rec.destopera := i.destopera;
rec.periodocob := i.periodocob;
rec.mescob := i.mescob;
rec.referencia := i.referencia;
rec.numeroref := i.numeroref;
rec.coduser := i.coduser;
rec.usuario := i.usuario;
          PIPE ROW(REC);
        END LOOP;



END FN_CONCILIACION_OPERAC_NO_REG;

/
