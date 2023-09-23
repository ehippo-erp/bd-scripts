--------------------------------------------------------
--  DDL for Package Body PACK_HR_FUNCTION_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_FUNCTION_GENERAL" AS

    FUNCTION sp_periodo_rango (
        pin_periodo         IN NUMBER,
        pin_mes             IN NUMBER,
        pin_acum            IN NUMBER,
        pin_incluye_periodo IN VARCHAR2,
        pin_incluye_mes     IN VARCHAR2
    ) RETURN datatable_periodo_rango
        PIPELINED
    AS
        v_rec    datarecord_periodo_rango;
        v_fhasta DATE := NULL;
        v_fdesde DATE := NULL;
    BEGIN
        IF nvl(pin_incluye_periodo, 'N') = 'S' THEN
            IF nvl(pin_incluye_mes, 'N') = 'S' THEN
                v_fhasta := TO_DATE ( '01/'
                                      || pin_mes
                                      || '/'
                                      || pin_periodo, 'DD/MM/YYYY' );
            ELSE
                v_fhasta := TO_DATE ( '01/'
                                      || pin_mes
                                      || '/'
                                      || pin_periodo, 'DD/MM/YYYY' );

                v_fhasta := add_months(v_fhasta, -1);
            END IF;

            v_fdesde := add_months(v_fhasta,(-1 *(pin_acum - 1)));

            IF extract(YEAR FROM v_fdesde) = extract(YEAR FROM v_fhasta) THEN
                v_rec.pdesde := extract(YEAR FROM v_fdesde) * 100 + extract(MONTH FROM v_fdesde);
            ELSE
                v_rec.pdesde := ( pin_periodo * 100 ) + 1;
            END IF;

            v_rec.phasta := extract(YEAR FROM v_fhasta) * 100 + extract(MONTH FROM v_fhasta);

        ELSE
            IF nvl(pin_incluye_mes, 'N') = 'S' THEN
                v_fhasta := TO_DATE ( '01/'
                                      || pin_mes
                                      || '/'
                                      || pin_periodo, 'DD/MM/YYYY' );
            ELSE
                v_fhasta := TO_DATE ( '01/'
                                      || pin_mes
                                      || '/'
                                      || pin_periodo, 'DD/MM/YYYY' );

                v_fhasta := add_months(v_fhasta, -1);
            END IF;

            v_fdesde := add_months(v_fhasta,(-1 *(pin_acum - 1)));

            v_rec.pdesde := extract(YEAR FROM v_fdesde) * 100 + extract(MONTH FROM v_fdesde);

            v_rec.phasta := extract(YEAR FROM v_fhasta) * 100 + extract(MONTH FROM v_fhasta);

        END IF;

        PIPE ROW ( v_rec );
    END sp_periodo_rango;

    FUNCTION sp_meses_completos_gratificacion (
        pin_id_cia  NUMBER,
        pin_periodo INTEGER,
        pin_fdesde  DATE,
        pin_fhasta  DATE,
        pin_mesgra  INTEGER
    ) RETURN datatable_meses_completos
        PIPELINED
    AS

        v_rec    datarecord_meses_completos := datarecord_meses_completos(0, 0, 0, 0, 0,
                                                                      0, 0, 0, 0, 0,
                                                                      0, 0);
        v_fdesde DATE;
        v_fhasta DATE;
        v_mdesde NUMBER;
        v_mhasta NUMBER;
    BEGIN
        IF pin_mesgra = 7 THEN
            v_fdesde := TO_DATE ( '01/01/'
                                  || pin_periodo, 'DD/MM/YYYY' );
            v_fhasta := TO_DATE ( '30/06/'
                                  || pin_periodo, 'DD/MM/YYYY' );
            v_mdesde := 1;
            v_mhasta := 6;
        ELSIF pin_mesgra = 12 THEN
            v_fdesde := TO_DATE ( '01/07/'
                                  || pin_periodo, 'DD/MM/YYYY' );
            v_fhasta := TO_DATE ( '31/12/'
                                  || pin_periodo, 'DD/MM/YYYY' );
            v_mdesde := 7;
            v_mhasta := 12;
        END IF;

        IF pin_fdesde BETWEEN v_fdesde AND v_fhasta THEN
            IF pin_fhasta BETWEEN v_fdesde AND v_fhasta THEN
                FOR i IN (
                    SELECT
                        idmes,
                        CASE
                            WHEN ( EXTRACT(MONTH FROM pin_fdesde) = idmes
                                   AND pin_fdesde <> fdesde ) THEN
                                dias - TO_NUMBER(to_char(pin_fdesde, 'DD'))
                            WHEN ( EXTRACT(MONTH FROM pin_fhasta) = idmes
                                   AND pin_fhasta <> fhasta ) THEN
                                TO_NUMBER(to_char(pin_fhasta, 'DD'))
                            WHEN pin_fdesde >= fhasta THEN
                                0
                            WHEN pin_fdesde <= fdesde THEN
                                30
                        END AS dias
                    FROM
                        mes
                    WHERE
                            periodo = pin_periodo
                        AND fdesde < pin_fhasta
                        AND idmes BETWEEN v_mdesde AND v_mhasta
                ) LOOP
                    CASE
                        WHEN i.idmes = 1 THEN
                            v_rec.enero := i.dias;
                        WHEN i.idmes = 2 THEN
                            v_rec.febrero := i.dias;
                        WHEN i.idmes = 3 THEN
                            v_rec.marzo := i.dias;
                        WHEN i.idmes = 4 THEN
                            v_rec.abril := i.dias;
                        WHEN i.idmes = 5 THEN
                            v_rec.mayo := i.dias;
                        WHEN i.idmes = 6 THEN
                            v_rec.junio := i.dias;
                        WHEN i.idmes = 7 THEN
                            v_rec.julio := i.dias;
                        WHEN i.idmes = 8 THEN
                            v_rec.agosto := i.dias;
                        WHEN i.idmes = 9 THEN
                            v_rec.septiembre := i.dias;
                        WHEN i.idmes = 10 THEN
                            v_rec.octubre := i.dias;
                        WHEN i.idmes = 11 THEN
                            v_rec.noviembre := i.dias;
                        ELSE
                            v_rec.diciembre := i.dias;
                    END CASE;
                END LOOP;

                PIPE ROW ( v_rec );
            ELSE -- pin_fhasta  > v_fhasta
                FOR i IN (
                    SELECT
                        idmes,
                        CASE
                            WHEN ( EXTRACT(MONTH FROM pin_fdesde) = idmes
                                   AND pin_fdesde <> fdesde ) THEN
                                dias - TO_NUMBER(to_char(pin_fdesde, 'DD'))
                            WHEN pin_fdesde >= fhasta THEN
                                0
                            WHEN pin_fdesde <= fdesde THEN
                                30
                        END AS dias
                    FROM
                        mes
                    WHERE
                            periodo = pin_periodo
                        AND idmes BETWEEN v_mdesde AND v_mhasta
                ) LOOP
                    CASE
                        WHEN i.idmes = 1 THEN
                            v_rec.enero := i.dias;
                        WHEN i.idmes = 2 THEN
                            v_rec.febrero := i.dias;
                        WHEN i.idmes = 3 THEN
                            v_rec.marzo := i.dias;
                        WHEN i.idmes = 4 THEN
                            v_rec.abril := i.dias;
                        WHEN i.idmes = 5 THEN
                            v_rec.mayo := i.dias;
                        WHEN i.idmes = 6 THEN
                            v_rec.junio := i.dias;
                        WHEN i.idmes = 7 THEN
                            v_rec.julio := i.dias;
                        WHEN i.idmes = 8 THEN
                            v_rec.agosto := i.dias;
                        WHEN i.idmes = 9 THEN
                            v_rec.septiembre := i.dias;
                        WHEN i.idmes = 10 THEN
                            v_rec.octubre := i.dias;
                        WHEN i.idmes = 11 THEN
                            v_rec.noviembre := i.dias;
                        ELSE
                            v_rec.diciembre := i.dias;
                    END CASE;
                END LOOP;

                PIPE ROW ( v_rec );
            END IF;

        ELSIF pin_fdesde < v_fdesde THEN
            IF pin_fhasta BETWEEN v_fdesde AND v_fhasta THEN
                FOR i IN (
                    SELECT
                        idmes,
                        CASE
                            WHEN ( EXTRACT(MONTH FROM pin_fhasta) = idmes
                                   AND pin_fhasta <> fhasta ) THEN
                                TO_NUMBER(to_char(pin_fhasta, 'DD'))
                            WHEN pin_fhasta >= fhasta THEN
                                30
                            WHEN pin_fhasta <= fdesde THEN
                                0
                        END AS dias
                    FROM
                        mes
                    WHERE
                            periodo = pin_periodo
                        AND idmes BETWEEN v_mdesde AND v_mhasta
                ) LOOP
                    CASE
                        WHEN i.idmes = 1 THEN
                            v_rec.enero := i.dias;
                        WHEN i.idmes = 2 THEN
                            v_rec.febrero := i.dias;
                        WHEN i.idmes = 3 THEN
                            v_rec.marzo := i.dias;
                        WHEN i.idmes = 4 THEN
                            v_rec.abril := i.dias;
                        WHEN i.idmes = 5 THEN
                            v_rec.mayo := i.dias;
                        WHEN i.idmes = 6 THEN
                            v_rec.junio := i.dias;
                        WHEN i.idmes = 7 THEN
                            v_rec.julio := i.dias;
                        WHEN i.idmes = 8 THEN
                            v_rec.agosto := i.dias;
                        WHEN i.idmes = 9 THEN
                            v_rec.septiembre := i.dias;
                        WHEN i.idmes = 10 THEN
                            v_rec.octubre := i.dias;
                        WHEN i.idmes = 11 THEN
                            v_rec.noviembre := i.dias;
                        ELSE
                            v_rec.diciembre := i.dias;
                    END CASE;
                END LOOP;

                PIPE ROW ( v_rec );
            ELSIF pin_fhasta < v_fdesde THEN
                v_rec := datarecord_meses_completos(0, 0, 0, 0, 0,
                                                   0, 0, 0, 0, 0,
                                                   0, 0);

                PIPE ROW ( v_rec );
                RETURN;
            ELSE -- pin_fhasta > v_fhasta
                IF pin_mesgra = 7 THEN
                    v_rec := datarecord_meses_completos(30, 30, 30, 30, 30,
                                                       30, 0, 0, 0, 0,
                                                       0, 0);
                ELSIF pin_mesgra = 12 THEN
                    v_rec := datarecord_meses_completos(0, 0, 0, 0, 0,
                                                       0, 30, 30, 30, 30,
                                                       30, 30);
                END IF;

                PIPE ROW ( v_rec );
                RETURN;
            END IF;
        ELSE -- pin_fdesde > v_fhasta
            v_rec := datarecord_meses_completos(0, 0, 0, 0, 0,
                                               0, 0, 0, 0, 0,
                                               0, 0);

            PIPE ROW ( v_rec );
            RETURN;
        END IF;

    END sp_meses_completos_gratificacion;

    FUNCTION sp_fun_ymd_fechas (
        fechainicial DATE,
        fechafinal   DATE
    ) RETURN datatable_fun_ymd_fechas
        PIPELINED
    AS

        v_rec datarecord_fun_ymd_fechas;
        a     INTEGER;
        ai    INTEGER;
        af    INTEGER;
        m     INTEGER;
        mi    INTEGER;
        mf    INTEGER;
        d     INTEGER;
        di    INTEGER;
        df    INTEGER;
    BEGIN
        ai := extract(YEAR FROM fechainicial);
        af := extract(YEAR FROM fechafinal);
        mi := extract(MONTH FROM fechainicial);
        mf := extract(MONTH FROM fechafinal);
        di := extract(DAY FROM fechainicial);
        df := extract(DAY FROM fechafinal);
        a := af - ai;
        IF mf < mi THEN
            a := a - 1;
            m := 12 - mi + mf;
        ELSE
            m := mf - mi;
        END IF;

        IF df < ( di - 1 ) THEN
            IF m > 0 THEN
                m := m - 1;
            ELSE
                a := a - 1;
                m := 11;
            END IF;

            d := 30 - di + df;
        ELSE
            d := df - di;
        END IF;

        d := d + 1;
        IF d >= 30 THEN
            d := 0;
            m := m + 1;
        END IF;

        v_rec.anio := a;
        v_rec.mes := m;
        v_rec.dia := d;
        PIPE ROW ( v_rec );
    END sp_fun_ymd_fechas;

END;

/
