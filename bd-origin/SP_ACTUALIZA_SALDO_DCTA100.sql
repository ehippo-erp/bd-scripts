--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_SALDO_DCTA100
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_SALDO_DCTA100" (
    pin_id_cia IN NUMBER,
    pin_numint IN NUMBER
) AS

    v_operac     NUMBER;
    v_operac_old VARCHAR2(2);
    v_codban     NUMBER;
    v_protes     NUMBER;
    v_tipdoc     NUMBER;
    v_numint     NUMBER;
    v_numite     NUMBER;
    v_anopro     NUMBER;
    v_mespro     NUMBER;
    v_monnac     VARCHAR2(5) := 'PEN';
    v_monext     VARCHAR2(5) := 'USD';
    v_tipmon     VARCHAR2(5);
    v_numbco     VARCHAR2(50);
    v_importe    NUMERIC(16, 2);
    v_pagosd01   NUMERIC(16, 2);
    v_pagosd02   NUMERIC(16, 2);
    v_pagosh01   NUMERIC(16, 2);
    v_pagosh02   NUMERIC(16, 2);
    v_pagos01    NUMERIC(16, 2);
    v_pagos02    NUMERIC(16, 2);
    v_saldo      NUMERIC(16, 2);
    v_saldo01    NUMERIC(16, 2);
    v_saldo02    NUMERIC(16, 2);
    v_date       DATE;
    pout_mensaje VARCHAR2(1000 CHAR);
BEGIN
    BEGIN
        SELECT
            moneda01,
            moneda02
        INTO
            v_monnac,
            v_monext
        FROM
            companias
        WHERE
            cia = pin_id_cia;

    EXCEPTION
        WHEN no_data_found THEN
            v_monnac := '';
            v_monext := '';
    END;

    v_monnac := trim(v_monnac);
    BEGIN
        SELECT
            c.numint,
            c.tipdoc,
            TRIM(c.tipmon),
            CASE
                WHEN ( c.importe IS NULL ) THEN
                    0
                ELSE
                    c.importe
            END,
            CASE
                WHEN ( o.saldo IS NULL ) THEN
                    0
                ELSE
                    o.saldo
            END
        INTO
            v_numint,
            v_tipdoc,
            v_tipmon,
            v_importe,
            v_saldo
        FROM
            dcta100     c
            LEFT OUTER JOIN dcta100_ori o ON o.id_cia = pin_id_cia
                                             AND o.numint = c.numint
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint;

    EXCEPTION
        WHEN no_data_found THEN
            v_numint := 0;
            v_tipdoc := 0;
            v_tipmon := '';
            v_importe := 0;
            v_saldo := 0;
    END;

    dbms_output.put_line('v_numint ==> ' || v_numint);
    dbms_output.put_line('v_tipdoc ==> ' || v_tipdoc);
    dbms_output.put_line('v_tipmon ==> ' || v_tipmon);
    dbms_output.put_line('v_saldo ==> ' || v_saldo);
    IF ( v_saldo = -1 ) THEN
        v_saldo := 0;
        v_importe := 0;
    END IF;

    IF ( v_saldo > 0 ) THEN
        v_importe := v_saldo;
    END IF;
    BEGIN
        SELECT
            p.numint,
            SUM(
                CASE
                    WHEN p.dh = 'H' THEN
                        p.impor01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN p.dh = 'H' THEN
                        p.impor02
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN p.dh = 'D' THEN
                        p.impor01
                    ELSE
                        0
                END
            ),
            SUM(
                CASE
                    WHEN p.dh = 'D' THEN
                        p.impor02
                    ELSE
                        0
                END
            )
        INTO
            v_numint,
            v_pagosh01,
            v_pagosh02,
            v_pagosd01,
            v_pagosd02 /*ACUMULA SEPARADO DH */
        FROM
            dcta101 p
        WHERE
                p.id_cia = pin_id_cia
            AND ( p.numint = pin_numint )
            AND ( p.tipcan <= 50 )
        GROUP BY
            p.numint;

    EXCEPTION
        WHEN no_data_found THEN
            v_numint := 0;
            v_pagosh01 := 0;
            v_pagosh02 := 0;
            v_pagosd01 := 0;
            v_pagosd02 := 0;
    END;

    dbms_output.put_line('PAGOS -----');
    dbms_output.put_line('v_numint ==> ' || v_numint);
    dbms_output.put_line('v_pagosh01 ==> ' || v_pagosh01);
    dbms_output.put_line('v_pagosh02 ==> ' || v_pagosh02);
    dbms_output.put_line('v_pagosd01 ==> ' || v_pagosd01);
    dbms_output.put_line('v_pagosd02 ==> ' || v_pagosd02);
    IF ( ( v_tipdoc IN ( 7, 9, 10, 43 ) ) ) THEN /* 7-NOTA DE CREDITO , 9-ANTICIPO Y 10-ANTICIPO DE IMPORTACION*/
        v_pagos01 := v_pagosd01 - v_pagosh01;
        v_pagos02 := v_pagosd02 - v_pagosh02;
    END IF;

    IF ( NOT ( v_tipdoc IN ( 7, 9, 10, 43 ) ) ) THEN /* 7-NOTA DE CREDITO , 9-ANTICIPO Y 10-ANTICIPO DE IMPORTACION*/
        v_pagos01 := v_pagosh01 - v_pagosd01;
        v_pagos02 := v_pagosh02 - v_pagosd02;
        dbms_output.put_line('TOTALES');
        dbms_output.put_line('v_pagos01 ==>  '
                             || v_pagos01
                             || '-'
                             || v_pagosd01);
        dbms_output.put_line('v_pagosd02 ==> '
                             || v_pagosh02
                             || '-'
                             || v_pagosd02);
    END IF;

    IF ( v_pagos01 IS NULL ) THEN
        v_pagos01 := 0;
    END IF;
    IF ( v_pagos02 IS NULL ) THEN
        v_pagos02 := 0;
    END IF;

  /* VALIDACION PARA QUE NO ACTUALICE SALDOS EN NEGATIVO
     SE REALIZA ANTES DE CUALQUIER UPDATE
  */
