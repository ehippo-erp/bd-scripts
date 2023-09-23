--------------------------------------------------------
--  DDL for Procedure SP_GENERA_ASIENTO_VENTA_DETALLADO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_GENERA_ASIENTO_VENTA_DETALLADO" (
    pin_id_cia   IN  NUMBER,
    pin_tipdoc   IN  NUMBER,
    pin_periodo  IN  NUMBER,
    pin_mes      IN  NUMBER,
    pin_coduser  IN  VARCHAR2,
    pin_mensaje OUT VARCHAR2
) AS

    v_libro          VARCHAR(5);
    facgenasientotg  VARCHAR(5);
    situac           VARCHAR(3);
    r_doccab         documentos_cab%rowtype;
    v_concep         VARCHAR2(150);
    v_fecha          DATE;
    v_ultdia         VARCHAR2(2);
    v_msj            VARCHAR2(1000) := '';
    v_codsunat       VARCHAR2(2);
    v_item number:=0;
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
    case 
        when pin_tipdoc = 1 THEN
        v_libro := '01';
        when pin_tipdoc = 3 THEN
        v_libro := '07';
        when pin_tipdoc = 7 THEN
        v_libro := '03';        
        when pin_tipdoc = 8 THEN
        v_libro := '02';           
    end case;    

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
        1, -- siempre es el asiento 1
        v_concep,
        '',
        '',
        '',
        66,
        'PEN',
        v_fecha,
        1,
        1,
        0,
        2,--contabilizado
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

    FOR i IN (
        SELECT
            dc.numint,
            dc.situac
        FROM
            documentos_cab dc
        WHERE
                dc.id_cia = pin_id_cia
            AND EXTRACT(YEAR FROM dc.femisi) = pin_periodo
            AND EXTRACT(MONTH FROM dc.femisi) = pin_mes
            AND dc.tipdoc = pin_tipdoc
            AND dc.situac IN (
                'F',--En Cta.Cte.
                'C' --Con Nota de Credito
            )
        ORDER BY
            tipdoc,
            series,
            numdoc
    ) LOOP
    /*Genera asiento por documento*/

        sp_genera_asiento_venta_detallado_documento(pin_id_cia, i.numint, v_libro, pin_periodo, pin_mes,
                                                      1,v_item,v_codsunat);


    END LOOP;

    COMMIT;
    /* copia asiendet en movimientos*/
    sp_contabilizar_asiento(pin_id_cia, v_libro, pin_periodo, pin_mes, 1,
                            pin_coduser, v_msj);

    pin_mensaje := v_msj; 

END sp_genera_asiento_venta_detallado;

/
