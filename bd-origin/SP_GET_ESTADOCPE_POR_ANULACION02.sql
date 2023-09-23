--------------------------------------------------------
--  DDL for Function SP_GET_ESTADOCPE_POR_ANULACION02
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_GET_ESTADOCPE_POR_ANULACION02" (
    pin_id_cia    NUMBER,
    pin_numint    NUMBER,
    pin_tipdoc    NUMBER,
    pin_series    VARCHAR2,
    pin_numdoc    NUMBER,
    pin_situac    VARCHAR2,
    pin_estadofe  VARCHAR2
) RETURN VARCHAR2 AS
    estadofe  VARCHAR2(15);
    cont      NUMBER;
    cont2     NUMBER;
    cont3     NUMBER;
BEGIN
    estadofe := pin_estadofe;
/*
  Este procedimiento es empleado para comprobantes
  que luego de haber sido aceptado se anularon
  select *
  from SP_GET_ESTADOCPE_POR_ANULACION(NULL,1,'F001',3251)
*/
    BEGIN
        SELECT
            COUNT(fd.numint)
        INTO cont
        FROM
            fe_comunica_baja_det  fd
            LEFT OUTER JOIN fe_comunica_baja_cab  fc ON ( fc.id_cia = fd.id_cia )
                                                       AND fc.idbaj = fd.idbaj
        WHERE
                fd.id_cia = pin_id_cia
            AND fd.numint = pin_numint
            AND ( fc.tipo = 1 )
            AND ( fc.estado = 'F' );

    EXCEPTION
        WHEN no_data_found THEN
            cont := 0;
    END;

    BEGIN
        SELECT
            COUNT(fd.numint)
        INTO cont2
        FROM
            fe_resumendiario_det  fd
            LEFT OUTER JOIN fe_resumendiario_cab  fc ON ( fc.id_cia = fd.id_cia )
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

    IF ( pin_situac = 'J' ) THEN
        IF ( pin_tipdoc IN (
            1,
            3,
            7,
            8
        ) ) THEN
            BEGIN
                IF ( (
                    substr(pin_series, 1, 1) = 'F' AND cont <> 0
                ) ) THEN
                    BEGIN
                        estadofe := 'Dado de baja';
                    END;
                ELSE
                    IF (
                        ( substr(pin_series, 1, 1) = 'B' ) AND cont2 <> 0
                    ) THEN
                        BEGIN
                            estadofe := 'Dado baja-res';
                        END;
                    END IF;
                END IF;

            END;

        END IF;
    END IF;
    IF (
        ( pin_situac = 'F' ) AND ( pin_tipdoc IN (
            3,
            7,
            8
        ) )
    ) THEN
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
        IF ( cont3 <> 0 ) THEN
            estadofe := 'inc.resumen';
        END IF;
    END IF;

    RETURN estadofe;
END;

/
