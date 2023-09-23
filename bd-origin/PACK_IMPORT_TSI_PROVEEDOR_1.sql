--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_TSI_PROVEEDOR
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_TSI_PROVEEDOR" AS

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codtpe IN NUMBER
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        SELECT
            c.codcli,
            c.razonc,
            c.tident,
            c.dident,
            c.codtpe,
            c.direc1,
            c.direc2,
            c.telefono,
            c.fax,
            c.repres,
            c.codpagcom,
            c.regret,
            cc4.codigo AS clase4
        BULK COLLECT
        INTO v_table
        FROM
                 cliente c
            INNER JOIN cliente_clase                                                    cli ON cli.id_cia = c.id_cia
                                            AND cli.tipcli = 'A'
                                            AND cli.codcli = c.codcli
                                            AND cli.clase = 1
                                            AND cli.codigo = '1'
            LEFT OUTER JOIN cliente_tpersona                                                 tp ON tp.id_cia = c.id_cia
                                                   AND tp.codcli = c.codcli
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, 'A', c.codcli, 35) cc4 ON 0 = 0
        WHERE
                c.id_cia = pin_id_cia
            AND ( nvl(pin_codtpe, - 1) = - 1
                  OR c.codtpe = pin_codtpe );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION existe_proveedor (
        pin_id_cia IN NUMBER,
        pin_codcli IN VARCHAR2
    ) RETURN INTEGER AS
        v_count   INTEGER := 0;
        resultado INTEGER := 0;
    BEGIN
        BEGIN
            SELECT
                COUNT(c.codcli)
            INTO v_count
            FROM
                cliente c
            WHERE
                    c.id_cia = pin_id_cia
                AND c.codcli = pin_codcli;

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
    END existe_proveedor;

    FUNCTION existe_clase_cliente_codigo (
        pin_id_cia IN NUMBER,
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
                clase_cliente_codigo
            WHERE
                    id_cia = pin_id_cia
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
    END existe_clase_cliente_codigo;

    FUNCTION existe_identidad (
        pin_id_cia IN NUMBER,
        pin_tident IN VARCHAR2
    ) RETURN INTEGER AS
        v_count   INTEGER := 0;
        resultado INTEGER := 0;
    BEGIN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_count
            FROM
                identidad
            WHERE
                    id_cia = pin_id_cia
                AND tident = pin_tident;

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
    END existe_identidad;

    FUNCTION existe_t_persona (
        pin_id_cia IN NUMBER,
        pin_codtpe IN NUMBER
    ) RETURN INTEGER AS
        v_count   INTEGER := 0;
        resultado INTEGER := 0;
    BEGIN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_count
            FROM
                t_persona
            WHERE
                    id_cia = pin_id_cia
                AND codtpe = pin_codtpe;

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
    END existe_t_persona;

    FUNCTION existe_c_pago_compras (
        pin_id_cia IN NUMBER,
        pin_codpag IN NUMBER
    ) RETURN INTEGER AS
        v_count   INTEGER := 0;
        resultado INTEGER := 0;
    BEGIN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_count
            FROM
                c_pago_compras
            WHERE
                    id_cia = pin_id_cia
                AND codpag = pin_codpag;

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
    END existe_c_pago_compras;

    FUNCTION existe_regimen_retenciones (
        pin_id_cia IN NUMBER,
        pin_codigo IN NUMBER
    ) RETURN INTEGER AS
        v_count   INTEGER := 0;
        resultado INTEGER := 0;
    BEGIN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_count
            FROM
                regimen_retenciones
            WHERE
                    id_cia = pin_id_cia
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
    END existe_regimen_retenciones;

    FUNCTION valida_proveedor_v2 (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores r_errores := r_errores(NULL, NULL, NULL, NULL);
        fila        NUMBER := 3;
        o           json_object_t;
        rec         cliente%rowtype;
        v_clase4    VARCHAR2(20);
        v_direcc1   VARCHAR2(220);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec.id_cia := pin_id_cia;
        rec.codcli := o.get_string('codcli');
        rec.razonc := o.get_string('razonc');
        rec.tident := o.get_string('tident');
        rec.dident := o.get_string('dident');
        rec.codtpe := o.get_number('codtpe');
            -- rec.direc1 := o.get_string('direc1');
        v_direcc1 := o.get_string('direc1');
        rec.direc2 := o.get_string('direc2');
        rec.telefono := o.get_string('telefono');
        rec.fax := o.get_string('fax');
        rec.repres := o.get_string('repres');
        rec.codpagcom := o.get_number('codpagcom');
        rec.regret := o.get_number('regret');
        fila := fila + 1;
        IF rec.codcli IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Codigo de Proveedor';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSE
            IF ( length(rec.codcli) > 20 ) THEN
                reg_errores.fila := fila;
                reg_errores.columna := 'Codigo de Proveedor';
                reg_errores.valor := rec.codcli;
                reg_errores.deserror := 'Longitud del campo excede lo requerido';
                PIPE ROW ( reg_errores );
            END IF;
        END IF;

        IF rec.tident IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Tipo de identidad';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSE
            IF existe_identidad(pin_id_cia, rec.tident) = 0 THEN
                reg_errores.fila := fila;
                reg_errores.columna := 'Tipo de identidad';
                reg_errores.valor := rec.tident;
                reg_errores.deserror := 'No Existe';
                PIPE ROW ( reg_errores );
            END IF;
        END IF;

        IF rec.dident IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Documento de identidad';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        END IF;

        IF rec.codtpe IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Tipo de persona';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSE
            IF existe_t_persona(pin_id_cia, rec.codtpe) = 0 THEN
                reg_errores.fila := fila;
                reg_errores.columna := 'Tipo de persona';
                reg_errores.valor := rec.codtpe;
                reg_errores.deserror := 'No Existe ';
                PIPE ROW ( reg_errores );
            END IF;
        END IF;

        IF rec.codtpe IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Tipo de persona';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        END IF;

        IF v_direcc1 IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Dirección 1';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSIF ( length(v_direcc1) >= 100 ) THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Dirección 1';
            reg_errores.valor := v_direcc1;
            reg_errores.deserror := 'Longitud del campo excede lo requerido. Debe tener menor a 100 caracteres';
            PIPE ROW ( reg_errores );
        END IF;

        IF rec.codpagcom IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Condición de pago';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSE
            IF existe_c_pago_compras(pin_id_cia, rec.codpagcom) = 0 THEN
                reg_errores.fila := fila;
                reg_errores.columna := 'Condición de pago';
                reg_errores.valor := to_char(rec.codpagcom);
                reg_errores.deserror := 'No Existe';
                PIPE ROW ( reg_errores );
            END IF;
        END IF;

        IF rec.regret IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Tipo de retención';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSE
            IF existe_regimen_retenciones(pin_id_cia, rec.regret) = 0 THEN
                reg_errores.fila := fila;
                reg_errores.columna := 'Tipo de retención';
                reg_errores.valor := to_char(rec.regret);
                reg_errores.deserror := 'No Existe';
                PIPE ROW ( reg_errores );
            END IF;
        END IF;

    END valida_proveedor_v2;

    PROCEDURE importa_proveedor_v2 (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                json_object_t;
        rec              cliente%rowtype;
        v_clase4         VARCHAR2(20);
        v_cliente_existe VARCHAR2(20);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec.id_cia := pin_id_cia;
        rec.codcli := o.get_string('codcli');
        rec.razonc := o.get_string('razonc');
        rec.tident := o.get_string('tident');
        rec.dident := o.get_string('dident');
        rec.codtpe := o.get_number('codtpe');
        rec.direc1 := o.get_string('direc1');
        rec.direc2 := o.get_string('direc2');
        rec.telefono := o.get_string('telefono');
        rec.fax := o.get_string('fax');
        rec.repres := o.get_string('repres');
        rec.codpagcom := o.get_number('codpagcom');
        rec.regret := o.get_number('regret');
        BEGIN
            SELECT
                codcli
            INTO v_cliente_existe
            FROM
                cliente
            WHERE
                    id_cia = pin_id_cia
                AND codcli = rec.codcli;

            UPDATE cliente
            SET
                razonc = nvl(rec.razonc, razonc),
                direc1 = nvl(rec.direc1, direc1),
                telefono = nvl(rec.telefono, telefono),
                fax = nvl(rec.fax, fax),
                direc2 = nvl(rec.direc2, direc2),
                email = nvl(rec.email, email),
                factua = current_timestamp
            WHERE
                    id_cia = pin_id_cia
                AND codcli = rec.codcli;

        EXCEPTION
            WHEN no_data_found THEN
                INSERT INTO cliente (
                    id_cia,
                    codcli,
                    razonc,
                    tident,
                    dident,
                    direc1,
                    direc2,
                    email,
                    fax,
                    repres,
                    codtit,
                    codpag,
                    codpagcom,
                    codtso,
                    codreg,
                    codfid,
                    codsec,
                    codtne,
                    codzon,
                    coddep,
                    codprv,
                    coddis,
                    codvol,
                    codven,
                    ctacli,
                    ctapro,
                    tipcli,
                    codtpe,
                    regret,
                    telefono,
                    zondes,
                    dctofijo,
                    limcre1,
                    limcre2,
                    chedev,
                    letpro,
                    deuda1,
                    deuda2,
                    renova,
                    refina,
                    capsoc,
                    diamor,
                    fecing,
                    fcierre,
                    fconst,
                    situac,
                    usuari,
                    swacti,
                    codtitcom,
                    observ,
                    valident,
                    fcreac,
                    factua
                ) VALUES (
                    pin_id_cia,
                    rec.codcli,
                    rec.razonc,
                    rec.tident,
                    rec.dident,
                    rec.direc1,
                    rec.direc2,
                    NULL,
                    rec.fax,
                    rec.repres,
                    0,
                    0,
                    rec.codpagcom,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    NULL,
                    NULL,
                    NULL,
                    0,
                    0,
                    NULL,
                    NULL,
                    NULL,
                    rec.codtpe,
                    rec.regret,
                    rec.telefono,
                    NULL,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    current_date,
                    NULL,
                    NULL,
                    NULL,
                    'admin',
                    'N',
                    99999,
                    NULL,
                    'N',
                    current_timestamp,
                    current_timestamp
                );

        END;

        sp_inserta_clases_obligatorias_ic(pin_id_cia, 'B', rec.codcli);
        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'El proceso completó correctamente.'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
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
    END importa_proveedor_v2;

END;

/
