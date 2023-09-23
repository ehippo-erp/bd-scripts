--------------------------------------------------------
--  DDL for Package Body PACK_TDOCUME
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_TDOCUME" AS

    FUNCTION sp_sel_tdocume (
        pin_id_cia IN NUMBER
    ) RETURN t_tdocume
        PIPELINED
    IS
        v_table t_tdocume;
    BEGIN
        SELECT
            d.id_cia,
            d.codigo,
            d.descri,
            d.abrevi,
            d.dh,
            d.factor,
            d.cdocum,
            d.clibro,
            d.rinfadi,
            d.signo,
            d.situac,
            d.usuari,
            d.salectas,
            d.ctagascolregcom,
            d.valor,
            d.swchkcompr010,
            d.fcreac,
            d.factua,
            l.descri AS deslib
        BULK COLLECT
        INTO v_table
        FROM
            tdocume  d
            LEFT OUTER JOIN tlibro   l ON l.id_cia = pin_id_cia
                                        AND l.codlib = d.clibro
        WHERE
            d.id_cia = pin_id_cia
        ORDER BY
            d.codigo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_tdocume;

    PROCEDURE sp_savetdocume (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o            json_object_t;
        rec_tdocume  r_tdocume;
        v_accion     VARCHAR2(50) := '';
    BEGIN 
--set SERVEROUTPUT ON;
--
--DECLARE
--    cadjson  VARCHAR2(4000);
--    mensaje  VARCHAR(150);
--BEGIN
--    cadjson := '{"codigo":"88",
--    "descri":"DEMOSTRACION DOCUMENTO",
--    "abrevi":"DEMO",
--    "dh":"H",
--    "factor":50,
--    "cdocum":"51",
--    "clibro":"00",
--    "rinfadi":"A",
--    "signo":-1,
--    "situac":"A",
--    "usuari":"RAOJ",
--    "salectas":"400,20",
--    "ctagascolregcom":4,
--    "valor":60,
--    "swchkcompr010":"S"}';
--    pack_TDOCUME.sp_saveTDOCUME(13, cadjson, 3, mensaje);
--    dbms_output.put_line(mensaje);
--END;
        o := json_object_t.parse(pin_datos);
        rec_tdocume.id_cia := pin_id_cia;
        rec_tdocume.codigo := o.get_string('codigo');
        rec_tdocume.descri := o.get_string('descri');
        rec_tdocume.abrevi := o.get_string('abrevi');
        rec_tdocume.dh := o.get_string('dh');
        rec_tdocume.factor := o.get_number('factor');
        rec_tdocume.cdocum := o.get_string('cdocum');
        rec_tdocume.clibro := o.get_string('clibro');
        rec_tdocume.rinfadi := o.get_string('rinfadi');
        rec_tdocume.signo := o.get_number('signo');
        rec_tdocume.situac := o.get_string('situac');
        rec_tdocume.usuari := o.get_string('usuari');
        rec_tdocume.salectas := o.get_string('salectas');
        rec_tdocume.ctagascolregcom := o.get_number('ctagascolregcom');
        rec_tdocume.valor := o.get_number('valor');
        rec_tdocume.swchkcompr010 := o.get_string('swchkcompr010');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO tdocume (
                    id_cia,
                    codigo,
                    descri,
                    abrevi,
                    dh,
                    factor,
                    cdocum,
                    clibro,
                    rinfadi,
                    signo,
                    situac,
                    usuari,
                    salectas,
                    ctagascolregcom,
                    valor,
                    swchkcompr010
                ) VALUES (
                    rec_tdocume.id_cia,
                    rec_tdocume.codigo,
                    rec_tdocume.descri,
                    rec_tdocume.abrevi,
                    rec_tdocume.dh,
                    rec_tdocume.factor,
                    rec_tdocume.cdocum,
                    rec_tdocume.clibro,
                    rec_tdocume.rinfadi,
                    rec_tdocume.signo,
                    rec_tdocume.situac,
                    rec_tdocume.usuari,
                    rec_tdocume.salectas,
                    rec_tdocume.ctagascolregcom,
                    rec_tdocume.valor,
                    rec_tdocume.swchkcompr010
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE tdocume
                SET
                    descri = rec_tdocume.descri,
                    abrevi = rec_tdocume.abrevi,
                    dh = rec_tdocume.dh,
                    factor = rec_tdocume.factor,
                    cdocum = rec_tdocume.cdocum,
                    clibro = rec_tdocume.clibro,
                    rinfadi = rec_tdocume.rinfadi,
                    signo = rec_tdocume.signo,
                    situac = rec_tdocume.situac,
                    usuari = rec_tdocume.usuari,
                    salectas = rec_tdocume.salectas,
                    ctagascolregcom = rec_tdocume.ctagascolregcom,
                    valor = rec_tdocume.valor,
                    swchkcompr010 = rec_tdocume.swchkcompr010
                WHERE
                        id_cia = rec_tdocume.id_cia
                    AND codigo = rec_tdocume.codigo;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM tdocume
                WHERE
                        id_cia = rec_tdocume.id_cia
                    AND codigo = rec_tdocume.codigo;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;

END;

/
