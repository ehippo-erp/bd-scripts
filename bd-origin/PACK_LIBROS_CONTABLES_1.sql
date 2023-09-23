--------------------------------------------------------
--  DDL for Package Body PACK_LIBROS_CONTABLES
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_LIBROS_CONTABLES" AS

    FUNCTION sp_sel_libros_contables (
        pin_id_cia IN NUMBER
    ) RETURN t_libros_contables
        PIPELINED
    IS
        v_table t_libros_contables;
    BEGIN
        SELECT
            t1.id_cia,
            t1.codlib,
            t1.descri,
            t1.moneda01,
            t1.moneda02,
            t1.destino,
            t1.abrevi,
            t1.usuario,
            t1.swacti,
            t1.fcreac,
            t1.factua,
            t1.filtro,
            t1.motivo
        BULK COLLECT
        INTO v_table
        FROM
            tlibro t1
        WHERE
            t1.id_cia = pin_id_cia;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_libros_contables;

     FUNCTION sp_sel_libros_contables_planillas (
        pin_id_cia IN NUMBER,
        pin_clase IN NUMBER
    ) RETURN t_libros_contables_planillas
        PIPELINED
    IS
        v_table t_libros_contables_planillas;
    BEGIN
        SELECT
            t1.id_cia,
            t1.codlib,
            t1.descri,
            --tl.clase
            t1.moneda01,
            t1.moneda02,
            t1.destino,
            t1.abrevi,
            t1.usuario,
            t1.swacti,
            t1.fcreac,
            t1.factua,
            t1.filtro,
            t1.motivo
        BULK COLLECT
        INTO v_table
        FROM
            tlibro t1
        LEFT OUTER JOIN  tlibros_clase tl on tl.id_cia = t1.id_cia and tl.codlib = t1.codlib
        WHERE
            t1.id_cia = pin_id_cia AND 
            tl.clase = pin_clase;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END  sp_sel_libros_contables_planillas ;

    PROCEDURE sp_save_tlibro (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o           json_object_t;
        rec_tlibro  tlibro%rowtype;
        v_accion    VARCHAR2(50) := '';
    BEGIN
--SET SERVEROUTPUT ON;
--
--DECLARE
--    cadjson  VARCHAR2(14000);
--    mensaje  VARCHAR(150);
--BEGIN
--    cadjson := '{"codlib":"88",
--    "descri":"libro demostracion",
--    "moneda01":"PEN",
--    "moneda02":"PEN",
--    "destino":3,
--    "abrevi":"ctadem",
--    "usuari":"RAOJ",
--    "swacti":"S",
--    "filtro":"F1",
--    "motivo":1
--}';
--    pack_libros_contables.sp_save_tlibro(13, cadjson, 3, mensaje);
--    dbms_output.put_line(mensaje);
--END;
        o := json_object_t.parse(pin_datos);
        rec_tlibro.id_cia := pin_id_cia;
        rec_tlibro.codlib := o.get_string('codlib');
        rec_tlibro.descri := o.get_string('descri');
        rec_tlibro.moneda01 := o.get_string('moneda01');
        rec_tlibro.moneda02 := o.get_string('moneda02');
        rec_tlibro.destino := o.get_number('destino');
        rec_tlibro.abrevi := o.get_string('abrevi');
        rec_tlibro.usuario := o.get_string('usuario');
        rec_tlibro.swacti := o.get_string('swacti');
        rec_tlibro.filtro := o.get_string('filtro');
        rec_tlibro.motivo := o.get_number('motivo');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO tlibro (
                    id_cia,
                    codlib,
                    descri,
                    moneda01,
                    moneda02,
                    destino,
                    abrevi,
                    usuario,
                    swacti,
                    filtro,
                    motivo
                ) VALUES (
                    rec_tlibro.id_cia,
                    rec_tlibro.codlib,
                    rec_tlibro.descri,
                    rec_tlibro.moneda01,
                    rec_tlibro.moneda02,
                    rec_tlibro.destino,
                    rec_tlibro.abrevi,
                    rec_tlibro.usuario,
                    rec_tlibro.swacti,
                    rec_tlibro.filtro,
                    rec_tlibro.motivo
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE tlibro
                SET
                    descri = rec_tlibro.descri,
                    moneda01 = rec_tlibro.moneda01,
                    moneda02 = rec_tlibro.moneda02,
                    destino = rec_tlibro.destino,
                    abrevi = rec_tlibro.abrevi,
                    usuario = rec_tlibro.usuario,
                    swacti = rec_tlibro.swacti,
                    filtro = rec_tlibro.filtro,
                    motivo = rec_tlibro.motivo
                WHERE
                        id_cia = rec_tlibro.id_cia
                    AND codlib = rec_tlibro.codlib;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM tlibro
                WHERE
                        id_cia = rec_tlibro.id_cia
                    AND codlib = rec_tlibro.codlib;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;

    FUNCTION sp_sel_libros (
        pin_id_cia  IN  NUMBER,
        pin_codlib  IN  VARCHAR2,
        pin_anio    IN  NUMBER
    ) RETURN t_libros
        PIPELINED
    IS
        v_table t_libros;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            libros
        WHERE
                id_cia = pin_id_cia
            AND codlib = pin_codlib
            AND anno = pin_anio;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_libros;

    PROCEDURE sp_save_libros (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o           json_object_t;
        rec_libros  libros%rowtype;
        v_accion    VARCHAR2(50) := '';
    BEGIN
--SET SERVEROUTPUT ON;
--
--DECLARE
--    cadjson  VARCHAR2(4000);
--    mensaje  VARCHAR(150);
--BEGIN
--    cadjson := '{"codlib":"88",
--    "anno":2021,
--    "mes":1,
--    "secuencia":0,
--    "swcorre":"S",
--    "swcierre":"S",
--    "swacti":"S",
--    "usuari":"RAOJ",
--    "usrlck":""}';
--    pack_libros_contables.sp_save_libros(13, cadjson, 3, mensaje);
--    dbms_output.put_line(mensaje);
--END;
        o := json_object_t.parse(pin_datos);
        rec_libros.id_cia := pin_id_cia;
        rec_libros.codlib := o.get_string('codlib');
        rec_libros.anno := o.get_number('anno');
        rec_libros.mes := o.get_number('mes');
        rec_libros.secuencia := o.get_number('secuencia');
        rec_libros.swcorre := o.get_string('swcorre');
        rec_libros.swcierre := o.get_string('swcierre');
        rec_libros.swacti := o.get_string('swacti');
        rec_libros.usuari := o.get_string('usuari');
        rec_libros.usrlck := o.get_string('usrlck');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO libros (
                    id_cia,
                    codlib,
                    anno,
                    mes,
                    secuencia,
                    swcorre,
                    swcierre,
                    swacti,
                    usuari,
                    usrlck
                ) VALUES (
                    rec_libros.id_cia,
                    rec_libros.codlib,
                    rec_libros.anno,
                    rec_libros.mes,
                    rec_libros.secuencia,
                    rec_libros.swcorre,
                    rec_libros.swcierre,
                    rec_libros.swacti,
                    rec_libros.usuari,
                    rec_libros.usrlck
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE libros
                SET
                    secuencia = rec_libros.secuencia,
                    swcorre = rec_libros.swcorre,
                    swcierre = rec_libros.swcierre,
                    swacti = rec_libros.swacti,
                    usuari = rec_libros.usuari,
                    usrlck = rec_libros.usrlck
                WHERE
                        id_cia = rec_libros.id_cia
                    AND codlib = rec_libros.codlib
                    AND anno = rec_libros.anno
                    AND mes = rec_libros.mes;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM libros
                WHERE
                        id_cia = rec_libros.id_cia
                    AND codlib = rec_libros.codlib
                    AND anno = rec_libros.anno
                    AND mes = rec_libros.mes;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;

    PROCEDURE sp_crea_libros_anual (
        pin_id_cia   IN  NUMBER,
        pin_periodo  IN  NUMBER
    ) IS
        v_count_lib NUMBER;
    BEGIN
        FOR registro IN (
            SELECT
                codlib
            FROM
                tlibro
            WHERE
                id_cia = pin_id_cia
        ) LOOP
            FOR n_mes IN 0..12 LOOP
 --           DBMS_OUTPUT.PUT_LINE('libro '||registro.codlib||' mes ' ||n_mes);
                BEGIN
                    SELECT
                        COUNT(0)
                    INTO v_count_lib
                    FROM
                        libros l
                    WHERE
                            l.id_cia = pin_id_cia
                        AND l.codlib = registro.codlib
                        AND l.anno = pin_periodo
                        AND l.mes = n_mes;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_count_lib := 0;
                END;
--                DBMS_OUTPUT.PUT_LINE('valor' ||v_count_lib);
                IF v_count_lib = 0 THEN
--                DBMS_OUTPUT.PUT_LINE('mes insertado ' ||n_mes);
                    INSERT INTO libros (
                        id_cia,
                        codlib,
                        anno,
                        mes,
                        secuencia,
                        swcorre,
                        swcierre,
                        swacti
                    ) VALUES (
                        pin_id_cia,
                        registro.codlib,
                        pin_periodo,
                        n_mes,
                        0,
                        'S',
                        'N',
                        'S'
                    );

                    COMMIT;
                END IF;

            END LOOP;
        END LOOP;
    END;

END;

/
