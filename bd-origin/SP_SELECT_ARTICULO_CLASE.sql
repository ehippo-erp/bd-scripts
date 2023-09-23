--------------------------------------------------------
--  DDL for Function SP_SELECT_ARTICULO_CLASE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_SELECT_ARTICULO_CLASE" (
    pid_cia  IN  NUMBER,
    ptipinv  IN  NUMBER,
    pcodart  IN  VARCHAR2,
    pclase   IN  NUMBER
) RETURN tbl_articulo_clase
    PIPELINED
AS
    rarticulo_clase rec_articulo_clase := rec_articulo_clase(NULL, NULL, NULL, NULL, NULL,
                   NULL);
BEGIN
    FOR registro IN (
        SELECT
            c.tipinv     AS tipinv,
            c.codart     AS codart,
            c.clase      AS clase,
            cl.descri    AS desclase,
            c.codigo     AS codigo,
            co.descri    AS descodigo
        FROM
            articulos_clase  c
            LEFT OUTER JOIN clase            cl ON cl.id_cia = pid_cia
                                        AND cl.tipinv = c.tipinv
                                        AND cl.clase = c.clase
            LEFT OUTER JOIN clase_codigo     co ON co.id_cia = pid_cia
                                               AND co.tipinv = c.tipinv
                                               AND co.clase = c.clase
                                               AND co.codigo = c.codigo
        WHERE
                c.id_cia = pid_cia
            AND c.tipinv = ptipinv
            AND c.codart = pcodart
            AND c.clase = pclase
    ) LOOP
        rarticulo_clase.tipinv := registro.tipinv;
        rarticulo_clase.codart := registro.codart;
        rarticulo_clase.clase := registro.clase;
        rarticulo_clase.desclase := registro.desclase;
        rarticulo_clase.codigo := registro.codigo;
        rarticulo_clase.descodigo := registro.descodigo;
        PIPE ROW ( rarticulo_clase );
    END LOOP;
END sp_select_articulo_clase;

/
