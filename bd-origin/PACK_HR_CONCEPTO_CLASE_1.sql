--------------------------------------------------------
--  DDL for Package Body PACK_HR_CONCEPTO_CLASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_CONCEPTO_CLASE" AS

    FUNCTION sp_buscar_valor_clase_codigo (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2,
        pin_clase  NUMBER,
        pin_codigo VARCHAR2
    ) RETURN datatable_valor_clase_codigo
        PIPELINED
    AS
        v_table datatable_valor_clase_codigo;
    BEGIN
        IF pin_codigo = '01' THEN
            SELECT
                id_cia,
                pin_codcon,
                pin_clase,
                pin_codigo,
                codcon AS valor,
                nombre AS desvalor
            BULK COLLECT
            INTO v_table
            FROM
                concepto
            WHERE
                id_cia = pin_id_cia
            ORDER BY
                codcon ASC;

        ELSIF pin_codigo = '02' THEN
            SELECT
                id_cia,
                pin_codcon,
                pin_clase,
                pin_codigo,
                codfac AS valor,
                nombre AS desvalor
            BULK COLLECT
            INTO v_table
            FROM
                factor_planilla
            WHERE
                    id_cia = pin_id_cia
                AND indafp = 'N'
                AND nombre <> 'LIBRE'
            ORDER BY
                codfac ASC;

        ELSIF pin_codigo = '03' THEN
            SELECT
                id_cia,
                pin_codcon,
                pin_clase,
                pin_codigo,
                codfac AS valor,
                nombre AS desvalor
            BULK COLLECT
            INTO v_table
            FROM
                factor_planilla
            WHERE
                    id_cia = pin_id_cia
                AND indafp = 'S'
                AND nombre <> 'LIBRE'
            ORDER BY
                codfac ASC;

        ELSE
            NULL;
        END IF;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_valor_clase_codigo;

    FUNCTION sp_buscar_tipoformato (
        pin_id_cia NUMBER,
        pin_codfor NUMBER
    ) RETURN datatable_tipoformato
        PIPELINED
    AS
        v_table datatable_tipoformato;
        v_rec   datarecord_tipoformato := datarecord_tipoformato(NULL, NULL, NULL);
    BEGIN
        FOR i IN pack_hr_concepto_clase.ka_codfor.first..pack_hr_concepto_clase.ka_codfor.last LOOP
            v_rec.id_cia := pin_id_cia;
            v_rec.codfor := i;
            v_rec.descodfor := pack_hr_concepto_clase.ka_codfor(i);
            IF v_rec.codfor = pin_codfor OR pin_codfor IS NULL THEN
                PIPE ROW ( v_rec );
            END IF;

        END LOOP;

        RETURN;
    END sp_buscar_tipoformato;

    FUNCTION sp_test_concepto (
        pin_id_cia    NUMBER,
        pin_codcon    VARCHAR2,
        pin_clase     NUMBER,
        pin_codigo    VARCHAR2,
        pin_vstrg     VARCHAR2,
        pin_vresult   VARCHAR2,
        pin_vposition VARCHAR2,
        pin_vsufijo   VARCHAR2,
        pin_vprefijo  VARCHAR2,
        pin_codfor    NUMBER
    ) RETURN datatable_test_concepto
        PIPELINED
    AS

        v_rec     datarecord_test_concepto;
        v_char    VARCHAR2(100) := '9,9999999999';
        v_prefijo VARCHAR2(100 CHAR);
        v_sufijo  VARCHAR2(100 CHAR);
    BEGIN
        SELECT
            id_cia,
            codcon,
            nombre
        INTO
            v_rec.id_cia,
            v_rec.codcon,
            v_rec.descon
        FROM
            concepto
        WHERE
                id_cia = pin_id_cia
            AND codcon = pin_codcon;

        IF pin_codfor = 1 THEN
            v_char := '0';
        ELSIF pin_codfor = 2 THEN
            v_char := '0.99';
        ELSIF pin_codfor = 3 THEN
            v_char := '0.9999';
        ELSIF pin_codfor = 4 THEN
            v_char := '0.999999';
        ELSIF pin_codfor = 5 THEN
            v_char := '99.99';
        ELSIF pin_codfor = 6 THEN
            v_char := '-99.99';
        ELSIF pin_codfor = 7 THEN
            v_char := 'ND';
        ELSE
            v_char := v_char;
        END IF;

        IF pin_vposition = 'P' THEN
            v_prefijo := pin_vprefijo
                         || trim(v_char)
                         || pin_vsufijo
                         || ' ';
        ELSIF pin_vposition = 'S' THEN
            v_sufijo := ' '
                        || pin_vprefijo
                        || trim(v_char)
                        || pin_vsufijo;
        ELSE
            v_prefijo := 'ERROR ';
            v_sufijo := ' ERROR';
        END IF;

        v_rec.rotulo := v_prefijo
                        || v_rec.descon
                        || v_sufijo;
        v_rec.valcon := 0.0;
        PIPE ROW ( v_rec );
    END sp_test_concepto;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2,
        pin_clase  NUMBER,
        pin_codigo VARCHAR2
    ) RETURN datatable_concepto_clase
        PIPELINED
    AS
        v_table datatable_concepto_clase;
    BEGIN
        SELECT
            pc.id_cia,
            pc.codcon,
            pc.clase,
            pc.codigo,
            cc.descri  AS descla,
            ccc.descri AS descodcla,
            pc.vstrg,
            CASE
                WHEN pc.clase IN ( 15, 16, 17, 20, 21,
                                   22, 23 ) THEN
                        CASE pc.codigo
                            WHEN '01' THEN
                                (
                                    SELECT
                                        nombre
                                    FROM
                                        concepto
                                    WHERE
                                            id_cia = pc.id_cia
                                        AND codcon = pc.vstrg
                                )
                            WHEN '02' THEN
                                (
                                    SELECT
                                        nombre
                                    FROM
                                        factor_planilla
                                    WHERE
                                            id_cia = pc.id_cia
                                        AND codfac = pc.vstrg
                                        AND indafp = 'N'
                                )
                            WHEN '03' THEN
                                (
                                    SELECT
                                        nombre
                                    FROM
                                        factor_planilla
                                    WHERE
                                            id_cia = pc.id_cia
                                        AND codfac = pc.vstrg
                                        AND indafp = 'S'
                                )
                            ELSE
                                ' '
                        END
                ELSE
                    NULL
            END        AS descri,
            pc.vresult,
            pc.vposition,
            CASE
                WHEN pc.vposition = 'P' THEN
                    'PREFIJO'
                ELSE
                    'SUFIJO'
            END,
            pc.vprefijo,
            pc.vsufijo,
            pc.codfor,
            pcc.descodfor,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
            concepto_clase                                                     pc
            LEFT OUTER JOIN clase_concepto                                                     cc ON cc.id_cia = pc.id_cia
                                                 AND cc.clase = pc.clase
            LEFT OUTER JOIN clase_concepto_codigo                                              ccc ON ccc.id_cia = pc.id_cia
                                                         AND ccc.clase = pc.clase
                                                         AND ccc.codigo = pc.codigo
            LEFT OUTER JOIN pack_hr_concepto_clase.sp_buscar_tipoformato(pc.id_cia, pc.codfor) pcc ON pcc.codfor = pc.codfor
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.codcon = pin_codcon
            AND pc.clase = pin_clase
            AND pc.codigo = pin_codigo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2
    ) RETURN datatable_concepto_clase
        PIPELINED
    AS
        v_table datatable_concepto_clase;
    BEGIN
        SELECT
            pc.id_cia,
            pc.codcon,
            pc.clase,
            pc.codigo,
            cc.descri  AS descla,
            ccc.descri AS descodcla,
            pc.vstrg,
            CASE
                WHEN pc.clase IN ( 15, 16, 17, 20, 21,
                                   22, 23 ) THEN
                        CASE pc.codigo
                            WHEN '01' THEN
                                (
                                    SELECT
                                        nombre
                                    FROM
                                        concepto
                                    WHERE
                                            id_cia = pc.id_cia
                                        AND codcon = pc.vstrg
                                )
                            WHEN '02' THEN
                                (
                                    SELECT
                                        nombre
                                    FROM
                                        factor_planilla
                                    WHERE
                                            id_cia = pc.id_cia
                                        AND codfac = pc.vstrg
                                        AND indafp = 'N'
                                )
                            WHEN '03' THEN
                                (
                                    SELECT
                                        nombre
                                    FROM
                                        factor_planilla
                                    WHERE
                                            id_cia = pc.id_cia
                                        AND codfac = pc.vstrg
                                        AND indafp = 'S'
                                )
                            ELSE
                                ' '
                        END
                ELSE
                    NULL
            END        AS descri,
            pc.vresult,
            pc.vposition,
            CASE
                WHEN pc.vposition = 'P' THEN
                    'PREFIJO'
                ELSE
                    'SUFIJO'
            END,
            pc.vprefijo,
            pc.vsufijo,
            pc.codfor,
            pcc.descodfor,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
            concepto_clase                                                     pc
            LEFT OUTER JOIN clase_concepto                                                     cc ON cc.id_cia = pc.id_cia
                                                 AND cc.clase = pc.clase
            LEFT OUTER JOIN clase_concepto_codigo                                              ccc ON ccc.id_cia = pc.id_cia
                                                         AND ccc.clase = pc.clase
                                                         AND ccc.codigo = pc.codigo
            LEFT OUTER JOIN pack_hr_concepto_clase.sp_buscar_tipoformato(pc.id_cia, pc.codfor) pcc ON pcc.codfor = pc.codfor
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.codcon = pin_codcon;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "codcon":"P001",
--                "clase":16,
--                "codigo":"A",
--                "vstrg":"PRUEBA",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_concepto_clase.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_concepto_clase.sp_obtener(66,'P001',16,'A');
--
--SELECT * FROM pack_hr_concepto_clase.sp_buscar(66,'P001');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                  json_object_t;
        rec_concepto_clase concepto_clase%rowtype;
        v_accion           VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_concepto_clase.id_cia := pin_id_cia;
        rec_concepto_clase.codcon := o.get_string('codcon');
        rec_concepto_clase.clase := o.get_number('clase');
        rec_concepto_clase.codigo := o.get_string('codigo');
        rec_concepto_clase.vstrg := o.get_string('vstrg');
        rec_concepto_clase.vresult := o.get_string('vresult');
        rec_concepto_clase.vposition := o.get_string('vposition');
        rec_concepto_clase.vsufijo := o.get_string('vsufijo');
        rec_concepto_clase.vprefijo := o.get_string('vprefijo');
        rec_concepto_clase.codfor := o.get_number('codfor');
        rec_concepto_clase.ucreac := o.get_string('ucreac');
        rec_concepto_clase.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO concepto_clase (
                    id_cia,
                    codcon,
                    clase,
                    codigo,
                    vstrg,
                    vresult,
                    vposition,
                    vprefijo,
                    vsufijo,
                    codfor,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_concepto_clase.id_cia,
                    rec_concepto_clase.codcon,
                    rec_concepto_clase.clase,
                    rec_concepto_clase.codigo,
                    rec_concepto_clase.vstrg,
                    rec_concepto_clase.vresult,
                    rec_concepto_clase.vposition,
                    rec_concepto_clase.vprefijo,
                    rec_concepto_clase.vsufijo,
                    rec_concepto_clase.codfor,
                    rec_concepto_clase.ucreac,
                    rec_concepto_clase.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE concepto_clase
                SET
                    vstrg =
                        CASE
                            WHEN rec_concepto_clase.vstrg IS NULL THEN
                                vstrg
                            ELSE
                                rec_concepto_clase.vstrg
                        END,
                    vresult =
                        CASE
                            WHEN rec_concepto_clase.vresult IS NULL THEN
                                vresult
                            ELSE
                                rec_concepto_clase.vresult
                        END,
                    vposition =
                        CASE
                            WHEN rec_concepto_clase.vposition IS NULL THEN
                                vposition
                            ELSE
                                rec_concepto_clase.vposition
                        END,
                    vprefijo = rec_concepto_clase.vprefijo,
                    vsufijo = rec_concepto_clase.vsufijo,
                    codfor =
                        CASE
                            WHEN rec_concepto_clase.codfor IS NULL THEN
                                codfor
                            ELSE
                                rec_concepto_clase.codfor
                        END,
                    uactua = rec_concepto_clase.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_concepto_clase.id_cia
                    AND codcon = rec_concepto_clase.codcon
                    AND clase = rec_concepto_clase.clase
                    AND codigo = rec_concepto_clase.codigo;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM concepto_clase
                WHERE
                        id_cia = rec_concepto_clase.id_cia
                    AND codcon = rec_concepto_clase.codcon
                    AND clase = rec_concepto_clase.clase
                    AND codigo = rec_concepto_clase.codigo;

        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con codigo de Concepto [ '
                                    || rec_concepto_clase.codcon
                                    || ' ] y con la Clase / Codigo [ '
                                    || rec_concepto_clase.clase
                                    || ' / '
                                    || rec_concepto_clase.codigo
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se insertar o modificar este registro porque la Clase [ '
                                        || rec_concepto_clase.clase
                                        || ' ] y el Codigo ['
                                        || rec_concepto_clase.codigo
                                        || ' ] no existen ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
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

            END IF;
    END sp_save;

END;

/
