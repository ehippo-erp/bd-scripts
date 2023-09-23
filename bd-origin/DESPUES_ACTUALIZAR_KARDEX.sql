--------------------------------------------------------
--  DDL for Trigger DESPUES_ACTUALIZAR_KARDEX
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ACTUALIZAR_KARDEX" AFTER
    UPDATE ON usr_tsi_suite.kardex
    FOR EACH ROW
DECLARE
    v_compra  DATE;
    v_mensaje VARCHAR2(1000 CHAR);
BEGIN
--    dbms_output.put_line('DESPUES DE ACTUALIZAR KARDEX');
    IF
        :new.id = 'I'
        AND :new.tipdoc = 103
        AND :new.codmot IN ( 1, 28 )
        AND :new.cantid > 0
    THEN
--        dbms_output.put_line('ANALIZANDO COSTO DE REPOSICION');
        pack_articulos_costo_reposicion.sp_actualizar(:new.id_cia, :new.tipinv, :new.codart, :new.codadd01,
                                                     :new.codadd02, :new.cantid, :new.costot01, :new.costot02, :new.femisi,
                                                     v_mensaje);

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ACTUALIZAR_KARDEX" ENABLE;
