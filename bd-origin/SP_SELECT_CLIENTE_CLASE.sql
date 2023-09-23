--------------------------------------------------------
--  DDL for Function SP_SELECT_CLIENTE_CLASE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_SELECT_CLIENTE_CLASE" (
    pid_cia  IN  NUMBER,
    ptipcli  IN  VARCHAR2,
    pcodcli  IN  VARCHAR2,
    pclase   IN  NUMBER
) RETURN tbl_cliente_clase
    PIPELINED
AS

    rcliente_clase rec_cliente_clase := rec_cliente_clase(NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL);
BEGIN
    FOR registro IN (
        SELECT
            c.tipcli     AS tipcli,
            c.codcli     AS codcli,
            c.clase      AS clase,
            cl.descri    AS desclase,
            c.codigo     AS codigo,
            co.descri    AS descodigo,
            co.abrevi    AS abrcodigo
        FROM
            cliente_clase         c
            LEFT OUTER JOIN clase_cliente         cl ON cl.id_cia = c.id_cia
                                                AND cl.tipcli = c.tipcli
                                                AND cl.clase = c.clase
            LEFT OUTER JOIN clase_cliente_codigo  co ON co.id_cia = c.id_cia
                                                       AND co.tipcli = c.tipcli
                                                       AND co.clase = c.clase
                                                       AND co.codigo = c.codigo
        WHERE
                c.id_cia = pid_cia
            AND c.tipcli = ptipcli
            AND c.codcli = pcodcli
            AND c.clase = pclase
    ) LOOP
        rcliente_clase.tipcli := registro.tipcli;
        rcliente_clase.codcli := registro.codcli;
        rcliente_clase.clase := registro.clase;
        rcliente_clase.desclase := registro.desclase;
        rcliente_clase.codigo := registro.codigo;
        rcliente_clase.descodigo := registro.descodigo;
        rcliente_clase.abrcodigo := registro.abrcodigo;
        PIPE ROW ( rcliente_clase );
    END LOOP;
END sp_select_cliente_clase;

/
