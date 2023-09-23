--------------------------------------------------------
--  DDL for Function SP_CUOTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_CUOTAS" (
    pin_id_cia IN VARCHAR2,
    pin_numint IN NUMBER
) RETURN tbl_sp_cuotas
    PIPELINED
AS

    rec             rec_sp_cuotas := rec_sp_cuotas(NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL,
                                      0, NULL, NULL);
    v_codcpag       SMALLINT;
    v_itemcab       SMALLINT;
    v_femisi        DATE;
    v_femisi_dr     DATE;
    v_fecter        DATE;
    v_canjlet       VARCHAR(1);
    v_diavencab     SMALLINT;
    v_diavendet     SMALLINT;
    v_simbolo       VARCHAR(3);
    v_itemdet       SMALLINT;
    v_diaven        SMALLINT;
    v_nregmain      INTEGER;
    v_nreg          INTEGER;
    v_current_reg   INTEGER;
    v_current_reg2  INTEGER;
    v_total         NUMERIC(16, 2);
    v_cuota         NUMERIC(16, 2);
    v_cpreven       NUMERIC(16, 2);
    wpreven         NUMERIC(16, 2);
    v_ctipcam       NUMERIC(16, 5);
    v_ctipmon       VARCHAR(5);
    v_tope          NUMERIC(16, 2);
    v_regret        INTEGER := 0;
    v_tasa          NUMERIC(16, 2);
    v_f331          VARCHAR2(10) := 'N';
    v_sw_calcularet VARCHAR2(1);
    w_cpreven       NUMERIC(16, 2);
    v_label         VARCHAR2(15) := '';
    v_ttg           VARCHAR2(25);
    v_tipdoc        INTEGER;
    v_montasa       NUMERIC(16, 2);
    v_montasa01     NUMERIC(16, 2);
    v_montasa02     NUMERIC(16, 2);
    v_tasap         NUMERIC(16, 2) := 0;
    v_tope_reten    NUMERIC(16, 2) := 0;
    v_tope_detrac   NUMERIC(16, 2) := 0;
    v_cantlet       NUMBER;
    v_aux           NUMBER := 0;
    v_simbolo_mn    VARCHAR(3);
