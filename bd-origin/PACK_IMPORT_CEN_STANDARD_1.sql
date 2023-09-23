--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_CEN_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_CEN_STANDARD" AS

    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        o                  json_object_t;
        reg_errores        r_errores;
        rec_documentos_cab documentos_cab%rowtype;
        rec_documentos_det documentos_det%rowtype;
        v_aux              VARCHAR2(1 CHAR);
        v_ruc              VARCHAR2(20 CHAR);
        v_razonc           VARCHAR2(200 CHAR);
        v_norden           NUMBER;
        v_nordennext       NUMBER;
        v_ean_entfac       VARCHAR2(20 CHAR);
        v_ean_entfacnext   VARCHAR2(20 CHAR);
        v_ean_desentfac    VARCHAR2(200 CHAR);
        v_fsolicitada      DATE;
        v_codmon           VARCHAR2(5 CHAR);
        v_ean_art          VARCHAR2(40 CHAR);
        v_ean_desart       VARCHAR2(200 CHAR);
        v_ean_entite       VARCHAR2(50 CHAR);
        v_ean_entitenext   VARCHAR2(50 CHAR);
        v_cantid           NUMBER;
        v_precio           NUMBER(16, 4);
        v_incigv           VARCHAR2(1 CHAR);
        v_ean_punven       VARCHAR2(50 CHAR);
        v_ean_punvennext   VARCHAR2(50 CHAR);
        v_ean_nompunven    VARCHAR2(200 CHAR);
        pin_coduser        VARCHAR2(10 CHAR);
        pin_codsuc         NUMBER;
    BEGIN
        o := json_object_t.parse(pin_datos);
        -- NUMERO DE FILA
        reg_errores.orden := o.get_number('fila');
        reg_errores.concepto := 'FILA - N°'
                                || to_char(o.get_number('fila'));
        v_ruc := o.get_string('ruc');-- COLUMNA 1
        v_razonc := o.get_string('razoc'); -- COLUMNA 2
        v_norden := o.get_number('norden'); -- COLUMNA 3
--        v_nordennext := o.get_number('nordennext'); -- COLUMNA 3 -NEXT
        v_ean_entfac := o.get_string('entfac'); -- COLUMNA 4
--        v_ean_entfacnext := o.get_string('entfacnext'); --COLUMNA 4 -NEXT
        v_ean_desentfac := o.get_string('desentfac'); -- COLUMNA 5
        v_fsolicitada := o.get_date('fsolicitada'); -- COLUMNA 6
        v_codmon := o.get_string('codmon'); -- COLUMNA 7
        v_ean_art := o.get_string('eanart'); -- COLUMNA 8
        v_ean_desart := o.get_string('eandesart'); -- COLUMNA 9
        v_ean_entite := o.get_string('entite'); -- COLUMNA 10
--        v_ean_entitenext := o.get_number('entitenext'); -- COLUMNA 10 -NEXT
        v_cantid := o.get_number('cantid'); -- COLUMNA 11
        v_precio := o.get_number('precio'); -- COLUMNA 12
        v_incigv := nvl(o.get_string('incigv'), 'S'); -- COLUMNA 13
        v_ean_punven := o.get_string('punven'); -- COLUMNA 14
