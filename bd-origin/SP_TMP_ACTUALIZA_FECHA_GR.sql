--------------------------------------------------------
--  DDL for Procedure SP_TMP_ACTUALIZA_FECHA_GR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_TMP_ACTUALIZA_FECHA_GR" (
    pin_id_cia   NUMBER,
    pin_fini     DATE,
    pin_ffin     DATE,
    pin_fcambio  DATE
) AS

    CURSOR cur_guias (
        pnumint  NUMBER,
        pfini    DATE,
        pffin    DATE
    ) IS
    SELECT DISTINCT
        c.numint
    FROM
        documentos_cab              c
        LEFT OUTER JOIN documentos_cab_envio_sunat  s ON s.id_cia = c.id_cia
                                                        AND s.numint = c.numint
    WHERE
            c.id_cia = pin_id_cia
        AND c.tipdoc = 102
        AND c.series LIKE 'T%'
        AND c.femisi BETWEEN pfini AND pffin
        AND c.situac IN (
            'F',
            'C'
        )
        AND c.numdoc > 0
        AND s.estado IN (
            0,
            2
        );

    v_numint INTEGER;
BEGIN
    FOR i IN cur_guias(pin_id_cia, pin_fini, pin_ffin) LOOP
        UPDATE documentos_cab
        SET
            femisi = pin_fcambio
        WHERE
                id_cia = pin_id_cia
            AND numint = i.numint;

        COMMIT;
    END LOOP;
END;

/
