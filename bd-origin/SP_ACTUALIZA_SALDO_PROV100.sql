--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_SALDO_PROV100
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_SALDO_PROV100" (
    pin_id_cia IN NUMBER,
    pin_tipo   IN NUMBER,
    pin_docu   IN NUMBER
) AS

    v_operac     NUMBER;
    v_codban     NUMBER;
    v_tipdoc     VARCHAR2(2);
    v_tipo       NUMBER;
    v_docu       NUMBER;
    v_monnac     VARCHAR2(5) := 'PEN';
    v_monext     VARCHAR2(5) := 'USD';
    v_tipmon     VARCHAR2(5);
    v_numbco     VARCHAR2(50);
    v_importe    NUMERIC(16, 2) := 0;
    v_pagosd01   NUMERIC(16, 2) := 0;
    v_pagosd02   NUMERIC(16, 2) := 0;
    v_pagosh01   NUMERIC(16, 2) := 0;
    v_pagosh02   NUMERIC(16, 2) := 0;
    v_pagos01    NUMERIC(16, 2) := 0;
    v_pagos02    NUMERIC(16, 2) := 0;
    v_refere01   VARCHAR2(25);
    v_refere02   VARCHAR2(25);
    v_signo      NUMBER;
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
            c.tipo,
            c.docu,
            c.tipdoc,
            t.signo,
            TRIM(c.tipmon),
            c.importe
        INTO
            v_tipo,
            v_docu,
            v_tipdoc,
            v_signo,
            v_tipmon,
            v_importe
        FROM
            prov100 c
            LEFT OUTER JOIN tdocume t ON t.id_cia = pin_id_cia
                                         AND t.codigo = c.tipdoc
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipo = pin_tipo
            AND c.docu = pin_docu;

    EXCEPTION
        WHEN no_data_found THEN
            v_tipo := NULL;
            v_docu := NULL;
            v_tipdoc := NULL;
            v_signo := NULL;
            v_tipmon := NULL;
            v_importe := NULL;
    END;

    IF ( v_importe IS NULL ) THEN
        v_importe := 0;
    END IF;
    BEGIN
        SELECT
            p.tipo,
            p.docu,
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
            v_tipo,
            v_docu,
            v_pagosh01,
            v_pagosh02,
            v_pagosd01,
            v_pagosd02
        FROM
            prov101 p
        WHERE
                p.id_cia = pin_id_cia
            AND ( p.tipo = pin_tipo )
            AND ( p.docu = pin_docu )
            AND ( NOT ( ( p.tipcan >= 50 )
                        AND ( p.tipcan <= 60 ) ) )
        GROUP BY
            p.tipo,
            p.docu;

    EXCEPTION
        WHEN no_data_found THEN
            v_tipo := NULL;
            v_docu := NULL;
            v_pagosh01 := 0;
            v_pagosh02 := 0;
            v_pagosd01 := 0;
            v_pagosd02 := 0;
    END;

    IF ( v_signo = -1 ) THEN  -- 07-NOTA DE CREDITO , 97-NOTA DE CREDITO NO DOMIC , A1-ANTICIPO 
        v_pagos01 := v_pagosh01 - v_pagosd01;  -- ESTO ES AL REVEZ QUE PROV101 
        v_pagos02 := v_pagosh02 - v_pagosd02;
    ELSE
        v_pagos01 := v_pagosd01 - v_pagosh01; -- ESTO ES AL REVEZ QUE PROV101 
        v_pagos02 := v_pagosd02 - v_pagosh02;
    END IF;

    IF ( v_pagos01 IS NULL ) THEN
        v_pagos01 := 0;
    END IF;
    IF ( v_pagos02 IS NULL ) THEN
        v_pagos02 := 0;
    END IF;

-- VALIDACION PARA QUE NO ACTUALICE SALDOS EN NEGATIVO
--     SE REALIZA ANTES DE CUALQUIER UPDATE
    IF
        v_tipmon = v_monnac
        AND v_importe - v_pagos01 < 0
    THEN
        pout_mensaje := 'ERROR, SE HA CALCULADO UN SALDO EN NEGATIVO, EL DOCUMENTO '
                        || pin_tipo
                        || ' - '
                        || pin_docu
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
                        || pin_tipo
                        || ' - '
                        || pin_docu
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