--    IF ( (
--        ( v_tipmon = v_monnac )
--        AND ( v_importe - v_pagos01 < 0 )
--    ) OR (
--        ( v_tipmon <> v_monnac )
--        AND ( v_importe - v_pagos02 < 0 )
--    ) ) THEN
--        RAISE pkg_exceptionuser.ex_saldo_en_negativo;
--    END IF;
    IF
        v_tipmon = v_monnac
        AND v_importe - v_pagos01 < 0
    THEN
        pout_mensaje := 'ERROR, SE HA CALCULADO UN SALDO EN NEGATIVO, EL DOCUMENTO '
                        || pin_numint
                        || ' TIENE UN SALDO DE S/. '
                        || v_importe
                        || ' Y EL PAGO DE S/. '
                        || v_pagos01
                        || ' EXCEDE DICHA CANTIDAD';

        RAISE pkg_exceptionuser.ex_saldo_en_negativo;
    ELSIF
        v_tipmon <> v_monnac
        AND v_importe - v_pagos02 < 0
    THEN
        pout_mensaje := 'ERROR, SE HA CALCULADO UN SALDO EN NEGATIVO, EL DOCUMENTO '
                        || pin_numint
                        || ' TIENE UN SALDO DE $. '
                        || v_importe
                        || ' Y EL PAGO DE $. '
                        || v_pagos02
                        || ' EXCEDE DICHA CANTIDAD';

        RAISE pkg_exceptionuser.ex_saldo_en_negativo;
    END IF;

    IF ( (
        ( v_tipmon = v_monnac )
        AND ( ( v_importe - ( v_importe - v_pagos01 ) ) < 0 )
    ) OR (
        ( v_tipmon <> v_monnac )
        AND ( ( v_importe - ( v_importe - v_pagos02 ) ) < 0 )
    ) ) THEN
        RAISE pkg_exceptionuser.ex_saldo_mayor;
    END IF;

    v_codban := NULL;
    BEGIN
  /*2015-02-23 ACTUALIZA SOLO EL ULTIMO REGISTRO DEL DCTA101*/
        SELECT
            c.periodo,
            c.mes,
            c.numite,
            c.tipcan,
            c.codban,
            CASE
                WHEN ( length(d1.numbco) > 0 )
                     AND ( length(c.numbco) = 0 ) THEN
                    d1.numbco
                ELSE
                    c.numbco
            END numbco,
            c.operac
        INTO
            v_anopro,
            v_mespro,
            v_numite,
            v_operac,
            v_codban,
            v_numbco,
            v_operac_old
        FROM
            dcta101 c
            LEFT OUTER JOIN dcta100 d1 ON d1.id_cia = pin_id_cia
                                          AND d1.numint = c.numint
            LEFT OUTER JOIN dcta102 d2 ON d2.id_cia = pin_id_cia
                                          AND d2.periodo = c.periodo
                                          AND d2.mes = c.mes
                                          AND d2.libro = c.libro
                                          AND d2.secuencia = c.secuencia
        WHERE
                c.id_cia = pin_id_cia
            AND ( c.numint = pin_numint )
            AND ( c.tipcan >= 50 )
            AND NOT ( c.tipcan = 59 )
        ORDER BY
            d2.femisi DESC,
            c.numite DESC
        FETCH FIRST 1 ROW ONLY;

    EXCEPTION
        WHEN no_data_found THEN
            v_anopro := 0;
            v_mespro := 0;
            v_numite := NULL;
            v_operac := 0;
            v_codban := NULL;
            v_numbco := '';
            v_operac_old := '';
    END;

    IF ( v_numite IS NOT NULL ) THEN
        IF ( v_operac = 55 ) THEN /* PROTESTO.. */
            UPDATE dcta100
            SET
                operac = 0,
                codban = 0,
                numbco = '',
                protes = 1
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

        END IF;

        IF ( v_operac = 58 ) THEN /* PROTESTO EN BANCO */
            IF (
                ( v_operac_old IS NOT NULL )
                AND ( length(v_operac_old) > 0 )
            ) THEN

         /* V_OPERAC=CAST(V_OPERAC_OLD AS NUMBER);*/
                UPDATE dcta100
                SET
                    operac = v_operac_old,
                    codban = v_codban,
                    numbco = v_numbco,
                    protes = 1
                WHERE
                        id_cia = pin_id_cia
                    AND numint = pin_numint;

            ELSE
                UPDATE dcta100
                SET
                    protes = 1
                WHERE
                        id_cia = pin_id_cia
                    AND numint = pin_numint;

            END IF;

        END IF;

        IF ( ( v_operac < 55 ) OR ( v_operac = 56 ) ) THEN /* MENORES A 55 = OPERACIONES DE ENVIO COBRANZA/DESCUENTO/RENOVACION, IGUAL 56 = ENVIO AL BANCO*/
            IF ( v_operac IS NULL ) THEN
                v_operac := 0;
            ELSE
                v_operac := v_operac - 50;
            END IF;

            IF ( v_codban IS NULL ) THEN
                v_codban := 0;
            END IF;
            IF ( v_numbco IS NULL ) THEN
                v_numbco := '';
            END IF;
            UPDATE dcta100
            SET
                operac = v_operac,
                codban = v_codban,
                numbco =
                    CASE
                        WHEN v_operac = 6 THEN
                            ''
                        ELSE
                            v_numbco
                    END,
                protes =
                    CASE
                        WHEN v_operac = 6 THEN
                            protes
                        ELSE
                            0
                    END
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

        END IF;

        IF ( v_operac = 57 ) THEN /*SITUACION EMITIDA(LETRAS)*/
            UPDATE dcta100
            SET
                operac = 0,
                codban = 0,
                numbco = ''
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

        END IF;

    ELSE
        BEGIN
            SELECT
                operac,
                codban,
                numbco,
                protes
            INTO
                v_operac,
                v_codban,
                v_numbco,
                v_protes
            FROM
                dcta100_ori
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

        EXCEPTION
            WHEN no_data_found THEN
                v_operac := 0;
                v_codban := '';
                v_numbco := 0;
                v_protes := 0;
        END;

        IF ( v_operac IS NOT NULL ) THEN
            UPDATE dcta100
            SET
                operac = v_operac,
                codban = v_codban,
                numbco = v_numbco,
                protes = v_protes
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

        END IF;

    END IF;

    dbms_output.put_line('ACTUALIZANDO DCTA100 -----');
    dbms_output.put_line('MARCA');
    dbms_output.put_line('IF v_tipmon = v_monnac THEN'
                         || v_tipmon
                         || '='
                         || v_monnac);
    IF ( v_tipmon = v_monnac ) THEN
 --   dbms_output.put_line('IGUAL ==>'||v_tipmon);
        UPDATE dcta100
        SET
            saldo = v_importe - v_pagos01,
            saldome = 0,
            saldomn = v_importe - v_pagos01
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        dbms_output.put_line('MARCA02');
        dbms_output.put_line('IF v_tipmon = v_monnac THEN'
                             || v_tipmon
                             || '='
                             || v_monnac);
        dbms_output.put_line('saldo ==> '
                             || v_importe
                             || '-'
                             || v_pagos01);
        dbms_output.put_line('saldome ==> 0');
        dbms_output.put_line('saldomn ==> '
                             || v_importe
                             || '-'
                             || v_pagos01);
    END IF;
