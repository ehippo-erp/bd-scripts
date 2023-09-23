--------------------------------------------------------
--  DDL for Package Body PACK_TMONEDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_TMONEDA" AS

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codmon IN NUMBER,
        pin_desmot IN VARCHAR2
    ) RETURN t_TMoneda
        PIPELINED
    IS
        v_table t_TMoneda;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            TMoneda
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_codmon IS NULL )
                  OR ( codmon = pin_codmon ) )
            AND ( ( pin_desmot IS NULL )
                  OR ( desmon = pin_desmot ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;
/*
set SERVEROUTPUT on;

DECLARE
    mensaje VARCHAR2(500);
    cadjson VARCHAR2(5000);
BEGIN
        cadjson := '{
            "codmon":LIB,
            "desmon":"LIBRAS",
			"abrevi":"LIB",
			"abrevi":"LIB",
			"simbolo":"LIB",
			"nacional":9,
			"cdifdeb":"cdifdeb",
			"cdifhab":"cdifhab",
			"codsunat":"codsunat",
			"codsunat":"20",
            "usuari":"admin",
            "swacti":"S",	
			"tcdesde":"2022-05-21",
			"tchasta":"2022-05-22",
        }';
        PACK_TMoneda.SP_SAVE(66,cadjson,1,mensaje);
        DBMS_OUTPUT.PUT_LINE(mensaje);
END;
SELECT *  FROM PACK_TMoneda.SP_BUSCAR(66,NULL,NULL);

*/
    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o         json_object_t;
        rec_TMoneda TMoneda%rowtype;
        v_accion  VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_TMoneda.id_cia := pin_id_cia;
        rec_TMoneda.codmon   :=o.get_string('codmon');
        rec_TMoneda.desmon   :=o.get_string('desmon'); 
        rec_TMoneda.abrevi   :=o.get_string('abrevi'); 
        rec_TMoneda.simbolo  :=o.get_string('simbolo');
        rec_TMoneda.nacional :=o.get_number('nacional');   
        rec_TMoneda.cdifdeb  :=o.get_string('cdifdeb');  
        rec_TMoneda.cdifhab  :=o.get_string('cdifhab');  
        rec_TMoneda.codsunat :=o.get_string('codsunat'); 
        rec_TMoneda.usuari   :=o.get_string('usuari');  
        rec_TMoneda.swacti   :=o.get_string('swacti');  
        rec_TMoneda.tcdesde  :=o.get_number('tcdesde');  
        rec_TMoneda.tchasta  :=o.get_number('tchasta');  
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO TMoneda (
                    id_cia,
                    codmon,   
                    desmon,   
                    abrevi,   
                    simbolo,  
                    nacional, 
                    cdifdeb,  
                    cdifhab,  
                    codsunat, 
                    fcreac,   
                    factua,   
                    usuari,   
                    swacti,   
                    tcdesde, 
                    tchasta
                ) VALUES (
                    rec_TMoneda.id_cia,
                    rec_TMoneda.codmon,   
                    rec_TMoneda.desmon,   
                    rec_TMoneda.abrevi,   
                    rec_TMoneda.simbolo,  
                    rec_TMoneda.nacional, 
                    rec_TMoneda.cdifdeb,  
                    rec_TMoneda.cdifhab,  
                    rec_TMoneda.codsunat, 
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),  
                    rec_TMoneda.usuari,   
                    rec_TMoneda.swacti,   
                    rec_TMoneda.tcdesde,  
                    rec_TMoneda.tchasta				
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE TMoneda
                SET
                    desmon=rec_TMoneda.desmon,   
                    abrevi=rec_TMoneda.abrevi,   
                    simbolo=rec_TMoneda.simbolo,  
                    nacional=rec_TMoneda.nacional, 
                    cdifdeb=rec_TMoneda.cdifdeb,  
                    cdifhab=rec_TMoneda.cdifhab,  
                    codsunat=rec_TMoneda.codsunat, 
                    factua=to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'), 
                    usuari=rec_TMoneda.swacti,   
                    tcdesde=rec_TMoneda.tcdesde,  
                    tchasta=rec_TMoneda.tchasta						
                WHERE
                        id_cia = rec_TMoneda.id_cia
                    AND codmon = rec_TMoneda.codmon;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM TMoneda
                WHERE
                        id_cia = rec_TMoneda.id_cia
                    AND codmon = rec_TMoneda.codmon;

                COMMIT;
        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
         WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con codigo de moneda [ '
                                    || rec_TMoneda.codmon
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_save;

END;

/
