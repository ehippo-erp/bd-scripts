--------------------------------------------------------
--  DDL for Package Body PACK_CLI_MEDICO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CLI_MEDICO" AS

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_id_med IN NUMBER
    ) RETURN t_cli_medico
        PIPELINED
    IS
        v_table t_cli_medico;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            cli_medico
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_id_med IS NULL )
                  OR ( id_med = pin_id_med ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_obtener;


    FUNCTION sp_buscar (
        pin_id_cia  IN  NUMBER,
        pin_nombre  IN  VARCHAR2
    ) RETURN t_cli_medico
        PIPELINED
    IS
        v_table t_cli_medico;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            cli_medico
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_nombre IS NULL )
                  OR (
                  INSTR(nombres || ' ' ||apepat || ' ' || apemat,pin_nombre) >= 1 OR
                  INSTR(apepat || ' ' || nombres || ' ' || apemat,pin_nombre) >= 1 OR
                  INSTR(apemat || ' ' || apepat || ' ' || nombres,pin_nombre) >= 1 OR
                  INSTR(nombres || ' ' || apemat || ' ' || apepat,pin_nombre) >= 1 OR
                  INSTR(apepat || ' ' || apemat || ' ' || nombres,pin_nombre) >= 1 OR
                  INSTR(apemat || ' ' || nombres || ' ' || apepat,pin_nombre) >= 1
                  ));

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
        rec_medico  cli_medico%rowtype;
        v_accion            VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_medico.id_cia := pin_id_cia;
        rec_medico.id_med := o.get_number('id_med');
        rec_medico.apepat := o.get_string('apepat');
        rec_medico.apemat := o.get_string('apemat');
        rec_medico.nombres := o.get_string('nombres');
        rec_medico.fnacimi := o.get_date('fnacimi');
        rec_medico.sexo := o.get_string('sexo');
        rec_medico.codeci := o.get_number('codeci');
        rec_medico.tident := o.get_string('tident');
        rec_medico.dident := o.get_string('dident');
        rec_medico.direccion := o.get_string('direccion');
        rec_medico.telefono := o.get_string('telefono');
        rec_medico.email := o.get_string('email');
        rec_medico.codesp := o.get_string('codesp');
        rec_medico.ucreac := o.get_string('ucreac');
        rec_medico.uactua := o.get_string('uactua');
        rec_medico.fcreac := o.get_Timestamp('fcreac');
        rec_medico.factua := o.get_Timestamp('factua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO cli_medico (
                    id_cia,
                    id_med,
                    apepat,
                    apemat,
                    nombres,
                    fnacimi,
                    sexo,
                    codeci,
                    tident,
                    dident,
                    direccion,
                    telefono,
                    email,
                    codesp,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_medico.id_cia,
                    rec_medico.id_med,
                    rec_medico.apepat,
                    rec_medico.apemat,
                    rec_medico.nombres,
                    rec_medico.fnacimi,
                    rec_medico.sexo,
                    rec_medico.codeci,
                    rec_medico.tident,
                    rec_medico.dident,
                    rec_medico.direccion,
                    rec_medico.telefono,
                    rec_medico.email,
                    rec_medico.codesp,
                    rec_medico.ucreac,
                    rec_medico.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
            v_accion := 'La actualización';
                UPDATE cli_medico
                SET
                    apepat = CASE WHEN rec_medico.apepat IS NULL THEN apepat ELSE rec_medico.apepat END,
                    apemat = CASE WHEN rec_medico.apemat IS NULL THEN apemat ELSE rec_medico.apemat END,
                    nombres = CASE WHEN rec_medico.nombres IS NULL THEN nombres ELSE rec_medico.nombres END,
                    fnacimi = CASE WHEN rec_medico.fnacimi IS NULL THEN fnacimi ELSE rec_medico.fnacimi END,
                    sexo = CASE WHEN rec_medico.sexo IS NULL THEN sexo ELSE rec_medico.sexo END,
                    codeci = CASE WHEN rec_medico.codeci IS NULL THEN codeci ELSE rec_medico.codeci END,
                    tident = CASE WHEN rec_medico.tident IS NULL THEN tident ELSE rec_medico.tident END,
                    dident = CASE WHEN rec_medico.dident IS NULL THEN dident ELSE rec_medico.dident END,
                    direccion = CASE WHEN rec_medico.direccion IS NULL THEN direccion ELSE rec_medico.direccion END,
                    telefono = CASE WHEN rec_medico.telefono IS NULL THEN telefono ELSE rec_medico.telefono END,
                    email = CASE WHEN rec_medico.email IS NULL THEN email ELSE rec_medico.email END,
                    codesp = CASE WHEN rec_medico.codesp IS NULL THEN codesp ELSE rec_medico.codesp END,
                    uactua = CASE WHEN rec_medico.uactua IS NULL THEN '' ELSE rec_medico.uactua END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_medico.id_cia
                    AND id_med = rec_medico.id_med;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM cli_medico
                WHERE
                        id_cia = rec_medico.id_cia
                    AND id_med = rec_medico.id_med;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, '{El registro ya existe.{');
    END;

END;

/
