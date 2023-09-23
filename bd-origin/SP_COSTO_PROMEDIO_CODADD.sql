--------------------------------------------------------
--  DDL for Procedure SP_COSTO_PROMEDIO_CODADD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_COSTO_PROMEDIO_CODADD" (
    pin_id_cia    IN   NUMBER,
    pin_tipinv    IN   NUMBER,
    pin_periodo   IN   NUMBER,
    pout_mensaje  OUT  VARCHAR2
) AS

    wlocali        INTEGER;
    wtipinv        INTEGER;
    wcodart        VARCHAR(40);
    wcodadd01      VARCHAR(10);
    wcodadd02      VARCHAR(10);
    wperiodo       INTEGER;
    wid            CHAR(1);
    wfemisi        DATE;
    wmonto1        NUMERIC(16, 2);
    wmonto2        NUMERIC(16, 2);
    wcantid        DOUBLE PRECISION;
    wcospro        CHAR(1);
    wcostea        CHAR(1);
    wfactor        DOUBLE PRECISION;
    wpuni1         DOUBLE PRECISION;
    wpuni2         DOUBLE PRECISION;
    wcostot01      NUMERIC(16, 2);
    wcostot02      NUMERIC(16, 2);
    wcantid2       NUMERIC(16, 4);
    wlocali2       INTEGER;
    swcostxetique  VARCHAR(20);
    wetiqueta      VARCHAR(100);
    wcodalm        INTEGER;
    wdesmot        VARCHAR(60);
    wcodmot        INTEGER;
    wnumint        INTEGER;
    wnumite        INTEGER;
    wswdevprod     VARCHAR(1);
    wopnumdoc      INTEGER;
    wopnumite      INTEGER;
    wswhercosori   VARCHAR(1);
    tipo_costeo    VARCHAR(5);
    worden         INTEGER;

    V_CODART    VARCHAR(100);

