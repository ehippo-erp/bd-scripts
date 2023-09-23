--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_SALDOS_CXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_SALDOS_CXC" AS

    FUNCTION existe_numint (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN INTEGER AS
        v_count    INTEGER := 0;
        v_response INTEGER := 0; -- 0 : false, 1 : true
    BEGIN
        BEGIN
            SELECT
                COUNT(c.codcli)
            INTO v_count
            FROM
                dcta100 c
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numint = pin_numint;

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
        rec_dcta100 dcta100%rowtype;
    BEGIN
    -- TAREA: Se necesita implantación para FUNCTION PACK_IMPORT_SALDOS_CXC.valida_objeto
        o := json_object_t.parse(pin_datos);
        rec_dcta100.id_cia := pin_id_cia;
        rec_dcta100.numint := o.get_number('numint');
        rec_dcta100.codcli := o.get_string('codcli');
        rec_dcta100.tipdoc := o.get_number('tipdoc');
        rec_dcta100.docume := o.get_string('docume');
        rec_dcta100.serie := o.get_string('serie');
        rec_dcta100.numero := o.get_string('numero');
        rec_dcta100.periodo := o.get_number('periodo');
        rec_dcta100.mes := o.get_number('mes');
        rec_dcta100.femisi := o.get_date('femisi');
        rec_dcta100.fvenci := o.get_date('fvenci');
        rec_dcta100.fcance := o.get_date('fcance');
        rec_dcta100.codban := o.get_number('codban');
        rec_dcta100.numbco := o.get_string('numbco');
        rec_dcta100.refere01 := o.get_string('refere01');
        rec_dcta100.refere02 := o.get_string('refere02');
        rec_dcta100.tipmon := o.get_string('tipmon');
        rec_dcta100.importe := o.get_number('importe');
        rec_dcta100.importemn := o.get_number('importemn');
        rec_dcta100.importeme := o.get_number('importeme');
        rec_dcta100.saldo := o.get_number('saldo');
        rec_dcta100.saldomn := o.get_number('saldomn');
        rec_dcta100.saldome := o.get_number('saldome');
        rec_dcta100.concpag := o.get_number('concpag');
        rec_dcta100.codcob := o.get_number('codcob');
        rec_dcta100.codven := o.get_number('codven');
        rec_dcta100.comisi := o.get_number('comisi');
        rec_dcta100.codsuc := o.get_number('codsuc');
        rec_dcta100.cancelado := o.get_string('cancelado');
        rec_dcta100.fcreac := o.get_date('fcreac');
        rec_dcta100.factua := o.get_date('factua');
        rec_dcta100.usuari := o.get_string('usuari');
        rec_dcta100.situac := o.get_string('situac');
        rec_dcta100.cuenta := o.get_string('cuenta');
        rec_dcta100.dh := o.get_string('dh');
        rec_dcta100.tipcam := o.get_number('tipcam');
        rec_dcta100.operac := o.get_number('operac');
        rec_dcta100.protes := o.get_number('protes');
        rec_dcta100.xlibro := o.get_string('xlibro');
        rec_dcta100.xperiodo := o.get_number('xperiodo');
        rec_dcta100.xmes := o.get_number('xmes');
        rec_dcta100.xsecuencia := o.get_number('xsecuencia');
        rec_dcta100.codubi := o.get_number('codubi');
        rec_dcta100.xprotesto := o.get_number('xprotesto');
        rec_dcta100.tercero := o.get_number('tercero');
        rec_dcta100.codterc := o.get_string('codterc');
        rec_dcta100.codacep := o.get_string('codacep');
        IF rec_dcta100.numint IS NULL THEN
            reg_errores.valor := 'Vacio';
            reg_errores.deserror := 'Número interno es requerido.';
            PIPE ROW ( reg_errores );
        ELSIF existe_numint(pin_id_cia, rec_dcta100.numint) = 1 THEN
            reg_errores.valor := rec_dcta100.numint;
            reg_errores.deserror := 'Número interno ya existe.';
            PIPE ROW ( reg_errores );
        END IF;

        IF rec_dcta100.codcli IS NULL THEN
            reg_errores.valor := 'Vacio';
            reg_errores.deserror := 'Codigo de cliente - Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSE
            IF ( length(rec_dcta100.codcli) > 20 ) THEN
                reg_errores.valor := rec_dcta100.codcli;
                reg_errores.deserror := 'Codigo de cliente - Longitud del campo excede lo requerido';
                PIPE ROW ( reg_errores );
            ELSE
                IF existe_cliente(pin_id_cia, rec_dcta100.codcli) = 0 THEN
                    reg_errores.valor := rec_dcta100.codcli;
                    reg_errores.deserror := 'Codigo de cliente - No existe.';
                    PIPE ROW ( reg_errores );
                END IF;
            END IF;
        END IF;

    END valida_objeto;

    PROCEDURE importa_saldos (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) AS
        o               json_object_t;
        rec_dcta100     dcta100%rowtype;
        rec_dcta100_ori dcta100_ori%rowtype;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_dcta100.id_cia := pin_id_cia;
        rec_dcta100.numint := o.get_number('numint');
        rec_dcta100.codcli := o.get_string('codcli');
        rec_dcta100.tipdoc := o.get_number('tipdoc');
        rec_dcta100.docume := o.get_string('docume');
        rec_dcta100.serie := o.get_string('serie');
        rec_dcta100.numero := o.get_string('numero');
        rec_dcta100.periodo := o.get_number('periodo');
        rec_dcta100.mes := o.get_number('mes');
        rec_dcta100.femisi := o.get_date('femisi');
        rec_dcta100.fvenci := o.get_date('fvenci');
        rec_dcta100.fcance := o.get_date('fcance');
        rec_dcta100.codban := o.get_number('codban');
        rec_dcta100.numbco := o.get_string('numbco');
        rec_dcta100.refere01 := o.get_string('refere01');
        rec_dcta100.refere02 := o.get_string('refere02');
        rec_dcta100.tipmon := o.get_string('tipmon');
        rec_dcta100.importe := o.get_number('importe');
        rec_dcta100.importemn := o.get_number('importemn');
        rec_dcta100.importeme := o.get_number('importeme');
        rec_dcta100.saldo := o.get_number('saldo');
        rec_dcta100.saldomn := o.get_number('saldomn');
        rec_dcta100.saldome := o.get_number('saldome');
        rec_dcta100.concpag := o.get_number('concpag');
        rec_dcta100.codcob := o.get_number('codcob');
        rec_dcta100.codven := o.get_number('codven');
        rec_dcta100.comisi := o.get_number('comisi');
        rec_dcta100.codsuc := o.get_number('codsuc');
        rec_dcta100.cancelado := o.get_string('cancelado');
        rec_dcta100.fcreac := current_timestamp;
        rec_dcta100.factua := current_timestamp;
        rec_dcta100.usuari := o.get_string('usuari');
        rec_dcta100.situac := o.get_string('situac');
        rec_dcta100.cuenta := o.get_string('cuenta');
        rec_dcta100.dh := o.get_string('dh');
        rec_dcta100.tipcam := o.get_number('tipcam');
        rec_dcta100.operac := o.get_number('operac');
        rec_dcta100.protes := o.get_number('protes');
        rec_dcta100.xlibro := o.get_string('xlibro');
        rec_dcta100.xperiodo := o.get_number('xperiodo');
        rec_dcta100.xmes := o.get_number('xmes');
        rec_dcta100.xsecuencia := o.get_number('xsecuencia');
        rec_dcta100.codubi := o.get_number('codubi');
        rec_dcta100.xprotesto := o.get_number('xprotesto');
        rec_dcta100.tercero := o.get_number('tercero');
        rec_dcta100.codterc := o.get_string('codterc');
        rec_dcta100.codacep := o.get_string('codacep');
        rec_dcta100.swmigra := 'S';
        IF rec_dcta100.tipmon = 'PEN' THEN
            rec_dcta100.importemn := rec_dcta100.importe;
        ELSE
            rec_dcta100.importeme := rec_dcta100.importe;
        END IF;

        IF rec_dcta100.tipmon = 'PEN' THEN
            rec_dcta100.saldomn := rec_dcta100.saldo;
        ELSE
            rec_dcta100.saldome := rec_dcta100.saldo;
        END IF;

        IF rec_dcta100.tipdoc = 5 THEN
            rec_dcta100.docume := rec_dcta100.numero;
        ELSE
            rec_dcta100.docume := rec_dcta100.serie
                                  || sp000_ajusta_string(rec_dcta100.numero, 7, '0', 'R');
        END IF;

        IF rec_dcta100.codubi IS NULL THEN
            rec_dcta100.codubi := 1.0;
        END IF;

        INSERT INTO dcta100 VALUES rec_dcta100;

        COMMIT;


        -- INSERTA EN DCTA100_ORI POR TRIGGER
        /* 
        rec_dcta100_ori.id_cia := pin_id_cia;
        rec_dcta100_ori.numint := rec_dcta100.numint;
        rec_dcta100_ori.operac := rec_dcta100.operac;
        rec_dcta100_ori.codban := rec_dcta100.codban;
        rec_dcta100_ori.numbco := null;
        rec_dcta100_ori.protes := rec_dcta100.protes;
        rec_dcta100_ori.saldo := rec_dcta100.saldo;

        insert into dcta100_ori values rec_dcta100_ori;
        COMMIT; 
        */

        UPDATE dcta100_ori
        SET
            saldo = rec_dcta100.saldo
        WHERE
                id_cia = pin_id_cia
            AND numint = rec_dcta100.numint;

        COMMIT;
        sp_actualiza_saldo_dcta100(pin_id_cia, rec_dcta100.numint);
    END importa_saldos;

END pack_import_saldos_cxc;

/
