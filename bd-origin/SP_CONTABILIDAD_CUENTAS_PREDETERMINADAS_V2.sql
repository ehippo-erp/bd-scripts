--------------------------------------------------------
--  DDL for Function SP_CONTABILIDAD_CUENTAS_PREDETERMINADAS_V2
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_CONTABILIDAD_CUENTAS_PREDETERMINADAS_V2" (
    pin_id_cia IN NUMBER,
    pin_tipo   IN NUMBER,
    pin_docume IN NUMBER
) RETURN tbl_cuentas_predeterminadas
    PIPELINED
AS

    registro    rec_cuentas_predeterminadas := rec_cuentas_predeterminadas(NULL, NULL, NULL, NULL, NULL,
                                                                       NULL, NULL, NULL, NULL, NULL,
                                                                       NULL, NULL, NULL, NULL, NULL,
                                                                       NULL, NULL, NULL, NULL, NULL,
                                                                       NULL, NULL, NULL, NULL, NULL,
                                                                       NULL, NULL, NULL, NULL, NULL,
                                                                       NULL, NULL, NULL, NULL, NULL,
                                                                       NULL, NULL, NULL, NULL);
    item        NUMBER;
    v_cuenta    VARCHAR2(16);
    v_dh        VARCHAR2(2);
    v_tipo      NUMBER;
    v_regcomcol NUMBER;
    v_vstrg     VARCHAR2(1);
BEGIN
    FOR j IN (
        SELECT
            a.*,
            tf.cuenta AS cuentadetrac
        FROM
            compr010 a
            LEFT OUTER JOIN tfactor  tf ON tf.id_cia = a.id_cia
                                          AND tf.tipo = 64
                                          AND tf.vreal = a.tdetrac / 10
        WHERE
                a.id_cia = pin_id_cia
            AND a.tipo = pin_tipo
            AND a.docume = pin_docume
    ) LOOP

          /* DECLARE BEGIN
               SELECT COUNT(*) AS ITEM INTO ITEM FROM pcuentastccostos 
               WHERE ID_CIA = pin_id_cia 
               AND CUENTA = j.CUENTA;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                ITEM := NULL;
           END;

           IF (ITEM IS NOT NULL) THEN 

                FOR i IN (  SELECT * FROM pcuentastccostos WHERE ID_CIA = pin_id_cia AND CUENTA = j.CUENTA ) LOOP

                    registro.ID_CIA := i.id_cia;
                    registro.CUENTA := j.CTAGASTO;
                    registro.CCOSTO := I.CCOSTO;  

                    -- DtTDocume.FieldByName('CtaGasColRegCom').AsString;

                    IF j.TDocum = '02' THEN
                        registro.IMPORTE := (j.IMPORTE * I.PORCENTAJE) / 100;
                    ELSE 
                        registro.IMPORTE := (j.BASE * I.PORCENTAJE) / 100;
                    END IF;


                    CASE j.DH
                        WHEN 'D' THEN  registro.dh := 'H';  
                        WHEN 'H' THEN  registro.dh := 'D';  
                        ELSE NULL;
                    END CASE;

                    PIPE ROW ( registro );
                END LOOP;

           ELSE */
        registro.id_cia := pin_id_cia;
        registro.periodo := j.periodo;
        registro.mes := j.mes;
        registro.libro := j.libro;
        registro.item := 0;
        registro.sitem := 0;
        registro.concep := j.concep;
        registro.fecha := j.femisi;
        registro.tasien := 66;
        registro.topera := 0;
        registro.tipo := j.tipo;
        registro.docume := j.docume;
        registro.codigo := j.codpro;
        registro.razon := j.razon;
        registro.tident := j.tident;
        registro.dident := j.dident;
        registro.tdocum := j.tdocum;
        registro.serie := j.nserie;
        registro.numero := j.numero;
        registro.fdocum := j.femisi;
        registro.moneda := j.moneda;
        registro.tcambio01 := j.tcamb01;
        registro.tcambio02 := j.tcamb02;
        -- INCIALIZANDO
