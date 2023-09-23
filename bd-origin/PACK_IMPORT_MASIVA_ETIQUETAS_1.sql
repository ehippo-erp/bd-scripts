--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_MASIVA_ETIQUETAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_MASIVA_ETIQUETAS" AS

    FUNCTION existe_etiqueta_k000 (
        pin_id_cia   IN NUMBER,
        pin_etiqueta IN VARCHAR2
    ) RETURN INTEGER AS
        v_count    INTEGER := 0;
        v_response INTEGER := 0; -- 0 : false, 1 : true
    BEGIN
        BEGIN
            SELECT
                COUNT(*)
            INTO v_count
            FROM
                kardex000 k
            WHERE
                    k.id_cia = pin_id_cia
                AND k.etiqueta = pin_etiqueta;

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
    END existe_etiqueta_k000;

    FUNCTION existe_etiqueta_k001 (
        pin_id_cia   IN NUMBER,
        pin_etiqueta IN VARCHAR2
    ) RETURN INTEGER AS
        v_count    INTEGER := 0;
        v_response INTEGER := 0; -- 0 : false, 1 : true
    BEGIN
        BEGIN
            SELECT
                COUNT(*)
            INTO v_count
            FROM
                kardex001 k
            WHERE
                    k.id_cia = pin_id_cia
                AND k.etiqueta = pin_etiqueta;

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
    END existe_etiqueta_k001;

    FUNCTION existe_guia_interna (
        pin_id_cia IN NUMBER,
        pin_series IN VARCHAR2,
        pin_numdoc IN NUMBER
    ) RETURN INTEGER AS
        v_count    INTEGER := 0;
        v_response INTEGER := 0; -- 0 : false, 1 : true
    BEGIN
        BEGIN
            SELECT
                COUNT(d.numint)
            INTO v_count
            FROM
                documentos_cab d
            WHERE
                    d.id_cia = pin_id_cia
                AND d.series = pin_series
                AND d.numdoc = pin_numdoc
                AND tipdoc = 103; -- GUIAS INTERNAS
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
    END existe_guia_interna;

    FUNCTION valida_objeto (
        pin_id_cia IN NUMBER,
        --pin_series IN VARCHAR2,
        --pin_numdoc IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        o            json_object_t;
        reg_errores  r_errores := r_errores(NULL, NULL);
        fila         NUMBER := 3;
        v_numint     NUMBER;
        v_etiqueta   VARCHAR2(200);
        v_nrocarrete VARCHAR2(200);
        v_lote       VARCHAR2(200);
        v_empalme    VARCHAR2(200);
        v_acabado    VARCHAR2(200);
        v_dam        VARCHAR2(200);
        v_placa      VARCHAR2(200);
        v_dam_item   NUMBER(38);
    BEGIN
        o := json_object_t.parse(pin_datos);
        v_etiqueta := o.get_string('etiqueta');
        v_nrocarrete := o.get_string('motor');
        v_lote := o.get_string('lote');
        v_empalme := o.get_string('empalme');
        v_acabado := o.get_string('chasis');
        v_dam := o.get_string('dam');
        --v_placa := o.get_string('placa');
        v_dam_item := o.get_number('dam_item');
        -- VALIDACIONES
        IF existe_etiqueta_k000(pin_id_cia, v_etiqueta) = 0 OR existe_etiqueta_k001(pin_id_cia, v_etiqueta) = 0 THEN
            IF
                existe_etiqueta_k000(pin_id_cia, v_etiqueta) = 0
                AND existe_etiqueta_k001(pin_id_cia, v_etiqueta) = 0
            THEN
                reg_errores.valor := 'Vacio';
                reg_errores.deserror := 'La Etiqueta - No existe, en el KARDEX000 y KARDEX001';
                PIPE ROW ( reg_errores );
            ELSIF existe_etiqueta_k001(pin_id_cia, v_etiqueta) = 0 THEN
                reg_errores.valor := 'Vacio';
                reg_errores.deserror := 'La Etiqueta - No existe, en el KARDEX000';
                PIPE ROW ( reg_errores );
            ELSIF existe_etiqueta_k001(pin_id_cia, v_etiqueta) = 0 THEN
                reg_errores.valor := 'Vacio';
                reg_errores.deserror := 'La Etiqueta - No existe, en el KARDEX001';
                PIPE ROW ( reg_errores );
            END IF;
        ELSIF v_etiqueta IS NULL THEN
            reg_errores.valor := 'Vacio';
            reg_errores.deserror := 'Etiqueta - Dato obligatorio';
            PIPE ROW ( reg_errores );
        ELSIF length(v_etiqueta) > 100 THEN
            reg_errores.valor := v_etiqueta;
            reg_errores.deserror := 'Etiqueta - Longitud del campo excede lo requerido';
            PIPE ROW ( reg_errores );
        END IF;
        -- VALIDACIONES, SECUNDARIAS
        IF length(v_lote) > 20 THEN
            reg_errores.valor := v_lote;
            reg_errores.deserror := 'Lote - Longitud del campo excede lo requerido';
            PIPE ROW ( reg_errores );
        END IF;

        IF length(v_nrocarrete) > 15 THEN
            reg_errores.valor := v_nrocarrete;
            reg_errores.deserror := 'Nrocarrete - Longitud del campo excede lo requerido';
            PIPE ROW ( reg_errores );
        END IF;

        IF length(v_empalme) > 20 THEN
            reg_errores.valor := v_empalme;
            reg_errores.deserror := 'Empalme - Longitud del campo excede lo requerido';
            PIPE ROW ( reg_errores );
        END IF;

        IF length(v_acabado) > 20 THEN
            reg_errores.valor := v_acabado;
            reg_errores.deserror := 'Acabado - Longitud del campo excede lo requerido';
            PIPE ROW ( reg_errores );
        END IF;

        IF length(v_dam) > 25 THEN
            reg_errores.valor := v_dam;
            reg_errores.deserror := 'DAM - Longitud del campo excede lo requerido';
            PIPE ROW ( reg_errores );
        END IF;

        /*IF length(v_placa) > 10 THEN
            reg_errores.valor := v_placa;
            reg_errores.deserror := 'Placa - Longitud del campo excede lo requerido';
            PIPE ROW ( reg_errores );
        END IF;*/

    END valida_objeto;

    PROCEDURE actualiza_campos_etiqueta (
        pin_id_cia IN NUMBER,
        --pin_series IN VARCHAR2,
        --pin_numdoc IN NUMBER,
        pin_datos  IN CLOB
    ) AS

        o            json_object_t;
        v_numint     NUMBER;
        v_etiqueta   VARCHAR2(100);
        v_nrocarrete VARCHAR2(15);
        v_lote       VARCHAR2(20);
        v_empalme    VARCHAR2(20);
        v_acabado    VARCHAR2(20);
        v_dam        VARCHAR2(25);
        v_placa      VARCHAR2(10);
        v_dam_item   NUMBER(38);
        v_combina    VARCHAR2(20);
        v_ancho      NUMBER(9, 3);
        v_largo      NUMBER(9, 3);
        v_diseno     VARCHAR2(20);
        v_fvenci     DATE;
        v_fmanuf     DATE;
    BEGIN
        o := json_object_t.parse(pin_datos);
        v_etiqueta := o.get_string('etiqueta');
        v_nrocarrete := o.get_string('motor');
        v_lote := o.get_string('lote');
        v_empalme := o.get_string('empalme');
        v_acabado := o.get_string('chasis');
        v_dam := o.get_string('dam');
        --v_placa := o.get_string('placa');
        v_dam_item := o.get_number('dam_item');
        v_combina := o.get_string('combina');
        v_ancho := o.get_number('ancho');
        v_largo := o.get_number('largo');
        v_diseno := o.get_string('diseno');
        v_fvenci := o.get_date('fvenci');
        v_fmanuf := o.get_date('fmanuf');

        --- TODO O NADA
        /*IF (
            v_nrocarrete IS NOT NULL
            AND v_lote IS NOT NULL
            AND v_empalme IS NOT NULL
            AND v_acabado IS NOT NULL
            AND v_dam IS NOT NULL
            AND v_dam_item IS NOT NULL
            AND v_combina IS NOT NULL
            AND v_largo IS NOT NULL
            AND v_ancho IS NOT NULL
            AND v_diseno IS NOT NULL
            AND v_fvenci IS NOT NULL
            AND v_fmanuf IS NOT NULL
        ) THEN*/

        -- EXTRAYENDO EL NUMERO INTERNO (KARDEX000) HABILITADO
        SELECT
            numint
        INTO v_numint
        FROM
            kardex000 k
        WHERE
                k.id_cia = pin_id_cia
            AND k.etiqueta = v_etiqueta;

        -- ACTUALIZANDO DOCUMENTOS_DET
        UPDATE documentos_det
        SET
            lote =
                CASE
                    WHEN v_lote IS NOT NULL THEN
                        v_lote
                    ELSE
                        lote
                END,
            nrocarrete =
                CASE
                    WHEN v_nrocarrete IS NOT NULL THEN
                        v_nrocarrete
                    ELSE
                        nrocarrete
                END,
            acabado =
                CASE
                    WHEN v_acabado IS NOT NULL THEN
                        v_acabado
                    ELSE
                        acabado
                END,
            empalme =
                CASE
                    WHEN v_empalme IS NOT NULL THEN
                        v_empalme
                    ELSE
                        empalme
                END,
            dam =
                CASE
                    WHEN v_dam IS NOT NULL THEN
                        v_dam
                    ELSE
                        dam
                END,
            dam_item =
                CASE
                    WHEN v_dam_item IS NOT NULL THEN
                        v_dam_item
                    ELSE
                        dam_item
                END,
            factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
            usuari = 'Admin'
        WHERE
                id_cia = pin_id_cia
            AND numint = v_numint
            AND etiqueta = v_etiqueta;

        COMMIT;
        -- ACTUALIZANDO KARDEX000  
        UPDATE kardex000
        SET
            dam =
                CASE
                    WHEN v_dam IS NOT NULL THEN
                        v_dam
                    ELSE
                        dam
                END,
            dam_item =
                CASE
                    WHEN v_dam_item IS NOT NULL THEN
                        v_dam_item
                    ELSE
                        dam_item
                END,
            /*placa =
                CASE
                    WHEN v_placa IS NOT NULL THEN
                        v_placa
                    ELSE
                        placa
                END,*/
            factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
            coduseractu = 'Admin'
        WHERE
                id_cia = pin_id_cia
            AND etiqueta = v_etiqueta;

        COMMIT;

        -- ACTUALIZANDO KARDEX001
        UPDATE kardex001
        SET
            lote =
                CASE
                    WHEN v_lote IS NOT NULL THEN
                        v_lote
                    ELSE
                        lote
                END,
            nrocarrete =
                CASE
                    WHEN v_nrocarrete IS NOT NULL THEN
                        v_nrocarrete
                    ELSE
                        nrocarrete
                END,
            acabado =
                CASE
                    WHEN v_acabado IS NOT NULL THEN
                        v_acabado
                    ELSE
                        acabado
                END,
            empalme =
                CASE
                    WHEN v_empalme IS NOT NULL THEN
                        v_empalme
                    ELSE
                        empalme
                END,
            combina =
                CASE
                    WHEN v_combina IS NOT NULL THEN
                        v_combina
                    ELSE
                        combina
                END,
            ancho =
                CASE
                    WHEN v_ancho IS NOT NULL THEN
                        v_ancho
                    ELSE
                        ancho
                END,
            largo =
                CASE
                    WHEN v_largo IS NOT NULL THEN
                        v_largo
                    ELSE
                        largo
                END,
            diseno =
                CASE
                    WHEN v_diseno IS NOT NULL THEN
                        v_diseno
                    ELSE
                        diseno
                END,
            fvenci =
                CASE
                    WHEN v_fvenci IS NOT NULL THEN
                        v_fvenci
                    ELSE
                        fvenci
                END,
            fmanuf =
                CASE
                    WHEN v_fmanuf IS NOT NULL THEN
                        v_fmanuf
                    ELSE
                        fmanuf
                END
        WHERE
                id_cia = pin_id_cia
            AND etiqueta = v_etiqueta;

        COMMIT;
    END actualiza_campos_etiqueta;

    FUNCTION mostrar_campos_etiqueta (
        pin_id_cia IN NUMBER,
        pin_series IN VARCHAR2,
        pin_numdoc IN NUMBER
    ) RETURN datatable_campos_etiqueta
        PIPELINED
    AS
        v_table   datatable_campos_etiqueta;
        v_numint  NUMBER;
        v_mensaje VARCHAR2(500);
    BEGIN
        IF existe_guia_interna(pin_id_cia, pin_series, pin_numdoc) = 0 THEN
            v_mensaje := 'No existen guias internas para la serie '
                         || pin_series
                         || 'y para el numero de documentos '
                         || to_char(pin_numdoc);
        ELSE
            v_mensaje := 'Exportando guias internas para la serie '
                         || pin_series
                         || 'y para el numero de documentos '
                         || to_char(pin_numdoc); 
         --- EXTRAYENDO EL NUMERO INTERNO (DOCUMENTOS_CAB) DESCONTINUADO 
            SELECT
                numint
            INTO v_numint
            FROM
                documentos_cab c
            WHERE
                    id_cia = pin_id_cia
                AND series = pin_series
                AND numdoc = pin_numdoc
                AND tipdoc = 103; -- GUIAS INTERNAS

            SELECT
                d.tipinv,
                d.codart,
                a.descri   AS desart,
                d.etiqueta,
                k1.lote,
                k1.nrocarrete,
                k1.acabado,
                k1.empalme,
                k0.dam,
                k0.dam_item,
                k0.placa,
                k1.combina AS coombinacion,
                k1.ancho,
                k1.largo,
                k1.diseno,
                k1.fvenci,
                k1.fmanuf
            BULK COLLECT
            INTO v_table
            FROM
                documentos_det d
                LEFT OUTER JOIN articulos      a ON a.id_cia = d.id_cia
                                               AND a.codart = d.codart
                                               AND a.tipinv = d.tipinv
                LEFT OUTER JOIN kardex000      k0 ON k0.id_cia = d.id_cia
                                                AND k0.etiqueta = d.etiqueta
                LEFT OUTER JOIN kardex001      k1 ON k1.id_cia = d.id_cia
                                                AND k1.etiqueta = d.etiqueta
            WHERE
                    d.id_cia = pin_id_cia
                AND d.numint = v_numint
            ORDER BY
                etiqueta DESC;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        END IF;
    END mostrar_campos_etiqueta;

END pack_import_masiva_etiquetas;

/
