--------------------------------------------------------
--  DDL for Package Body PACK_CONCEPTOS_PDT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CONCEPTOS_PDT" AS

    FUNCTION sp_buscar (
        pin_id_cia  IN  NUMBER,
        pin_codpdt  IN  NUMBER,
        pin_descri  IN  VARCHAR2
    ) RETURN t_conceptos_pdt
        PIPELINED
    IS
        v_table t_conceptos_pdt;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            conceptos_pdt
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_codpdt IS NULL )
                  OR ( codpdt = pin_codpdt ) )
            AND ( ( pin_descri IS NULL )
                  OR ( descri = pin_descri ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_buscar;

    PROCEDURE sp_save (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o                  json_object_t;
        rec_conceptos_pdt  conceptos_pdt%rowtype;
        v_accion           VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_conceptos_pdt.id_cia := pin_id_cia;
        rec_conceptos_pdt.codpdt := o.get_string('codpdt');
        rec_conceptos_pdt.descri := o.get_string('descri');
        rec_conceptos_pdt.ucreac := o.get_string('ucreac');
        rec_conceptos_pdt.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO conceptos_pdt (
                    id_cia,
                    codpdt,
                    descri,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_conceptos_pdt.id_cia,
                    rec_conceptos_pdt.codpdt,
                    rec_conceptos_pdt.descri,
                    rec_conceptos_pdt.ucreac,
                    rec_conceptos_pdt.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE conceptos_pdt
                SET
                    descri = rec_conceptos_pdt.descri,
                    uactua = rec_conceptos_pdt.uactua,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_conceptos_pdt.id_cia
                    AND codpdt = rec_conceptos_pdt.codpdt;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM conceptos_pdt
                WHERE
                        id_cia = rec_conceptos_pdt.id_cia
                    AND codpdt = rec_conceptos_pdt.codpdt;

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
                    'message' VALUE 'El registro con codigo concepto pdt [ '
                                    || rec_conceptos_pdt.codpdt
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

END;

/