--

    IF ( v_tipmon <> v_monnac ) THEN
        UPDATE dcta100
        SET
            saldo = v_importe - v_pagos02,
            saldomn = 0,
            saldome = v_importe - v_pagos02
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

--    dbms_output.put_line('IF v_tipmon <> v_monnac THEN'
--                         || v_tipmon
--                         || '<>'
--                         || v_monnac);
--    dbms_output.put_line('saldo ==> '
--                         || v_importe
--                         || '-'
--                         || v_pagos02);
--    dbms_output.put_line('saldomn ==> 0');
--    dbms_output.put_line('saldome ==> '
--                         || v_importe
--                         || '-'
--                         || v_pagos02);

    END IF;

    -- ACTUALIZANDO LA FECHA DE CANCELACION
    BEGIN
        SELECT
            MAX(femisi)
        INTO v_date
        FROM
            dcta101
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint
            AND tipcan < 50;

        UPDATE dcta100
        SET
            fcance = v_date
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

EXCEPTION
    WHEN pkg_exceptionuser.ex_saldo_en_negativo THEN
        raise_application_error(pkg_exceptionuser.saldo_en_negativo, pout_mensaje);
    WHEN pkg_exceptionuser.ex_saldo_mayor THEN
        raise_application_error(pkg_exceptionuser.saldo_saldo_mayor, 'Se ha calculado un saldo mayor al importe del documento.');
END sp_actualiza_saldo_dcta100;

/