--        v_ean_punvennext := o.get_string('punvennext'); -- COLUMNA 14 -NEXT
        v_ean_nompunven := o.get_string('despunven'); -- COLUMNA 15
        pin_coduser := o.get_string('coduser');
        pin_codsuc := o.get_number('codsuc');
        BEGIN
            SELECT
                'S'
            INTO v_aux
            FROM
                clientes_almacen
            WHERE
                    id_cia = pin_id_cia
                AND codcen = v_ean_punven
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := nvl(to_char(v_ean_punven), 'ND');
                reg_errores.deserror := 'NO HAY CLIENTE CON DIRECCION DE ENVIO QUE TENGA ASIGNADO EL CODIGO EAN ENVIADO - COLUMNA 14'
                || ' ( EL CODIGO EAN SE DEFINE EN LA DIRECCION DE ENVIO DEL CLIENTE )';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                'S'
            INTO v_aux
            FROM
                     cliente c
                INNER JOIN cliente_clase cc ON cc.id_cia = c.id_cia
                                               AND cc.codcli = c.codcli
                                               AND cc.clase = 9
            WHERE
                    c.id_cia = pin_id_cia
                AND cc.clase = 9
                AND cc.codigo = v_ean_entfac
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := nvl(v_ean_entfac, 'ND');
                reg_errores.deserror := 'NO EXISTE CLIENTE CON EL CODIGO DE EAN ENVIADO - COLUMNA 4 '
                                        || chr(13)
                                        || '( LA ASIGNACION DE CODIGO SE REALIZA DEFINIENDO LA CLASE 9 DEL CLIENTE )';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                'S'
            INTO v_aux
            FROM
                tcambio
            WHERE
                    id_cia = pin_id_cia
                AND hmoneda = 'PEN'
                AND trunc(fecha) = trunc(current_timestamp)
                AND moneda = 'USD';

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := nvl(to_char(current_timestamp, 'DD/MM/YY'), 'ND');
                reg_errores.deserror := 'REGISTRE EL TIPO DE CAMBIO PARA HOY';
                PIPE ROW ( reg_errores );
        END;

        -- VALIDACION DEL NUMERO DE ORDEN DE COMPRA YA GENERADO
        BEGIN
            SELECT
                numdoc,
                series
            INTO
                rec_documentos_cab.numdoc,
                rec_documentos_cab.series
            FROM
                documentos_cab
            WHERE
                    id_cia = pin_id_cia
                AND tipdoc = 101
                AND situac <> 'J'
                AND numped = to_char(v_norden);

            reg_errores.valor := nvl(to_char(v_norden), 'ND');
            reg_errores.deserror := 'LA ORDEN DE COMPRA N°'
                                    || v_norden
                                    || ' YA SE REGISTRADO EN LA ORDEN DE PEDIDO [ '
                                    || rec_documentos_cab.series
                                    || '-'
                                    || to_char(rec_documentos_cab.numdoc)
                                    || ' ]';

            PIPE ROW ( reg_errores );
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

        BEGIN
            SELECT
                'S'
            INTO v_aux
            FROM
                documentos
            WHERE
                    id_cia = pin_id_cia
                AND codigo = 101
                AND codsuc = pin_codsuc
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := nvl(to_char(pin_codsuc), 'ND');
                reg_errores.deserror := 'LA SUCURSAL NO TIENE REGISTRADA UNA SERIE VALIDA PARA LA ORDEN DE DESPACHO';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                'S'
            INTO v_aux
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 1;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := nvl(to_char(pin_codsuc), 'ND');
                reg_errores.deserror := 'LA EMPRESA NO TIENE CONFIGURADO EL FACTOR I.G.V (CODIGO 1)';
                PIPE ROW ( reg_errores );
        END;

