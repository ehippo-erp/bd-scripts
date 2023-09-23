--------------------------------------------------------
--  DDL for Procedure SB_CONCILIAR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SB_CONCILIAR" 
(
  PIN_ID_CIA IN NUMBER 
, PIN_CUENTA IN VARCHAR2 
, PIN_PERIODO IN NUMBER
, PIN_MES IN NUMBER 
) AS 

    cursor dtEstadoCuenta(b_id_cia NUMBER, b_cuenta VARCHAR2, b_periodo number, b_mes number) is 
    select
			
                      be.b_cuenta,
                      be.b_periodo,
                      be.b_mes,
                      be.b_fecha,
                      be.b_dh,
                      be.b_importe,
                      be.B_NUMITE,
                      be.m_cuenta,
                      be.m_periodo,
                      be.m_mes,
                      be.m_libro,
                      be.m_asiento,
                      be.m_item,
                      be.m_sitem,
                      m.libro as j_libro,
                      m.periodo as j_periodo,
                      m.mes as j_mes,
                      m.asiento as j_asiento,
                      m.item as j_item,
                      m.sitem as j_sitem,
                      m.fecha as j_fecha,
                      m.importe as j_importe,
                      m.dh as j_dh
		from BANCOS_ESTADOCUENTA be
        inner join movimientos m on m.id_cia = be.id_cia and m.periodo = be.b_periodo and m.mes = be.b_mes 
                    and m.cuenta = be.b_cuenta and m.fecha = be.b_fecha and m.dh = be.b_dh and m.importe = be.b_importe
		where be.id_cia = b_id_cia
        and be.b_periodo = b_periodo
        and be.b_mes = b_mes
        and be.b_cuenta = b_cuenta;


BEGIN

      -- se inicializamos el periodo bancos en N el campo SWCHKCONCILIA
      update BANCOS_ESTADOCUENTA
            set SWCHKCONCILIA = 'N'
      where ID_CIA = pin_id_cia
      and b_periodo = PIN_PERIODO
      and b_mes = PIN_MES
      and b_cuenta = PIN_CUENTA;
      COMMIT;


    FOR i IN dtEstadoCuenta(PIN_ID_CIA, PIN_CUENTA, PIN_PERIODO, PIN_MES) LOOP

                      update BANCOS_ESTADOCUENTA 
                        set                            
                            M_LIBRO = i.j_libro,
                            M_CUENTA = i.b_cuenta,
                            M_PERIODO = i.j_periodo,
                            M_MES = i.j_mes,
                            M_ASIENTO = i.j_asiento,
                            M_ITEM = i.j_item,
                            M_SITEM = i.j_sitem,
                            SWCHKCONCILIA = 'S'
                       where ID_CIA = pin_id_cia 
                       and B_PERIODO = i.b_periodo
                       and B_MES = i.b_mes
                       and B_CUENTA = i.b_cuenta
                       and B_NUMITE = i.B_NUMITE;

                        -- actualiza campo SWCHKCONCILIA de tbl movimientos
                        update Movimientos
                        set
                            SWCHKCONCILIA = 'S'
                        where  ID_CIA = pin_id_cia
                        and PERIODO = i.j_periodo
                        and MES = i.j_mes
                        and LIBRO = i.j_libro
                        and ASIENTO = i.j_asiento
                        and ITEM = i.j_item
                        and SITEM = i.j_sitem;

    END LOOP;


END SB_CONCILIAR;

/
