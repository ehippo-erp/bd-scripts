--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_TOMA_INVENTARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_TOMA_INVENTARIO" AS

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_toma_inventario
        PIPELINED
    AS
        v_table datatable_toma_inventario;
    BEGIN
        SELECT
            c.numint,
            c.series,
            c.numdoc,
            c.tident,
            c.ruc,
            c.codcli,
            c.razonc   AS razonsocial,
            c.direc1   AS direccion,
            c.fentreg  AS fentreg,
            c.femisi,
            c.lugemi,
            c.situac,
            s.dessit   AS situacnombre,
            c.id,
            c.codmot,
            c.codven,
            c.codsuc,
            c.tipmon   AS moneda,
            c.tipcam,
            c.optipinv,
            t.dtipinv,
            c.codalm,
            a.descri,
--            coc.numint   AS coc_numint,
--            coc.fecha    AS coc_fecha,
--            coc.numero   AS coc_numero,
--            coc.contacto AS coc_contacto,
--            cp.despag    AS condicionpago,
            v.desven   AS vendedor,
--            c.codcpag,
            c.usuari   AS coduser,
            us.nombres AS usuario,
            CASE
                WHEN c.incigv = 'S' THEN
                    'true'
                ELSE
                    'false'
            END        AS incigv,
            c.porigv,
            c.numped   AS referencia,
            c.observ   AS observacion,
            c.monafe,
            c.monina,
            c.monigv,
            c.preven,
            c.totbru   AS importebruto,
            c.preven   AS importe,
            dcc.vchar  AS situacimp,
            CASE
                WHEN dcc.vchar = 'S' THEN
                    'Liquidado'
                ELSE
                    'En proceso'
            END        AS dessituacimp,
            c.flete,
            c.countadj,
            c.seguro,
            c.tipdoc,
            c1.descri  AS dtipdoc,
            m1.desmot  AS motivo,
            c.ucreac,
            c.factua,
            c.fcreac
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab       c
            LEFT OUTER JOIN t_inventario         t ON t.id_cia = c.id_cia
                                              AND t.tipinv = c.optipinv
            LEFT OUTER JOIN almacen              a ON a.id_cia = t.id_cia
                                         AND a.tipinv = t.tipinv
                                         AND a.codalm = c.codalm
--            LEFT OUTER JOIN documentos_cab_ordcom coc ON coc.id_cia = c.id_cia
--                                                         AND coc.numint = c.numint
            LEFT OUTER JOIN documentos_cab_clase dcc ON dcc.id_cia = c.id_cia
                                                        AND dcc.numint = c.numint
                                                        AND dcc.clase = 1
--            LEFT OUTER JOIN c_pago                cp ON cp.id_cia = c.id_cia
--                                         AND cp.codpag = c.codcpag
            LEFT OUTER JOIN vendedor             v ON v.id_cia = c.id_cia
                                          AND v.codven = c.codven
            LEFT OUTER JOIN cliente              cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codcli
            LEFT OUTER JOIN usuarios             us ON us.id_cia = c.id_cia
                                           AND us.coduser = c.usuari
            LEFT OUTER JOIN situacion            s ON s.id_cia = c.id_cia
                                           AND s.tipdoc = c.tipdoc
                                           AND s.situac = c.situac
            LEFT OUTER JOIN motivos              m1 ON m1.id_cia = c.id_cia
                                          AND m1.tipdoc = c.tipdoc
                                          AND m1.codmot = c.codmot
                                          AND m1.id = c.id
            LEFT OUTER JOIN documentos           c1 ON c1.id_cia = c.id_cia
                                             AND c1.codigo = c.tipdoc
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 111
            AND c.codmot = 5
            AND c.femisi BETWEEN pin_fdesde AND pin_fhasta;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    PROCEDURE sp_anular (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_femisi     DATE;
        v_mensaje    VARCHAR2(1000) := '';
        pout_mensaje VARCHAR2(1000) := '';
        o            json_object_t;
    BEGIN
        SELECT
            femisi
        INTO v_femisi
        FROM
            documentos_cab
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;


      --MES 0 : APERTURA Y 4 : MODULO LOGISTICA 
        sp_chequea_mes_proceso(pin_id_cia, extract(YEAR FROM v_femisi), 0, 4, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;    

        -- ELIMINA KARDEX
        DELETE kardex
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        COMMIT;
       --SE MODIFICA LA SITUACIÒN A ANULADA
        UPDATE documentos_cab
        SET
            situac = 'J' -- J = ANULADA        
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pout_mensaje := 'mensaje : '
                            || sqlerrm
                            || ' codigo :'
                            || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_anular;

    PROCEDURE sp_anular_fisico (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_femisi     DATE;
        v_mensaje    VARCHAR2(1000) := '';
        pout_mensaje VARCHAR2(1000) := '';
        o            json_object_t;
    BEGIN
        SELECT
            femisi
        INTO v_femisi
        FROM
            documentos_cab
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

      --MES 0 : APERTURA Y 4 : MODULO LOGISTICA 

        sp_chequea_mes_proceso(pin_id_cia, extract(YEAR FROM v_femisi), 0, 4, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;    

    -- ELIMINA KARDEX
        DELETE kardex
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        COMMIT;
       --SE MODIFICA LA SITUACIÒN A ANULADA
        UPDATE documentos_cab
        SET
            situac = 'J' -- J = ANULADA        
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pout_mensaje := 'mensaje : '
                            || sqlerrm
                            || ' codigo :'
                            || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_anular_fisico;

END;

/
