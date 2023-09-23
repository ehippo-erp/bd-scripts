--------------------------------------------------------
--  DDL for Procedure SP_GENERA_ASIENTOS_CXCOBRAR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_GENERA_ASIENTOS_CXCOBRAR" (
    pin_id_cia    IN NUMBER,
    pin_libro     IN VARCHAR2,
    pin_periodo   IN NUMBER,
    pin_mes       IN NUMBER,
    pin_secuencia IN NUMBER,
    pin_usuario   IN VARCHAR2,
    pin_mensaje   OUT VARCHAR2
) AS

    o           json_object_t;
    v_femisi    DATE;
    v_moneda    VARCHAR2(5);
    v_tcambio01 NUMERIC(14, 6) := 0;
    v_tcambio02 NUMERIC(14, 6) := 0;
    v_importe   NUMERIC(16, 2) := 0;
    v_impor01   NUMERIC(16, 2) := 0;
    v_impor02   NUMERIC(16, 2) := 0;
    v_item      INTEGER := 0;
    v_dh        VARCHAR2(1) := '';
    v_msj       VARCHAR2(1000);
    v_mensaje   VARCHAR2(1000) := '';
    v_proceso   NUMBER := 0;
    v_concep    VARCHAR2(150) := '';
    CURSOR cur_detalleasiento IS
    SELECT
        id_cia,
        periodo,
        mes,
        libro,
        asiento,
        item,
        sitem,
        concep,
        fecha,
        tasien,
        topera,
        cuenta,
        dh,
        moneda,
        importe,
        impor01,
        impor02,
        debe,
        debe01,
        debe02,
        haber,
        haber01,
        haber02,
        tcambio01,
        tcambio02,
        ccosto,
        proyec,
        subcco,
        tipo,
        docume,
        codigo,
        razon,
        tident,
        dident,
        tdocum,
        serie,
        numero,
        fdocum,
        usuari,
        fcreac,
        factua,
        regcomcol,
        swprovicion,
        saldo,
        swgasoper,
        codporret,
        swchkconcilia,
        ctaalternativa
    FROM
        TABLE ( sp_contabilidad_cuentas_para_asientos_cxcobrar(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                                                               pin_usuario) );

