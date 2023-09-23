--------------------------------------------------------
--  DDL for Function SP00_SELECT_ANALITICA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP00_SELECT_ANALITICA" (
    pin_id_cia  IN INTEGER,
    pin_periodo IN INTEGER,
    pin_mes     IN INTEGER,
    pin_codtana IN INTEGER,
    pin_codigo  IN VARCHAR2
) RETURN tbl_sp_000_analitica_de_cuentas
    PIPELINED
AS

    r_analitica rec_sp_000_analitica_de_cuentas := rec_sp_000_analitica_de_cuentas(NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL);
    v_n01       INTEGER := 0;
    v_n02       INTEGER := 0;
    v_n03       INTEGER := 0;
    v_nivel1    INTEGER := 0;
    v_nivel2    INTEGER := 0;
    v_nivel3    INTEGER := 0;
BEGIN
    FOR registro IN (
        SELECT
            substr(p.cuenta, 1, 2)  AS n01,
            substr(p.cuenta, 1, 6)  AS n02,
            substr(p.cuenta, 1, 12) AS n03,
            p.cuenta,
            p.nombre,
            m.codigo,
            c.razonc,
            c.dident,
            m.tdocum,
            MAX(m.fecha)            AS fecha,
            d.descri                AS desdoc,
            d.abrevi,
            m.serie,
            m.numero,
            tc.tipdoc,
            pc.swflag,
            SUM(m.debe01)           AS debe01,
            SUM(m.haber01)          AS haber01,
            SUM(m.debe02)           AS debe02,
            SUM(m.haber02)          AS haber02
        FROM
                 movimientos m
            INNER JOIN pcuentas       p ON p.id_cia = m.id_cia
                                     AND p.cuenta = m.cuenta
            LEFT JOIN cliente        c ON c.id_cia = m.id_cia
                                   AND c.codcli = m.codigo
            LEFT OUTER JOIN tdocume        d ON d.id_cia = m.id_cia
                                         AND d.codigo = m.tdocum
            LEFT OUTER JOIN tdoccobranza   tc ON tc.id_cia = m.id_cia
                                               AND tc.codsunat IS NOT NULL
                                               AND tc.codsunat = m.tdocum
            LEFT OUTER JOIN pcuentas_clase pc ON pc.id_cia = m.id_cia
                                                 AND pc.cuenta = m.cuenta
                                                 AND pc.clase = 1
        WHERE
                m.id_cia = pin_id_cia
            AND m.periodo = pin_periodo
            AND m.mes <= pin_mes
            AND p.codtana = pin_codtana
            AND ( pin_codigo = '-1'
                  OR m.codigo = pin_codigo )
        GROUP BY
            p.cuenta,
            p.nombre,
            m.codigo,
            c.razonc,
            c.dident,
            m.tdocum,
            d.descri,
            d.abrevi,
            m.serie,
            m.numero,
            tc.tipdoc,
            pc.swflag
        HAVING ( ( SUM(m.debe01) - SUM(m.haber01) ) <> 0 )
               OR ( ( ( SUM(m.debe02) - SUM(m.haber02) ) <> 0 )
                    AND ( upper(pc.swflag) = 'S' ) )
    ) LOOP
        r_analitica.tipdoc := registro.tipdoc;
        r_analitica.dident := registro.dident;
        r_analitica.femisi := NULL;
        r_analitica.fvenci := NULL;
        r_analitica.referencia := NULL;
        IF ( registro.tipdoc > 0 ) THEN
            BEGIN
                SELECT
                    femisi,
                    fvenci,
                    refere01
                    || ' '
                    || refere02
                INTO
                    r_analitica.femisi,
                    r_analitica.fvenci,
                    r_analitica.referencia
                FROM
                    dcta100
                WHERE
                        id_cia = pin_id_cia
                    AND codcli = registro.codigo
                    AND tipdoc = registro.tipdoc
                    AND serie = registro.serie
                    AND numero = registro.numero
                FETCH FIRST 1 ROW ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    r_analitica.femisi := NULL;
                    r_analitica.fvenci := NULL;
                    r_analitica.referencia := NULL;
            END;
        END IF;

        IF (
            ( registro.tdocum IS NOT NULL )
            AND ( r_analitica.femisi IS NULL )
        ) THEN
            BEGIN
                SELECT
                    femisi,
                    fvenci,
                    concep
                INTO
                    r_analitica.femisi,
                    r_analitica.fvenci,
                    r_analitica.referencia
                FROM
                    compr010
                WHERE
                        id_cia = pin_id_cia
                    AND codpro = registro.codigo
                    AND tdocum = registro.tdocum
                    AND nserie || numero = registro.serie || registro.numero
                FETCH FIRST 1 ROW ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    r_analitica.femisi := NULL;
                    r_analitica.fvenci := NULL;
                    r_analitica.referencia := NULL;
            END;

            IF ( r_analitica.femisi IS NULL ) THEN
                BEGIN
                    SELECT
                        femisi,
                        fvenci,
                        refere01
                        || ' '
                        || refere02
                    INTO
                        r_analitica.femisi,
                        r_analitica.fvenci,
                        r_analitica.referencia
                    FROM
                        prov100
                    WHERE
                            id_cia = pin_id_cia
                        AND codcli = registro.codigo
                        AND tipdoc = registro.tdocum
                        AND docume = registro.serie || registro.numero
                    FETCH FIRST 1 ROW ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        r_analitica.femisi := NULL;
                        r_analitica.fvenci := NULL;
                        r_analitica.referencia := NULL;
                END;

            END IF;

            IF ( r_analitica.femisi IS NULL ) THEN
                r_analitica.femisi := registro.fecha;
            END IF;

        END IF;

        r_analitica.n01 := registro.n01;
        r_analitica.n02 := registro.n02;
        r_analitica.n03 := registro.n03;
        r_analitica.cuenta := registro.cuenta;
        r_analitica.nombre := registro.nombre;
        r_analitica.codigo := registro.codigo;
        r_analitica.razonc := registro.razonc;
        r_analitica.tdocum := registro.tdocum;
        r_analitica.desdoc := registro.desdoc;
        r_analitica.abrevi := registro.abrevi;
        r_analitica.serie := registro.serie;
        r_analitica.numero := registro.numero;
        r_analitica.debe01 := registro.debe01;
        r_analitica.haber01 := registro.haber01;
        r_analitica.debe02 := registro.debe02;
        r_analitica.haber02 := registro.haber02;
        PIPE ROW ( r_analitica );
    END LOOP;
END sp00_select_analitica;

/
