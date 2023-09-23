--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_DCTA100
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DCTA100" BEFORE
    INSERT ON "USR_TSI_SUITE".dcta100
    FOR EACH ROW
DECLARE
    wcuenta     VARCHAR2(16);
    wdh         CHAR(1);
    wdiaven     INTEGER;
    wfecter     DATE;
    wcontrolfv  VARCHAR2(25);
BEGIN
    IF ( :new.codacep IS NULL OR :new.codacep = '' ) THEN
        :new.codacep := :new.codcli;
    END IF;
 /* 2014-11-28 - MODIFICADO  PARA QUE LAS LETRAS Y CHEQUES COB. FUTURA NO SE CALCULE FECHA VENCIMIENTO PUES YA VIENE CALCULADA */

    IF ( NOT ( :new.tipdoc IN (
        5,
        6
    ) ) ) THEN
        BEGIN
            SELECT
                p.diaven,
                d.fecter,
                cp.valor
            INTO
                wdiaven,
                wfecter,
                wcontrolfv
            FROM
                documentos_cab  d
                LEFT OUTER JOIN c_pago          p ON "USR_TSI_SUITE".p.id_cia = d.id_cia
                                            AND p.codpag = d.codcpag
                LEFT OUTER JOIN c_pago_clase    cp ON "USR_TSI_SUITE".cp.id_cia = p.id_cia
                                                   AND cp.codpag = p.codpag
                                                   AND cp.codigo = 4 /* CONTROL DE VENCIMIENTO*/
            WHERE
                    d.id_cia = :new.id_cia
                AND d.numint = :new.numint;

        EXCEPTION
            WHEN no_data_found THEN
                wdiaven := NULL;
                wfecter := NULL;
                wcontrolfv := NULL;
        END;

        IF ( NOT ( wcontrolfv = 'S' ) ) THEN
            IF ( wdiaven IS NULL ) THEN
                wdiaven := 0;
            END IF;
            IF ( wfecter > :new.femisi ) THEN
                :new.fvenci := :new.femisi + wdiaven;
            END IF;

        END IF;

    END IF;

    IF ( :new.tipdoc > 0 ) THEN
        wdh := NULL;
        wcuenta := NULL;
        BEGIN
            SELECT
                d.dh,
                c.codigo
            INTO
                wdh,
                wcuenta
            FROM
                     tdoccobranza d
                INNER JOIN cliente_clase       cc ON "USR_TSI_SUITE".cc.id_cia = d.id_cia
                                               AND ( cc.tipcli = 'A' )
                                               AND ( cc.codcli = :new.codcli )
                                               AND    /* SOLO CLIENTES */ ( cc.clase = 4 )          /* CLASE RELACIONADA / TERCEROS */
                INNER JOIN tdoccobranza_clase  c ON "USR_TSI_SUITE".c.id_cia = d.id_cia
                                                   AND c.tipdoc = d.tipdoc
                                                   AND c.clase =
                    CASE
                        WHEN :new.tipdoc = 41 THEN
                            CAST(cc.codigo AS INTEGER) - 2
                        ELSE
                            CASE
                                WHEN :new.tercero = 1 THEN
                                    CAST(66 AS INTEGER)
                                ELSE
                                    CAST(cc.codigo AS INTEGER)
                            END
                    END
                                                   AND /* LA CLASE VIENE DESDE EL CLIENTE_CLASE */ c.moneda = :new.tipmon
            WHERE
                    d.id_cia = :new.id_cia
                AND d.tipdoc = :new.tipdoc;

        EXCEPTION
            WHEN no_data_found THEN
                wdh := NULL;
                wcuenta := NULL;
        END;

        IF ( :new.operac IS NULL ) THEN
            :new.operac := 0;
        END IF;

        IF ( wdh IS NULL ) THEN
            wdh := 'D';
        END IF;
        IF ( wcuenta IS NULL ) THEN
            RAISE pkg_exceptionuser.ex_cuenta_en_blanco;
        ELSE
            :new.cuenta := wcuenta;
        END IF;

        :new.dh := wdh;
    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_cuenta_en_blanco THEN
        raise_application_error(pkg_exceptionuser.cuenta_en_blanco, 'CUENTA CONTABLE EN BLANCO');
END;

/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DCTA100" ENABLE;
