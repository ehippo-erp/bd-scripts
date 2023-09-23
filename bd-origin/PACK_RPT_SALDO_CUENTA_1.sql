--------------------------------------------------------
--  DDL for Package Body PACK_RPT_SALDO_CUENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_RPT_SALDO_CUENTA" AS

    FUNCTION sp_anual (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_cdesde  VARCHAR2,
        pin_chasta  VARCHAR2,
        pin_nivel   NUMBER
    ) RETURN datatable_anual
        PIPELINED
    AS

        v_table      datatable_anual;
        CURSOR cur_select (
            plargodesde NUMBER,
            plargohasta NUMBER
        ) IS
        SELECT
            p.cuenta,
            p.nombre
        FROM
            pcuentas p
        WHERE
                p.id_cia = pin_id_cia
            AND p.nivel = pin_nivel
            AND ( plargodesde = 0
                  OR substr(p.cuenta, 1, plargodesde) >= pin_cdesde )
            AND ( plargohasta = 0
                  OR substr(p.cuenta, 1, plargohasta) <= pin_chasta )
        ORDER BY
            p.cuenta;

        v_largodesde NUMBER := 0;
        v_largohasta NUMBER := 0;
        v_cdesde     VARCHAR2(40) := '';
        v_chasta     VARCHAR2(40) := '';
    BEGIN
        IF pin_cdesde IS NOT NULL THEN
            v_largodesde := length(pin_cdesde);
        ELSE
            v_largodesde := 0;
        END IF;

        IF pin_chasta IS NOT NULL THEN
            v_largohasta := length(pin_chasta);
        ELSE
            v_largohasta := 0;
        END IF;

        FOR registro IN cur_select(v_largodesde, v_largohasta) LOOP
            SELECT
                m.id_cia,
                m.cuenta,
                p.nombre,
                SUM(nvl(m.saldo0001, 0)) AS enero_apertura,
                SUM(nvl(m.saldo0101, 0)) AS enero,
                SUM(nvl(m.saldo0201, 0)) AS febrero,
                SUM(nvl(m.saldo0301, 0)) AS marzo,
                SUM(nvl(m.saldo0401, 0)) AS abril,
                SUM(nvl(m.saldo0501, 0)) AS mayo,
                SUM(nvl(m.saldo0601, 0)) AS junio,
                SUM(nvl(m.saldo0701, 0)) AS julio,
                SUM(nvl(m.saldo0801, 0)) AS agosto,
                SUM(nvl(m.saldo0901, 0)) AS septiembre,
                SUM(nvl(m.saldo1001, 0)) AS octubre,
                SUM(nvl(m.saldo1101, 0)) AS noviembre,
                SUM(nvl(m.saldo1201, 0)) AS diciembre,
                SUM(nvl(m.saldo9901, 0)) AS total,
                SUM(nvl(m.saldo0002, 0)) AS enero_apertura,
                SUM(nvl(m.saldo0102, 0)) AS enero,
                SUM(nvl(m.saldo0202, 0)) AS febrero,
                SUM(nvl(m.saldo0302, 0)) AS marzo,
                SUM(nvl(m.saldo0402, 0)) AS abril,
                SUM(nvl(m.saldo0502, 0)) AS mayo,
                SUM(nvl(m.saldo0602, 0)) AS junio,
                SUM(nvl(m.saldo0702, 0)) AS julio,
                SUM(nvl(m.saldo0802, 0)) AS agosto,
                SUM(nvl(m.saldo0902, 0)) AS septiembre,
                SUM(nvl(m.saldo1002, 0)) AS octubre,
                SUM(nvl(m.saldo1102, 0)) AS noviembre,
                SUM(nvl(m.saldo1202, 0)) AS diciembre,
                SUM(nvl(m.saldo9902, 0)) AS total
            BULK COLLECT
            INTO v_table
            FROM
                movimientos_acumulados m
                LEFT OUTER JOIN pcuentas               p ON p.id_cia = m.id_cia
                                              AND p.cuenta = m.cuenta
            WHERE
                    m.id_cia = pin_id_cia
                AND m.periodo = pin_periodo
                AND m.cuenta LIKE registro.cuenta || '%'
            GROUP BY
                m.id_cia,
                m.cuenta,
                p.nombre;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        END LOOP;

    END sp_anual;

END;

/
