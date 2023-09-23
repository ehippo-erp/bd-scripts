--------------------------------------------------------
--  DDL for Function SP_GET_ESTADOCPE_POR_ANULACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_GET_ESTADOCPE_POR_ANULACION" (
    pin_id_cia   NUMBER,
    pin_numint   NUMBER,
    pin_tipdoc   NUMBER,
    pin_series   VARCHAR2,
    pin_numdoc   NUMBER,
    pin_situac   VARCHAR2,
    pin_codest   NUMBER,
    pin_estadofe VARCHAR2
) RETURN VARCHAR2 AS
    estadofe VARCHAR2(50);
    cont     NUMBER;
    cont2    NUMBER;
    cont3    NUMBER;
BEGIN
    estadofe := pin_estadofe;

--  Este procedimiento es empleado para comprobantes
--  que luego de haber sido aceptado se anularon
--  SELECT sp_get_estadocpe_por_anulacion(66,163524,1,'F001','13546','J',0,'HOLI') FROM DUAL;

    BEGIN
        SELECT
--        MAX(1)
            CASE
                WHEN fc.cdr IS NOT NULL THEN
                    1
                ELSE
                    2
            END
        INTO cont -- IDENTIFICANDO LA COMUNICACION DE BAJA
        FROM
            fe_comunica_baja_det fd
            LEFT OUTER JOIN fe_comunica_baja_cab fc ON ( fc.id_cia = fd.id_cia )
                                                       AND fc.idbaj = fd.idbaj
        WHERE
                fd.id_cia = pin_id_cia
            AND fd.numint = pin_numint
            AND ( fc.tipo = 1 )
            AND ( fc.estado = 'F' )
        ORDER BY
            fc.idbaj DESC
        FETCH NEXT 1 ROWS ONLY;

    EXCEPTION
        WHEN no_data_found THEN
            cont := 0; -- NO TIENE COMUNICACION DE BAJA, PUEDE SER QUE NUNCA SE HIZO, O QUE SUNAT DIRECTAMENTE LO RECHAZO*
    END;

    BEGIN
        SELECT
            COUNT(fd.numint)
        INTO cont2
        FROM
            fe_resumendiario_det fd
            LEFT OUTER JOIN fe_resumendiario_cab fc ON ( fc.id_cia = fd.id_cia )
                                                       AND fc.idres = fd.idres
        WHERE
                fd.id_cia = pin_id_cia
            AND fd.numint = pin_numint
            AND ( fc.tipo = 1 )
            AND ( fc.estado = 'F' );

    EXCEPTION
        WHEN no_data_found THEN
            cont2 := 0;
    END;

    IF
        pin_situac = 'J'
        AND pin_tipdoc IN ( 1, 3, 7, 8 )
    THEN
        IF substr(pin_series, 1, 1) = 'F' THEN
            IF
                cont = 0
                AND pin_codest NOT IN ( 0, 2, 4 ) -- NO TIENE COMUNICACION DE BAJA, NO ESTA NI ENVIADO, NI RECHAZADO, NI BADO DE BAJA
            THEN
                estadofe := 'Pendiente por comunicacion de baja';
            ELSIF
                cont = 0
                AND pin_codest = 4
            THEN -- NO TIENE NINGUNA COMUNICACION DE BAJA, PERO ESTA MARCADO CON SITUACION 4
                estadofe := 'Dado de Baja por Sunat';
            ELSIF cont = 1 THEN -- TIENE COMUNICACION DE BAJA
                estadofe := 'Dado de baja';
            ELSIF cont = 2 THEN -- TIENE COMUNICACION DE BAJA, PERO ESTA EN NULL EL CRD
                estadofe := 'Pendiente - CDR';
            END IF;

        ELSIF substr(pin_series, 1, 1) = 'B' THEN
            IF
                cont2 = 0
                AND pin_codest = 1
            THEN
                estadofe := 'Pendiente de resumen por anulación';
            ELSIF cont2 > 0 THEN
                estadofe := 'Dado baja-res';
            END IF;
        END IF;
    ELSIF
        pin_situac = 'F'
        AND pin_tipdoc IN ( 3, 7, 8 )
    THEN
        BEGIN
            SELECT
                COUNT(0)
            INTO cont3
            FROM
                documentos_cab_envio_sunat dcs
            WHERE
                    dcs.id_cia = pin_id_cia
                AND dcs.numint = pin_numint
                AND ( dcs.estado = 0 )
                AND ( dcs.cres >= 1 );

        EXCEPTION
            WHEN no_data_found THEN
                cont3 := 0;
        END;

        IF cont3 > 0 THEN
            estadofe := 'Aceptado R.Dia'; --'Aceptado-res';
        END IF;
    END IF;

    RETURN estadofe;
END;

/
