--------------------------------------------------------
--  DDL for Package Body PACK_HR_FACTOR_PLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_FACTOR_PLANILLA" AS

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codfac IN INTEGER,
        pin_nombre IN VARCHAR2
    ) RETURN t_factor_planilla
        PIPELINED
    IS
        v_table t_factor_planilla;
    BEGIN
--select 
--id_cia,
--codfac,
--nombre,
--valfa1,
--valfa2,
--tipfac,
--ucreac,
--uactua,
--fcreac,
--factua
--from table(pack_factor_planilla.sp_sel_factor_planilla (5,1,NULL));    
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            factor_planilla
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_codfac IS NULL )
                  OR ( pin_codfac = - 1 )
                  OR ( codfac = pin_codfac ) )
            AND ( ( pin_nombre IS NULL )
                  OR ( upper(nombre) LIKE upper(pin_nombre || '%') ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                   json_object_t;
        rec_factor_planilla factor_planilla%rowtype;
        v_accion            VARCHAR2(50) := '';
    BEGIN
--SET SERVEROUTPUT ON;
--DECLARE 
--    MSJ VARCHAR2(500);
--    cadjson  VARCHAR2(4000);
--BEGIN
-- cadjson := '{
--    "codfac": "001",
--    "nombre": "UNIDAD IMPOSITIVA TRIBUTARIA",
--    "valfa1":0,
--    "valfa2":0,
--    "tipfac":"0",
--    "indafp":"S",
--    "ucreac":"admin",
--    "uactua":"admin"
--}';
--    pack_factor_planilla.sp_save_factor_planilla(5,cadjson,1, MSJ);
--    dbms_output.put_line(MSJ);
--END;    
        o := json_object_t.parse(pin_datos);
        rec_factor_planilla.id_cia := pin_id_cia;
        rec_factor_planilla.codfac := o.get_string('codfac');
        rec_factor_planilla.nombre := o.get_string('nombre');
        rec_factor_planilla.valfa1 := o.get_number('valfa1');
        rec_factor_planilla.valfa2 := o.get_number('valfa2');
        rec_factor_planilla.tipfac := o.get_string('tipfac');
        rec_factor_planilla.indafp := o.get_string('indafp');
        rec_factor_planilla.ucreac := o.get_string('ucreac');
        rec_factor_planilla.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO factor_planilla (
                    id_cia,
                    codfac,
                    nombre,
                    valfa1,
                    valfa2,
                    tipfac,
                    indafp,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_factor_planilla.id_cia,
                    rec_factor_planilla.codfac,
                    rec_factor_planilla.nombre,
                    rec_factor_planilla.valfa1,
                    rec_factor_planilla.valfa2,
                    rec_factor_planilla.tipfac,
                    rec_factor_planilla.indafp,
                    rec_factor_planilla.ucreac,
                    rec_factor_planilla.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE factor_planilla
                SET
                    nombre = rec_factor_planilla.nombre,
                    valfa1 = rec_factor_planilla.valfa1,
                    valfa2 = rec_factor_planilla.valfa2,
                    tipfac = rec_factor_planilla.tipfac,
                    indafp = rec_factor_planilla.indafp,
                    uactua = rec_factor_planilla.uactua,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_factor_planilla.id_cia
                    AND codfac = rec_factor_planilla.codfac;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM factor_planilla
                WHERE
                        id_cia = rec_factor_planilla.id_cia
                    AND codfac = rec_factor_planilla.codfac;

                DELETE FROM factor_clase_planilla
                WHERE
                        id_cia = rec_factor_planilla.id_cia
                    AND codfac = rec_factor_planilla.codfac;
                    --AND codcla = rec_factor_clase_planilla.codcla;

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
                    'message' VALUE 'El registro con codigo de factor de planilla [ '
                                    || rec_factor_planilla.codfac
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

    FUNCTION sp_buscar_clase (
        pin_id_cia IN NUMBER,
        pin_codfac IN VARCHAR2,
        pin_codcla IN VARCHAR2,
        pin_nombre IN VARCHAR2
    ) RETURN datatable_buscar_clase
        PIPELINED
    IS
        v_table datatable_buscar_clase;
    BEGIN
        SELECT
            fcp.id_cia,
            fcp.codfac,
            fcp.codcla,
            fcp.tipcla,
            tc.destipcla,
            fcp.tipvar,
            CASE
                WHEN fcp.tipvar = 'R' THEN
                    'VREAL'
                WHEN fcp.tipvar = 'S' THEN
                    'VSTRG'
                WHEN fcp.tipvar = 'C' THEN
                    'VCHAR'
                WHEN fcp.tipvar = 'D' THEN
                    'VDATE'
                WHEN fcp.tipvar = 'T' THEN
                    'VTIME'
                ELSE
                    'ND'
            END AS destipvar,
            fcp.nombre,
            fcp.vreal,
            fcp.vstrg,
            fcp.vchar,
            fcp.vdate,
            fcp.vtime,
            fcp.ventero,
            fcp.ucreac,
            fcp.uactua,
            fcp.fcreac,
            fcp.factua
        BULK COLLECT
        INTO v_table
        FROM
            factor_clase_planilla                                               fcp
            LEFT OUTER JOIN pack_hr_factor_planilla.sp_buscar_tipoclase(pin_id_cia, fcp.tipcla) tc ON tc.id_cia = fcp.id_cia
                                                                                                      AND tc.tipcla = fcp.tipcla
        WHERE
                fcp.id_cia = pin_id_cia
            AND ( ( pin_codfac IS NULL )
                  OR ( pin_codfac = - 1 )
                  OR ( fcp.codfac = pin_codfac ) )
            AND ( ( pin_codcla IS NULL )
                  OR ( pin_codcla = '-1' )
                  OR ( fcp.codcla = pin_codcla ) )
            AND ( ( pin_nombre IS NULL )
                  OR ( pin_nombre = '-1' )
                  OR ( upper(fcp.nombre) LIKE upper(pin_nombre || '%') ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_clase;


--SET SERVEROUTPUT ON;
--
--DECLARE 
--    MSJ VARCHAR2(500);
--    cadjson  VARCHAR2(4000);
--BEGIN
-- cadjson := '{
--    "codfac":"013",
--    "codcla":"001DFSFD",
--    "nombre": "RMV 2020",
--    "vreal":850.00,
--    "vstrg":"",
--    "vchar":"",
--    "vdate":"",
--    "vtime":"",
--    "ventero":0,
--    "ucreac":"admin",
--    "uactua":"admin"
--}';
--    pack_HR_factor_planilla.sp_save_clase(30,cadjson,1, MSJ);
--    dbms_output.put_line(MSJ);
--END;  


    PROCEDURE sp_save_clase (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                         json_object_t;
        rec_factor_clase_planilla factor_clase_planilla%rowtype;
        v_accion                  VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_factor_clase_planilla.id_cia := pin_id_cia;
        rec_factor_clase_planilla.codfac := o.get_string('codfac');
        rec_factor_clase_planilla.codcla := o.get_string('codcla');
        rec_factor_clase_planilla.nombre := o.get_string('nombre');
        rec_factor_clase_planilla.tipcla := o.get_number('tipcla');
        rec_factor_clase_planilla.tipvar := o.get_string('tipvar');
        rec_factor_clase_planilla.vreal := o.get_number('vreal');
        rec_factor_clase_planilla.vstrg := o.get_string('vstrg');
        rec_factor_clase_planilla.vchar := o.get_string('vchar');
        rec_factor_clase_planilla.vdate := o.get_date('vdate');
        rec_factor_clase_planilla.vtime := o.get_date('vtime');
        rec_factor_clase_planilla.ventero := o.get_number('ventero');
        rec_factor_clase_planilla.ucreac := o.get_string('ucreac');
        rec_factor_clase_planilla.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO factor_clase_planilla (
                    id_cia,
                    codfac,
                    codcla,
                    tipcla,
                    tipvar,
                    nombre,
                    vreal,
                    vstrg,
                    vchar,
                    vdate,
                    vtime,
                    ventero,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_factor_clase_planilla.id_cia,
                    rec_factor_clase_planilla.codfac,
                    rec_factor_clase_planilla.codcla,
                    rec_factor_clase_planilla.tipcla,
                    rec_factor_clase_planilla.tipvar,
                    rec_factor_clase_planilla.nombre,
                    rec_factor_clase_planilla.vreal,
                    rec_factor_clase_planilla.vstrg,
                    rec_factor_clase_planilla.vchar,
                    rec_factor_clase_planilla.vdate,
                    rec_factor_clase_planilla.vtime,
                    rec_factor_clase_planilla.ventero,
                    rec_factor_clase_planilla.ucreac,
                    rec_factor_clase_planilla.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE factor_clase_planilla
                SET
                    tipcla = rec_factor_clase_planilla.tipcla,
                    tipvar = rec_factor_clase_planilla.tipvar,
                    nombre = rec_factor_clase_planilla.nombre,
                    vreal = rec_factor_clase_planilla.vreal,
                    vstrg = rec_factor_clase_planilla.vstrg,
                    vchar = rec_factor_clase_planilla.vchar,
                    vdate = rec_factor_clase_planilla.vdate,
                    vtime = rec_factor_clase_planilla.vtime,
                    ventero = rec_factor_clase_planilla.ventero,
                    uactua = rec_factor_clase_planilla.uactua,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_factor_clase_planilla.id_cia
                    AND codfac = rec_factor_clase_planilla.codfac
                    AND codcla = rec_factor_clase_planilla.codcla;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM factor_clase_planilla
                WHERE
                        id_cia = rec_factor_clase_planilla.id_cia
                    AND codfac = rec_factor_clase_planilla.codfac
                    AND codcla = rec_factor_clase_planilla.codcla;

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
                    'message' VALUE 'El registro con codigo de factor de planilla [ '
                                    || rec_factor_clase_planilla.codfac
                                    || ' ] y clase [ '
                                    || rec_factor_clase_planilla.codcla
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

    END sp_save_clase;

    FUNCTION sp_buscar_tipoclase (
        pin_id_cia NUMBER,
        pin_tipcla NUMBER
    ) RETURN datatable_tipoclase
        PIPELINED
    AS
        v_table datatable_tipoclase;
        v_rec   datarecord_tipoclase := datarecord_tipoclase(NULL, NULL, NULL);
    BEGIN
--        FOR i IN (
--            SELECT
--                *
--            FROM
--                clase_tipo_factor_planilla
--        ) LOOP
--            v_rec.id_cia := pin_id_cia;
--            v_rec.tipcla := i.tipcla;
--            v_rec.destipcla := i.destipcla;
--            PIPE ROW ( v_rec );
--        END LOOP;
--    
        FOR i IN pack_hr_factor_planilla.ka_tipcla.first..pack_hr_factor_planilla.ka_tipcla.last LOOP
            v_rec.id_cia := pin_id_cia;
            v_rec.tipcla := i;
            v_rec.destipcla := pack_hr_factor_planilla.ka_tipcla(i);
            IF v_rec.tipcla = pin_tipcla OR pin_tipcla IS NULL THEN
                PIPE ROW ( v_rec );
            END IF;

        END LOOP;

        RETURN;
    END sp_buscar_tipoclase;

    FUNCTION sp_buscar_tipovariable (
        pin_id_cia NUMBER,
        pin_tipvar VARCHAR2
    ) RETURN datatable_tipovariable
        PIPELINED
    AS
        v_table datatable_tipovariable;
        v_rec   datarecord_tipovariable := datarecord_tipovariable(NULL, NULL, NULL);
    BEGIN
--    
        FOR i IN pack_hr_factor_planilla.ka_tipvar.first..pack_hr_factor_planilla.ka_tipvar.last LOOP
            v_rec.id_cia := pin_id_cia;
            v_rec.tipvar := SUBSTR(pack_hr_factor_planilla.ka_tipvar(i),2,1);
            v_rec.destipvar := pack_hr_factor_planilla.ka_tipvar(i);
            IF v_rec.tipvar = pin_tipvar OR pin_tipvar IS NULL THEN
                PIPE ROW ( v_rec );
            END IF;

        END LOOP;

        RETURN;
    END sp_buscar_tipovariable;

END;

/
