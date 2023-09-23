--------------------------------------------------------
--  DDL for Procedure SP000_ACTUALIZA_CIERRE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_ACTUALIZA_CIERRE" (
    pid_id_cia   IN  NUMBER,
    pid_sistema  IN  NUMBER,
    pid_periodo  IN  NUMBER,
    pid_usuario  IN  VARCHAR2,
    pid_cierr00  IN  NUMBER,
    pid_cierr01  IN  NUMBER,
    pid_cierr02  IN  NUMBER,
    pid_cierr03  IN  NUMBER,
    pid_cierr04  IN  NUMBER,
    pid_cierr05  IN  NUMBER,
    pid_cierr06  IN  NUMBER,
    pid_cierr07  IN  NUMBER,
    pid_cierr08  IN  NUMBER,
    pid_cierr09  IN  NUMBER,
    pid_cierr10  IN  NUMBER,
    pid_cierr11  IN  NUMBER,
    pid_cierr12  IN  NUMBER
) AS
BEGIN
    UPDATE cierre
    SET
        cierre = pid_cierr00,
        usuario = pid_usuario
    WHERE
            id_cia = pid_id_cia
        AND sistema = pid_sistema
        AND periodo = pid_periodo
        AND mes = 00;

    UPDATE cierre
    SET
        cierre = pid_cierr01,
        usuario = pid_usuario
    WHERE
            id_cia = pid_id_cia
        AND sistema = pid_sistema
        AND periodo = pid_periodo
        AND mes = 01;

    UPDATE cierre
    SET
        cierre = pid_cierr02,
        usuario = pid_usuario
    WHERE
            id_cia = pid_id_cia
        AND sistema = pid_sistema
        AND periodo = pid_periodo
        AND mes = 02;

    UPDATE cierre
    SET
        cierre = pid_cierr03,
        usuario = pid_usuario
    WHERE
            id_cia = pid_id_cia
        AND sistema = pid_sistema
        AND periodo = pid_periodo
        AND mes = 03;

    UPDATE cierre
    SET
        cierre = pid_cierr04,
        usuario = pid_usuario
    WHERE
            id_cia = pid_id_cia
        AND sistema = pid_sistema
        AND periodo = pid_periodo
        AND mes = 04;

    UPDATE cierre
    SET
        cierre = pid_cierr05,
        usuario = pid_usuario
    WHERE
            id_cia = pid_id_cia
        AND sistema = pid_sistema
        AND periodo = pid_periodo
        AND mes = 05;

    UPDATE cierre
    SET
        cierre = pid_cierr06,
        usuario = pid_usuario
    WHERE
            id_cia = pid_id_cia
        AND sistema = pid_sistema
        AND periodo = pid_periodo
        AND mes = 06;

    UPDATE cierre
    SET
        cierre = pid_cierr07,
        usuario = pid_usuario
    WHERE
            id_cia = pid_id_cia
        AND sistema = pid_sistema
        AND periodo = pid_periodo
        AND mes = 07;

    UPDATE cierre
    SET
        cierre = pid_cierr08,
        usuario = pid_usuario
    WHERE
            id_cia = pid_id_cia
        AND sistema = pid_sistema
        AND periodo = pid_periodo
        AND mes = 08;

    UPDATE cierre
    SET
        cierre = pid_cierr09,
        usuario = pid_usuario
    WHERE
            id_cia = pid_id_cia
        AND sistema = pid_sistema
        AND periodo = pid_periodo
        AND mes = 09;

    UPDATE cierre
    SET
        cierre = pid_cierr10,
        usuario = pid_usuario
    WHERE
            id_cia = pid_id_cia
        AND sistema = pid_sistema
        AND periodo = pid_periodo
        AND mes = 10;

    UPDATE cierre
    SET
        cierre = pid_cierr11,
        usuario = pid_usuario
    WHERE
            id_cia = pid_id_cia
        AND sistema = pid_sistema
        AND periodo = pid_periodo
        AND mes = 11;

    UPDATE cierre
    SET
        cierre = pid_cierr12,
        usuario = pid_usuario
    WHERE
            id_cia = pid_id_cia
        AND sistema = pid_sistema
        AND periodo = pid_periodo
        AND mes = 12;

    COMMIT;
END sp000_actualiza_cierre;

/
