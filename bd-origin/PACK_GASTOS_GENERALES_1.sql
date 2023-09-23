--------------------------------------------------------
--  DDL for Package Body PACK_GASTOS_GENERALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_GASTOS_GENERALES" AS

    FUNCTION sp_buscar_subcentro_costo_cab (
        pin_id_cia NUMBER,
        pin_pdesde NUMBER,
        pin_phasta NUMBER,
        pin_ccosto VARCHAR2
    ) RETURN datatable_subcentro_costo_cab
        PIPELINED
    AS
        v_table datatable_subcentro_costo_cab;
    BEGIN
        SELECT DISTINCT
            c.codcli,
            c.razonc,
            cc.abrevi
        BULK COLLECT
        INTO v_table
        FROM
                 cliente c
            INNER JOIN cliente_clase        cl ON cl.id_cia = c.id_cia
                                           AND cl.codcli = c.codcli
                                           AND ( ( cl.tipcli = 'O' )
                                                 OR ( cl.tipcli = 'E' ) )
                                           AND cl.clase = 1
            INNER JOIN movimientos          m ON m.id_cia = c.id_cia
                                        AND ( m.subcco = c.codcli ) 
--    And  (M.CCosto Like #{ccosto})
--    And  (((M.Periodo * 100)+M.Mes)
--    between
--    #{periodoMes1} And #{periodoMes2}) And (M.SItem=0)
            LEFT OUTER JOIN cliente_clase        c2 ON c2.id_cia = c.id_cia
                                                AND c2.codcli = c.codcli
                                                AND ( ( c2.tipcli = 'O' )
                                                      OR ( c2.tipcli = 'E' ) )
                                                AND c2.clase = 7
            LEFT OUTER JOIN clase_cliente_codigo cc ON cc.id_cia = c2.id_cia
                                                       AND cc.tipcli = c2.tipcli
                                                       AND cc.clase = c2.clase
                                                       AND cc.codigo = c2.codigo
        WHERE
                c.id_cia = pin_id_cia
            AND ( ( m.periodo * 100 ) + m.mes ) BETWEEN pin_pdesde AND pin_phasta
            AND m.ccosto LIKE pin_ccosto
        ORDER BY
            c.razonc;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_subcentro_costo_cab;

    FUNCTION sp_buscar_subcentro_costo_det (
        pin_id_cia NUMBER,
        pin_pdesde NUMBER,
        pin_phasta NUMBER,
        pin_ccosto VARCHAR2,
        pin_moneda VARCHAR2
    ) RETURN datatable_subcentro_costo_det
        PIPELINED
    AS

        rec datarecord_subcentro_costo_det := datarecord_subcentro_costo_det(NULL, NULL, NULL, NULL, NULL,
                                                                            NULL, NULL);
    BEGIN
        IF pin_moneda = '01' THEN
            FOR j IN (
                SELECT
                    *
                FROM
                    sp_buscar_subcentro_costo_cab(pin_id_cia, pin_pdesde, pin_phasta, pin_ccosto)
            ) LOOP
                FOR i IN (
                    SELECT
                        p.tipgas,
                        g.descri AS destipgas,
                        m.cuenta,
                        p.nombre AS descuenta,
                        SUM(
                            CASE
                                WHEN m.subcco = j.codcli THEN
                                    m.debe01 - m.haber01
                                ELSE
                                    0
                            END
                        )        AS saldo
                    FROM
                        movimientos m
                        LEFT OUTER JOIN pcuentas    p ON p.id_cia = m.id_cia
                                                      AND p.cuenta = m.cuenta
                        LEFT OUTER JOIN tgastos     g ON g.id_cia = p.id_cia
                                                     AND g.codigo = p.tipgas
                    WHERE
                            m.id_cia = pin_id_cia
                        AND m.ccosto LIKE pin_ccosto
                        AND ( ( ( m.periodo * 100 ) + m.mes ) BETWEEN pin_pdesde AND pin_phasta )
                        AND m.sitem = 0
                        --AND m.subcco = j.codcli
--    <foreach item="item" collection="prueba" separator=" or ">
--      M.SubCCo= pin_item.codcli
--    </foreach>
--    SELECT abrevi FROM sp_buscar_subcentro_costo_cab(pin_id_cia,pin_pdesde,pin_phasta,pin_ccosto) IS NULL THEN
--        Sum(Case When M.SubCCo=${item.codcli Then M.Debe${moneda-M.Haber${moneda Else 0 End) as ${item.abrevi
--    ELSE
--        Sum(Case When M.SubCCo=${item.codcli Then M.Debe${moneda-M.Haber${moneda Else 0 End) as C${item.codcli
                    GROUP BY
                        p.tipgas,
                        g.descri,
                        m.cuenta,
                        p.nombre
                    ORDER BY
                        p.tipgas,
                        m.cuenta
                ) LOOP
                    rec.tipgas := i.tipgas;
                    rec.destipgas := i.destipgas;
                    rec.cuenta := i.cuenta;
                    rec.descuenta := i.descuenta;
                    rec.saldo := i.saldo;
                    IF j.abrevi IS NOT NULL THEN
                        rec.abrevi := j.abrevi;
                        rec.codcli := '';
                    ELSE
                        rec.abrevi := '';
                        rec.codcli := j.codcli;
                    END IF;

                    PIPE ROW ( rec );
                END LOOP;
            END LOOP;
        ELSIF pin_moneda = '02' THEN
            NULL;
        END IF;
    END sp_buscar_subcentro_costo_det;

END;

/
