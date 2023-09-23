--------------------------------------------------------
--  DDL for Package Body PACK_ASIENTO_VENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ASIENTO_VENTA" AS

    FUNCTION sp_reporte_clase (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_reporte_clase
        PIPELINED
    AS
        v_table datatable_reporte_clase;
    BEGIN
        SELECT DISTINCT
            d.tipinv,
            t.dtipinv,
            d.codart,
            a.descri AS desart,
            'Articulo registrado con movimiento sin la clase 18,19,31, 69, 70'
        BULK COLLECT
        INTO v_table
        FROM
                 documentos_cab c
            INNER JOIN documentos_det d ON c.id_cia = d.id_cia
                                           AND c.numint = d.numint
            LEFT OUTER JOIN t_inventario   t ON t.id_cia = d.id_cia
                                              AND t.tipinv = d.tipinv
            INNER JOIN articulos      a ON a.id_cia = d.id_cia
                                      AND a.tipinv = d.tipinv
                                      AND a.codart = d.codart
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc IN ( 1, 3, 7, 8 )
            AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
            AND ( ( NOT EXISTS (
                SELECT
                    ac.codart
                FROM
                    articulos_clase ac
                WHERE
                        ac.id_cia = d.id_cia
                    AND ac.tipinv = d.tipinv
                    AND ac.codart = d.codart
                    AND ac.clase = 31
                    AND ac.codigo <> 'ND'
            ) )
                  OR ( NOT EXISTS (
                SELECT
                    ac.codart
                FROM
                    articulos_clase ac
                WHERE
                        ac.id_cia = d.id_cia
                    AND ac.tipinv = d.tipinv
                    AND ac.codart = d.codart
                    AND ac.clase = 69
                    AND ac.codigo <> 'ND'
            ) )
                  OR ( NOT EXISTS (
                SELECT
                    ac.codart
                FROM
                    articulos_clase ac
                WHERE
                        ac.id_cia = d.id_cia
                    AND ac.tipinv = d.tipinv
                    AND ac.codart = d.codart
                    AND ac.clase = 70
                    AND ac.codigo <> 'ND'
            ) )
                  OR ( NOT EXISTS (
                SELECT
                    ac.codart
                FROM
                    articulos_clase ac
                WHERE
                        ac.id_cia = d.id_cia
                    AND ac.tipinv = d.tipinv
                    AND ac.codart = d.codart
                    AND ac.clase = 18
                    AND ac.codigo <> 'ND'
            ) )
                  OR ( NOT EXISTS (
                SELECT
                    ac.codart
                FROM
                    articulos_clase ac
                WHERE
                        ac.id_cia = d.id_cia
                    AND ac.tipinv = d.tipinv
                    AND ac.codart = d.codart
                    AND ac.clase = 19
                    AND ac.codigo <> 'ND'
            ) ) )
        ORDER BY
            d.tipinv,
            d.codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_clase;

    FUNCTION sp_reporte_clase_basic (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_reporte_clase
        PIPELINED
    AS
        v_table datatable_reporte_clase;
    BEGIN
        SELECT DISTINCT
            d.tipinv,
            t.dtipinv,
            d.codart,
            a.descri AS desart,
            'Articulo registrado con movimiento sin la clase 69, 70'
        BULK COLLECT
        INTO v_table
        FROM
                 documentos_cab c
            INNER JOIN documentos_det d ON c.id_cia = d.id_cia
                                           AND c.numint = d.numint
            LEFT OUTER JOIN t_inventario   t ON t.id_cia = d.id_cia
                                              AND t.tipinv = d.tipinv
            INNER JOIN articulos      a ON a.id_cia = d.id_cia
                                      AND a.tipinv = d.tipinv
                                      AND a.codart = d.codart
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc IN ( 1, 3, 7, 8 )
            AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
            AND ( ( NOT EXISTS (
                SELECT
                    ac.codart
                FROM
                    articulos_clase ac
                WHERE
                        ac.id_cia = d.id_cia
                    AND ac.tipinv = d.tipinv
                    AND ac.codart = d.codart
                    AND ac.clase = 69
                    AND ac.codigo <> 'ND'
            ) )
                  OR ( NOT EXISTS (
                SELECT
                    ac.codart
                FROM
                    articulos_clase ac
                WHERE
                        ac.id_cia = d.id_cia
                    AND ac.tipinv = d.tipinv
                    AND ac.codart = d.codart
                    AND ac.clase = 70
                    AND ac.codigo <> 'ND'
            ) ) )
        ORDER BY
            d.tipinv,
            d.codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_clase_basic;

    FUNCTION sp_reporte_cuenta (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipinv NUMBER
    ) RETURN datatable_reporte_cuenta
        PIPELINED
    AS
        v_table datatable_reporte_cuenta;
    BEGIN
        SELECT DISTINCT
            c.id_cia,
            d.tipinv,
            d.codart,
            a.descri AS desart,
            ac.clase,
            ac.codigo,
            'Articulo registrado con una Cuenta que no existe en el Libro de Cuentas!'
        BULK COLLECT
        INTO v_table
        FROM
                 documentos_cab c
            INNER JOIN documentos_det  d ON c.id_cia = d.id_cia
                                           AND c.numint = d.numint
            INNER JOIN articulos       a ON a.id_cia = c.id_cia
                                      AND a.tipinv = d.tipinv
                                      AND a.codart = d.codart
            INNER JOIN articulos_clase ac ON ac.id_cia = c.id_cia
                                             AND ac.tipinv = a.tipinv
                                             AND ac.codart = a.codart
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc IN ( 1, 3, 7, 8 )
            AND ac.clase IN ( 69, 70 )
            AND a.tipinv = pin_tipinv
            AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
            AND NOT EXISTS (
                SELECT
                    pc.cuenta
                FROM
                    pcuentas pc
                WHERE
                        pc.id_cia = d.id_cia
                    AND pc.cuenta = ac.codigo
            );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_cuenta;

    FUNCTION sp_reporte_cuentav2 (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER
    ) RETURN datatable_reporte_cuenta
        PIPELINED
    AS
        v_table datatable_reporte_cuenta;
    BEGIN
        SELECT DISTINCT
            a.id_cia,
            a.tipinv,
            a.codart,
            a.descri AS desart,
            ac.clase,
            ac.codigo,
            'Articulo registrado con una Cuenta que no existe en el Libro de Cuentas!'
        BULK COLLECT
        INTO v_table
        FROM
                 articulos a
            INNER JOIN articulos_clase ac ON ac.id_cia = a.id_cia
                                             AND ac.tipinv = a.tipinv
                                             AND ac.codart = a.codart
        WHERE
                a.id_cia = pin_id_cia
            AND ac.clase IN ( 69, 70 )
            AND a.tipinv = pin_tipinv
            AND NOT EXISTS (
                SELECT
                    pc.cuenta
                FROM
                    pcuentas pc
                WHERE
                        pc.id_cia = a.id_cia
                    AND pc.cuenta = ac.codigo
            );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_cuentav2;

END;

/
