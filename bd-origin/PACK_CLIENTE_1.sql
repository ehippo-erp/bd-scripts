--------------------------------------------------------
--  DDL for Package Body PACK_CLIENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CLIENTE" AS

    FUNCTION sp_buscar_clase_codigo (
        pin_id_cia IN NUMBER,
        pin_tipcli IN VARCHAR2,
        pin_codcli IN VARCHAR2,
        pin_clase  IN NUMBER
    ) RETURN datatable_clase_codigo
        PIPELINED
    AS
        v_table datatable_clase_codigo;
    BEGIN
        SELECT
            c.tipcli  AS tipcli,
            c.codcli  AS codcli,
            c.clase   AS clase,
            cl.descri AS desclase,
            c.codigo  AS codigo,
            co.descri AS descodigo,
            co.abrevi AS abrcodigo
        BULK COLLECT
        INTO v_table
        FROM
            cliente_clase        c
            LEFT OUTER JOIN clase_cliente        cl ON cl.id_cia = c.id_cia
                                                AND cl.tipcli = c.tipcli
                                                AND cl.clase = c.clase
            LEFT OUTER JOIN clase_cliente_codigo co ON co.id_cia = c.id_cia
                                                       AND co.tipcli = c.tipcli
                                                       AND co.clase = c.clase
                                                       AND co.codigo = c.codigo
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipcli = pin_tipcli
            AND c.codcli = pin_codcli
            AND c.clase = pin_clase;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_clase_codigo;

    PROCEDURE sp_insert_clases_obligatorias (
        pin_id_cia  IN NUMBER,
        pin_tipcli  IN VARCHAR2,
        pin_codcli  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_aux        NUMBER := 0;
        v_clase      VARCHAR2(1000);
        pout_mensaje VARCHAR2(4000);
    BEGIN
    -- INSERTANDO CLASES OBLIGATORIAS
        INSERT INTO cliente_clase (
            id_cia,
            tipcli,
            codcli,
            clase,
            codigo,
            situac
        )
            SELECT
                pin_id_cia,
                pin_tipcli,
                pin_codcli,
                c.clase,
                CASE
                    WHEN cc.codigo IS NULL THEN
                        CAST('ND' AS VARCHAR(20))
                    ELSE
                        cc.codigo
                END AS codigo,
                'S'
            FROM
                clase_cliente        c
                LEFT OUTER JOIN clase_cliente_codigo cc ON cc.id_cia = c.id_cia
                                                           AND cc.tipcli = c.tipcli
                                                           AND cc.clase = c.clase
                                                           AND cc.swdefaul = 'S'
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipcli = pin_tipcli
                AND c.obliga = 'S'
                AND NOT EXISTS (
                    SELECT
                        *
                    FROM
                        cliente_clase
                    WHERE
                            id_cia = pin_id_cia
                        AND tipcli = pin_tipcli
                        AND codcli = pin_codcli
                        AND clase = c.clase
                );

    -- VALIDANDO LA INSERCION DE CLASES NO ND
        BEGIN
            FOR i IN (
                SELECT
                    cc.codigo,
                    upper(ccl.descri) AS clase_cliente
                FROM
                         cliente_clase cc
                    INNER JOIN clase_cliente ccl ON ccl.id_cia = cc.id_cia
                                                    AND ccl.tipcli = cc.tipcli
                                                    AND ccl.clase = cc.clase
                                                    AND ccl.obliga = 'S'
                WHERE
                        cc.id_cia = pin_id_cia
                    AND cc.tipcli = pin_tipcli
                    AND cc.codcli = pin_codcli
                    AND cc.codigo = 'ND'
            ) LOOP
                v_aux := v_aux + 1;
                v_clase := v_clase
                           || ' [ '
                           || i.clase_cliente
                           || ' ] ';
            END LOOP;

        END;

        IF v_aux > 0 THEN
            UPDATE cliente_clase
            SET
                codigo = 0
            WHERE
                    id_cia = pin_id_cia
                AND tipcli = pin_tipcli
                AND codcli = pin_codcli
                AND clase = 1;

            pout_mensaje := 'CLIENTE INACTIVO - Clases obligatorias no definidas ' || v_clase;
        ELSE
            pout_mensaje := 'CLIENTE ACTIVO -  Proceso culminado correctamente ...!';
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE pout_mensaje
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_insert_clases_obligatorias;

    FUNCTION sp_obtener_proveedor (
        pin_id_cia NUMBER,
        pin_codcli VARCHAR2
    ) RETURN datatable_proveedor
        PIPELINED
    AS
        v_table datatable_proveedor;
    BEGIN
        SELECT
            c.id_cia,
            c.codcli,
            c.tident,
            c.dident,
            c.codsec,
            c.razonc,
            c.codtit,
            c.codven,
            c.codtpe,
            c.codpag,
            c.telefono,
            c.fax,
            c.email,
            c.repres,
            cc.codigo AS situacion,
            cr.codigo AS relacion,
            c.direc1,
            c.direc2,
            c.codtitcom,
            c.regret,
            c.usuari  AS ucreac,
            c.usuari  AS uactua,
            c.fcreac,
            c.factua
        BULK COLLECT
        INTO v_table
        FROM
            cliente       c
            LEFT OUTER JOIN cliente_clase cc ON cc.id_cia = c.id_cia
                                                AND cc.tipcli = 'B'
                                                AND cc.codcli = c.codcli
                                                AND cc.clase = 1
            LEFT OUTER JOIN cliente_clase cr ON cr.id_cia = c.id_cia
                                                AND cr.tipcli = 'B'
                                                AND cr.codcli = c.codcli
                                                AND cr.clase = 4
        WHERE
                c.id_cia = pin_id_cia
            AND c.codcli = pin_codcli
        FETCH NEXT 1 ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_proveedor;

    FUNCTION sp_obtener_cliente (
        pin_id_cia NUMBER,
        pin_codcli VARCHAR2
    ) RETURN datatable_cliente
        PIPELINED
    AS
        v_table datatable_cliente;
    BEGIN
        SELECT
            c.id_cia,
            c.codcli,
            c.tident,
            i.abrevi   AS tidentnombre,
            c.dident,
            c.codsec,
            c.razonc,
            c.codtit,
            c.codven,
            c.codtpe,
            c.telefono,
            c.fax,
            c.email,
            c.limcre1,
            c.limcre2,
            c.repres,
            c.regret,
            c.direc1,
            c.direc2,
            c.codpag,
            c.observ   AS observ,
            (
                SELECT
                    sp_exonerado_a_igv(c.id_cia, 'A', c.codcli, 0)
                FROM
                    dual
            )          AS exoimp,
            (
                CASE
                    WHEN cl.codigo = '1' THEN
                        'S'
                    ELSE
                        'N'
                END
            )          AS clase_01,
            (
                CASE
                    WHEN cl2.codigo IS NULL THEN
                        'N'
                    ELSE
                        cl2.codigo
                END
            )          AS clase_22,
            (
                CASE
                    WHEN cl3.codigo IS NULL THEN
                        'N'
                    ELSE
                        cl3.codigo
                END
            )          AS clase_30,
            (
                CASE
                    WHEN cl4.codigo IS NULL THEN
                        'N'
                    ELSE
                        cl4.codigo
                END
            )          AS clase_32,
            ctp.apepat AS apellidopaterno,
            ctp.apemat AS apeliidomaterno,
            ctp.nombre AS nombres,
            ctp.nrodni,
            ctp.sexo,
            c.fecing,
            CASE
                WHEN c.valident = 'S' THEN
                    'true'
                ELSE
                    'false'
            END        valident,
            tl.titulo  AS titulolista,
            c.usuari   AS ucreac,
            c.usuari   AS uactua,
            c.fcreac,
            c.factua
        BULK COLLECT
        INTO v_table
        FROM
            cliente          c
            LEFT OUTER JOIN cliente_clase    cl ON cl.id_cia = c.id_cia
                                                AND cl.codcli = c.codcli
                                                AND cl.tipcli = 'A'
                                                AND cl.clase = 1
            LEFT OUTER JOIN cliente_clase    cl2 ON cl2.id_cia = c.id_cia
                                                 AND cl2.codcli = c.codcli
                                                 AND cl2.tipcli = 'A'
                                                 AND cl2.clase = 22
            LEFT OUTER JOIN cliente_clase    cl3 ON cl3.id_cia = c.id_cia
                                                 AND cl3.codcli = c.codcli
                                                 AND cl3.tipcli = 'A'
                                                 AND cl3.clase = 30
            LEFT OUTER JOIN cliente_clase    cl4 ON cl4.id_cia = c.id_cia
                                                 AND cl4.codcli = c.codcli
                                                 AND cl4.tipcli = 'A'
                                                 AND cl4.clase = 32
            LEFT OUTER JOIN identidad        i ON i.id_cia = c.id_cia
                                           AND i.tident = c.tident
            LEFT OUTER JOIN cliente_tpersona ctp ON ctp.id_cia = c.id_cia
                                                    AND ctp.codcli = c.codcli
            LEFT OUTER JOIN titulolista      tl ON tl.id_cia = c.id_cia
                                              AND tl.codtit = c.codtit
        WHERE
                c.id_cia = pin_id_cia
            AND c.codcli = pin_codcli;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_cliente;

END;

/