--        registro.ccosto := NULL;
--        registro.subccosto := NULL;
        IF ( j.tdocum = '02' ) THEN
            registro.importe := j.importe;
        ELSE
            registro.importe := j.base;
        END IF;

        dbms_output.put_line('IF N0 - ' || registro.importe);
        IF NOT ( registro.importe = 0.0 ) THEN
            registro.cuenta := j.ctagasto;
            registro.ccosto := j.ccosto;
            registro.subccosto := j.subccosto;
            registro.proyec := j.proyec;
            registro.impor01 := 0;
            registro.impor02 := 0;
            registro.debe := 0;
            registro.debe01 := 0;
            registro.debe02 := 0;
            registro.haber := 0;
            registro.haber01 := 0;
            registro.haber02 := 0;
            IF ( j.motivo = '1' OR j.tdocum = '02' ) THEN
                registro.regcomcol := '1';
            ELSIF j.motivo = '2' THEN
                registro.regcomcol := '2';
            ELSIF j.motivo = '3' THEN
                registro.regcomcol := '5';
            END IF;

            CASE j.dh
                WHEN 'D' THEN
                    registro.dh := 'H';
                WHEN 'H' THEN
                    registro.dh := 'D';
                ELSE
                    NULL;
            END CASE;

            registro.impor01 := registro.importe * registro.tcambio01;
            registro.impor02 := registro.importe * registro.tcambio02;
            IF ( registro.dh = 'D' ) THEN
                registro.debe := registro.importe;
                registro.debe01 := registro.impor01;
                registro.debe02 := registro.impor02;
            ELSE
                registro.haber := registro.importe;
                registro.haber01 := registro.impor01;
                registro.haber02 := registro.impor02;
            END IF;
            dbms_output.put_line('ENTRE - IF N0 - IMPRIME - ' || registro.importe);
            PIPE ROW ( registro );
        END IF;
    
        /*   END IF;*/
        dbms_output.put_line('IF N1 - ' || j.nogravado);
        IF j.nogravado > 0 THEN
            registro.importe := 0;
            registro.impor01 := 0;
            registro.impor02 := 0;
            registro.debe := 0;
            registro.debe01 := 0;
            registro.debe02 := 0;
            registro.haber := 0;
            registro.haber01 := 0;
            registro.haber02 := 0;
            registro.cuenta := j.ctagasto;
            registro.ccosto := j.ccosto;
            registro.subccosto := j.subccosto;
            registro.proyec := j.proyec;
            registro.regcomcol := '4';
            registro.importe := j.nogravado;
            CASE j.dh
                WHEN 'D' THEN
                    registro.dh := 'H';
                WHEN 'H' THEN
                    registro.dh := 'D';
                ELSE
                    NULL;
            END CASE;

            registro.impor01 := registro.importe * registro.tcambio01;
            registro.impor02 := registro.importe * registro.tcambio02;
            IF ( registro.dh = 'D' ) THEN
                registro.debe := registro.importe;
                registro.debe01 := registro.impor01;
                registro.debe02 := registro.impor02;
            ELSE
                registro.haber := registro.importe;
                registro.haber01 := registro.impor01;
                registro.haber02 := registro.impor02;
            END IF;

            dbms_output.put_line('ENTRE - IF N1 - IMPRIME - ' || j.nogravado);
            PIPE ROW ( registro );
        END IF;

        dbms_output.put_line('IF N2 - ' || j.isc);
        IF j.isc > 0 THEN
            registro.importe := 0;
            registro.impor01 := 0;
            registro.impor02 := 0;
            registro.debe := 0;
            registro.debe01 := 0;
            registro.debe02 := 0;
            registro.haber := 0;
            registro.haber01 := 0;
            registro.haber02 := 0;
            registro.cuenta := j.ctagasto;
            registro.ccosto := j.ccosto;
            registro.subccosto := j.subccosto;
            registro.proyec := j.proyec;
            registro.regcomcol := '10';
            registro.importe := j.isc;
            CASE j.dh
                WHEN 'D' THEN
                    registro.dh := 'H';
                WHEN 'H' THEN
                    registro.dh := 'D';
                ELSE
                    NULL;
            END CASE;

            registro.impor01 := registro.importe * registro.tcambio01;
            registro.impor02 := registro.importe * registro.tcambio02;
            IF ( registro.dh = 'D' ) THEN
                registro.debe := registro.importe;
                registro.debe01 := registro.impor01;
                registro.debe02 := registro.impor02;
            ELSE
                registro.haber := registro.importe;
                registro.haber01 := registro.impor01;
                registro.haber02 := registro.impor02;
            END IF;

            dbms_output.put_line('ENTRE - IF N2 - IMPRIME - ' || j.isc);
            PIPE ROW ( registro );
        END IF;

        dbms_output.put_line('IF N3 - ' || j.otrtri);
        IF j.otrtri > 0 THEN
            dbms_output.put_line('ENTRE - IF N3 - IMPRIME - ' || j.otrtri);
            registro.importe := 0;
            registro.impor01 := 0;
            registro.impor02 := 0;
            registro.debe := 0;
            registro.debe01 := 0;
            registro.debe02 := 0;
            registro.haber := 0;
            registro.haber01 := 0;
            registro.haber02 := 0;
            registro.cuenta := j.ctagasto;
            registro.ccosto := j.ccosto;
            registro.subccosto := j.subccosto;
            registro.proyec := j.proyec;
            registro.regcomcol := '11';
            registro.importe := j.otrtri;
            CASE j.dh
                WHEN 'D' THEN
                    registro.dh := 'H';
                WHEN 'H' THEN
                    registro.dh := 'D';
                ELSE
                    NULL;
            END CASE;

            registro.impor01 := registro.importe * registro.tcambio01;
            registro.impor02 := registro.importe * registro.tcambio02;
            IF ( registro.dh = 'D' ) THEN
                registro.debe := registro.importe;
                registro.debe01 := registro.impor01;
                registro.debe02 := registro.impor02;
            ELSE
                registro.haber := registro.importe;
                registro.haber01 := registro.impor01;
                registro.haber02 := registro.impor02;
            END IF;

            dbms_output.put_line('ENTRE - IF N3 - IMPRIME - ' || j.otrtri);
            PIPE ROW ( registro );
        END IF;

        dbms_output.put_line('IF N4 - ' || j.factor);
        IF NOT ( ( j.factor = '0' ) OR ( j.factor = '00' ) OR ( j.factor = '000' ) ) THEN
            dbms_output.put_line('ENTRE - IF N4 - (TODAVIA NO IMPRIME) - ' || j.factor);
            SELECT
                dh,
                factor
            INTO
                v_dh,
                v_tipo
            FROM
                tdocume
            WHERE
                    id_cia = pin_id_cia
                AND codigo = j.tdocum;

            SELECT
                cuenta
            INTO v_cuenta
            FROM
                tfactor
            WHERE
                    id_cia = pin_id_cia
                AND tipo = v_tipo
                AND codfac = j.factor;

            registro.importe := 0;
            registro.impor01 := 0;
            registro.impor02 := 0;
            registro.debe := 0;
            registro.debe01 := 0;
            registro.debe02 := 0;
            registro.haber := 0;
            registro.haber01 := 0;
            registro.haber02 := 0;
            registro.cuenta := v_cuenta;
            registro.dh := v_dh;
            IF j.motivo = '1' OR j.tdocum = '02' THEN
                registro.regcomcol := '6';
            ELSIF j.motivo = '2' THEN
                registro.regcomcol := '8';
            ELSIF j.motivo = '3' THEN
                registro.regcomcol := '7';
            END IF;

            registro.importe := j.igv;
            IF j.tdocum <> '02' THEN
                CASE v_dh
                    WHEN 'D' THEN
                        registro.dh := 'H';
                    WHEN 'H' THEN
                        registro.dh := 'D';
                    ELSE
                        NULL;
                END CASE;
            END IF;

            registro.impor01 := registro.importe * registro.tcambio01;
            registro.impor02 := registro.importe * registro.tcambio02;
            IF ( registro.dh = 'D' ) THEN
                registro.debe := registro.importe;
                registro.debe01 := registro.impor01;
                registro.debe02 := registro.impor02;
            ELSE
                registro.haber := registro.importe;
                registro.haber01 := registro.impor01;
                registro.haber02 := registro.impor02;
            END IF;

            dbms_output.put_line('IF N5 - ' || registro.importe);
            IF registro.importe > 0 THEN
                dbms_output.put_line('ENTRE - IF N5 - IMPRIME - ' || registro.importe);
                -- VOLVIENDO A INICIALIZAR --  CCOSTO Y SUBCCO, para la cuenta de gasto, el igv y la cuenta 42 no debe tener esos valores
                registro.ccosto := NULL;
                registro.subccosto := NULL;
                PIPE ROW ( registro );
            END IF;

        END IF;  

           /* DECLARE
            BEGIN*/

        registro.importe := 0;
        registro.impor01 := 0;
        registro.impor02 := 0;
        registro.debe := 0;
        registro.debe01 := 0;
        registro.debe02 := 0;
        registro.haber := 0;
        registro.haber01 := 0;
        registro.haber02 := 0;
        registro.cuenta := j.cuenta;
        registro.dh := j.dh;
        SELECT
            regcomcol
        INTO v_regcomcol
        FROM
            pcuentas
        WHERE
                id_cia = pin_id_cia
            AND cuenta = j.cuenta;

        registro.regcomcol := v_regcomcol;
        IF j.tdocum = '02' THEN
            registro.importe := j.base;
        ELSE
            registro.importe := j.importe;
        END IF;

        registro.impor01 := registro.importe * registro.tcambio01;
        registro.impor02 := registro.importe * registro.tcambio02;
        IF ( registro.dh = 'D' ) THEN
            registro.debe := registro.importe;
            registro.debe01 := registro.impor01;
            registro.debe02 := registro.impor02;
        ELSE
            registro.haber := registro.importe;
            registro.haber01 := registro.impor01;
            registro.haber02 := registro.impor02;
        END IF;

        -- VOLVIENDO A INICIALIZAR --  CCOSTO Y SUBCCO, para la cuenta de gasto, el igv y la cuenta 42 no debe tener esos valores
        registro.ccosto := NULL;
        registro.subccosto := NULL;
        PIPE ROW ( registro );
        dbms_output.put_line('REGISTRO - SIEMPRE SE IMPRIME');
         /*   EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    registro.importe := 0;
            END;*/
        --  VOLVIENDO A CARGAR VALORES
        registro.ccosto := j.ccosto;
        registro.subccosto := j.subccosto;

            -- Cia.FacControlCxPDetracciones
            /*DECLARE
            BEGIN*/
        SELECT
            vstrg
        INTO v_vstrg
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 417;
            /*EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    V_VSTRG := NULL;
            END;*/
        dbms_output.put_line('IF N6 -' || v_vstrg);
        IF (
            (
                v_vstrg IS NOT NULL
                AND v_vstrg = 'S'
            )
            AND j.swafeccion = 2
            AND j.impdetrac > 0
        ) THEN
            registro.importe := 0;
            registro.impor01 := 0;
            registro.impor02 := 0;
            registro.debe := 0;
            registro.debe01 := 0;
            registro.debe02 := 0;
            registro.haber := 0;
            registro.haber01 := 0;
            registro.haber02 := 0;
            registro.id_cia := pin_id_cia;
            registro.cuenta := j.cuenta;
            --IF j.moneda = 'PEN' THEN
            registro.importe := j.impdetrac;
            -- ELSE
            --     registro.importe := j.impdetrac / j.tcamb01;
            -- END IF;

            registro.regcomcol := '80';
            CASE j.dh
                WHEN 'D' THEN
                    registro.dh := 'H';
                WHEN 'H' THEN
                    registro.dh := 'D';
                ELSE
                    NULL;
            END CASE;

            registro.impor01 := j.impdetrac;
            IF j.moneda = 'PEN' THEN
                registro.impor02 := j.impdetrac;
            ELSE
                registro.impor02 := j.impdetrac / j.tcamb01;
            END IF;
            -- registro.impor02 := registro.importe * registro.tcambio02;
            IF ( registro.dh = 'D' ) THEN
                registro.debe := registro.importe;
                registro.debe01 := registro.impor01;
                registro.debe02 := registro.impor02;
            ELSE
                registro.haber := registro.importe;
                registro.haber01 := registro.impor01;
                registro.haber02 := registro.impor02;
            END IF;

            dbms_output.put_line('ENTRE - IF N6 - IMPRIME - ' || v_vstrg);
            PIPE ROW ( registro );

                 -- CUENTA 2
            registro.importe := 0;
            registro.impor01 := 0;
            registro.impor02 := 0;
            registro.debe := 0;
            registro.debe01 := 0;
            registro.debe02 := 0;
            registro.haber := 0;
            registro.haber01 := 0;
            registro.haber02 := 0;
            registro.id_cia := pin_id_cia;
            registro.cuenta := j.cuentadetrac;
            --IF j.moneda = 'PEN' THEN
            registro.importe := j.impdetrac;
            -- ELSE
            --     registro.importe := j.impdetrac / j.tcamb01;
            -- END IF;

            registro.regcomcol := '80';
            CASE registro.dh
                WHEN 'D' THEN
                    registro.dh := 'H';
                WHEN 'H' THEN
                    registro.dh := 'D';
                ELSE
                    NULL;
            END CASE;

            registro.impor01 := j.impdetrac;
            IF j.moneda = 'PEN' THEN
                registro.impor02 := j.impdetrac;
            ELSE
                registro.impor02 := j.impdetrac / j.tcamb01;
            END IF;
            -- registro.impor02 := registro.importe * registro.tcambio02;
            IF ( registro.dh = 'D' ) THEN
                registro.debe := registro.importe;
                registro.debe01 := registro.impor01;
                registro.debe02 := registro.impor02;
            ELSE
                registro.haber := registro.importe;
                registro.haber01 := registro.impor01;
                registro.haber02 := registro.impor02;
            END IF;

            dbms_output.put_line('ENTRE2 - IF N6 - IMPRIME - ' || v_vstrg);
            PIPE ROW ( registro );
        END IF;

    END LOOP;
END sp_contabilidad_cuentas_predeterminadas_v2;

/
