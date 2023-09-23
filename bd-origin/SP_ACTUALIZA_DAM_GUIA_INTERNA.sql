--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_DAM_GUIA_INTERNA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_DAM_GUIA_INTERNA" (
    pin_id_cia  IN INTEGER,
    pin_numint  IN NUMBER,
    pin_dam     IN VARCHAR2,
    pin_mensaje OUT VARCHAR2
) AS
BEGIN
    FOR i IN (
        SELECT
            d.tipinv,
            d.codart,
            d.etiqueta
        FROM
                 documentos_det d
            INNER JOIN articulos a ON a.id_cia = d.id_cia
                                      AND a.tipinv = d.tipinv
                                      AND a.codart = d.codart
                                      AND a.consto = 8
        WHERE
                d.id_cia = pin_id_cia
            AND d.numint = pin_numint
            AND d.etiqueta IS NOT NULL 
            AND TRIM(LENGTH(d.etiqueta)) > 0
    ) LOOP
        UPDATE kardex000
        SET
            dam = pin_dam
        WHERE
                id_cia = pin_id_cia
            AND etiqueta = i.etiqueta;
            COMMIT;
    END LOOP;
    pin_mensaje := 'Proceso de actualización realizado correctamente ...!';
EXCEPTION
    WHEN value_error THEN
        pin_mensaje := ' Formato Incorrecto, No se puede resgistrar ['
                       || pin_dam
                       || '] porque la base de datos no soporta este formato';
    WHEN OTHERS THEN
        pin_mensaje := 'Error al actualizar los datos : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
END;

/
