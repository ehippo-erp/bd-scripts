--------------------------------------------------------
--  DDL for Package Body PACK_RETENCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_RETENCION" AS

    FUNCTION sp_regimen_retencion (
        pin_id_cia NUMBER,
        pin_codigo NUMBER,
        pin_codcli VARCHAR2,
        pin_fhasta DATE
    ) RETURN datatable_regimen_retencion
        PIPELINED
    AS
        v_table datatable_regimen_retencion;
    BEGIN
        IF pin_codcli IS NULL THEN
            SELECT
                nvl(tope, 0),
                nvl(tasa, 0)
            BULK COLLECT
            INTO v_table
            FROM
                regimen_retenciones_vigencia
            WHERE
                    id_cia = pin_id_cia
                AND finicio <= pin_fhasta
                AND codigo = pin_codigo
            ORDER BY
                finicio DESC
            FETCH NEXT 1 ROWS ONLY;

        ELSE
            SELECT
                nvl(r.tope, 0),
                nvl(r.tasa, 0)
            BULK COLLECT
            INTO v_table
            FROM
                     regimen_retenciones_vigencia r
                INNER JOIN cliente c ON c.id_cia = r.id_cia
                                        AND c.regret = r.codigo
                                        AND c.codcli = pin_codcli
            WHERE
                    r.id_cia = pin_id_cia
                AND finicio <= pin_fhasta
            ORDER BY
                finicio DESC
            FETCH NEXT 1 ROWS ONLY;

        END IF;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_regimen_retencion;

    PROCEDURE sp_contabilizar (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        o            json_object_t;
        pout_mensaje VARCHAR2(1000 CHAR);
        v_mensaje    VARCHAR2(1000 CHAR);
        rec_retenhea retenhea%rowtype;
        rec_retendet retendet%rowtype;
        reg_asiendet asiendet%rowtype;
    BEGIN
        BEGIN
            SELECT
                h.*
            INTO rec_retenhea
            FROM
                retenhea h
            WHERE
                    h.id_cia = pin_id_cia
                AND h.numint = pin_numint
                AND EXISTS (
                    SELECT
                        d.*
                    FROM
                        retendet d
                    WHERE
                            d.id_cia = h.id_cia
                        AND d.numint = h.numint
                );

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'EL REGISTRO DE RETENCION CON NUMERO INTERNO [ '
                                || pin_numint
                                || ' ] NO TIENE DETALLE, O NO EXISTE';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        -- 1 : MODULO CONTABILIDAD 
        sp_chequea_mes_proceso(rec_retenhea.id_cia, rec_retenhea.periodo, rec_retenhea.mes, 1, v_mensaje);

        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('Secuencia ==> ' || rec_retenhea.asiento);
        IF rec_retenhea.asiento = 0 THEN
            sp00_saca_secuencia_libro(rec_retenhea.id_cia, rec_retenhea.libro, rec_retenhea.periodo, rec_retenhea.mes, pin_coduser,
                                     1, rec_retenhea.asiento);

            dbms_output.put_line('Secuencia ==> ' || rec_retenhea.asiento);
        ELSE
            DELETE FROM movimientos
            WHERE
                    id_cia = rec_retenhea.id_cia
                AND libro = rec_retenhea.libro
                AND periodo = rec_retenhea.periodo
                AND mes = rec_retenhea.mes
                AND asiento = rec_retenhea.asiento;

            COMMIT;
            DELETE FROM asiendet
            WHERE
                    id_cia = rec_retenhea.id_cia
                AND libro = rec_retenhea.libro
                AND periodo = rec_retenhea.periodo
                AND mes = rec_retenhea.mes
                AND asiento = rec_retenhea.asiento;

            COMMIT;
            DELETE FROM asienhea
            WHERE
                    id_cia = rec_retenhea.id_cia
                AND libro = rec_retenhea.libro
                AND periodo = rec_retenhea.periodo
                AND mes = rec_retenhea.mes
                AND asiento = rec_retenhea.asiento;

        END IF;

        UPDATE retenhea
        SET
            asiento = rec_retenhea.asiento,
            situac = 1
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;


         -- GENERA ASIENTO 
        INSERT INTO asienhea (
            id_cia,
            periodo,
            mes,
            libro,
            asiento,
            concep,
            codigo,
            nombre,
            motivo,
            tasien,
            moneda,
            fecha,
            tcamb01,
            tcamb02,
            ncontab,
            situac,
            usuari,
            fcreac,
            factua,
            usrlck,
            codban,
            referencia,
            girara,
            serret,
            numret,
            ucreac
        ) VALUES (
            rec_retenhea.id_cia,
            rec_retenhea.periodo,
            rec_retenhea.mes,
            rec_retenhea.libro,
            rec_retenhea.asiento,
            'COMPROBANTE DE RETENCION '
            || rec_retenhea.serie
            || ' - '
            || rec_retenhea.numero,
            rec_retenhea.codigo,
            rec_retenhea.razonc,
            '',
            66, -- X validar
            rec_retenhea.moneda,
            rec_retenhea.femisi,
            rec_retenhea.tcamb01,
            rec_retenhea.tcamb02,
            0,
            1,-- ESTADO POR PROCESAR ....
            pin_coduser,
            current_timestamp,
            current_timestamp,
            '',
            '',
            '',
            rec_retenhea.serie,
            rec_retenhea.numero,
            0,
            pin_coduser
        );

        BEGIN
            SELECT
                SUM(retencion)   AS retencion,
                SUM(retencion01) AS retencion01,
                SUM(retencion02) AS retencion02
            INTO
                rec_retendet.retencion,
                rec_retendet.retencion01,
                rec_retendet.retencion02
            FROM
                retendet
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

        END;

        IF rec_retenhea.dhret = 'H' THEN
            reg_asiendet.debe := 0;
            reg_asiendet.debe01 := 0;
            reg_asiendet.debe02 := 0;
            reg_asiendet.haber := rec_retendet.retencion;
            reg_asiendet.haber01 := rec_retendet.retencion01;
            reg_asiendet.haber02 := rec_retendet.retencion02;
        ELSE
            reg_asiendet.debe := rec_retendet.retencion;
            reg_asiendet.debe01 := rec_retendet.retencion01;
            reg_asiendet.debe02 := rec_retendet.retencion02;
            reg_asiendet.haber := 0;
            reg_asiendet.haber01 := 0;
            reg_asiendet.haber02 := 0;
        END IF;

        -- GENERANDO DETALLE DEL ASIENTO -- CUENTA DE RETENCION
        INSERT INTO asiendet (
            id_cia,--01
            periodo,--02
            mes,--03
            libro,--04
            asiento,--05
            item,--06
            sitem,--07
            concep,--08
            fecha,--09
            tasien,--10
            topera,--11
            cuenta,--12
            dh,--13
            moneda,--14
            importe,--15
            impor01,--16
            impor02,--17
            debe,--18
            debe01,--19
            debe02,--20
            haber,--21
            haber01,--22
            haber02,--23
            tcambio01,--24
            tcambio02,--25
            ccosto,--26
            proyec,--27
            subcco,--28
            ctaalternativa,--29
            tipo,--30
            docume,--31
            codigo,--32
            razon,--33
            tident,--34
            dident,--35
            tdocum,--36
            serie,--37
            numero,--38
            fdocum,--39
            usuari,--40
            fcreac,--41
            factua,--42
            regcomcol,--43
            swprovicion,--44
            saldo,--45
            swgasoper,--46
            codporret,--47
            swchkconcilia--48
        ) VALUES (
            rec_retenhea.id_cia,
            rec_retenhea.periodo,
            rec_retenhea.mes,
            rec_retenhea.libro,
            rec_retenhea.asiento,
            1,
            0,
            'COMPROBANTE DE RETENCION '
            || rec_retenhea.serie
            || ' - '
            || rec_retenhea.numero,
            rec_retenhea.femisi,
            NULL, --reg_asiendet.tasien,
            NULL, --reg_asiendet.topera,
            rec_retenhea.cuentaret,
            rec_retenhea.dhret,
            rec_retenhea.moneda,
            rec_retendet.retencion,
            rec_retendet.retencion01,
            rec_retendet.retencion02,
            reg_asiendet.debe,
            reg_asiendet.debe01,
            reg_asiendet.debe02,
            reg_asiendet.haber,
            reg_asiendet.haber01,
            reg_asiendet.haber02,
            rec_retenhea.tcamb01,
            rec_retenhea.tcamb02,
            NULL, --reg_asiendet.ccosto,
            NULL, --reg_asiendet.proyec,
            NULL, --reg_asiendet.subcco,
            NULL, --reg_asiendet.ctaalternativa,
            NULL, --reg_asiendet.tipo,
            NULL, --reg_asiendet.docume,
            rec_retenhea.codigo,
            rec_retenhea.razonc,
            NULL, --reg_asiendet.tident,
            NULL, --reg_asiendet.dident,
            NULL, --reg_asiendet.tdocum,
            rec_retenhea.serie,
            rec_retenhea.numero,
            rec_retenhea.femisi,
            pin_coduser,
            current_timestamp,
            current_timestamp,
            NULL, --reg_asiendet.regcomcol,
            'S',
            NULL, --reg_asiendet.saldo,
            1,
            NULL,
            'N'
        );

        IF rec_retenhea.dhret = 'H' THEN
            reg_asiendet.debe := rec_retendet.retencion;
            reg_asiendet.debe01 := rec_retendet.retencion01;
            reg_asiendet.debe02 := rec_retendet.retencion02;
            reg_asiendet.haber := 0;
            reg_asiendet.haber01 := 0;
            reg_asiendet.haber02 := 0;
        ELSE
            reg_asiendet.debe := 0;
            reg_asiendet.debe01 := 0;
            reg_asiendet.debe02 := 0;
            reg_asiendet.haber := rec_retendet.retencion;
            reg_asiendet.haber01 := rec_retendet.retencion01;
            reg_asiendet.haber02 := rec_retendet.retencion02;
        END IF;

        -- GENERANDO DETALLE DEL ASIENTO -- CUENTA DE IGV
        INSERT INTO asiendet (
            id_cia,--01
            periodo,--02
            mes,--03
            libro,--04
            asiento,--05
            item,--06
            sitem,--07
            concep,--08
            fecha,--09
            tasien,--10
            topera,--11
            cuenta,--12
            dh,--13
            moneda,--14
            importe,--15
            impor01,--16
            impor02,--17
            debe,--18
            debe01,--19
            debe02,--20
            haber,--21
            haber01,--22
            haber02,--23
            tcambio01,--24
            tcambio02,--25
            ccosto,--26
            proyec,--27
            subcco,--28
            ctaalternativa,--29
            tipo,--30
            docume,--31
            codigo,--32
            razon,--33
            tident,--34
            dident,--35
            tdocum,--36
            serie,--37
            numero,--38
            fdocum,--39
            usuari,--40
            fcreac,--41
            factua,--42
            regcomcol,--43
            swprovicion,--44
            saldo,--45
            swgasoper,--46
            codporret,--47
            swchkconcilia--48
        ) VALUES (
            rec_retenhea.id_cia,
            rec_retenhea.periodo,
            rec_retenhea.mes,
            rec_retenhea.libro,
            rec_retenhea.asiento,
            2,
            0,
            'COMPROBANTE DE RETENCION '
            || rec_retenhea.serie
            || ' - '
            || rec_retenhea.numero,
            rec_retenhea.femisi,
            NULL, --reg_asiendet.tasien,
            NULL, --reg_asiendet.topera,
            rec_retenhea.cuentaigv,
            decode(rec_retenhea.dhret, 'D', 'H', 'D'),
            rec_retenhea.moneda,
            rec_retendet.retencion,
            rec_retendet.retencion01,
            rec_retendet.retencion02,
            reg_asiendet.debe,
            reg_asiendet.debe01,
            reg_asiendet.debe02,
            reg_asiendet.haber,
            reg_asiendet.haber01,
            reg_asiendet.haber02,
            rec_retenhea.tcamb01,
            rec_retenhea.tcamb02,
            NULL, --reg_asiendet.ccosto,
            NULL, --reg_asiendet.proyec,
            NULL, --reg_asiendet.subcco,
            NULL, --reg_asiendet.ctaalternativa,
            NULL, --reg_asiendet.tipo,
            NULL, --reg_asiendet.docume,
            rec_retenhea.codigo,
            rec_retenhea.razonc,
            NULL, --reg_asiendet.tident,
            NULL, --reg_asiendet.dident,
            NULL, --reg_asiendet.tdocum,
            rec_retenhea.serie,
            rec_retenhea.numero,
            rec_retenhea.femisi,
            pin_coduser,
            current_timestamp,
            current_timestamp,
            NULL, --reg_asiendet.regcomcol,
            'S',
            NULL, --reg_asiendet.saldo,
            1,
            NULL,
            'N'
        );

        COMMIT;
        -- CONTABILIZANDO / TRANLADANDO A MOVIMIENTOS
        sp_contabilizar_asiento(rec_retenhea.id_cia, rec_retenhea.libro, rec_retenhea.periodo, rec_retenhea.mes, rec_retenhea.asiento
        ,
                               pin_coduser, v_mensaje);

        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN -- ASIENTO NO CONTABILIZADO
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        ELSE
            -- CONTABILIZANDO ASIENTO
            UPDATE asienhea
            SET
                situac = 2,
                factua = current_timestamp,
                usuari = pin_coduser
            WHERE
                    id_cia = rec_retenhea.id_cia
                AND periodo = rec_retenhea.periodo
                AND mes = rec_retenhea.mes
                AND libro = rec_retenhea.libro
                AND asiento = rec_retenhea.asiento;

            UPDATE retenhea
            SET
                situac = 2
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

            COMMIT;
        END IF;

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

        WHEN OTHERS THEN
            pout_mensaje := 'mensaje : '
                            || sqlerrm
                            || ' codigo :'
                            || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_contabilizar;

    PROCEDURE sp_descontabilizar (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        o            json_object_t;
        pout_mensaje VARCHAR2(1000 CHAR);
        v_mensaje    VARCHAR2(1000 CHAR);
        rec_retenhea retenhea%rowtype;
        rec_retendet retendet%rowtype;
        reg_asiendet asiendet%rowtype;
    BEGIN
        BEGIN
            SELECT
                h.*
            INTO rec_retenhea
            FROM
                retenhea h
            WHERE
                    h.id_cia = pin_id_cia
                AND h.numint = pin_numint;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'EL REGISTRO DE RETENCION CON NUMERO INTERNO [ '
                                || pin_numint
                                || ' ] NO EXISTE';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        sp_descontabilizar_asiento(rec_retenhea.id_cia, rec_retenhea.libro, rec_retenhea.periodo, rec_retenhea.mes, rec_retenhea.asiento
        ,
                                  pin_coduser, v_mensaje);

        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        ELSE
            UPDATE retenhea
            SET
                situac = 1
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

        END IF;

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

        WHEN OTHERS THEN
            pout_mensaje := 'mensaje : '
                            || sqlerrm
                            || ' codigo :'
                            || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_descontabilizar;

    PROCEDURE sp_anular (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        o            json_object_t;
        pout_mensaje VARCHAR2(1000 CHAR);
        v_mensaje    VARCHAR2(1000 CHAR);
        rec_retenhea retenhea%rowtype;
        rec_retendet retendet%rowtype;
        reg_asiendet asiendet%rowtype;
    BEGIN
        BEGIN
            SELECT
                h.*
            INTO rec_retenhea
            FROM
                retenhea h
            WHERE
                    h.id_cia = pin_id_cia
                AND h.numint = pin_numint;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'EL REGISTRO DE RETENCION CON NUMERO INTERNO [ '
                                || pin_numint
                                || ' ] NO EXISTE';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

                -- 1 : MODULO CONTABILIDAD 
        sp_chequea_mes_proceso(rec_retenhea.id_cia, rec_retenhea.periodo, rec_retenhea.mes, 1, v_mensaje);

        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        DELETE FROM movimientos
        WHERE
                id_cia = rec_retenhea.id_cia
            AND libro = rec_retenhea.libro
            AND periodo = rec_retenhea.periodo
            AND mes = rec_retenhea.mes
            AND asiento = rec_retenhea.asiento;

        UPDATE asienhea
        SET
            situac = 9
        WHERE
                id_cia = rec_retenhea.id_cia
            AND libro = rec_retenhea.libro
            AND periodo = rec_retenhea.periodo
            AND mes = rec_retenhea.mes
            AND asiento = rec_retenhea.asiento;

        UPDATE retenhea
        SET
            serie = NULL,
            numero = 0,
            situac = 9
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

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

        WHEN OTHERS THEN
            pout_mensaje := 'mensaje : '
                            || sqlerrm
                            || ' codigo :'
                            || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_anular;

END;

/
