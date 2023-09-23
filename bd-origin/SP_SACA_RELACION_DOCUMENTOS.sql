--------------------------------------------------------
--  DDL for Function SP_SACA_RELACION_DOCUMENTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_SACA_RELACION_DOCUMENTOS" (
    pin_id_cia  NUMBER,
    pin_numint  NUMBER
) RETURN VARCHAR2 IS

    v_numintre  documentos_relacion.numintre%TYPE;
    v_tipdoc    documentos_cab.tipdoc%TYPE;
    v_series    documentos_cab.series%TYPE;
    v_numdoc    documentos_cab.numdoc%TYPE;
    v_abrevi    VARCHAR2(5) := '';
    valor       VARCHAR2(2000) := '';
BEGIN
    FOR r IN (
        SELECT
            r.numintre,
            d.tipdoc,
            d.series,
            d.numdoc
        FROM
                 documentos_relacion r
            INNER JOIN documentos_cab d ON d.id_cia = r.id_cia
                                           AND d.numint = r.numintre
        WHERE
                r.id_cia = pin_id_cia
            AND r.numint = pin_numint
    ) LOOP
        v_abrevi :=
            CASE
                WHEN r.tipdoc = 1 THEN
                    'FA'
                WHEN r.tipdoc = 3 THEN
                    'BV'
                ELSE ''
            END;

        valor := valor
                 || v_abrevi
                 || r.series
                 || '-'
                 || lpad(r.numdoc, 6, '0')
                 || ' ';

    END LOOP;

    RETURN valor;
END sp_saca_relacion_documentos;

/