--        BEGIN
--            SELECT
--                'S'
--            INTO v_aux
--            FROM
--                vendedor
--            WHERE
--                    id_cia = pin_id_cia
--                AND codven = 0;
--
--        EXCEPTION
--            WHEN no_data_found THEN
--                reg_errores.valor := nvl(to_char(pin_codsuc), 'ND');
--                reg_errores.deserror := 'LA EMPRESA NO TIENE CONFIGURADO UN VENDEDOR POR DEFECTO (CODIGO 0)';
--                PIPE ROW ( reg_errores );
--        END;

        RETURN;
    END sp_valida_objeto;

    FUNCTION sp_valida_objeto_detalle (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        o                  json_object_t;
        reg_errores        r_errores;
        rec_documentos_cab documentos_cab%rowtype;
        rec_documentos_det documentos_det%rowtype;
        v_aux              VARCHAR2(1 CHAR);
        v_ruc              VARCHAR2(20 CHAR);
        v_razonc           VARCHAR2(200 CHAR);
        v_norden           NUMBER;
        v_nordennext       NUMBER;
        v_ean_entfac       VARCHAR2(20 CHAR);
        v_ean_entfacnext   VARCHAR2(20 CHAR);
        v_ean_desentfac    VARCHAR2(200 CHAR);
        v_fsolicitada      DATE;
        v_codmon           VARCHAR2(5 CHAR);
        v_ean_art          VARCHAR2(40 CHAR);
        v_ean_desart       VARCHAR2(200 CHAR);
        v_ean_entite       VARCHAR2(50 CHAR);
        v_ean_entitenext   VARCHAR2(50 CHAR);
        v_cantid           NUMBER;
        v_precio           NUMBER(16, 4);
        v_incigv           VARCHAR2(1 CHAR);
        v_ean_punven       VARCHAR2(50 CHAR);
        v_ean_punvennext   VARCHAR2(50 CHAR);
        v_ean_nompunven    VARCHAR2(200 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        -- NUMERO DE FILA
        reg_errores.orden := o.get_number('fila');
        reg_errores.concepto := 'FILA - N°'
                                || to_char(o.get_number('fila'));
        v_ruc := o.get_string('ruc');-- COLUMNA 1
        v_razonc := o.get_string('razoc'); -- COLUMNA 2
        v_norden := o.get_number('norden'); -- COLUMNA 3
--        v_nordennext := o.get_number('nordennext'); -- COLUMNA 3 -NEXT
        v_ean_entfac := o.get_string('entfac'); -- COLUMNA 4
--        v_ean_entfacnext := o.get_string('entfacnext'); --COLUMNA 4 -NEXT
        v_ean_desentfac := o.get_string('desentfac'); -- COLUMNA 5
        v_fsolicitada := o.get_date('fsolicitada'); -- COLUMNA 6
        v_codmon := o.get_string('codmon'); -- COLUMNA 7
        v_ean_art := o.get_string('eanart'); -- COLUMNA 8
        v_ean_desart := o.get_string('eandesart'); -- COLUMNA 9
        v_ean_entite := o.get_string('entite'); -- COLUMNA 10
--        v_ean_entitenext := o.get_number('entitenext'); -- COLUMNA 10 -NEXT
        v_cantid := o.get_number('cantid'); -- COLUMNA 11
        v_precio := o.get_number('precio'); -- COLUMNA 12
        v_incigv := nvl(o.get_string('incigv'), 'S'); -- COLUMNA 13
        v_ean_punven := o.get_string('punven'); -- COLUMNA 14
--        v_ean_punvennext := o.get_string('punvennext'); -- COLUMNA 14 -NEXT
        v_ean_nompunven := o.get_string('despunven'); -- COLUMNA 15
        BEGIN
            SELECT
                'S'
            INTO v_aux
            FROM
                articulos_ean
            WHERE
                    id_cia = pin_id_cia
                AND ean = v_ean_art
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                BEGIN
                    SELECT
                        'S'
                    INTO v_aux
                    FROM
                        articulos
                    WHERE
                            id_cia = pin_id_cia
                        AND codbar = v_ean_art
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        reg_errores.valor := nvl(v_ean_art, 'ND');
                        reg_errores.deserror := 'NO HAY NINGUN ARTICULO CON EL CODIGO DE EAN DEFINIDO - COLUMNA 8';
                        PIPE ROW ( reg_errores );
                END;
        END;

        RETURN;
    END sp_valida_objeto_detalle;

    FUNCTION sp_orden_pedido (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable_orden_pedido
        PIPELINED
    AS

        o                    json_object_t;
        rec_documentos_cab   datarecord_orden_pedido;
        rec_cliente          cliente%rowtype;
        rec_cliente_clase    cliente_clase%rowtype;
        rec_clientes_almacen clientes_almacen%rowtype;
        v_ruc                VARCHAR2(20 CHAR);
        v_razonc             VARCHAR2(200 CHAR);
        v_norden             NUMBER;
        v_nordennext         NUMBER;
        v_ean_entfac         VARCHAR2(20 CHAR);
        v_ean_entfacnext     VARCHAR2(20 CHAR);
        v_ean_desentfac      VARCHAR2(200 CHAR);
        v_fsolicitada        DATE;
        v_codmon             VARCHAR2(5 CHAR);
        v_ean_art            VARCHAR2(40 CHAR);
        v_ean_desart         VARCHAR2(200 CHAR);
        v_ean_entite         VARCHAR2(50 CHAR);
        v_ean_entitenext     VARCHAR2(50 CHAR);
        v_cantid             NUMBER;
        v_precio             NUMBER(16, 4);
        v_incigv             VARCHAR2(1 CHAR);
        v_ean_punven         VARCHAR2(50 CHAR);
        v_ean_punvennext     VARCHAR2(50 CHAR);
        v_ean_nompunven      VARCHAR2(200 CHAR);
        pin_coduser          VARCHAR2(10 CHAR);
        pin_codsuc           NUMBER;
    BEGIN
        o := json_object_t.parse(pin_datos);
        v_ruc := o.get_string('ruc');-- COLUMNA 1
        v_razonc := o.get_string('razoc'); -- COLUMNA 2
        v_norden := o.get_number('norden'); -- COLUMNA 3
--        v_nordennext := o.get_number('nordennext'); -- COLUMNA 3 -NEXT
        v_ean_entfac := o.get_string('entfac'); -- COLUMNA 4
--        v_ean_entfacnext := o.get_string('entfacnext'); --COLUMNA 4 -NEXT
        v_ean_desentfac := o.get_string('desentfac'); -- COLUMNA 5
        v_fsolicitada := o.get_date('fsolicitada'); -- COLUMNA 6
        v_codmon := nvl(o.get_string('codmon'), 'PEN'); -- COLUMNA 7
        v_ean_art := o.get_string('eanart'); -- COLUMNA 8
        v_ean_desart := o.get_string('eandesart'); -- COLUMNA 9
        v_ean_entite := o.get_string('entite'); -- COLUMNA 10
--        v_ean_entitenext := o.get_number('entitenext'); -- COLUMNA 10 -NEXT
        v_cantid := o.get_number('cantid'); -- COLUMNA 11
        v_precio := o.get_number('precio'); -- COLUMNA 12
        v_incigv := nvl(o.get_string('incigv'), 'S'); -- COLUMNA 13
        v_ean_punven := o.get_string('punven'); -- COLUMNA 14
--        v_ean_punvennext := o.get_string('punvennext'); -- COLUMNA 14 -NEXT
        v_ean_nompunven := o.get_string('despunven'); -- COLUMNA 15
        pin_coduser := o.get_string('coduser');
        pin_codsuc := o.get_number('codsuc');
        SELECT
            c.codcli,
            c.tident,
            c.dident,
            c.direc1,
            c.telefono,
            cc.codigo,
            c.razonc,
            c.codtit,
            ca.codenv,
            ca.descri,
            ca.direc1,
            ca.direc2
        INTO
            rec_cliente.codcli,
            rec_cliente.tident,
            rec_cliente.dident,
            rec_cliente.direc1,
            rec_cliente.telefono,
            rec_cliente_clase.codigo,
            rec_cliente.razonc,
            rec_cliente.codtit,
            rec_clientes_almacen.codenv,
            rec_clientes_almacen.descri,
            rec_clientes_almacen.direc1,
            rec_clientes_almacen.direc2
        FROM
                 cliente c
            INNER JOIN cliente_clase    cc ON cc.id_cia = c.id_cia
                                           AND cc.codcli = c.codcli
                                           AND cc.clase = 9
            INNER JOIN clientes_almacen ca ON ca.id_cia = c.id_cia
                                              AND ca.codcli = c.codcli
                                              AND ca.codcen = v_ean_punven -- VALIDACION NO DATA FOUND, ESTA EN SP_VALIDA_OBJETO
        WHERE
                c.id_cia = pin_id_cia
            AND cc.clase = 9
            AND cc.codigo = v_ean_entfac -- VALIDACION NO DATA FOUND, ESTA EN SP_VALIDA_OBJETO
        ORDER BY
            c.codcli
        FETCH NEXT 1 ROWS ONLY;
        -- CONSTRULLENDO EL DOCUMENTO_CAB
        rec_documentos_cab.id_cia := pin_id_cia;
        rec_documentos_cab.numint := NULL;
--            rec_documentos_cab.tipdoc := 101;
        rec_documentos_cab.codsuc := pin_codsuc;
        SELECT
            series
        INTO rec_documentos_cab.serie
        FROM
            documentos
        WHERE
                id_cia = pin_id_cia
            AND codigo = 101
            AND codsuc = pin_codsuc
        FETCH NEXT 1 ROWS ONLY;

        rec_documentos_cab.numero := NULL;
        rec_documentos_cab.femisi := trunc(current_timestamp);
        rec_documentos_cab.fentreg := trunc(v_fsolicitada);
        rec_documentos_cab.horapactada := NULL;
        rec_documentos_cab.lugemi := 2;
        rec_documentos_cab.situac := NULL;
        rec_documentos_cab.id := 'S';
        SELECT
            codmot
        INTO rec_documentos_cab.codmot
        FROM
            motivos
        WHERE
                id_cia = pin_id_cia
            AND id = 'S'
            AND tipdoc = 101
        ORDER BY
            codmot ASC
        FETCH NEXT 1 ROWS ONLY;

        CASE
            WHEN v_incigv = 'S' THEN
                rec_documentos_cab.incigv := 'true';
            ELSE
                rec_documentos_cab.incigv := 'false';
        END CASE;

        SELECT
            vreal
        INTO rec_documentos_cab.porigv
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 1;

        SELECT
            codven,
            desven
        INTO
            rec_documentos_cab.codven,
            rec_documentos_cab.vendedor
        FROM
            vendedor
        WHERE
                id_cia = pin_id_cia
            AND codven = 0;

        rec_documentos_cab.codcli := rec_cliente.codcli;
        rec_documentos_cab.tident := rec_cliente.tident;
        rec_documentos_cab.dident := rec_cliente.dident;
        rec_documentos_cab.razonsocial := rec_cliente.razonc;
        rec_documentos_cab.direccion := rec_cliente.direc1;
        rec_documentos_cab.telefono := rec_cliente.telefono;
--        SELECT
--            JSON_OBJECT(
--                'id_cia' VALUE pin_id_cia,
--                'numint' VALUE NULL,
--                'codenv' VALUE rec_clientes_almacen.codenv,
--                'direc1' VALUE rec_clientes_almacen.direc1,
--                'direc2' VALUE rec_clientes_almacen.direc2,
--                        'ubigeo' VALUE NULL
--            )
--        INTO rec_documentos_cab.direccionenvio
--        FROM
--            dual;

        rec_documentos_cab.observacion := 'Informacion por Masivo';
        rec_documentos_cab.referencia := v_norden;
        SELECT
            venta
        INTO rec_documentos_cab.tipcam
        FROM
            tcambio
        WHERE
                id_cia = pin_id_cia
            AND hmoneda = 'PEN'
            AND trunc(fecha) = trunc(current_timestamp)
            AND moneda = 'USD';

        rec_documentos_cab.moneda := v_codmon;
        SELECT
            codpag,
            despag
        INTO
            rec_documentos_cab.codcpag,
            rec_documentos_cab.condicionpago
        FROM
            c_pago
        WHERE
                id_cia = pin_id_cia
            AND codpag = 1;

        rec_documentos_cab.ucreac := pin_coduser;
        rec_documentos_cab.usuari := pin_coduser;
        rec_documentos_cab.fcreac := trunc(current_timestamp);
        rec_documentos_cab.factua := trunc(current_timestamp);
        rec_documentos_cab.direccionenvio_codenv := rec_clientes_almacen.codenv;
        rec_documentos_cab.direccionenvio_direc1 := rec_clientes_almacen.direc1;
        rec_documentos_cab.direccionenvio_direc2 := rec_clientes_almacen.direc2;
        BEGIN
            SELECT
                femisi
            INTO rec_documentos_cab.ordencompra_fecha
            FROM
                documentos_cab
            WHERE
                    id_cia = pin_id_cia
                AND numint = v_norden;

        EXCEPTION
            WHEN no_data_found THEN
                rec_documentos_cab.ordencompra_fecha := NULL;
        END;

        rec_documentos_cab.ordencompra_numero := v_norden;
        rec_documentos_cab.ordencompra_contacto := NULL;
        PIPE ROW ( rec_documentos_cab );
        RETURN;
    END sp_orden_pedido;

    FUNCTION sp_orden_pedido_detalle (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable_orden_pedido_detalle
        PIPELINED
    AS

        o                    json_object_t;
        rec_documentos_det   datarecord_orden_pedido_detalle;
        rec_documentos_cab   documentos_cab%rowtype;
        rec_cliente          cliente%rowtype;
        rec_cliente_clase    cliente_clase%rowtype;
        rec_clientes_almacen clientes_almacen%rowtype;
        v_ruc                VARCHAR2(20 CHAR);
        v_razonc             VARCHAR2(200 CHAR);
        v_norden             NUMBER;
        v_nordennext         NUMBER;
        v_ean_entfac         VARCHAR2(20 CHAR);
        v_ean_entfacnext     VARCHAR2(20 CHAR);
        v_ean_desentfac      VARCHAR2(200 CHAR);
        v_fsolicitada        DATE;
        v_codmon             VARCHAR2(5 CHAR);
        v_ean_art            VARCHAR2(40 CHAR);
        v_ean_desart         VARCHAR2(200 CHAR);
        v_ean_entite         VARCHAR2(50 CHAR);
        v_ean_entitenext     VARCHAR2(50 CHAR);
        v_cantid             NUMBER;
        v_precio             NUMBER(16, 4);
        v_incigv             VARCHAR2(1 CHAR);
        v_ean_punven         VARCHAR2(50 CHAR);
        v_ean_punvennext     VARCHAR2(50 CHAR);
        v_ean_nompunven      VARCHAR2(200 CHAR);
        pin_coduser          VARCHAR2(10 CHAR);
        pin_codsuc           NUMBER;
    BEGIN
        o := json_object_t.parse(pin_datos);
        v_ruc := o.get_string('ruc');-- COLUMNA 1
        v_razonc := o.get_string('razoc'); -- COLUMNA 2
        v_norden := o.get_number('norden'); -- COLUMNA 3
--        v_nordennext := o.get_number('nordennext'); -- COLUMNA 3 -NEXT
        v_ean_entfac := o.get_string('entfac'); -- COLUMNA 4
--        v_ean_entfacnext := o.get_string('entfacnext'); --COLUMNA 4 -NEXT
        v_ean_desentfac := o.get_string('desentfac'); -- COLUMNA 5
        v_fsolicitada := o.get_date('fsolicitada'); -- COLUMNA 6
        v_codmon := nvl(o.get_string('codmon'), 'PEN'); -- COLUMNA 7
        v_ean_art := o.get_string('eanart'); -- COLUMNA 8
        v_ean_desart := o.get_string('eandesart'); -- COLUMNA 9
        v_ean_entite := o.get_string('entite'); -- COLUMNA 10
--        v_ean_entitenext := o.get_number('entitenext'); -- COLUMNA 10 -NEXT
        v_cantid := o.get_number('cantid'); -- COLUMNA 11
        v_precio := o.get_number('precio'); -- COLUMNA 12
        v_incigv := nvl(o.get_string('incigv'), 'S'); -- COLUMNA 13
        v_ean_punven := o.get_string('punven'); -- COLUMNA 14
--        v_ean_punvennext := o.get_string('punvennext'); -- COLUMNA 14 -NEXT
        v_ean_nompunven := o.get_string('despunven'); -- COLUMNA 15
        pin_coduser := o.get_string('coduser');
        pin_codsuc := o.get_number('codsuc');
        -- INSERTANDO EL DOCUMENTO DET
        rec_documentos_det.id_cia := pin_id_cia;
        rec_documentos_det.numint := NULL;
        rec_documentos_det.numite := NULL;
--        rec_documentos_det.tipdoc := 101;
--        rec_documentos_det.series := NULL;
        BEGIN
            SELECT
                a.tipinv,
                a.codart,
                a.descri,
                a.coduni
            INTO
                rec_documentos_det.tipinv,
                rec_documentos_det.codart,
                rec_documentos_det.desart,
                rec_documentos_det.undmed
            FROM
                articulos     a
                LEFT OUTER JOIN articulos_ean ae ON a.id_cia = ae.id_cia
                                                    AND a.codart = ae.codart
            WHERE
                    ae.id_cia = pin_id_cia
                AND ae.ean = v_ean_art
            ORDER BY
                a.codart
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                SELECT
                    a.tipinv,
                    a.codart,
                    a.descri,
                    a.coduni
                INTO
                    rec_documentos_det.tipinv,
                    rec_documentos_det.codart,
                    rec_documentos_det.desart,
                    rec_documentos_det.undmed
                FROM
                    articulos a
                WHERE
                        a.id_cia = pin_id_cia
                    AND a.codbar = v_ean_art
                ORDER BY
                    a.codart
                FETCH NEXT 1 ROWS ONLY;

        END;

--        rec_documentos_det.situac := NULL;
        rec_documentos_det.codalm := NULL;
        rec_documentos_det.cantid := v_cantid;
--        rec_documentos_det.canref := NULL;
--        rec_documentos_det.canped := NULL;
--        rec_documentos_det.saldo := NULL;
        rec_documentos_det.pordes1 := NULL;
        rec_documentos_det.pordes2 := NULL;
        rec_documentos_det.pordes3 := NULL;
        rec_documentos_det.pordes4 := NULL;
        SELECT
            vreal
        INTO rec_documentos_cab.porigv
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 1;

        IF v_incigv = 'N' THEN
            rec_documentos_det.preuni := v_precio;
            rec_documentos_det.preuni := ( rec_documentos_det.preuni * ( 1 + ( rec_documentos_cab.porigv / 100 ) ) ); -- PENDIENTE

        ELSE
            rec_documentos_det.preuni := v_precio;
        END IF;

        PIPE ROW ( rec_documentos_det );
        RETURN;
    END sp_orden_pedido_detalle;

END;

/
