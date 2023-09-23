--------------------------------------------------------
--  DDL for Package Body PACK_DCTA101
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DCTA101" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_dcta101
        PIPELINED
    AS
        v_table datatable_dcta101;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            dcta101
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    PROCEDURE deldcta101 (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_mensaje   OUT VARCHAR2
    ) AS
        pout_mensaje VARCHAR2(1000 CHAR);
    BEGIN
        DELETE FROM dcta101
        WHERE
            ( id_cia = pin_id_cia )
            AND NOT ( libro = 'hoa' )
            AND libro = pin_libro
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND secuencia = pin_secuencia;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo : '
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END deldcta101;

    PROCEDURE enviar_ctas_ctes_from_dcta103 (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_usuari    IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    ) AS

        v_operac     VARCHAR2(2) := '';
        v_numbco     VARCHAR2(50);
        v_numite     NUMBER := 1;
        pout_mensaje VARCHAR2(1000 CHAR);
        CURSOR cur_select IS
        SELECT
            p.numint,
            p.libro,
            p.periodo,
            p.mes,
            p.secuencia,
            p.item,
            CASE
                WHEN c.tippla = 136 THEN
                    56
                ELSE
                    p.tipcan
            END                        AS tipcan,
            p.doccan,
            c.codcob,
            p.cuenta,
            p.dh,
            p.tipmon,
            p.amorti,
            p.impor01,
            p.impor02,
            p.tcamb01,
            p.tcamb02,
            p.impor01 * cr.porcom      AS comision,
            c.codsuc,
            pin_usuari,
            'A',
            nvl(c.femisi, p102.femisi) AS femisi,
            d0.codcli
        FROM
            dcta103  p
            LEFT OUTER JOIN dcta102  c ON c.id_cia = p.id_cia
                                         AND c.libro = p.libro
                                         AND c.periodo = p.periodo
                                         AND c.mes = p.mes
                                         AND c.secuencia = p.secuencia
            LEFT OUTER JOIN prov102  p102 ON p102.id_cia = p.id_cia
                                            AND p102.libro = p.libro
                                            AND p102.periodo = p.periodo
                                            AND p102.mes = p.mes
                                            AND p102.secuencia = p.secuencia
            LEFT OUTER JOIN dcta100  d0 ON d0.id_cia = pin_id_cia
                                          AND d0.numint = p.numint
            LEFT OUTER JOIN cobrador cr ON cr.id_cia = pin_id_cia
                                           AND cr.codcob = c.codcob
        WHERE
            ( p.id_cia = pin_id_cia )
            AND ( p.libro = pin_libro )
            AND ( p.periodo = pin_periodo )
            AND ( p.mes = pin_mes )
            AND ( p.secuencia = pin_secuencia )
            AND NOT ( p.situac = 'J ' );

    BEGIN
        FOR reg IN cur_select LOOP
            BEGIN
                dbms_output.put_line('v_numite antes ==> ' || v_numite);
                dbms_output.put_line('pin_id_cia ==> ' || pin_id_cia);
                dbms_output.put_line('reg.numint ==> ' || reg.numint);
                SELECT
                    trunc((MAX(nvl(numite, 0)) / 1))
                INTO v_numite
                FROM
                    dcta101
                WHERE
                        id_cia = pin_id_cia
                    AND numint = reg.numint;

            EXCEPTION
                WHEN no_data_found THEN
                    v_numite := NULL;
            END;

            IF ( v_numite IS NULL ) THEN
                v_numite := 0;
            END IF;
            v_numite := v_numite + 1;
            BEGIN	
	  /* SE HEREDARA EL OPERAC AL MOMENTO QUE SE INSERTA */
                SELECT
                    numbco
                INTO v_numbco
                FROM
                    dcta100
                WHERE
                        id_cia = pin_id_cia
                    AND numint = reg.numint;

            EXCEPTION
                WHEN no_data_found THEN
                    v_numbco := NULL;
            END;

            BEGIN	
	  /* SE HEREDARA EL OPERAC AL MOMENTO QUE SE INSERTA */
                SELECT
                    operac
                INTO v_operac
                FROM
                    dcta100
                WHERE
                        id_cia = pin_id_cia
                    AND numint = reg.numint;

            EXCEPTION
                WHEN no_data_found THEN
                    v_operac := '';
            END;

            -- SE ACTUALIZA EL VENDEDOR, HEREDA DEL D100
            BEGIN
                FOR i IN (
                    SELECT
                        d103.id_cia,
                        d105.numint  AS numint_let,
                        d105.codven  AS codven_let,
                        d100.numint  AS numint_facbol,
                        d100.codven  AS codven_facbol,
                        dd100.numint AS numint_doc,
                        dd100.codven AS codven_doc
                    FROM
                             dcta103 d103
                        INNER JOIN dcta105 d105 ON d105.id_cia = d103.id_cia
                                                   AND d105.libro = d103.libro
                                                   AND d105.periodo = d103.periodo
                                                   AND d105.mes = d103.mes
                                                   AND d105.secuencia = d103.secuencia
                        INNER JOIN dcta100 d100 ON d100.id_cia = d103.id_cia -- FAC/BOL ORIGEN
                                                   AND d100.numint = d103.numint
                        INNER JOIN dcta100 dd100 ON dd100.id_cia = d105.id_cia -- LETRA
                                                    AND dd100.numint = d105.numint
                    WHERE
                            d103.id_cia = pin_id_cia
                        AND d103.numint = reg.numint 
                        AND d105.tipdoc = 5 -- SOLO PARA LAS LETRAS
                        AND dd100.codven IS NULL -- SOLO PARA LETRAS , SIN CODVEN
                ) LOOP
                    UPDATE dcta100
                    SET
                        codven = i.codven_facbol --FAC/BOL ORIGEN
                    WHERE
                            id_cia = i.id_cia
                        AND numint = i.numint_doc; --LETRA

                END LOOP;
            END;

            INSERT INTO dcta101 (
                id_cia,
                numint,
                numite,
                fproce,
                libro,
                periodo,
                mes,
                secuencia,
                item,
                tipcan,
                doccan,
                operac,
                numbco,
                codcob,
                cuenta,
                dh,
                tipmon,
                importe,
                impor01,
                impor02,
                tcamb01,
                tcamb02,
                comisi,
                codsuc,
                fcreac,
                factua,
                usuari,
                situac,
                femisi,
                codcli,
                codban
            ) VALUES (
                pin_id_cia,
                reg.numint,
                v_numite,
                current_date,
                reg.libro,
                reg.periodo,
                reg.mes,
                reg.secuencia,
                reg.item,
                reg.tipcan,
                reg.doccan,
                v_operac,
                v_numbco,
                reg.codcob,
                reg.cuenta,
                reg.dh,
                reg.tipmon,
                reg.amorti,
                reg.impor01,
                reg.impor02,
                reg.tcamb01,
                reg.tcamb02,
                reg.comision,
                reg.codsuc,
                current_timestamp,
                current_timestamp,
                pin_usuari,
                'A',
                reg.femisi,
                reg.codcli,
                reg.codcob
            );