BEGIN
    IF pin_libro = '98' THEN
        dbms_output.put_line('NO GENERA ASIENTO CONTABLE');
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'LIBRO DE REGULARIZACIÓN DE SALDOS - NO GENERA ASIENTO CONTABLE'
            )
        INTO pin_mensaje
        FROM
            dual;

        RETURN;
    END IF;

    dbms_output.put_line('GENERA ASIENTO CONTABLE');
    BEGIN
        SELECT
            femisi,
            TRIM(tipmon),
            concep
        INTO
            v_femisi,
            v_moneda,
            v_concep
        FROM
            dcta102
        WHERE
                id_cia = pin_id_cia
            AND libro = pin_libro
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND secuencia = pin_secuencia;

    EXCEPTION
        WHEN no_data_found THEN
            v_femisi := NULL;
            v_moneda := NULL;
            v_concep := NULL;
    END;

    IF (
        ( v_femisi IS NULL )
        AND ( v_moneda IS NULL )
    ) THEN
        BEGIN
            SELECT
                femisi,
                TRIM(tipmon),
                concep
            INTO
                v_femisi,
                v_moneda,
                v_concep
            FROM
                prov102
            WHERE
                    id_cia = pin_id_cia
                AND libro = pin_libro
                AND periodo = pin_periodo
                AND mes = pin_mes
                AND secuencia = pin_secuencia;

        EXCEPTION
            WHEN no_data_found THEN
                v_femisi := NULL;
                v_moneda := NULL;
                v_concep := NULL;
        END;
    END IF;
	/*eliminando movimientos*/

    DELETE FROM movimientos
    WHERE
            id_cia = pin_id_cia
        AND libro = pin_libro
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND asiento = pin_secuencia;
	/*eliminando asiendet*/

    DELETE FROM asiendet
    WHERE
            id_cia = pin_id_cia
        AND libro = pin_libro
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND asiento = pin_secuencia;	       
	   /*eliminando asienhea*/

    DELETE FROM asienhea
    WHERE
            id_cia = pin_id_cia
        AND libro = pin_libro
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND asiento = pin_secuencia;

	  /*creando AsienHea */

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
        numret
    ) VALUES (
        pin_id_cia,
        pin_periodo,
        pin_mes,
        pin_libro,
        pin_secuencia,
        v_concep,
        ' ',
        ' ',
        ' ',
        66,
        v_moneda,
        v_femisi,
        0,
        0,
        0,
        1,
        pin_usuario,
        sysdate,
        sysdate,
        '',
        '',
        '',
        '',
        '',
        0
    );
    /*Grabando el deposito*/

    FOR reg_asiendet IN cur_detalleasiento LOOP
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
            reg_asiendet.id_cia,
            reg_asiendet.periodo,
            reg_asiendet.mes,
            reg_asiendet.libro,
            reg_asiendet.asiento,
            reg_asiendet.item,
            reg_asiendet.sitem,
            reg_asiendet.concep,
            v_femisi,--reg_asiendet.fecha,
            reg_asiendet.tasien,
            reg_asiendet.topera,
            reg_asiendet.cuenta,
            reg_asiendet.dh,
            reg_asiendet.moneda,
            reg_asiendet.importe,
            reg_asiendet.impor01,
            reg_asiendet.impor02,
            reg_asiendet.debe,
            reg_asiendet.debe01,
            reg_asiendet.debe02,
            reg_asiendet.haber,
            reg_asiendet.haber01,
            reg_asiendet.haber02,
            reg_asiendet.tcambio01,
            reg_asiendet.tcambio02,
            reg_asiendet.ccosto,
            reg_asiendet.proyec,
            reg_asiendet.subcco,
            reg_asiendet.ctaalternativa,
            reg_asiendet.tipo,
            reg_asiendet.docume,
            reg_asiendet.codigo,
            reg_asiendet.razon,
            reg_asiendet.tident,
            reg_asiendet.dident,
            reg_asiendet.tdocum,
            reg_asiendet.serie,
            reg_asiendet.numero,
            reg_asiendet.fdocum,
            reg_asiendet.usuari,
            reg_asiendet.fcreac,
            reg_asiendet.factua,
            reg_asiendet.regcomcol,
            reg_asiendet.swprovicion,
            reg_asiendet.saldo,
            reg_asiendet.swgasoper,
            reg_asiendet.codporret,
            reg_asiendet.swchkconcilia
        );

        COMMIT;
    END LOOP;

    sp_contabilizar_asiento(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                           pin_usuario, v_msj);
    o := json_object_t.parse(v_msj);
    dbms_output.put_line('CONTABILIZAR ASIENTO - ' || o.get_string('message'));
    IF ( o.get_number('status') <> 1.0 ) THEN
        v_proceso := 1;
        v_mensaje := o.get_string('message');
        pin_mensaje := 'Asiento de Cuentas x Cobrar no a podido ser contabilizado por [ '
                       || v_mensaje
                       || ' ] para el Periodo [ '
                       || pin_periodo
                       || ' ], Mes [ '
                       || pin_mes
                       || ' ], Libro [ '
                       || pin_libro
                       || ' ] y Asiento [ '
                       || pin_secuencia
                       || ' ]';

        RAISE pkg_exceptionuser.ex_error_inesperado;
    ELSE
        UPDATE asienhea
        SET
            situac = 2,
            factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS'),
            usuari = pin_usuario
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_libro
            AND asiento = pin_secuencia;

        COMMIT;
    END IF;

    pin_mensaje := 'Asiento de Cuentas x Cobrar generados y contabilizados correctamente para el Periodo [ '
                   || pin_periodo
                   || ' ], Mes [ '
                   || pin_mes
                   || ' ], Libro [ '
                   || pin_libro
                   || ' ] y Asiento [ '
                   || pin_secuencia
                   || ' ]';

    SELECT
        JSON_OBJECT(
            'status' VALUE 1.0,
            'message' VALUE pin_mensaje
        )
    INTO pin_mensaje
    FROM
        dual;

    COMMIT;
EXCEPTION
    WHEN pkg_exceptionuser.ex_error_inesperado THEN
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.1,
                'message' VALUE pin_mensaje
            )
        INTO pin_mensaje
        FROM
            dual;

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

END sp_genera_asientos_cxcobrar;

/
