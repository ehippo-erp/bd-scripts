--------------------------------------------------------
--  DDL for Function SP00_SACA_SALDOS_DOCUMENTOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP00_SACA_SALDOS_DOCUMENTOS" (
    pin_id_cia   NUMBER,
    pin_tipinv   NUMBER,
    pin_codart   VARCHAR2,
    pin_codalm   NUMBER,
    pin_tipdoc   NUMBER,
    pin_sitdoc   VARCHAR2,
    pin_codmot   NUMBER,
    pin_id       VARCHAR2
) RETURN tbl_saldos_documentos
    PIPELINED
AS

    v_saldos_documentos   rec_saldos_documentos := rec_saldos_documentos(NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL);
    numint_refcur         SYS_REFCURSOR;
    v_numint              documentos_cab.numint%TYPE;
    v_cadin               VARCHAR2(100);
    strselect             VARCHAR2(2000);
    CURSOR cur_select (
        pnumint NUMBER
    ) IS
    SELECT
        dd.numite,
        dd.tipinv,
        dd.codalm,
        dd.codart,
        dd.cantid,
        (
            SELECT
                SUM(de.entreg)
            FROM
                documentos_ent de
            WHERE
                de.id_cia = pin_id_cia
                AND de.opnumdoc = pnumint
                AND de.opnumite = dd.numite
        ) AS entrega
    FROM
        documentos_det dd
    WHERE
        dd.id_cia = pin_id_cia
        AND dd.numint = pnumint
        AND ( ( pin_tipinv = 0 )
              OR ( dd.tipinv = pin_tipinv ) )
        AND ( ( pin_codart = '' )
              OR ( dd.codart = pin_codart ) )
        AND ( ( pin_codalm = 0 )
              OR ( dd.codalm = pin_codalm ) )
    ORDER BY
        dd.tipinv,
        dd.codart,
        dd.codalm;

BEGIN
    IF TRIM(pin_sitdoc) IS NULL THEN
        v_cadin := '';
    ELSE
        SELECT
            ' OR (dc.situac IN ('
            || ''''
            || replace(pin_sitdoc, ' ', ''',''')
            || ''''
            || '))'
        INTO v_cadin
        FROM
            dual;

    END IF;

    strselect := 'Select DC.NumInt From Documentos_Cab Dc  '
                 || 'Where  (Dc.id_cia='
                 || pin_id_cia
                 || ') And ( Dc.TipDoc='
                 || to_char(pin_tipdoc)
                 || ') And '
                 || '(('
                 || to_char(pin_codmot)
                 || '=0)  or (Dc.CodMot='
                 || to_char(pin_codmot)
                 || ')) And '
                 || '(('
                 || ''''
                 || pin_id
                 || ''''
                 || '= '
                 || ''''
                 || ''''
                 || ')  or (Dc.ID    ='
                 || ''''
                 || pin_id
                 || ''''
                 || ')) And '
                 || '(('
                 || ''''
                 || pin_sitdoc
                 || ''''
                 || '='
                 || ''''
                 || ''''
                 || ') '
                 || v_cadin
                 || ' ) ';

    OPEN numint_refcur FOR strselect;

    LOOP
        FETCH numint_refcur INTO v_numint;
        EXIT WHEN numint_refcur%notfound;
        FOR registro IN cur_select(v_numint) LOOP
            v_saldos_documentos.numint := v_numint;
            v_saldos_documentos.numite := registro.numite;
            v_saldos_documentos.tipinv := registro.tipinv;
            v_saldos_documentos.codart := registro.codart;
            v_saldos_documentos.codalm := registro.codalm;
            v_saldos_documentos.cantidad := registro.cantid;
            v_saldos_documentos.entrega := registro.entrega;
            IF ( v_saldos_documentos.tipinv IS NULL ) THEN
                v_saldos_documentos.tipinv := -1;
            END IF;

            IF ( v_saldos_documentos.codalm IS NULL ) THEN
                v_saldos_documentos.codalm := -1;
            END IF;

            IF ( v_saldos_documentos.codart IS NULL ) THEN
                v_saldos_documentos.codart := '-1';
            END IF;

            IF ( v_saldos_documentos.cantidad IS NULL ) THEN
                v_saldos_documentos.cantidad := 0;
            END IF;

            IF ( v_saldos_documentos.entrega IS NULL ) THEN
                v_saldos_documentos.entrega := 0;
            END IF;

            v_saldos_documentos.saldo := v_saldos_documentos.cantidad - v_saldos_documentos.entrega;
            PIPE ROW ( v_saldos_documentos );
        END LOOP;

    END LOOP;

    CLOSE numint_refcur;
END sp00_saca_saldos_documentos;

/
