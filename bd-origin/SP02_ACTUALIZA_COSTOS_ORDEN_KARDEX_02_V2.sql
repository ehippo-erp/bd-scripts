--------------------------------------------------------
--  DDL for Procedure SP02_ACTUALIZA_COSTOS_ORDEN_KARDEX_02_V2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP02_ACTUALIZA_COSTOS_ORDEN_KARDEX_02_V2" (
    pin_id_cia  IN  NUMBER,
    pin_tipdoc  IN  NUMBER,
    pin_series  IN  VARCHAR2,
    pin_numdoc  IN  NUMBER
) AS

    CURSOR cur_costos_orden_kardex IS
    SELECT
        d.tipmon                                            AS moneda,
        d.series,
        d.numdoc,
        d.numint,
        EXTRACT(YEAR FROM CAST(d.femisi AS DATE))           AS ano,
        EXTRACT(MONTH FROM CAST(d.femisi AS DATE))          AS mes
    FROM
        documentos_cab d
    WHERE
        ( d.id_cia = pin_id_cia )
        AND ( d.tipdoc = pin_tipdoc )
        AND ( upper(d.situac) <> 'J' )
        AND ( upper(d.situac) <> 'K' )
        AND ( d.id = 'I' )
        AND ( d.codmot = 28 )
        AND d.series = pin_series
        AND d.numdoc = pin_numdoc
    ORDER BY
        d.series,
        d.numdoc;

    v_mon01    VARCHAR2(5);
    v_mon02    VARCHAR2(5);
    v_tcostot  NUMERIC(16, 3);
--    v_ttotal NUMERIC(16, 3);
    v_cierre   INTEGER;
BEGIN
    BEGIN
        SELECT
            TRIM(moneda01),
            TRIM(moneda02)
        INTO
            v_mon01,
            v_mon02
        FROM
            companias
        WHERE
            cia = pin_id_cia;

    EXCEPTION
        WHEN no_data_found THEN
            v_mon01 := NULL;
            v_mon02 := NULL;
    END;

    FOR registro IN cur_costos_orden_kardex LOOP
        v_cierre := 1;
    /* 2014-05-06  -> DEBE COMPROBAR QUE LOGISTICA ESTE ABIERTO NO CONTABILIDAD           */
        BEGIN
            SELECT
                cierre
            INTO v_cierre
            FROM
                cierre
            WHERE
                    id_cia = pin_id_cia
                AND sistema = 4
                AND periodo = registro.ano
                AND mes = registro.mes;

        EXCEPTION
            WHEN no_data_found THEN
                v_cierre := 1;
        END;

        IF ( v_cierre = 1 ) THEN
            RAISE pkg_exceptionuser.ex_mes_cerrado_logistica;
        END IF;
        IF ( v_cierre = 0 ) THEN
 --           v_ttotal := 0;
            FOR reg_ordimport02_v2 IN (
                SELECT
                    c.numite,
                    c.tipcam,
                    c.tcostotsol,
                    c.tcostotdol
                FROM
                    TABLE ( sp01_costos_orden_importacion_02_v2(pin_id_cia, pin_tipdoc, registro.series, registro.numdoc) ) c
                WHERE
                    c.numint = registro.numint
            ) LOOP
                UPDATE kardex
                SET
                    costot01 = reg_ordimport02_v2.tcostotsol,
                    costot02 = reg_ordimport02_v2.tcostotdol
                WHERE
                        id_cia = pin_id_cia
                    AND numint = registro.numint
                    AND numite = reg_ordimport02_v2.numite;

                IF ( registro.moneda = v_mon01 ) THEN
                    v_tcostot := reg_ordimport02_v2.tcostotsol;
                END IF;

                IF ( registro.moneda = v_mon02 ) THEN
                    v_tcostot := reg_ordimport02_v2.tcostotdol;
                END IF;

                COMMIT;
--                v_ttotal := v_ttotal + v_tcostot;
                      /* SOLO SE CORRIGE LO NESCESARIO PARA RE-ENVIARLO AL KARDEX SI FUERA NESCESARIO */
                UPDATE documentos_det
                SET
                    preuni = v_tcostot / cantid,
                    pordes1 = 0,
                    pordes2 = 0,
                    pordes3 = 0,
                    pordes4 = 0,
                    monina = v_tcostot,
                    monafe = 0,
                    monigv = 0,
                    importe_bruto = v_tcostot,
                    importe = v_tcostot
                WHERE
                        id_cia = pin_id_cia
                    AND numint = registro.numint
                    AND numite = reg_ordimport02_v2.numite;

                COMMIT;
            END LOOP;
        END IF;

        UPDATE documentos_cab c
        SET
            preven = (
                SELECT
                    SUM(importe)
                FROM
                    documentos_det
                WHERE
                        id_cia = pin_id_cia
                    AND numint = c.numint
            )
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = registro.numint;

        COMMIT;
    END LOOP;

EXCEPTION
    WHEN pkg_exceptionuser.ex_mes_cerrado_logistica THEN
        raise_application_error(pkg_exceptionuser.mes_cerrado_logistica, 'Mes cerrado en módulo logística');
END sp02_actualiza_costos_orden_kardex_02_v2;

/
