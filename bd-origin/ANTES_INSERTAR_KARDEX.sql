--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_KARDEX
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_KARDEX" BEFORE
    INSERT ON "USR_TSI_SUITE".kardex
    FOR EACH ROW
DECLARE
    v_ingreso        NUMERIC(11, 4);
    v_salida         NUMERIC(11, 4);
    v_royoing        NUMERIC(11, 4);
    v_royosal        NUMERIC(11, 4);
    v_cant           NUMBER;
    v_fecing         TIMESTAMP;
    v_fecsal         TIMESTAMP;
    v_consto         NUMBER;
    v_ruccia         VARCHAR2(20);
    v_etiqueta       VARCHAR2(100);
    v_atipinv        NUMBER;
    v_costocero      VARCHAR2(3);
    v_namegenerador  VARCHAR2(60);
    v_count          NUMBER := 0;
BEGIN
    v_namegenerador := upper('GEN_KARDEX_')
                       || :new.id_cia;
    IF ( ( :new.locali IS NULL ) OR ( :new.locali < 1 ) ) THEN
--        IF ( :new.etiqueta IS NULL ) THEN
--            :new.etiqueta := ' ';
--        END IF;
--
--        IF ( :new.codadd01 IS NULL ) THEN
--            :new.codadd01 := ' ';
--        END IF;
--
--        IF ( :new.codadd02 IS NULL ) THEN
--            :new.codadd02 := ' ';
--        END IF;
  /*IF (V_RUCCIA='20259659907') THEN SELECT RESULTADO FROM SP000_QUITA_CARACTER_TEXTO(' ',:new.CODART) INTO :new.CODART;*/

        IF ( :new.cantid IS NULL ) THEN
            :new.cantid := 0;
        END IF;

        IF ( :new.costot01 IS NULL ) THEN
            :new.costot01 := 0;
        END IF;

        IF ( :new.costot02 IS NULL ) THEN
            :new.costot02 := 0;
        END IF;

        IF ( :new.fobtot01 IS NULL ) THEN
            :new.fobtot01 := 0;
        END IF;

        IF ( :new.fobtot02 IS NULL ) THEN
            :new.fobtot02 := 0;
        END IF;

        IF ( :new.royos IS NULL ) THEN
            :new.royos := 0;
        END IF;

        IF ( :new.cosmat01 IS NULL ) THEN
            :new.cosmat01 := 0;
        END IF;

        IF ( :new.cosmob01 IS NULL ) THEN
            :new.cosmob01 := 0;
        END IF;

        IF ( :new.cosfab01 IS NULL ) THEN
            :new.cosfab01 := 0;
        END IF;

        BEGIN
            SELECT
                valor
            INTO v_costocero
            FROM
                motivos_clase
            WHERE
                    id_cia = :new.id_cia
                AND tipdoc = :new.tipdoc
                AND id = :new.id
                AND codmot = :new.codmot
                AND codigo = 47;

        EXCEPTION
            WHEN no_data_found THEN
                v_costocero := NULL;
        END;

        v_costocero := ( CASE
            WHEN v_costocero IS NULL THEN
                'N'
            ELSE v_costocero
        END );
        IF ( v_costocero = 'S' ) THEN
            :new.costot01 := 0;
            :new.costot02 := 0;
        END IF;

        BEGIN
            SELECT
                COUNT(0)
            INTO v_count
            FROM
                user_sequences
            WHERE
                upper(sequence_name) = v_namegenerador;

        EXCEPTION
            WHEN no_data_found THEN
                v_count := 0;
        END;

        IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
            RAISE pkg_exceptionuser.ex_gen_documentos_cab_log;
        END IF;

        IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
            RAISE pkg_exceptionuser.ex_gen_kardex;
        END IF;

        IF ( ( :new.locali IS NULL ) OR ( :new.locali < 1 ) ) THEN
            EXECUTE IMMEDIATE 'select '
                              || v_namegenerador
                              || '.NEXTVAL FROM DUAL'
            INTO v_count;
            :new.locali := v_count;



        END IF;

        IF (
                ( :new.tipdoc = 111 ) AND ( :new.codmot = 5 )
            AND ( extract(MONTH FROM :new.femisi) = 1 )
        ) THEN
            :new.periodo := extract(YEAR FROM :new.femisi) * 100;
        END IF;

        v_consto := 0;
        BEGIN
            SELECT
                codart,
                consto
            INTO
                :new.codart,
                v_consto
            FROM
                articulos
            WHERE
                    id_cia = :new.id_cia
                AND tipinv = :new.tipinv
                AND codart = :new.codart;

        EXCEPTION
            WHEN no_data_found THEN
                v_consto := NULL;
        END;

        IF ( v_consto IS NULL ) THEN
            v_consto := 0;
        END IF;
        IF ( v_consto > 0 ) THEN
            BEGIN
                SELECT
                    tipinv,
                    ingreso,
                    salida
                INTO
                    v_atipinv,
                    v_ingreso,
                    v_salida
                FROM
                    articulos_almacen
                WHERE
                        id_cia = :new.id_cia
                    AND tipinv = :new.tipinv
                    AND codart = :new.codart
                    AND codalm = :new.codalm
                    AND periodo = :new.periodo;

            EXCEPTION
                WHEN no_data_found THEN
                    v_atipinv := NULL;
                    v_ingreso := NULL;
                    v_salida := NULL;
            END;

            IF ( v_salida IS NULL ) THEN
                v_salida := 0;
            END IF;
            IF ( v_ingreso IS NULL ) THEN
                v_ingreso := 0;
            END IF;
            IF ( upper(:new.id) = 'S' ) THEN
                v_salida := v_salida + :new.cantid;
            END IF;

            IF ( upper(:new.id) = 'I' ) THEN
                v_ingreso := v_ingreso + :new.cantid;
            END IF;

            IF ( v_atipinv IS NULL ) THEN
                v_cant := 0;
            ELSE
                v_cant := 1;
            END IF;

            IF ( v_cant = 0 ) THEN
                INSERT INTO articulos_almacen (
                    id_cia,
                    tipinv,
                    codart,
                    codalm,
                    periodo,
                    ingreso,
                    salida
                ) VALUES (
                    :new.id_cia,
                    :new.tipinv,
                    :new.codart,
                    :new.codalm,
                    :new.periodo,
                    v_ingreso,
                    v_salida
                );

            ELSE
                UPDATE articulos_almacen
                SET
                    ingreso = v_ingreso,
                    salida = v_salida
                WHERE
                        id_cia = :new.id_cia
                    AND tipinv = :new.tipinv
                    AND codart = :new.codart
                    AND codalm = :new.codalm
                    AND periodo = :new.periodo;

            END IF;

            IF (
                ( :new.codadd01 <> '' ) AND ( :new.codadd02 <> '' )
            ) THEN
                BEGIN
                    SELECT
                        tipinv,
                        ingreso,
                        salida
                    INTO
                        v_atipinv,
                        v_ingreso,
                        v_salida
                    FROM
                        articulos_almacen_codadd
                    WHERE
                            id_cia = :new.id_cia
                        AND tipinv = :new.tipinv
                        AND codart = :new.codart
                        AND codadd01 = :new.codadd01
                        AND codadd02 = :new.codadd02
                        AND codalm = :new.codalm
                        AND periodo = :new.periodo;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_atipinv := NULL;
                        v_ingreso := NULL;
                        v_salida := NULL;
                END;

                IF ( v_atipinv IS NULL ) THEN
                    v_cant := 0;
                ELSE
                    v_cant := 1;
                END IF;

                IF ( v_cant = 0 ) THEN
                    INSERT INTO articulos_almacen_codadd (
                        id_cia,
                        tipinv,
                        codart,
                        codadd01,
                        codadd02,
                        codalm,
                        periodo,
                        ingreso,
                        salida
                    ) VALUES (
                        :new.id_cia,
                        :new.tipinv,
                        :new.codart,
                        :new.codadd01,
                        :new.codadd02,
                        :new.codalm,
                        :new.periodo,
                        v_ingreso,
                        v_salida
                    );

                ELSE
                    UPDATE articulos_almacen_codadd
                    SET
                        ingreso = v_ingreso,
                        salida = v_salida
                    WHERE
                            id_cia = :new.id_cia
                        AND tipinv = :new.tipinv
                        AND codart = :new.codart
                        AND codadd01 = :new.codadd01
                        AND codadd02 = :new.codadd02
                        AND codalm = :new.codalm
                        AND periodo = :new.periodo;

                END IF;

            END IF;


            IF ( ( :new.etiqueta IS NOT NULL ) and ( length( trim(:new.etiqueta)) > 0 ) ) THEN
    /* SOLO POR INGRESO  1 VES */


                IF ( :new.id = 'I' ) THEN
                    BEGIN
                        SELECT
                            COUNT(0)
                        INTO v_cant
                        FROM
                            kardex000
                        WHERE
                                id_cia = :new.id_cia
                            AND etiqueta = :new.etiqueta;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_cant := NULL;
                    END;

                    IF ( v_cant IS NULL ) THEN
                        v_cant := 0;
                    END IF;

                    IF ( v_cant = 0 ) THEN  /* SOLO INSERTA UNA VEZ */
                        INSERT INTO kardex000 (
                            id_cia,
                            etiqueta,
                            locali,
                            tipinv,
                            codart,
                            codalm,
                            cantid,
                            costot01,
                            costot02,
                            fingreso,
                            numint,
                            numite,
                            codmot,
                            coduseractu
                        ) VALUES (
                            :new.id_cia,
                            :new.etiqueta,
                            :new.locali,
                            :new.tipinv,
                            :new.codart,
                            :new.codalm,
                            :new.cantid,
                            :new.costot01,
                            :new.costot02,
                            :new.femisi,
                            :new.numint,
                            :new.numite,
                            :new.codmot,
                            :new.usuari
                        );

