--------------------------------------------------------
--  DDL for Function FSISTEMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."FSISTEMA" (
    pin_id_cia  NUMBER,
    pin_numpla  NUMBER,
    pin_codper  VARCHAR2,
    pin_codcon  NUMBER,
    pin_nombre  VARCHAR2
) RETURN VARCHAR2 AS

    CURSOR cur_planilla IS
    SELECT
        *
    FROM
        planilla
    WHERE
            id_cia = pin_id_cia
        AND numpla = pin_numpla;

    CURSOR cur_personal IS
    SELECT
        *
    FROM
        personal
    WHERE
            id_cia = pin_id_cia
        AND codper = pin_codper;

    v_rpla     planilla%rowtype;
    v_rper     personal%rowtype;
    v_nombre   VARCHAR2(100) := upper(pin_nombre);
    v_result   VARCHAR2(30);
    v_integer  INTEGER := 0;
BEGIN
    v_result := '0';
    IF v_nombre = 'RANGO' THEN
        v_result := '0';
    ELSIF v_nombre = 'NHESCOLAR' THEN
        v_result := '1';
    ELSIF v_nombre = 'NO' THEN
        v_result := '0';
    ELSIF v_nombre = 'SI' THEN
        v_result := '1';
    ELSIF v_nombre = 'ANO' THEN
        v_result := to_char(current_date, 'YYYY');
    ELSIF v_nombre = 'MES' THEN
        v_result := to_char(current_date, 'MM');
    ELSIF v_nombre = 'DIA' THEN
        v_result := to_char(current_date, 'DD');
    ELSIF v_nombre = 'DIASEM' THEN
        v_integer := to_number(to_char(current_date, 'D', 'NLS_DATE_LANGUAGE =SPANISH'));
        IF v_integer = 1 THEN
            v_result := '7';
        ELSE
            v_result := to_char(v_integer - 1);
        END IF;

    ELSIF v_nombre = 'ANOPLA' THEN
        OPEN cur_planilla;
        LOOP
            FETCH cur_planilla INTO v_rpla;
            EXIT WHEN cur_planilla%notfound;
            IF cur_planilla%rowcount = 1 THEN
                v_result := to_char(v_rpla.anopla);
            END IF;

        END LOOP;

        CLOSE cur_planilla;
    ELSIF v_nombre = 'MESPLA' THEN
        OPEN cur_planilla;
        LOOP
            FETCH cur_planilla INTO v_rpla;
            EXIT WHEN cur_planilla%notfound;
            IF cur_planilla%rowcount = 1 THEN
                v_result := to_char(v_rpla.mespla);
            END IF;

        END LOOP;

        CLOSE cur_planilla;
    ELSIF v_nombre = 'SEMPLA' THEN
        OPEN cur_planilla;
        LOOP
            FETCH cur_planilla INTO v_rpla;
            EXIT WHEN cur_planilla%notfound;
            IF cur_planilla%rowcount = 1 THEN
                v_result := to_char(v_rpla.sempla);
            END IF;

        END LOOP;

        CLOSE cur_planilla;
    ELSIF v_nombre = 'TCPLA' THEN
        v_result := 1;
        OPEN cur_planilla;
        LOOP
            FETCH cur_planilla INTO v_rpla;
            EXIT WHEN cur_planilla%notfound;
            IF cur_planilla%rowcount = 1 THEN
                v_result := to_char(nvl(v_rpla.tcambio, 1));
            END IF;

        END LOOP;

        CLOSE cur_planilla;
    ELSIF v_nombre = 'TIPPLA' THEN
        v_result := 1;
        OPEN cur_planilla;
        LOOP
            FETCH cur_planilla INTO v_rpla;
            EXIT WHEN cur_planilla%notfound;
            IF cur_planilla%rowcount = 1 THEN
                v_result := v_rpla.tippla;
            END IF;
        END LOOP;

        CLOSE cur_planilla;
    ELSIF v_nombre = 'DIFMESFFIN' THEN
        v_result := '0';
    ELSIF v_nombre = 'DMES' THEN
        v_result := 0;
        OPEN cur_planilla;
        LOOP
            FETCH cur_planilla INTO v_rpla;
            EXIT WHEN cur_planilla%notfound;
            IF cur_planilla%rowcount = 1 THEN
                v_result := to_char(last_day(to_date('01/'
                                                     || v_rpla.mespla
                                                     || '/'
                                                     || v_rpla.anopla, 'DD/MM/YYYY')), 'DD');
            END IF;

        END LOOP;

        CLOSE cur_planilla;
    ELSIF v_nombre = 'DLABMES' THEN --POR IMPLEMENTAR
        v_result := '0';
    ELSIF v_nombre = 'DIFDIAFFIN' THEN--POR IMPLEMENTAR
        v_result := '0';
    ELSIF v_nombre = 'DIFMESFINI' THEN--POR IMPLEMENTAR
        v_result := '0';
    ELSIF v_nombre = 'DIFDIAFINI' THEN--POR IMPLEMENTAR
        v_result := '0';
    ELSIF substr(v_nombre, 1, 5) = 'LETRA' THEN--POR IMPLEMENTAR
        v_result := substr(v_nombre, 6, 1);
    ELSIF v_nombre = 'INDAFP' THEN
        OPEN cur_personal;
        LOOP
            FETCH cur_personal INTO v_rper;
            EXIT WHEN cur_personal%notfound;
            IF cur_personal%rowcount = 1 THEN
                IF ( v_rper.codafp = '0000' ) THEN
                    v_result := '0';
                ELSE
                    v_result := '1';
                END IF;
            END IF;

        END LOOP;

        CLOSE cur_personal;
    ELSE
        v_result := '0';
    END IF;

    RETURN v_result;
END;

/
