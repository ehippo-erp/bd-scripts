--------------------------------------------------------
--  DDL for Function SP_CONSISTENCIA_AVISOS_DE_VENCIMIENTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_CONSISTENCIA_AVISOS_DE_VENCIMIENTO" (
    pin_id_cia  IN  NUMBER,
    pin_codcli  IN  VARCHAR2,
    pin_tipo    IN  NUMBER,
    pin_valido  IN  SMALLINT
) RETURN tbl_sp_avisos_de_vencimiento
    PIPELINED
AS

    rec rec_sp_avisos_de_vencimiento := rec_sp_avisos_de_vencimiento(NULL, NULL, NULL, NULL, NULL,
                             NULL);
    CURSOR cur_avisos_validos IS
    SELECT
        codcli,
        razonc,
        codenv,
        sumcont,
        cancon,
        conemailvacio
    FROM
        TABLE ( sp_avisos_de_vencimiento(pin_id_cia, pin_codcli, pin_tipo) )
    WHERE
            sumcont > 0
        AND cancon > 0
        AND codenv <> 'XXX';

    CURSOR cur_avisos_invalidos IS
    SELECT
        codcli,
        razonc,
        codenv,
        sumcont,
        cancon,
        conemailvacio
    FROM
        TABLE ( sp_avisos_de_vencimiento(pin_id_cia, pin_codcli, pin_tipo) )
    WHERE
        ( ( sumcont = 0 )
          OR ( cancon = 0 )
          OR ( codenv ='XXX' ) );

BEGIN
    IF ( pin_valido = 1 ) THEN
        FOR raviso IN cur_avisos_validos LOOP
            rec.codcli := raviso.codcli;
            rec.razonc := raviso.razonc;
            rec.codenv := raviso.codenv;
            rec.sumcont := raviso.sumcont;
            rec.cancon := raviso.cancon;
            rec.conemailvacio := raviso.conemailvacio;
            PIPE ROW ( rec );
        END LOOP;

    ELSE
        FOR raviso IN cur_avisos_invalidos LOOP
            rec.codcli := raviso.codcli;
            rec.razonc := raviso.razonc;
            rec.codenv := raviso.codenv;
            rec.sumcont := raviso.sumcont;
            rec.cancon := raviso.cancon;
            rec.conemailvacio := raviso.conemailvacio;
            PIPE ROW ( rec );
        END LOOP;
    END IF;
END sp_consistencia_avisos_de_vencimiento;

/
