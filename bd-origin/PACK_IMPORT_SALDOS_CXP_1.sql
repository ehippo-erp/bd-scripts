--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_SALDOS_CXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_SALDOS_CXP" AS

    FUNCTION existe_numint (
        pin_id_cia IN NUMBER,
        pin_tipo   IN NUMBER,
        pin_docu   IN NUMBER
    ) RETURN INTEGER AS
        v_count    INTEGER := 0;
        v_response INTEGER := 0; -- 0 : false, 1 : true
    BEGIN
        BEGIN
            SELECT
                COUNT(c.docu)
            INTO v_count
            FROM
                prov100 c
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipo = pin_tipo
                AND c.docu = pin_docu;

        EXCEPTION
            WHEN no_data_found THEN
                v_count := NULL;
        END;

        IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
            v_response := 0;
        ELSE
            v_response := 1;
        END IF;

        RETURN v_response;
    END existe_numint;

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

    FUNCTION valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores r_errores := r_errores(NULL, NULL);
        fila        NUMBER := 3;
        o           json_object_t;
        rec_prov100 prov100%rowtype;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_prov100.id_cia := pin_id_cia;
        rec_prov100.tipo := o.get_number('tipo');
        rec_prov100.docu := o.get_number('docu');
        rec_prov100.codcli := o.get_string('codcli');
        rec_prov100.tipdoc := o.get_string('tipdoc');
        rec_prov100.docume := o.get_string('docume');
        rec_prov100.serie := o.get_string('serie');
        rec_prov100.numero := o.get_string('numero');
        rec_prov100.periodo := o.get_number('periodo');
        rec_prov100.mes := o.get_number('mes');
        rec_prov100.femisi := o.get_date('femisi');
        rec_prov100.fvenci := o.get_date('fvenci');
        rec_prov100.fcance := o.get_date('fcance');
        rec_prov100.codban := o.get_number('codban');
        rec_prov100.numbco := o.get_string('numbco');
        rec_prov100.refere01 := o.get_string('refere01');
        rec_prov100.refere02 := o.get_string('refere02');
        rec_prov100.tipmon := o.get_string('tipmon');
        rec_prov100.importe := o.get_number('importe');
        rec_prov100.importemn := o.get_number('importemn');
        rec_prov100.importeme := o.get_number('importeme');
        rec_prov100.saldo := o.get_number('saldo');
        rec_prov100.saldomn := o.get_number('saldomn');
        rec_prov100.saldome := o.get_number('saldome');
        rec_prov100.concpag := o.get_number('concpag');
        rec_prov100.codcob := o.get_number('codcob');
        rec_prov100.codven := o.get_number('codven');
        rec_prov100.comisi := o.get_number('comisi');
        rec_prov100.codsuc := o.get_number('codsuc');
        rec_prov100.cancelado := o.get_string('cancelado');
        rec_prov100.fcreac := current_timestamp;
        rec_prov100.factua := current_timestamp;
        rec_prov100.usuari := o.get_string('usuari');
        rec_prov100.situac := o.get_string('situac');
        rec_prov100.cuenta := o.get_string('cuenta');
        rec_prov100.dh := o.get_string('dh');
        rec_prov100.tipcam := o.get_number('tipcam');
        rec_prov100.operac := o.get_number('operac');
        rec_prov100.protes := o.get_number('protes');
        rec_prov100.xlibro := o.get_string('xlibro');
        rec_prov100.xperiodo := o.get_number('xperiodo');
        rec_prov100.xmes := o.get_number('xmes');
        rec_prov100.xsecuencia := o.get_number('xsecuencia');
        rec_prov100.codubi := o.get_number('codubi');
        rec_prov100.xprotesto := o.get_number('xprotesto');
        rec_prov100.codclir := o.get_string('codclir');
        rec_prov100.fvenci2 := o.get_date('fvenci2');
        IF rec_prov100.tipo IS NULL THEN
            reg_errores.valor := 'Vacio';
            reg_errores.deserror := 'Tipo es requerido.';
            PIPE ROW ( reg_errores );
        END IF;

        IF
            rec_prov100.tipo IS NOT NULL
            AND rec_prov100.docu IS NOT NULL
            AND rec_prov100.docu <> -1
        THEN
            IF existe_numint(pin_id_cia, rec_prov100.tipo, rec_prov100.docu) = 1 THEN
                reg_errores.valor := to_char(rec_prov100.tipo)
                                     || ' y '
                                     || to_char(rec_prov100.docu);

                reg_errores.deserror := 'Tipo y Número Interno del documento ya existe.';
                PIPE ROW ( reg_errores );
            END IF;
        END IF;

        IF rec_prov100.codcli IS NOT NULL THEN
            IF ( length(rec_prov100.codcli) > 20 ) THEN
                reg_errores.valor := rec_prov100.codcli;
                reg_errores.deserror := 'Codigo de cliente - Longitud del campo excede lo requerido';
                PIPE ROW ( reg_errores );
            ELSE
                IF existe_cliente(pin_id_cia, rec_prov100.codcli) = 0 THEN
                    reg_errores.valor := rec_prov100.codcli;
                    reg_errores.deserror := 'Codigo de cliente - No existe.';
                    PIPE ROW ( reg_errores );
                END IF;
            END IF;
        END IF;

        IF rec_prov100.tipdoc IS NULL THEN
            reg_errores.valor := 'Vacio';
            reg_errores.deserror := 'Tipo de Documento - Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSIF ( length(rec_prov100.tipdoc) > 2 ) THEN
            reg_errores.valor := rec_prov100.tipdoc;
            reg_errores.deserror := 'Tipo de Documento - Longitud del campo excede lo requerido';
        END IF;

        IF rec_prov100.serie IS NULL THEN
            reg_errores.valor := 'Vacio';
            reg_errores.deserror := 'Serie - Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSIF ( length(rec_prov100.serie) > 20 ) THEN
            reg_errores.valor := rec_prov100.serie;
            reg_errores.deserror := 'Tipo de Documento - Longitud del campo excede lo requerido';
        END IF;

        IF rec_prov100.docume IS NULL THEN
            reg_errores.valor := 'Vacio';
            reg_errores.deserror := 'Numero - Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSIF ( length(rec_prov100.docume) > 40 ) THEN
            reg_errores.valor := rec_prov100.docume;
            reg_errores.deserror := 'Tipo de Documento - Longitud del campo excede lo requerido';
        END IF;

    END valida_objeto;

    PROCEDURE importa_saldos (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) AS
        o           json_object_t;
        rec_prov100 prov100%rowtype;
        --rec_prov100_ori prov100_ori%rowtype;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_prov100.id_cia := pin_id_cia;
        rec_prov100.tipo := o.get_number('tipo');
        rec_prov100.docu := o.get_number('docu');
        IF rec_prov100.docu IS NULL OR rec_prov100.docu = -1 THEN
            BEGIN
                SELECT
                    nvl(MAX(p100.docu), 0)
                INTO rec_prov100.docu
                FROM
                    prov100 p100
                WHERE
                        p100.id_cia = pin_id_cia
                    AND p100.tipo = rec_prov100.tipo;

            EXCEPTION
                WHEN no_data_found THEN
                    rec_prov100.docu := 0;
            END;

            rec_prov100.docu := rec_prov100.docu + 1;
        END IF;

        rec_prov100.codcli := o.get_string('codcli');
        rec_prov100.tipdoc := o.get_string('tipdoc');
        rec_prov100.docume := o.get_string('docume');
        rec_prov100.serie := o.get_string('serie');
        rec_prov100.numero := o.get_string('numero');
        rec_prov100.periodo := o.get_number('periodo');
        rec_prov100.mes := o.get_number('mes');
        rec_prov100.femisi := o.get_date('femisi');
        rec_prov100.fvenci := o.get_date('fvenci');
        rec_prov100.fcance := o.get_date('fcance');
        rec_prov100.codban := o.get_number('codban');
        rec_prov100.numbco := o.get_string('numbco');
        rec_prov100.refere01 := o.get_string('refere01');
        rec_prov100.refere02 := o.get_string('refere02');
        rec_prov100.tipmon := o.get_string('tipmon');
        rec_prov100.importe := o.get_number('importe');
        rec_prov100.importemn := o.get_number('importemn');
        rec_prov100.importeme := o.get_number('importeme');
        rec_prov100.saldo := o.get_number('saldo');
        rec_prov100.saldomn := o.get_number('saldomn');
        rec_prov100.saldome := o.get_number('saldome');
        rec_prov100.concpag := o.get_number('concpag');
        rec_prov100.codcob := o.get_number('codcob');
        rec_prov100.codven := o.get_number('codven');
        rec_prov100.comisi := o.get_number('comisi');
        rec_prov100.codsuc := o.get_number('codsuc');
        rec_prov100.cancelado := o.get_string('cancelado');
        rec_prov100.fcreac := current_timestamp;
        rec_prov100.factua := current_timestamp;
        rec_prov100.usuari := o.get_string('usuari');
        rec_prov100.situac := o.get_string('situac');
        rec_prov100.cuenta := o.get_string('cuenta');
        rec_prov100.dh := o.get_string('dh');
        rec_prov100.tipcam := o.get_number('tipcam');
        rec_prov100.operac := o.get_number('operac');
        rec_prov100.protes := o.get_number('protes');
        rec_prov100.xlibro := o.get_string('xlibro');
        rec_prov100.xperiodo := o.get_number('xperiodo');
        rec_prov100.xmes := o.get_number('xmes');
        rec_prov100.xsecuencia := o.get_number('xsecuencia');
        rec_prov100.codubi := o.get_number('codubi');
        rec_prov100.xprotesto := o.get_number('xprotesto');
        rec_prov100.codclir := o.get_string('codclir');
        rec_prov100.fvenci2 := o.get_date('fvenci2');
        rec_prov100.swmigra := 'S';
        IF rec_prov100.tipmon = 'PEN' THEN
            rec_prov100.importemn := rec_prov100.importe;
        ELSE
            rec_prov100.importeme := rec_prov100.importe;
        END IF;

        IF rec_prov100.tipmon = 'PEN' THEN
            rec_prov100.saldomn := rec_prov100.saldo;
        ELSE
            rec_prov100.saldome := rec_prov100.saldo;
        END IF;

        INSERT INTO prov100 VALUES rec_prov100;

        COMMIT;
        sp_actualiza_saldo_prov100(pin_id_cia, rec_prov100.tipo, rec_prov100.docu);
    END importa_saldos;

END pack_import_saldos_cxp;

/
