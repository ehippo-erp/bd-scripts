--------------------------------------------------------
--  DDL for Package Body PACK_COMPR040
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_COMPR040" AS

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_tipo   IN NUMBER,
        pin_docume IN NUMBER
    ) RETURN datatable_compr040
        PIPELINED
    AS
        v_table datatable_compr040;
    BEGIN
        SELECT
            c.*,
            cli.razonc AS personal,
            tl.descri  AS librodesc,
            tc.descri  AS ccostodesc,
            pc.nombre  AS ctapagodesc,
            m.descri AS tippagodesc,
            us.nombres AS descaprob
        BULK COLLECT
        INTO v_table
        FROM
            compr040 c
            LEFT OUTER JOIN cliente  cli ON cli.id_cia = c.id_cia
                                           AND cli.codcli = c.codper
            LEFT OUTER JOIN tlibro   tl ON tl.id_cia = c.id_cia
                                         AND tl.codlib = c.libro
            LEFT OUTER JOIN tccostos tc ON tc.id_cia = c.id_cia
                                           AND tc.codigo = c.ccosto
            LEFT OUTER JOIN pcuentas pc ON pc.id_cia = c.id_cia
                                           AND pc.cuenta = c.ctapago
            LEFT OUTER JOIN m_pago m ON m.id_cia = c.id_cia
                                            AND m.codigo = c.tippago
            LEFT OUTER JOIN usuarios us ON us.id_cia = c.id_cia
                                            AND us.coduser = c.caprob
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipo = pin_tipo
            AND c.docume = pin_docume
        ORDER BY
            femisi DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia  IN NUMBER,
        pin_tipo    IN NUMBER,
        pin_docume  IN NUMBER,
        pin_fdesde  IN DATE,
        pin_fhasta  IN DATE,
        pin_codper  IN VARCHAR2,
        pin_moneda  IN VARCHAR2,
        pin_codarea IN NUMBER,
        pin_limit   IN NUMBER,
        pin_offset  IN NUMBER
    ) RETURN datatable_compr040
        PIPELINED
    AS
        v_table datatable_compr040;
        x       NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO x
        FROM
            compr040;

        SELECT
            c.*,
            cli.razonc AS personal,
            tl.descri  AS librodesc,
            tc.descri  AS ccostodesc,
            pc.nombre  AS ctapagodesc,
            m.descri AS tippagodesc,
            us.nombres AS nomuser
        BULK COLLECT
        INTO v_table
        FROM
            compr040 c
            LEFT OUTER JOIN cliente  cli ON cli.id_cia = c.id_cia
                                           AND cli.codcli = c.codper
            LEFT OUTER JOIN tlibro   tl ON tl.id_cia = c.id_cia
                                         AND tl.codlib = c.libro
            LEFT OUTER JOIN tccostos tc ON tc.id_cia = c.id_cia
                                           AND tc.codigo = c.ccosto
            LEFT OUTER JOIN pcuentas pc ON pc.id_cia = c.id_cia
                                           AND pc.cuenta = c.ctapago
            LEFT OUTER JOIN m_pago m ON m.id_cia = c.id_cia
                                            AND m.codigo = c.tippago
            LEFT OUTER JOIN usuarios us ON us.id_cia = c.id_cia
                                            AND us.coduser = c.caprob
        WHERE
                c.id_cia = pin_id_cia
            AND ( ( pin_tipo = - 1
                    OR pin_tipo IS NULL )
                  OR ( c.tipo = pin_tipo ) )
            AND ( ( pin_docume = - 1
                    OR pin_docume IS NULL )
                  OR ( c.docume = pin_docume ) )
            AND ( c.femisi BETWEEN pin_fdesde AND pin_fhasta )
            AND ( ( pin_codper IS NULL )
                  OR ( c.codper = pin_codper ) )
            AND ( ( pin_moneda IS NULL )
                  OR ( c.moneda = pin_moneda ) )
            AND ( ( pin_codarea = - 1
                    OR pin_codarea IS NULL )
                  OR ( c.codarea = pin_codarea ) )
        ORDER BY
            femisi DESC
        OFFSET
            CASE
                WHEN pin_offset = - 1 THEN
                    0
                ELSE
                    pin_offset
            END
        ROWS FETCH NEXT
            CASE
                WHEN pin_limit = - 1 THEN
                    x
                ELSE
                    pin_limit
            END
        ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    -- NO IMPLEMENTADO 
    /*PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o            json_object_t;
        rec_compr040 compr040%rowtype;
        v_accion     VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_compr040.id_cia := pin_id_cia;
        rec_compr040.tipo := o.get_number('tipo');
        rec_compr040.docume := o.get_number('docume');
        rec_compr040.femisi := o.get_date('femisi');
        rec_compr040.codper := o.get_string('codper');
        rec_compr040.concep := o.get_string('concep');
        rec_compr040.motivo := o.get_number('motivo');
        rec_compr040.moneda := o.get_string('moneda');
        rec_compr040.codarea := o.get_number('codarea');
        rec_compr040.referen := o.get_string('referen');
        rec_compr040.ccosto := o.get_string('ccosto');
        rec_compr040.aprobado := o.get_string('aprobado');
        rec_compr040.caprob := o.get_string('caprob');
        rec_compr040.faprob := o.get_date('faprob');
        rec_compr040.tippago := o.get_number('tippago');
        rec_compr040.ctapago := o.get_string('ctapago');
        rec_compr040.situac := o.get_number('sitauc');
        rec_compr040.usuari := o.get_string('usuari');
        rec_compr040.periodo := o.get_number('periodo');
        rec_compr040.mes := o.get_number('mes');
        rec_compr040.libro := o.get_string('libro');
        rec_compr040.asiento := o.get_number('asiento');
        rec_compr040.librop := o.get_string('librop');
        rec_compr040.asientop := o.get_number('adientop');
        rec_compr040.tcambio := o.get_number('tcambio');
        rec_compr040.fondo := o.get_number('fondo');
        --rec_compr040.ucreac := o.get_string('ucreac');
        --rec_compr040.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO compr040 (
                    id_cia,
                    tipo,
                    docume,
                    femisi,
                    codper,
                    concep,
                    motivo,
                    moneda,
                    codarea,
                    referen,
                    ccosto,
                    aprobado,
                    caprob,
                    faprob,
                    tippago,
                    ctapago,
                    situac,
                    usuari,
                    fcreac,
                    factua,
                    periodo,
                    mes,
                    libro,
                    asiento,
                    librop,
                    asientop,
                    tcambio,
                    fondo
                ) VALUES (
                    rec_compr040.id_cia,
                    rec_compr040.tipo,
                    rec_compr040.docume,
                    rec_compr040.femisi,
                    rec_compr040.codper,
                    rec_compr040.concep,
                    rec_compr040.motivo,
                    rec_compr040.moneda,
                    rec_compr040.codarea,
                    rec_compr040.referen,
                    rec_compr040.ccosto,
                    rec_compr040.aprobado,
                    rec_compr040.caprob,
                    rec_compr040.faprob,
                    rec_compr040.tippago,
                    rec_compr040.ctapago,
                    rec_compr040.situac,
                    rec_compr040.usuari,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    rec_compr040.periodo,
                    rec_compr040.mes,
                    rec_compr040.libro,
                    rec_compr040.asiento,
                    rec_compr040.librop,
                    rec_compr040.asientop,
                    rec_compr040.tcambio,
                    rec_compr040.fondo
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE compr040
                SET
                    codper =
                        CASE
                            WHEN rec_compr040.codper IS NULL THEN
                                codper
                            ELSE
                                rec_compr040.codper
                        END,
                    motivo =
                        CASE
                            WHEN rec_compr040.motivo IS NULL THEN
                                motivo
                            ELSE
                                rec_compr040.motivo
                        END,
                    codarea =
                        CASE
                            WHEN rec_compr040.codarea IS NULL THEN
                                codarea
                            ELSE
                                rec_compr040.codarea
                        END,
                    referen =
                        CASE
                            WHEN rec_compr040.referen IS NULL THEN
                                referen
                            ELSE
                                rec_compr040.referen
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    usuari = rec_compr040.usuari
                WHERE
                        id_cia = pin_id_cia
                    AND tipo = rec_compr040.tipo
                    AND docume = rec_compr040.docume;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La Eliminación';
                DELETE FROM compr040
                WHERE
                        id_cia = pin_id_cia
                    AND tipo = rec_compr040.tipo
                    AND docume = rec_compr040.docume;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
        WHEN value_error THEN
            pin_mensaje := ' Formato Incorrecto, No se puede resgistrar ';
        WHEN OTHERS THEN
            IF sqlcode = -2292 THEN
                pin_mensaje := 'No es posible eliminar este registro por restricción de integridad';
            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' codigo :'
                               || sqlcode;
            END IF;
    END sp_save;*/

END;

/
