--------------------------------------------------------
--  DDL for Trigger DESPUES_ACTUALIZAR_COMPR010
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ACTUALIZAR_COMPR010" AFTER
    UPDATE ON "USR_TSI_SUITE".compr010
    FOR EACH ROW
DECLARE
/*
    v_conteo        NUMBER;
    v_conteo20      NUMBER;
    */
    v_fac_417       VARCHAR2(10);
    v_cuentadetrac  VARCHAR2(16);
    v_tcambio       NUMERIC(14, 6);
    v_serie         VARCHAR2(20);
    V_conteo NUMBER;
    v_numero        VARCHAR2(20);
    v_documento     VARCHAR2(40);
    v_limporte      NUMERIC(16, 2);
    v_limportemn    NUMERIC(16, 2);
    v_limporteme    NUMERIC(16, 2);
    v_impdetrac01   NUMERIC(16, 2);
    v_impdetrac02   NUMERIC(16, 2);
BEGIN
    IF ( :new.tcamb02 = 0 ) THEN
        v_tcambio := 0;
    ELSE
        v_tcambio := :new.tcamb01 / :new.tcamb02;
    END IF;

    IF ( :new.nserie IS NULL ) THEN
        v_serie := '';
    ELSE
        v_serie := :new.nserie;
    END IF;

    IF ( :new.numero IS NULL ) THEN
        v_numero := '';
    ELSE
        v_numero := :new.numero;
    END IF;

    v_documento := v_serie || v_numero;
    IF ( ( :new.situac = 0 ) OR ( :new.situac = 1 ) OR ( :new.situac = 8 ) OR ( :new.situac = 9 ) ) THEN --2011-10-24 - CUANDO GRABA COMPR10 DEBE ACTUALIZAR O INTERTAR PROV100 
        DELETE FROM prov100
        WHERE
                id_cia = :new.id_cia
            AND tipo = :new.tipo
            AND docu = :new.docume;

        DELETE FROM prov100
        WHERE
                id_cia = :new.id_cia
            AND tipo = 200
            AND docu = :new.docume; --DETRACCION 

        IF ( ( :new.situac = 8 ) OR ( :new.situac = 9 ) ) THEN
            DELETE FROM compr010guia
            WHERE
                    id_cia = :new.id_cia
                AND tipo = :new.tipo
                AND docume = :new.docume;  -- 2011-12-09 - CARLOS - CUANDO SE ANULE QUE ELIMINA GUIAS INTERNAS 

        END IF;

    ELSE
        IF (
            (
                ( ( :new.tipcaja IS NULL ) OR ( :new.tipcaja = 0 ) ) AND ( ( :new.doccaja IS NULL ) OR ( :new.doccaja = 0 ) )
            ) AND ( :new.situac = 2 )/*2-contabilizado*/
        ) THEN --2011-10-19 CARLOS - QUEDA SIN EFECTO ESTE FLAG QUE SOLO VALIDE CAJA CHICA - > AND (WSWFLAG IN ('S','A'))) THEN

            BEGIN
                SELECT
                    COUNT(0)
                INTO v_conteo
                FROM
                    prov100
                WHERE
                        id_cia = :new.id_cia
                    AND tipo = :new.tipo
                    AND docu = :new.docume;

            EXCEPTION
                WHEN no_data_found THEN
                    v_conteo := 0;
            END;

            /*
            BEGIN
                SELECT
                    COUNT(tipo)
                INTO v_conteo20
                FROM
                    prov100
                WHERE
                        id_cia = :new.id_cia
                    AND tipo = 200
                    AND docu = :new.docume;

            EXCEPTION
                WHEN no_data_found THEN
                    v_conteo20 := NULL;
            END;

            IF ( v_conteo20 IS NULL ) THEN
                v_conteo20 := 0;
            END IF;
            */
            BEGIN
                SELECT
                    vstrg
                INTO v_fac_417
                FROM
                    factor
                WHERE
                        id_cia = :new.id_cia
                    AND codfac = 417;/*Control de detracciones en provision de registro de compras en CxP*/

            EXCEPTION
                WHEN no_data_found THEN
                    v_fac_417 := NULL;
            END;

            IF ( v_fac_417 IS NULL ) THEN
                v_fac_417 := 'N';
            END IF;
            v_cuentadetrac := '';
            IF (
                    ( v_fac_417 = 'S' ) AND ( :new.impdetrac > 0 )
                AND ( :new.swafeccion = 2 )
            ) THEN
                v_impdetrac01 := :new.impdetrac;
                IF ( :new.moneda <> 'PEN' ) THEN
                    v_impdetrac02 := :new.impdetrac / :new.tcamb01;
                ELSE
                    v_impdetrac02 := :new.impdetrac / :new.tcamb02;
                END IF;

                IF ( :new.moneda = 'PEN' ) THEN
                    v_limporte := (
                        CASE
                            WHEN :new.tdocum = '02' THEN
                                :new.base
                            ELSE :new.importe
                        END
                    ) - v_impdetrac01;
                ELSE
                    v_limporte := (
                        CASE
                            WHEN :new.tdocum = '02' THEN
                                :new.base
                            ELSE :new.importe
                        END
                    ) - v_impdetrac02;
                END IF;

                v_limportemn := (
                    CASE
                        WHEN :new.tdocum = '02' THEN
                            :new.base01
                        ELSE :new.impor01
                    END
                ) - v_impdetrac01;

                v_limporteme := (
                    CASE
                        WHEN :new.tdocum = '02' THEN
                            :new.base02
                        ELSE :new.impor02
                    END
                ) - v_impdetrac02;

                BEGIN
                    SELECT
                        cuenta
                    INTO v_cuentadetrac
                    FROM
                        tfactor
                    WHERE
                            id_cia = :new.id_cia
                        AND tipo = 64 /*DETRACCION*/
                        AND vreal = :new.tdetrac / 10;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cuentadetrac := NULL;
                END;

                IF ( v_cuentadetrac IS NULL ) THEN
                    v_cuentadetrac := '';
                END IF;
            ELSE
                v_limporte := ( CASE
                    WHEN :new.tdocum = '02' THEN
                        :new.base
                    ELSE :new.importe
                END );

                v_limportemn := ( CASE
                    WHEN :new.tdocum = '02' THEN
                        :new.base01
                    ELSE :new.impor01
                END );

                v_limporteme := ( CASE
                    WHEN :new.tdocum = '02' THEN
                        :new.base02
                    ELSE :new.impor02
                END );

            END IF;



                IF ( v_conteo = 0 ) THEN
            INSERT INTO prov100 (
                id_cia,
                tipo,
                docu,
                codcli,
                tipdoc,
                docume,
                serie,
                numero,
                periodo,
                mes,
                femisi,
                fvenci,
                tipmon,
                importe,
                importemn,
                importeme,
                fcreac,
                factua,
                usuari,
                situac,
                cuenta,
                dh,
                tipcam,
                refere01,
                refere02,
                codsuc,
                codclir
            ) VALUES (
                :new.id_cia,
                :new.tipo,
                :new.docume,
                :new.codpro,
                :new.tdocum,
                v_documento,
                :new.nserie,
                :new.numero,
                :new.periodo,
                :new.mes,
                :new.femisi,
                :new.fvenci,
                :new.moneda,
                v_limporte,
                v_limportemn,
                v_limporteme,
                :new.fcreac,
                :new.factua,
                :new.usuari,
                :new.situac,
                :new.cuenta,
                :new.dh,
                v_tcambio,
                :new.refere,
                :new.refere02,
                :new.codsuc,
                :new.codclir
            );
            END IF;

            sp_actualiza_saldo_prov100(:new.id_cia, :new.tipo, :new.docume);
 /*           ELSE
                UPDATE prov100
                SET
                    tipo = :new.tipo,
                    docu = :new.docume,
                    codcli = :new.codpro,
                    tipdoc = :new.tdocum,
                    docume = v_documento,
                    serie = :new.nserie,
                    numero = :new.numero,
                    periodo = :new.periodo,
                    mes = :new.mes,
                    femisi = :new.femisi,
                    fvenci = :new.fvenci,
                    tipmon = :new.moneda,
                    importe = v_limporte,
                    importemn = v_limportemn,
                    importeme = v_limporteme,
                    fcreac = :new.fcreac,
                    factua = :new.factua,
                    usuari = :new.usuari,
                    situac = :new.situac,
                    cuenta = :new.cuenta,
                    dh = :new.dh,
                    tipcam = v_tcambio,
                    refere01 = :new.refere,
                    refere02 = :new.refere02,
                    codsuc = :new.codsuc,
                    codclir = :new.codclir
                WHERE
                        id_cia = :new.id_cia
                    AND tipo = :new.tipo
                    AND docu = :new.docume;

                sp_actualiza_saldo_prov100(:new.id_cia, :new.tipo, :new.docume);

            END IF;
            */
            IF (
                    ( v_fac_417 = 'S' ) AND ( :new.impdetrac > 0 )
                AND ( :new.swafeccion = 2 )
            ) THEN
            /*
                IF (
                        ( v_conteo20 = 0 ) AND ( ( :new.tipcaja IS NULL ) OR ( :new.tipcaja = 0 ) )
                    AND ( ( :new.doccaja IS NULL ) OR ( :new.doccaja = 0 ) )
                ) THEN
                */
                IF ( v_conteo = 0 ) THEN
                INSERT INTO prov100 (
                    id_cia,
                    tipo,
                    docu,
                    codcli,
                    tipdoc,
                    docume,
                    serie,
                    numero,
                    periodo,
                    mes,
                    femisi,
                    fvenci,
                    tipmon,
                    importe,
                    importemn,
                    importeme,
                    fcreac,
                    factua,
                    usuari,
                    situac,
                    cuenta,
                    dh,
                    tipcam,
                    refere01,
                    refere02,
                    codsuc,
                    codclir
                ) VALUES (
                    :new.id_cia,
                    200,
                    :new.docume,
                    :new.codpro,
                    'DE',
                    v_documento,
                    :new.nserie,
                    :new.numero,
                    :new.periodo,
                    :new.mes,
                    :new.femisi,
                    :new.fvenci,
                    'PEN',
                    v_impdetrac01,
                    v_impdetrac01,
                    v_impdetrac02,
                    :new.fcreac,
                    :new.factua,
                    :new.usuari,
                    :new.situac,
                    v_cuentadetrac,
                    :new.dh,
                    v_tcambio,
                    :new.refere,
                    :new.refere02,
                    :new.codsuc,
                    :new.codclir
                );
