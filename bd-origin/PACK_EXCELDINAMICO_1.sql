--------------------------------------------------------
--  DDL for Package Body PACK_EXCELDINAMICO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_EXCELDINAMICO" AS

    FUNCTION sp_buscar (
        pin_id_cia    NUMBER,
        pin_codmod    NUMBER,
        pin_desexc    VARCHAR2,
        pin_coduser   VARCHAR2,
        pin_swsistema VARCHAR2
    ) RETURN datatable_exceldinamico
        PIPELINED
    AS
        v_table datatable_exceldinamico;
    BEGIN
        SELECT
            t.id_cia,
            t.codexc,
            t.desexc,
            t.cadsql,
            t.observ,
            t.nlibro,
            t.codmod,
            t.tipbd,
            t.params,
            t.swtabd,
            t.swsistema
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    exe.id_cia AS id_cia,
                    exe.codexc AS codexc,
                    exe.desexc,
                    exe.cadsql,
                    exe.observ,
                    exe.nlibro,
                    exe.codmod,
                    exe.tipbd,
                    exe.params,
                    exe.swtabd,
                    'N'        AS swsistema
                FROM
                    exceldinamico_especifico exe
                WHERE
                        exe.id_cia = pin_id_cia
                    AND ( pin_desexc IS NULL
                          OR ( upper(exe.desexc) LIKE upper('%'
                                                            || pin_desexc
                                                            || '%') )
                          OR ( to_char(exe.codexc) = pin_desexc ) )
                    AND ( pin_swsistema IS NULL
                          OR exe.swsistema = pin_swsistema )
                    AND ( nvl(pin_codmod, - 1) = - 1
                          OR exe.codmod = pin_codmod )
                UNION ALL
                SELECT
                    pin_id_cia AS id_cia,
                    exg.codexc AS codexc,
                    exg.desexc AS desexc,
                    exg.cadsql,
                    exg.observ,
                    exg.nlibro,
                    exg.codmod,
                    exg.tipbd,
                    exg.params,
                    exg.swtabd,
                    'S'        AS swsistema
                FROM
                    exceldinamico_generico exg
                WHERE
                        exg.id_cia = 1
                    AND ( pin_desexc IS NULL
                          OR ( upper(exg.desexc) LIKE upper('%'
                                                            || pin_desexc
                                                            || '%') )
                          OR ( to_char(exg.codexc) = pin_desexc ) )
                    AND ( pin_swsistema IS NULL
                          OR exg.swsistema = pin_swsistema )
                    AND ( nvl(pin_codmod, - 1) = - 1
                          OR exg.codmod = pin_codmod )
            ) t
        WHERE
            nvl(pin_coduser, 'admin') IN ( 'admin','005' )
            OR EXISTS (
                SELECT
                    eu.*
                FROM
                    exceldinamico_usuario eu
                WHERE
                        eu.id_cia = t.id_cia
                    AND eu.codexc = t.codexc
                    AND eu.coduser = pin_coduser
            )
            OR EXISTS (
                SELECT
                    eg.*
                FROM
                         exceldinamico_grupo eg
                    INNER JOIN usuario_grupo ug ON ug.id_cia = eg.id_cia
                                                   AND ug.codgrupo = eg.codgrupo
                                                   AND ug.coduser = pin_coduser
                WHERE
                        eg.id_cia = t.id_cia
                    AND eg.codexc = t.codexc
                    AND ug.coduser = pin_coduser
            )
        ORDER BY
            t.codexc DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codexc NUMBER
    ) RETURN datatable_exceldinamico
        PIPELINED
    AS
        v_table datatable_exceldinamico;
    BEGIN
        SELECT
            t.*
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    id_cia,
                    codexc,
                    desexc,
                    cadsql,
                    observ,
                    nlibro,
                    codmod,
                    tipbd,
                    params,
                    swtabd,
                    'N' AS swsistema
                FROM
                    exceldinamico_especifico
                WHERE
                        id_cia = pin_id_cia
                    AND codexc = pin_codexc
                UNION ALL
                SELECT
                    id_cia,
                    codexc,
                    desexc,
                    cadsql,
                    observ,
                    nlibro,
                    codmod,
                    tipbd,
                    params,
                    swtabd,
                    'S' AS swsistema
                FROM
                    exceldinamico_generico
                WHERE
                        id_cia = 1
                    AND codexc = pin_codexc
            ) t
        FETCH NEXT 1 ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;


