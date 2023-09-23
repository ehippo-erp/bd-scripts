--------------------------------------------------------
--  DDL for Package Body PACK_VALIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_VALIDA" AS

    FUNCTION envioctactefacturaboleta (
        pin_id_cia IN NUMBER,
        pin_doccab IN VARCHAR2
    ) RETURN datatable
        PIPELINED
    AS

        rec              datarecord;
        o                json_object_t;
        v_cliente_clase4 VARCHAR2(220);
        v_factor216      NUMBER;
        v_motivo_clase8  NUMBER;
        v_motivo_clase28 NUMBER;
        rec_doccab       documentos_cab%rowtype;
    BEGIN
    -- TAREA: Se necesita implantación para FUNCTION PACK_VALIDA.envioCtaCteFacturaBoleta
        o := json_object_t.parse(pin_doccab);
        rec_doccab.id_cia := pin_id_cia;
        rec_doccab.numint := o.get_number('numint');
        rec_doccab.tipdoc := o.get_number('tipdoc');
        rec_doccab.series := o.get_string('series');
        rec_doccab.numdoc := o.get_number('numdoc');
        rec_doccab.femisi := o.get_date('femisi');
        rec_doccab.lugemi := o.get_number('lugemi');
        rec_doccab.situac := o.get_string('situac');
        rec_doccab.id := o.get_string('id');
        rec_doccab.codmot := o.get_number('codmot');
        rec_doccab.motdoc := o.get_number('motdoc');
        rec_doccab.codalm := o.get_number('codalm');
        rec_doccab.almdes := o.get_number('almdes');
        rec_doccab.codcli := o.get_string('codcli');
        rec_doccab.tident := o.get_string('tident');
        rec_doccab.ruc := o.get_string('ruc');
        rec_doccab.razonc := o.get_string('razonc');
        rec_doccab.direc1 := o.get_string('direc1');
        rec_doccab.codenv := o.get_number('codenv');
        rec_doccab.codcpag := o.get_number('codcpag');
        rec_doccab.codtra := o.get_number('codtra');
        rec_doccab.codven := o.get_number('codven');
        rec_doccab.comisi := o.get_number('comisi');
        rec_doccab.incigv := o.get_string('incigv');
        rec_doccab.destin := o.get_number('destin');
        rec_doccab.totbru := o.get_number('totbru');
        rec_doccab.descue := o.get_number('descue');
        rec_doccab.desesp := o.get_number('desesp');
        rec_doccab.monafe := o.get_number('monafe');
        rec_doccab.monina := o.get_number('monina');
        rec_doccab.porigv := o.get_number('porigv');
        rec_doccab.monigv := o.get_number('monigv');
        rec_doccab.preven := o.get_number('preven');
        rec_doccab.costo := o.get_number('costo');
        rec_doccab.tipmon := o.get_string('tipmon');
        rec_doccab.tipcam := o.get_number('tipcam');
        rec_doccab.observ := o.get_string('observ');
        rec_doccab.atenci := o.get_string('atenci');
        rec_doccab.valide := o.get_string('valide');
        rec_doccab.plaent := o.get_string('plaent');
        rec_doccab.ordcom := o.get_string('ordcom');
        rec_doccab.numped := o.get_string('numped');
        rec_doccab.gasvin := o.get_number('gasvin');
        rec_doccab.seguro := o.get_number('seguro');
        rec_doccab.flete := o.get_number('flete');
        rec_doccab.desfle := o.get_string('desfle');
        rec_doccab.desexp := o.get_number('desexp');
        rec_doccab.gasadu := o.get_number('gasadu');
        rec_doccab.pesbru := o.get_number('pesbru');
        rec_doccab.pesnet := o.get_number('pesnet');
        rec_doccab.bultos := o.get_number('bultos');
        rec_doccab.presen := o.get_string('presen');
        rec_doccab.marcas := o.get_string('marcas');
        rec_doccab.numdue := o.get_string('numdue');
        rec_doccab.fnumdue := o.get_date('fnumdue');
        rec_doccab.fembarq := o.get_date('fembarq');
        rec_doccab.fentreg := o.get_date('fentreg');
        rec_doccab.valfob := o.get_number('valfob');
        rec_doccab.guipro := o.get_string('guipro');
        rec_doccab.fguipro := o.get_date('fguipro');
        rec_doccab.facpro := o.get_string('facpro');
        rec_doccab.ffacpro := o.get_date('ffacpro');
        rec_doccab.cargo := o.get_string('cargo');
        rec_doccab.codsuc := o.get_number('codsuc');
        rec_doccab.fcreac := o.get_date('fcreac');
        rec_doccab.factua := o.get_date('factua');
        rec_doccab.acuenta := o.get_number('acuenta');
        rec_doccab.ucreac := o.get_string('ucreac');
        rec_doccab.usuari := o.get_string('usuari');
        rec_doccab.swacti := o.get_string('swacti');
        rec_doccab.codarea := o.get_number('codarea');
        rec_doccab.coduso := o.get_number('coduso');
        rec_doccab.opnumdoc := o.get_number('opnumdoc');
        rec_doccab.opcargo := o.get_string('opcargo');
        rec_doccab.opnumite := o.get_number('opnumite');
        rec_doccab.opcodart := o.get_string('opcodart');
        rec_doccab.optipinv := o.get_number('optipinv');
        rec_doccab.totcan := o.get_number('totcan');
        rec_doccab.fordcom := o.get_date('fordcom');
        rec_doccab.ordcomni := o.get_number('ordcomni');
        rec_doccab.motvarios := o.get_number('motvarios');
        rec_doccab.horing := o.get_date('horing');
        rec_doccab.fecter := o.get_date('fecter');
        rec_doccab.horter := o.get_date('horter');
        rec_doccab.codtec := o.get_number('codtec');
        rec_doccab.guiarefe := o.get_string('guiarefe');
        rec_doccab.desenv := o.get_string('desenv');
        rec_doccab.codaux := o.get_string('codaux');
        rec_doccab.codetapauso := o.get_number('codetapauso');
        rec_doccab.codsec := o.get_number('codsec');
        rec_doccab.numvale := o.get_number('numvale');
        rec_doccab.fecvale := o.get_date('fecvale');
        rec_doccab.swtrans := o.get_number('swtrans');
        rec_doccab.desseg := o.get_string('desseg');
        rec_doccab.desgasa := o.get_string('desgasa');
        rec_doccab.desnetx := o.get_string('desnetx');
        rec_doccab.despreven := o.get_string('despreven');
        rec_doccab.codcob := o.get_number('codcob');
        rec_doccab.codveh := o.get_number('codveh');
        rec_doccab.codpunpar := o.get_number('codpunpar');
        rec_doccab.ubigeopar := o.get_string('ubigeopar');
        rec_doccab.direccpar := o.get_string('direccpar');
        rec_doccab.monisc := o.get_number('monisc');
        rec_doccab.monexo := o.get_number('monexo');
        rec_doccab.monotr := o.get_number('monotr');
        ------------------------------------------
        -- VERIFICA ASIGNACIÓN DE CLASE 4 (CLIENTE RELACIONADO - 70) DE CLIENTE 
        DECLARE BEGIN
            SELECT
                codigo
            INTO v_cliente_clase4
            FROM
                cliente_clase
            WHERE
                    id_cia = pin_id_cia
                AND tipcli = 'A'
                AND codcli = rec_doccab.codcli
                AND clase = 4
                AND codigo <> 'ND'
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                v_cliente_clase4 := NULL;
        END;

        IF v_cliente_clase4 IS NULL THEN
            rec.codigo := '1.1';
            rec.descripcion := 'El cliente no tiene asignado la clase 4';
            PIPE ROW ( rec );
        END IF;

    -----------------------------------------
    -- VERIFICAR EL PROCESO DE FACTURACIÓN 216 - PROCESO DE FACTURACION
        DECLARE BEGIN
            SELECT
                codfac
            INTO v_factor216
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 216
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                v_factor216 := NULL;
        END;

        IF v_factor216 IS NULL THEN
            rec.codigo := '1.1';
            rec.descripcion := 'Debe configurar el proceso de facturación en el factor: 216';
            PIPE ROW ( rec );
        END IF;

    ------------------------------------------------------
    -- VERIFICAR CLASE 8 (VERIFICAR LIMITE DE CREDITO) DEL MOTIVO DE COMPROBANTE 
        DECLARE BEGIN
            SELECT
                codigo
            INTO v_motivo_clase8
            FROM
                motivos_clase
            WHERE
                    id_cia = pin_id_cia
                AND tipdoc = rec_doccab.tipdoc
                AND id = rec_doccab.id
                AND codmot = rec_doccab.codmot
                AND codigo = 8
            ORDER BY
                codigo ASC;

        EXCEPTION
            WHEN no_data_found THEN
                v_motivo_clase8 := NULL;
        END;

        IF v_motivo_clase8 IS NULL THEN
            rec.codigo := '1.1';
            rec.descripcion := 'Debe asignar la clase 8 al motivo';
            PIPE ROW ( rec );
        END IF;

    ------------------------------------------------------
    -- VERIFICAR CLASE 28 (Enviar al kardex en facturación ó guía de remisión) DEL MOTIVO DE COMPROBANTE
        DECLARE BEGIN
            SELECT
                codigo
            INTO v_motivo_clase28
            FROM
                motivos_clase
            WHERE
                    id_cia = pin_id_cia
                AND tipdoc = rec_doccab.tipdoc
                AND id = rec_doccab.id
                AND codmot = rec_doccab.codmot
                AND codigo = 28
            ORDER BY
                codigo ASC;

        EXCEPTION
            WHEN no_data_found THEN
                v_motivo_clase28 := NULL;
        END;

        IF v_motivo_clase28 IS NULL THEN
            rec.codigo := '1.1';
            rec.descripcion := 'Debe asignar la clase 28 al motivo';
            PIPE ROW ( rec );
        END IF;    

    -----------------------------------
    -- VERIFICA EL MES CERRADO PARA EL PERIODO CONTABLE
        FOR i IN (
            SELECT
                *
            FROM
                TABLE ( mescerrado(pin_id_cia, 3, EXTRACT(YEAR FROM rec_doccab.femisi), EXTRACT(MONTH FROM rec_doccab.femisi)) )
        ) LOOP
            rec.codigo := i.codigo;
            rec.descripcion := i.descripcion;
            PIPE ROW ( rec );
        END LOOP;


    --------------------------------------------------
    --- -valida_Tope_Boletas

        FOR i IN (
            SELECT
                *
            FROM
                TABLE ( topeboletas(pin_id_cia, rec_doccab.tipdoc, rec_doccab.tident, rec_doccab.ruc, rec_doccab.preven) )
        ) LOOP
            rec.codigo := i.codigo;
            rec.descripcion := i.descripcion;
            PIPE ROW ( rec );
        END LOOP;   


      ----------------------------------------------------
      ----  validaIgvDocumento
        FOR i IN (
            SELECT
                *
            FROM
                TABLE ( igvdocumento(pin_id_cia, rec_doccab.porigv, rec_doccab.monafe, rec_doccab.preven, rec_doccab.monotr,
                                     rec_doccab.monisc, rec_doccab.monigv,rec_doccab.monina, rec_doccab.monexo ) )
        ) LOOP
            rec.codigo := i.codigo;
            rec.descripcion := i.descripcion;
            PIPE ROW ( rec );
        END LOOP;   



      ----------------------------------------------------
      -- clienteCredito_verify
        FOR i IN (
            SELECT
                *
            FROM
                TABLE ( clientecredito_verify(pin_id_cia, rec_doccab.codcli) )
        ) LOOP
            rec.codigo := i.codigo;
            rec.descripcion := i.descripcion;
            PIPE ROW ( rec );
        END LOOP;   

      ----------------------------------------------------
      -- validaEnvioCtaClase87


      ----------------------------------------------------
      -- dcabcorrelativo_validaFemisi
        FOR i IN (
            SELECT
                *
            FROM
                TABLE ( dcabcorrelativo_validafemisi(pin_id_cia, rec_doccab.tipdoc, rec_doccab.series, rec_doccab.numdoc, rec_doccab.
                femisi,
                                                     1) )
        ) LOOP
            rec.codigo := i.codigo;
            rec.descripcion := i.descripcion;
            PIPE ROW ( rec );
        END LOOP;   




      ----------------------------------------------------
      -- valida_TIdent_Ruc
        FOR i IN (
            SELECT
                *
            FROM
                TABLE ( valida_tident_ruc(pin_id_cia, rec_doccab.tipdoc, rec_doccab.tident, rec_doccab.ruc, rec_doccab.destin,
                                          rec_doccab.direc1) )
        ) LOOP
            rec.codigo := i.codigo;
            rec.descripcion := i.descripcion;
            PIPE ROW ( rec );
        END LOOP;   



        ----------------------------------------------------
      -- retornaItemsXNumint
        FOR i IN (
            SELECT
                *
            FROM
                TABLE ( retornaitemsxnumint(pin_id_cia, rec_doccab.numint, rec_doccab.tipdoc, rec_doccab.series) )
        ) LOOP
            rec.codigo := i.codigo;
            rec.descripcion := i.descripcion;
            PIPE ROW ( rec );
        END LOOP;   
         ----------------------------------------------------
      -- verificar_cantidades_saldos_articulo

    END envioctactefacturaboleta;

    FUNCTION documentocajatienda (
        pin_id_cia IN NUMBER,
        pin_doccab IN VARCHAR2
    ) RETURN datatable
        PIPELINED
    AS
        rec datarecord;
    BEGIN



    -- TAREA: Se necesita implantación para FUNCTION PACK_VALIDA.documentoCajaTienda
        PIPE ROW ( rec );
    END documentocajatienda;

    FUNCTION documentorelacionado (
        pin_id_cia     IN NUMBER,
        pin_numint_rel IN NUMBER
    ) RETURN datatable
        PIPELINED
    AS

        rec             datarecord;
        v_cantitems_rel NUMBER := 0;
        v_descdocumento VARCHAR2(30) := '';
        jo              json_object_t;
    BEGIN



    -- TAREA: Se necesita implantación para FUNCTION PACK_VALIDA.documentoRelacionado
        FOR i IN (
            SELECT
                c.numint,
                CAST(c.tipdoc AS NUMBER) AS tipdoc,
                c.series,
                c.numdoc,
                c.situac,
                (
                    SELECT
                        COUNT(1)
                    FROM
                        documentos_det
                    WHERE
                            id_cia = c.id_cia
                        AND numint = c.numint
                )                        AS cantitems
            FROM
                documentos_cab c
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numint = pin_numint_rel
        ) LOOP
            CASE
                WHEN i.tipdoc = 108 THEN
                    v_descdocumento := 'guias de recepción';
                    IF i.situac <> 'E' THEN
                        rec.codigo := '1.1';
                        rec.descripcion := 'La guia de recepción '
                                           || i.series
                                           || '-'
                                           || i.numdoc
                                           || ' ya está boleteada y/o facturada.';

                    END IF;

                    v_cantitems_rel := v_cantitems_rel + i.cantitems;
                WHEN i.tipdoc = 1 THEN
                    dbms_output.put_line('Very Good');
            END CASE;

            PIPE ROW ( rec );
        END LOOP;

        IF v_cantitems_rel <> 10 THEN
            rec.codigo := '1.1';
            rec.descripcion := ' La cantidad de items de '
                               || v_descdocumento
                               || ' no es igual a la cantidad de items del comprobante de venta. ';
            PIPE ROW ( rec );
        END IF;

    END documentorelacionado;

    FUNCTION mescerrado (
        pin_id_cia  IN NUMBER,
        pin_sistema IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER
    ) RETURN datatable
        PIPELINED
    AS
        rec      datarecord;
        v_modulo VARCHAR2(220);
        v_cierre NUMBER;
    BEGIN
    -- TAREA: Se necesita implantación para function PACK_VALIDA.mesCerrado
        CASE pin_sistema
            WHEN 1 THEN
                v_modulo := 'en el modulo contabilidad';
            WHEN 2 THEN
                v_modulo := 'en el modulo cuentas por cobrar - clientes';
            WHEN 3 THEN
                v_modulo := 'en el modulo comercial';
            WHEN 4 THEN
                v_modulo := 'en el modulo logística';
            WHEN 5 THEN
                v_modulo := 'en el modulo cuentas por pagar - proveedores';
            ELSE
                NULL;
        END CASE;

        DECLARE BEGIN
            SELECT
                cierre
            INTO v_cierre
            FROM
                cierre
            WHERE
                    id_cia = pin_id_cia
                AND sistema = pin_sistema
                AND periodo = pin_periodo
                AND mes = pin_mes;

        EXCEPTION
            WHEN no_data_found THEN
                v_cierre := NULL;
        END;

        IF v_cierre IS NULL THEN
            rec.codigo := '1.1';
            rec.descripcion := ' Periodo '
                               || pin_periodo
                               || '-'
                               || pin_mes
                               || ' no esta creado. ';

            PIPE ROW ( rec );
        END IF;

        IF v_cierre <> 0 THEN
            rec.codigo := '1.1';
            rec.descripcion := ' Periodo '
                               || pin_periodo
                               || '-'
                               || pin_mes
                               || ' se encuentra cerrado. ';

            PIPE ROW ( rec );
        END IF;

    END mescerrado;

    FUNCTION topeboletas (
        pin_id_cia IN NUMBER,
        pin_tipdoc IN NUMBER,
        pin_tident IN VARCHAR2,
        pin_ruc    IN VARCHAR2,
        pin_preven IN NUMBER
    ) RETURN datatable
        PIPELINED
    AS
        rec            datarecord;
        v_verificatope VARCHAR2(10) := 'N';
        v_topeboleta   NUMBER;
    BEGIN
        IF pin_tipdoc = 3 THEN
            -- dudas
            IF NOT ( (
                pin_tident = '01'
                AND length(pin_ruc) = 8
            ) OR (
                pin_tident = '06'
                AND ( length(pin_ruc) = 8 OR length(pin_ruc) = 11 )
            ) OR (
                pin_tident = '04'
                AND length(pin_ruc) <> 0
            ) OR (
                pin_tident = '07'
                AND length(pin_ruc) <> 0
            ) ) THEN
                v_verificatope := 'S';
            END IF;

            DECLARE BEGIN
                SELECT
                    vreal
                INTO v_topeboleta
                FROM
                    factor
                WHERE
                        id_cia = pin_id_cia
                    AND codfac = 354;

            EXCEPTION
                WHEN no_data_found THEN
                    v_topeboleta := 0;
            END;

            IF (
                pin_preven > v_topeboleta
                AND v_verificatope = 'S'
            ) THEN
                rec.codigo := '1.1';
                rec.descripcion := ' El interlocutor comercial tiene que identificarse porque superó el tope establecido por la SUNAT. Emisión de boletas de venta. ';
                PIPE ROW ( rec );
            END IF;

        END IF;
    END topeboletas;

    FUNCTION envio_a_cuenta_x_cobrar (
        pin_id_cia IN NUMBER,
        pin_codpag IN NUMBER
    ) RETURN VARCHAR2 AS
        rec              datarecord;
        v_condicion_pago VARCHAR2(10);
    BEGIN
        BEGIN
            SELECT
                valor
            INTO v_condicion_pago
            FROM
                c_pago_clase
            WHERE
                    id_cia = pin_id_cia
                AND codpag = pin_codpag
                --AND valor = 'N'
            FETCH NEXT 1 ROWS ONLY;
        -- SI EXISTE Y ES N = FALSO (NO PASA)
        EXCEPTION
            WHEN no_data_found THEN
                v_condicion_pago := 'S';
        END;

        IF ( v_condicion_pago = 'N' ) THEN
            RETURN 'N';
        ELSE
            RETURN 'S';
        END IF;
    END envio_a_cuenta_x_cobrar;

    FUNCTION fechaentrega (
        pin_id_cia       IN NUMBER,
        pin_fechaentrega IN DATE
    ) RETURN VARCHAR2 AS
    BEGIN
        IF ( trunc(pin_fechaentrega) >= trunc(current_date) ) THEN
            -- N (NO VENCIO) -- SI SE PUEDE VISAR EL DOCUMENTOS 
            -- LA FECHA ENTREGA ES MAYOR A LA FECHA DE APROBACION
            RETURN 'N';/*
                   || '   Hora de Enviada:  '
                   || to_char(trunc(pin_fechaentrega), 'DD/MM/YYYY HH:MI:SS')
                   || '   Hora de DB:  '
                   || to_char(trunc(current_date), 'DD/MM/YYYY HH:MI:SS');*/

        ELSE
            -- S(SE VENCIO) -- NO SE PUEDE VISAR EL DOCUMENTO
            -- LA FECHA DE ENTREGA ES MENOR A LA FECHA DE APROBACION
            RETURN 'S';/*
                   || '   Hora de Enviada:  '
                   || to_char(trunc(pin_fechaentrega), 'DD/MM/YYYY HH:MI:SS')
                   || '   Hora de DB:  '
                   || to_char(trunc(current_date), 'DD/MM/YYYY HH:MI:SS');*/
        END IF;
    END fechaentrega;

    FUNCTION igvdocumento (
        pin_id_cia IN NUMBER,
        pin_porigv IN NUMBER,
        pin_monafe IN NUMBER,
        pin_preven IN NUMBER,
        pin_monotr IN NUMBER,
        pin_monisc IN NUMBER,
        pin_monigv IN NUMBER,
        pin_monina IN NUMBER,
        pin_monexo IN NUMBER
    ) RETURN datatable
        PIPELINED
    AS
        rec           datarecord;
        basecalculada NUMBER;
        igvcalculada  NUMBER;
    BEGIN
        IF (
            pin_porigv > 0
            AND pin_monafe <> 0
        ) THEN
            basecalculada := ( pin_preven - pin_monotr - pin_monina  - pin_monexo ) / ( 1 + ( pin_porigv / 100 ) );

            igvcalculada := basecalculada * ( pin_porigv / 100 );
            IF ( ( ( basecalculada - ( pin_monafe + pin_monisc ) ) > 0.02 ) OR ( ( igvcalculada - pin_monigv ) > 0.02 ) ) THEN
                rec.codigo := '1.1';
                rec.descripcion := ' Verifique el IGV o la base imponible calculada. ' || ( pin_monigv );
                PIPE ROW ( rec );
            END IF;

        END IF;
    END igvdocumento;

    FUNCTION clientecredito_verify (
        pin_id_cia IN NUMBER,
        pin_codcli IN VARCHAR2
    ) RETURN datatable
        PIPELINED
    AS
        v_codcli VARCHAR2(60);
        v_codpag NUMBER;
        rec      datarecord;
    BEGIN
    -- TAREA: Se necesita implantación para function PACK_VALIDA.clienteCredito_verify

        DECLARE BEGIN
            SELECT
                c.codcli,
                c.codpag
            INTO
                v_codcli,
                v_codpag
            FROM
                     cliente c
                INNER JOIN cliente_clase cc ON cc.id_cia = c.id_cia
                                               AND cc.tipcli = 'A'
                                               AND cc.codcli = c.codcli
                                               AND cc.clase = 1
            WHERE
                    c.id_cia = pin_id_cia
                AND c.codcli = pin_codcli;

        EXCEPTION
            WHEN no_data_found THEN
                v_codcli := NULL;
                v_codpag := NULL;
        END;

        IF v_codcli IS NULL OR v_codpag IS NULL THEN
            rec.codigo := '1.1';
            rec.descripcion := ' Verifique la situación y el crédito asignado al cliente. ';
            PIPE ROW ( rec );
        END IF;

        IF
            v_codpag IS NOT NULL
            AND v_codpag = 0
        THEN
            rec.codigo := '1.1';
            rec.descripcion := ' El cliente posee crédito cerrado.. ';
            PIPE ROW ( rec );
        END IF;

    END clientecredito_verify;

    FUNCTION dcabcorrelativo_validafemisi (
        pin_id_cia IN NUMBER,
        pin_tipdoc IN NUMBER,
        pin_serie  IN VARCHAR2,
        pin_numdoc IN NUMBER,
        pin_femisi IN DATE,
        pin_accion IN NUMBER
    ) RETURN datatable
        PIPELINED
    AS

        v_doc_numint NUMBER;
        v_doc_serie  VARCHAR(10);
        v_doc_numdoc NUMBER;
        v_doc_femisi DATE;
        v_doc_situac VARCHAR(10);
        rec          datarecord;
        v_stracc     VARCHAR(120);
    BEGIN
    -- TAREA: Se necesita implantación para function PACK_VALIDA.dcabcorrelativo_validaFemisi

        DECLARE BEGIN
            SELECT
                c.numint,
                c.series,
                c.numdoc,
                c.femisi,
                c.situac
            INTO
                v_doc_numint,
                v_doc_serie,
                v_doc_numdoc,
                v_doc_femisi,
                v_doc_situac
            FROM
                documentos_cab c
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc = pin_tipdoc
                AND c.series = pin_serie
                AND c.numdoc = (
                    SELECT
                        MAX(numdoc)
                    FROM
                        documentos_cab
                    WHERE
                            id_cia = pin_id_cia
                        AND tipdoc = pin_tipdoc
                        AND series = pin_serie
                        AND ( numdoc > ( pin_numdoc - 50 )
                              AND numdoc < pin_numdoc )
                        AND numdoc > 0
                );

        EXCEPTION
            WHEN no_data_found THEN
                v_doc_numint := NULL;
                v_doc_serie := NULL;
                v_doc_numdoc := NULL;
                v_doc_femisi := NULL;
                v_doc_situac := NULL;
        END;

        IF
            v_doc_femisi IS NOT NULL
            AND v_doc_femisi > v_doc_femisi
        THEN
            CASE pin_accion
                WHEN 1 THEN
                    v_stracc := 'imprimir';
                WHEN 2 THEN
                    v_stracc := 'enviar a cuentas corrientes';
                WHEN 3 THEN
                    v_stracc := 'guardar';
                WHEN 4 THEN
                    v_stracc := 'realizar el proceso';
                ELSE
                    dbms_output.put_line('No such grade');
            END CASE;

            rec.codigo := '1.1';
            rec.descripcion := ' No puede '
                               || v_stracc
                               || 'el documento por tener su fecha de emisión menor. '
                               || ' Documento anterior: '
                               || v_doc_serie
                               || '-'
                               || v_doc_numdoc
                               || ' fecha de emision '
                               || v_doc_femisi
                               || ' Documento actual: '
                               || pin_serie
                               || '-'
                               || pin_numdoc
                               || ' fecha de emision '
                               || pin_femisi;

            PIPE ROW ( rec );
        END IF;

    END dcabcorrelativo_validafemisi;

    FUNCTION valida_tident_ruc (
        pin_id_cia IN NUMBER,
        pin_tipdoc IN NUMBER,
        pin_tident IN VARCHAR2,
        pin_ruc    IN VARCHAR2,
        pin_destin IN NUMBER,
        pin_direc1 IN VARCHAR2
    ) RETURN datatable
        PIPELINED
    AS

        v_vstrg   VARCHAR(1) := 'N';
        rec       datarecord;
        vresponse VARCHAR(1) := 'S';
    BEGIN


    -- TAREA: Se necesita implantación para function PACK_VALIDA.valida_TIdent_Ruc
        DECLARE BEGIN
            SELECT
                vstrg
            INTO v_vstrg
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 416;

        EXCEPTION
            WHEN no_data_found THEN
                v_vstrg := 'N';
        END;

        IF v_vstrg = 'S' THEN
            IF (
                pin_tident = '06'
                AND length(pin_ruc) = 11
                AND ( pin_tipdoc = 1 OR pin_tipdoc = 3 OR pin_tipdoc = 7 OR pin_tipdoc = 8 OR pin_tipdoc = 41 OR pin_tipdoc = 123 )
            ) THEN
                vresponse := 'S';
            ELSE
                vresponse := 'N';
            END IF;

        ELSE
            IF (
                pin_tident = '06'
                AND length(pin_ruc) = 11
                AND ( pin_tipdoc = 1 OR pin_tipdoc = 7 OR pin_tipdoc = 8 OR pin_tipdoc = 41 OR pin_tipdoc = 123 )
            ) THEN
                vresponse := 'S';
            ELSE
                vresponse := 'N';
            END IF;
        END IF;

        IF ( vresponse = 'S' OR (
            ( pin_tipdoc = 3 OR pin_tipdoc = 7 OR pin_tipdoc = 8 OR pin_tipdoc = 41 OR pin_tipdoc = 123 )
            AND (
                pin_tident = '01'
                AND length(pin_ruc) = 8
            )
        ) ) THEN
            vresponse := 'S';
        ELSE
            vresponse := 'N';
        END IF;

        IF ( vresponse = 'S' OR (
            ( pin_tipdoc = 7 OR pin_tipdoc = 123 )
            AND (
                ( pin_tident = '06' OR pin_tident = '01' )
                AND length(pin_ruc) >= 0
            )
        ) ) THEN
            vresponse := 'S';
        ELSE
            vresponse := 'N';
        END IF;

        IF ( vresponse = 'S' OR (
            ( pin_tipdoc = 3 OR pin_tipdoc = 41 )
            AND ( (
                pin_tident = '01'
                AND length(pin_ruc) = 8
            ) OR (
                pin_tident <> '06'
                AND length(pin_ruc) >= 0
            ) )
        ) ) THEN
            vresponse := 'S';
        ELSE
            vresponse := 'N';
        END IF;

        IF ( vresponse = 'S' OR (
            ( pin_tipdoc = 1 OR pin_tipdoc = 3 OR pin_tipdoc = 7 OR pin_tipdoc = 8 OR pin_tipdoc = 123 )
            AND (
                (
                    pin_tident = '00'
                    AND length(pin_ruc) >= 0
                )
--                AND pin_destin <> 2
            )
        ) ) THEN
            vresponse := 'S';
        ELSE
            vresponse := 'N';
        END IF;

        IF ( vresponse = 'S' OR ( pin_tipdoc = 12 OR pin_tipdoc = 210 OR pin_tipdoc = 100 ) ) THEN
            vresponse := 'S';
        ELSE
            vresponse := 'N';
        END IF;

        IF vresponse <> 'S' THEN
            rec.codigo := '1.1';
            rec.descripcion := 'El documento tiene un tipo o número de identidad inválido. ';
            PIPE ROW ( rec );
        END IF;

        IF (
            vresponse = 'S'
            AND ( pin_tipdoc <> 3 OR pin_tipdoc <> 12 OR pin_tipdoc <> 210 OR pin_tipdoc <> 100 OR pin_tipdoc <> 41 OR pin_tipdoc <> 123 )
        ) THEN
            IF (
                ( pin_tipdoc = 1 OR pin_tipdoc = 7 OR pin_tipdoc = 8 )
                AND ( pin_direc1 IS NULL OR length(pin_direc1) <= 10 )
            ) THEN
                rec.codigo := '1.1';
                rec.descripcion := 'Ingrese una dirección valida mayor a 10 caracteres. ';
                PIPE ROW ( rec );
            END IF;
        END IF;

    END valida_tident_ruc;

    FUNCTION retornaitemsxnumint (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER,
        pin_tipdoc IN NUMBER,
        pin_serie  IN VARCHAR2
    ) RETURN datatable
        PIPELINED
    AS

        v_vchar   VARCHAR(1);
        v_canitem NUMBER := 0; -- cantidad de items permito¿idos
        v_nitems  NUMBER := 0; -- cantidad de items
        rec       datarecord;
    BEGIN
    -- TAREA: Se necesita implantación para function PACK_VALIDA.retornaItemsXNumint

        DECLARE BEGIN
            SELECT
                vchar
            INTO v_vchar
            FROM
                documentos_clase       dc
                LEFT OUTER JOIN documentos_clase_ayuda dca ON dca.id_cia = dc.id_cia
                                                              AND dca.clase = dc.clase
            WHERE
                    dc.id_cia = pin_id_cia
                AND dc.codigo = pin_tipdoc
                AND dc.series = pin_serie
                AND dc.clase = 16;

        EXCEPTION
            WHEN no_data_found THEN
                v_vchar := NULL;
        END;

        IF
            v_vchar IS NOT NULL
            AND v_vchar = 'S'
        THEN
            DECLARE BEGIN
                SELECT
                    COUNT(1)
                INTO v_nitems
                FROM
                         documentos_det d
                    INNER JOIN articulos       a ON d.id_cia = a.id_cia
                                              AND d.tipinv = a.tipinv
                                              AND d.codart = a.codart
                    LEFT OUTER JOIN articulos_clase ac ON ac.id_cia = a.id_cia
                                                          AND ac.tipinv = a.tipinv
                                                          AND ac.codart = a.codart
                                                          AND ac.clase = 87
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.numint = pin_numint
                GROUP BY
                    d.numint,
                    d.codart,
                    a.descri,
                    d.codadd01,
                    d.codadd02,
                    d.preuni,
                    ac.codigo;

            EXCEPTION
                WHEN no_data_found THEN
                    v_nitems := 0;
            END;

            -- la agrupación depenete de v_vchar
        ELSE
            DECLARE BEGIN
                SELECT
                    COUNT(1)
                INTO v_nitems
                FROM
                         documentos_det d
                    INNER JOIN articulos       a ON d.id_cia = a.id_cia
                                              AND d.tipinv = a.tipinv
                                              AND d.codart = a.codart
                    LEFT OUTER JOIN articulos_clase ac ON ac.id_cia = a.id_cia
                                                          AND ac.tipinv = a.tipinv
                                                          AND ac.codart = a.codart
                                                          AND ac.clase = 87
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.numint = pin_numint;

            EXCEPTION
                WHEN no_data_found THEN
                    v_nitems := 0;
            END;
        END IF;

        DECLARE BEGIN
            SELECT
                dc.canitem
            INTO v_canitem
            FROM
                documentos dc
            WHERE
                    dc.id_cia = pin_id_cia
                AND dc.codigo = pin_tipdoc
                AND dc.series = pin_serie;

        EXCEPTION
            WHEN no_data_found THEN
                v_canitem := 0;
        END;

        IF
            v_canitem > 0
            AND v_nitems > v_canitem
        THEN
            rec.codigo := '1.1';
            rec.descripcion := 'El documento permite imprimir: '
                               || v_canitem
                               || ' items. 
                Cantidad en documento: '
                               || v_nitems;
            PIPE ROW ( rec );
        END IF;

    END retornaitemsxnumint;
