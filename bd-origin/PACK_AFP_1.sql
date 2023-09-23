--------------------------------------------------------
--  DDL for Package Body PACK_AFP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_AFP" AS

    FUNCTION sp_buscar (
        pin_id_cia  IN  NUMBER,
        pin_codafp  IN  VARCHAR2,
        pin_nombre  IN  VARCHAR2,
        pin_codcla  IN  VARCHAR2,
        pin_dh      IN  VARCHAR2
    ) RETURN afpdatatable
        PIPELINED
    IS

        registro afpdatarecord := afpdatarecord(NULL, NULL, NULL, NULL, NULL,
              NULL, NULL, NULL, NULL, NULL,
              NULL, NULL, NULL);
        CURSOR cur_afp IS
        SELECT
            a.id_cia,
            a.codafp,
            a.nombre,
            a.codcta,
            a.codcla,
            cc.descri AS nomcla,
            a.dh,
            a.ucreac,
            a.uactua,
            a.fcreac,
            a.factua,
            a.codigo,
            a.abrevi
        FROM
            afp                    a
            LEFT JOIN clase_codigo_personal  cc ON cc.id_cia = a.id_cia
                                                  AND cc.clase = 11 /*REGIMEN PENSIONARIO*/
                                                  AND cc.codigo = a.codcla
        WHERE
                a.id_cia = pin_id_cia
            AND ( ( pin_codafp IS NULL )
                  OR ( a.codafp = pin_codafp ) )
            AND ( ( pin_nombre IS NULL )
                  OR ( a.nombre = pin_nombre ) )
            AND ( ( pin_codcla IS NULL )
                  OR ( a.codcla = pin_codcla ) )
            AND ( ( pin_dh IS NULL )
                  OR ( a.dh = pin_dh ) );

    BEGIN
        FOR j IN cur_afp LOOP
            registro.id_cia := j.id_cia;
            registro.codafp := j.codafp;
            registro.nombre := j.nombre;
            registro.codcta := j.codcta;
            registro.codcla := j.codcla;
            registro.nomcla := j.nomcla;
            registro.dh := j.dh;
            registro.ucreac := j.ucreac;
            registro.uactua := j.uactua;
            registro.fcreac := j.fcreac;
            registro.factua := j.factua;
            registro.codigo := j.codigo;
            registro.abrevi := j.abrevi;
            PIPE ROW ( registro );
        END LOOP;
    END sp_buscar;

--DECLARE
--    mensaje VARCHAR2(250);
--    cadjson VARCHAR2(1000);
--BEGIN
--    cadjson := '{
--            "codafp":"P",
--            "nombre":"PRUEBA",
--            "codcla":"P",
--            "codcta":"P",
--            "dh":"P",
--            "codigo":"P",
--            "abrevi":"P",
--            "ucreac":"admin",
--            "uactua":"admin"
--        }';
--    PACK_AFP.SP_SAVE(100,cadjson,1,mensaje);
--    DBMS_OUTPUT.PUT_LINE(mensaje);
--END;
--
--SELECT * FROM PACK_AFP.SP_BUSCAR(100,'P',NULL,NULL,NULL);

    PROCEDURE sp_save (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o         json_object_t;
        rec_afp   afp%rowtype;
        v_accion  VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_afp.id_cia := pin_id_cia;
        rec_afp.codafp := o.get_string('codafp');
        rec_afp.nombre := o.get_string('nombre');
        rec_afp.codcla := o.get_string('codcla');
        rec_afp.codcta := o.get_string('codcta');
        rec_afp.dh := o.get_string('dh');
        rec_afp.codigo := o.get_string('codigo');
        rec_afp.abrevi := o.get_string('abrevi');
        rec_afp.ucreac := o.get_string('ucreac');
        rec_afp.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO afp (
                    id_cia,
                    codafp,
                    nombre,
                    codcla,
                    codcta,
                    dh,
                    codigo,
                    abrevi,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_afp.id_cia,
                    rec_afp.codafp,
                    rec_afp.nombre,
                    rec_afp.codcla,
                    rec_afp.codcta,
                    rec_afp.dh,
                    rec_afp.codigo,
                    rec_afp.abrevi,
                    rec_afp.ucreac,
                    rec_afp.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE afp
                SET
                    nombre = rec_afp.nombre,
                    codcla = rec_afp.codcla,
                    codcta = rec_afp.codcta,
                    dh = rec_afp.dh,
                    codigo = rec_afp.codigo,
                    abrevi = rec_afp.abrevi,
                    uactua = rec_afp.uactua,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_afp.id_cia
                    AND codafp = rec_afp.codafp;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                
                DELETE FROM factor_afp
                WHERE
                        id_cia = rec_afp.id_cia
--                    AND anio = rec_factor_afp.anio
--                    AND mes = rec_factor_afp.mes
                    AND codafp = rec_afp.codafp;
--                    AND codfac = rec_factor_afp.codfac;
                
                DELETE FROM afp
                WHERE
                        id_cia = rec_afp.id_cia
                    AND codafp = rec_afp.codafp;

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
                    'message' VALUE 'El registro con codigo de AFP [ '
                                    || rec_afp.codafp
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
             IF sqlcode = -2291 THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'No se eliminar este registro porque hay [ '
                                    || rec_afp.codafp
                                    || ' ] factores de afp asociadas a este codigo '
                )
            INTO pin_mensaje
            FROM
                dual;

        ELSE
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
            ROLLBACK;
        END IF;
    END;
END;

/
