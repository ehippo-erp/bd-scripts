--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_RELACION_HASH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_RELACION_HASH" AS

    FUNCTION sp_sel_documentos_relacion_hash (
        pin_id_cia IN NUMBER
    ) RETURN t_documentos_relacion_hash
        PIPELINED
    IS
        v_table t_documentos_relacion_hash;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            documentos_relacion_hash
        WHERE
            id_cia = pin_id_cia;

        FOR registro IN 1..v_table.count LOOP PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_documentos_relacion_hash;

    PROCEDURE sp_save_documentos_relacion_hash (
        pin_id_cia    IN    NUMBER,
        pin_datos     IN    VARCHAR2,
        pin_opcdml    INTEGER,
        pin_mensaje   OUT   VARCHAR2
    ) IS
        o                              json_object_t;
        rec_documentos_relacion_hash   documentos_relacion_hash%rowtype;
        v_accion                       VARCHAR2(50) := '';
        v_numint number;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_documentos_relacion_hash.id_cia := pin_id_cia;
        rec_documentos_relacion_hash.numint := o.get_number('numint');
        rec_documentos_relacion_hash.hash := o.get_string('hash');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN

                          DECLARE
                BEGIN
                select numint into v_numint from documentos_relacion_hash
                    where id_cia = pin_id_cia
                    and numint = rec_documentos_relacion_hash.numint;                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                    v_numint := null;
                END;


                if v_numint is null then

                         INSERT INTO documentos_relacion_hash (
                    id_cia,
                    numint,
                    hash
                ) VALUES (
                    rec_documentos_relacion_hash.id_cia,
                    rec_documentos_relacion_hash.numint,
                    rec_documentos_relacion_hash.hash
                );

                else
                    UPDATE documentos_relacion_hash
                    SET hash = rec_documentos_relacion_hash.hash
                    WHERE id_cia = rec_documentos_relacion_hash.id_cia
                    AND numint = rec_documentos_relacion_hash.numint;
                end if;


                COMMIT;
            WHEN 2 THEN
                UPDATE documentos_relacion_hash
                SET
                    hash = rec_documentos_relacion_hash.hash
                WHERE
                    id_cia = rec_documentos_relacion_hash.id_cia
                    AND numint = rec_documentos_relacion_hash.numint;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM documentos_relacion_hash
                WHERE
                    id_cia = rec_documentos_relacion_hash.id_cia
                    AND numint = rec_documentos_relacion_hash.numint;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;

END;


/
