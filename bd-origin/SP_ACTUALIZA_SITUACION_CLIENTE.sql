--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_SITUACION_CLIENTE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_SITUACION_CLIENTE" (
    pin_id_cia IN NUMBER
) AS
BEGIN
    FOR i IN (
        SELECT
            c.codcli,
            c.tident,
            c.dident,
            cl.clase
        FROM
            cliente        c
            LEFT OUTER JOIN cliente_clase  cl ON cl.id_cia = c.id_cia
                                                AND cl.codcli = c.codcli
                                                AND cl.tipcli = 'A'
                                                AND cl.clase = 1
        WHERE
                c.id_cia = pin_id_cia
            AND cl.clase IS NULL
    ) LOOP
        INSERT INTO cliente_clase (
            id_cia,
            tipcli,
            codcli,
            clase,
            codigo,
            situac
        ) VALUES (
            pin_id_cia,
            'A',
            i.codcli,
            1,
            '1',
            'S'
        );

    END LOOP;
END sp_actualiza_situacion_cliente;

/
