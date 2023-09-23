--------------------------------------------------------
--  DDL for Function GETDIALAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."GETDIALAB" (
    pin_ano       INTEGER,
    pin_mes       INTEGER,
    pin_fingreso  DATE,
    pin_fcese     DATE
) RETURN INTEGER AS

    v_mdcalc  INTEGER := 30;--máximo días para cálculo
    v_mdcale  INTEGER := to_number(to_char(last_day(to_date('01/'
                                                           || pin_mes
                                                           || '/'
                                                           || pin_ano, 'DD/MM/YYYY')), 'DD'));--máximo días calendario
    v_yy      INTEGER := 0;
    v_mm      INTEGER := 0;
    v_dd      INTEGER := 0;
    v_dlab    INTEGER := 0;
    v_dingre  INTEGER := 0;
    v_dcese   INTEGER := 0;
BEGIN
    v_dlab := v_mdcalc;
    v_dingre := 0;
    IF pin_fingreso IS NOT NULL THEN
        v_yy := extract(YEAR FROM pin_fingreso);
        v_mm := extract(MONTH FROM pin_fingreso);
        v_dd := extract(DAY FROM pin_fingreso);
        IF (
            ( pin_ano = v_yy ) AND ( pin_mes = v_mm )
        ) THEN
            v_dingre := v_dd - 1;
        END IF;

    END IF;

    v_dcese := 0;
    IF pin_fcese IS NOT NULL THEN
        v_yy := extract(YEAR FROM pin_fcese);
        v_mm := extract(MONTH FROM pin_fcese);
        v_dd := extract(DAY FROM pin_fcese);
        IF (
            ( pin_ano = v_yy ) AND ( pin_mes = v_mm )
        ) THEN
            v_dcese := v_dd;
        END IF;

    END IF;

    IF ( v_dingre > 0 ) THEN
        v_dlab :=
            CASE
                WHEN ( v_dcese > 0 ) THEN
                    v_dcese - v_dingre
                WHEN ( v_dcese = 0 ) THEN
                    v_mdcale - v_dingre
            END;
    ELSIF ( v_dcese > 0 ) THEN
        v_dlab :=
            CASE
                WHEN (
                    ( v_dcese = v_mdcale ) AND ( ( v_mdcale < 30 ) OR ( v_mdcale > 30 ) )
                ) THEN
                    30
                ELSE v_dcese
            END;
    END IF;

    RETURN v_dlab;
END;

/