BEGIN
/*COMPANIA ES AGENTE DE RETENCION FACTOR 331 */
    BEGIN
        SELECT
            vstrg
        INTO v_f331
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 331;

    EXCEPTION
        WHEN no_data_found THEN
            v_f331 := NULL;
    END;

    IF ( v_f331 IS NULL ) THEN
        v_f331 := 'N';
    END IF;
    dbms_output.put_line('Es Agente de Retencion[F331] ==> ' || v_f331);
    wpreven := 0;
    v_tope := 0;
    v_tasa := 0;
    v_montasa := 0;
    v_current_reg := 0;
    v_total := 0;
    v_label := '';
    w_cpreven := 0;
       /* sacamos valores de la cabecera del documento */
    SELECT
        dc.preven,
        dc.tipcam,
        dc.tipmon,
        dc.codcpag,
        trunc(dc.femisi) AS femisi,
        trunc(dc.fecter) AS fecter,
        m1.simbolo       AS simbolo,
        cp.canjlet,
        cp.diaven        AS diavencab,
        cp.cantlet,
        cl.regret,
        dc.tipdoc,
        dr.femisi,
        CASE
            WHEN mc.valor IS NULL THEN
                'N'
            ELSE
                mc.valor
        END              AS ttg
    INTO
        v_cpreven,
        v_ctipcam,
        v_ctipmon,
        v_codcpag,
        v_femisi,
        v_fecter,
        v_simbolo,
        v_canjlet,
        v_diavencab,
        v_cantlet,
        v_regret,
        v_tipdoc,
        v_femisi_dr,
        v_ttg
    FROM
        documentos_cab            dc
        LEFT OUTER JOIN tmoneda                   m1 ON m1.id_cia = dc.id_cia
                                      AND m1.codmon = dc.tipmon
        LEFT OUTER JOIN c_pago                    cp ON cp.id_cia = dc.id_cia
                                     AND cp.codpag = dc.codcpag
        LEFT OUTER JOIN cliente                   cl ON cl.id_cia = dc.id_cia
                                      AND cl.codcli = dc.codcli
        LEFT OUTER JOIN documentos_cab_referencia dr ON dr.id_cia = dc.id_cia
                                                        AND dr.numint = dc.numint
        LEFT OUTER JOIN motivos_clase             mc ON mc.id_cia = dc.id_cia
                                            AND mc.codmot = dc.codmot
                                            AND mc.tipdoc = dc.tipdoc
                                            AND mc.id = dc.id
                                            AND mc.codigo = 44 /*Motivo es tranferencia grauita (SUNAT)*/
    WHERE
            dc.id_cia = pin_id_cia
        AND dc.numint = pin_numint;

    IF ( v_cpreven IS NULL ) THEN
        v_cpreven := 0;
    END IF;
    IF ( v_ctipcam IS NULL ) THEN
        v_ctipcam := 0;
    END IF;
    IF ( v_ctipmon IS NULL ) THEN
        v_ctipmon := '';
    END IF;
    IF ( v_ttg IS NULL ) THEN
        v_ttg := 'N';
    END IF;
    IF ( v_ttg = 'S' ) THEN
        RETURN;
    ELSE
        v_sw_calcularet := 'N';
        w_cpreven := v_cpreven;
        dbms_output.put_line('Nro. Interno ==> ' || pin_numint);
        dbms_output.put_line('F.Emision    ==>' || v_femisi);
        dbms_output.put_line('Moneda       ==> ' || v_ctipmon);
        dbms_output.put_line('Reg.Ret      ==> ' || v_regret);
        dbms_output.put_line('Cond-Pago    ==> ' || v_codcpag);
        dbms_output.put_line('Dia Venc cpago ==>  ' || v_diavencab);
        dbms_output.put_line('P.Venta      ==>  ' || v_cpreven); 
  /*CONVERSION SOLES PARA EVALUAR */
        IF ( v_ctipmon <> 'PEN' ) THEN
            wpreven := v_cpreven * v_ctipcam;
        ELSE
            wpreven := v_cpreven;
        END IF;

        SELECT
            simbolo
        INTO v_simbolo_mn
        FROM
            tmoneda
        WHERE
                id_cia = pin_id_cia
            AND codmon = 'PEN';

        dbms_output.put_line('P.Venta si es <> PEN ==>  ' || wpreven);  
     /******************************/
     /**   CALCULA RETENCION      **/
     /******************************/
	 /* SI EL CLIENTE ES AFECTO A RETENCION
        SACAMOS LA TASA Y TOPE DE LA RETENCION */
        BEGIN
            SELECT
                nvl(tope, 0),
                nvl(tasa, 0)
            INTO
                v_tope_reten,
                v_tasa
            FROM
                regimen_retenciones_vigencia
            WHERE
                    id_cia = pin_id_cia
                AND codigo = 3 --AFECTO A RETENCION
            ORDER BY
                finicio DESC --OBTENEMOS EL MAS RECIENTE
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                v_tope_reten := 0;
                v_tasa := 0;
        END;

        IF
            v_f331 = 'N'
            AND v_tope_reten > 0
        THEN /*COMPAÑIA EMISORA  NO ES AGENTE DE RETENCION*/
            IF ( wpreven > v_tope_reten ) THEN
                IF ( v_regret = 1 ) THEN
                    v_sw_calcularet := 'S';
                END IF;
            END IF;

            IF ( v_sw_calcularet = 'S' ) THEN
                v_label := 'Retención ';
                w_cpreven := ( v_cpreven * ( ( 100 - v_tasa ) / 100 ) );
                v_montasa := round((v_cpreven *(v_tasa / 100)), 2);
                v_tasap := v_tasa;
                dbms_output.put_line('------------------------------------------------------------------------------------------------'
                );
                dbms_output.put_line('v_label   ==>' || v_label);
                dbms_output.put_line('w_cpreven ==>' || w_cpreven);
                dbms_output.put_line('v_montasa ==>' || v_montasa);
                dbms_output.put_line('v_tasap   ==>' || v_tasap);
                dbms_output.put_line('RETENCION CALCULADA, REVISAR LA CONFIGURACION DE LA CONDICION DE PAGO');
                dbms_output.put_line('SI EL CANJE POR LETRAS ESTA EN "N" ENTONCES LA CANTIDAD DE CUOTAS DEBE SER 0');
                dbms_output.put_line('------------------------------------------------------------------------------------------------'
                );
            END IF;

        END IF;     

       /******************************/
       /**   CALCULA DETRACCION      **/
       /******************************/

        v_tasa := 0;
        v_tope_detrac := 0;

        /* sacamos la tasa = vreal y tope =ventero de detraccion */
        BEGIN
            SELECT
                nvl(MAX(nvl(tf.vreal, 0)),
                    0),
                nvl(tf.ventero, 0)
            INTO
                v_tasa,
                v_tope_detrac
            FROM
                     documentos_det dd
                INNER JOIN documentos_cab       dc ON dc.id_cia = dd.id_cia
                                                AND dc.numint = dd.numint
                INNER JOIN articulos_detraccion ad ON ad.id_cia = dd.id_cia
                                                      AND ad.tipinv = dd.tipinv
                                                      AND ad.codart = dd.codart
                INNER JOIN tfactor              tf ON tf.id_cia = ad.id_cia
                                         AND tf.codfac = ad.tasdet
                                         AND ( tf.tipo = 64 )
            WHERE
                    dd.id_cia = pin_id_cia
                AND dd.numint = pin_numint
                AND dc.destin <> 2 -- ARTICULOS DE UNA IMPORTACIONES, NO SE CALCULA LA DESTRACCION
            GROUP BY
                nvl(tf.ventero, 0);

        EXCEPTION
            WHEN no_data_found THEN
                v_tasa := 0;
                v_tope_detrac := 0;
        END;

        IF
            v_tasa > 0
            AND wpreven > v_tope_detrac
        THEN
            IF ( v_ctipmon <> 'PEN' ) THEN
