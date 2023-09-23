--------------------------------------------------------
--  DDL for Package Body PACK_VALIDA_DOCUMENTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_VALIDA_DOCUMENTO" AS

    FUNCTION sp_propiedad (
        pin_id_cia  INTEGER,
        pin_codigo  INTEGER,
        pin_coduser VARCHAR2
    ) RETURN VARCHAR2 AS
        v_respuesta VARCHAR2(1 CHAR) := 'S';
    BEGIN
        BEGIN
            SELECT
                nvl(swflag, 'N')
            INTO v_respuesta
            FROM
                usuarios_propiedades
            WHERE
                    id_cia = pin_id_cia
                AND coduser = pin_coduser
                AND codigo = pin_codigo;

        EXCEPTION
            WHEN no_data_found THEN
                v_respuesta := 'N';
        END;

        RETURN v_respuesta;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'S';
    END sp_propiedad;

    PROCEDURE sp_tope (
        pin_id_cia  IN INTEGER,
        pin_codigo  IN INTEGER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_desdoc     VARCHAR2(250 CHAR) := '';
        v_aux        VARCHAR2(250 CHAR) := '';
        v_vstring    NUMBER;
        v_importe    NUMBER;
        pout_mensaje VARCHAR2(1000 CHAR);
        pin_tipdoc   INTEGER := 0;
    BEGIN
        CASE pin_codigo
            WHEN 80 THEN
                pin_tipdoc := 101;
            WHEN 108 THEN
                pin_tipdoc := 105;
            WHEN 85 THEN
                pin_tipdoc := 201;
            ELSE
                pin_tipdoc := 0;
        END CASE;

        BEGIN
            SELECT
                descri
            INTO v_desdoc
            FROM
                documentos_tipo
            WHERE
                    id_cia = pin_id_cia
                AND tipdoc = pin_tipdoc;

        EXCEPTION
            WHEN no_data_found THEN
                v_desdoc := 'NO DEFINIDO';
        END;

        BEGIN
            SELECT
                CASE
                    WHEN tipmon = 'PEN' THEN
                        nvl(preven, 0)
                    ELSE
                        nvl(preven, 0) * nvl(tipcam, 0)
                END AS importe
            INTO v_importe
            FROM
                documentos_cab
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'EL DOCUMENTO N° '
                                || pin_numint
                                || ' NO EXISTE!';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                vstring
            INTO v_aux
            FROM
                usuarios_propiedades
            WHERE
                    id_cia = pin_id_cia
                AND coduser = pin_coduser
                AND codigo = pin_codigo;

        EXCEPTION
            WHEN no_data_found THEN
                v_aux := '0';
        END;

        SELECT
            CAST(nvl(TRIM(v_aux),
                     '0') AS NUMBER)
        INTO v_vstring
        FROM
            dual;

        IF nvl(v_vstring, 0) > 0 THEN
            IF v_importe > v_vstring THEN
                pout_mensaje := 'EL USUARIO NO PUEDE APROBAR LA(EL) '
                                || v_desdoc
                                || ' POR SU TOPE DE APROBACION, '
                                || ' ( REVISAR EL VALOR VSTRING DE LA PROPIEDAD N° '
                                || pin_codigo
                                || ' ) !';

                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success!'
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
            IF sqlcode = -1722 THEN
                pin_mensaje := 'ERROR,  EL VALOR VSTRING ( '
                               || v_aux
                               || ' ) ASIGNADO A LA PROPIEDAD N° '
                               || pin_codigo
                               || ', NO PUEDE INTERPRETAR COMO UN NUMERO !';
            ELSE
                pin_mensaje := 'ERROR: '
                               || sqlerrm
                               || ' CODIGO: '
                               || sqlcode;
            END IF;

            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_tope;

    PROCEDURE sp_detalle (
        pin_id_cia  IN INTEGER,
        pin_tipdoc  IN INTEGER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_mensaje    VARCHAR2(1000) := '';
        o            json_object_t;
        pout_mensaje VARCHAR2(1000 CHAR);
        v_vstrg      factor.vstrg%TYPE;
    BEGIN
        BEGIN
            SELECT
                nvl(vstrg, 'N')
            INTO v_vstrg
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 442;

        EXCEPTION
            WHEN no_data_found THEN
                v_vstrg := 'N';
        END;

        IF
            pin_tipdoc = 101
            AND v_vstrg = 'S'
        THEN -- ORDER DE PEDIDO

            BEGIN
                FOR i IN (
                    SELECT
                        d.*
                    FROM
                        documentos_det d
                    WHERE
                            d.id_cia = pin_id_cia
                        AND d.numint = pin_numint
                    ORDER BY
                        d.numite ASC
                ) LOOP
                    IF nvl(i.tipcam, 0) = 0 THEN
                        pout_mensaje := 'ERROR, EL TIPO DE CAMBIO PARA EL ITEM N°'
                                        || to_char(i.numite)
                                        || ' ( CODART : '
                                        || i.codart
                                        || ' ) '
                                        || ' NO ESTA DEFINIDO (NULO O EN CERO)';

                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                    IF nvl(i.cosuni, 0) = 0 THEN
                        pout_mensaje := 'ERROR, EL COSTO UNITARIO PARA EL ITEM N°'
                                        || to_char(i.numite)
                                        || ' ( CODART : '
                                        || i.codart
                                        || ' ) '
                                        || ' NO ESTA DEFINIDO (NULO O EN CERO)';

                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END LOOP;

            END;

        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success!'
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
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_detalle;

    PROCEDURE sp_permiso (
        pin_id_cia  IN INTEGER,
        pin_tipdoc  IN INTEGER,
        pin_accion  IN VARCHAR2, -- 'V' ( Visar ), 'A' ( Aprobacion )
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_permiso    VARCHAR2(1 CHAR) := 'S';
        v_accion     VARCHAR2(20 CHAR) := '';
        v_desdoc     VARCHAR2(250 CHAR) := '';
        v_mensaje    VARCHAR2(1000) := '';
        v_codigo     INTEGER;
        o            json_object_t;
        pout_mensaje VARCHAR2(1000 CHAR);
    BEGIN
        v_permiso := 'S';
        BEGIN
            SELECT
                descri
            INTO v_desdoc
            FROM
                documentos_tipo
            WHERE
                    id_cia = pin_id_cia
                AND tipdoc = pin_tipdoc;

        EXCEPTION
            WHEN no_data_found THEN
                v_desdoc := 'NO DEFINIDO';
        END;

        CASE pin_tipdoc
            WHEN 100 THEN -- COTIZACION
                IF pin_accion = 'V' THEN
                    v_permiso := pack_valida_documento.sp_propiedad(pin_id_cia, 5, pin_coduser);
                    v_codigo := 5;
                ELSIF pin_accion = 'A' THEN
                    v_permiso := 'S';
                ELSE
                    v_permiso := 'S';
                END IF;
            WHEN 101 THEN -- ORDEN DE PEDIDO
                IF pin_accion = 'V' THEN
                    v_permiso := pack_valida_documento.sp_propiedad(pin_id_cia, 10, pin_coduser);
                    v_codigo := 10;
                ELSIF pin_accion = 'A' THEN
                    v_permiso := pack_valida_documento.sp_propiedad(pin_id_cia, 80, pin_coduser);
                    v_codigo := 80;
                    IF v_permiso = 'S' THEN
                        pack_valida_documento.sp_tope(pin_id_cia, 80, pin_numint, pin_coduser, v_mensaje);
                        o := json_object_t.parse(v_mensaje);
                        IF ( o.get_number('status') <> 1.0 ) THEN
                            pout_mensaje := o.get_string('message');
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;

                    END IF;

                ELSE
                    v_permiso := 'S';
                END IF;
            WHEN 105 THEN -- ORDEN DE COMPRA
                IF pin_accion = 'V' THEN
                    v_permiso := pack_valida_documento.sp_propiedad(pin_id_cia, 12, pin_coduser);
                    v_codigo := 12;
                ELSIF pin_accion = 'A' THEN
                    v_permiso := pack_valida_documento.sp_propiedad(pin_id_cia, 108, pin_coduser);
                    v_codigo := 108;
                    IF v_permiso = 'S' THEN
                        pack_valida_documento.sp_tope(pin_id_cia, 108, pin_numint, pin_coduser, v_mensaje);
                        o := json_object_t.parse(v_mensaje);
                        IF ( o.get_number('status') <> 1.0 ) THEN
                            pout_mensaje := o.get_string('message');
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;

                    END IF;

                ELSE
                    v_permiso := 'S';
                END IF;
            WHEN 104 THEN -- ORDEN DE PRODUCCION
                IF pin_accion = 'V' THEN
                    v_permiso := pack_valida_documento.sp_propiedad(pin_id_cia, 13, pin_coduser);
                    v_codigo := 13;
                ELSIF pin_accion = 'A' THEN
                    v_permiso := 'S';
                ELSE
                    v_permiso := 'S';
                END IF;
            WHEN 125 THEN -- REQUERIMIENTO DE COMPRA
                IF pin_accion = 'V' THEN
                    v_permiso := pack_valida_documento.sp_propiedad(pin_id_cia, 11, pin_coduser);
                    v_codigo := 11;
                ELSIF pin_accion = 'A' THEN
                    v_permiso := 'S';
                ELSE
                    v_permiso := 'S';
                END IF;
            WHEN 201 THEN -- ORDER DE DEVOLUCION
                IF pin_accion = 'V' THEN
                    v_permiso := 'S';
                ELSIF pin_accion = 'A' THEN
                    v_permiso := pack_valida_documento.sp_propiedad(pin_id_cia, 85, pin_coduser);
                    v_codigo := 85;
                    IF v_permiso = 'S' THEN
                        pack_valida_documento.sp_tope(pin_id_cia, 85, pin_numint, pin_coduser, v_mensaje);
                        o := json_object_t.parse(v_mensaje);
                        IF ( o.get_number('status') <> 1.0 ) THEN
                            pout_mensaje := o.get_string('message');
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;

                    END IF;

                ELSE
                    v_permiso := 'S';
                END IF;
            ELSE
                v_permiso := 'S';
        END CASE;

        IF v_permiso = 'S' THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.0,
                    'message' VALUE 'Success!'
                )
            INTO pin_mensaje
            FROM
                dual;

        ELSE
            CASE pin_accion
                WHEN 'V' THEN
                    v_accion := 'VISAR';
                WHEN 'A' THEN
                    v_accion := 'APROBAR';
                ELSE
                    v_accion := 'NO DEFINIDO';
            END CASE;

            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                            'message' VALUE 'EL USUARIO [ '
                                            || pin_coduser
                                            || ' ] no tiene la PROPIEDAD para '
                                            || v_accion
                                            || ' la(el) '
                                            || upper(v_desdoc)
                                            || ' !'
                                            || ' ( REVISAR LA ASIGNACION DE LA PROPIEDAD N° '
                                            || v_codigo
                                            || ' Y EL VALOR SWFLAG ) !'
                )
            INTO pin_mensaje
            FROM
                dual;

        END IF;

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
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_permiso;

END;

/
