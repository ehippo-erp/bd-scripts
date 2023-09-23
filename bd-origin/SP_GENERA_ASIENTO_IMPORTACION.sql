--------------------------------------------------------
--  DDL for Procedure SP_GENERA_ASIENTO_IMPORTACION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_GENERA_ASIENTO_IMPORTACION" (
    pin_id_cia    IN NUMBER,
    pin_periodo   IN NUMBER,
    pin_mes       IN NUMBER,
    pin_dia       IN NUMBER,
    pin_codlib    IN VARCHAR2,
    pin_coduser   IN VARCHAR2,
    pin_numint    IN INTEGER,
    pin_secuencia IN OUT NUMBER,
    pout_message  OUT VARCHAR2
) AS

    CURSOR cur_detalleasiento (
        pconcepto VARCHAR2,
        pseries   VARCHAR2,
        pnumdoc   NUMBER,
        ptipmon   VARCHAR2
    ) IS
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
        TABLE ( sp_contabilidad_cuentas_para_asiento_importacion(pin_id_cia, pin_periodo, pin_mes, pin_dia, pin_codlib,
                                                                 pconcepto, current_date, pseries, pnumdoc, ptipmon,
                                                                 pin_coduser) );

    o               json_object_t;
    smes            VARCHAR2(15);
    serror          VARCHAR2(70) := '';
    v_cierra        NUMBER;
    v_secuencia     NUMBER := 0;
    v_maximo        NUMBER := 0;
    v_razonc        VARCHAR2(100);
    v_tipmon        VARCHAR2(5);
    v_series        VARCHAR2(5);
    v_numdoc        NUMBER;
    totalsoles      NUMERIC(16, 5) := 0;
    totaldolares    NUMERIC(16, 5) := 0;
    v_concepto      VARCHAR2(500 CHAR) := '';
    v_fecha         DATE := TO_DATE ( pin_dia
                              || '/'
                              || pin_mes
                              || '/'
                              || pin_periodo, 'DD/MM/YYYY' );
    v_guardaasiento VARCHAR2(1) := 'N';
    v_msj           VARCHAR2(1000);
    v_mensaje       VARCHAR2(1000);
    pin_mensaje     VARCHAR2(1000);
BEGIN
    pout_message := '';
    BEGIN
        SELECT
            asiento
        INTO v_secuencia
        FROM
            movimientos_relacion_asiento
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

    EXCEPTION
        WHEN no_data_found THEN
            v_secuencia := 0;
    END;

    IF ( v_secuencia IS NULL ) THEN
        v_secuencia := 0;
    END IF;
    DELETE FROM movimientos_relacion_asiento
    WHERE
            id_cia = pin_id_cia
        AND numint = pin_numint;

    BEGIN
        SELECT
            razonc,
            tipmon,
            series,
            numdoc
        INTO
            v_razonc,
            v_tipmon,
            v_series,
            v_numdoc
        FROM
            documentos_cab
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

    EXCEPTION
        WHEN no_data_found THEN
            v_razonc := NULL;
            v_tipmon := NULL;
            v_series := NULL;
            v_numdoc := NULL;
    END;

    BEGIN
        SELECT
            cierre
        INTO v_cierra
        FROM
            cierre
        WHERE
                id_cia = pin_id_cia
            AND sistema = 1 -- 1 = modulo contabilidad
            AND periodo = pin_periodo
            AND mes = pin_mes;

    EXCEPTION
        WHEN no_data_found THEN
            v_cierra := NULL;
    END;
    /* v_cierre = 1 cerrado / v_cierre = 0 abierto*/

    IF ( ( v_cierra IS NULL ) OR ( v_cierra = 1 ) ) THEN
        SELECT
            to_char(sysdate, 'Month', 'nls_date_language=spanish') AS mes
        INTO smes
        FROM
            dual;

        serror := 'Periodo ('
                  || smes
                  || ' '
                  || pin_periodo
                  || ')'
                  || pkg_constantes.kacierres(1)
                  || ' se encuentra cerrado';

        RAISE pkg_exceptionuser.ex_mes_cerrado_contabilidad;
    END IF;

