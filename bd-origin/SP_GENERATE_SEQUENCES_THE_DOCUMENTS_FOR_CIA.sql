--------------------------------------------------------
--  DDL for Procedure SP_GENERATE_SEQUENCES_THE_DOCUMENTS_FOR_CIA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_GENERATE_SEQUENCES_THE_DOCUMENTS_FOR_CIA" (
    pin_id_cia IN NUMBER
)
    AUTHID current_user
AS

    CURSOR cur_documentos IS
    SELECT
        codigo,
        series,
        'GEN_DOC'
        || '_'
        || id_cia
        || '_'
        || codigo
        || '_'
        || series AS namesequence
    FROM
        documentos
    WHERE
        id_cia = pin_id_cia;

    v_namesecunce  VARCHAR2(80);
    v_maxnumdoc    NUMBER;
    V_343 VARCHAR2(1):='N';
BEGIN
--FORMA DE USO
--SET SERVEROUTPUT ON
--BEGIN
-- SP_GENERATE_SEQUENCES_THE_DOCUMENTS_FOR_CIA(13);
--END;
    FOR registro IN cur_documentos LOOP
        CASE
        /*CORRELATIVO DOCUMENTOS_CAB*/
            WHEN ( ( registro.codigo = 1 )   OR /*FACTURA*/
                   ( registro.codigo = 3 )   OR /*BOLETA*/
                   ( registro.codigo = 7 )   OR /*NOTA DE CREDITO*/
                   ( registro.codigo = 8 )   OR /*NOTA DE DEBITO*/
                   ( registro.codigo = 104 ) OR /*ORDEN DE PRODUCCION*/
                   ( registro.codigo = 101 ) OR /*ORDEN DE DESPACHO*/
                   ( registro.codigo = 108 ) OR /*GUIA DE RECEPCION*/
                   ( registro.codigo = 102 ) OR /*GUIA DE REMISION*/
                   ( registro.codigo = 103 ) OR /*GUIAS INTERNAS*/
                   ( registro.codigo = 111 ) OR /*TOMA DE INVENTARIO*/
                   ( registro.codigo = 41 ) /*CONSTANCIA DE PERCEPCION*/
                   ) THEN
                BEGIN
                    SELECT
                        nvl(MAX(numdoc), 0)
                    INTO v_maxnumdoc
                    FROM
                        documentos_cab
                    WHERE
                            id_cia = pin_id_cia
                        AND tipdoc = registro.codigo
                        AND series = registro.series;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_maxnumdoc := 0;
                END;
                alter_start_sequence(registro.namesequence, v_maxnumdoc + 1);
                /*CORRELATIVO DCTA105*/
            WHEN ( ( registro.codigo = 4 ) OR /*CHEQUE DEVUELTO*/
                   ( registro.codigo = 5 ) OR /*LETRAS DE CAMBIO*/
                   ( registro.codigo = 9 ) OR /*ANTICIPOS*/
                   ( registro.codigo = 6 ) OR /*CHEQUE DE COBRANZA FUTURA*/
                   ( registro.codigo = 43 )OR /*DEPOSITO NO IDENTIFICADO*/
                   ( registro.codigo = 44 ) 
                   ) THEN                
               IF  registro.series ='999' THEN
                 /* CODFAC = 343 CORRELATIVO DE se adiLETRAS X 100 */
                 BEGIN
                    SELECT
                        VSTRG
                    INTO V_343
                    FROM
                        FACTOR
                    WHERE
                            id_cia = pin_id_cia
                        AND CODFAC = 343;                
                 EXCEPTION
                    WHEN no_data_found THEN
                        V_343 := 'N';
                 END; 

                 BEGIN
                    SELECT
                        nvl(MAX(numdoc), 0)
                    INTO v_maxnumdoc
                    FROM
                        DCTA105
                    WHERE
                            id_cia = pin_id_cia
                        AND tipdoc = registro.codigo;

                 EXCEPTION
                    WHEN no_data_found THEN
                        v_maxnumdoc := 0;
                 END;  
                 IF ((V_343='S')AND(registro.codigo = 5)AND (v_maxnumdoc > 0)) THEN
                    v_maxnumdoc := TRUNC(v_maxnumdoc/100);
                 END IF;
                 alter_start_sequence(registro.namesequence, v_maxnumdoc + 1);
               END IF;
               /*CORRELATIVO COMPRAS COMPR010 */
             WHEN ( ( registro.codigo = 601 )  OR /*DOCUMENTO DE COMPRAS PROVEEDOR*/
                    ( registro.codigo = 602 )  OR /*RECIBOS POR HONORARIOS*/
                    ( registro.codigo = 610 )  OR /*CTAS. X PAGAR PROVEEDORES*/
                    ( registro.codigo = 611 )     /*REGISTRO DE RECIBOS*/
                   ) THEN
                BEGIN
                    SELECT
                        nvl(MAX(Docume), 0)
                    INTO v_maxnumdoc
                    FROM
                        COMPR010
                    WHERE
                            id_cia = pin_id_cia
                        AND tipo = registro.codigo;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_maxnumdoc := 0;
                END; 
                alter_start_sequence(registro.namesequence, v_maxnumdoc + 1);
               /*CORRELATIVO CAJA CHICA COMPR040 */
             WHEN ( 
                    ( registro.codigo = 603 )     /*CAJA EGRESOS*/
                   ) THEN
                BEGIN
                    SELECT
                        nvl(MAX(Docume), 0)
                    INTO v_maxnumdoc
                    FROM
                        COMPR040
                    WHERE
                            id_cia = pin_id_cia
                        AND tipo = registro.codigo;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_maxnumdoc := 0;
                END;  
                alter_start_sequence(registro.namesequence, v_maxnumdoc + 1);
               /*CORRELATIVO CONSTACIA DE RETENCION */
             WHEN ( 
                    ( registro.codigo = 20 )     /*CONSTACIA DE RETENCION*/
                   ) THEN
                IF  registro.series ='999' THEN                   
                BEGIN
                    SELECT
                        nvl(MAX(NUMERO), 0)
                    INTO v_maxnumdoc
                    FROM
                        RETENHEA
                    WHERE
                            id_cia = pin_id_cia
                        AND SERIE = registro.series;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_maxnumdoc := 0;
                END; 
                alter_start_sequence(registro.namesequence, v_maxnumdoc + 1);
                END IF;
                ELSE
                NULL;
        END CASE;

--        EXECUTE IMMEDIATE 'BEGIN   alter_start_sequence('
--                          || ''''
--                          || upper(registro.namesequence)
--                          || ''''
--                          || ','
--                          || to_char(v_maxnumdoc)
--                          || '); END;';
    END LOOP;
END sp_generate_sequences_the_documents_for_cia;

/
