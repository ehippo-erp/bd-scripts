--------------------------------------------------------
--  DDL for Package Body PACK_AYUDA_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_AYUDA_GENERAL" AS

    FUNCTION sp_ajusta_string (
        wstring    IN VARCHAR2,
        wlargo     IN NUMBER,
        wcaracter  IN CHAR,
        wdireccion IN CHAR
    ) RETURN datatable_ajusta_string
        PIPELINED
    AS
        v_table    datatable_ajusta_string;
        wx         NUMBER;
        wy         NUMBER;
        svalor     VARCHAR2(250);
        xdireccion CHAR;
    BEGIN
        IF ( wstring IS NULL ) THEN
            svalor := '';
        ELSE
            wx := 1;
            wy := wlargo - length(wstring);
            svalor := '';
            xdireccion := upper(wdireccion);
            WHILE ( wx <= wy ) LOOP
                svalor := svalor || wcaracter;
                wx := wx + 1;
            END LOOP;

            IF ( xdireccion = 'R' ) THEN
                svalor := svalor || wstring;
            END IF;
            IF ( xdireccion = 'L' ) THEN
                svalor := wstring || svalor;
            END IF;
            IF ( xdireccion = 'C' ) THEN
                wx := wy / 2;
                wy := wy - wx;
                svalor := substr(svalor, 1, wx)
                          || wstring
                          || substr(svalor, 1, wy);

            END IF;

        END IF;

        SELECT
            svalor AS ajustado
        BULK COLLECT
        INTO v_table
        FROM
            dual;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ajusta_string;

    FUNCTION sp_difhor_string (
        pin_fdesde IN DATE,
        pin_fhasta IN DATE
    ) RETURN datatable_ajusta_string
        PIPELINED
    AS

        v_fecha  VARCHAR2(200) := '';
        v_hdesde VARCHAR2(200) := '';
        v_hhasta VARCHAR2(200) := '';
        v_table  datatable_ajusta_string;
    BEGIN
        v_fecha := '01/01/2000 ';
        v_hdesde := to_char(pin_fdesde, 'HH24:MI:SS');
        v_hhasta := to_char(pin_fhasta, 'HH24:MI:SS');
        SELECT
