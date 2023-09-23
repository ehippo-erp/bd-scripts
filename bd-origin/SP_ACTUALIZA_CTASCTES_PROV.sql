--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_CTASCTES_PROV
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_CTASCTES_PROV" 
(
  PIN_ID_CIA IN NUMBER 
, PIN_TIPDOC IN VARCHAR2 
, PIN_NUMDOC IN NUMBER 
) AS 

   V_DUCUME VARCHAR2(12);

BEGIN


  FOR j IN (

    SELECT
        ID_CIA, TIPDOC, SERIES, NUMDOC, LIBRO, PERIODO, MES, 
        SECUENCIA, CODCLI, FEMISI, FVENCI, REFERE, TIPMON, TIPCAM, IMPORTE, IMPORTEMN, IMPORTEME, 
        TCAMB01, TCAMB02, IMPOR01, IMPOR02, CODCOB, COMISI, CODSUC, 
        FCREAC, FACTUA, USUARI, SITUAC, CUENTA, DH, CODBAN, CODVEN, OBSERV, TIPCAN, TIPO, DOCU, REFERE02
    FROM PROV105 P5
    WHERE P5.ID_CIA = PIN_ID_CIA
    AND P5.TIPDOC = PIN_TIPDOC
    AND P5.NUMDOC = PIN_NUMDOC
    AND NOT EXISTS (select * from PROV100 
                    where id_cia = P5.id_cia
                    AND TIPO = P5.TIPO
                    and DOCU = P5.DOCU)
  ) LOOP

      IF J.TIPDOC = '5' THEN
        V_DUCUME := J.NUMDOC;
      ELSE
        V_DUCUME := J.SERIES || J.NUMDOC;
      END IF;

      INSERT INTO PROV100 (
        ID_CIA, TIPO, DOCU, CODCLI, TIPDOC, DOCUME, SERIE, NUMERO, 
        PERIODO, MES, FEMISI, FVENCI, FCANCE, CODBAN, NUMBCO, REFERE01, 
        REFERE02, TIPMON, IMPORTE, IMPORTEMN, IMPORTEME, SALDO, SALDOMN, SALDOME, 
        CONCPAG, CODCOB, CODVEN, COMISI, CODSUC, CANCELADO, FCREAC, FACTUA, USUARI, SITUAC, CUENTA, 
        DH, TIPCAM, OPERAC, PROTES, XLIBRO, XPERIODO, XMES, XSECUENCIA, CODUBI, XPROTESTO, CODCLIR, FVENCI2
      ) VALUES (
        PIN_ID_CIA, J.TIPO, J.DOCU, J.CODCLI, J.TIPDOC, V_DUCUME, J.SERIES, J.NUMDOC, J.PERIODO, J.MES, 
        J.FEMISI, J.FVENCI, NULL/*FCANCE*/, J.CODBAN, NULL/*NUMBCO*/, J.REFERE, J.REFERE02, j.TIPMON, J.IMPORTE, J.IMPORTEMN, 
        J.IMPORTEME, J.IMPORTE/*SALDO*/, J.IMPORTEMN/*SALDOMN*/, J.IMPORTEME/*SALDOME*/, NULL /*CONCPAG*/, J.CODCOB, J.CODVEN, J.COMISI, 
        J.CODSUC, NULL /*CANCELADO*/, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP, 
        J.USUARI, J.SITUAC, J.CUENTA, J.DH, J.TIPCAM, NULL/*OPERAC*/, NULL/*PROTES*/, 
        NULL /*XLIBRO*/, 
        NULL /*XPERIODO*/, 
        NULL /*XMES*/, 
        NULL /*XSECUENCIA*/, 
        NULL /*CODUBI*/, 
        NULL /*XPROTESTO*/, 
        NULL /*CODCLIR*/, 
        NULL /*FVENCI2*/
      );
      COMMIT;

      SP_ACTUALIZA_SALDO_PROV100(PIN_ID_CIA, J.TIPO, J.DOCU);
      COMMIT;
    END LOOP;



END SP_ACTUALIZA_CTASCTES_PROV;

/