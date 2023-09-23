--------------------------------------------------------
--  DDL for Function SP_MAYOR_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_MAYOR_GENERAL" (
    pin_id_cia   NUMBER,
    pin_periodo  NUMBER,
    pin_mes      NUMBER,
    pin_swlista  NUMBER
) RETURN tbl_mayor_general
    PIPELINED
AS

    v_mayor_general  rec_mayor_general := rec_mayor_general(NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL);
    CURSOR cur_select (
        pcuenta VARCHAR2
    ) IS
    SELECT
        SUM(m.debe01)        AS debe01,
        SUM(m.debe02)        AS debe02,
        SUM(m.haber01)       AS haber01,
        SUM(m.haber02)       AS haber02
    FROM
        movimientos m
    WHERE
            m.id_cia = pin_id_cia
        AND m.periodo = pin_periodo
        AND m.mes < pin_mes
        AND m.cuenta = pcuenta
        AND ( ( pin_swlista IS NULL )
              OR ( pin_swlista = 0 )
              OR ( pin_swlista = 1
                   AND m.libro <> '99' )
              OR ( pin_swlista = 2
                   AND m.libro = '99' ) );

    v_swsalio        VARCHAR2(1);
    v_codsunat       VARCHAR2(10);
    CURSOR cur_select02 (
        pcuenta VARCHAR2
    ) IS
    SELECT
        m.asiento,
        m.libro,
        m.fecha,
        m.codigo,
        m.tdocum,
        m.serie,
        m.numero,
        m.concep,
        m.fdocum,
        m.debe01,
        m.debe02,
        m.haber01,
        m.haber02,
        tc.vstrg AS codsunat
    FROM
        movimientos    m
        LEFT OUTER JOIN tlibros_clase  tc ON ( tc.id_cia = pin_id_cia )
                                            AND ( tc.codlib = m.libro )
                                            AND ( tc.clase = 1 ) /* CLASE TIPO LIBRO SUNAT */
    WHERE
        ( m.id_cia = pin_id_cia )
        AND ( m.periodo = pin_periodo )
        AND ( m.mes = pin_mes )
        AND ( m.cuenta = pcuenta )
        AND ( ( pin_swlista IS NULL )
              OR ( pin_swlista = 0 )
              OR ( pin_swlista = 1
                   AND m.libro <> '99' )
              OR ( pin_swlista = 2
                   AND m.libro = '99' ) )
    ORDER BY
        m.asiento,
        m.libro,
        m.fecha,
        m.codigo,
        m.tdocum,
        m.serie;

BEGIN
    FOR registro IN (
        SELECT
            p.cuenta,
            p.nivel,
            p.nombre
        FROM
            pcuentas p
        WHERE
            id_cia = pin_id_cia
        ORDER BY
            p.cuenta
    ) LOOP
        v_mayor_general.cuenta := registro.cuenta;
        v_mayor_general.nivel := registro.nivel;
        v_mayor_general.nombre := registro.nombre;
        v_mayor_general.debe01 := 0;
        v_mayor_general.debe02 := 0;
        v_mayor_general.haber01 := 0;
        v_mayor_general.haber02 := 0;
        v_swsalio := 'N';
        v_codsunat := 'X';
        v_mayor_general.codsunat2 := '';
        v_mayor_general.libro2 := '';
        v_mayor_general.asiento2 := '';
        v_mayor_general.codope2 := '';
        v_mayor_general.tinidebe01 := 0;
        v_mayor_general.tinidebe02 := 0;
        v_mayor_general.tinihaber01 := 0;
        v_mayor_general.tinihaber02 := 0;
        FOR registro2 IN cur_select(registro.cuenta) LOOP
            v_mayor_general.tinidebe01 := registro2.debe01;
            v_mayor_general.tinidebe02 := registro2.debe02;
            v_mayor_general.tinihaber01 := registro2.haber01;
            v_mayor_general.tinihaber02 := registro2.haber02;
        END LOOP;

        IF ( v_mayor_general.tinidebe01 IS NULL ) THEN
            v_mayor_general.tinidebe01 := 0;
        END IF;

        IF ( v_mayor_general.tinidebe02 IS NULL ) THEN
            v_mayor_general.tinidebe02 := 0;
        END IF;

        IF ( v_mayor_general.tinihaber01 IS NULL ) THEN
            v_mayor_general.tinihaber01 := 0;
        END IF;

        IF ( v_mayor_general.tinihaber02 IS NULL ) THEN
            v_mayor_general.tinihaber02 := 0;
        END IF;

        FOR registro03 IN cur_select02(registro.cuenta) LOOP
            v_mayor_general.asiento := registro03.asiento;
            v_mayor_general.libro := registro03.libro;
            v_mayor_general.fecha := registro03.fecha;
            v_mayor_general.codigo := registro03.codigo;
            v_mayor_general.tdocum := registro03.tdocum;
            v_mayor_general.serie := registro03.serie;
            v_mayor_general.numero := registro03.numero;
            v_mayor_general.concep := registro03.concep;
            v_mayor_general.fdocum := registro03.fdocum;
            v_mayor_general.debe01 := registro03.debe01;
            v_mayor_general.debe02 := registro03.debe02;
            v_mayor_general.haber01 := registro03.haber01;
            v_mayor_general.haber02 := registro03.haber02;
            v_mayor_general.codsunat := registro03.codsunat;
            v_mayor_general.libro2 := '';
            v_mayor_general.asiento2 := '';
            v_mayor_general.codope2 := '';
            IF ( v_codsunat <> v_mayor_general.codsunat ) THEN
                v_codsunat := v_mayor_general.codsunat;
                v_mayor_general.codsunat2 := sp000_ajusta_string(v_mayor_general.codsunat, 02, '0', 'R');
                IF ( v_mayor_general.codsunat2 IS NULL ) THEN
                    v_mayor_general.codsunat2 := '';
                END IF;

            END IF;

            v_mayor_general.libro2 := sp000_ajusta_string(v_mayor_general.libro, 02, '0', 'R');
            IF ( v_mayor_general.libro2 IS NULL ) THEN
                v_mayor_general.libro2 := '';
            END IF;

            v_mayor_general.asiento2 := sp000_ajusta_string(v_mayor_general.asiento, 05, '0', 'R');
            IF ( v_mayor_general.asiento2 IS NULL ) THEN
                v_mayor_general.asiento2 := '';
            END IF;

            v_mayor_general.codope1 := v_mayor_general.libro2
                                       || '-'
                                       || v_mayor_general.asiento2;
            v_mayor_general.codope2 := v_mayor_general.codsunat2
                                       || '-'
                                       || v_mayor_general.asiento2;
            IF ( v_mayor_general.debe01 IS NULL ) THEN
                v_mayor_general.debe01 := 0;
            END IF;

            IF ( v_mayor_general.debe01 IS NULL ) THEN
                v_mayor_general.debe01 := 0;
            END IF;

            IF ( v_mayor_general.debe02 IS NULL ) THEN
                v_mayor_general.debe02 := 0;
            END IF;

            IF ( v_mayor_general.haber01 IS NULL ) THEN
                v_mayor_general.haber01 := 0;
            END IF;

            IF ( v_mayor_general.haber02 IS NULL ) THEN
                v_mayor_general.haber02 := 0;
            END IF;

            v_swsalio := 'S';
            PIPE ROW ( v_mayor_general );
        END LOOP;

        IF ( v_swsalio = 'N' ) THEN
            PIPE ROW ( v_mayor_general );
        END IF;
    END LOOP;
END sp_mayor_general;

/
