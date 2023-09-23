--------------------------------------------------------
--  DDL for Package Body PACK_OPERACIONES
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_OPERACIONES" AS

    FUNCTION sp_sel_operaciones (
        pin_id_cia    IN  NUMBER,
        pin_swactivo  IN  CHAR
    ) RETURN t_operaciones
        PIPELINED
    IS
        v_table t_operaciones;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            tbancos
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_swactivo IS NULL )
                  OR ( swacti = pin_swactivo ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_operaciones;

    PROCEDURE sp_save_operaciones (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o            json_object_t;
        rec_tbancos  tbancos%rowtype;
        v_accion     VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_tbancos.id_cia := pin_id_cia;
        rec_tbancos.codban := o.get_string('codban');
        rec_tbancos.descri := o.get_string('descri');
        rec_tbancos.sector := o.get_string('sector');
        rec_tbancos.moneda := o.get_string('moneda');
        rec_tbancos.direcc := o.get_string('direcc');
        rec_tbancos.clibro := o.get_string('clibro');
        rec_tbancos.cuenta := o.get_string('cuenta');
        rec_tbancos.codsunat := o.get_string('codsunat');
        rec_tbancos.situac := o.get_number('situac');
        rec_tbancos.usuari := o.get_string('usuari');
        rec_tbancos.cuentacon := o.get_string('cuentacon');
        rec_tbancos.cuentaret := o.get_string('cuentaret');
        rec_tbancos.secuencia := o.get_number('secuencia');
        rec_tbancos.cuentacta := o.get_string('cuentacta');
        rec_tbancos.cuentacar := o.get_string('cuentacar');
        rec_tbancos.cuentacprot := o.get_string('cuentacprot');
        rec_tbancos.cuentacob := o.get_string('cuentacob');
        rec_tbancos.cuentades := o.get_string('cuentades');
        rec_tbancos.cuentagar := o.get_string('cuentagar');
        rec_tbancos.cuentaord01 := o.get_string('cuentaord01');
        rec_tbancos.cuentaord02 := o.get_string('cuentaord02');
        rec_tbancos.cuentaenvios := o.get_string('cuentaenvios');
        rec_tbancos.filtro := o.get_string('filtro');
        rec_tbancos.swacti := o.get_string('swacti');
        rec_tbancos.abrevi := o.get_string('abrevi');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO tbancos (
                    id_cia,
                    codban,
                    descri,
                    sector,
                    moneda,
                    direcc,
                    clibro,
                    cuenta,
                    codsunat,
                    situac,
                    usuari,
                    cuentacon,
                    cuentaret,
                    secuencia,
                    cuentacta,
                    cuentacar,
                    cuentacprot,
                    cuentacob,
                    cuentades,
                    cuentagar,
                    cuentaord01,
                    cuentaord02,
                    cuentaenvios,
                    filtro,
                    swacti,
                    abrevi
                ) VALUES (
                    rec_tbancos.id_cia,
                    rec_tbancos.codban,
                    rec_tbancos.descri,
                    rec_tbancos.sector,
                    rec_tbancos.moneda,
                    rec_tbancos.direcc,
                    rec_tbancos.clibro,
                    rec_tbancos.cuenta,
                    rec_tbancos.codsunat,
                    rec_tbancos.situac,
                    rec_tbancos.usuari,
                    rec_tbancos.cuentacon,
                    rec_tbancos.cuentaret,
                    rec_tbancos.secuencia,
                    rec_tbancos.cuentacta,
                    rec_tbancos.cuentacar,
                    rec_tbancos.cuentacprot,
                    rec_tbancos.cuentacob,
                    rec_tbancos.cuentades,
                    rec_tbancos.cuentagar,
                    rec_tbancos.cuentaord01,
                    rec_tbancos.cuentaord02,
                    rec_tbancos.cuentaenvios,
                    rec_tbancos.filtro,
                    rec_tbancos.swacti,
                    rec_tbancos.abrevi
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE tbancos
                SET
                    descri = rec_tbancos.descri,
                    sector = rec_tbancos.sector,
                    moneda = rec_tbancos.moneda,
                    direcc = rec_tbancos.direcc,
                    clibro = rec_tbancos.clibro,
                    cuenta = rec_tbancos.cuenta,
                    codsunat = rec_tbancos.codsunat,
                    situac = rec_tbancos.situac,
                    usuari = rec_tbancos.usuari,
                    cuentacon = rec_tbancos.cuentacon,
                    cuentaret = rec_tbancos.cuentaret,
                    secuencia = rec_tbancos.secuencia,
                    cuentacta = rec_tbancos.cuentacta,
                    cuentacar = rec_tbancos.cuentacar,
                    cuentacprot = rec_tbancos.cuentacprot,
                    cuentacob = rec_tbancos.cuentacob,
                    cuentades = rec_tbancos.cuentades,
                    cuentagar = rec_tbancos.cuentagar,
                    cuentaord01 = rec_tbancos.cuentaord01,
                    cuentaord02 = rec_tbancos.cuentaord02,
                    cuentaenvios = rec_tbancos.cuentaenvios,
                    filtro = rec_tbancos.filtro,
                    swacti = rec_tbancos.swacti,
                    abrevi = rec_tbancos.abrevi
                WHERE
                        id_cia = rec_tbancos.id_cia
                    AND codban = rec_tbancos.codban;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM tbancos
                WHERE
                        id_cia = rec_tbancos.id_cia
                    AND codban = rec_tbancos.codban;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;


---TBANCOS_CLASE

    FUNCTION sp_sel_tbancos_clase (
        pin_id_cia  IN  NUMBER,
        pin_codban  IN  VARCHAR2
    ) RETURN t_tbancos_clase
        PIPELINED
    IS
        v_table t_tbancos_clase;
    BEGIN
        SELECT
            t.id_cia,
            t.codban,
            t.clase,
            c.descripcion     AS desclase,
            t.codigo,
            cc.descripcion    AS descodigo,
            t.vreal,
            t.vstrg,
            t.vchar,
            t.vdate,
            t.vtime,
            t.ventero,
            t.codusercrea,
            t.coduseractu,
            t.fcreac,
            t.factua
        BULK COLLECT
        INTO v_table
        FROM
            tbancos_clase                      t
            LEFT OUTER JOIN TABLE ( xhlp001.clasestbancos )    c ON c.codigo = t.clase
            LEFT OUTER JOIN TABLE ( xhlp001.bancos )           cc ON cc.codigo = t.codigo
        WHERE
            t.id_cia = pin_id_cia
        ORDER BY
            t.codban,
            t.clase;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_tbancos_clase;

    PROCEDURE sp_save_tbancos_clase (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o                  json_object_t;
        rec_tbancos_clase  r_tbancos_clase;
        v_accion           VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_tbancos_clase.id_cia := pin_id_cia;
        rec_tbancos_clase.codban := o.get_string('codban');
        rec_tbancos_clase.clase := o.get_number('clase');
        rec_tbancos_clase.codigo := o.get_string('codigo');
        rec_tbancos_clase.vreal := o.get_string('vreal');
        rec_tbancos_clase.vstrg := o.get_string('vstrg');
        rec_tbancos_clase.vchar := o.get_string('vchar');
        rec_tbancos_clase.vdate := o.get_date('vdate');
        rec_tbancos_clase.vtime := o.get_date('vtime');
        rec_tbancos_clase.ventero := o.get_number('ventero');
        rec_tbancos_clase.codusercrea := o.get_string('codusercrea');
        rec_tbancos_clase.coduseractu := o.get_string('coduseractu');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO tbancos_clase (
                    id_cia,
                    codban,
                    clase,
                    codigo,
                    vreal,
                    vstrg,
                    vchar,
                    vdate,
                    vtime,
                    ventero,
                    codusercrea,
                    coduseractu
                ) VALUES (
                    rec_tbancos_clase.id_cia,
                    rec_tbancos_clase.codban,
                    rec_tbancos_clase.clase,
                    rec_tbancos_clase.codigo,
                    rec_tbancos_clase.vreal,
                    rec_tbancos_clase.vstrg,
                    rec_tbancos_clase.vchar,
                    rec_tbancos_clase.vdate,
                    rec_tbancos_clase.vtime,
                    rec_tbancos_clase.ventero,
                    rec_tbancos_clase.codusercrea,
                    rec_tbancos_clase.coduseractu
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE tbancos_clase
                SET
                    codigo = rec_tbancos_clase.codigo,
                    vreal = rec_tbancos_clase.vreal,
                    vstrg = rec_tbancos_clase.vstrg,
                    vchar = rec_tbancos_clase.vchar,
                    vdate = rec_tbancos_clase.vdate,
                    vtime = rec_tbancos_clase.vtime,
                    ventero = rec_tbancos_clase.ventero,
                    codusercrea = rec_tbancos_clase.codusercrea,
                    coduseractu = rec_tbancos_clase.coduseractu
                WHERE
                        id_cia = rec_tbancos_clase.id_cia
                    AND codban = rec_tbancos_clase.codban
                    AND clase = rec_tbancos_clase.clase;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM tbancos_clase
                WHERE
                        id_cia = rec_tbancos_clase.id_cia
                    AND codban = rec_tbancos_clase.codban
                    AND clase = rec_tbancos_clase.clase;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;

END;

/
