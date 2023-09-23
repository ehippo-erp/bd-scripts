--------------------------------------------------------
--  DDL for Package Body PACK_COMPR010_DOCORIGEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_COMPR010_DOCORIGEN" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tipo   NUMBER,
        pin_docume NUMBER,
        pin_item   NUMBER
    ) RETURN datatable_compr010_docorigen
        PIPELINED
    AS
        v_table datatable_compr010_docorigen;
    BEGIN
        SELECT
            cd.tipo,
            cd.docume,
            cd.item,
            cd.codpro,
            cd.tdocum,
            cd.serie,
            cd.numero,
            cd.importe,
            cd.femisi,
            cd.tipcam,
            cd.impor01,
            cd.impor02,
            cd.ucreac,
            cd.uactua,
            cd.fcreac,
            cd.factua
        BULK COLLECT
        INTO v_table
        FROM
            compr010_docorigen cd
        WHERE
                cd.id_cia = pin_id_cia
            AND cd.tipo = pin_tipo
            AND cd.docume = pin_docume
            AND cd.item = pin_item;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipo   NUMBER,
        pin_docume NUMBER,
        pin_item   NUMBER,
        pin_tdocum VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_compr010_docorigen
        PIPELINED
    AS
        v_table datatable_compr010_docorigen;
    BEGIN
        SELECT
            cd.tipo,
            cd.docume,
            cd.item,
            cd.codpro,
            cd.tdocum,
            cd.serie,
            cd.numero,
            cd.importe,
            cd.femisi,
            cd.tipcam,
            cd.impor01,
            cd.impor02,
            cd.ucreac,
            cd.uactua,
            cd.fcreac,
            cd.factua
        BULK COLLECT
        INTO v_table
        FROM
            compr010_docorigen cd
        WHERE
                cd.id_cia = pin_id_cia
            AND ( pin_tipo = - 1
                  OR pin_tipo IS NULL
                  OR cd.tipo = pin_tipo )
            AND ( pin_docume = - 1
                  OR pin_docume IS NULL
                  OR cd.docume = pin_docume )
            AND ( pin_item = - 1
                  OR pin_item IS NULL
                  OR cd.item = pin_item )
            AND ( pin_tdocum IS NULL
                  OR cd.tdocum = pin_tdocum )
            AND cd.femisi BETWEEN pin_fdesde AND pin_fhasta
        FETCH NEXT 1000 ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END;

