--------------------------------------------------------
--  DDL for Package Body PACK_CLI_TIPO_ENFERMEDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CLI_TIPO_ENFERMEDAD" AS

    FUNCTION sp_obtener (
        pin_id_cia  IN  NUMBER,
        pin_id_tipo  IN  NUMBER
    ) RETURN t_cli_tipo_enfermedad
        PIPELINED
    IS
        v_table t_cli_tipo_enfermedad;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            cli_tipo_enfermedad
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_id_tipo IS NULL )
                  OR ( id_tipo = pin_id_tipo ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_nombre IN VARCHAR2
    ) RETURN t_cli_tipo_enfermedad
        PIPELINED
    IS
        v_table t_cli_tipo_enfermedad;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            cli_tipo_enfermedad
        WHERE
                id_cia = pin_id_cia
            AND ((pin_nombre IS NULL) OR (pin_nombre IS NOT NULL AND INSTR(descri,pin_nombre) >= 1));

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
        o                   json_object_t;
        rec_tipo_enfermedad  cli_tipo_enfermedad%rowtype;
        v_accion            VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_tipo_enfermedad.id_cia := pin_id_cia;
        rec_tipo_enfermedad.id_tipo := o.get_string('id_tipo');
        rec_tipo_enfermedad.descri := o.get_string('descri');
        rec_tipo_enfermedad.abrevi := o.get_string('abrevi');
        rec_tipo_enfermedad.ucreac := o.get_string('ucreac');
        rec_tipo_enfermedad.uactua := o.get_string('uactua');
        rec_tipo_enfermedad.fcreac := o.get_timestamp('fcreac');
        rec_tipo_enfermedad.factua := o.get_timestamp('factua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO cli_tipo_enfermedad (
                    id_cia,
                    id_tipo,
                    descri,
                    abrevi,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_tipo_enfermedad.id_cia,
                    rec_tipo_enfermedad.id_tipo,
                    rec_tipo_enfermedad.descri,
                    rec_tipo_enfermedad.abrevi,
                    rec_tipo_enfermedad.ucreac,
                    rec_tipo_enfermedad.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
            v_accion := 'La actualización';
                UPDATE cli_tipo_enfermedad
                SET
                    descri = CASE WHEN rec_tipo_enfermedad.descri IS NULL THEN descri ELSE rec_tipo_enfermedad.descri END,
                    abrevi = CASE WHEN rec_tipo_enfermedad.abrevi IS NULL THEN abrevi ELSE rec_tipo_enfermedad.abrevi END,
                    uactua = CASE WHEN rec_tipo_enfermedad.uactua IS NULL THEN '' ELSE rec_tipo_enfermedad.uactua END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_tipo_enfermedad.id_cia
                    AND id_tipo = rec_tipo_enfermedad.id_tipo;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM cli_tipo_enfermedad
                WHERE
                        id_cia = rec_tipo_enfermedad.id_cia
                    AND id_tipo = rec_tipo_enfermedad.id_tipo;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, '{El registro ya existe.{');
    END;

END;

/
