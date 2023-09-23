--------------------------------------------------------
--  DDL for Procedure SP_GENERA_DCTA101_PLANILLA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_GENERA_DCTA101_PLANILLA" (
    pin_id_cia      IN   NUMBER,
    pin_libro       IN   VARCHAR2,
    pin_periodo     IN   NUMBER,
    pin_mes         IN   NUMBER,
    pin_secuencia   IN   NUMBER,
    pin_coduser     IN   VARCHAR2
) AS
    v_lnumint NUMBER;

     v_numite number := 1;


BEGIN




    FOR i IN (
         SELECT
            p.id_cia,
            p.numint,         
            p.libro,
            p.periodo,
            p.mes,
            p.secuencia,
            p.item,
            p.tipcan,
            p.doccan,
            c.codcob,
            p.cuenta,
            p.dh,
            p.tipmon,
            p.amorti,
            p.impor01,
            p.impor02,
            p.tcamb01,
            p.tcamb02,
            p.impor01 * cr.porcom AS comision,
            c.codsuc,
            'A',
            c.femisi,
            d0.codcli,
            d0.numbco,
            d0.operac

        FROM
            dcta103    p
            LEFT OUTER JOIN dcta102    c ON c.id_cia = p.id_cia
                                         AND c.libro = p.libro
                                         AND c.periodo = p.periodo
                                         AND c.mes = p.mes
                                         AND c.secuencia = p.secuencia
            LEFT OUTER JOIN dcta100    d0 ON d0.id_cia = p.id_cia
                                          AND d0.numint = p.numint
            LEFT OUTER JOIN cobrador   cr ON cr.id_cia = p.id_cia
                                           AND cr.codcob = c.codcob
        WHERE p.id_cia = pin_id_cia
            and ( p.libro = pin_libro )
            AND ( p.periodo = pin_periodo )
            AND ( p.mes = pin_mes )
            AND ( p.secuencia = pin_secuencia )
            AND ( p.swchksepaga = 'S' )
            AND NOT ( p.situac = 'J' )

    ) LOOP


                            DECLARE
              BEGIN
                SELECT (MAX(numite) + 1) into  v_numite
                  FROM dcta101 
                  WHERE id_cia = i.id_cia 
                  and numint = i.numint;
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    v_numite := 1;
              END;

                if v_numite is null then
                    v_numite := 1;
                    end if;


                INSERT INTO dcta101 (
                    id_cia,
                    numint,
                    numite,
                    fproce,
                    libro,
                    periodo,
                    mes,
                    secuencia,
                    item,
                    tipcan,
                    doccan,
                    codcob,
                    cuenta,
                    dh,
                    tipmon,
                    importe,
                    impor01,
                    impor02,
                    tcamb01,
                    tcamb02,
                    comisi,
                    codsuc,
                    fcreac,
                    factua,
                    usuari,
                    situac,
                    femisi,
                    codcli,
                    codban,
                    numbco,
                    operac
    ) values (
            i.id_cia,
            i.numint,
            v_numite,
            current_date,
            i.libro,
            i.periodo,
            i.mes,
            i.secuencia,
            i.item,
            i.tipcan,
            i.doccan,
            i.codcob,
            i.cuenta,
            i.dh,
            i.tipmon,
            i.amorti,
            i.impor01,
            i.impor02,
            i.tcamb01,
            i.tcamb02,
            i.comision,
            i.codsuc,
            current_date,
            current_date,
            pin_coduser,
            'A',
            i.femisi,
            i.codcli,
            i.codcob,
            i.numbco,
            i.operac

    );


        COMMIT;



      END LOOP;



    FOR p IN (

        SELECT
            p.id_cia,
            p.numint,
            p.libro,
            p.periodo,
            p.mes,
            p.secuencia,
            p.item,
            p.tipcan,
            p.doccan,
            c.codcob,
            p.cuenta,
            p.dh,
            p.tipmon,
            p.amorti,
            p.impor01,
            p.impor02,
            p.tcamb01,
            p.tcamb02,
            p.impor01 * cr.porcom AS comision,
            c.codsuc,
            'A',
            c.femisi,
            d0.codcli,
            d0.numbco,
            d0.operac
        FROM
            dcta113    p
            LEFT OUTER JOIN dcta102    c ON c.id_cia = p.id_cia
                                         AND c.libro = p.libro
                                         AND c.periodo = p.periodo
                                         AND c.mes = p.mes
                                         AND c.secuencia = p.secuencia
            LEFT OUTER JOIN dcta100    d0 ON d0.id_cia = p.id_cia
                                          AND d0.numint = p.numint
            LEFT OUTER JOIN cobrador   cr ON cr.id_cia = p.id_cia
                                           AND cr.codcob = c.codcob
        WHERE p.id_cia = pin_id_cia
            and ( p.libro = pin_libro )
            AND ( p.periodo =  pin_periodo)
            AND ( p.mes = pin_mes )
            AND ( p.secuencia = pin_secuencia )
            AND ( p.swchksepaga = 'S' )
            AND NOT ( p.situac = 'J' )


    ) LOOP

               DECLARE
        BEGIN
     SELECT 
                (MAX(numite) +1 )  into v_numite FROM dcta101 
            WHERE id_cia = p.id_cia 
            and numint = p.numint;        EXCEPTION
           WHEN NO_DATA_FOUND THEN
            v_numite := 1;
        END;

                     if v_numite is null then
                    v_numite := 1;
                    end if;


             INSERT INTO dcta101 (
        id_cia,
        numint,
        numite,
        fproce,
        libro,
        periodo,
        mes,
        secuencia,
        item,
        tipcan,
        doccan,
        codcob,
        cuenta,
        dh,
        tipmon,
        importe,
        impor01,
        impor02,
        tcamb01,
        tcamb02,
        comisi,
        codsuc,
        fcreac,
        factua,
        usuari,
        situac,
        femisi,
        codcli,
        codban,
        numbco,
        operac
    ) values (

            p.id_cia,
            p.numint,
            v_numite,
            current_date,
            p.libro,
            p.periodo,
            p.mes,
            p.secuencia,
            p.item,
            p.tipcan,
            p.doccan,
            p.codcob,
            p.cuenta,
            p.dh,
            p.tipmon,
            p.amorti,
            p.impor01,
            p.impor02,
            p.tcamb01,
            p.tcamb02,
            p.comision,
            p.codsuc,
            current_date,
            current_date,
            pin_coduser,
            'A',
            p.femisi,
            p.codcli,
            p.codcob,
            p.numbco,
            p.operac

    );
    COMMIT;


      END LOOP;

    FOR j IN (
        SELECT numint FROM dcta103 p
        WHERE p.id_cia = pin_id_cia
            and ( p.libro = pin_libro )
            AND ( p.periodo = pin_periodo )
            AND ( p.mes = pin_mes )
            AND ( p.secuencia = pin_secuencia )
            AND ( p.swchksepaga = 'S' )
            AND NOT ( p.situac = 'J' )

        UNION
        SELECT numint FROM dcta113 p
        WHERE p.id_cia = pin_id_cia
            and ( p.libro = pin_libro )
            AND ( p.periodo = pin_periodo )
            AND ( p.mes = pin_mes )
            AND ( p.secuencia = pin_secuencia )
            AND ( p.swchksepaga = 'S' )
            AND NOT ( p.situac = 'J' )

    ) LOOP
        sp_actualiza_saldo_dcta100(pin_id_cia, j.numint);
        COMMIT;
    END LOOP;

END sp_genera_dcta101_planilla;

/