--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "generico":"N",
--                "codexc":701,
--                "nlibro":"REPORTE PRUEBA"
--                }';
--pack_exceldinamico.sp_save(25, 'SELECT 5 FROM DUAL','AYUDA',cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_exceldinamico.sp_obtener(25,701);
--
--SELECT * FROM pack_exceldinamico.sp_buscar(66,NULL,NULL,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_cadsql  IN VARCHAR2,
        pin_observ  IN VARCHAR2,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        pout_mensaje               VARCHAR2(1000);
        o                          json_object_t;
        rec_exceldinamico          exceldinamico%rowtype;
        rec_exceldinamico_generico exceldinamico_generico%rowtype;
        v_accion                   VARCHAR2(50) := '';
        v_generico                 VARCHAR2(1 CHAR) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_exceldinamico_generico.id_cia := pin_id_cia;
        rec_exceldinamico_generico.codexc := o.get_string('codigo');
        rec_exceldinamico_generico.desexc := o.get_string('descri');
        rec_exceldinamico_generico.nlibro := o.get_string('nlibro');
        rec_exceldinamico_generico.codmod := o.get_number('codmod');
        rec_exceldinamico_generico.tipbd := o.get_number('codmod');
        rec_exceldinamico_generico.params := o.get_string('params');
        rec_exceldinamico_generico.swtabd := o.get_string('swtabd');
        v_generico := o.get_string('swsistema');
        v_accion := '';
        IF
            nvl(v_generico, 'N') = 'N'
            AND nvl(rec_exceldinamico_generico.codexc, 0) <> 0
        THEN
            IF rec_exceldinamico_generico.codexc >= 1000 THEN
                pout_mensaje := 'El REPORTE marcado como ESPECIFICO DE LA EMPRESA no pueden tener un CODIGO mayor o igual a 1000 ...!'
                ;
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;
        ELSIF
            nvl(v_generico, 'N') = 'S'
            AND nvl(rec_exceldinamico_generico.codexc, 0) <> 0
        THEN
            IF rec_exceldinamico_generico.codexc < 1000 THEN
                pout_mensaje := 'El REPORTE marcado como de SISTEMA no pueden tener un CODIGO menor a 1000 ...!';
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;
        END IF;

        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                IF nvl(v_generico, 'N') = 'N' THEN
                    IF nvl(rec_exceldinamico_generico.codexc, 0) = 0 THEN
                        BEGIN
                            SELECT
                                nvl(MAX(nvl(codexc, 0)),
                                    0)
                            INTO rec_exceldinamico_generico.codexc
                            FROM
                                exceldinamico_especifico
                            WHERE
                                id_cia = pin_id_cia;

                        EXCEPTION
                            WHEN no_data_found THEN
                                rec_exceldinamico_generico.codexc := 0;
                        END;

                        rec_exceldinamico_generico.codexc := rec_exceldinamico_generico.codexc + 1;
                    END IF;

                    INSERT INTO exceldinamico_especifico VALUES (
                        rec_exceldinamico_generico.id_cia,
                        rec_exceldinamico_generico.codexc,
                        rec_exceldinamico_generico.desexc,
                        pin_cadsql,
                        pin_observ,
                        rec_exceldinamico_generico.nlibro,
                        rec_exceldinamico_generico.codmod,
                        rec_exceldinamico_generico.tipbd,
                        rec_exceldinamico_generico.params,
                        rec_exceldinamico_generico.swtabd,
                        rec_exceldinamico_generico.swsistema
                    );

                -- INSERTANDO EN EXCELDINAMICO GRUPO
                    INSERT INTO exceldinamico_grupo (
                        id_cia,
                        codexc,
                        codgrupo,
                        ucreac,
                        uactua,
                        fcreac,
                        factua
                    ) VALUES (
                        rec_exceldinamico_generico.id_cia,
                        rec_exceldinamico_generico.codexc,
                        1,
                        'admin',
                        'admin',
                        current_timestamp,
                        current_timestamp
                    );

                ELSE
                    IF nvl(rec_exceldinamico_generico.codexc, 0) = 0 THEN
                        BEGIN
                            SELECT
                                nvl(MAX(nvl(codexc, 0)),
                                    0)
                            INTO rec_exceldinamico_generico.codexc
                            FROM
                                exceldinamico_generico
                            WHERE
                                id_cia = pin_id_cia;

                        EXCEPTION
                            WHEN no_data_found THEN
                                rec_exceldinamico_generico.codexc := 0;
                        END;

                        rec_exceldinamico_generico.codexc := rec_exceldinamico_generico.codexc + 1;
                    END IF;

                    INSERT INTO exceldinamico_generico VALUES (
                        1,
                        rec_exceldinamico_generico.codexc,
                        rec_exceldinamico_generico.desexc,
                        pin_cadsql,
                        pin_observ,
                        rec_exceldinamico_generico.nlibro,
                        rec_exceldinamico_generico.codmod,
                        rec_exceldinamico_generico.tipbd,
                        rec_exceldinamico_generico.params,
                        rec_exceldinamico_generico.swtabd,
                        rec_exceldinamico_generico.swsistema
                    );

                    FOR i IN (
                        SELECT
                            *
                        FROM
                            companias
                    ) LOOP
                    -- INSERTANDO EN EXCELDINAMICO GRUPO - MASIVO
                        BEGIN
                            INSERT INTO exceldinamico_grupo (
                                id_cia,
                                codexc,
                                codgrupo,
                                ucreac,
                                uactua,
                                fcreac,
                                factua
                            ) VALUES (
                                i.cia,
                                rec_exceldinamico_generico.codexc,
                                1,
                                'admin',
                                'admin',
                                current_timestamp,
                                current_timestamp
                            );

                        EXCEPTION
                            WHEN OTHERS THEN
                                IF sqlcode = -2291 THEN
                                    INSERT INTO grupo_usuario VALUES (
                                        i.cia,
                                        1,
                                        'GRUPO GENERAL DE USUARIOS',
                                        'S',
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL
                                    );

                                    INSERT INTO exceldinamico_grupo (
                                        id_cia,
                                        codexc,
                                        codgrupo,
                                        ucreac,
                                        uactua,
                                        fcreac,
                                        factua
                                    ) VALUES (
                                        i.cia,
                                        rec_exceldinamico_generico.codexc,
                                        1,
                                        'admin',
                                        'admin',
                                        current_timestamp,
                                        current_timestamp
                                    );

                                ELSE
                                    pin_mensaje := 'mensaje : '
                                                   || sqlerrm
                                                   || ' codite :'
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
                                    RETURN;
                                END IF;
                        END;
                    END LOOP;

                END IF;

            WHEN 2 THEN
                v_accion := 'La actualización';
                IF nvl(v_generico, 'N') = 'N' THEN
                    UPDATE exceldinamico_especifico
                    SET
                        desexc = rec_exceldinamico_generico.desexc,
                        cadsql = pin_cadsql,
                        observ = pin_observ,
                        nlibro = rec_exceldinamico_generico.nlibro,
                        codmod = rec_exceldinamico_generico.codmod,
                        tipbd = rec_exceldinamico_generico.tipbd
                    WHERE
                            id_cia = rec_exceldinamico_generico.id_cia
                        AND codexc = rec_exceldinamico_generico.codexc;

                ELSE
                    UPDATE exceldinamico_generico
                    SET
                        desexc = rec_exceldinamico_generico.desexc,
                        cadsql = pin_cadsql,
                        observ = pin_observ,
                        nlibro = rec_exceldinamico_generico.nlibro,
                        codmod = rec_exceldinamico_generico.codmod,
                        tipbd = rec_exceldinamico_generico.tipbd
                    WHERE
                            id_cia = 1
                        AND codexc = rec_exceldinamico_generico.codexc;

                END IF;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                IF nvl(v_generico, 'N') = 'N' THEN
                    DELETE FROM exceldinamico_especifico
                    WHERE
                            id_cia = rec_exceldinamico_generico.id_cia
                        AND codexc = rec_exceldinamico_generico.codexc;

                ELSE
                    DELETE FROM exceldinamico_generico
                    WHERE
                            id_cia = rec_exceldinamico_generico.id_cia
                        AND codexc = rec_exceldinamico_generico.codexc;

                END IF;

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
                    'message' VALUE 'El registro con CODIGO DEL REPORTE [ '
                                    || rec_exceldinamico_generico.codexc
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codexc :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_save;

END;

/
