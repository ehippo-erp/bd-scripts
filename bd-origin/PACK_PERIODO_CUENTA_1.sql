--------------------------------------------------------
--  DDL for Package Body PACK_PERIODO_CUENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_PERIODO_CUENTA" AS

    FUNCTION sp_buscar_tiporango (
        pin_id_cia NUMBER,
        pin_tipran NUMBER
    ) RETURN datatable_tiporango
        PIPELINED
    AS
        v_table datatable_tiporango;
        v_rec   datarecord_tiporango := datarecord_tiporango(NULL, NULL, NULL);
    BEGIN
        FOR i IN pack_periodo_cuenta.ka_tipran.first..pack_periodo_cuenta.ka_tipran.last LOOP
            v_rec.id_cia := pin_id_cia;
            v_rec.tipran := i;
            v_rec.destipran := pack_periodo_cuenta.ka_tipran(i);
            IF v_rec.tipran = pin_tipran OR pin_tipran IS NULL THEN
                PIPE ROW ( v_rec );
            END IF;

        END LOOP;

        RETURN;
    END sp_buscar_tiporango;

    FUNCTION sp_buscar_rango (
        pin_id_cia NUMBER,
        pin_tipran NUMBER
    ) RETURN datatable_rango
        PIPELINED
    AS
        v_table datatable_rango;
    BEGIN
        SELECT DISTINCT
            id_cia,
            tipran,
            tipven,
            CASE WHEN tipven = 1 THEN
                'VENCIDOS'
            ELSE
                'POR VENCER'
            END as desven,
            orden,
            desran
        BULK COLLECT
        INTO v_table
        FROM
            periodo_cuenta
        WHERE
                id_cia = pin_id_cia
            AND tipran = pin_tipran
        ORDER BY
            tipven ASC,
            orden ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_rango;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tipran NUMBER,
        pin_orden  NUMBER
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        SELECT
            pc.id_cia,
            pc.tipran,
            ptr.destipran,
            pc.orden,
            pc.desran,
            pc.rdesde,
            pc.rhasta,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
                 periodo_cuenta pc
            INNER JOIN pack_periodo_cuenta.sp_buscar_tiporango(pc.id_cia, pc.tipran) ptr ON ptr.id_cia = pc.id_cia
                                                                                            AND ptr.tipran = pc.tipran
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.tipran = pin_tipran
            AND pc.orden = pin_orden
            AND pc.tipven = 1;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipran NUMBER
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        SELECT
            pc.id_cia,
            pc.tipran,
            ptr.destipran,
            pc.orden,
            pc.desran,
            pc.rdesde,
            pc.rhasta,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
                 periodo_cuenta pc
            INNER JOIN pack_periodo_cuenta.sp_buscar_tiporango(pc.id_cia, pc.tipran) ptr ON ptr.id_cia = pc.id_cia
                                                                                            AND ptr.tipran = pc.tipran
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.tipven = 1
            AND ( pin_tipran IS NULL
                  OR pc.tipran = pin_tipran );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                  json_object_t;
        rec_periodo_cuenta periodo_cuenta%rowtype;
        v_accion           VARCHAR2(50) := '';
        pout_mensaje       VARCHAR2(1000) := '';
        v_periodo          NUMBER := 0;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_periodo_cuenta.id_cia := pin_id_cia;
        rec_periodo_cuenta.tipran := o.get_number('tipran');
        rec_periodo_cuenta.orden := o.get_number('orden');
        rec_periodo_cuenta.rdesde := o.get_number('rdesde');
        rec_periodo_cuenta.rhasta := o.get_number('rhasta');
        rec_periodo_cuenta.ucreac := o.get_string('ucreac');
        rec_periodo_cuenta.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                -- INSERTANDO TIPVEN = 1
                INSERT INTO periodo_cuenta (
                    id_cia,
                    tipran,
                    tipven,
                    orden,
                    rdesde,
                    rhasta,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_periodo_cuenta.id_cia,
                    rec_periodo_cuenta.tipran,
                    1,
                    rec_periodo_cuenta.orden,
                    rec_periodo_cuenta.rdesde,
                    rec_periodo_cuenta.rhasta,
                    rec_periodo_cuenta.ucreac,
                    rec_periodo_cuenta.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );
            -- INSERTANDO TIPVEN = 2
                INSERT INTO periodo_cuenta (
                    id_cia,
                    tipran,
                    tipven,
                    orden,
                    rdesde,
                    rhasta,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_periodo_cuenta.id_cia,
                    rec_periodo_cuenta.tipran,
                    2,
                    rec_periodo_cuenta.orden,
                    ( rec_periodo_cuenta.rdesde * - 1 ),
                    ( rec_periodo_cuenta.rhasta * - 1 ),
                    rec_periodo_cuenta.ucreac,
                    rec_periodo_cuenta.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                -- ACTUALIZANDO TIPVEN = 1
                UPDATE periodo_cuenta
                SET
                    rdesde =
                        CASE
                            WHEN rec_periodo_cuenta.rdesde IS NULL THEN
                                rdesde
                            ELSE
                                rec_periodo_cuenta.rdesde
                        END,
                    rhasta =
                        CASE
                            WHEN rec_periodo_cuenta.rhasta IS NULL THEN
                                rhasta
                            ELSE
                                rec_periodo_cuenta.rhasta
                        END,
                    uactua =
                        CASE
                            WHEN rec_periodo_cuenta.uactua IS NULL THEN
                                ''
                            ELSE
                                rec_periodo_cuenta.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_periodo_cuenta.id_cia
                    AND tipran = rec_periodo_cuenta.tipran
                    AND tipven = 1
                    AND orden = rec_periodo_cuenta.orden;

            -- ACTUALIZANDO TIPVEN = 2
                UPDATE periodo_cuenta
                SET
                    rdesde =
                        CASE
                            WHEN rec_periodo_cuenta.rdesde IS NULL THEN
                                rdesde
                            ELSE
                                ( rec_periodo_cuenta.rdesde * - 1 )
                        END,
                    rhasta =
                        CASE
                            WHEN rec_periodo_cuenta.rhasta IS NULL THEN
                                rhasta
                            ELSE
                                ( rec_periodo_cuenta.rhasta * - 1 )
                        END,
                    uactua =
                        CASE
                            WHEN rec_periodo_cuenta.uactua IS NULL THEN
                                ''
                            ELSE
                                rec_periodo_cuenta.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_periodo_cuenta.id_cia
                    AND tipran = rec_periodo_cuenta.tipran
                    AND tipven = 1
                    AND orden = rec_periodo_cuenta.orden;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM periodo_cuenta
                WHERE
                        id_cia = rec_periodo_cuenta.id_cia
                    AND tipran = rec_periodo_cuenta.tipran
                    AND orden = rec_periodo_cuenta.orden;

        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'rdesdesage' VALUE v_accion || ' se realizó satisfactoriamente...!'
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
                    'rdesdesage' VALUE 'El registro con codigo para el Periodo [ '
                                       || rec_periodo_cuenta.tipran
                                       || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'rdesdesage' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'rdesdesage' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                NULL;
            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' codigo :'
                               || sqlcode;
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.2,
                        'rdesdesage' VALUE pin_mensaje
                    )
                INTO pin_mensaje
                FROM
                    dual;

            END IF;
    END sp_save;

END;

/
