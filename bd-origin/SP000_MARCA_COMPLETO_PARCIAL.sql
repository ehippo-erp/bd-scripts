--------------------------------------------------------
--  DDL for Procedure SP000_MARCA_COMPLETO_PARCIAL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_MARCA_COMPLETO_PARCIAL" (
    pid_cia     IN   NUMBER,
    pnumint     IN   NUMBER,
    ptipdoc     IN   NUMBER,
    pseries     IN   VARCHAR2,
    ptipmarca   IN   VARCHAR2,
    ptotal      IN   NUMBER,
    ppendiente  IN   NUMBER,
    pcoduser    IN   VARCHAR2,
    pstrsituac  OUT  VARCHAR2
) AS
    wsn       VARCHAR(1);
    wconteo   NUMBER;
    v_situac  VARCHAR(1);
BEGIN
    v_situac := 'X';
   /* MARCA COMPLETO */
    IF ( ptipmarca = 'C' ) THEN
        v_situac := 'H'; /* KACOM */
        IF ( ptipdoc = 102 ) THEN
            v_situac := 'C';
        END IF; /* 102- GUIA DE REMISION *//* C=KFACTU // 2008-08-26 SE SUPONE QUE LAS GUIAS SON ATENDIDAS SOLO CON FACTURAS... */
    END IF;
  /* MARCA PARCIAL */

    IF ( ptipmarca = 'P' ) THEN
        v_situac := 'G'; /* KAPAR */
        IF ( ptipdoc = 102 ) /* 102- GUIA DE REMISION  */ THEN
            IF ( ptotal <= ppendiente ) THEN
                v_situac := 'F'; /* F=KECTA;*/
            ELSE
                v_situac := 'G'; /* G=KAPAR; */
            END IF;

        END IF;

        IF ( ptipdoc = 103 ) /* 103- GUIA DE INTERNA   */ THEN
            v_situac := 'F';
        END IF; /* F=KECTA; */
        IF ( ( ptipdoc = 108 ) /* 108- GUIA DE RECEPCIÓN */ OR ( ptipdoc = 101 ) /* 101- ORDEN DE DESPACHO/PEDIDO */ ) THEN
            v_situac := 'G'; /* KAPAR */


        /*CARLOS - 2011-03-21- DESAPRUEBA LA ORDEN DE DESPACHO.. CADA VEZ QUE SE ATIENDE PARCIALMENTE..
                            ESTO ES VALIDO PARA TODOS LOS QUE DESOBLAPRO='S'
       */
            BEGIN
                SELECT
                    upper(t.vstrg) AS despoblapro
                INTO wsn
                FROM
                    documentos_clase t
                WHERE
                        t.id_cia = pid_cia
                    AND t.codigo = ptipdoc
                    AND t.series = pseries
                    AND t.clase = 50; /* 50 => KCLADOCUMENTOSDESOLBAPRO */

            EXCEPTION
                WHEN no_data_found THEN
                    wsn := '';
            END;

/*// 2011-03-22 SOLO SIRVEN PARA LOS DOCUMENTOS_CLASE QUE DIGA 'S'*/

            IF (
                ( NOT ( wsn IS NULL ) ) AND ( wsn = 'S' )
            ) THEN
                BEGIN
           /*// VERIFICA SI EXISTE DOCUMENTOS_APROBACION        */
                    SELECT
                        COUNT(0) AS conteo
                    INTO wconteo
                    FROM
                        documentos_aprobacion
                    WHERE
                            id_cia = pid_cia
                        AND numint = pnumint;

                EXCEPTION
                    WHEN no_data_found THEN
                        wconteo := 0;
                END;

                IF ( ( wconteo IS NULL ) OR ( wconteo = 0 ) ) THEN
                /* NO EXISTE */
                    INSERT INTO documentos_aprobacion (
                        id_cia,
                        numint,
                        situac,
                        fcreac,
                        ucreac
                    ) VALUES (
                        pid_cia,
                        pnumint,
                        'J',
                        sysdate,
                        pcoduser
                    );


                ELSE /* SI EXISTE */
                    UPDATE documentos_aprobacion
                    SET
                        situac = 'J', /* ANULADO */
                        factua = sysdate,
                        uactua = pcoduser
                    WHERE
                            id_cia = pid_cia
                        AND numint = pnumint;


                END IF;

            END IF;

        END IF;

    END IF;
    pstrsituac := v_situac;
END sp000_marca_completo_parcial;

/
