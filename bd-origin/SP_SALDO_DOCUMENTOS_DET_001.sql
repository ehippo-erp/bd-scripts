--------------------------------------------------------
--  DDL for Function SP_SALDO_DOCUMENTOS_DET_001
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_SALDO_DOCUMENTOS_DET_001" (
    pin_id_cia  IN  NUMBER,
    pin_numint  IN  NUMBER,
    pin_numite  IN  NUMBER
) RETURN tbl_documentos_det_001
    PIPELINED
IS

    documentos_det_001  rec_documentos_det_001 := rec_documentos_det_001(NULL, NULL, NULL, NULL, NULL,
                       NULL, NULL, NULL, NULL, NULL,
                       NULL);
    CURSOR cur_documentos_det_001_all (
        wid_cia NUMBER
    ) IS
    SELECT
        d.tipdoc,
        d.numint,
        d.numite,
        d.codart,
        d.observ,
        d.tipinv,
        d.monafe,
        d.monina,
        d.monigv,
        abs(CAST(d.cantid AS DOUBLE PRECISION)) AS cantidad
    FROM
        documentos_det d
    WHERE
        ( d.id_cia = wid_cia );

    CURSOR cur_documentos_det_001_numint (
        wid_cia  NUMBER,
        wnumint  NUMBER
    ) IS
    SELECT
        d.tipdoc,
        d.numint,
        d.numite,
        d.codart,
        d.observ,
        d.tipinv,
        d.monafe,
        d.monina,
        d.monigv,
        abs(CAST(d.cantid AS DOUBLE PRECISION)) AS cantidad
    FROM
        documentos_det d
    WHERE
            d.id_cia = wid_cia
        AND d.numint = wnumint;

    CURSOR cur_documentos_det_001_numint_numite (
        wid_cia  NUMBER,
        wnumint  NUMBER,
        wnumite  NUMBER
    ) IS
    SELECT
        d.tipdoc,
        d.numint,
        d.numite,
        d.codart,
        d.observ,
        d.tipinv,
        d.monafe,
        d.monina,
        d.monigv,
        abs(CAST(d.cantid AS DOUBLE PRECISION)) AS cantidad
    FROM
        documentos_det d
    WHERE
            d.id_cia = wid_cia
        AND d.numint = wnumint
        AND d.numite = wnumite;

    v_entrega           NUMBER(16, 5);
    v_saldo             NUMBER(16, 5);
BEGIN
    IF (
        ( pin_numint <= 0 ) AND ( pin_numite <= 0 )
    ) THEN
        FOR registro IN cur_documentos_det_001_all(pin_id_cia) LOOP
            BEGIN
                SELECT
                    abs(SUM(nvl(de.entreg, 0)))
                INTO v_entrega
                FROM
                         documentos_ent de
                    INNER JOIN documentos_cab dc ON dc.id_cia = de.id_cia
                                                    AND dc.numint = de.orinumint
                                                    AND dc.situac NOT IN (
                        'J',
                        'K'
                    )
                WHERE
                    ( de.id_cia = pin_id_cia )
                    AND ( de.opnumdoc = registro.numint )
                    AND ( de.opnumite = registro.numite );

            EXCEPTION
                WHEN no_data_found THEN
                    v_entrega := 0;
            END;

            v_saldo := nvl(registro.cantidad, 0) - nvl(v_entrega, 0);

            documentos_det_001.tipdoc := registro.tipdoc;
            documentos_det_001.numint := registro.numint;
            documentos_det_001.numite := registro.numite;
            documentos_det_001.codart := registro.codart;
            documentos_det_001.tipinv := registro.tipinv;
            documentos_det_001.monafe := registro.monafe;
            documentos_det_001.monina := registro.monina;
            documentos_det_001.monigv := registro.monigv;
            documentos_det_001.cantidad := registro.cantidad;
            documentos_det_001.entrega := nvl(v_entrega, 0);
            documentos_det_001.saldo := v_saldo;
            PIPE ROW ( documentos_det_001 );
        END LOOP;
    END IF;
--------------------------

    IF (
        ( pin_numint > 0 ) AND ( pin_numite <= 0 )
    ) THEN
        FOR registro IN cur_documentos_det_001_numint(pin_id_cia, pin_numint) LOOP
            BEGIN
                SELECT
                    abs(SUM(nvl(de.entreg, 0)))
                INTO v_entrega
                FROM
                         documentos_ent de
                    INNER JOIN documentos_cab dc ON dc.id_cia = de.id_cia
                                                    AND dc.numint = de.orinumint
                                                    AND dc.situac NOT IN (
                        'J',
                        'K'
                    )
                WHERE
                    ( de.id_cia = pin_id_cia )
                    AND ( de.opnumdoc = registro.numint )
                    AND ( de.opnumite = registro.numite );

            EXCEPTION
                WHEN no_data_found THEN
                    v_entrega := 0;
            END;

            v_saldo := nvl(registro.cantidad, 0) - nvl(v_entrega, 0);

            documentos_det_001.tipdoc := registro.tipdoc;
            documentos_det_001.numint := registro.numint;
            documentos_det_001.numite := registro.numite;
            documentos_det_001.codart := registro.codart;
            documentos_det_001.tipinv := registro.tipinv;
            documentos_det_001.monafe := registro.monafe;
            documentos_det_001.monina := registro.monina;
            documentos_det_001.monigv := registro.monigv;
            documentos_det_001.cantidad := registro.cantidad;
            documentos_det_001.entrega := nvl(v_entrega, 0);
            documentos_det_001.saldo := v_saldo;
            PIPE ROW ( documentos_det_001 );
        END LOOP;

    END IF;
    -----

    IF (
        ( pin_numint > 0 ) AND ( pin_numite > 0 )
    ) THEN
        FOR registro IN cur_documentos_det_001_numint_numite(pin_id_cia, pin_numint, pin_numite) LOOP
            BEGIN
                SELECT
                    abs(SUM(nvl(de.entreg, 0)))
                INTO v_entrega
                FROM
                         documentos_ent de
                    INNER JOIN documentos_cab dc ON dc.id_cia = de.id_cia
                                                    AND dc.numint = de.orinumint
                                                    AND dc.situac NOT IN (
                        'J',
                        'K'
                    )
                WHERE
                    ( de.id_cia = pin_id_cia )
                    AND ( de.opnumdoc = registro.numint )
                    AND ( de.opnumite = registro.numite );

            EXCEPTION
                WHEN no_data_found THEN
                    v_entrega := 0;
            END;

            v_saldo := nvl(registro.cantidad, 0) - nvl(v_entrega, 0);

            documentos_det_001.tipdoc := registro.tipdoc;
            documentos_det_001.numint := registro.numint;
            documentos_det_001.numite := registro.numite;
            documentos_det_001.codart := registro.codart;
            documentos_det_001.tipinv := registro.tipinv;
            documentos_det_001.monafe := registro.monafe;
            documentos_det_001.monina := registro.monina;
            documentos_det_001.monigv := registro.monigv;
            documentos_det_001.cantidad := registro.cantidad;
            documentos_det_001.entrega := nvl(v_entrega, 0);
            documentos_det_001.saldo := v_saldo;
            PIPE ROW ( documentos_det_001 );
        END LOOP;
    END IF;

    return;
END sp_saldo_documentos_det_001;

/
