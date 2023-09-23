--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_PLACA_ETIQUETA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_PLACA_ETIQUETA" (
    pin_id_cia   IN INTEGER,
    pin_etiqueta IN VARCHAR2,
    pin_placa    IN VARCHAR2,
    pin_mensaje  OUT VARCHAR2
) AS
BEGIN
    UPDATE kardex000
    SET
        placa = pin_placa
    WHERE
            id_cia = pin_id_cia
        AND etiqueta = pin_etiqueta;
    COMMIT;
    pin_mensaje := 'Proceso de actualización realizado correctamente ...!';
EXCEPTION
    WHEN value_error THEN
        pin_mensaje := ' Formato Incorrecto, No se puede resgistrar ['
                       || pin_placa
                       || '] porque la base de datos no soporta este formato';
    WHEN no_data_found THEN
        pin_mensaje := ' No se encontraron resgistros para actualizar ['
                       || pin_placa
                       || ']';
    WHEN OTHERS THEN
        pin_mensaje := 'Error al actualizar los datos : '
                       || sqlerrm
                       || ' codigo :'
                       || sqlcode;
END;

/
