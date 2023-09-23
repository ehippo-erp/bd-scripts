--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_TSI_CLIENTE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_TSI_CLIENTE" AS

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codtpe NUMBER
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        SELECT
            c.codcli,
            c.ctacli,
            c.razonc,
            c.tident,
            c.dident,
            c.direc1,
            c.telefono,
            c.fax,
            tp.apepat,
            tp.apemat,
            tp.nombre,
            c.direc2,
            c.codtpe,
            c.email,
            c.codven,
            c.observ,
            cc35.codigo AS cla_zona,
            cc10.codigo AS cla_pais,
            cc14.codigo AS cla_dep,
            cc15.codigo AS cla_pro,
            cc16.codigo AS cla_dis
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
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, 'A', c.codcli, 35) cc35 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, 'A', c.codcli, 10) cc10 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, 'A', c.codcli, 14) cc14 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, 'A', c.codcli, 15) cc15 ON 0 = 0
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(c.id_cia, 'A', c.codcli, 16) cc16 ON 0 = 0
        WHERE
                c.id_cia = pin_id_cia
            AND ( nvl(pin_codtpe, - 1) = - 1
                  OR c.codtpe = pin_codtpe );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION existe_cliente (
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
    END existe_cliente;

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

    FUNCTION existe_vendedor (
        pin_id_cia IN NUMBER,
        pin_codven IN VARCHAR2
    ) RETURN INTEGER AS
        v_count   INTEGER := 0;
        resultado INTEGER := 0;
    BEGIN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_count
            FROM
                vendedor
            WHERE
                    id_cia = pin_id_cia
                AND codven = pin_codven;

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
    END existe_vendedor;

    FUNCTION valida_cliente_v2 (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores r_errores := r_errores(NULL, NULL, NULL, NULL);
        fila        NUMBER := 3;
        o           json_object_t;
        rec_cliente cliente%rowtype;
        v_apepat    VARCHAR2(60);
        v_apemat    VARCHAR2(60);
        v_nombres   VARCHAR2(60);
        v_cla_zona  VARCHAR2(10);
        v_cla_pais  VARCHAR2(10);
        v_cla_dep   VARCHAR2(10);
        v_cla_pro   VARCHAR2(10);
        v_cla_dis   VARCHAR2(10);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_cliente.id_cia := pin_id_cia;
        rec_cliente.codcli := o.get_string('codcli');
        rec_cliente.ctacli := o.get_number('ctacli');
        rec_cliente.razonc := o.get_string('razonc');
        rec_cliente.tident := o.get_string('tident');
        rec_cliente.dident := o.get_string('dident');
        rec_cliente.direc1 := o.get_string('direc1');
        rec_cliente.telefono := o.get_string('telefono');
        rec_cliente.fax := o.get_string('fax');
        v_apepat := o.get_string('apepat');
        v_apemat := o.get_string('apemat');
        v_nombres := o.get_string('nombres');
        rec_cliente.direc2 := o.get_string('direc2');
        rec_cliente.codtpe := o.get_number('codtpe');
        rec_cliente.email := o.get_string('email');
        rec_cliente.codven := o.get_number('codven');
        rec_cliente.observ := o.get_string('observ');
        fila := fila + 1;
        IF rec_cliente.codcli IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Codigo de cliente';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSE
            IF ( length(rec_cliente.codcli) > 20 ) THEN
                reg_errores.fila := fila;
                reg_errores.columna := 'Codigo de cliente';
                reg_errores.valor := rec_cliente.codcli;
                reg_errores.deserror := 'Longitud del campo excede lo requerido';
                PIPE ROW ( reg_errores );
            END IF;
        END IF;

        IF rec_cliente.tident IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Tipo de identidad';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSE
            IF existe_identidad(pin_id_cia, rec_cliente.tident) = 0 THEN
                reg_errores.fila := fila;
                reg_errores.columna := 'Tipo de identidad';
                reg_errores.valor := rec_cliente.tident;
                reg_errores.deserror := 'No Existe';
                PIPE ROW ( reg_errores );
            END IF;
        END IF;

        IF rec_cliente.dident IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Documento de identidad';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        END IF;

        IF rec_cliente.codtpe IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Tipo de persona';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSE
            IF existe_t_persona(pin_id_cia, rec_cliente.codtpe) = 0 THEN
                reg_errores.fila := fila;
                reg_errores.columna := 'Tipo de persona';
                reg_errores.valor := rec_cliente.codtpe;
                reg_errores.deserror := 'ya Existe ';
                PIPE ROW ( reg_errores );
            END IF;
        END IF;

        IF rec_cliente.direc1 IS NULL THEN
            reg_errores.fila := fila;
            reg_errores.columna := 'Dirección 1';
            reg_errores.valor := 'vacio';
            reg_errores.deserror := 'Dato obligatorio';
            PIPE ROW ( reg_errores );
        END IF;

    END valida_cliente_v2;

    PROCEDURE importa_cliente_v2 (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_mensaje OUT VARCHAR2
    ) AS

        reg_errores      r_errores := r_errores(NULL, NULL, NULL, NULL);
        fila             NUMBER := 3;
        o                json_object_t;
        rec_cliente      cliente%rowtype;
        v_apepat         VARCHAR2(60);
        v_apemat         VARCHAR2(60);
        v_nombres        VARCHAR2(60);
        v_cliente_existe VARCHAR2(60);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_cliente.id_cia := pin_id_cia;
        rec_cliente.codcli := o.get_string('codcli');
        rec_cliente.ctacli := o.get_number('ctacli');
        rec_cliente.razonc := o.get_string('razonc');
        rec_cliente.tident := o.get_string('tident');
        rec_cliente.dident := o.get_string('dident');
        rec_cliente.direc1 := o.get_string('direc1');
        rec_cliente.telefono := o.get_string('telefono');
        rec_cliente.fax := o.get_string('fax');
        v_apepat := o.get_string('apellidopaterno');
        v_apemat := o.get_string('apeliidomaterno');
        v_nombres := o.get_string('nombres');
        rec_cliente.direc2 := o.get_string('direc2');
        rec_cliente.codtpe := o.get_number('codtpe');
        rec_cliente.email := o.get_string('email');
        rec_cliente.codven := o.get_number('codven');
        rec_cliente.observ := o.get_string('observ');
        rec_cliente.repres := NULL;
        rec_cliente.codtit := 1;
        rec_cliente.codpag := 1;
        rec_cliente.codpagcom := 0;
        rec_cliente.codtso := 0;
        rec_cliente.codreg := 0;
        rec_cliente.codfid := 0;
        rec_cliente.codsec := 0;
        rec_cliente.codtne := 0;
        rec_cliente.codzon := 0;
        rec_cliente.coddep := NULL;
        rec_cliente.codprv := NULL;
        rec_cliente.coddis := NULL;
        rec_cliente.codvol := 0;
        rec_cliente.ctacli := NULL;
        rec_cliente.ctapro := NULL;
        rec_cliente.tipcli := NULL;
        rec_cliente.regret := 0;
        rec_cliente.zondes := NULL;
        rec_cliente.dctofijo := 0;
        rec_cliente.limcre1 := 0;
        rec_cliente.limcre2 := 0;
        rec_cliente.chedev := 0;
        rec_cliente.letpro := 0;
        rec_cliente.deuda1 := 0;
        rec_cliente.deuda2 := 0;
        rec_cliente.renova := 0;
        rec_cliente.refina := 0;
        rec_cliente.capsoc := 0;
        rec_cliente.diamor := 0;
        rec_cliente.fecing := current_date;
        rec_cliente.fcreac := current_timestamp;
        rec_cliente.factua := current_timestamp;
        rec_cliente.fcierre := NULL;
        rec_cliente.fconst := NULL;
        rec_cliente.situac := NULL;
        rec_cliente.usuari := o.get_string('factua');
        rec_cliente.swacti := 'N';
        rec_cliente.codtitcom := 1;
        rec_cliente.valident := 'N';
        BEGIN
            SELECT
                codcli
            INTO v_cliente_existe
            FROM
                cliente
            WHERE
                    id_cia = pin_id_cia
                AND codcli = rec_cliente.codcli;

            UPDATE cliente
            SET
                razonc = nvl(rec_cliente.razonc, razonc),
                direc1 = nvl(rec_cliente.direc1, direc1),
                telefono = nvl(rec_cliente.telefono, telefono),
                fax = nvl(rec_cliente.fax, fax),
                direc2 = nvl(rec_cliente.direc2, direc2),
                email = nvl(rec_cliente.email, email),
                observ = nvl(rec_cliente.observ, observ),
                usuari = rec_cliente.usuari,
                factua = current_timestamp
            WHERE
                    id_cia = pin_id_cia
                AND codcli = rec_cliente.codcli;

            UPDATE cliente_tpersona
            SET
                apepat = nvl(v_apepat, apepat),
                apemat = nvl(v_apemat, apemat),
                nombre = nvl(v_nombres, nombre)
            WHERE
                    id_cia = pin_id_cia
                AND codcli = rec_cliente.codcli;

            COMMIT;
        EXCEPTION
            WHEN no_data_found THEN
                INSERT INTO cliente VALUES rec_cliente;

                INSERT INTO cliente_codpag (
                    id_cia,
                    codcli,
                    codpag,
                    fcreac,
                    factua,
                    usuari,
                    swdefaul,
                    swacti
                ) VALUES (
                    pin_id_cia,
                    rec_cliente.codcli,
                    1,
                    current_timestamp,
                    current_timestamp,
                    rec_cliente.usuari,
                    'S',
                    'S'
                );

                INSERT INTO clientes_almacen (
                    id_cia,
                    codcli,
                    codenv,
                    descri,
                    direc1,
                    direc2,
                    fcreac,
                    factua,
                    usuari,
                    swacti
                ) VALUES (
                    pin_id_cia,
                    rec_cliente.codcli,
                    1,
                    'CASA MATRIZ',
                    rec_cliente.direc1,
                    rec_cliente.direc2,
                    current_timestamp,
                    current_timestamp,
                    rec_cliente.usuari,
                    'S'
                );

                INSERT INTO cliente_tpersona (
                    id_cia,
                    codcli,
                    apepat,
                    apemat,
                    nombre,
                    sexo
                ) VALUES (
                    pin_id_cia,
                    rec_cliente.codcli,
                    v_apepat,
                    v_apemat,
                    v_nombres,
                    'M'
                );

        END;

        -- REVISANDO LA INSERSION Y/O ACTUALIZACION DE CLASES OBLIGATORIAS
        sp_inserta_clases_obligatorias_ic(pin_id_cia, 'A', rec_cliente.codcli);
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
    END importa_cliente_v2;

END;

/
