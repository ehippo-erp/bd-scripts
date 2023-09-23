--------------------------------------------------------
--  DDL for Package Body PACK_CAJA_BANCOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CAJA_BANCOS" AS
    --SP000_CAJA_BANCOS_DETALLE_CUENTA_CORRIENTE
    FUNCTION sp_detalle_cuenta (
        pin_id_cia    NUMBER,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_swdetalle VARCHAR2
    ) RETURN datatable_cuenta_corriente
        PIPELINED
    AS
        rec     datarecord_cuenta_corriente;
        v_count NUMBER;
    BEGIN
        FOR i IN (
            SELECT
                p.cuenta,
                p.nombre,
                p.moneda01,
                tb.descri   AS entidadfin,
                tb.cuenta   AS cuentaban,
                tb.codsunat AS codsunban,
                mo.desmon
            FROM
                     pcuentas p
                INNER JOIN pcuentas_clase pc ON pc.id_cia = p.id_cia
                                                AND pc.cuenta = p.cuenta
                                                AND pc.clase = 2
                                                AND pc.swflag = 'S'
                LEFT OUTER JOIN tbancos        tb ON tb.id_cia = p.id_cia
                                              AND tb.codban = pc.vstrg
                INNER JOIN tmoneda        mo ON mo.id_cia = p.id_cia
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
                )
        ) LOOP
            rec.cuenta := i.cuenta;
            rec.nombre := i.nombre;
            rec.moneda01 := i.moneda01;
            rec.entidadfin := i.entidadfin;
            rec.cuentaban := i.cuentaban;
            rec.codsunban := i.codsunban;
            rec.desmon := i.desmon;
            BEGIN
                SELECT
                    COUNT(cuenta)
                INTO v_count
                FROM
                    movimientos
                WHERE
                        id_cia = pin_id_cia
                    AND cuenta = rec.cuenta
                    AND periodo = pin_periodo
                    AND mes = pin_mes;

            EXCEPTION
                WHEN no_data_found THEN
                    v_count := 0;
            END;

            rec.cuentam := NULL;
            rec.nombrem := NULL;
            rec.periodo := NULL;
            rec.mes := NULL;
            rec.libro := NULL;
            rec.asiento := NULL;
            rec.item := NULL;
            rec.sitem := NULL;
            rec.topera := NULL;
            rec.fecha := NULL;
            rec.dh := NULL;
            rec.fdocum := NULL;
            rec.concep := NULL;
            rec.serie := NULL;
            rec.numero := NULL;
            rec.debe01 := NULL;
            rec.haber01 := NULL;
            rec.debe02 := NULL;
            rec.haber02 := NULL;
            rec.razon := NULL;
            rec.codope1 := NULL;
            rec.codope2 := NULL;
            rec.cuenta_ref := NULL;
            rec.nombre_ref := NULL;
            IF ( v_count = 0 ) THEN
                PIPE ROW ( rec );
            ELSE
                BEGIN
                    FOR e IN (
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
                            CASE
                                WHEN m.numero = ''
                                     OR m.numero IS NULL THEN
                                    h.referencia
                                ELSE
                                    m.numero
                            END AS numero,
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
                            (
                                SELECT
                                    ajustado
                                FROM
                                    pack_ayuda_general.sp_ajusta_string(m.libro, 02, '0', 'R')
                            )
                            || '-'
                            || (
                                SELECT
                                    ajustado
                                FROM
                                    pack_ayuda_general.sp_ajusta_string(m.asiento, 05, '0', 'R')
                            )   AS codope1,
                            (
                                SELECT
                                    ajustado
                                FROM
                                    pack_ayuda_general.sp_ajusta_string(i.codsunban, 02, '0', 'R')
                            )
                            || '-'
                            || (
                                SELECT
                                    ajustado
                                FROM
                                    pack_ayuda_general.sp_ajusta_string(m.asiento, 05, '0', 'R')
                            )   AS codope2
                        FROM
                            movimientos m
                            LEFT OUTER JOIN pcuentas    p ON p.id_cia = m.id_cia
                                                          AND p.cuenta = m.cuenta
                            LEFT OUTER JOIN asienhea    h ON h.id_cia = m.id_cia
                                                          AND h.libro = m.libro
                                                          AND h.periodo = m.periodo
                                                          AND h.mes = m.mes
                                                          AND h.asiento = m.asiento
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
                                        id_cia = m.id_cia
                                    AND periodo = m.periodo
                                    AND mes = m.mes
                                    AND libro = m.libro
                                    AND asiento = m.asiento
                                    AND cuenta = i.cuenta
                            ) ) )
                                  OR ( m.cuenta = i.cuenta ) )
                    ) LOOP
                        rec.cuentam := e.cuenta;
                        rec.nombrem := e.nombre;
                        rec.periodo := e.periodo;
                        rec.mes := e.mes;
                        rec.libro := e.libro;
                        rec.asiento := e.asiento;
                        rec.item := e.item;
                        rec.sitem := e.sitem;
                        rec.topera := e.topera;
                        rec.fecha := e.fecha;
                        rec.dh := e.dh;
                        rec.fdocum := e.fdocum;
                        rec.concep := e.concep;
                        rec.numero := e.numero;
                        rec.debe01 := e.debe01;
                        rec.haber01 := e.haber01;
                        rec.debe02 := e.debe02;
                        rec.haber02 := e.haber02;
                        rec.razon := e.razon;
                        rec.codope1 := e.codope1;
                        rec.codope2 := e.codope2;
                        BEGIN
                            IF ( pin_swdetalle <> 'S' ) THEN
                                FOR j IN (
                                    SELECT
                                        m1.cuenta,
                                        p1.nombre
                                    FROM
                                        asiendet m1
                                        LEFT OUTER JOIN pcuentas p1 ON p1.id_cia = m1.id_cia
                                                                       AND p1.cuenta = m1.cuenta
                                    WHERE
                                            m1.id_cia = pin_id_cia
                                        AND m1.periodo = pin_periodo
                                        AND m1.mes = pin_mes
                                        AND m1.libro = rec.libro
                                        AND m1.asiento = rec.asiento
                                        AND m1.cuenta <> rec.cuenta
                                        AND m1.dh <> rec.dh
                                        AND m1.sitem = 0
                                    FETCH NEXT 1 ROWS ONLY
                                ) LOOP
                        --ROWS 1 TO 1 TOP 1
                                    rec.cuenta_ref := j.cuenta;
                                    rec.nombre_ref := j.nombre;
                                END LOOP;
                            END IF;

                            IF (
                                ( rec.cuentam LIKE '104%' )
                                AND ( rec.cuentam <> rec.cuenta )
                            ) THEN
                                rec.numero := '';
                                NULL;
                            END IF;

                            PIPE ROW ( rec );
                        END;

                    END LOOP;

                END;
            END IF;

            FOR h IN (
                SELECT
                    i.cuenta     AS cuenta,
                    i.nombre     AS nombre,
                    a.periodo,
                    a.mes,
                    a.libro,
                    a.asiento,
                    1            AS item,
                    0            AS sitem,
                    NULL         AS topera,
                    a.fecha,
                    NULL         AS dh,
                    a.fecha      AS fdocum,
                    a.concep,
                    NULL         AS serie,
                    a.referencia AS numero,
                    0            AS debe01,
                    0            AS haber01,
                    0            AS debe02,
                    0            AS haber02,
                    a.girara     AS razon,
                    (
                        SELECT
                            ajustado
                        FROM
                            pack_ayuda_general.sp_ajusta_string(a.libro, 02, '0', 'R')
                    )
                    || '-'
                    || (
                        SELECT
                            ajustado
                        FROM
                            pack_ayuda_general.sp_ajusta_string(a.asiento, 05, '0', 'R')
                    )            AS codope1,
                    (
                        SELECT
                            ajustado
                        FROM
                            pack_ayuda_general.sp_ajusta_string(i.codsunban, 02, '0', 'R')
                    )
                    || '-'
                    || (
                        SELECT
                            ajustado
                        FROM
                            pack_ayuda_general.sp_ajusta_string(a.asiento, 05, '0', 'R')
                    )            AS codope2
                FROM
                    asienhea a
                    LEFT OUTER JOIN tbancos  b ON b.id_cia = a.id_cia
                                                 AND b.codban = a.codban
                WHERE
                        a.id_cia = pin_id_cia
                    AND a.periodo = pin_periodo
                    AND a.mes = pin_mes
                    AND a.libro = '50'
                    AND a.situac = 9
                    AND a.referencia <> '0'
                    AND a.referencia <> ''
                    AND b.cuentacon = i.cuenta
            ) LOOP
                rec.cuentam := h.cuenta;
                rec.nombrem := h.nombre;
                rec.periodo := h.periodo;
                rec.mes := h.mes;
                rec.libro := h.libro;
                rec.asiento := h.asiento;
                rec.item := h.item;
                rec.sitem := h.sitem;
                rec.topera := h.topera;
                rec.fecha := h.fecha;
                rec.dh := h.dh;
                rec.fdocum := h.fdocum;
                rec.concep := h.concep;
                rec.numero := h.numero;
                rec.debe01 := h.debe01;
                rec.haber01 := h.haber01;
                rec.debe02 := h.debe02;
                rec.haber02 := h.haber02;
                rec.razon := h.razon;
                rec.codope1 := h.codope1;
                rec.codope2 := h.codope2;
                PIPE ROW ( rec );
            END LOOP;

        END LOOP;
    END sp_detalle_cuenta;

END;

/
