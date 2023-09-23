--------------------------------------------------------
--  DDL for Procedure SP_GENERA_ASIENTO_HEA_VENTA_DETALLADO_DOCUMENTO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_GENERA_ASIENTO_HEA_VENTA_DETALLADO_DOCUMENTO" (
    pin_id_cia  IN NUMBER,
    pin_tipdoc  IN NUMBER,
    pin_periodo IN NUMBER,
    pin_mes     IN NUMBER,
    pin_coduser IN VARCHAR2,
    pin_mensaje OUT VARCHAR2
) AS

    v_libro         VARCHAR(5);
    facgenasientotg VARCHAR(5);
    situac          VARCHAR(3);
    r_doccab        documentos_cab%rowtype;
    v_concep        VARCHAR2(150);
    v_fecha         DATE;
    v_ultdia        VARCHAR2(2);
    v_msj           VARCHAR2(1000) := '';
    v_codsunat      VARCHAR2(2);
    v_item          NUMBER := 0;
    v_asiento       NUMBER := 1;
    o               json_object_t;
    pout_mensaje    VARCHAR2(1000) := '';
    v_proceso       NUMBER := 0;
--    CURSOR cur_gen_asiento_det (
--        aux_id_cia NUMBER,
--        aux_numint NUMBER
--    ) IS
--    SELECT
--        s.cuenta,
--        s.dh,
--        s.codcli,
--        s.razonc,
--        s.tident,
--        s.ruc,
--        s.femisi,
--        s.series,
--        s.numdoc,
--        s.tipmon,
--        s.tipcam,
--        s.importe01,
--        s.importe02
--    FROM
--        TABLE ( sp_genera_detalle_asiento_venta_documento(aux_id_cia, aux_numint) ) s;

BEGIN
    BEGIN
        SELECT
            codsunat
        INTO v_codsunat
        FROM
            tdoccobranza
        WHERE
                id_cia = pin_id_cia
            AND tipdoc = pin_tipdoc;

    EXCEPTION
        WHEN no_data_found THEN
            v_codsunat := '';
    END;

    CASE
        WHEN pin_tipdoc = 1 THEN
            v_libro := '01';
        WHEN pin_tipdoc = 3 THEN
            v_libro := '07';
        WHEN pin_tipdoc = 7 THEN
            v_libro := '03';
        WHEN pin_tipdoc = 8 THEN
            v_libro := '02';
    END CASE;

    BEGIN
    /*Factor 403 transferencia gratuita */
        SELECT
            vstrg
        INTO facgenasientotg
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 403;

    EXCEPTION
        WHEN no_data_found THEN
            facgenasientotg := '';
    END;

    DELETE FROM movimientos
    WHERE
            id_cia = pin_id_cia
        AND libro = v_libro
        AND periodo = pin_periodo
        AND mes = pin_mes;

    COMMIT;
    DELETE FROM asiendet
    WHERE
            id_cia = pin_id_cia
        AND libro = v_libro
        AND periodo = pin_periodo
        AND mes = pin_mes;

    COMMIT;
    DELETE FROM asienhea
    WHERE
            id_cia = pin_id_cia
        AND libro = v_libro
        AND periodo = pin_periodo
        AND mes = pin_mes;

    COMMIT;

	/*creando asienhea */
    v_concep := 'Reg.Ventas - '
                || lpad(to_char(pin_tipdoc), '0')
                || ' - '
                || ( ( pin_periodo * 100 ) + pin_mes );
/*obtengo ultimo dia del mes */

    v_ultdia := to_char(last_day(to_date(01
                                         || '/'
                                         || pin_mes
                                         || '/'
                                         || pin_periodo, 'DD/MM/YYYY')), 'dd');

    v_fecha := to_date(v_ultdia
                       || '/'
                       || to_char(pin_mes)
                       || '/'
                       || to_char(pin_periodo), 'DD/MM/YYYY');

    FOR i IN (
        SELECT
            dc.femisi,
            dc.numint,
            dc.series,
            dc.numdoc,
            dc.razonc,
            dc.situac
        FROM
            documentos_cab dc
        WHERE
                dc.id_cia = pin_id_cia
            AND EXTRACT(YEAR FROM dc.femisi) = pin_periodo
            AND EXTRACT(MONTH FROM dc.femisi) = pin_mes
            AND dc.tipdoc = pin_tipdoc
            AND dc.situac IN ( 'F',--En Cta.Cte.
             'C' --Con Nota de Credito
             )
        ORDER BY
            tipdoc,
            series,
            numdoc
    ) LOOP
        v_item := 0; -- REGENERAMOS EL ITEM

    -- GENERA ASIENTO POR DOCUMENTOS_CAB 
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
            pin_id_cia,
            pin_periodo,
            pin_mes,
            v_libro,
            v_asiento, -- ASIENTO POR DOCUMENTO / INCREMENTAL
            substr(v_concep
                   || ' - '
                   || i.series
                   || ' - '
                   || i.numdoc
                   || ' - '
                   || i.razonc, 1, 149),
            '',
            '',
            '',
            66,
            'PEN',
            i.femisi,
            1,
            1,
            0,
            1,-- ESTADO POR PROCESAR ....
            pin_coduser,
            current_timestamp,
            current_timestamp,
            '',
            '',
            '',
            '',
            '',
            0,
            pin_coduser
        );

        COMMIT;
        -- GENERANDO DETALLE
        sp_genera_asiento_venta_detallado_documento(pin_id_cia, i.numint, v_libro, pin_periodo, pin_mes,
                                                   v_asiento, v_item, v_codsunat);

        COMMIT;
        -- CONTABILIZANDO / TRANLADANDO A MOVIMIENTOS
        sp_contabilizar_asiento(pin_id_cia, v_libro, pin_periodo, pin_mes, v_asiento,
                               pin_coduser, v_msj);
        COMMIT;
        o := json_object_t.parse(v_msj);
        IF ( o.get_number('status') <> 1.0 ) THEN
            v_proceso := 1; -- ASIENTO NO CONTABILIZADO
        ELSE
            -- CONTABILIZANDO ASIENTO
            UPDATE asienhea
            SET
                situac = 2,
                factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                usuari = pin_coduser
            WHERE
                    id_cia = pin_id_cia
                AND periodo = pin_periodo
                AND mes = pin_mes
                AND libro = v_libro
                AND asiento = v_asiento;

            COMMIT;
        END IF;

        v_asiento := v_asiento + 1; -- AUTOINCREMENTAMOS EL ASIENTO POR DOCUMENTO

    END LOOP;

    COMMIT;
    IF v_proceso = 0 THEN
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Proceso Terminado, Asientos generados y contabilizados correctamente'
            )
        INTO pin_mensaje
        FROM
            dual;

    ELSE
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Proceso Terminado, Sin embargo, algunos asientos no han podido ser contabilizados'
            )
        INTO pin_mensaje
        FROM
            dual;

    END IF;

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

        ROLLBACK;
END sp_genera_asiento_hea_venta_detallado_documento;

/
