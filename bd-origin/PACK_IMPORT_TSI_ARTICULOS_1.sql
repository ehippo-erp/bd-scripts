--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_TSI_ARTICULOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_TSI_ARTICULOS" AS

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_coduni VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        SELECT
            tipinv,
            codart,
            descri,
            coduni,
            consto,
            codprv,
            wglosa,
            proart,
            faccon,
            codbar
        BULK COLLECT
        INTO v_table
        FROM
            articulos
        WHERE
                id_cia = pin_id_cia
            AND tipinv = pin_tipinv
            AND ( pin_coduni IS NULL
                  OR coduni = pin_coduni )
        ORDER BY
            codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION existe_unidad_medida (
        pin_id_cia IN NUMBER,
        pin_unidad IN VARCHAR2
    ) RETURN INTEGER AS
        v_count   INTEGER := 0;
        resultado INTEGER := 0;
    BEGIN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_count
            FROM
                unidad
            WHERE
                    id_cia = pin_id_cia
                AND coduni = pin_unidad;

        EXCEPTION
            WHEN no_data_found THEN
                v_count := NULL;
        END;

        IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
            resultado := 0;
        ELSE
            resultado := 1;
        END IF;

        RETURN resultado;
    END existe_unidad_medida;

    FUNCTION existe_tipo_inventario (
        pin_id_cia IN NUMBER,
        pin_tipinv IN INTEGER
    ) RETURN INTEGER AS
        v_count   INTEGER := 0;
        resultado INTEGER := 0;
    BEGIN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_count
            FROM
                t_inventario
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv;

        EXCEPTION
            WHEN no_data_found THEN
                v_count := NULL;
        END;

        IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
            resultado := 0;
        ELSE
            resultado := 1;
        END IF;

        RETURN resultado;
    END existe_tipo_inventario;

    FUNCTION existe_articulo (
        pin_id_cia IN NUMBER,
        pin_tipinv IN INTEGER,
        pin_codart IN VARCHAR2
    ) RETURN INTEGER AS
        v_count   INTEGER := 0;
        resultado INTEGER := 0;
    BEGIN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_count
            FROM
                articulos
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND codart = pin_codart;

        EXCEPTION
            WHEN no_data_found THEN
                v_count := NULL;
        END;

        IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
            resultado := 0;
        ELSE
            resultado := 1;
        END IF;

        RETURN resultado;
    END existe_articulo;

    FUNCTION existe_clase_codigo (
        pin_id_cia IN NUMBER,
        pin_tipinv IN INTEGER,
        pin_clase  IN NUMBER,
        pin_codigo IN VARCHAR2
    ) RETURN INTEGER AS
        v_count   INTEGER := 0;
        resultado INTEGER := 0;
    BEGIN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_count
            FROM
                clase_codigo
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv
                AND clase = pin_clase
                AND codigo = pin_codigo;

        EXCEPTION
            WHEN no_data_found THEN
                v_count := NULL;
        END;

        IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
            resultado := 0;
        ELSE
            resultado := 1;
        END IF;

        RETURN resultado;
    END existe_clase_codigo;

    FUNCTION existe_tipo_control_stock (
        pin_id_cia IN NUMBER,
        pin_tipo   IN INTEGER
    ) RETURN INTEGER AS
        v_count   INTEGER := 0;
        resultado INTEGER := 0;
    BEGIN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_count
            FROM
                tipo_control_stock
            WHERE
                    id_cia = pin_id_cia
                AND tipo = pin_tipo;

        EXCEPTION
            WHEN no_data_found THEN
                v_count := NULL;
        END;

        IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
            resultado := 0;
        ELSE
            resultado := 1;
        END IF;

        RETURN resultado;
    END existe_tipo_control_stock;

    FUNCTION valida_articulo_v2 (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores  r_errores := r_errores(NULL, NULL, NULL, NULL);
        fila         NUMBER := 3;
        o            json_object_t;
        rec_articulo articulos%rowtype;
        v_aux        NUMBER := 0;
        v_codfam     VARCHAR2(20) := '';
        v_codlin     VARCHAR2(20) := '';
        v_codmar     VARCHAR2(20) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_articulo.id_cia := pin_id_cia;
        rec_articulo.tipinv := o.get_number('tipinv');
        rec_articulo.codart := o.get_string('codart');
        rec_articulo.descri := o.get_string('descri');
        rec_articulo.coduni := o.get_string('coduni');
        rec_articulo.consto := o.get_number('consto');
        rec_articulo.codprv := o.get_string('codprv');
        rec_articulo.wglosa := o.get_string('wglosa');
        rec_articulo.proart := o.get_string('proart');
        rec_articulo.faccon := o.get_number('faccon');
        IF rec_articulo.tipinv IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Tipo de inventario';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSE
            IF existe_tipo_inventario(pin_id_cia, rec_articulo.tipinv) = 0 THEN
                reg_errores.fila := fila;
                reg_errores.columna := 'Tipo de inventario';
                reg_errores.valor := to_char(rec_articulo.tipinv);
                reg_errores.deserror := 'No Existe';
                PIPE ROW ( reg_errores );
            END IF;
        END IF;

        IF rec_articulo.coduni IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Codigo de unidad';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSE
            IF existe_unidad_medida(pin_id_cia, rec_articulo.coduni) = 0 THEN
                reg_errores.fila := fila;
                reg_errores.columna := 'Codigo de unidad';
                reg_errores.valor := rec_articulo.coduni;
                reg_errores.deserror := 'No Existe';
                PIPE ROW ( reg_errores );
            END IF;
        END IF;

        IF rec_articulo.codart IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Codigo de articulo';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        END IF;

        IF rec_articulo.consto IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Codigo de control stock';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSE
            IF existe_tipo_control_stock(pin_id_cia, rec_articulo.consto) = 0 THEN
                reg_errores.fila := fila;
                reg_errores.columna := 'Codigo de control stock';
                reg_errores.valor := to_char(rec_articulo.consto);
                reg_errores.deserror := 'No Existe';
                PIPE ROW ( reg_errores );
            END IF;
        END IF;

        IF rec_articulo.codprv IS NOT NULL THEN
            BEGIN
                SELECT
                    0
                INTO v_aux
                FROM
                    cliente
                WHERE
                        id_cia = pin_id_cia
                    AND codcli = rec_articulo.codprv;

            EXCEPTION
                WHEN no_data_found THEN
                    reg_errores.fila := fila;
                    reg_errores.columna := 'Codigo Proveedor';
                    reg_errores.valor := to_char(rec_articulo.codprv);
                    reg_errores.deserror := 'No Existe';
                    PIPE ROW ( reg_errores );
            END;
        END IF;

    END valida_articulo_v2;

    PROCEDURE importa_articulos_v2 (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) AS
        o            json_object_t;
        rec_articulo articulos%rowtype;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_articulo.id_cia := pin_id_cia;
        rec_articulo.tipinv := o.get_number('tipinv');
        rec_articulo.codart := o.get_string('codart');
        rec_articulo.descri := o.get_string('descri');
        rec_articulo.coduni := o.get_string('coduni');
        rec_articulo.consto := o.get_number('consto');
        rec_articulo.codprv := o.get_string('codprv');
        rec_articulo.wglosa := o.get_string('wglosa');
        rec_articulo.proart := o.get_string('proart');
        rec_articulo.faccon := nvl(o.get_number('faccon'), 1);
        rec_articulo.codbar := o.get_string('codbar');
        rec_articulo.usuari := o.get_string('factua');
        BEGIN
            INSERT INTO articulos (
                id_cia,
                tipinv,
                codart,
                descri,
                codmar,
                codubi,
                codprc,
                codmod,
                modelo,
                codobs,
                coduni,
                codlin,
                codori,
                codfam,
                codbar,
                parara,
                proart,
                consto,
                codprv,
                agrupa,
                fmatri,
                usuari,
                swacti,
                wglosa,
                faccon,
                tusoesp,
                tusoing,
                diacmm,
                cuenta,
                conesp,
                linea,
                proint,
                codint,
                codope,
                situac,
                sim,
                tsystem,
                descri2,
                fcreac,
                factua
            ) VALUES (
                pin_id_cia,
                rec_articulo.tipinv,
                rec_articulo.codart,
                rec_articulo.descri,
                0,
                0,
                0,
                0,
                NULL,
                0,
                rec_articulo.coduni,
                0,
                '',
                0,
                rec_articulo.codbar,
                '',
                rec_articulo.proart,
                rec_articulo.consto,
                rec_articulo.codprv,
                'N',
                current_date,
                rec_articulo.usuari,
                'N',
                rec_articulo.wglosa,
                rec_articulo.faccon,
                0,
                0,
                0,
                '',
                0,
                NULL,
                NULL,
                NULL,
                0,
                NULL,
                NULL,
                NULL,
                NULL,
                current_timestamp,
                current_timestamp
            );

            COMMIT;
        EXCEPTION
            WHEN dup_val_on_index THEN
                UPDATE articulos
                SET
                    consto = nvl(rec_articulo.consto, consto),
                    faccon = nvl(rec_articulo.faccon, faccon),
                    descri = nvl(rec_articulo.descri, descri),
                    coduni = nvl(rec_articulo.coduni, coduni),
                    codprv = nvl(rec_articulo.codprv, codprv),
                    wglosa = nvl(rec_articulo.wglosa, wglosa),
                    proart = nvl(rec_articulo.proart, proart),
                    codbar = nvl(rec_articulo.codbar, codbar),
                    usuari = rec_articulo.usuari,
                    factua = current_timestamp
                WHERE
                        id_cia = pin_id_cia
                    AND tipinv = rec_articulo.tipinv
                    AND codart = rec_articulo.codart;

        END;

    END importa_articulos_v2;

END;

/
