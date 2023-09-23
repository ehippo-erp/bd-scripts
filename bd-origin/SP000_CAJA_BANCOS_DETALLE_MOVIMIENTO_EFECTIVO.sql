--------------------------------------------------------
--  DDL for Function SP000_CAJA_BANCOS_DETALLE_MOVIMIENTO_EFECTIVO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_CAJA_BANCOS_DETALLE_MOVIMIENTO_EFECTIVO" (
    pin_id_cia     NUMBER,
    pin_periodo    NUMBER,
    pin_mes        VARCHAR2,
    pin_swdetalle  VARCHAR2
) RETURN tbl_caja_bancos_detalle_movimiento_efectivo
    PIPELINED
AS

    v_caja_bancos_detalle_movimiento_efectivo  rec_caja_bancos_detalle_movimiento_efectivo := rec_caja_bancos_detalle_movimiento_efectivo(
    NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL);
    CURSOR cur_select00 IS
    SELECT
        p.cuenta,
        p.nombre,
        p.moneda01,
        tb.descri      AS entidadfin,
        tb.cuenta      AS cuentaban,
        tb.codsunat    AS codsunban,
        mo.desmon
    FROM
             pcuentas p
        INNER JOIN pcuentas_clase  pc ON pc.id_cia = pin_id_cia
                                        AND pc.cuenta = p.cuenta
                                        AND pc.clase = 3
                                        AND pc.swflag = 'S'
        LEFT OUTER JOIN tbancos         tb ON tb.id_cia = pin_id_cia
                                      AND tb.codban = pc.vstrg
        INNER JOIN tmoneda         mo ON mo.id_cia = pin_id_cia
                                 AND mo.codmon = p.moneda01
    WHERE
            p.id_cia = pin_id_cia
        AND EXISTS (
            SELECT
                cuenta
            FROM
                movimientos
            WHERE
                    id_cia = pin_id_cia
                AND cuenta = p.cuenta
                AND periodo = pin_periodo
        );

    CURSOR cur_select01 (
        pcodbansunat  VARCHAR2,
        pcuenta       VARCHAR2
    ) IS
    SELECT
        m.cuenta,
        p.nombre,
        m.periodo,
        m.mes,
        m.libro,
        m.asiento,
        m.item,
        m.sitem,
        m.topera,
        m.fecha,
        m.dh,
        m.fdocum,
        m.concep,
        m.serie,
        m.numero,
        CASE
            WHEN m.debe01 IS NULL THEN
                0
            ELSE
                m.debe01
        END AS debe01,
        CASE
            WHEN m.haber01 IS NULL THEN
                0
            ELSE
                m.haber01
        END AS haber01,
        CASE
            WHEN m.debe02 IS NULL THEN
                0
            ELSE
                m.debe02
        END AS debe02,
        CASE
            WHEN m.haber02 IS NULL THEN
                0
            ELSE
                m.haber02
        END AS haber02,
        m.razon,
        sp000_ajusta_string(m.libro, 02, '0', 'R')
        || '-'
        || sp000_ajusta_string(m.asiento, 05, '0', 'R') AS codope1,
        sp000_ajusta_string(pcodbansunat, 02, '0', 'R')
        || '-'
        || sp000_ajusta_string(m.asiento, 05, '0', 'R') AS codope2
    FROM
        movimientos  m
        LEFT OUTER JOIN pcuentas     p ON p.id_cia = pin_id_cia
                                      AND p.cuenta = m.cuenta
    WHERE
            m.id_cia = pin_id_cia
        AND m.periodo = pin_periodo
        AND m.mes = pin_mes
        AND ( ( ( pin_swdetalle = 'S' )
                AND ( EXISTS (
            SELECT
                cuenta
            FROM
                movimientos
            WHERE
                    id_cia = pin_id_cia
                AND periodo = m.periodo
                AND mes = m.mes
                AND libro = m.libro
                AND asiento = m.asiento
                AND cuenta = pcuenta
        ) ) )
              OR ( m.cuenta = pcuenta ) );

    v_existe                                   NUMBER;