/*
set SERVEROUTPUT on;
/
DECLARE 
mensaje VARCHAR2(500);
cadjson VARCHAR2(5000);
BEGIN
    cadjson := '{
        "tipo":100,
        "docume":100,
        "item":100,
        "codpro":"PRUEBA PRO",
        "tdocum":"PRUEBA TDOC",
        "serie":"SERIE",
        "numero":"NUMERO",
        "importe":45.00,
        "femisi":"2022-05-12",
        "tipcam":3.78,
        "impor01":546.54,
        "impor02":202.45,
        "ucreac":"admin",
        "uactua":"admin"
        }';
        pack_compr010_docorigen.sp_save(100,cadjson,1,mensaje);
        DBMS_OUTPUT.PUT_LINE(mensaje);
END; 
*/

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                      json_object_t;
        rec_compr010_docorigen compr010_docorigen%rowtype;
        v_accion               VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_compr010_docorigen.id_cia := pin_id_cia;
        rec_compr010_docorigen.tipo := o.get_number('tipo');
        rec_compr010_docorigen.docume := o.get_number('docume');
        rec_compr010_docorigen.item := o.get_number('item');
        rec_compr010_docorigen.codpro := o.get_string('codpro');
        rec_compr010_docorigen.tdocum := o.get_string('tdocum');
        rec_compr010_docorigen.serie := o.get_string('serie');
        rec_compr010_docorigen.numero := o.get_string('numero');
        rec_compr010_docorigen.importe := o.get_number('importe');
        rec_compr010_docorigen.femisi := o.get_date('femisi');
        rec_compr010_docorigen.tipcam := o.get_number('tipcam');
        rec_compr010_docorigen.impor01 := o.get_number('impor01');
        rec_compr010_docorigen.impor02 := o.get_number('impor02');
        rec_compr010_docorigen.ucreac := o.get_string('ucreac');
        rec_compr010_docorigen.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO compr010_docorigen (
                    id_cia,
                    tipo,
                    docume,
                    item,
                    codpro,
                    tdocum,
                    serie,
                    numero,
                    importe,
                    femisi,
                    tipcam,
                    impor01,
                    impor02,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_compr010_docorigen.id_cia,
                    rec_compr010_docorigen.tipo,
                    rec_compr010_docorigen.docume,
                    rec_compr010_docorigen.item,
                    rec_compr010_docorigen.codpro,
                    rec_compr010_docorigen.tdocum,
                    rec_compr010_docorigen.serie,
                    rec_compr010_docorigen.numero,
                    rec_compr010_docorigen.importe,
                    rec_compr010_docorigen.femisi,
                    rec_compr010_docorigen.tipcam,
                    rec_compr010_docorigen.impor01,
                    rec_compr010_docorigen.impor02,
                    rec_compr010_docorigen.ucreac,
                    rec_compr010_docorigen.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE compr010_docorigen
                SET
                    codpro =
                        CASE
                            WHEN rec_compr010_docorigen.codpro IS NULL THEN
                                codpro
                            ELSE
                                rec_compr010_docorigen.codpro
                        END,
                    tdocum =
                        CASE
                            WHEN rec_compr010_docorigen.tdocum IS NULL THEN
                                tdocum
                            ELSE
                                rec_compr010_docorigen.tdocum
                        END,
                    serie =
                        CASE
                            WHEN rec_compr010_docorigen.serie IS NULL THEN
                                serie
                            ELSE
                                rec_compr010_docorigen.serie
                        END,
                    numero =
                        CASE
                            WHEN rec_compr010_docorigen.numero IS NULL THEN
                                numero
                            ELSE
                                rec_compr010_docorigen.numero
                        END,
                    importe =
                        CASE
                            WHEN rec_compr010_docorigen.importe IS NULL THEN
                                importe
                            ELSE
                                rec_compr010_docorigen.importe
                        END,
                    femisi =
                        CASE
                            WHEN rec_compr010_docorigen.femisi IS NULL THEN
                                femisi
                            ELSE
                                rec_compr010_docorigen.femisi
                        END,
                    tipcam =
                        CASE
                            WHEN rec_compr010_docorigen.tipcam IS NULL THEN
                                tipcam
                            ELSE
                                rec_compr010_docorigen.tipcam
                        END,
                    impor01 =
                        CASE
                            WHEN rec_compr010_docorigen.impor01 IS NULL THEN
                                impor01
                            ELSE
                                rec_compr010_docorigen.impor01
                        END,
                    impor02 =
                        CASE
                            WHEN rec_compr010_docorigen.impor02 IS NULL THEN
                                impor02
                            ELSE
                                rec_compr010_docorigen.impor02
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_compr010_docorigen.id_cia
                    AND tipo = rec_compr010_docorigen.tipo
                    AND docume = rec_compr010_docorigen.docume
                    AND item = rec_compr010_docorigen.item;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM compr010_docorigen
                WHERE
                        id_cia = rec_compr010_docorigen.id_cia
                    AND tipo = rec_compr010_docorigen.tipo
                    AND docume = rec_compr010_docorigen.docume
                    AND item = rec_compr010_docorigen.item;

                COMMIT;
        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con codigo de tipo [ '
                                    || rec_compr010_docorigen.tipo
                                    || ' ] [ '
                                    || rec_compr010_docorigen.docume
                                    || ' ]  [ '
                                    || rec_compr010_docorigen.item
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

    END sp_save;

    FUNCTION sp_relacion (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_relacion
        PIPELINED
    AS
        v_table datatable_relacion;
    BEGIN
        SELECT
            cc.ruc,
            c.nserie  AS serie,
            c.numero,
            c.femisi,
            c.importe,
            d.tdocum AS  tdocumori,
            d.serie   AS serieori,
            d.numero  AS numeroori,
            d.femisi  AS femisiori,
            d.importe AS importeori
        BULK COLLECT
        INTO v_table
        FROM
            compr010           c
            LEFT OUTER JOIN compr010_docorigen d ON d.id_cia = c.id_cia
                                                    AND d.tipo = c.tipo
                                                    AND d.docume = c.docume
            LEFT OUTER JOIN companias          cc ON cc.cia = c.id_cia
        WHERE
                c.id_cia = pin_id_cia
            AND c.libro = '71'
            AND c.periodo = pin_periodo
            AND ( pin_mes = - 1
                  OR c.mes = pin_mes );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_relacion;

    FUNCTION sp_relacion_compras (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_relacion_compras
        PIPELINED
    AS
        v_table datatable_relacion_compras;
    BEGIN
        SELECT
            cc.ruc,
            c.nserie  AS serie,
            c.numero,
            c.femisi,
            c.importe,
            d.tdocum AS  tdocumori,
            d.serie   AS serieori,
            d.numero  AS numeroori,
            d.femisi  AS femisiori,
            d.importe AS importeori
        BULK COLLECT
        INTO v_table
        FROM
            compr010           c
            LEFT OUTER JOIN compr010_docorigen d ON d.id_cia = c.id_cia
                                                    AND d.tipo = c.tipo
                                                    AND d.docume = c.docume
            LEFT OUTER JOIN companias          cc ON cc.cia = c.id_cia
        WHERE
                c.id_cia = pin_id_cia
            AND c.libro = '74'
            AND c.periodo = pin_periodo
            AND ( pin_mes = - 1
                  OR c.mes = pin_mes );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_relacion_compras;

END;

/
