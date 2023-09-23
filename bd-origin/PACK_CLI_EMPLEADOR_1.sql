--------------------------------------------------------
--  DDL for Package Body PACK_CLI_EMPLEADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CLI_EMPLEADOR" AS

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_id_emp IN NUMBER
    ) RETURN t_cli_empleador
        PIPELINED
    IS
        v_table t_cli_empleador;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            cli_empleador
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_id_emp IS NULL )
                  OR ( id_emp = pin_id_emp ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_nombre IN VARCHAR2
    ) RETURN t_cli_empleador
        PIPELINED
    IS
        v_table t_cli_empleador;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            cli_empleador
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_nombre IS NULL )
                  OR ( instr(razonc, pin_nombre) >= 1 ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o             json_object_t;
        rec_empleador cli_empleador%rowtype;
        v_accion      VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_empleador.id_cia := pin_id_cia;
        rec_empleador.id_emp := o.get_number('id_emp');
        rec_empleador.razonc := o.get_string('razonc');
        rec_empleador.tident := o.get_string('tident');
        rec_empleador.dident := o.get_string('dident');
        rec_empleador.direccion := o.get_string('direccion');
        rec_empleador.telefono := o.get_string('telefono');
        rec_empleador.ucreac := o.get_timestamp('ucreac');
        rec_empleador.uactua := o.get_timestamp('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO cli_empleador (
                    id_cia,
                    id_emp,
                    razonc,
                    tident,
                    dident,
                    direccion,
                    telefono,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_empleador.id_cia,
                    rec_empleador.id_emp,
                    rec_empleador.razonc,
                    rec_empleador.tident,
                    rec_empleador.dident,
                    rec_empleador.direccion,
                    rec_empleador.telefono,
                    rec_empleador.ucreac,
                    rec_empleador.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
            v_accion := 'La actualización';
                UPDATE cli_empleador
                SET
                    razonc =
                        CASE
                            WHEN rec_empleador.razonc IS NULL THEN
                                razonc
                            ELSE
                                rec_empleador.razonc
                        END,
                    tident =
                        CASE
                            WHEN rec_empleador.tident IS NULL THEN
                                tident
                            ELSE
                                rec_empleador.tident
                        END,
                    dident =
                        CASE
                            WHEN rec_empleador.dident IS NULL THEN
                                dident
                            ELSE
                                rec_empleador.dident
                        END,
                    direccion =
                        CASE
                            WHEN rec_empleador.direccion IS NULL THEN
                                direccion
                            ELSE
                                rec_empleador.direccion
                        END,
                    telefono =
                        CASE
                            WHEN rec_empleador.telefono IS NULL THEN
                                telefono
                            ELSE
                                rec_empleador.telefono
                        END,
                    uactua =
                        CASE
                            WHEN rec_empleador.uactua IS NULL THEN
                                ''
                            ELSE
                                rec_empleador.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_empleador.id_cia
                    AND id_emp = rec_empleador.id_emp;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM cli_empleador
                WHERE
                        id_cia = rec_empleador.id_cia
                    AND id_emp = rec_empleador.id_emp;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, '{El registro ya existe.{');
    END sp_save;

END;

/
