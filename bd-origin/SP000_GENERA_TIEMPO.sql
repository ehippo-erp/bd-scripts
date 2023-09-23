--------------------------------------------------------
--  DDL for Procedure SP000_GENERA_TIEMPO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_GENERA_TIEMPO" (
    fdesde IN DATE,
    fhasta IN DATE
) AS

    fecha        DATE;
    periodo      INTEGER;
    mesid        INTEGER;
    mes          VARCHAR(15);
    nummes       SMALLINT;
    semestre     INTEGER;
    cuatrimestre INTEGER;
    trimestre    INTEGER;
    bimestre     INTEGER;
    cuarto       INTEGER;
    semana       INTEGER;
    numdiasemana SMALLINT;
    diasemana    VARCHAR2(15);
BEGIN
    DELETE FROM tiempo;

    fecha := fdesde;
    WHILE ( fecha <= fhasta ) LOOP
        periodo := to_number(to_char(fecha, 'YYYY'));
        mesid := to_number(to_char(fecha, 'YYYY')) * 100 + to_number(to_char(fecha, 'MM'));

        nummes := to_number(to_char(fecha, 'MM'));
        numdiasemana := to_number(to_char(fecha, 'D', 'NLS_DATE_LANGUAGE=SPANISH'));
        CASE nummes
            WHEN 1 THEN
                mes := 'ENERO';
            WHEN 2 THEN
                mes := 'FEBRERO';
            WHEN 3 THEN
                mes := 'MARZO';
            WHEN 4 THEN
                mes := 'ABRIL';
            WHEN 5 THEN
                mes := 'MAYO';
            WHEN 6 THEN
                mes := 'JUNIO';
            WHEN 7 THEN
                mes := 'JULIO';
            WHEN 8 THEN
                mes := 'AGOSTO';
            WHEN 9 THEN
                mes := 'SEPTIEMBRE';
            WHEN 10 THEN
                mes := 'OCTUBRE';
            WHEN 11 THEN
                mes := 'NOVIEMBRE';
            WHEN 12 THEN
                mes := 'DICIEMBRE';
            ELSE
                mes := 'MES INVALIDO';
        END CASE;

        CASE numdiasemana
            WHEN 1 THEN
                diasemana := 'LUNES';
            WHEN 2 THEN
                diasemana := 'MARTES';
            WHEN 3 THEN
                diasemana := 'MIERCOLES';
            WHEN 4 THEN
                diasemana := 'JUEVES';
            WHEN 5 THEN
                diasemana := 'VIERNES';
            WHEN 6 THEN
                diasemana := 'SABADO';
            WHEN 7 THEN
                diasemana := 'DOMINGO';
            ELSE
                mes := 'DIA INVALIDO';
        END CASE;

        IF ( nummes IN ( 1, 2, 3, 4, 5,
                         6 ) ) THEN
            semestre := periodo * 10 + 1;
        END IF;

        IF ( nummes IN ( 7, 8, 9, 10, 11,
                         12 ) ) THEN
            semestre := periodo * 10 + 2;
        END IF;

        IF ( nummes IN ( 1, 2, 3, 4 ) ) THEN
            cuatrimestre := periodo * 10 + 1;
        END IF;

        IF ( nummes IN ( 5, 6, 7, 8 ) ) THEN
            cuatrimestre := periodo * 10 + 2;
        END IF;

        IF ( nummes IN ( 9, 10, 11, 12 ) ) THEN
            cuatrimestre := periodo * 10 + 3;
        END IF;

        IF ( nummes IN ( 1, 2, 3 ) ) THEN
            trimestre := periodo * 10 + 1;
        END IF;

        IF ( nummes IN ( 4, 5, 6 ) ) THEN
            trimestre := periodo * 10 + 2;
        END IF;

        IF ( nummes IN ( 7, 8, 9 ) ) THEN
            trimestre := periodo * 10 + 3;
        END IF;

        IF ( nummes IN ( 10, 11, 12 ) ) THEN
            trimestre := periodo * 10 + 4;
        END IF;

        IF ( nummes IN ( 1, 2 ) ) THEN
            bimestre := periodo * 10 + 1;
        END IF;

        IF ( nummes IN ( 3, 4 ) ) THEN
            bimestre := periodo * 10 + 2;
        END IF;

        IF ( nummes IN ( 5, 6 ) ) THEN
            bimestre := periodo * 10 + 3;
        END IF;

        IF ( nummes IN ( 7, 8 ) ) THEN
            bimestre := periodo * 10 + 4;
        END IF;

        IF ( nummes IN ( 9, 10 ) ) THEN
            bimestre := periodo * 10 + 5;
        END IF;

        IF ( nummes IN ( 11, 12 ) ) THEN
            bimestre := periodo * 10 + 6;
        END IF;

        semana := periodo * 100 + to_number(to_char(fecha, 'WW'));
        INSERT INTO tiempo (
            "FECHA",
            "PERIODO",
            "MESID",
            "MES",
            "NUMMES",
            "SEMESTRE",
            "CUATRIMESTRE",
            "TRIMESTRE",
            "BIMESTRE",
            "SEMANA",
            "NUMDIASEMANA",
            "DIASEMANA"
        ) VALUES (
            fecha,
            periodo,
            mesid,
            mes,
            nummes,
            semestre,
            cuatrimestre,
            trimestre,
            bimestre,
            semana,
            numdiasemana,
            diasemana
        );

        fecha := fecha + 1;
    END LOOP;

END;

/