--    v_secuencia := pin_secuencia;
    dbms_output.put_line('v_secuencia ==> ' || v_secuencia);
    IF v_secuencia = 0 THEN
        sp00_saca_secuencia_libro(pin_id_cia, pin_codlib, pin_periodo, pin_mes, pin_coduser,
                                 1, v_secuencia);
        dbms_output.put_line('v_secuencia DESPUES ==> ' || v_secuencia);
    END IF;

    DELETE FROM movimientos
    WHERE
            id_cia = pin_id_cia
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND libro = pin_codlib
        AND asiento = v_secuencia;

    COMMIT;
    DELETE FROM asiendet
    WHERE
            id_cia = pin_id_cia
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND libro = pin_codlib
        AND asiento = v_secuencia;

    COMMIT;
    DELETE FROM asienhea
    WHERE
            id_cia = pin_id_cia
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND libro = pin_codlib
        AND asiento = v_secuencia;

    COMMIT;
    v_concepto := 'Importacion '
                  || v_series
                  || '-'
                  || v_numdoc
                  || ' '
                  || v_razonc
                  || ' '
                  || to_char(pin_periodo)
                  || '/'
                  || lpad(to_char(pin_mes), 2, '0');

    v_concepto := substr(v_concepto, 1, 149);

--    select *
--    from asienhea
--    where id_cia=5 and libro='77' and periodo=2021 and mes=4
    INSERT INTO asienhea (
        id_cia,
        periodo,
        mes,
        libro,
        asiento,
        concep,
        tasien,
        moneda,
        fecha,
        tcamb01,
        tcamb02,
        situac,
        usuari,
        fcreac,
        factua
    ) VALUES (
        pin_id_cia,
        pin_periodo,
        pin_mes,
        pin_codlib,
        v_secuencia,
        v_concepto,
        0,
        v_tipmon,
        v_fecha,
        0,
        0,
        1,
        pin_coduser,
        current_timestamp,
        current_timestamp
    );

    dbms_output.put_line('v_secuencia DESPUES ==> ' || v_concepto);
    dbms_output.put_line('v_secuencia DESPUES ==> ' || v_series);
    dbms_output.put_line('v_secuencia DESPUES ==> ' || v_numdoc);
    dbms_output.put_line('v_secuencia DESPUES ==> ' || v_tipmon);
    FOR reg_asiendet IN cur_detalleasiento(v_concepto, v_series, v_numdoc, v_tipmon) LOOP
        dbms_output.put_line('wii');
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
            v_secuencia,
            reg_asiendet.item,
            reg_asiendet.sitem,
            reg_asiendet.concep,
            reg_asiendet.fecha,
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

    INSERT INTO movimientos_relacion_asiento (
        id_cia,
        numint,
        periodo,
        mes,
        libro,
        asiento,
        dia,
        usuari
    ) VALUES (
        pin_id_cia,
        pin_numint,
        pin_periodo,
        pin_mes,
        pin_codlib,
        v_secuencia,
        pin_dia,
        pin_coduser
    );

    COMMIT;
    pout_message := 'El asiento '
                    || chr(10)
                    || '           Periodo = '
                    || pin_periodo
                    || chr(10)
                    || '           Mes     = '
                    || pin_mes
                    || chr(10)
                    || '           Libro   = '
                    || pin_codlib
                    || chr(10)
                    || '           Asiento   = '
                    || v_secuencia
                    || chr(10)
                    || ' Se generó correctamente ';

    dbms_output.put_line('CONTABILIZAR ASIENTO - INICIO');
    sp_contabilizar_asiento(pin_id_cia, pin_codlib, pin_periodo, pin_mes, v_secuencia,
                           pin_coduser, v_msj);
    o := json_object_t.parse(v_msj);
    dbms_output.put_line('CONTABILIZAR ASIENTO - ' || o.get_string('message'));
    IF ( o.get_number('status') <> 1.0 ) THEN
        v_mensaje := o.get_string('message');
        pin_mensaje := 'ASIENTO DE IMPORTACION [ '
                       || to_char(pin_codlib)
                       || '-'
                       || to_char(pin_periodo)
                       || '-'
                       || to_char(pin_mes)
                       || '-'
                       || to_char(v_secuencia)
                       || ' ] NO A PODIDO SER CONTABILIZADO [ '
                       || v_mensaje
                       || ' ]';

        RAISE pkg_exceptionuser.ex_error_inesperado;
    ELSE
        UPDATE asienhea
        SET
            situac = 2,
            factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS'),
            usuari = pin_coduser
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_codlib
            AND asiento = v_secuencia;

        COMMIT;
    END IF;

    pin_secuencia := v_secuencia;
    SELECT
        JSON_OBJECT(
            'status' VALUE 1.0,
            'message' VALUE 'Success ...!'
        )
    INTO pout_message
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
        INTO pout_message
        FROM
            dual;

    WHEN zero_divide THEN
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.2,
                'message' VALUE 'ERROR, Se a dectectado un costo en 0, revisar el REPORTE DE DISTRIBUCION DE COSTOS, adicionalmente REVISAR que la ORDEN DE COMPRA DE IMPORTACION tenga un importe distinto a CERO para todos sus items'
            )
        INTO pout_message
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
        INTO pout_message
        FROM
            dual;

END sp_genera_asiento_importacion;

/
