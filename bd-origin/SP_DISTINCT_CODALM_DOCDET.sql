--------------------------------------------------------
--  DDL for Function SP_DISTINCT_CODALM_DOCDET
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_DISTINCT_CODALM_DOCDET" (
    pin_id_cia  IN  NUMBER,
    pin_numint  IN  NUMBER,
    pin_situac  IN  VARCHAR2
) RETURN VARCHAR2 IS

    almacen_refcur  SYS_REFCURSOR;
    v_lcodalm       INTEGER;
    v_coma          CHAR(1) := '';
    v_cadin         VARCHAR2(100);
    strselect       VARCHAR2(2000);
    v_codalm        VARCHAR2(50) := '';
BEGIN
--FORMA DE USO
--SELECT sp_distinct_codalm_docdet(13,100003,'B X') FROM DUAL;
    IF TRIM(pin_situac) IS NULL THEN
        v_cadin := '';
    ELSE
        SELECT
            ' (SITUAC IN ('
            || ''''
            || replace(pin_situac, ' ', ''',''')
            || ''''
            || '))'
        INTO v_cadin
        FROM
            dual;

    END IF;

    strselect := 'SELECT DISTINCT CODALM
      FROM DOCUMENTOS_DET
      WHERE ID_CIA = '
                 || pin_id_cia
                 || ' AND NUMINT='
                 || pin_numint
                 || ' AND '
                 || v_cadin;

    OPEN almacen_refcur FOR strselect;

    LOOP
        FETCH almacen_refcur INTO v_lcodalm;
        EXIT WHEN almacen_refcur%notfound;
        IF NOT ( v_codalm = '' ) THEN
            v_coma := ',';
        END IF;
        v_codalm := v_codalm
                    || v_lcodalm
                    || ',';
    END LOOP;

    v_codalm := substr(v_codalm, 1, length(v_codalm) - 1);
    RETURN v_codalm;
--RETURN strselect;
END sp_distinct_codalm_docdet;

/
