--------------------------------------------------------
--  DDL for Package Body PACK_PERSONAL_CONTRATOS_ADJUNTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_PERSONAL_CONTRATOS_ADJUNTO" AS

    FUNCTION sp_sel_personal_contratos_adjunto (
        pin_id_cia  IN  NUMBER,
        pin_codper  IN  VARCHAR2,
        pin_nrocon  IN  SMALLINT,
        pin_item    IN  SMALLINT
    ) RETURN t_personal_contratos_adjunto
        PIPELINED
    IS
        v_table t_personal_contratos_adjunto;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            personal_contratos_adjunto
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_codper IS NULL )
                  OR ( codper = pin_codper ) )
            AND ( ( pin_nrocon IS NULL )
                  OR ( nrocon = pin_nrocon ) )
            AND ( ( pin_item IS NULL )
                  OR ( item = pin_item ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_personal_contratos_adjunto;

    PROCEDURE sp_save_personal_contratos_adjunto (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o                                json_object_t;
        rec_personal_contratos_adjuntos  personal_contratos_adjunto%rowtype;
        v_accion                         VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal_contratos_adjuntos.id_cia := pin_id_cia;
        rec_personal_contratos_adjuntos.codper := o.get_string('codper');
        rec_personal_contratos_adjuntos.nrocon := o.get_number('nrocon');
        rec_personal_contratos_adjuntos.item := o.get_number('item');
        rec_personal_contratos_adjuntos.formato := o.get_string('formato');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO personal_contratos_adjunto (
                    id_cia,
                    codper,
                    nrocon,
                    item,
                    formato
                ) VALUES (
                    rec_personal_contratos_adjuntos.id_cia,
                    rec_personal_contratos_adjuntos.codper,
                    rec_personal_contratos_adjuntos.nrocon,
                    rec_personal_contratos_adjuntos.item,
                    rec_personal_contratos_adjuntos.formato
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE personal_contratos_adjunto
                SET
                    formato = rec_personal_contratos_adjuntos.formato
                WHERE
                        id_cia = rec_personal_contratos_adjuntos.id_cia
                    AND codper = rec_personal_contratos_adjuntos.codper
                    AND item = rec_personal_contratos_adjuntos.item;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM personal_contratos_adjunto
                WHERE
                        id_cia = rec_personal_contratos_adjuntos.id_cia
                    AND codper = rec_personal_contratos_adjuntos.codper
                    AND item = rec_personal_contratos_adjuntos.item;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            pin_mensaje := 'El código : ['
                           || rec_personal_contratos_adjuntos.item
                           || '] ya existe.';
        WHEN OTHERS THEN
            IF sqlcode = -2292 THEN
                pin_mensaje := 'No es posible eliminar el codigo de factor ['
                               || rec_personal_contratos_adjuntos.item
                               || '] por restricción de integridad';
            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' codigo :'
                               || sqlcode;
            END IF;
    END;

END;

/
