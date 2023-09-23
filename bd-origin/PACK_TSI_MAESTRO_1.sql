--------------------------------------------------------
--  DDL for Package Body PACK_TSI_MAESTRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_TSI_MAESTRO" AS

    FUNCTION sp_cliente (
        pin_id_cia NUMBER
    ) RETURN datatable_cliente
        PIPELINED
    AS
        v_table datatable_cliente;
    BEGIN
        SELECT
            c.codcli       "CODIGO",
            c.razonc       "RAZON SOCIAL",
            p.destpe       "TIPO DE PERSONA",
            i.descri       AS "DOCUMENTO DE IDENTIDAD",
            c.dident       "NRO DE IDENTIDAD",
            c.direc1       AS "DIRECCION FISCAL",
            c.telefono     "TELEFONO",
            c.email        "CORREO ELECTRONICO",
            cc16.codigo    AS "UBIGEO",
            cc14.descodigo "DEPARTAMENTO",
            cc15.descodigo "PROVINCIA",
            cc16.descodigo "DISTRITO",
            cc1.descodigo  "SITUACION",
            c.limcre2      "LINEA DE CRÉDITO",
            cpp.despag     "CONDICION DE PAGO",
            c.codven       "COD VENDEDOR",
            v.desven       "NOM VENDEDOR",
            cc28.descodigo "GRUPO ECONOMICO",
            cc20.descodigo "GRUPO DE CLIENTE",
            cc21.descodigo "CLASIFICACION DE CLIENTE",
            cc29.descodigo
        BULK COLLECT
        INTO v_table
        FROM
                 cliente c
            INNER JOIN cliente_clase                                                           cli ON cli.id_cia = c.id_cia
                                            AND cli.tipcli = 'A'
                                            AND cli.codcli = c.codcli
                                            AND cli.clase = 1
            LEFT OUTER JOIN t_persona                                                               p ON p.id_cia = c.id_cia
                                           AND p.codtpe = c.codtpe
            LEFT OUTER JOIN identidad                                                               i ON i.id_cia = c.id_cia
                                           AND i.tident = c.tident
            LEFT OUTER JOIN vendedor                                                                v ON v.id_cia = c.id_cia
                                          AND v.codven = c.codven
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 1)  cc1 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 14) cc14 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 15) cc15 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 16) cc16 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 28) cc28 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 20) cc20 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 21) cc21 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 29) cc29 ON 0 = 0
            LEFT OUTER JOIN cliente_codpag                                                          cpag ON cpag.id_cia = c.id_cia
                                                   AND cpag.codcli = c.codcli
            LEFT OUTER JOIN c_pago                                                                  cpp ON cpp.id_cia = c.id_cia
                                          AND cpp.codpag = cpag.codpag
        WHERE
            c.id_cia = pin_id_cia
        ORDER BY
            c.razonc;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cliente;

    FUNCTION sp_proveedor (
        pin_id_cia NUMBER
    ) RETURN datatable_proveedor
        PIPELINED
    AS
        v_table datatable_proveedor;
    BEGIN
        SELECT
            c.codcli       "CODIGO",
            c.razonc       "RAZON SOCIAL",
            p.destpe       "TIPO DE PERSONA",
            i.descri       AS "DOCUMENTO DE IDENTIDAD",
            c.dident       "NRO DE IDENTIDAD",
            c.direc1       AS "DIRECCION FISCAL",
            c.telefono     "TELEFONO",
            c.email        "CORREO ELECTRONICO",
            cc16.codigo    AS "UBIGEO",
            cc14.descodigo "DEPARTAMENTO",
            cc15.descodigo "PROVINCIA",
            cc16.descodigo "DISTRITO",
            cc1.descodigo  "SITUACION",
            c.limcre2      "LINEA DE CRÉDITO",
            cpp.despag     "CONDICION DE PAGO",
            c.codven       "COD VENDEDOR",
            v.desven       "NOM VENDEDOR",
            cc28.descodigo "GRUPO ECONOMICO",
            cc20.descodigo "GRUPO DE CLIENTE",
            cc21.descodigo "CLASIFICACION DE CLIENTE"
        BULK COLLECT
        INTO v_table
        FROM
                 cliente c
            INNER JOIN cliente_clase                                                           cli ON cli.id_cia = c.id_cia
                                            AND cli.tipcli = 'B'
                                            AND cli.codcli = c.codcli
                                            AND cli.clase = 1
            LEFT OUTER JOIN t_persona                                                               p ON p.id_cia = c.id_cia
                                           AND p.codtpe = c.codtpe
            LEFT OUTER JOIN identidad                                                               i ON i.id_cia = c.id_cia
                                           AND i.tident = c.tident
            LEFT OUTER JOIN vendedor                                                                v ON v.id_cia = c.id_cia
                                          AND v.codven = c.codven
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 1)  cc1 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 14) cc14 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 15) cc15 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 16) cc16 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 28) cc28 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 20) cc20 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 21) cc21 ON 0 = 0
            LEFT OUTER JOIN cliente_codpag                                                          cpag ON cpag.id_cia = c.id_cia
                                                   AND cpag.codcli = c.codcli
            LEFT OUTER JOIN c_pago                                                                  cpp ON cpp.id_cia = c.id_cia
                                          AND cpp.codpag = cpag.codpag
        WHERE
            c.id_cia = pin_id_cia
        ORDER BY
            c.razonc;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_proveedor;

    FUNCTION sp_cliente_proveedor (
        pin_id_cia NUMBER
    ) RETURN datatable_cliente_proveedor
        PIPELINED
    AS
        v_table datatable_cliente_proveedor;
    BEGIN
        SELECT
            tc.nomtcl      AS "TIPO",
            c.codcli       "CODIGO",
            c.razonc       "RAZON SOCIAL",
            p.destpe       "TIPO DE PERSONA",
            i.descri       AS "DOCUMENTO DE IDENTIDAD",
            c.dident       "NRO DE IDENTIDAD",
            c.direc1       AS "DIRECCION FISCAL",
            c.telefono     AS "TELEFONO",
            c.email        AS "CORREO ELECTRONICO",
            cc16.codigo    AS "UBIGEO",
            cc14.descodigo "DEPARTAMENTO",
            cc15.descodigo "PROVINCIA",
            cc16.descodigo "DISTRITO",
            cc1.descodigo  "SITUACION",
            cc28.descodigo "GRUPO ECONOMICO",
            cc20.descodigo "GRUPO DE CLIENTE",
            cc21.descodigo "CLASIFICACION DE CLIENTE"
        BULK COLLECT
        INTO v_table
        FROM
                 cliente c
            INNER JOIN cliente_clase                                                           cli ON cli.id_cia = c.id_cia
                                            AND cli.tipcli IN ( 'A', 'B' )
                                            AND cli.codcli = c.codcli
                                            AND cli.clase = 1
            LEFT OUTER JOIN tipocliente                                                             tc ON tc.id_cia = c.id_cia
                                              AND tc.tipcli = cli.tipcli
            LEFT OUTER JOIN t_persona                                                               p ON p.id_cia = c.id_cia
                                           AND p.codtpe = c.codtpe
            LEFT OUTER JOIN identidad                                                               i ON i.id_cia = c.id_cia
                                           AND i.tident = c.tident
            LEFT OUTER JOIN vendedor                                                                v ON v.id_cia = c.id_cia
                                          AND v.codven = c.codven
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 1)  cc1 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 14) cc14 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 15) cc15 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 16) cc16 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 28) cc28 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 20) cc20 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, cli.tipcli, c.codcli, 21) cc21 ON 0 = 0
        WHERE
            c.id_cia = pin_id_cia
        ORDER BY
            tc.nomtcl,
            c.razonc;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cliente_proveedor;

    FUNCTION sp_plan_cuenta (
        pin_id_cia NUMBER
    ) RETURN datatable_plan_cuenta
        PIPELINED
    AS
        v_table datatable_plan_cuenta;
    BEGIN
        SELECT
            p.cuenta            AS "CUENTA",
            p.nombre            AS "DESCRIPCION",
            CASE p.dh
                WHEN 'D' THEN
                    p.dh
                    || '-'
                    || 'DEBE'
                WHEN 'H' THEN
                    p.dh
                    || '-'
                    || 'HABER'
            END                 AS "DH",
            'NIVEL ' || p.nivel AS "NIVEL",
            p.moneda01
            || '-'
            || m1.desmon        AS "MONEDA 01",
            p.moneda02
            || '-'
            || m2.desmon        AS "MONEDA 02",
            p.codtana
            || '-'
            || a.descri         AS "ANALITICA",
            CASE p.destino
                WHEN 'S' THEN
                    'SI'
                WHEN 'N' THEN
                    'NO'
            END                 AS "DESTINO AUTOMATICO",
            CASE
                WHEN ( ( p.destid IS NULL )
                       OR ( p.destid = '0' ) ) THEN
                    ''
                ELSE
                    dd.cuenta
                    || '-'
                    || dd.nombre
            END                 AS "DESTINO DEBE",
            CASE
                WHEN ( ( p.destih IS NULL )
                       OR ( p.destih = '0' ) ) THEN
                    ''
                ELSE
                    dh.cuenta
                    || '-'
                    || dh.nombre
            END                 AS "DESTINO HABER",
            CASE p.imputa
                WHEN 'S' THEN
                    'SI'
                WHEN 'N' THEN
                    'NO'
            END                 AS "IMPUTABLE",
            CASE p.refere
                WHEN 'S' THEN
                    'SI'
                WHEN 'N' THEN
                    'NO'
            END                 AS "PIDE REFERENCIA",
            CASE p.ccosto
                WHEN 'S' THEN
                    'SI'
                WHEN 'N' THEN
                    'NO'
            END                 AS "PIDE CENTRO DE COSTO",
            CASE p.balance
                WHEN 'S' THEN
                    'SI'
                WHEN 'N' THEN
                    'NO'
            END                 AS "INCLUIR EN BALANCE",
            CASE p.proyec
                WHEN 'S' THEN
                    'SI'
                WHEN 'N' THEN
                    'NO'
            END                 AS "PEDIR PROYECTO",
            CASE p.concilia
                WHEN 'S' THEN
                    'SI'
                WHEN 'N' THEN
                    'NO'
            END                 AS "CONCILIACION",
            p.moneda01,
            p.moneda02,
            CASE p.docori
                WHEN 0 THEN
                    p.docori
                    || '-'
                    || 'Ninguno'
                WHEN 1 THEN
                    p.docori
                    || '-'
                    || 'Clientes'
                WHEN 2 THEN
                    p.docori
                    || '-'
                    || 'Proveedor'
                WHEN 3 THEN
                    p.docori
                    || '-'
                    || 'Empleado'
                WHEN 4 THEN
                    p.docori
                    || '-'
                    || 'Obrero'
                WHEN 5 THEN
                    p.docori
                    || '-'
                    || 'Otros'
                WHEN 6 THEN
                    p.docori
                    || '-'
                    || 'Cta.Bancos'
            END                 AS "DOCUMENTO ORIGEN",
            p.tipgas
            || '-'
            || tg.descri        AS "TIPO GASTO",
            p.regcomcol
            || '-'
            || cr.descri        AS "COLUMNA DEL REGISTRO DE COMPRAS",
            p.regvencol
            || '-'
            || cb.descri        AS "COLUMNA DEL REGISTRO DE VENTAS",
            CASE p.balancecol
                WHEN ''  THEN
                    ''
                WHEN 'I' THEN
                    p.balancecol
                    || '-'
                    || 'Inventario'
                WHEN 'N' THEN
                    p.balancecol
                    || '-'
                    || 'Naturaleza'
                WHEN 'F' THEN
                    p.balancecol
                    || '-'
                    || 'Función'
                WHEN 'R' THEN
                    p.balancecol
                    || '-'
                    || 'Naturaleza y Función '
                WHEN 'S' THEN
                    p.balancecol
                    || '-'
                    || 'Saldos'
            END                 AS "COLUMNA BALANCE"
        BULK COLLECT
        INTO v_table
        FROM
            pcuentas   p
            LEFT OUTER JOIN tgastos    tg ON tg.id_cia = p.id_cia
                                          AND tg.codigo = p.tipgas
            LEFT OUTER JOIN pcuentas   cp ON cp.id_cia = p.id_cia
                                           AND cp.cuenta = p.cpadre
            LEFT OUTER JOIN tanalitica a ON a.id_cia = p.id_cia
                                            AND ( p.codtana = a.codtana )
            LEFT OUTER JOIN tmoneda    m1 ON m1.id_cia = p.id_cia
                                          AND ( m1.codmon = p.moneda01 )
            LEFT OUTER JOIN tmoneda    m2 ON m2.id_cia = p.id_cia
                                          AND ( m2.codmon = p.moneda02 )
            LEFT OUTER JOIN usuarios   u ON u.id_cia = p.id_cia
                                          AND u.coduser = p.usuari
            LEFT OUTER JOIN pcuentas   dd ON dd.id_cia = p.id_cia
                                           AND dd.cuenta = p.destid
            LEFT OUTER JOIN pcuentas   dh ON dh.id_cia = p.id_cia
                                           AND dh.cuenta = p.destih
            LEFT OUTER JOIN colregcom  cr ON cr.id_cia = p.id_cia
                                            AND cr.columna = p.regcomcol
                                            AND cr.tipo = 60
            LEFT OUTER JOIN colregcom  cb ON cb.id_cia = p.id_cia
                                            AND cb.columna = p.regvencol
                                            AND cb.tipo = 63
        WHERE
            p.id_cia = pin_id_cia;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_plan_cuenta;

END;

/
