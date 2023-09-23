--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_FORMATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_FORMATOS" AS

    FUNCTION sp_sel_documentos_formatos (
        pin_tipdoc   IN   NUMBER,
        pin_item     IN   NUMBER,
        pin_activo     IN   VARCHAR2
    ) RETURN documentoformatodatatable
        PIPELINED
    IS

        registro documentoformatodatarecord := documentoformatodatarecord(NULL, NULL, NULL, NULL);
        CURSOR cur_documentos_formatos IS
        SELECT
            a.tipdoc,
            a.item,
            a.descri,
            a.formato,
            a.activo
        FROM
            documentos_formatos a
        WHERE
            a.tipdoc = pin_tipdoc
            -- ( pin_tipdoc IS NULL )
              --    OR ( A.tipdoc = pin_tipdoc ) 
            AND ( ( pin_item IS NULL )
                  OR ( a.item = pin_item ) )
            AND ( ( pin_activo IS NULL )
                  OR ( a.activo = pin_activo ) );

    BEGIN
        FOR j IN cur_documentos_formatos LOOP
            registro.tipdoc := j.tipdoc;
            registro.item := j.item;
            registro.descri := j.descri;
            registro.formato := j.formato;
            registro.activo := j.activo;
            PIPE ROW ( registro );
        END LOOP;
    END sp_sel_documentos_formatos;

    PROCEDURE sp_save_documentos_formatos (
        pin_datos     IN    VARCHAR2,
        pin_opcdml    INTEGER,
        pin_mensaje   OUT   VARCHAR2
    ) IS
        o                         json_object_t;
        rec_documentos_formatos   documentos_formatos%rowtype;
        v_accion                  VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_documentos_formatos.tipdoc := o.get_number('tipdoc');
        rec_documentos_formatos.item := o.get_number('item');
        rec_documentos_formatos.descri := o.get_string('descri');
        rec_documentos_formatos.formato := o.get_string('formato');
        rec_documentos_formatos.activo := o.get_string('activo');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO documentos_formatos (
                    tipdoc,
                    item,
                    descri,
                    formato,
                    activo
                ) VALUES (
                    rec_documentos_formatos.tipdoc,
                    rec_documentos_formatos.item,
                    rec_documentos_formatos.descri,
                    rec_documentos_formatos.formato,
                     rec_documentos_formatos.activo
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE documentos_formatos
                SET
                    descri = rec_documentos_formatos.descri,
                    formato = rec_documentos_formatos.formato,
                    activo = rec_documentos_formatos.activo
                WHERE
                    tipdoc = rec_documentos_formatos.tipdoc
                    AND item = rec_documentos_formatos.item;

COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM documentos_formatos
                WHERE
                    tipdoc = rec_documentos_formatos.tipdoc
                    AND item = rec_documentos_formatos.item;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;

END;

/