BEGIN
    FOR registro IN cur_select00 LOOP
        v_caja_bancos_detalle_movimiento_efectivo.cuenta := registro.cuenta;
        v_caja_bancos_detalle_movimiento_efectivo.nombre := registro.nombre;
        v_caja_bancos_detalle_movimiento_efectivo.moneda01 := registro.moneda01;
        v_caja_bancos_detalle_movimiento_efectivo.entidadfin := registro.entidadfin;
        v_caja_bancos_detalle_movimiento_efectivo.cuentaban := registro.cuentaban;
        v_caja_bancos_detalle_movimiento_efectivo.codsunban := registro.codsunban;
        v_caja_bancos_detalle_movimiento_efectivo.desmon := registro.desmon;
        /* Imprimiran solo un registro los que no tengan movimiento en el mes */
        v_caja_bancos_detalle_movimiento_efectivo.cuentam := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.nombrem := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.periodo := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.mes := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.libro := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.asiento := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.item := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.sitem := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.topera := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.fecha := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.dh := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.fdocum := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.concep := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.serie := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.numero := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.debe01 := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.haber01 := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.debe02 := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.haber02 := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.razon := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.codope1 := NULL;
        v_caja_bancos_detalle_movimiento_efectivo.codope2 := NULL;
        BEGIN
            SELECT
                COUNT(cuenta)
            INTO v_existe
            FROM
                movimientos
            WHERE
                    id_cia = pin_id_cia
                AND cuenta = registro.cuenta
                AND periodo = pin_periodo
                AND mes = pin_mes;

        EXCEPTION
            WHEN no_data_found THEN
                v_existe := 0;
        END;

        IF ( v_existe = 0 ) THEN
            PIPE ROW ( v_caja_bancos_detalle_movimiento_efectivo );
        ELSE
            FOR reg IN cur_select01(registro.codsunban, registro.cuenta) LOOP
                v_caja_bancos_detalle_movimiento_efectivo.cuentam := reg.cuenta;
                v_caja_bancos_detalle_movimiento_efectivo.nombrem := reg.nombre;
                v_caja_bancos_detalle_movimiento_efectivo.periodo := reg.periodo;
                v_caja_bancos_detalle_movimiento_efectivo.mes := reg.mes;
                v_caja_bancos_detalle_movimiento_efectivo.libro := reg.libro;
                v_caja_bancos_detalle_movimiento_efectivo.asiento := reg.asiento;
                v_caja_bancos_detalle_movimiento_efectivo.item := reg.item;
                v_caja_bancos_detalle_movimiento_efectivo.sitem := reg.sitem;
                v_caja_bancos_detalle_movimiento_efectivo.topera := reg.topera;
                v_caja_bancos_detalle_movimiento_efectivo.fecha := reg.fecha;
                v_caja_bancos_detalle_movimiento_efectivo.dh := reg.dh;
                v_caja_bancos_detalle_movimiento_efectivo.fdocum := reg.fdocum;
                v_caja_bancos_detalle_movimiento_efectivo.concep := reg.concep;
                v_caja_bancos_detalle_movimiento_efectivo.serie := reg.serie;
                v_caja_bancos_detalle_movimiento_efectivo.numero := reg.numero;
                v_caja_bancos_detalle_movimiento_efectivo.debe01 := reg.debe01;
                v_caja_bancos_detalle_movimiento_efectivo.haber01 := reg.haber01;
                v_caja_bancos_detalle_movimiento_efectivo.debe02 := reg.debe02;
                v_caja_bancos_detalle_movimiento_efectivo.haber02 := reg.haber02;
                v_caja_bancos_detalle_movimiento_efectivo.razon := reg.razon;
                v_caja_bancos_detalle_movimiento_efectivo.codope1 := reg.codope1;
                v_caja_bancos_detalle_movimiento_efectivo.codope2 := reg.codope2;
                PIPE ROW ( v_caja_bancos_detalle_movimiento_efectivo );
            END LOOP;
        END IF;

    END LOOP;
END sp000_caja_bancos_detalle_movimiento_efectivo;

/
