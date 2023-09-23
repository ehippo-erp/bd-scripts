--------------------------------------------------------
--  DDL for Function SP000_SACA_SALDOS_ADUANAS_ARTICULOSV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_SALDOS_ADUANAS_ARTICULOSV2" (
    pin_id_cia  IN  INTEGER,
    pin_tipinv  IN  INTEGER,
    pin_codart  IN  VARCHAR2
) RETURN NUMERIC AS
    v_saldo NUMERIC(16, 4) := 0;
BEGIN
    BEGIN
        SELECT
            SUM(nvl(sa.saldo, 0))
        INTO v_saldo
        FROM
            documentos_cab                                                                  c
            LEFT OUTER JOIN documentos_det                                                                  d ON d.id_cia = c.id_cia
                                                AND d.numint = c.numint
            LEFT OUTER JOIN TABLE ( sp_saldo_documentos_det_001(pin_id_cia, d.numint, d.numite) )           sa ON 0 = 0
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 115 /* Documento de Importación */
            AND c.situac IN (
                'B',/*En Deposito*/
                'G'/*Parcialmente Atendida*/
            )
            AND d.tipinv = pin_tipinv
            AND d.codart = pin_codart;

    EXCEPTION
        WHEN no_data_found THEN
            v_saldo := NULL;
    END;

    IF v_saldo IS NULL THEN
        v_saldo := 0;
    END IF;
    RETURN v_saldo;
END sp000_saca_saldos_aduanas_articulosv2;

/
