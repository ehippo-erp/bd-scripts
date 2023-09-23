--------------------------------------------------------
--  DDL for Procedure SP000_INSERT_MOVIMIENTOS_ACUMULADOS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_INSERT_MOVIMIENTOS_ACUMULADOS" (
    pin_id_cia       NUMBER,
    pin_periodo      NUMBER,
    pin_cuentadesde  VARCHAR2,
    pin_cuentahasta  VARCHAR2
) IS

    v_largodesde   NUMBER := 0;
    v_largohasta   NUMBER := 0;
    v_cuentadesde  VARCHAR2(40) := '';
    v_cuentahasta  VARCHAR2(40) := '';
BEGIN
    IF ( pin_cuentadesde IS NULL ) THEN
        v_cuentadesde := '';
    END IF;
    IF ( pin_cuentahasta IS NULL ) THEN
        v_cuentahasta := '';
    END IF;
    IF ( v_cuentadesde <> '' ) THEN
        v_largodesde := length(pin_cuentadesde);
    END IF;

    IF ( v_cuentahasta <> '' ) THEN
        v_largohasta := length(pin_cuentahasta);
    END IF;

 /* ACTUALIZA TABLA TEMPORAL ACUMULADOS */

    DELETE FROM movimientos_acumulados
    WHERE
        id_cia = pin_id_cia;

    INSERT INTO movimientos_acumulados
        SELECT
            m.id_cia,
            m.periodo,
            m.cuenta,
            SUM(
                CASE
                    WHEN m.mes = 00 THEN
                        m.debe01 - m.haber01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 01 THEN
                        m.debe01 - m.haber01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 02 THEN
                        m.debe01 - m.haber01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 03 THEN
                        m.debe01 - m.haber01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 04 THEN
                        m.debe01 - m.haber01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 05 THEN
                        m.debe01 - m.haber01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 06 THEN
                        m.debe01 - m.haber01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 07 THEN
                        m.debe01 - m.haber01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 08 THEN
                        m.debe01 - m.haber01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 09 THEN
                        m.debe01 - m.haber01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 10 THEN
                        m.debe01 - m.haber01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 11 THEN
                        m.debe01 - m.haber01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 12 THEN
                        m.debe01 - m.haber01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes > - 1 THEN
                        m.debe01 - m.haber01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 00 THEN
                        m.debe02 - m.haber02
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 01 THEN
                        m.debe02 - m.haber02
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 02 THEN
                        m.debe02 - m.haber02
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 03 THEN
                        m.debe02 - m.haber02
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 04 THEN
                        m.debe02 - m.haber02
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 05 THEN
                        m.debe02 - m.haber02
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 06 THEN
                        m.debe02 - m.haber02
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 07 THEN
                        m.debe02 - m.haber02
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 08 THEN
                        m.debe02 - m.haber02
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 09 THEN
                        m.debe02 - m.haber02
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 10 THEN
                        m.debe02 - m.haber02
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 11 THEN
                        m.debe02 - m.haber02
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes = 12 THEN
                        m.debe02 - m.haber02
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN m.mes > - 1 THEN
                        m.debe02 - m.haber02
                    ELSE
                        0
                END
            )
        FROM
            movimientos m
        WHERE
            ( m.id_cia = pin_id_cia )
            AND ( m.periodo = pin_periodo )
            AND ( ( v_largodesde = 0 )
                  OR ( substr2(m.cuenta, 1, v_largodesde) >= v_cuentadesde ) )
            AND ( ( v_largohasta = 0 )
                  OR ( substr(m.cuenta, 1, v_largohasta) <= v_cuentahasta ) )
        GROUP BY
            m.periodo,
            m.cuenta;

END sp000_insert_movimientos_acumulados;

/