--            'Dias: '
--            || to_char(diferencia_dias, '00')
--            || ' - '
--            || 
            replace((to_char(diferencia_horas, '00')
                     || ':'
                     || to_char(diferencia_minutos, '00')
                     || ':'
                     || to_char(diferencia_segundos, '00')),
                    ' ',
                    '') AS "Dias: DD - HH24: MI: SS"
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    fecha_uno,
                    fecha_dos,
                    trunc((fecha_dos - fecha_uno))                          diferencia_dias,
                    trunc(mod((fecha_dos - fecha_uno) * 24, 24))            diferencia_horas,
                    trunc(mod((fecha_dos - fecha_uno) *(60 * 24), 60))      diferencia_minutos,
                    trunc(mod((fecha_dos - fecha_uno) *(60 * 60 * 24), 60)) diferencia_segundos
                FROM
                    (
                        SELECT
                            TO_DATE(v_fecha || v_hdesde, 'DD/MM/YYYY HH24:MI:SS') fecha_uno,
                            TO_DATE(v_fecha || v_hhasta, 'DD/MM/YYYY HH24:MI:SS') fecha_dos
                        FROM
                            dual
                    )
            );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_difhor_string;

    FUNCTION sp_difhor_number (
        pin_fdesde IN DATE,
        pin_fhasta IN DATE
    ) RETURN datatable_ajusta_number
        PIPELINED
    AS

        v_fecha  VARCHAR2(200) := '';
        v_hdesde VARCHAR2(200) := '';
        v_hhasta VARCHAR2(200) := '';
        v_table  datatable_ajusta_number;
    BEGIN
        v_fecha := '01/01/2000 ';
        v_hdesde := to_char(pin_fdesde, 'HH24:MI:SS');
        v_hhasta := to_char(pin_fhasta, 'HH24:MI:SS');
        SELECT
            ( TO_NUMBER(to_char(diferencia_horas, '00')) + ( TO_NUMBER(to_char(diferencia_minutos, '00')) / 60 ) + ( TO_NUMBER(to_char
            (diferencia_segundos, '00')) / 3600 ) )
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    fecha_uno,
                    fecha_dos,
                    trunc((fecha_dos - fecha_uno))                          diferencia_dias,
                    trunc(mod((fecha_dos - fecha_uno) * 24, 24))            diferencia_horas,
                    trunc(mod((fecha_dos - fecha_uno) *(60 * 24), 60))      diferencia_minutos,
                    trunc(mod((fecha_dos - fecha_uno) *(60 * 60 * 24), 60)) diferencia_segundos
                FROM
                    (
                        SELECT
                            TO_DATE(v_fecha || v_hdesde, 'DD/MM/YYYY HH24:MI:SS') fecha_uno,
                            TO_DATE(v_fecha || v_hhasta, 'DD/MM/YYYY HH24:MI:SS') fecha_dos
                        FROM
                            dual
                    )
            );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_difhor_number;

    FUNCTION sp_difmin_number (
        pin_fdesde IN TIMESTAMP,
        pin_fhasta IN TIMESTAMP
    ) RETURN datatable_ajusta_number
        PIPELINED
    AS

        v_fecha  VARCHAR2(200) := '';
        v_hdesde VARCHAR2(200) := '';
        v_hhasta VARCHAR2(200) := '';
        v_table  datatable_ajusta_number;
        v_rec    datarecord_ajusta_number;
    BEGIN
        v_fecha := '01/01/2000 ';
        v_hdesde := to_char(pin_fdesde, 'HH24:MI:SS');
        v_hhasta := to_char(pin_fhasta, 'HH24:MI:SS');
        SELECT
            ( ( TO_NUMBER(to_char(f.diferencia_horas, '00')) * 60 ) + TO_NUMBER(to_char(f.diferencia_minutos, '00')) + ( TO_NUMBER(to_char
            (f.diferencia_segundos, '00')) / 60 ) ) AS diffmin
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    fecha_uno,
                    fecha_dos,
                    trunc((fecha_dos - fecha_uno))                          diferencia_dias,
                    trunc(mod((fecha_dos - fecha_uno) * 24, 24))            diferencia_horas,
                    trunc(mod((fecha_dos - fecha_uno) *(60 * 24), 60))      diferencia_minutos,
                    trunc(mod((fecha_dos - fecha_uno) *(60 * 60 * 24), 60)) diferencia_segundos
                FROM
                    (
                        SELECT
                            TO_DATE((v_fecha
                                     || v_hdesde), 'DD/MM/YYYY HH24:MI:SS') fecha_uno,
                            TO_DATE((v_fecha
                                     || v_hhasta), 'DD/MM/YYYY HH24:MI:SS') fecha_dos
                        FROM
                            dual
                    )
            ) f;
