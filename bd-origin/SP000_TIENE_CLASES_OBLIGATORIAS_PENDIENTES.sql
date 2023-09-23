--------------------------------------------------------
--  DDL for Procedure SP000_TIENE_CLASES_OBLIGATORIAS_PENDIENTES
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_TIENE_CLASES_OBLIGATORIAS_PENDIENTES" (
    pin_id_cia                 IN   NUMBER,
    pin_numint                 IN   NUMBER,
    pin_swmuestrapout_mensaje  IN   VARCHAR2,
    pout_swresultado           OUT  VARCHAR2,
    pout_mensaje               OUT  VARCHAR2
) AS

    v_conteo     NUMBER := 0;
    v_descri     VARCHAR2(30) := '';
    v_tipdoc     NUMBER := 0;
    v_series     VARCHAR2(5) := '';
    v_numdoc     NUMBER := 0;
    v_mensaje    VARCHAR(1000) := '';
    v_resultado  VARCHAR(1) := 'N';
BEGIN
    BEGIN
        SELECT
            COUNT(0) AS conteo,
            d.descri,
            dc.tipdoc,
            dc.series,
            dc.numdoc
        INTO
            v_conteo,
            v_descri,
            v_tipdoc,
            v_series,
            v_numdoc
        FROM
            documentos_cab_clase  cc
            LEFT OUTER JOIN documentos_cab        dc ON dc.id_cia = pin_id_cia
                                                 AND dc.numint = cc.numint
            LEFT OUTER JOIN documentos            d ON d.id_cia = pin_id_cia
                                            AND d.codigo = dc.tipdoc
                                            AND d.series = dc.series
            LEFT OUTER JOIN clase_documentos_cab  cdc ON cdc.id_cia = pin_id_cia
                                                        AND cdc.tipdoc = dc.tipdoc
                                                        AND cdc.clase = cc.clase
        WHERE
                cc.id_cia = pin_id_cia
            AND cc.numint = pin_numint
            AND cc.codigo = 'ND'
            AND cdc.swcodigo = 'S'
        GROUP BY
            d.descri,
            dc.tipdoc,
            dc.series,
            dc.numdoc;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := 0;
            v_descri := '';
            v_tipdoc := 0;
            v_series := '';
            v_numdoc := 0;
    END;

    IF ( v_conteo IS NULL ) THEN
        v_conteo := 0;
    END IF;
    IF ( v_descri IS NULL ) THEN
        v_descri := '';
    END IF;
    IF ( v_tipdoc IS NULL ) THEN
        v_tipdoc := 0;
    END IF;
    IF ( v_numdoc IS NULL ) THEN
        v_numdoc := 0;
    END IF;
    IF ( v_series IS NULL ) THEN
        v_series := '';
    END IF;
    
    IF ( v_conteo > 0 ) THEN
        v_resultado := 'S';
        IF ( upper(pin_swmuestrapout_mensaje) = 'S' ) THEN
            v_mensaje := 'El documento '
                         || v_descri
                         || ' '
                         || v_series
                         || '-'
                         || to_char(v_numdoc)
                         || ' Tiene '
                         || to_char(v_conteo)
                         || ' clases obligatorias pendientes de completar';

        END IF;

    END IF;
    v_resultado := 'S';
    pout_swresultado := v_resultado;
    pout_mensaje := v_mensaje;
END sp000_tiene_clases_obligatorias_pendientes;

/
