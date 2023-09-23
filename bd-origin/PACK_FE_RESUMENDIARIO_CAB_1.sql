--------------------------------------------------------
--  DDL for Package Body PACK_FE_RESUMENDIARIO_CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_FE_RESUMENDIARIO_CAB" AS

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_idres  IN NUMBER
    ) RETURN t_fe_resumendiario_cab
        PIPELINED
    IS
        v_table t_fe_resumendiario_cab;
    BEGIN
        SELECT
            id_cia,
            idres,
            tipo,
            NULL,
            fgenera,
            femisi,
            tipmon,
            estado,
            CASE
                WHEN estado = 'A'    THEN
                    'Emitido'
                WHEN estado = 'F'    THEN
                    'Aceptado'
                WHEN estado = 'J'    THEN
                    'Observado'
                WHEN estado = 'R'    THEN
                    'Rechazado'
                WHEN estado = 'B' THEN
                    'Baja'
                ELSE
                    'ND'
            END AS desest,
            ticket_old,
            xml,
            cdr,
            ticketbck,
            ticket
        BULK COLLECT
        INTO v_table
        FROM
            fe_resumendiario_cab
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_idres IS NULL )
                  OR ( idres = pin_idres ) );

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
    ) RETURN t_fe_resumendiario_cab
        PIPELINED
    IS
        v_table t_fe_resumendiario_cab;
    BEGIN
        SELECT
            id_cia,
            idres,
            tipo,
            NULL,
            fgenera,
            femisi,
            tipmon,
            estado,
                        CASE
                WHEN estado = 'A'    THEN
                    'Emitido'
                WHEN estado = 'F'    THEN
                    'Aceptado'
                WHEN estado = 'J'    THEN
                    'Observado'
                WHEN estado = 'R'    THEN
                    'Rechazado'
                WHEN estado = 'B' THEN
                    'Baja'
                ELSE
                    'ND'
            END AS desest,
            NULL,
            NULL,
            NULL,
            ticketbck,
            ticket
        BULK COLLECT
        INTO v_table
        FROM
            fe_resumendiario_cab
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_estado IS NULL )
                  OR ( estado IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_estado) )
            ) )
                  AND ( ( pin_tipo IS NULL )
                        OR ( tipo = pin_tipo ) )
                  AND ( ( pin_fgentodos = 'S' )
                        OR ( ( pin_fgentodos = 'N' )
                             AND ( trunc(fgenera) BETWEEN pin_fgdesde AND pin_fghasta ) ) )
                  AND ( ( pin_femitodos = 'S' )
                        OR ( ( pin_femitodos = 'N' )
                             AND ( trunc(femisi) BETWEEN pin_fedesde AND pin_fehasta ) ) ) );

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
        o                        json_object_t;
        rec_fe_resumendiario_cab fe_resumendiario_cab%rowtype;
        v_accion                 VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_fe_resumendiario_cab.id_cia := pin_id_cia;
        rec_fe_resumendiario_cab.idres := o.get_number('idres');
        rec_fe_resumendiario_cab.tipo := o.get_number('tipo');
        rec_fe_resumendiario_cab.fgenera := o.get_date('fgenera');
        rec_fe_resumendiario_cab.femisi := o.get_date('femisi');
        rec_fe_resumendiario_cab.tipmon := o.get_string('tipmon');
        rec_fe_resumendiario_cab.estado := o.get_string('estado');
        rec_fe_resumendiario_cab.ticket_old := o.get_blob('ticket_old');
        rec_fe_resumendiario_cab.xml := o.get_blob('xml');
        rec_fe_resumendiario_cab.cdr := o.get_blob('cdr');
        rec_fe_resumendiario_cab.ticketbck := o.get_string('ticketbck');
        rec_fe_resumendiario_cab.ticket := o.get_string('ticket');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO fe_resumendiario_cab (
                    id_cia,
                    idres,
                    tipo,
                    fgenera,
                    femisi,
                    tipmon,
                    estado,
                    ticket_old,
                    xml,
                    cdr,
                    ticketbck,
                    ticket
                ) VALUES (
                    rec_fe_resumendiario_cab.id_cia,
                    rec_fe_resumendiario_cab.idres,
                    rec_fe_resumendiario_cab.tipo,
                    rec_fe_resumendiario_cab.fgenera,
                    rec_fe_resumendiario_cab.femisi,
                    rec_fe_resumendiario_cab.tipmon,
                    rec_fe_resumendiario_cab.estado,
                    rec_fe_resumendiario_cab.ticket_old,
                    rec_fe_resumendiario_cab.xml,
                    rec_fe_resumendiario_cab.cdr,
                    rec_fe_resumendiario_cab.ticketbck,
                    rec_fe_resumendiario_cab.ticket
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE fe_resumendiario_cab
                SET
                    estado =
                        CASE
                            WHEN rec_fe_resumendiario_cab.estado IS NOT NULL THEN
                                rec_fe_resumendiario_cab.estado
                            ELSE
                                estado
                        END,
                    tipo =
                        CASE
                            WHEN rec_fe_resumendiario_cab.tipo IS NOT NULL THEN
                                rec_fe_resumendiario_cab.tipo
                            ELSE
                                tipo
                        END,
                    tipmon =
                        CASE
                            WHEN rec_fe_resumendiario_cab.tipmon IS NOT NULL THEN
                                rec_fe_resumendiario_cab.tipmon
                            ELSE
                                tipmon
                        END
                WHERE
                        id_cia = rec_fe_resumendiario_cab.id_cia
                    AND idres = rec_fe_resumendiario_cab.idres;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM fe_resumendiario_cab
                WHERE
                        id_cia = rec_fe_resumendiario_cab.id_cia
                    AND idres = rec_fe_resumendiario_cab.idres;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, '{El registro ya existe.{');
    END;
