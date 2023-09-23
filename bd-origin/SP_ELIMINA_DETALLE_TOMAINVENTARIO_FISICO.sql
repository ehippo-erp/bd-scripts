--------------------------------------------------------
--  DDL for Procedure SP_ELIMINA_DETALLE_TOMAINVENTARIO_FISICO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ELIMINA_DETALLE_TOMAINVENTARIO_FISICO" (
    pin_id_cia   IN   NUMBER,
    pin_numint   IN   NUMBER
) AS
BEGIN
    DELETE FROM kardex
    WHERE
        id_cia = pin_id_cia
        AND numint = pin_numint;

    COMMIT;
    DELETE FROM documentos_det
    WHERE
        id_cia = pin_id_cia
        AND numint = pin_numint;

    COMMIT;
  /* CAMBIA SITUACION  A = EN EMITIDA*/
    UPDATE documentos_cab
    SET
        situac = 'A'
    WHERE
        id_cia = pin_id_cia
        AND numint = pin_numint;

    COMMIT;
END sp_elimina_detalle_tomaInventario_fisico;

/
