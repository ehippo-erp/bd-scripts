--------------------------------------------------------
--  DDL for Function CONCILIACION_DETALLE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."CONCILIACION_DETALLE" 
(
  PIN_ID_CIA IN NUMBER, 
  PIN_CUENTA IN VARCHAR2,
  PIN_PERIODO IN NUMBER,
  PIN_MES IN NUMBER,
  PIN_CODCLI IN VARCHAR2
) RETURN CONCILIACION_DETALLE_TBL  PIPELINED AS 
    
    
    REC CONCILIACION_DETALLE_REC := CONCILIACION_DETALLE_REC(
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
NULL,
NULL,
NULL,
NULL
    );
 vResponse number;
BEGIN


    FOR i IN (
     SELECT

         M.SwChkConcilia,    M.Cuenta, M.Codigo, M.Razon,M.Periodo, M.Mes, M.Fecha,  
         M.Libro,  M.Asiento,M.Item,   M.SItem,  M.Numero, P.Moneda01, 
         Case When P.Moneda01='PEN' Then M.Debe01  Else M.Debe02  End as Debe,  
         Case When P.Moneda01='PEN' Then M.Haber01 Else M.Haber02 End as Haber, 
         Case When P.Moneda01='PEN' Then M.Debe01  Else M.Debe02  End -   
         Case When P.Moneda01='PEN' Then M.Haber01 Else M.Haber02 End as Saldo, 
         Cast(0 As Numeric(16,2)) as PenDebe, 
         Cast(0 As Numeric(16,2)) as PenHaber, 
         case when a.tcamb01<>0.0 and a.tcamb02<>0.0 then a.tcamb01/a.tcamb02 else 0.0 end tipcam, 
         M.Concep, M.TOpera, 
         O.Descri as DesTOpera, C.PeriodoCob, C.MesCob,A.Referencia, 
         M.NUMERO AS NUMEROREF, 
         A.Usuari as Coduser,  
         U.Nombres as Usuario 
    FROM
        movimientos               m
 Left outer join AsienHea A on A.id_cia=M.id_cia  and A.Periodo=M.Periodo and                                  A.Mes    =M.Mes and 
                                 A.Libro  =M.Libro and 
                                 A.Asiento=M.Asiento 
 Left outer join Usuarios u on u.id_cia = a.id_cia and u.coduser=a.usuari 
   Left outer Join Pcuentas P on P.id_cia = M.id_cia and P.Cuenta = M.Cuenta 
   Left Outer Join Movimientos_Conciliacion C on  C.id_cia=M.id_cia and C.Periodo=M.Periodo And 
                                                  C.Mes    =M.Mes     And 
                                                  C.Libro  =M.Libro   And 
                                                  C.Asiento=M.Asiento And 
                                                  C.Item   =M.Item    And 
                                                  C.SItem  =M.SItem       
   Left Outer Join M_Pago O on O.id_cia = M.id_cia and (O.Codigo=((Case When (M.TOpera is Null) or 
                                                     (M.TOpera='') or 
                                                     Not(SubStr(M.TOpera,1,1) in ('0','1','2','3','4','5','6','7','8','9')) 
                                               Then 0  else Cast(M.TOpera as Smallint) End)) )
    WHERE M.ID_CIA = PIN_ID_CIA
    and (((  ((M.Periodo    * 100)+M.Mes)=((PIN_PERIODO * 100)+PIN_MES) ) And 
         ( (((C.PeriodoCOB * 100)+C.MesCob) Is Null) Or  
           (((C.PeriodoCob * 100)+C.MesCob) = ((PIN_PERIODO * 100)+PIN_MES) )
         ) 
        ) Or 
        (( ((M.Periodo    * 100)+M.Mes   )< ((PIN_PERIODO * 100)+PIN_MES)) And 
         ( ((C.PeriodoCob * 100)+C.MesCob)= ((PIN_PERIODO * 100)+PIN_MES)) 
        )  
       ) And 

       M.Cuenta = PIN_CUENTA 
      and ((pin_codcli is null) or (M.CODIGO = pin_codcli))

    ) LOOP
            REC.swchkconcilia := i.swchkconcilia;
REC.cuenta := i.cuenta;
REC.codigo := i.codigo;
REC.razon := i.razon;
REC.periodo := i.periodo;
REC.mes := i.mes;
REC.fecha := i.fecha;
REC.libro := i.libro;
REC.asiento := i.asiento;
REC.item := i.item;
REC.sitem := i.sitem;
REC.numero := i.numero;
REC.moneda01 := i.moneda01;
REC.debe := i.debe;
REC.haber := i.haber;
REC.saldo := i.saldo;
REC.pendebe := i.pendebe;
REC.penhaber := i.penhaber;
REC.tipcam := i.tipcam;
REC.concep := i.concep;
REC.topera := i.topera;
REC.destopera := i.destopera;
REC.periodocob := i.periodocob;
REC.mescob := i.mescob;
REC.referencia := i.referencia;
REC.numeroref := i.numeroref;
REC.coduser := i.coduser;
REC.usuario := i.usuario;



          PIPE ROW(REC);
        END LOOP;

END conciliacion_detalle;

/