------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------

    FUNCTION sp_documentos_pendientes (
        pin_id_cia    NUMBER,
        pin_femisi    DATE,
        pin_cadestado NUMBER,
        pin_tipdoc    NUMBER
    ) RETURN datatable_documentos_pendientes
        PIPELINED
    AS
        rec datarecord_documentos_pendientes;
    BEGIN
        IF pin_cadestado = 0 THEN
            FOR i IN (
                SELECT
                    cab.numint,
                    dt.descri AS desdoc,
                    cab.situac,
                    cab.tipdoc,
                    cab.codsuc,
                    cab.femisi,
                    cab.codcli,
                    cab.razonc,
                    cab.series,
                    cab.numdoc,
                    cab.monafe,
                    cab.monina,
                    cab.monigv,
                    cab.acuenta,
                    cab.tipmon,
                    cab.preven,
                    CASE
                        WHEN s.ctxt = 0 THEN
                            'No Generado'
                        ELSE
                            'Generado'
                    END       AS gentxt,
                    s.estado
                FROM
                         documentos_cab cab
                    INNER JOIN documentos_cab_envio_sunat s ON cab.id_cia = s.id_cia
                                                               AND cab.numint = s.numint
                    INNER JOIN estado_envio_sunat         es ON s.id_cia = es.id_cia
                                                        AND s.estado = es.codest
                    INNER JOIN documentos                 cc ON cc.codigo = cab.tipdoc
                                                AND cc.id_cia = cab.id_cia
                                                AND cc.series = cab.series
                    LEFT OUTER JOIN documentos_tipo            dt ON dt.id_cia = cab.id_cia
                                                          AND dt.tipdoc = cab.tipdoc
                WHERE
                        cab.id_cia = pin_id_cia
                    AND cc.docelec = 'S'
                    AND cab.femisi = pin_femisi
                    AND cab.tipdoc = pin_tipdoc
                    AND cab.tipdoc = 3
                    AND cab.numdoc > 0
                    AND ( ( cab.situac = 'F'
                            AND ( s.estado = 0
                                  OR s.estado = 2 )
                            AND s.cres = 0 )
                          OR ( cab.situac = 'J'
                               AND s.estado = 1
                               AND s.cres = 0 ) )
                UNION
                SELECT
                    cab.numint,
                    dt.descri AS desdoc,
                    cab.situac,
                    cab.tipdoc,
                    cab.codsuc,
                    cab.femisi,
                    cab.codcli,
                    cab.razonc,
                    cab.series,
                    cab.numdoc,
                    cab.monafe,
                    cab.monina,
                    cab.monigv,
                    cab.acuenta,
                    cab.tipmon,
                    cab.preven,
                    CASE
                        WHEN s.ctxt = 0 THEN
                            'No Generado'
                        ELSE
                            'Generado'
                    END       AS gentxt,
                    s.estado
                FROM
                         documentos_cab cab
                    INNER JOIN documentos_cab_envio_sunat s ON cab.id_cia = s.id_cia
                                                               AND cab.numint = s.numint
                    INNER JOIN documentos_cab_referencia  r ON r.id_cia = cab.id_cia
                                                              AND r.numint = cab.numint
                                                              AND r.tipdoc = 3
                    INNER JOIN estado_envio_sunat         es ON s.id_cia = es.id_cia
                                                        AND s.estado = es.codest
                    INNER JOIN documentos                 cc ON cc.codigo = cab.tipdoc
                                                AND cc.id_cia = cab.id_cia
                                                AND cc.series = cab.series
                    LEFT OUTER JOIN documentos_tipo            dt ON dt.id_cia = cab.id_cia
                                                          AND dt.tipdoc = cab.tipdoc
                WHERE
                        cab.id_cia = pin_id_cia
                    AND cc.docelec = 'S'
                    AND cab.femisi = pin_femisi
                    AND cab.tipdoc = pin_tipdoc
                    AND cab.tipdoc IN ( 7, 8 )
                    AND cab.numdoc > 0
                    AND ( ( cab.situac = 'F'
                            AND ( s.estado = 0
                                  OR s.estado = 2 )
                            AND s.cres = 0 )
                          OR ( cab.situac = 'J'
                               AND s.estado = 1
                               AND s.cres <= 2 ) )
                OFFSET 0 ROWS FETCH NEXT 500 ROWS ONLY
            ) LOOP
                rec.numint := i.numint;
                rec.desdoc := i.desdoc;
                rec.situac := i.situac;
                rec.tipdoc := i.tipdoc;
                rec.codsuc := i.codsuc;
                rec.femisi := i.femisi;
                rec.codcli := i.codcli;
                rec.razonc := i.razonc;
                rec.series := i.series;
                rec.numdoc := i.numdoc;
                rec.monafe := i.monafe;
                rec.monina := i.monina;
                rec.monigv := i.monigv;
                rec.acuenta := i.acuenta;
                rec.tipmon := i.tipmon;
                rec.preven := i.preven;
                rec.gentxt := i.gentxt;
                rec.estado := i.estado;
                PIPE ROW ( rec );
            END LOOP;