--             dbms_output.put_line(v_fecha || v_hdesde|| ' - ' || v_fecha || v_hhasta);
--        dbms_output.put_line(TO_CHAR(to_date(v_fecha || v_hdesde, 'DD/MM/YYYY HH24:MI:SS'), 'DD/MM/YYYY HH24:MI:SS')
--        || ' - ' || TO_CHAR(to_date(v_fecha || v_hhasta, 'DD/MM/YYYY HH24:MI:SS'), 'DD/MM/YYYY HH24:MI:SS'));
--
        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_difmin_number;

    PROCEDURE sp_generate_numero (
        pin_id_cia  IN NUMBER,
        pin_number  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_nummax NUMBER := 100000;
    BEGIN
        IF pin_number IS NOT NULL THEN
            v_nummax := pin_number;
        END IF;
        FOR num IN 1..v_nummax LOOP
            BEGIN
                INSERT INTO numero VALUES ( num );

                COMMIT;
            EXCEPTION
                WHEN dup_val_on_index THEN
                    NULL;
            END;
        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Succes ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_generate_numero;

    FUNCTION sp_coma_fila (
        pin_texto VARCHAR2
    ) RETURN datatable_coma_fila
        PIPELINED
    AS
        v_rec datarecord_coma_fila := datarecord_coma_fila(0, 0);
    BEGIN
        FOR i IN (
            (
                SELECT
                    regexp_substr(pin_texto, '[^,]+', 1, level) AS campo
                FROM
                    dual
                CONNECT BY
                    regexp_substr(pin_texto, '[^,]+', 1, level) IS NOT NULL
            )
        ) LOOP
            v_rec.orden := v_rec.orden + 1;
            v_rec.campo := i.campo;
            PIPE ROW ( v_rec );
        END LOOP;

        RETURN;
    END sp_coma_fila;

    FUNCTION sp_number_text_aux (
        pin_numeroentero IN NUMBER
    ) RETURN VARCHAR2 IS

        fuera_de_rango EXCEPTION;
        numero_entero EXCEPTION;
        centenas        NUMBER;
        decenas         NUMBER;
        unidades        NUMBER;
        v_numeroenletra VARCHAR2(100);
        unir            VARCHAR2(2);
    BEGIN
        BEGIN
            IF trunc(pin_numeroentero) <> pin_numeroentero THEN
                RAISE numero_entero;
            END IF;
            IF pin_numeroentero < 0 OR pin_numeroentero > 999 THEN
                RAISE fuera_de_rango;
            END IF;
            IF pin_numeroentero = 100 THEN
                RETURN ( 'CIEN ' );
            ELSIF pin_numeroentero = 0 THEN
                RETURN ( 'CERO ' );
            ELSIF pin_numeroentero = 1 THEN
                RETURN ( 'UNO ' );
            ELSE
                centenas := trunc(pin_numeroentero / 100);
                decenas := trunc((pin_numeroentero MOD 100) / 10);
                unidades := pin_numeroentero MOD 10;
                unir := 'Y ';

        -- OBTENIENDO CENTENAS
                IF centenas = 1 THEN
                    v_numeroenletra := 'CIENTO ';
                ELSIF centenas = 2 THEN
                    v_numeroenletra := 'DOSCIENTOS ';
                ELSIF centenas = 3 THEN
                    v_numeroenletra := 'TRESCIENTOS ';
                ELSIF centenas = 4 THEN
                    v_numeroenletra := 'CUATROCIENTOS ';
                ELSIF centenas = 5 THEN
                    v_numeroenletra := 'QUINIENTOS ';
                ELSIF centenas = 6 THEN
                    v_numeroenletra := 'SEISCIENTOS ';
                ELSIF centenas = 7 THEN
                    v_numeroenletra := 'SETECIENTOS ';
                ELSIF centenas = 8 THEN
                    v_numeroenletra := 'OCHOCIENTOS ';
                ELSIF centenas = 9 THEN
                    v_numeroenletra := 'NOVECIENTOS ';
                END IF;

        -- OBTENIENDO DECENAS
                IF decenas = 3 THEN
                    v_numeroenletra := v_numeroenletra || 'TREINTA ';
                ELSIF decenas = 4 THEN
                    v_numeroenletra := v_numeroenletra || 'CUARENTA ';
                ELSIF decenas = 5 THEN
                    v_numeroenletra := v_numeroenletra || 'CINCUENTA ';
                ELSIF decenas = 6 THEN
                    v_numeroenletra := v_numeroenletra || 'SESENTA ';
                ELSIF decenas = 7 THEN
                    v_numeroenletra := v_numeroenletra || 'SETENTA ';
                ELSIF decenas = 8 THEN
                    v_numeroenletra := v_numeroenletra || 'OCHENTA ';
                ELSIF decenas = 9 THEN
                    v_numeroenletra := v_numeroenletra || 'NOVENTA ';
                ELSIF decenas = 1 THEN
                    IF unidades < 6 THEN
                        IF unidades = 0 THEN
                            v_numeroenletra := v_numeroenletra || 'DIEZ ';
                        ELSIF unidades = 1 THEN
                            v_numeroenletra := v_numeroenletra || 'ONCE ';
                        ELSIF unidades = 2 THEN
                            v_numeroenletra := v_numeroenletra || 'DOCE ';
                        ELSIF unidades = 3 THEN
                            v_numeroenletra := v_numeroenletra || 'TRECE ';
                        ELSIF unidades = 4 THEN
                            v_numeroenletra := v_numeroenletra || 'CATORCE ';
                        ELSIF unidades = 5 THEN
                            v_numeroenletra := v_numeroenletra || 'QUINCE ';
                        END IF;

                        unidades := 0;
                    ELSE
                        v_numeroenletra := v_numeroenletra || 'DIECI';
                        unir := NULL;
                    END IF;
                ELSIF decenas = 2 THEN
                    IF unidades = 0 THEN
                        v_numeroenletra := v_numeroenletra || 'VEINTE ';
                    ELSE
                        v_numeroenletra := v_numeroenletra || 'VEINTI';
                    END IF;

                    unir := NULL;
                ELSIF decenas = 0 THEN
                    unir := NULL;
                END IF;

        -- OBTENIENDO UNIDADES
                IF unidades = 1 THEN
                    v_numeroenletra := v_numeroenletra
                                       || unir
                                       || 'UNO ';
                ELSIF unidades = 2 THEN
                    v_numeroenletra := v_numeroenletra
                                       || unir
                                       || 'DOS ';
                ELSIF unidades = 3 THEN
                    v_numeroenletra := v_numeroenletra
                                       || unir
                                       || 'TRES ';
                ELSIF unidades = 4 THEN
                    v_numeroenletra := v_numeroenletra
                                       || unir
                                       || 'CUATRO ';
                ELSIF unidades = 5 THEN
                    v_numeroenletra := v_numeroenletra
                                       || unir
                                       || 'CINCO ';
                ELSIF unidades = 6 THEN
                    v_numeroenletra := v_numeroenletra
                                       || unir
                                       || 'SEIS ';
                ELSIF unidades = 7 THEN
                    v_numeroenletra := v_numeroenletra
                                       || unir
                                       || 'SIETE ';
                ELSIF unidades = 8 THEN
                    v_numeroenletra := v_numeroenletra
                                       || unir
                                       || 'OCHO ';
                ELSIF unidades = 9 THEN
                    v_numeroenletra := v_numeroenletra
                                       || unir
                                       || 'NUEVE ';
                END IF;

            END IF;

            RETURN ( v_numeroenletra );
        EXCEPTION
            WHEN numero_entero THEN
                RETURN ( 'ERROR: EL NUMERO NO ES ENTERO' );
            WHEN fuera_de_rango THEN
                RETURN ( 'ERROR: NUMERO FUERA DE RANGO' );
            WHEN OTHERS THEN
                RAISE;
        END;
    END sp_number_text_aux;

    FUNCTION sp_number_text (
        pin_numeroentero IN NUMBER
    ) RETURN VARCHAR2 IS

        fuera_de_rango EXCEPTION;
        n_millares_de_millon NUMBER;
        n_millones           NUMBER;
        n_millares           NUMBER;
        centenas             NUMBER;
        centimos             NUMBER;
        v_numeroenletra      VARCHAR2(2000);
        n_entero             NUMBER;
        aux                  VARCHAR2(15);
        n_millares_de_billon NUMBER;
    BEGIN
        BEGIN
            IF pin_numeroentero < 0 OR pin_numeroentero > 999999999999999.99 THEN
                RAISE fuera_de_rango;
            END IF;
            n_entero := trunc(pin_numeroentero);
            n_millares_de_billon := trunc(n_entero / 1000000000000);
            n_millares_de_millon := trunc(MOD(n_entero, 1000000000000) / 1000000000);
            n_millones := trunc(MOD(n_entero, 1000000000) / 1000000);
            n_millares := trunc(MOD(n_entero, 1000000) / 1000);
            centenas := MOD(n_entero, 1000);
            centimos := MOD((round(pin_numeroentero, 2) * 100), 100);

      -- BILLONES DE MILLON
            IF n_millares_de_billon = 1 THEN
                IF n_millares_de_millon = 0 OR n_millares_de_billon = 1 THEN
                    v_numeroenletra := 'UN BILLON ';
                ELSE
                    v_numeroenletra := 'BILLON ';
                END IF;
            ELSIF n_millares_de_billon > 1 THEN
                v_numeroenletra := pack_ayuda_general.sp_number_text_aux(n_millares_de_billon);
                IF n_millares_de_millon = 0 THEN
                    v_numeroenletra := v_numeroenletra || 'MIL BILLONES ';
                ELSE
                    v_numeroenletra := v_numeroenletra || 'BILLONES ';
                END IF;

            END IF;

      -- MILLARES DE MILLON

            IF n_millares_de_millon = 1 THEN
                IF n_millones = 0 THEN
                    v_numeroenletra := v_numeroenletra || ' MIL MILLONES ';
                ELSE
                    v_numeroenletra := v_numeroenletra || ' MIL ';
                END IF;
            ELSIF n_millares_de_millon > 1 THEN
                v_numeroenletra := v_numeroenletra || pack_ayuda_general.sp_number_text_aux(n_millares_de_millon);
                IF n_millones = 0 THEN
                    v_numeroenletra := v_numeroenletra || 'MIL MILLONES ';
                ELSE
                    v_numeroenletra := v_numeroenletra || 'MIL ';
                END IF;

            END IF;

      -- MILLONES
            IF
                n_millones = 1
                AND n_millares_de_millon = 0
            THEN
                v_numeroenletra := 'UN MILLON ';
            ELSIF n_millones > 0 THEN
                v_numeroenletra := v_numeroenletra
                                   || pack_ayuda_general.sp_number_text_aux(n_millones)
                                   || 'MILLONES ';
            END IF;

      -- MILES
            IF
                n_millares = 1
                AND n_millares_de_millon = 0
                AND n_millones = 0
            THEN
                v_numeroenletra := 'MIL ';
            ELSIF n_millares > 0 THEN
                v_numeroenletra := v_numeroenletra
                                   || pack_ayuda_general.sp_number_text_aux(n_millares)
                                   || 'MIL ';
            END IF;

      -- CENTENAS
            IF centenas > 0 OR (
                n_entero = 0
                AND centimos = 0
            ) THEN
                v_numeroenletra := v_numeroenletra || pack_ayuda_general.sp_number_text_aux(centenas);
            END IF;

            IF centimos > 0 THEN
                IF n_entero > 0 THEN
                    v_numeroenletra := v_numeroenletra
                                       || 'CON '
                                       || replace(pack_ayuda_general.sp_number_text_aux(centimos), 'UNO ', 'UN ')
                                       || aux;

                ELSE
                    v_numeroenletra := v_numeroenletra
                                       || replace(pack_ayuda_general.sp_number_text_aux(centimos), 'UNO', 'UN')
                                       || aux;
                END IF;
            END IF;

            RETURN ( v_numeroenletra );
        EXCEPTION
            WHEN fuera_de_rango THEN
                RETURN ( 'ERROR: NUMERO FUERA DE RANGO' );
            WHEN OTHERS THEN
                RAISE;
        END;
    END sp_number_text;

    FUNCTION sp_decimal2_text (
        pin_numerodecimal IN NUMBER
    ) RETURN VARCHAR2 AS
        v_aux NUMBER(16, 2) := 0;
    BEGIN
        v_aux := pin_numerodecimal -  floor(pin_numerodecimal) ;
        v_aux := trunc(v_aux*100);
        RETURN to_char(v_aux)
               || '/100';
    END;

END;

/
