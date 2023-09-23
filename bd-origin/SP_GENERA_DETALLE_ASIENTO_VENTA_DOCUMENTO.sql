--------------------------------------------------------
--  DDL for Function SP_GENERA_DETALLE_ASIENTO_VENTA_DOCUMENTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_GENERA_DETALLE_ASIENTO_VENTA_DOCUMENTO" (
    pin_id_cia IN NUMBER,
    pin_numint IN NUMBER
) RETURN tbl_sp_genera_detalle_asiento_venta_documento
    PIPELINED
AS

    rec        rec_sp_genera_detalle_asiento_venta_documento := rec_sp_genera_detalle_asiento_venta_documento(NULL, NULL, NULL, NULL,
    NULL,
                                                                                                      NULL, NULL, NULL, NULL, NULL,
                                                                                                      NULL, NULL, NULL, NULL);
    v_totalcab NUMBER := 0;
    v_totaldet NUMBER := 0;
    v_diff     NUMBER := 0;
    v_id_reg   INTEGER;
    v_process  VARCHAR2(1 CHAR);
BEGIN
    BEGIN
        SELECT
            nvl(monafe, 0)
        INTO v_totalcab -- TOTAL DEL DOCUMENTO
        FROM
            documentos_cab
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

    END;

    BEGIN
        SELECT
            id_reg
        INTO v_id_reg -- IDENTIFICADOR DEL REGISTRO CON MAYOR MONTO, REGISTRO A DESCONTAR LA DIFFERENCIA
        FROM
            sp_identificardor_detalle_asiento_venta_documento(pin_id_cia, pin_numint)
        WHERE
            id_ide = 1
        ORDER BY
            decode(tipmon, 'PEN', importe01, importe02) DESC
        FETCH NEXT 1 ROWS ONLY;

    EXCEPTION
        WHEN no_data_found THEN
            v_process := 'N';
            v_id_reg := 999; -- NO DEBE REALIZAR CALCULO ALGUNO
    END;

    BEGIN
        SELECT
            SUM(decode(tipmon, 'PEN', importe01, importe02))
        INTO v_totaldet -- TOTAL DETALLE ASIENTO
        FROM
            sp_identificardor_detalle_asiento_venta_documento(pin_id_cia, pin_numint)
        WHERE
            id_ide = 1;

    EXCEPTION
        WHEN no_data_found THEN
            v_process := 'N';
            v_id_reg := 999; -- NO DEBE REALIZAR CALCULO ALGUNO

    END;

    v_diff := v_totalcab - v_totaldet;
    IF v_diff BETWEEN - 1.5 AND 1.5 THEN
        v_process := 'S'; -- DIFERENCIA MAXIMA ACEPTABLE
    END IF;

    FOR i IN (
        SELECT
            *
        FROM
            sp_identificardor_detalle_asiento_venta_documento(pin_id_cia, pin_numint)
    ) LOOP
        IF
            i.id_ide = 1
            AND v_process = 'S'
            AND i.id_reg = v_id_reg
        THEN
            rec.cuenta := i.cuenta;
            rec.dh := i.dh;
            rec.codcli := i.codcli;
            rec.razonc := i.razonc;
            rec.tident := i.tident;
            rec.ruc := i.ruc;
            rec.femisi := i.femisi;
            rec.tipdoc := i.tipdoc;
            rec.series := i.series;
            rec.numdoc := i.numdoc;
            rec.tipmon := i.tipmon;
            rec.tipcam := i.tipcam;
            IF rec.tipmon = 'PEN' THEN
                rec.importe01 := abs(i.importe01) + ( v_diff );
                rec.importe02 := abs(i.importe02) + ( v_diff / rec.tipcam );

            ELSE
                rec.importe01 := abs(i.importe01) + ( v_diff * rec.tipcam );

                rec.importe02 := abs(i.importe02) + ( v_diff );
            END IF;

            PIPE ROW ( rec );
        ELSE
            rec.cuenta := i.cuenta;
            rec.dh := i.dh;
            rec.codcli := i.codcli;
            rec.razonc := i.razonc;
            rec.tident := i.tident;
            rec.ruc := i.ruc;
            rec.femisi := i.femisi;
            rec.tipdoc := i.tipdoc;
            rec.series := i.series;
            rec.numdoc := i.numdoc;
            rec.tipmon := i.tipmon;
            rec.tipcam := i.tipcam;
            rec.importe01 := abs(i.importe01);
            rec.importe02 := abs(i.importe02);
            PIPE ROW ( rec );
        END IF;
    END LOOP;

END;

/