--                v_montasa01 := round((v_cpreven * v_ctipcam * (v_tasa / 100)), 0);
                v_label := 'Detracción ';
                v_montasa := round((v_cpreven *(v_tasa / 100)), 2);
                w_cpreven := ( v_cpreven - v_montasa );
                v_tasap := v_tasa;
            ELSE
                v_label := 'Detracción ';
                v_montasa := round((v_cpreven *(v_tasa / 100)), 0);
                w_cpreven := ( v_cpreven - v_montasa );
                v_tasap := v_tasa;
            END IF;

            dbms_output.put_line('------------------------------------------------------------------------------------------------');
            dbms_output.put_line('v_label   ==>' || v_label);
            dbms_output.put_line('v_cpreven ==>' || v_cpreven);
            dbms_output.put_line('v_montasa ==>' || v_montasa);
            dbms_output.put_line('v_tcambio  ==> ' || v_ctipcam);
            dbms_output.put_line('v_tasap   ==>' || v_tasap);
            dbms_output.put_line('v_montasa01   ==>' || v_montasa01);
            dbms_output.put_line('DETRACCION CALCULADA, REVISAR LA CONFIGURACION DE LA CONDICION DE PAGO');
            dbms_output.put_line('SI EL CANJE POR LETRAS ESTA EN "N" ENTONCES LA CANTIDAD DE CUOTAS DEBE SER 0');
            dbms_output.put_line('------------------------------------------------------------------------------------------------');
        END IF;

        v_cpreven := w_cpreven;

    /*Obteniendo el nro de registros de consulta de cuotas*/
        SELECT
            COUNT(0)
        INTO v_nregmain
        FROM
            documentos_cab_c_pago dp
        WHERE
                dp.id_cia = pin_id_cia
            AND dp.numint = pin_numint;

        v_itemdet := 1;
        IF ( v_nregmain IS NULL ) THEN
            v_nregmain := 0;
        END IF;
        rec.simbolo_mn := v_simbolo_mn;
        rec.montasa_mn := 0;
