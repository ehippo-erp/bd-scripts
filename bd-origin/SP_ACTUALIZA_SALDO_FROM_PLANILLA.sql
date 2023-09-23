--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_SALDO_FROM_PLANILLA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_SALDO_FROM_PLANILLA" (
    pin_id_cia  IN  NUMBER,
    pin_libro  IN  VARCHAR2,
    pin_periodo  IN  NUMBER,
    pin_mes  IN  NUMBER,
    pin_secuencia  IN  NUMBER
) AS

    CURSOR rec_cxc (  
        v_id_cia NUMBER, 
        v_libro VARCHAR2,
        v_periodo NUMBER,
        v_mes NUMBER,
        v_secuencia NUMBER) IS 
    select numint 
    from dcta103    
    where id_cia = v_id_cia and
          libro = v_libro and
          periodo = v_periodo and
          mes = v_mes and
          secuencia = v_secuencia
    union all
    select numint 
    from dcta113    
    where id_cia = v_id_cia and
          libro = v_libro and
          periodo = v_periodo and
          mes = v_mes and
          secuencia = v_secuencia;

    CURSOR rec_cxp (  
        v_id_cia NUMBER, 
        v_libro VARCHAR2,
        v_periodo NUMBER,
        v_mes NUMBER,
        v_secuencia NUMBER) IS 
    select tipo,docu 
    from prov103    
    where id_cia = v_id_cia and
          libro = v_libro and
          periodo = v_periodo and
          mes = v_mes and
          secuencia = v_secuencia
    union all
    select tipo,docu 
    from prov113    
    where id_cia = v_id_cia and
          libro = v_libro and
          periodo = v_periodo and
          mes = v_mes and
          secuencia = v_secuencia;          
BEGIN
    FOR record IN rec_cxc(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia) LOOP
        sp_actualiza_saldo_dcta100(pin_id_cia, record.numint);
        COMMIT;
    END LOOP;

    FOR record IN rec_cxp(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia) LOOP
        sp_actualiza_saldo_prov100(pin_id_cia, record.tipo, record.docu);
        COMMIT;
    END LOOP;

END sp_actualiza_saldo_from_planilla;

/
