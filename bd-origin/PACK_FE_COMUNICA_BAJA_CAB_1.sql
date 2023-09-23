--------------------------------------------------------
--  DDL for Package Body PACK_FE_COMUNICA_BAJA_CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_FE_COMUNICA_BAJA_CAB" AS

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_idbaj  IN NUMBER
    ) RETURN t_fe_comunica_baja_cab
        PIPELINED
    IS
        v_table t_fe_comunica_baja_cab;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            fe_comunica_baja_cab
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_idbaj IS NULL )
                  OR ( idbaj = pin_idbaj ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia    IN NUMBER,
        pin_estado    IN VARCHAR2,
        pin_tipo      IN NUMBER,
        pin_fgdesde   IN DATE,
        pin_fghasta   IN DATE,
        pin_fedesde   IN DATE,
        pin_fehasta   IN DATE,
        pin_fgentodos IN VARCHAR2,
        pin_femitodos IN VARCHAR2
    ) RETURN t_fe_comunica_baja_cab
        PIPELINED
    IS
        v_table fe_comunica_baja_cab%rowtype;
    BEGIN

        FOR registro IN (SELECT
            id_cia, idbaj, tipo, fgenera, femisi, estado, ticket  FROM
            fe_comunica_baja_cab
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_estado IS NULL )
                  OR ( estado IN (SELECT * FROM TABLE ( convert_in(pin_estado))) )
            AND ( ( pin_tipo IS NULL ) OR (tipo = pin_tipo))
            AND ((pin_fgentodos = 'S')OR ((pin_fgentodos = 'N')AND(fgenera BETWEEN pin_fgdesde AND pin_fghasta)))
            AND ((pin_femitodos = 'S')OR ((pin_femitodos = 'N')AND(femisi BETWEEN pin_fedesde AND pin_fehasta))))) LOOP
            v_table.id_cia := registro.id_cia;
            v_table.idbaj := registro.idbaj;
            v_table.tipo := registro.tipo;
            v_table.fgenera := registro.fgenera;
            v_table.femisi := registro.femisi;
            v_table.estado := registro.estado;
            v_table.ticket := registro.ticket;
            PIPE ROW ( v_table ); 
        END LOOP;

        RETURN ;
    END sp_buscar;

    PROCEDURE sp_save(
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                           json_object_t;
        rec_fe_comunica_baja_cab    fe_comunica_baja_cab%rowtype;
        v_accion                    VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_fe_comunica_baja_cab.id_cia := pin_id_cia;
        rec_fe_comunica_baja_cab.idbaj := o.get_number('idbaj');
        rec_fe_comunica_baja_cab.tipo := o.get_number('tipo');
        rec_fe_comunica_baja_cab.fgenera := o.get_date('fgenera');
        rec_fe_comunica_baja_cab.femisi := o.get_date('femisi');
        rec_fe_comunica_baja_cab.estado := o.get_string('estado');
        rec_fe_comunica_baja_cab.ticket_old := o.get_blob('ticket_old');
        rec_fe_comunica_baja_cab.xml := o.get_blob('xml');
        rec_fe_comunica_baja_cab.cdr := o.get_blob('cdr');
        rec_fe_comunica_baja_cab.ticketbck := o.get_string('ticketbck');
        rec_fe_comunica_baja_cab.ticket := o.get_string('ticket');
    v_accion := 'La grabación';
    CASE pin_opcdml
        WHEN 1 THEN
            INSERT INTO fe_comunica_baja_cab (
                id_cia,
                idbaj,
                tipo,
                fgenera,
                femisi,
                estado,
                ticket_old,
                xml,
                cdr,
                ticketbck,
                ticket
            ) VALUES (
                rec_fe_comunica_baja_cab.id_cia,
                rec_fe_comunica_baja_cab.idbaj,
                rec_fe_comunica_baja_cab.tipo,
                rec_fe_comunica_baja_cab.fgenera,
                rec_fe_comunica_baja_cab.femisi,
                rec_fe_comunica_baja_cab.estado,
                rec_fe_comunica_baja_cab.ticket_old,
                rec_fe_comunica_baja_cab.xml,
                rec_fe_comunica_baja_cab.cdr,
                rec_fe_comunica_baja_cab.ticketbck,
                rec_fe_comunica_baja_cab.ticket
            );

            COMMIT;
        WHEN 2 THEN
            v_accion := 'La actualización';
            UPDATE fe_comunica_baja_cab
            SET
                estado = CASE WHEN rec_fe_comunica_baja_cab.estado IS NOT NULL THEN rec_fe_comunica_baja_cab.estado ELSE estado END,
                tipo = CASE WHEN rec_fe_comunica_baja_cab.tipo IS NOT NULL THEN rec_fe_comunica_baja_cab.tipo ELSE tipo END
            WHERE
                    id_cia = rec_fe_comunica_baja_cab.id_cia
                AND idbaj = rec_fe_comunica_baja_cab.idbaj;
            COMMIT;
    WHEN 3 THEN
        v_accion := 'La eliminación';
        DELETE FROM fe_comunica_baja_cab
        WHERE
                id_cia = rec_fe_comunica_baja_cab.id_cia
            AND idbaj = rec_fe_comunica_baja_cab.idbaj;

        COMMIT;
END CASE;

    pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, '{El registro ya existe.{');
            end;
END;

/