--                ELSE
--                    IF (
--                            ( :new.id = 'I' ) AND ( :new.tipdoc = 111 )
--                        AND ( substr2(:new.periodo, 5, 6) = '00' )
--                    ) THEN
--                        UPDATE kardex000
--                        SET
--                            cantid_ap = :new.cantid,
--                            costot01_ap = :new.costot01,
--                            costot02_ap = :new.costot02
--                        WHERE
--                                id_cia = :new.id_cia
--                            AND etiqueta = :new.etiqueta;
--
--                    END IF;

                    END IF;

                END IF;

                v_ingreso := NULL;
                v_salida := NULL;
                v_royoing := NULL;
                v_royosal := NULL;
                v_fecing := NULL;
                v_fecsal := NULL;

    /*SELECT COUNT(*) FROM KARDEX001
      WHERE TIPINV=:new.TIPINV AND CODART=:new.CODART AND CODALM=:new.CODALM AND ETIQUETA=:new.ETIQUETA
     INTO :V_CANT;*/
                BEGIN
                    SELECT
                        etiqueta,
                        ingreso,
                        salida,
                        royoing,
                        royosal,
                        fingreso,
                        fsalida
                    INTO
                        v_etiqueta,
                        v_ingreso,
                        v_salida,
                        v_royoing,
                        v_royosal,
                        v_fecing,
                        v_fecsal
                    FROM
                        kardex001
                    WHERE
                            id_cia = :new.id_cia
                        AND tipinv = :new.tipinv
                        AND codart = :new.codart
                        AND codalm = :new.codalm
                        AND etiqueta = :new.etiqueta;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_etiqueta := NULL;
                        v_ingreso := NULL;
                        v_salida := NULL;
                        v_royoing := NULL;
                        v_royosal := NULL;
                        v_fecing := NULL;
                        v_fecsal := NULL;
                END;

                IF ( v_etiqueta IS NULL ) THEN
                    v_cant := 0;
                ELSE
                    v_cant := 1;
                END IF;

                IF ( v_salida IS NULL ) THEN
                    v_salida := 0;
                END IF;
                IF ( v_ingreso IS NULL ) THEN
                    v_ingreso := 0;
                END IF;
                IF ( v_royosal IS NULL ) THEN
                    v_royosal := 0;
                END IF;
                IF ( v_royoing IS NULL ) THEN
                    v_royoing := 0;
                END IF;
                IF ( upper(:new.id) = 'S' ) THEN
                    v_salida := v_salida + :new.cantid;
                    v_royosal := v_royosal + :new.royos;
                    v_fecsal := :new.femisi;
                ELSE
                    IF ( upper(:new.id) = 'I' ) THEN
                        v_ingreso := v_ingreso + :new.cantid;
                        v_royoing := v_royoing + :new.royos;
                        v_fecing := :new.femisi;
                    END IF;
                END IF;

                IF ( v_cant = 0 ) THEN
                    IF ( :new.id = 'I' ) THEN
                        INSERT INTO kardex001 (
                            id_cia,
                            tipinv,
                            codart,
                            codalm,
                            etiqueta,
                            ingreso,
                            salida,
                            royoing,
                            royosal,
                            fingreso,
                            fsalida,
                            swacti,
                            opnumdoc,
                            optramo,
                            codcli,
                            numint,
                            numite,
                            ubica,
                            codadd01,
                            codadd02
                        ) VALUES (
                            :new.id_cia,
                            :new.tipinv,
                            :new.codart,
                            :new.codalm,
                            :new.etiqueta,
                            v_ingreso,
                            v_salida,
                            v_royoing,
                            v_royosal,
                            v_fecing,
                            v_fecsal,
                            0,
                            :new.opnumdoc,
                            :new.optramo,
                            :new.codcli,
                            :new.numint,
                            :new.numite,
                            :new.ubica,
                            :new.codadd01,
                            :new.codadd02
                        );

                    ELSE
                        INSERT INTO kardex001 (
                            id_cia,
                            tipinv,
                            codart,
                            codalm,
                            etiqueta,
                            ingreso,
                            salida,
                            royoing,
                            royosal,
                            fingreso,
                            fsalida,
                            swacti,
                            codadd01,
                            codadd02
                        ) VALUES (
                            :new.id_cia,
                            :new.tipinv,
                            :new.codart,
                            :new.codalm,
                            :new.etiqueta,
                            v_ingreso,
                            v_salida,
                            v_royoing,
                            v_royosal,
                            v_fecing,
                            v_fecsal,
                            0,
                            :new.codadd01,
                            :new.codadd02
                        );

                    END IF;
                ELSE
                    IF ( :new.id = 'I' ) THEN

                    DBMS_OUTPUT.PUT_LINE(':new.id');

                        IF (
                            ( :new.tipdoc = 111 ) AND ( :new.codmot = 5 )
                        ) THEN  /* LOS AJUSTES DE INVENTARIO NO SE ACTUALIZAN */
                            :new.tipdoc := 111;
              /* NO ACTUALIZARA EL KARDEX SI INGRESO, PARA QUE NO MODIFIQUE */
              /*UPDATE KARDEX001 SET INGRESO=:V_INGRESO , SALIDA =:V_SALIDA,
                                   ROYOING=:V_ROYOING , ROYOSAL=:V_ROYOSAL
              WHERE TIPINV=:new.TIPINV AND CODART=:new.CODART AND CODALM=:new.CODALM AND ETIQUETA=:new.ETIQUETA; */
                        ELSE
                            UPDATE kardex001
                            SET
                                ingreso = v_ingreso,
                                salida = v_salida,
                                fingreso = v_fecing,
                                fsalida = v_fecsal,
                                royoing = v_royoing,
                                royosal = v_royosal,
                                opnumdoc = :new.opnumdoc,
                                optramo = :new.optramo,
                                codcli = :new.codcli,
                                swacti =
                                    CASE
                                        WHEN ( :new.codmot IN (
                                            1,
                                            28
                                        ) )
                                             OR ( v_ingreso - v_salida ) > 0
                                             AND :new.tipdoc = 103 THEN
                                            0
                                        ELSE
                                            :new.swacti
                                    END,
                                numint = :new.numint,
                                numite = :new.numite,
                                codadd01 =
                                    CASE
                                        WHEN ( :new.tipdoc = 103 ) THEN
                                            :new.codadd01
                                        ELSE
                                            codadd01
                                    END,
                                codadd02 =
                                    CASE
                                        WHEN ( :new.tipdoc = 103 ) THEN
                                            :new.codadd02
                                        ELSE
                                            codadd02
                                    END
                            WHERE
                                    id_cia = :new.id_cia
                                AND tipinv = :new.tipinv
                                AND codart = :new.codart
                                AND codalm = :new.codalm
                                AND etiqueta = :new.etiqueta;

                        END IF;

                    ELSE
                        UPDATE kardex001
                        SET
                            ingreso = v_ingreso,
                            salida = v_salida,
                            royoing = v_royoing,
                            royosal = v_royosal,
                            fingreso = v_fecing,
                            fsalida = v_fecsal,
                            swacti =
                                CASE
                                    WHEN ( ( :new.tipdoc = 103 )
                                           AND ( swacti = 1 ) ) THEN
                                        1
                                    ELSE
                                        :new.swacti
                                END
                        WHERE
                                id_cia = :new.id_cia
                            AND tipinv = :new.tipinv
                            AND codart = :new.codart
                            AND codalm = :new.codalm
                            AND etiqueta = :new.etiqueta;

                    END IF;--( :new.id = 'I' )--
                END IF;---( v_cant = 0 )

            END IF;---( :new.etiqueta IS NOT NULL ) AND ( :new.etiqueta <> '' )

        END IF;---( v_consto > 0 )

    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_gen_kardex THEN
        raise_application_error(pkg_exceptionuser.gen_kardex_no_existe, 'Generador ['
                                                                        || v_namegenerador
                                                                        || '] no existe');
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_KARDEX" ENABLE;