--
--            dbms_output.put_line('id_cia ==> ' || pin_id_cia);
--            dbms_output.put_line('numint ==> ' || reg.numint);
--            dbms_output.put_line('numite ==> ' || v_numite);
--            dbms_output.put_line('fproce ==> ' || current_date);
--            dbms_output.put_line('libro ==> ' || reg.libro);
--            dbms_output.put_line('periodo ==> ' || reg.periodo);
--            dbms_output.put_line('mes ==> ' || reg.mes);
--            dbms_output.put_line('secuencia ==> ' || reg.secuencia);
--            dbms_output.put_line('item ==> ' || reg.item);
--            dbms_output.put_line('tipcan ==> ' || reg.tipcan);
--            dbms_output.put_line('doccan ==> ' || reg.doccan);
--            dbms_output.put_line('operac ==> ' || v_operac);
--            dbms_output.put_line('numbco ==> ' || v_numbco);
--            dbms_output.put_line('codcob ==> ' || reg.codcob);
--            dbms_output.put_line('cuenta ==> ' || reg.cuenta);
--            dbms_output.put_line('dh ==> ' || reg.dh);
--            dbms_output.put_line('tipmon ==> ' || reg.tipmon);
--            dbms_output.put_line('importe ==> ' || reg.amorti);
--            dbms_output.put_line('impor01 ==> ' || reg.impor01);
--            dbms_output.put_line('impor02 ==> ' || reg.impor02);
--            dbms_output.put_line('tcamb01 ==> ' || reg.tcamb01);
--            dbms_output.put_line('tcamb02 ==> ' || reg.tcamb02);
--            dbms_output.put_line('comisi ==> ' || reg.comision);
--            dbms_output.put_line('codsuc ==> ' || reg.codsuc);
--            dbms_output.put_line('fcreac ==> ' || current_timestamp);
--            dbms_output.put_line('factua ==> ' || current_timestamp);
--            dbms_output.put_line('usuari ==> ' || pin_usuari);
--            dbms_output.put_line('situac ==> ' || 'A');
--            dbms_output.put_line('femisi ==> ' || reg.femisi);
--            dbms_output.put_line('codcli ==> ' || reg.codcli);

            COMMIT;
            sp_actualiza_saldo_dcta100(pin_id_cia, reg.numint);
            COMMIT;
        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo : '
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END enviar_ctas_ctes_from_dcta103;

    PROCEDURE deldcta113 (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_mensaje   OUT VARCHAR2
    ) AS
        pout_mensaje VARCHAR2(1000 CHAR);
    BEGIN
        DELETE FROM dcta113
        WHERE
            ( id_cia = pin_id_cia )
            AND libro = pin_libro
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND secuencia = pin_secuencia;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo : '
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END deldcta113;

    PROCEDURE enviar_ctas_ctes_from_dcta113 (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_usuari    IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    ) AS

        pout_mensaje VARCHAR2(1000 CHAR);
        v_numite     NUMBER := 1;
        CURSOR cur_select IS
        SELECT
            pin_id_cia,
            p.numint,
            p.libro,
            p.periodo,
            p.mes,
            p.secuencia,
            p.item,
            p.tipcan,
            p.doccan,
            c.codcob,
            p.cuenta,
            p.dh,
            p.tipmon,
            p.amorti,
            p.impor01,
            p.impor02,
            p.tcamb01,
            p.tcamb02,
            p.impor01 * cr.porcom AS comision,
            c.codsuc,
            pin_usuari,
            'A',
            c.femisi,
            d0.codcli
        FROM
            dcta113  p
            LEFT OUTER JOIN dcta102  c ON c.id_cia = pin_id_cia
                                         AND c.libro = p.libro
                                         AND c.periodo = p.periodo
                                         AND c.mes = p.mes
                                         AND c.secuencia = p.secuencia
            LEFT OUTER JOIN dcta100  d0 ON d0.id_cia = pin_id_cia
                                          AND d0.numint = p.numint
            LEFT OUTER JOIN cobrador cr ON cr.id_cia = pin_id_cia
                                           AND cr.codcob = c.codcob
        WHERE
            ( p.id_cia = pin_id_cia )
            AND ( p.libro = pin_libro )
            AND ( p.periodo = pin_periodo )
            AND ( p.mes = pin_mes )
            AND ( p.secuencia = pin_secuencia )
            AND NOT ( p.situac = 'J ' );

    BEGIN
        FOR reg IN cur_select LOOP
            v_numite := v_numite + 1;
            INSERT INTO dcta101 (
                id_cia,
                numint,
                numite,
                fproce,
                libro,
                periodo,
                mes,
                secuencia,
                item,
                tipcan,
                doccan,
                codcob,
                cuenta,
                dh,
                tipmon,
                importe,
                impor01,
                impor02,
                tcamb01,
                tcamb02,
                comisi,
                codsuc,
                fcreac,
                factua,
                usuari,
                situac,
                femisi,
                codcli
            ) VALUES (
                pin_id_cia,
                reg.numint,
                v_numite,
                current_date,
                reg.libro,
                reg.periodo,
                reg.mes,
                reg.secuencia,
                reg.item,
                reg.tipcan,
                reg.doccan,
                reg.codcob,
                reg.cuenta,
                reg.dh,
                reg.tipmon,
                reg.amorti,
                reg.impor01,
                reg.impor02,
                reg.tcamb01,
                reg.tcamb02,
                reg.comision,
                reg.codsuc,
                current_timestamp,
                current_timestamp,
                pin_usuari,
                'A',
                reg.femisi,
                reg.codcli
            );

            COMMIT;
            sp_actualiza_saldo_dcta100(pin_id_cia, reg.numint);
            COMMIT;
        END LOOP;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo : '
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END enviar_ctas_ctes_from_dcta113;

END pack_dcta101;

/
