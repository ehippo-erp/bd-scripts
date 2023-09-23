--------------------------------------------------------
--  DDL for Procedure SP_ANULA_MANTENER_ASIENTO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ANULA_MANTENER_ASIENTO" (
    pin_id_cia    IN   INTEGER,
    pin_periodo   IN   INTEGER,
    pin_mes       IN   INTEGER,
    pin_libro     IN   VARCHAR2,
    pin_asiento   IN   INTEGER,
    pin_coduser   IN   VARCHAR2
) AS
BEGIN
   /*ELIMINA MOVIMIENTOS*/
    sp_delete_movimientos_por_asiento(pin_id_cia, pin_periodo, pin_mes, pin_libro, pin_asiento);
    sp_delete_asiendet_por_asiento(pin_id_cia, pin_periodo, pin_mes, pin_libro, pin_asiento);

   /* 9 = ANULADO */
    UPDATE asienhea
    SET
        situac = 9,
        usuari = pin_coduser,
        fcreac = current_timestamp,
        factua = current_timestamp
    WHERE
        id_cia = pin_id_cia
        AND ( periodo = pin_periodo )
        AND ( mes = pin_mes )
        AND ( libro = pin_libro )
        AND ( asiento = pin_asiento );

    COMMIT;
END sp_anula_mantener_asiento;

/