/* si documentos_cab_c_pago tiene registros */
        IF ( v_nregmain > 0 ) THEN
            dbms_output.put_line('---------------------documentos_cab_c_pago>0 ---------------------------------------------------------'
            );
            FOR i IN (
                SELECT
                    dp.item,
                    dp.dias AS diavendet,
                    dp.importe
                FROM
                    documentos_cab_c_pago dp
                WHERE
                        dp.id_cia = pin_id_cia
                    AND dp.numint = pin_numint
                ORDER BY
                    dp.item
            ) LOOP
                v_itemcab := i.item;
                v_diavendet := i.diavendet;
                rec.moncuota_nc := i.importe;
                rec.numint := pin_numint;
                rec.tipdoc := v_tipdoc;
                rec.tasa := v_tasap;
                rec.montasa := v_montasa;
                rec.simbolo_mn := v_simbolo_mn;
                rec.montasa_mn := v_montasa;
                IF ( v_ctipmon <> 'PEN' ) THEN
                    rec.montasa_mn := round(v_montasa * v_ctipcam, 0);
                END IF;

                rec.label := v_label;
                rec.msjsunat := '';
                IF ( v_label = 'Detracción ' ) THEN
                    rec.msjsunat := 'OPERACIÓN SUJETA AL SISTEMA DE PAGO DE OBLIGACIONES TRIBUTARIAS CON EL GOBIERNO CENTRAL';
                END IF;
                rec.simbolo := v_simbolo;
                rec.nrocuota := v_itemdet;
                IF ( v_tipdoc = 7 ) THEN /*NOTA DE CREDITO*/
                    rec.fvenci := v_femisi_dr + v_diavendet;
                ELSE
                    rec.fvenci := v_femisi + v_diavendet;
                END IF;

                rec.moncuota := round((v_cpreven / v_nregmain), 2);
                IF ( v_itemdet < v_nregmain ) THEN
                    v_total := v_total + rec.moncuota;
                ELSE
                    rec.moncuota := ( v_cpreven - v_total );
                END IF;

                rec.moncuota_nc := ( CASE
                    WHEN rec.moncuota_nc IS NULL THEN
                        0
                    ELSE rec.moncuota_nc
                END );

                v_itemdet := v_itemdet + 1;
                v_aux := 1;
                PIPE ROW ( rec );
                dbms_output.put_line('------------------------------------------------------------------------------------------------'
                );
                dbms_output.put_line('nrocuota ==> ' || rec.nrocuota);
                dbms_output.put_line('numint   ==> ' || rec.numint);
                dbms_output.put_line('tipdoc   ==> ' || rec.tipdoc);
                dbms_output.put_line('simbolo  ==> ' || rec.simbolo);
                dbms_output.put_line('label    ==> ' || rec.label);
                dbms_output.put_line('tasa     ==> ' || rec.tasa);
                dbms_output.put_line('tcambio  ==> ' || v_ctipcam);
                dbms_output.put_line('montasa  ==> ' || rec.montasa);
                dbms_output.put_line('moncuota ==> ' || rec.moncuota);
                dbms_output.put_line('moncuota_nc ==> ' || rec.moncuota_nc);
                dbms_output.put_line('------------------------------------------------------------------------------------------------'
                );
            END LOOP;

            dbms_output.put_line('------------------------------------------------------------------------------------------------');
        ELSE /*trabajamos con la condicio de pago */
            SELECT
                COUNT(0)
            INTO v_nregmain
            FROM
                c_pago_det cpd
            WHERE
                    cpd.id_cia = pin_id_cia
                AND cpd.codpag = v_codcpag;

            IF ( v_nregmain IS NULL ) THEN
                v_nregmain := 0;
            END IF;
            IF (
                ( v_canjlet = 'N' )
                AND ( v_diavencab > 0 )
                AND ( v_cantlet = 0 )
            ) THEN
                dbms_output.put_line('----------------------------v_canjlet = N  and v_diavencab>0  ---------------------------------'
                );
                rec.numint := pin_numint;
                rec.tipdoc := v_tipdoc;
                rec.tasa := v_tasap;
                dbms_output.put_line('( v_canjlet = N ) AND ( v_diavencab > 0 )= ' || rec.tasa);
                rec.montasa := v_montasa;
                rec.simbolo_mn := v_simbolo_mn;
                rec.montasa_mn := v_montasa;
                IF ( v_ctipmon <> 'PEN' ) THEN
                    rec.montasa_mn := round(v_montasa * v_ctipcam, 0);
                END IF;

                rec.label := v_label;
                rec.msjsunat := '';
                IF ( v_label = 'Detracción ' ) THEN
                    rec.msjsunat := 'OPERACIÓN SUJETA AL SISTEMA DE PAGO DE OBLIGACIONES TRIBUTARIAS CON EL GOBIERNO CENTRAL';
                END IF;
                rec.nrocuota := 1;
                rec.fvenci := v_femisi + v_diavencab;
                rec.simbolo := v_simbolo;
                rec.moncuota := v_cpreven;
                rec.moncuota_nc := 0;
                v_aux := 1;
                PIPE ROW ( rec );
                dbms_output.put_line('------------------------------------------------------------------------------------------------'
                );
                dbms_output.put_line('nrocuota ==> ' || rec.nrocuota);
                dbms_output.put_line('numint   ==> ' || rec.numint);
                dbms_output.put_line('tipdoc   ==> ' || rec.tipdoc);
                dbms_output.put_line('simbolo  ==> ' || rec.simbolo);
                dbms_output.put_line('label    ==> ' || rec.label);
                dbms_output.put_line('tasa     ==> ' || rec.tasa);
                dbms_output.put_line('tcambio  ==> ' || v_ctipcam);
                dbms_output.put_line('montasa  ==> ' || rec.montasa);
                dbms_output.put_line('moncuota ==> ' || rec.moncuota);
                dbms_output.put_line('moncuota_nc ==> ' || rec.moncuota_nc);
                dbms_output.put_line('------------------------------------------------------------------------------------------------'
                );
            END IF;

            IF
                v_canjlet = 'S'
                AND v_nregmain > 0
            THEN
                dbms_output.put_line('----------------------------v_canjlet = S  and c_pago_det>0  ---------------------------------'
                );
                FOR i IN (
                    SELECT
                        dp.item,
                        dp.diaven AS diavendet
                    FROM
                        c_pago_det dp
                    WHERE
                            dp.id_cia = pin_id_cia
                        AND dp.codpag = v_codcpag
                    ORDER BY
                        dp.item
                ) LOOP
                    rec.numint := pin_numint;
                    rec.tipdoc := v_tipdoc;
                    rec.tasa := v_tasap;
                    dbms_output.put_line('( v_canjlet = S ) AND ( v_nregmain > 0 )= ' || rec.tasa);
                    rec.montasa := v_montasa;
                    rec.simbolo_mn := v_simbolo_mn;
                    rec.montasa_mn := v_montasa;
                    IF ( v_ctipmon <> 'PEN' ) THEN
                        rec.montasa_mn := round(v_montasa * v_ctipcam, 0);
                    END IF;

                    rec.label := v_label;
                    rec.msjsunat := '';
                    IF ( v_label = 'Detracción ' ) THEN
                        rec.msjsunat := 'OPERACIÓN SUJETA AL SISTEMA DE PAGO DE OBLIGACIONES TRIBUTARIAS CON EL GOBIERNO CENTRAL';
                    END IF;
                    v_itemcab := i.item;
                    v_diavendet := i.diavendet;
                    rec.simbolo := v_simbolo;
                    rec.nrocuota := v_itemcab;
                    rec.fvenci := v_femisi + v_diavendet;
                    rec.moncuota := round((v_cpreven / v_nregmain), 2);
                    rec.moncuota_nc := 0;
                    IF ( v_itemcab < v_nregmain ) THEN
                        v_total := v_total + rec.moncuota;
                    ELSE
                        rec.moncuota := ( v_cpreven - v_total );
                    END IF;

                    v_aux := 1;
                    PIPE ROW ( rec );
                    dbms_output.put_line('------------------------------------------------------------------------------------------------'
                    );
                    dbms_output.put_line('nrocuota ==> ' || rec.nrocuota);
                    dbms_output.put_line('numint   ==> ' || rec.numint);
                    dbms_output.put_line('tipdoc   ==> ' || rec.tipdoc);
                    dbms_output.put_line('simbolo  ==> ' || rec.simbolo);
                    dbms_output.put_line('label    ==> ' || rec.label);
                    dbms_output.put_line('tasa     ==> ' || rec.tasa);
                    dbms_output.put_line('montasa  ==> ' || rec.montasa);
                    dbms_output.put_line('moncuota ==> ' || rec.moncuota);
                    dbms_output.put_line('moncuota_nc ==> ' || rec.moncuota_nc);
                    dbms_output.put_line('------------------------------------------------------------------------------------------------'
                    );
                END LOOP; 
             /*fin for si documentos_cab_c_pago tiene registros */

            END IF;/*IF ((:V_CANJLET = 'S')AND (:V_NREGMAIN>0))  THEN*/

        END IF;

        IF
            v_canjlet = 'N'
            AND v_diavencab = 0
            AND v_cantlet = 0
        THEN
            IF (
                v_montasa > 0
                AND v_aux = 0
            ) THEN
                rec.msjsunat := '';
                rec.nrocuota := 0;
                rec.simbolo := v_simbolo;
                rec.fvenci := NULL;
                rec.moncuota := 0;
                rec.moncuota_nc := 0;
                rec.tasa := v_tasap;
                rec.montasa := v_montasa;
                rec.simbolo_mn := v_simbolo_mn;
                rec.montasa_mn := v_montasa;
                IF ( v_ctipmon <> 'PEN' ) THEN
                    rec.montasa_mn := round(v_montasa * v_ctipcam, 0);
                END IF;

                rec.label := v_label;
                IF ( v_label = 'Detracción ' ) THEN
                    rec.msjsunat := 'OPERACIÓN SUJETA AL SISTEMA DE PAGO DE OBLIGACIONES TRIBUTARIAS CON EL GOBIERNO CENTRAL';
                END IF;
                PIPE ROW ( rec );
                dbms_output.put_line('----------------------------CONTADO SIN CUOTAS  ---------------------------------');
                dbms_output.put_line('------------------------------------------------------------------------------------------------'
                );
                dbms_output.put_line('nrocuota ==> ' || rec.nrocuota);
                dbms_output.put_line('numint   ==> ' || rec.numint);
                dbms_output.put_line('tipdoc   ==> ' || rec.tipdoc);
                dbms_output.put_line('simbolo  ==> ' || rec.simbolo);
                dbms_output.put_line('label    ==> ' || rec.label);
                dbms_output.put_line('tasa     ==> ' || rec.tasa);
                dbms_output.put_line('montasa  ==> ' || rec.montasa);
                dbms_output.put_line('tcambio  ==> ' || v_ctipcam);
                dbms_output.put_line('moncuota ==> ' || rec.moncuota);
                dbms_output.put_line('moncuota_nc ==> ' || rec.moncuota_nc);
                dbms_output.put_line('------------------------------------------------------------------------------------------------'
                );
            END IF;
        END IF;

    END IF;

END sp_cuotas;

/
