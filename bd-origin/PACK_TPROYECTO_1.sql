--------------------------------------------------------
--  DDL for Package Body PACK_TPROYECTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_TPROYECTO" AS

    FUNCTION sp_sel_tproyecto (
        pin_id_cia IN NUMBER
    ) RETURN t_tproyecto
        PIPELINED
    IS
        v_table t_tproyecto;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            tproyecto
        WHERE
            id_cia = pin_id_cia;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_tproyecto;

    PROCEDURE sp_save_tproyecto (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o              json_object_t;
        rec_tproyecto  tproyecto%rowtype;
        v_accion       VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_tproyecto.id_cia := pin_id_cia;
        rec_tproyecto.codigo := o.get_string('codigo');
        rec_tproyecto.secuencia := o.get_number('secuencia');
        rec_tproyecto.finicio := o.get_date('finicio');
        rec_tproyecto.ffin := o.get_date('ffin');
        rec_tproyecto.descri := o.get_string('descri');
        rec_tproyecto.presup01 := o.get_number('presup01');
        rec_tproyecto.presup02 := o.get_number('presup02');
        rec_tproyecto.situac := o.get_string('situac');
        rec_tproyecto.usuari := o.get_string('usuari');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO tproyecto (
                    id_cia,
                    codigo,
                    secuencia,
                    finicio,
                    ffin,
                    descri,
                    presup01,
                    presup02,
                    situac,
                    usuari
                ) VALUES (
                    rec_tproyecto.id_cia,
                    rec_tproyecto.codigo,
                    rec_tproyecto.secuencia,
                    rec_tproyecto.finicio,
                    rec_tproyecto.ffin,
                    rec_tproyecto.descri,
                    rec_tproyecto.presup01,
                    rec_tproyecto.presup02,
                    rec_tproyecto.situac,
                    rec_tproyecto.usuari
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE tproyecto
                SET
                    secuencia = rec_tproyecto.secuencia,
                    finicio = rec_tproyecto.finicio,
                    ffin = rec_tproyecto.ffin,
                    descri = rec_tproyecto.descri,
                    presup01 = rec_tproyecto.presup01,
                    presup02 = rec_tproyecto.presup02,
                    situac = rec_tproyecto.situac,
                    usuari = rec_tproyecto.usuari
                WHERE
                        id_cia = rec_tproyecto.id_cia
                    AND codigo = rec_tproyecto.codigo;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM tproyecto
                WHERE
                        id_cia = rec_tproyecto.id_cia
                    AND codigo = rec_tproyecto.codigo;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;

END;

/
