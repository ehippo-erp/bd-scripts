--------------------------------------------------------
--  DDL for Package Body PACK_CLI_ASEGURADORA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CLI_ASEGURADORA" AS

    FUNCTION sp_obtener (
        pin_id_cia  IN  NUMBER,
        pin_id_aseg  IN  NUMBER
    ) RETURN t_cli_aseguradora
        PIPELINED
    IS
        v_table t_cli_aseguradora;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            cli_aseguradora
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_id_aseg IS NULL )
                  OR ( id_aseg = pin_id_aseg ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_nombre IN VARCHAR2
    ) RETURN t_cli_aseguradora
        PIPELINED
    IS
        v_table t_cli_aseguradora;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            cli_aseguradora c
        WHERE
                id_cia = pin_id_cia
            AND ((pin_nombre IS NULL) OR (pin_nombre IS NOT NULL AND INSTR(razonc,pin_nombre) >= 1));

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
        rec_aseguradora  cli_aseguradora%rowtype;
        v_accion            VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_aseguradora.id_cia := pin_id_cia;
        rec_aseguradora.id_aseg := o.get_string('id_aseg');
        rec_aseguradora.razonc := o.get_string('razonc');
        rec_aseguradora.tident := o.get_string('tident');
        rec_aseguradora.dident := o.get_string('dident');
        rec_aseguradora.direccion := o.get_string('direccion');
        rec_aseguradora.telefono := o.get_string('telefono');
        rec_aseguradora.poliza := o.get_string('poliza');
        rec_aseguradora.finicio := o.get_date('finicio');
        rec_aseguradora.ffinal := o.get_date('ffinal');
        rec_aseguradora.ucreac := o.get_string('ucreac');
        rec_aseguradora.uactua := o.get_string('uactua');
        rec_aseguradora.fcreac := o.get_timestamp('fcreac');
        rec_aseguradora.factua := o.get_timestamp('factua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO cli_aseguradora (
                    id_cia,
                    id_aseg,
                    razonc,
                    tident,
                    dident,
                    direccion,
                    telefono,
                    poliza,
                    finicio,
                    ffinal,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_aseguradora.id_cia,
                    rec_aseguradora.id_aseg,
                    rec_aseguradora.razonc,
                    rec_aseguradora.tident,
                    rec_aseguradora.dident,
                      rec_aseguradora.direccion,
                    rec_aseguradora.telefono,
                    rec_aseguradora.poliza,
                      rec_aseguradora.finicio,
                    rec_aseguradora.ffinal,
                    rec_aseguradora.ucreac,
                    rec_aseguradora.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
            v_accion := 'La actualización';
                UPDATE cli_aseguradora
                SET
                    razonc = CASE WHEN rec_aseguradora.razonc IS NULL THEN razonc ELSE rec_aseguradora.razonc END,
                    tident = CASE WHEN rec_aseguradora.tident IS NULL THEN tident ELSE rec_aseguradora.tident END,
                    dident = CASE WHEN rec_aseguradora.dident IS NULL THEN dident ELSE rec_aseguradora.dident END,
                    direccion = CASE WHEN rec_aseguradora.direccion IS NULL THEN direccion ELSE rec_aseguradora.direccion END,
                    telefono = CASE WHEN rec_aseguradora.telefono IS NULL THEN telefono ELSE rec_aseguradora.telefono END,
                    poliza = CASE WHEN rec_aseguradora.poliza IS NULL THEN poliza ELSE rec_aseguradora.poliza END,
                    finicio = CASE WHEN rec_aseguradora.finicio IS NULL THEN finicio ELSE rec_aseguradora.finicio END,
                    ffinal = CASE WHEN rec_aseguradora.ffinal IS NULL THEN ffinal ELSE rec_aseguradora.ffinal END,
                    uactua = CASE WHEN rec_aseguradora.uactua IS NULL THEN '' ELSE rec_aseguradora.uactua END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_aseguradora.id_cia
                    AND id_aseg = rec_aseguradora.id_aseg;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM cli_aseguradora
                WHERE
                        id_cia = rec_aseguradora.id_cia
                    AND id_aseg = rec_aseguradora.id_aseg;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, '{El registro ya existe.{');
    END;

END;

/