/*
  function verificar_cantidades_saldos_articulo(
         pin_id_cia IN NUMBER,
         pin_tipdoc in NUMBER,
         pin_id in VARCHAR2,
         pin_codmot in number
    ) return datatable PIPELINED AS

     v_motivo_clase28_enviar_kardex  NUMBER;
     rec        datarecord;

  BEGIN
    -- TAREA: Se necesita implantación para function PACK_VALIDA.verificar_cantidades_saldos_articulo

        DECLARE BEGIN
            SELECT
                valor
            INTO v_motivo_clase28_enviar_kardex
            FROM
                motivos_clase
            WHERE
                    id_cia = pin_id_cia
                AND tipdoc = pin_tipdoc
                AND id = pin_id
                AND codmot = pin_codmot
                AND codigo = 28
            ORDER BY
                codigo ASC;
      EXCEPTION
            WHEN no_data_found THEN
                v_motivo_clase28_enviar_kardex := NULL;
        END;

        IF (v_motivo_clase28_enviar_kardex IS NOT NULL and v_motivo_clase28_enviar_kardex = 'S') THEN

            rec.codigo := '1.1';
            rec.descripcion := '-----';
            PIPE ROW ( rec );

        END IF;    


  END verificar_cantidades_saldos_articulo;
*/
    FUNCTION configbanco (
        pin_id_cia IN NUMBER,
        pin_tipdep IN NUMBER,
        pin_tipmon IN VARCHAR2,
        pin_codsuc IN NUMBER
    ) RETURN datatable
        PIPELINED
    AS
        rec      datarecord;
        v_codban VARCHAR2(3);
        v_banco  VARCHAR2(3);
    BEGIN
    -- TAREA: Se necesita implantación para FUNCTION PACK_VALIDA.configBanco

        DECLARE BEGIN
            SELECT
                codban
            INTO v_codban
            FROM
                m_pago_config
            WHERE
                    id_cia = pin_id_cia
                AND codsuc = pin_codsuc
                AND codigo = pin_tipdep
                AND moneda = pin_tipmon;

        EXCEPTION
            WHEN no_data_found THEN
                v_codban := NULL;
        END;

        IF v_codban IS NULL THEN
            rec.codigo := '1.1';
            rec.descripcion := 'Medio de pago [ '
                               || pin_tipdep
                               || ' ] no tiene banco configurado en: '
                               || pin_tipmon;
            PIPE ROW ( rec );
        ELSE
            DECLARE BEGIN
                SELECT
                    b.codban
                INTO v_banco
                FROM
                    tbancos       b
                    LEFT OUTER JOIN tbancos_clase c ON c.id_cia = b.id_cia
                                                       AND c.codban = b.codban
                                                       AND c.clase = 2
                WHERE
                        b.id_cia = pin_id_cia
                    AND b.swacti = 'S'
                    AND c.vchar = 'S'
                    AND b.codban = v_codban;

            EXCEPTION
                WHEN no_data_found THEN
                    v_banco := NULL;
            END;

            IF v_banco IS NULL THEN
                rec.codigo := '1.1';
                rec.descripcion := 'Banco [ '
                                   || v_codban
                                   || ' ] no configurado.  Clase 2 es requerido';
                PIPE ROW ( rec );
            END IF;

        END IF;

    END configbanco;

    FUNCTION configbancoautomatico (
        pin_id_cia IN NUMBER,
        pin_tipdep IN NUMBER, -- solo si el pago es con tarjeta
        pin_tipmon IN VARCHAR2,
        pin_codsuc IN NUMBER
    ) RETURN datatable
        PIPELINED
    AS
        rec datarecord;
    BEGIN

        -- solo si el pago es con tarjeta.
        IF pin_tipdep IS NOT NULL THEN
            FOR i IN (
                SELECT
                    *
                FROM
                    TABLE ( configbanco(pin_id_cia, pin_tipdep, pin_tipmon, pin_codsuc) )
            ) LOOP
                rec.codigo := i.codigo;
                rec.descripcion := i.descripcion;
                PIPE ROW ( rec );
            END LOOP;
        END IF;


        -- efectivo
        FOR i IN (
            SELECT
                *
            FROM
                TABLE ( configbanco(pin_id_cia, 8, pin_tipmon, pin_codsuc) )
        ) LOOP
            rec.codigo := i.codigo;
            rec.descripcion := i.descripcion;
            PIPE ROW ( rec );
        END LOOP;

        -- vuelto
        FOR i IN (
            SELECT
                *
            FROM
                TABLE ( configbanco(pin_id_cia, 999, pin_tipmon, pin_codsuc) )
        ) LOOP
            rec.codigo := i.codigo;
            rec.descripcion := i.descripcion;
            PIPE ROW ( rec );
        END LOOP;


        -- redondeo a favor
        FOR i IN (
            SELECT
                *
            FROM
                TABLE ( configbanco(pin_id_cia, 12, pin_tipmon, pin_codsuc) )
        ) LOOP
            rec.codigo := i.codigo;
            rec.descripcion := i.descripcion;
            PIPE ROW ( rec );
        END LOOP;


        -- redondeo en contra
        FOR i IN (
            SELECT
                *
            FROM
                TABLE ( configbanco(pin_id_cia, 13, pin_tipmon, pin_codsuc) )
        ) LOOP
            rec.codigo := i.codigo;
            rec.descripcion := i.descripcion;
            PIPE ROW ( rec );
        END LOOP;

    END configbancoautomatico;

END pack_valida;

/
