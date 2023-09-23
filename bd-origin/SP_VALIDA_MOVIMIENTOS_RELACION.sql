--------------------------------------------------------
--  DDL for Function SP_VALIDA_MOVIMIENTOS_RELACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_VALIDA_MOVIMIENTOS_RELACION" (
    pin_id_cia   INTEGER,
    pin_libro    VARCHAR2,
    pin_periodo  INTEGER,
    pin_mes      INTEGER,
    pin_asiento  INTEGER
) RETURN VARCHAR2 IS

    v_numint  INTEGER := 0;
    v_tipdoc  INTEGER := 0;
    v_series  VARCHAR2(5) := '';
    v_numdoc  INTEGER := 0;
    v_femisi  DATE;
    v_codcli  VARCHAR2(20) := '';
    v_tident  VARCHAR2(2) := '';
    v_dident  cliente.dident%type := '';
    v_razonc  VARCHAR2(80) := '';
    msj       VARCHAR2(3996) := '';
BEGIN
    BEGIN
        SELECT DISTINCT
            mr.numint,
            dc.tipdoc,
            dc.series,
            dc.numdoc,
            dc.femisi,
            dc.codcli,
            c.tident,
            dc.ruc,
            dc.razonc
        INTO
            v_numint,
            v_tipdoc,
            v_series,
            v_numdoc,
            v_femisi,
            v_codcli,
            v_tident,
            v_dident,
            v_razonc
        FROM
            movimientos_relacion  mr
            LEFT OUTER JOIN documentos_cab        dc ON ( dc.id_cia = mr.id_cia )
                                                 AND ( dc.numint = mr.numint )
            LEFT OUTER JOIN cliente               c ON c.id_cia = mr.id_cia
                                         AND c.codcli = dc.codcli
        WHERE
                mr.id_cia = pin_id_cia
            AND mr.libro = pin_libro
            AND mr.periodo = pin_periodo
            AND mr.mes = pin_mes
            AND mr.asiento = pin_asiento
            FETCH NEXT 1 ROWS ONLY;

    EXCEPTION
        WHEN no_data_found THEN
            v_numint := NULL;
            v_tipdoc := NULL;
            v_series := NULL;
            v_numdoc := NULL;
            v_femisi := NULL;
            v_codcli := NULL;
            v_tident := NULL;
            v_dident := NULL;
            v_razonc := NULL;
    END;

    IF v_numint IS NULL THEN
        msj := '';
    ELSE
        msj := 'Planilla '
               || pin_libro
               || '-'
               || pin_periodo
               || '-'
               || pin_mes
               || '-'
               || pin_asiento
               || chr(13)
               || ' Se encuentra relacionada con la guia interna ['
               || v_series
               || '-'
               || v_numdoc
               || ']'
               || chr(13)
               || 'Interlocutor comercial : ['
               || v_dident
               || '-'
               || v_razonc
               || ']'
               || chr(13)
               || 'Fecha : '
               || to_char(v_femisi, 'dd-mm-yyyy');
    END IF;

    RETURN msj;
END sp_valida_movimientos_relacion;

/
