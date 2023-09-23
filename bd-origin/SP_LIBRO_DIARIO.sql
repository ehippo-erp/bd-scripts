--------------------------------------------------------
--  DDL for Function SP_LIBRO_DIARIO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_LIBRO_DIARIO" (
    pin_id_cia   IN  NUMBER,
    pin_periodo  IN  NUMBER,
    pin_mes      IN  NUMBER
) RETURN tbl_sp_libro_diario
    PIPELINED
AS

    rec rec_sp_libro_diario := rec_sp_libro_diario(NULL, NULL, NULL, NULL, NULL,
                                                  NULL, NULL, NULL, NULL, NULL,
                                                  NULL, NULL);
BEGIN
    FOR i IN (
        SELECT
            d1.*,
            d2.descri,
            d3.nombre,
            d4.descri                       AS descos,
            CAST(tc.vstrg AS INTEGER)      AS codsunat,
            (
                SELECT
                    sp000_ajusta_string(tc.vstrg, 02, '0', 'R') AS ajustado
                FROM
                    dual
            )                               AS codsunat2,
            (
                SELECT
                    sp000_ajusta_string(CAST(d1.asiento AS VARCHAR(10)), 05, '0', 'R') AS ajustado
                FROM
                    dual
            )                               AS asiento2,
            (
                SELECT
                    sp000_ajusta_string(d1.libro, 02, '0', 'R') AS ajustado
                FROM
                    dual
            )
            || '-'
            || (
                SELECT
                    sp000_ajusta_string(CAST(d1.asiento AS VARCHAR(10)), 05, '0', 'R') AS ajustado
                FROM
                    dual
            )                               AS codope1,
            (
                SELECT
                    sp000_ajusta_string(tc.vstrg, 02, '0', 'R') AS ajustado
                FROM
                    dual
            )
            || '-'
            || (
                SELECT
                    sp000_ajusta_string(CAST(d1.asiento AS VARCHAR(10)), 05, '0', 'R') AS ajustado
                FROM
                    dual
            )                               AS codope2
        FROM
                 movimientos d1
            INNER JOIN tlibro         d2 ON d1.id_cia = d2.id_cia
                                    AND ( d1.libro = d2.codlib )
            LEFT OUTER JOIN tlibros_clase  tc ON tc.id_cia = d2.id_cia
                                                AND ( tc.codlib = d2.codlib )
                                                AND ( tc.clase = 1 )
            INNER JOIN pcuentas       d3 ON d1.id_cia = d3.id_cia
                                      AND ( d1.cuenta = d3.cuenta )
            LEFT OUTER JOIN tccostos       d4 ON d1.id_cia = d4.id_cia
                                           AND ( d1.ccosto = d4.codigo )
        WHERE
                d1.id_cia = pin_id_cia
            AND ( d1.periodo = pin_periodo )
            AND ( d1.mes = pin_mes )
        ORDER BY
            d1.periodo,
            d1.mes,
            codsunat,
            d1.libro,
            d1.asiento,
            d1.item,
            d1.sitem
    ) LOOP
        rec.id_cia := pin_id_cia;
        rec.fecha := i.fecha;
        rec.concep := i.concep;
        rec.moneda := i.moneda;
        rec.codsunat2 := i.codsunat2;
        rec.codope1 := i.codope1;
        rec.serie := i.serie;
        rec.numero := i.numero;
        rec.cuenta := i.cuenta;
        rec.nombre := i.nombre;
        rec.debe01 := i.debe01;
        rec.haber01 := i.haber01;
        PIPE ROW ( rec );
    END LOOP;
END sp_libro_diario;

/
