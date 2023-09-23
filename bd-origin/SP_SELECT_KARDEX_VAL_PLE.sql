--------------------------------------------------------
--  DDL for Function SP_SELECT_KARDEX_VAL_PLE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_SELECT_KARDEX_VAL_PLE" (
    pin_id_cia    IN INTEGER,
    pin_periodo   INTEGER,
    pin_tipinv    INTEGER,
    pin_codart    VARCHAR2,
    pin_codadd01  VARCHAR2,
    pin_codadd02  VARCHAR2
) RETURN tbl_kardex_val_ple
    PIPELINED
AS
    v_record rec_kardex_val_ple := rec_kardex_val_ple(NULL);
BEGIN
    FOR registro IN (
        SELECT
            k.locali
        FROM
            kardex         k
            LEFT OUTER JOIN motivos_clase  mk ON mk.id_cia = pin_id_cia
                                                AND mk.tipdoc = k.tipdoc
                                                AND mk.id = k.id
                                                AND mk.codmot = k.codmot
                                                AND mk.codigo = 46
        WHERE
                k.id_cia = pin_id_cia
            AND k.periodo = pin_periodo
            AND k.tipinv = pin_tipinv
            AND k.codart = pin_codart
            AND k.codadd01 = pin_codadd01
            AND k.codadd02 = pin_codadd02
    ) LOOP
        v_record.locali := registro.locali;
        PIPE ROW ( v_record );
    END LOOP;

    return;
END;

/
