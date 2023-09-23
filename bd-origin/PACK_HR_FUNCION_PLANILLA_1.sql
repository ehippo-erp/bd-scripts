--------------------------------------------------------
--  DDL for Package Body PACK_HR_FUNCION_PLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_FUNCION_PLANILLA" AS

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codfun IN INTEGER,
        pin_nombre IN VARCHAR2
    ) RETURN datatable_funcion_planilla
        PIPELINED
    IS
        v_table datatable_funcion_planilla;
    BEGIN
        SELECT
            fp.id_cia,
            fp.codfun,
            fp.nombre,
            fp.nomfun,
            fp.tipfun,
            tfp.destipfun,
            fp.nummes,
            fp.pactual,
            fp.mactual,
            fp.observ,
            fp.fcreac,
            fp.factua,
            fp.ucreac,
            fp.uactua
        BULK COLLECT
        INTO v_table
        FROM
            funcion_planilla   fp
            LEFT OUTER JOIN pack_hr_funcion_planilla.sp_buscar_tipofuncion(fp.id_cia,
                                                                           nvl(fp.tipfun, 8)) tfp ON 0 = 0
        WHERE
                fp.id_cia = pin_id_cia
            AND ( pin_codfun IS NULL
                  OR pin_codfun = - 1
                  OR fp.codfun = pin_codfun )
            AND ( pin_nombre IS NULL
                  OR upper(fp.nombre) LIKE upper(pin_nombre || '%') );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_buscar_tipofuncion (
        pin_id_cia NUMBER,
        pin_tipfun NUMBER
    ) RETURN datatable_tipofuncion
        PIPELINED
    AS
        v_rec datarecord_tipofuncion;
    BEGIN
        FOR i IN pack_hr_funcion_planilla.ka_tipfun.first..pack_hr_funcion_planilla.ka_tipfun.last LOOP
            v_rec.id_cia := pin_id_cia;
            v_rec.tipfun := i;
            v_rec.destipfun := pack_hr_funcion_planilla.ka_tipfun(i);
            IF v_rec.tipfun = pin_tipfun OR pin_tipfun IS NULL THEN
                PIPE ROW ( v_rec );
            END IF;

        END LOOP;

        RETURN;
    END sp_buscar_tipofuncion;

--SET SERVEROUTPUT ON;
--
--DECLARE 
--    MSJ VARCHAR2(500);
--    cadjson  VARCHAR2(4000);
--BEGIN
-- cadjson := '{
--    "codfun": 1002,
--    "nombre": "PRUEBA",
--    "nomfun":"PRUEBA",
--    "tipfun":1,
--    "nummes":5,
--    "pactual":"S",
--    "mactual":"S",
--    "observ":"N",
--    "ucreac":"ADMIN",
--    "uactua":"ADMIN"
--}';
--    pack_HR_funcion_planilla.sp_save(66,cadjson,2, MSJ);
--    dbms_output.put_line(MSJ);
--END;    
--
--SELECT * FROM pack_hr_funcion_planilla.sp_buscar (66,-1,NULL);    
--
--SELECT * FROM pack_hr_funcion_planilla.sp_buscar_tipofuncion(25,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                    json_object_t;
        rec_funcion_planilla funcion_planilla%rowtype;
        v_accion             VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_funcion_planilla.id_cia := pin_id_cia;
        rec_funcion_planilla.codfun := o.get_number('codfun');
        rec_funcion_planilla.nombre := o.get_string('nombre');
        rec_funcion_planilla.nomfun := o.get_string('nomfun');
        rec_funcion_planilla.tipfun := o.get_number('tipfun');
        rec_funcion_planilla.nummes := o.get_number('nummes');
        rec_funcion_planilla.pactual := o.get_string('pactual');
        rec_funcion_planilla.mactual := o.get_string('mactual');
        rec_funcion_planilla.observ := o.get_string('observ');
        rec_funcion_planilla.ucreac := o.get_string('ucreac');
        rec_funcion_planilla.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO funcion_planilla (
                    id_cia,
                    codfun,
                    nombre,
                    nomfun,
                    tipfun,
                    nummes,
                    pactual,
                    mactual,
                    observ,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_funcion_planilla.id_cia,
                    rec_funcion_planilla.codfun,
                    rec_funcion_planilla.nombre,
                    rec_funcion_planilla.nomfun,
                    rec_funcion_planilla.tipfun,
                    rec_funcion_planilla.nummes,
                    rec_funcion_planilla.pactual,
                    rec_funcion_planilla.mactual,
                    rec_funcion_planilla.observ,
                    rec_funcion_planilla.ucreac,
                    rec_funcion_planilla.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE funcion_planilla
                SET
                    nombre = rec_funcion_planilla.nombre,
                    nomfun = rec_funcion_planilla.nomfun,
                    tipfun = rec_funcion_planilla.tipfun,
                    nummes = rec_funcion_planilla.nummes,
                    pactual = rec_funcion_planilla.pactual,
                    mactual = rec_funcion_planilla.mactual,
                    observ = rec_funcion_planilla.observ,
                    uactua = rec_funcion_planilla.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_funcion_planilla.id_cia
                    AND codfun = rec_funcion_planilla.codfun;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM funcion_planilla
                WHERE
                        id_cia = rec_funcion_planilla.id_cia
                    AND codfun = rec_funcion_planilla.codfun;

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
                    'message' VALUE 'El registro con codigo de FUNCION DE PLANILLA [ '
                                    || rec_funcion_planilla.codfun
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto ...!'
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
