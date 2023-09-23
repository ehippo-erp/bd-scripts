--------------------------------------------------------
--  DDL for Function SP000_DETALLES_DCTA102_CAJA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_DETALLES_DCTA102_CAJA" (
    pin_id_cia   NUMBER,
    pin_numcaja  NUMBER
) RETURN tbl_detalles_dcta102_caja
    PIPELINED
AS

    r_detalles_dcta102_caja rec_detalles_dcta102_caja := rec_detalles_dcta102_caja(NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL);
    CURSOR cur_select IS
    SELECT
        p.periodo,
        p.mes,
        p.libro,
        p.secuencia,
        p.concep,
        upper(p.situac)       AS situac,
        l.descri              AS deslibro,
        SUM(d.pagomn)         AS pagomn,
        SUM(d.pagome)         AS pagome
    FROM
        dcta102  p
        LEFT OUTER JOIN tlibro   l ON l.id_cia = p.id_cia
                                    AND l.codlib = p.libro
        LEFT OUTER JOIN dcta103  d ON d.id_cia = p.id_cia
                                     AND d.periodo = p.periodo
                                     AND d.mes = p.mes
                                     AND d.libro = p.libro
                                     AND d.secuencia = p.secuencia
                                     AND NOT ( d.situac IN (
            'K'
        ) )
    WHERE
            p.id_cia = pin_id_cia
        AND p.numcaja = pin_numcaja
        AND NOT ( p.situac IN (
            'K'
        ) )
    GROUP BY
        p.periodo,
        p.mes,
        p.libro,
        p.secuencia,
        p.concep,
        p.situac,
        l.descri;

BEGIN
    FOR registro IN cur_select LOOP
        r_detalles_dcta102_caja.libro := registro.libro;
        r_detalles_dcta102_caja.deslibro := registro.deslibro;
        r_detalles_dcta102_caja.periodo := registro.periodo;
        r_detalles_dcta102_caja.mes := registro.mes;
        r_detalles_dcta102_caja.secuencia := registro.secuencia;
        r_detalles_dcta102_caja.concep := registro.concep;
        r_detalles_dcta102_caja.situac := registro.situac;
        r_detalles_dcta102_caja.dessituac := '**';
        r_detalles_dcta102_caja.pagomn := registro.pagomn;
        r_detalles_dcta102_caja.pagome := registro.pagome;
        IF ( registro.situac = 'A' ) THEN
            r_detalles_dcta102_caja.dessituac := 'EMITIDO';
        END IF;

        IF ( registro.situac = 'B' ) THEN
            r_detalles_dcta102_caja.dessituac := 'APROBADO';
        END IF;

        IF ( registro.situac = 'J' ) THEN
            r_detalles_dcta102_caja.dessituac := 'ANULADO';
        END IF;

        PIPE ROW ( r_detalles_dcta102_caja );
    END LOOP;
END sp000_detalles_dcta102_caja;

/