BEGIN

   /*PASO 1: ELIMINAMOS DATOS DE ARTICULOS_COSTO DEL PERIODO ACTUAL*/
    DELETE FROM articulos_costo_codadd WHERE id_cia = pin_id_cia AND tipinv = pin_tipinv AND periodo = pin_periodo;

   /*PASO 2: INSERTAMOS REGISTROS DE ARTICULOS_COSTO DEL PERIODO ANTERIOR AL PERIODO ACTUAL*/
   INSERT INTO articulos_costo_codadd
   SELECT a.id_cia, a.tipinv, a.codart, a.codadd01, a.codadd02, pin_periodo, a.costo01    monto1, a.costo02    monto2, a.cantid FROM articulos_costo_codadd a
   WHERE a.id_cia = pin_id_cia AND a.tipinv = pin_tipinv AND a.periodo = pin_periodo - 1;

   /* 1 - COSTO PROMEDIO
      2 - COSTO MIXTO   */
   DECLARE
   BEGIN
       TIPO_COSTEO := NULL;
       SELECT CODIGO INTO TIPO_COSTEO FROM T_INVENTARIO_CLASE WHERE ID_CIA = pin_id_cia AND TIPINV = pin_tipinv AND CLASE = 4;
       IF (TIPO_COSTEO IS NULL) THEN
         TIPO_COSTEO := '2';
       END IF;   EXCEPTION
      WHEN NO_DATA_FOUND THEN
          TIPO_COSTEO := NULL;
   END;


    /*PASO3: OBTENEMOS DATOS DEL KARDEX DEL PERIODO ACTUAL*/
   FOR i IN (
        SELECT 
               CASE WHEN MC3.VALOR IS NULL THEN K.CODMOT ELSE CAST(MC3.VALOR AS INTEGER) END AS ORDEN,
               K.LOCALI,K.TIPINV,K.CODART,K.CODADD01,K.CODADD02,K.CODALM,K.ETIQUETA,K.PERIODO,K.ID,K.FEMISI,K.COSTOT01 MONTO1, K.COSTOT02 MONTO2,
               K.CANTID,M.COSPRO,M.COSTEA,CASE WHEN K.ID='S' THEN -1 ELSE 1 END AS FACTOR,
               K.CODMOT,M.DESMOT,K.NUMINT,K.NUMITE,MC1.VALOR,MC2.VALOR AS WSWHERCOSORI
            INTO WORDEN,WLOCALI, WTIPINV, WCODART,WCODADD01,WCODADD02, WCODALM,WETIQUETA,WPERIODO, WID, WFEMISI, WMONTO1, WMONTO2,
             WCANTID, WCOSPRO, WCOSTEA , WFACTOR,
             WCODMOT,WDESMOT,WNUMINT,WNUMITE,WSWDEVPROD,WSWHERCOSORI
        FROM KARDEX K
            INNER JOIN MOTIVOS M ON M.ID_CIA = K.ID_CIA AND M.TIPDOC=K.TIPDOC AND M.ID=K.ID AND M.CODMOT=K.CODMOT
            LEFT OUTER JOIN MOTIVOS_CLASE MC1 ON MC1.ID_CIA = K.ID_CIA AND MC1.TIPDOC=K.TIPDOC AND MC1.ID = K.ID AND MC1.CODMOT=K.CODMOT AND MC1.CODIGO=22  /* 22- DEVOLUCION DE PRODUCCION */
            LEFT OUTER JOIN MOTIVOS_CLASE MC2 ON MC2.ID_CIA = K.ID_CIA AND MC2.TIPDOC=K.TIPDOC AND MC2.ID = K.ID AND MC2.CODMOT=K.CODMOT AND MC2.CODIGO=32  /* 32- HEREDA COSTO UNITARIO POR RELACION DE ITEM */
            LEFT OUTER JOIN MOTIVOS_CLASE MC3 ON MC3.ID_CIA = K.ID_CIA AND MC3.TIPDOC=K.TIPDOC AND MC3.ID = K.ID AND MC3.CODMOT=K.CODMOT AND MC3.CODIGO=49  /* 49- ORDEN PARA PROCESO DE COSTEO */
        WHERE K.ID_CIA = pin_id_cia AND  K.TIPINV = pin_tipinv AND K.PERIODO=pin_periodo AND 
                (length(trim(k.codadd01)) is not null and (length(trim(k.codadd01)) > 1)) and
                (length(trim(k.codadd02)) is not null and (length(trim(k.codadd02)) > 1)) 
        ORDER BY K.CODART,K.CODADD01,K.CODADD02,K.FEMISI,K.ID,ORDEN

   ) LOOP

        /*2014-10-01 -  INICIALIZANDO LAS VARIABLES DE COSTEO */
              WPUNI1 :=0;
              WPUNI2 :=0;
              WCANTID2 :=0;

          /* INSERTA ARTICULOS_COSTO PERIODO ANTERIOR */
          V_CODART := NULL;
          DECLARE
          BEGIN
            SELECT T.CODART INTO V_CODART FROM ARTICULOS_COSTO_CODADD T 
            WHERE T.ID_CIA = pin_id_cia AND (T.TIPINV=WTIPINV) AND (T.CODART=WCODART) AND (T.CODADD01=WCODADD01) AND (T.CODADD02=WCODADD02) AND (T.PERIODO= pin_periodo-1);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_CODART := NULL;
          END;

          IF (V_CODART IS NULL) THEN           
              INSERT INTO ARTICULOS_COSTO_CODADD (ID_CIA , TIPINV,   CODART, CODADD01 , CODADD02 , PERIODO, COSTO01,COSTO02,CANTID)
                                 VALUES (pin_id_cia, WTIPINV, WCODART, WCODADD01, WCODADD02, pin_periodo-1, 0,0,0);
          END IF;

            /* INSERTA ARTICULOS_COSTO PERIODO ACTUAL */
          V_CODART := NULL;
          DECLARE
          BEGIN
             SELECT T.CODART INTO V_CODART FROM ARTICULOS_COSTO_CODADD T 
             WHERE T.ID_CIA = pin_id_cia AND  (T.TIPINV=WTIPINV) AND (T.CODART=WCODART) AND (T.CODADD01=WCODADD01) AND (T.CODADD02=WCODADD02) AND (T.PERIODO=pin_periodo);
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                V_CODART := NULL;
          END;

          IF (V_CODART IS NULL) THEN
            INSERT INTO ARTICULOS_COSTO_CODADD (ID_CIA, TIPINV,    CODART, CODADD01, CODADD02, PERIODO,COSTO01,COSTO02,CANTID)
                                    VALUES (pin_id_cia, WTIPINV, WCODART,WCODADD01,WCODADD02, pin_periodo, 0,0,0);
          END IF;

            /* NOTA EL WCOSPRO Y EL WCOSTEA JAMAS DEBEN SER AMBOS 'S'  PUES AMBOS GRABAN EN ARTICULOS_COSTO  */
             /* ------------------------------------------ SI ES COSTO PROMEDIO ----------------------------------------------- */
            IF (WCOSPRO='S') THEN   
                  /* ACTUALIZA DATOS DE ARTICULOS_COSTO*/
                  UPDATE ARTICULOS_COSTO_CODADD SET COSTO01 =CAST(COSTO01 + (WMONTO1 * WFACTOR) AS NUMERIC(11,2)),
                                                    COSTO02 =CAST(COSTO02 + (WMONTO2 * WFACTOR) AS NUMERIC(11,2)),
                                                    CANTID  =CAST(CANTID  + (WCANTID * WFACTOR) AS NUMERIC(11,2))
                    WHERE ID_CIA = pin_id_cia AND TIPINV=WTIPINV AND CODART=WCODART AND CODADD01=WCODADD01 AND CODADD02=WCODADD02 AND PERIODO=WPERIODO;
            END  IF; 

             /* --------------------------------------------- SI SE COSTEA ---------------------------------------------------- */
             IF (WCOSTEA='S') THEN

                 /* 2010-11-05- > SE COLOCO PARA SOLUCIONAR EL PROBLEMA DE INGRESO TRANSFERENCIA-CONSUMO ENTRE
                                 ALMACENES DE CONSUMO.. >=25 QUE SALEN CON UNA GUIA INTERNA Y HACE LOS 2 MOVIMIENTOS
                                 BUSCA LA SALIDA PARA PONERLE EL COSTO =
                 */
                     IF ((UPPER(WID)='I')AND(WCODMOT>=25)AND(UPPER(WDESMOT) LIKE '%CONSUMO%' ))  THEN
                            SELECT 
                                CANTID,
                                COSTOT01  /*(CASE WHEN CANTID=0 THEN 0 ELSE (COSTOT01/CANTID) END)*/ AS PUNI1 ,
                                COSTOT02  /*(CASE WHEN CANTID=0 THEN 0 ELSE (COSTOT02/CANTID) END )*/AS PUNI2
                                INTO WCANTID2, WPUNI1, WPUNI2        
                             FROM KARDEX
                             WHERE ID_CIA = pin_id_cia AND NUMINT = WNUMINT AND NUMITE = WNUMITE AND UPPER(ID)='S';
                             IF (WCANTID2 IS NULL) THEN WCANTID2 :=0;END IF;
                             IF (WPUNI1 IS NULL) THEN WPUNI1 :=0;END IF;
                             IF (WPUNI2 IS NULL) THEN WPUNI2 :=0; END IF;

                     ELSE 

                            IF ((LENGTH(WETIQUETA)>0)AND(TIPO_COSTEO='2')) THEN


                               SELECT CANTID, COSTOT01, COSTOT02 INTO WCANTID2, WPUNI1, WPUNI2
                               FROM KARDEX000
                               WHERE ID_CIA = pin_id_cia AND TIPINV = WTIPINV AND CODART = WCODART AND ETIQUETA=WETIQUETA;

                               IF (WCANTID2 IS NULL) THEN WCANTID2 :=0; END IF;
                               IF (WPUNI1 IS NULL) THEN WPUNI1:=0;END IF;
                               IF (WPUNI2 IS NULL) THEN WPUNI2:=0;END IF;

                             ELSE

                                      IF ((WID='I')AND(WSWDEVPROD='S')) THEN  /* SOLO PARA LOS INGRESOS POR DEVOLUCION DE PRODUCCION */

                                             /* OBTENGO LA ULTIMA SALIDA MAS CERCANA A ESTA DEVOLUCIÓN POR PRODUCCION */
                                            SELECT D.OPNUMDOC, D.OPNUMITE  INTO WOPNUMDOC, WOPNUMITE 
                                            FROM DOCUMENTOS_DET D WHERE D.ID_CIA = pin_id_cia AND  D.NUMINT= WNUMINT AND D.NUMITE=WNUMITE;

                                            IF (WOPNUMDOC IS NULL) THEN WOPNUMDOC := 0; END IF;
                                            IF (WOPNUMITE IS NULL) THEN WOPNUMITE := 0; END IF;

                                             SELECT MIN(K.LOCALI) INTO WLOCALI2
                                             FROM KARDEX K
                                             LEFT OUTER JOIN DOCUMENTOS_DET D ON D.ID_CIA = K.ID_CIA  AND  D.NUMINT=K.NUMINT AND D.NUMITE=K.NUMITE
                                             WHERE K.ID_CIA  = pin_id_cia   AND K.TIPINV  =WTIPINV   AND K.CODART  =WCODART   AND K.CODADD01=WCODADD01 AND K.CODADD02=WCODADD02 AND
                                                    K.CODALM  =WCODALM   AND K.LOCALI  <WLOCALI   AND K.CODMOT  =WCODMOT   AND /* BUSCA DEVOLUCION DEL MISMO MOTIVO */
                                                    K.ID      ='S'        AND D.NUMINT  =K.NUMINT   AND D.NUMITE  =K.NUMITE   AND
                                                    D.OPNUMDOC=WOPNUMDOC AND D.OPNUMITE=WOPNUMITE AND K.CANTID  <>0 AND K.COSTOT01<>0 AND K.COSTOT02<>0;


                                               IF (WLOCALI2 IS NULL) THEN WLOCALI2 :=0; END IF;

                                                SELECT 
                                                       CANTID,
                                                       COSTOT01 /* (CASE WHEN CANTID=0 THEN 0 ELSE (COSTOT01/CANTID) END) */ AS PUNI1 ,
                                                       COSTOT02 /* (CASE WHEN CANTID=0 THEN 0 ELSE (COSTOT02/CANTID) END) */ AS PUNI2
                                                INTO WCANTID2, WPUNI1, WPUNI2
                                                FROM KARDEX WHERE ID_CIA = pin_id_cia AND LOCALI=WLOCALI2;

                                      ELSIF ((WID='I')AND(WSWHERCOSORI='S')AND(LENGTH(WETIQUETA)>0)) THEN 

                                                 SELECT CANTID, COSTOT01, COSTOT02, LOCALI INTO WCANTID2, WPUNI1, WPUNI2, WLOCALI2
                                                 FROM KARDEX000
                                                 WHERE ID_CIA = pin_id_cia AND TIPINV =WTIPINV AND CODART =WCODART AND ETIQUETA=WETIQUETA;

                                                 IF (((WCANTID2 IS NULL)AND(WPUNI1 IS NULL)AND(WPUNI2 IS NULL))OR
                                                     ((WPUNI1=0)AND(WPUNI2=0)AND(WLOCALI=WLOCALI2))) THEN

                                                    SELECT D.CANTID,
                                                           CAST((D.MONAFE+D.MONINA) * CAST((CASE WHEN C.TIPMON='PEN' THEN 1.0 ELSE C.TIPCAM END) AS NUMERIC(16,2)) AS NUMERIC(16,2)),
                                                           CAST((D.MONAFE+D.MONINA) / CAST((CASE WHEN C.TIPMON='PEN' THEN C.TIPCAM ELSE 1.0 END)  AS NUMERIC(16,2)) AS NUMERIC(16,2))
                                                           INTO WCANTID2, WPUNI1, WPUNI2
                                                    FROM KARDEX K
                                                    LEFT OUTER JOIN DOCUMENTOS_DET D ON D.ID_CIA = K.ID_CIA AND D.NUMINT=K.NUMINT AND D.NUMITE=K.NUMITE
                                                    LEFT OUTER JOIN DOCUMENTOS_CAB C ON C.ID_CIA = K.ID_CIA AND C.NUMINT=K.NUMINT
                                                    WHERE K.ID_CIA = pin_id_cia AND K.LOCALI=WLOCALI;

                                                 END   IF;  

                                      ELSE


                                                /* OBTENGO PRECIOS UNITARIOS (SOLES/DOLARES)ARTICULO_COSTO*/
                                             SELECT CANTID, COSTO01, /* (CASE WHEN CANTID=0 THEN 0 ELSE COSTO01 END) AS PUNI1 */
                                                         COSTO02  /* (CASE WHEN CANTID=0 THEN 0 ELSE COSTO02 END) AS PUNI2 */
                                                         INTO WCANTID2, WPUNI1, WPUNI2
                                             FROM ARTICULOS_COSTO_CODADD
                                             WHERE ID_CIA = pin_id_cia AND TIPINV = WTIPINV AND CODART=WCODART AND CODADD01=WCODADD01 AND CODADD02=WCODADD02 AND PERIODO=WPERIODO;


                                      END IF;

                                      IF (WCANTID2 IS NULL) THEN WCANTID2:=0; END IF;
                                      IF (WPUNI1   IS NULL) THEN WPUNI1  :=0; END IF;
                                      IF (WPUNI2   IS NULL) THEN WPUNI2  :=0; END IF;  

                             END IF;

                     END IF;


                     /* 2014-10-01 - VALIDACION EN CASO QUE LA CANTIDAD SEA CERO PUES NO SE ESTABA INICIALIZANDO */
                 WCOSTOT01 :=0;
                 WCOSTOT02 :=0;
                 IF (WCANTID2<>0) THEN

                    WCOSTOT01 := round(((WPUNI1*WCANTID)/WCANTID2),2); /* AJUSTA A 2 DECIMALES */
                    WCOSTOT02 := round(((WPUNI2*WCANTID)/WCANTID2),2); /* AJUSTA A 2 DECIMALES */
                  END IF;

                     /* ACTUALIZO DATOS DE KARDEX  --> SE COSTEA*/
                 UPDATE KARDEX SET  COSTOT01 = WCOSTOT01, COSTOT02 = WCOSTOT02
                 WHERE ID_CIA = pin_id_cia AND LOCALI=WLOCALI; 

                    /* ACTUALIZA ARTICULOS_COSTO */
                 UPDATE ARTICULOS_COSTO_CODADD SET
                     COSTO01 =COSTO01 + (WCOSTOT01 *WFACTOR),
                     COSTO02 =COSTO02 + (WCOSTOT02 *WFACTOR),
                     CANTID  =CANTID  + (WCANTID   *WFACTOR)
                   WHERE ID_CIA = pin_id_cia AND TIPINV=WTIPINV AND CODART=WCODART AND CODADD01=WCODADD01 AND CODADD02=WCODADD02 AND PERIODO=WPERIODO;

             END IF;

   END LOOP;

END sp_costo_promedio_codadd;

/