end if;
                sp_actualiza_saldo_prov100(:new.id_cia, 200, :new.docume);
/*
                ELSE
                    UPDATE prov100
                    SET
                        tipo = 200,
                        docu = :new.docume,
                        codcli = :new.codpro,
                        tipdoc = 'DE',
                        docume = v_documento,
                        serie = :new.nserie,
                        numero = :new.numero,
                        periodo = :new.periodo,
                        mes = :new.mes,
                        femisi = :new.femisi,
                        fvenci = :new.fvenci,
                        tipmon = 'PEN',
                        importe = v_impdetrac01,
                        importemn = v_impdetrac01,
                        importeme = v_impdetrac02,
                        fcreac = :new.fcreac,
                        factua = :new.factua,
                        usuari = :new.usuari,
                        situac = :new.situac,
                        cuenta = v_cuentadetrac,
                        dh = :new.dh,
                        tipcam = v_tcambio,
                        refere01 = :new.refere,
                        refere02 = :new.refere02,
                        codsuc = :new.codsuc,
                        codclir = :new.codclir
                    WHERE
                            id_cia = :new.id_cia
                        AND tipo = 200
                        AND docu = :new.docume;

                    sp_actualiza_saldo_prov100(:new.id_cia, 200, :new.docume);
                END IF;--V_CONTEO20
                */
            END IF;--( v_fac_417 = 'S' )

        END IF;--( :new.motcaja = 0 )
    END IF;--( ( :new.situac = 0 ) OR ( :new.situac = 1 ) OR ( :new.situac = 8 ) OR ( :new.situac = 9 ) )
  /* PARA ACTUALIZAR ALGUNOS DATOS COMO POR EJEMPLO EL CONCEPTO ; SE PUEDEN AÑADIR MAS */

    IF (
                    ( :new.periodo IS NOT NULL ) AND ( :new.mes IS NOT NULL )
                AND ( :new.libro IS NOT NULL )
            AND ( :new.asiento IS NOT NULL )
        AND ( :new.asiento > 0 )
    ) THEN
        UPDATE asienhea
        SET
            concep = :new.concep,
            codigo = :new.codpro,
            nombre = :new.razon,
            moneda = :new.moneda,
            fecha = :new.femisi,
            tcamb01 = :new.tcamb01,
            tcamb02 = :new.tcamb02,
            motivo = :new.motivo
        WHERE
                id_cia = :new.id_cia
            AND periodo = :new.periodo
            AND mes = :new.mes
            AND libro = :new.libro
            AND asiento = :new.asiento;

    END IF;

END;
/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ACTUALIZAR_COMPR010" ENABLE;