------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
        ELSIF pin_cadestado > 0 THEN
            FOR i IN (
                SELECT
                    cab.numint,
                    dt.descri AS desdoc,
                    cab.situac,
                    cab.tipdoc,
                    cab.codsuc,
                    cab.femisi,
                    cab.codcli,
                    cab.razonc,
                    cab.series,
                    cab.numdoc,
                    cab.monafe,
                    cab.monina,
                    cab.monigv,
                    cab.acuenta,
                    cab.tipmon,
                    cab.preven,
                    CASE
                        WHEN s.ctxt = 0 THEN
                            'No Generado'
                        ELSE
                            'Generado'
                    END       AS gentxt,
                    s.estado
                FROM
                         documentos_cab cab
                    INNER JOIN documentos_cab_envio_sunat s ON cab.id_cia = s.id_cia
                                                               AND cab.numint = s.numint
                    INNER JOIN estado_envio_sunat         es ON s.id_cia = es.id_cia
                                                        AND s.estado = es.codest
                    INNER JOIN documentos                 cc ON cc.codigo = cab.tipdoc
                                                AND cc.id_cia = cab.id_cia
                                                AND cc.series = cab.series
                    LEFT OUTER JOIN documentos_tipo            dt ON dt.id_cia = cab.id_cia
                                                          AND dt.tipdoc = cab.tipdoc
                WHERE
                        cab.id_cia = pin_id_cia
                    AND cc.docelec = 'S'
                    AND cab.femisi = pin_femisi
                    AND cab.tipdoc = 3
                    AND cab.tipdoc = pin_tipdoc
                    AND cab.numdoc > 0
                    AND ( ( cab.situac = 'F'
                            AND ( s.estado = 0
                                  OR s.estado = 2 )
                            AND s.cres >= 1 )
                          OR ( cab.situac = 'J'
                               AND s.estado = 1
                               AND s.cres >= 1 ) )
                UNION
                SELECT
                    cab.numint,
                    dt.descri AS desdoc,
                    cab.situac,
                    cab.tipdoc,
                    cab.codsuc,
                    cab.femisi,
                    cab.codcli,
                    cab.razonc,
                    cab.series,
                    cab.numdoc,
                    cab.monafe,
                    cab.monina,
                    cab.monigv,
                    cab.acuenta,
                    cab.tipmon,
                    cab.preven,
                    CASE
                        WHEN s.ctxt = 0 THEN
                            'No Generado'
                        ELSE
                            'Generado'
                    END       AS gentxt,
                    s.estado
                FROM
                         documentos_cab cab
                    INNER JOIN documentos_cab_envio_sunat s ON cab.id_cia = s.id_cia
                                                               AND cab.numint = s.numint
                    INNER JOIN documentos_cab_referencia  r ON r.id_cia = cab.id_cia
                                                              AND r.numint = cab.numint
                                                              AND r.tipdoc = 3
                    INNER JOIN estado_envio_sunat         es ON s.id_cia = es.id_cia
                                                        AND s.estado = es.codest
                    INNER JOIN documentos                 cc ON cc.codigo = cab.tipdoc
                                                AND cc.id_cia = cab.id_cia
                                                AND cc.series = cab.series
                    LEFT OUTER JOIN documentos_tipo            dt ON dt.id_cia = cab.id_cia
                                                          AND dt.tipdoc = cab.tipdoc
                WHERE
                        cab.id_cia = pin_id_cia
                    AND cc.docelec = 'S'
                    AND cab.femisi = pin_femisi
                    AND cab.tipdoc IN ( 7, 8 )
                    AND cab.tipdoc = pin_tipdoc
                    AND cab.numdoc > 0
                    AND ( ( cab.situac = 'F'
                            AND ( s.estado = 0
                                  OR s.estado = 2 )
                            AND s.cres >= 1 )
                          OR ( cab.situac = 'J'
                               AND s.estado = 1
                               AND s.cres <= 2 ) )
                OFFSET 0 ROWS FETCH NEXT 500 ROWS ONLY
            ) LOOP
                rec.numint := i.numint;
                rec.desdoc := i.desdoc;
                rec.situac := i.situac;
                rec.tipdoc := i.tipdoc;
                rec.codsuc := i.codsuc;
                rec.femisi := i.femisi;
                rec.codcli := i.codcli;
                rec.razonc := i.razonc;
                rec.series := i.series;
                rec.numdoc := i.numdoc;
                rec.monafe := i.monafe;
                rec.monina := i.monina;
                rec.monigv := i.monigv;
                rec.acuenta := i.acuenta;
                rec.tipmon := i.tipmon;
                rec.preven := i.preven;
                rec.gentxt := i.gentxt;
                rec.estado := i.estado;
                PIPE ROW ( rec );
            END LOOP;
        END IF;
    END sp_documentos_pendientes;

END;

/