--   INICIALIZA LOS VALORES .. SE SUPONE QUE ESTE PROCESO DEBE ACTUALIZARLO ..
--   UPDATE PROV100 SET OPERAC=0,CODBAN=0,NUMBCO='',PROTES=0 WHERE TIPO=:ITIPO AND DOCU=:IDOCU;
--   2015-10-02 - Se corrigio por que ahora el NumBco y el CodBan se digita directamente 

    UPDATE prov100
    SET
        operac = 0,
        protes = 0
    WHERE
            id_cia = pin_id_cia
        AND tipo = pin_tipo
        AND docu = pin_docu;

    FOR registro IN (
        SELECT
            c.tipcan AS operac,
            c.codban,
            c.numbco
        FROM
            prov101 c
        WHERE
            ( c.id_cia = pin_id_cia )
            AND ( c.tipo = pin_tipo )
            AND ( c.docu = pin_docu )
            AND ( c.tipcan >= 50 )
            AND ( c.tipcan <= 60 )
    ) LOOP
        v_operac := registro.operac;
        v_codban := registro.codban;
        v_numbco := registro.numbco;
        IF ( v_operac = 55 ) THEN -- PROTESTO.. SE SUPONE QUE ES EL MAYOR VALOR
            UPDATE prov100
            SET
                operac = 0,
                codban = 0,
                numbco = '',
                protes = 1
            WHERE
                    id_cia = pin_id_cia
                AND tipo = pin_tipo
                AND docu = pin_docu;

        END IF;

        IF ( v_operac < 55 ) THEN
            IF ( v_operac IS NULL ) THEN
                v_operac := 0;
            ELSE
                v_operac := v_operac - 50;
            END IF;

            IF ( v_codban IS NULL ) THEN
                v_codban := 0;
            END IF;
            IF ( v_numbco IS NULL ) THEN
                v_numbco := '*';
            END IF;
            UPDATE prov100
            SET
                operac = v_operac,
                codban = v_codban,
                numbco = v_numbco,
                protes = 0
            WHERE
                    id_cia = pin_id_cia
                AND ( tipo = pin_tipo )
                AND ( docu = pin_docu );

        END IF;

    END LOOP;

  /*
    v_refere02 := '';
    FOR registro2 IN (
        SELECT
            c.refere01,
            c.refere02
        FROM
            prov101 c
        WHERE
            ( c.id_cia = pin_id_cia )
            AND ( c.tipo = 601 )
            AND ( c.docu = pin_docu )
    ) LOOP
        v_refere01 := registro2.refere01;
        v_refere02 := registro2.refere02;
        UPDATE prov100
        SET
            refere01 = v_refere01,
            refere02 = v_refere02
        WHERE
                id_cia = pin_id_cia
            AND tipo = pin_tipo
            AND docu = pin_docu;

    END LOOP;

    */

    IF ( v_tipmon = v_monnac ) THEN
        UPDATE prov100
        SET
            saldo = v_importe - v_pagos01,
            saldome = 0,
            saldomn = v_importe - v_pagos01
        WHERE
                id_cia = pin_id_cia
            AND ( tipo = pin_tipo )
            AND ( docu = pin_docu );

    END IF;

    IF ( v_tipmon <> v_monnac ) THEN
        UPDATE prov100
        SET
            saldo = v_importe - v_pagos02,
            saldomn = 0,
            saldome = v_importe - v_pagos02
        WHERE
                id_cia = pin_id_cia
            AND ( tipo = pin_tipo )
            AND ( docu = pin_docu );

    END IF;

    -- ACTUALIZANDO LA FECHA DE CANCELACION
    BEGIN
        SELECT
            MAX(femisi)
        INTO v_date
        FROM
            prov101
        WHERE
                id_cia = pin_id_cia
            AND tipo = pin_tipo
            AND docu = pin_docu;

        UPDATE prov100
        SET
            fcance = v_date
        WHERE
                id_cia = pin_id_cia
            AND tipo = pin_tipo
            AND docu = pin_docu;

    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

EXCEPTION
    WHEN pkg_exceptionuser.ex_saldo_en_negativo THEN
        raise_application_error(pkg_exceptionuser.saldo_en_negativo, pout_mensaje);
    WHEN pkg_exceptionuser.ex_saldo_mayor THEN
        raise_application_error(pkg_exceptionuser.saldo_saldo_mayor, 'Se ha calculado un saldo mayor al importe del documento.');
END sp_actualiza_saldo_prov100;

/
