--------------------------------------------------------
--  DDL for Function SP_ANALITICA_DE_CUENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_ANALITICA_DE_CUENTAS" (
    pin_id_cia   IN  INTEGER,
    pin_periodo  IN  INTEGER,
    pin_mes      IN  INTEGER,
    pin_codtana  IN  INTEGER,
    pin_codigo   IN  VARCHAR2
) RETURN tbl_sp_analitica_de_cuentas
    PIPELINED
AS

    r_analitica  rec_sp_analitica_de_cuentas := rec_sp_analitica_de_cuentas(NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL);
    v_n01        INTEGER := 0;
    v_n02        INTEGER := 0;
    v_n03        INTEGER := 0;
    v_nivel1     INTEGER := 0;
    v_nivel2     INTEGER := 0;
    v_nivel3     INTEGER := 0;
BEGIN
    BEGIN
        SELECT
            ventero
        INTO v_n01
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 200;

    EXCEPTION
        WHEN no_data_found THEN
            v_n01 := 0;
    END;

    BEGIN
        SELECT
            ventero
        INTO v_n02
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 201;

    EXCEPTION
        WHEN no_data_found THEN
            v_n02 := 0;
    END;

    BEGIN
        SELECT
            ventero
        INTO v_n03
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 202;

    EXCEPTION
        WHEN no_data_found THEN
            v_n03 := 0;
    END;

    v_nivel1 := v_n01;
    v_nivel2 := v_n01 + v_n02;
    v_nivel3 := v_n01 + v_n02 + v_n03;
    FOR registro IN (
        SELECT
            substr(p.cuenta, 1, v_nivel1)                         AS n01,
            substr(p.cuenta, 1, v_nivel2)                         AS n02,
            substr(p.cuenta, 1, v_nivel3)                         AS n03,
            p.cuenta,
            p.nombre,
            m.codigo,
            m.concep,
            c.razonc,
            m.tdocum,
            d.descri                                              AS desdoc,
            d.abrevi,
            m.serie,
            m.numero,
            CAST(m.serie || m.numero AS VARCHAR2(30))             AS xnrodoc,
            m.debe01,
            m.haber01,
            m.debe02,
            m.haber02,
            m.libro,
            l.descri                                              AS deslib,
            m.asiento,
            m.fecha,
            m.periodo,
            m.mes,
            m.item,
            m.sitem,
            sp_saldo_analitica(pin_id_cia, pin_periodo, pin_mes, p.codtana, p.cuenta,
                               m.codigo, m.tdocum, m.serie, m.numero) AS saldoc
        FROM
                 pcuentas p
            INNER JOIN movimientos  m ON m.id_cia = p.id_cia
                                        AND ( ( m.periodo = pin_periodo )
                                              AND ( m.mes <= pin_mes ) )
                                        AND ( p.cuenta = m.cuenta )
            LEFT JOIN cliente      c ON c.id_cia = p.id_cia
                                   AND m.codigo = c.codcli
            LEFT JOIN tdocume      d ON d.id_cia = p.id_cia
                                   AND m.tdocum = d.codigo
            LEFT JOIN tlibro       l ON l.id_cia = p.id_cia
                                  AND m.libro = l.codlib
        WHERE
                m.id_cia = pin_id_cia
            AND m.codigo <> 'AMBS'
            AND p.codtana = pin_codtana
            AND ( ( pin_codigo = '-1' )
                  OR m.codigo = pin_codigo )
        ORDER BY
            1,
            2,
            3,
            p.cuenta,
            p.nombre,
            m.codigo,
            m.tdocum,
            m.serie,
            m.numero,
            m.periodo,
            m.mes,
            m.libro,
            m.asiento,
            m.item,
            m.sitem
    ) LOOP
        r_analitica.n01 := registro.n01;
        r_analitica.n02 := registro.n02;
        r_analitica.n03 := registro.n03;
        r_analitica.cuenta := registro.cuenta;
        r_analitica.nombre := registro.nombre;
        r_analitica.codigo := registro.codigo;
        r_analitica.concep := registro.concep;
        r_analitica.razonc := registro.razonc;
        r_analitica.tdocum := registro.tdocum;
        r_analitica.desdoc := registro.desdoc;
        r_analitica.abrevi := registro.abrevi;
        r_analitica.serie := registro.serie;
        r_analitica.numero := registro.numero;
        r_analitica.xnrodoc := registro.xnrodoc;
        r_analitica.debe01 := registro.debe01;
        r_analitica.haber01 := registro.haber01;
        r_analitica.debe02 := registro.debe02;
        r_analitica.haber02 := registro.haber02;
        r_analitica.libro := registro.libro;
        r_analitica.deslib := registro.deslib;
        r_analitica.asiento := registro.asiento;
        r_analitica.fecha := registro.fecha;
        r_analitica.periodo := registro.periodo;
        r_analitica.mes := registro.mes;
        r_analitica.item := registro.item;
        r_analitica.sitem := registro.sitem;
        r_analitica.saldoc := registro.saldoc;
        PIPE ROW ( r_analitica );
    END LOOP;

END sp_analitica_de_cuentas;

/
