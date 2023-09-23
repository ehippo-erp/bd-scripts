--------------------------------------------------------
--  DDL for Procedure SP_PROCESA_KARDEX_Y_COSTOS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_PROCESA_KARDEX_Y_COSTOS" (
    pin_id_cia   IN NUMBER,
    pin_tipinv   IN NUMBER,
    pin_periodo  IN NUMBER,
    pout_mensaje OUT VARCHAR2
) AS

    o                 json_object_t;
    v_periodoanterior NUMBER;
    v_mensaje         VARCHAR2(4000) := '';
    v_pout_mensaje    VARCHAR2(4000) := '';
    v_mes             VARCHAR2(10);
    v_aux             VARCHAR2(10) := '99';
    v_anio            VARCHAR2(10);
    v_fdesde          DATE;
    v_fhasta          DATE;
BEGIN
    v_mes := substr(to_char(pin_periodo, '000000'), -2);
    v_anio := ltrim(substr(to_char(pin_periodo, '000000'), 1, 5));

    IF ( v_mes = '00' ) THEN
        v_mes := '01';
        v_aux := '00';
    END IF;
-- Ultima dia del Mes
    v_fhasta := last_day(trunc(to_date(to_char('01'
                                               || '/'
                                               || v_mes
                                               || '/'
                                               || v_anio), 'DD/MM/YYYY')));
-- Primer dia del Mes
    v_fdesde := to_date(to_char('01'
                                || '/'
                                || v_mes
                                || '/'
                                || v_anio), 'DD/MM/YYYY');

    v_periodoanterior := pin_periodo - 1;
    dbms_output.put_line('INICIO ' || current_timestamp);
    -- REPROCESAMIENTO DEL ARTICULOS_COSTO Y ARTICULOS_COSTO_CODADD
    dbms_output.put_line('ASIGNA COSTOS TOTALES ' || current_timestamp);
    IF ( v_aux <> '00' ) THEN -- NO ES NECESARIO EN LA APERTURA
        sp000_asigna_costos_totales(pin_id_cia, pin_tipinv, v_periodoanterior, v_mensaje);
    END IF;
    
    -- COSTO PROMEDIO
    sp_costo_promedio(pin_id_cia, pin_periodo, pin_tipinv, v_mensaje);
    o := json_object_t.parse(v_mensaje);
    IF ( o.get_number('status') <> 1.0 ) THEN
        v_pout_mensaje := o.get_string('message');
        RAISE pkg_exceptionuser.ex_error_inesperado;
    END IF;

    dbms_output.put_line('COSTO PROMEDIO ' || current_timestamp);
    
    -- CODTO PROMEDIO DE ARTICULOS CON CODADD
    sp_costo_promedio_codadd(pin_id_cia, pin_tipinv, pin_periodo, v_mensaje);
    dbms_output.put_line('CODTO PROMEDIO CODADD ' || current_timestamp);
    -- ACTUALIZA EL KARDEX COSTO VENTA
    IF ( v_aux <> '00' ) THEN -- NO ES NECESARIO EN LA APERTURA
        sp_actualiza_kardex_costoventa(pin_id_cia, v_fdesde, v_fhasta, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            v_pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

    END IF;

    dbms_output.put_line('KARDEX COSTO VENTA ' || current_timestamp);
    -- REPROCESAMIENTO DEL ARTICULOS_COSTO Y ARTICULOS_COSTO_CODADD
    sp000_asigna_costos_totales(pin_id_cia, pin_tipinv, pin_periodo, v_mensaje);
    dbms_output.put_line('COSTOS TOTALES ' || current_timestamp);
    SELECT
        JSON_OBJECT(
            'status' VALUE 1.0,
            'message' VALUE 'El proceso se realizó satisfactoriamente'
        )
    INTO pout_mensaje
    FROM
        dual;

EXCEPTION
    WHEN pkg_exceptionuser.ex_error_inesperado THEN
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.1,
                'message' VALUE v_pout_mensaje
            )
        INTO pout_mensaje
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
        INTO pout_mensaje
        FROM
            dual;

END sp_procesa_kardex_y_costos;

/
