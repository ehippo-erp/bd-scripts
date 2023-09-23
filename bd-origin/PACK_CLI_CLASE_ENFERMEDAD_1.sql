--------------------------------------------------------
--  DDL for Package Body PACK_CLI_CLASE_ENFERMEDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CLI_CLASE_ENFERMEDAD" AS

    FUNCTION sp_obtener (
        pin_id_cia  IN  NUMBER,
        pin_id_tipo  IN  NUMBER,
        pin_clase IN NUMBER
    ) RETURN t_cli_clase_enfermedad
        PIPELINED
    IS
        v_table t_cli_clase_enfermedad;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            cli_clase_enfermedad
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_id_tipo IS NULL )
                  OR ( id_tipo = pin_id_tipo ) )
            AND ( ( pin_clase IS NULL )
                  OR ( clase = pin_clase ) );      

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_nombre IN VARCHAR2
    ) RETURN t_cli_clase_enfermedad
        PIPELINED
    IS
        v_table t_cli_clase_enfermedad;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            cli_clase_enfermedad
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
        rec_aseguradora  cli_clase_enfermedad%rowtype;
        v_accion            VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_aseguradora.id_cia := pin_id_cia;
        rec_aseguradora.id_tipo := o.get_string('id_tipo');
        rec_aseguradora.clase := o.get_string('clase');
        rec_aseguradora.descri := o.get_string('descri');
        rec_aseguradora.situac := o.get_string('situac');
        rec_aseguradora.obliga := o.get_string('obliga');
        rec_aseguradora.ucreac := o.get_string('ucreac');
        rec_aseguradora.uactua := o.get_string('uactua');
        rec_aseguradora.fcreac := o.get_timestamp('fcreac');
        rec_aseguradora.factua := o.get_timestamp('factua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO cli_clase_enfermedad (
                    id_cia,
                    id_tipo,
                    clase,
                    descri,
                    situac,
                    obliga,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_aseguradora.id_cia,
                    rec_aseguradora.id_tipo,
                    rec_aseguradora.clase,
                    rec_aseguradora.descri,
                    rec_aseguradora.situac,
                    rec_aseguradora.obliga,
                    rec_aseguradora.ucreac,
                    rec_aseguradora.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
            v_accion := 'La actualización';
                UPDATE cli_clase_enfermedad
                SET
                    descri = CASE WHEN rec_aseguradora.descri IS NULL THEN descri ELSE rec_aseguradora.descri END,
                    situac = CASE WHEN rec_aseguradora.situac IS NULL THEN situac ELSE rec_aseguradora.situac END,
                    obliga = CASE WHEN rec_aseguradora.obliga IS NULL THEN obliga ELSE rec_aseguradora.obliga END,
                    uactua = CASE WHEN rec_aseguradora.uactua IS NULL THEN '' ELSE rec_aseguradora.uactua END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_aseguradora.id_cia
                    AND id_tipo = rec_aseguradora.id_tipo
                    AND clase = rec_aseguradora.clase;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM cli_clase_enfermedad
                WHERE
                        id_cia = rec_aseguradora.id_cia
                    AND id_tipo = rec_aseguradora.id_tipo
                    AND clase = rec_aseguradora.clase;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, '{El registro ya existe.{');
    END;

END;

/
