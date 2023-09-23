--------------------------------------------------------
--  DDL for Package Body PACK_PROV104
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_PROV104" AS

    FUNCTION sp_obtener (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER
    ) RETURN datatable_prov104
        PIPELINED
    IS
        v_table datatable_prov104;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            prov104
        WHERE
                id_cia = pin_id_cia
            AND libro = pin_libro
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND secuencia = pin_secuencia
            AND item = pin_item;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER
    ) RETURN datatable_prov104
        PIPELINED
    IS
        v_table datatable_prov104;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            prov104
        WHERE
                id_cia = pin_id_cia
            AND ( pin_libro IS NULL
                  OR libro = pin_libro )
            AND ( nvl(pin_periodo, - 1) = - 1
                  OR periodo = pin_periodo )
            AND ( nvl(pin_mes, - 1) = - 1
                  OR mes = pin_mes )
            AND ( nvl(pin_secuencia, - 1) = - 1
                  OR secuencia = pin_secuencia )
            AND ( nvl(pin_item, - 1) = - 1
                  OR item = pin_item );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_buscar_deposito (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER
    ) RETURN datatable_prov104
        PIPELINED
    AS
        v_table datatable_prov104;
    BEGIN
        SELECT
            p104.id_cia,
            p104.libro,
            p104.periodo,
            p104.mes,
            p104.secuencia,
            p104.item,
            p104.tipdep,
            p104.doccan,
            p104.cuenta,
            p104.dh,
            p104.tipmon,
            p104.codban,
            p104.op,
            p104.agencia,
            p104.tipcam,
            p104.deposito,
            p104.tcamb01,
            p104.tcamb02,
            (
                CASE
                    WHEN p104.dh = 'H' THEN
                        1
                    ELSE
                        - 1
                END
            ) * p104.impor01 AS import01,
            (
                CASE
                    WHEN p104.dh = 'H' THEN
                        1
                    ELSE
                        - 1
                END
            ) * p104.impor02 AS import02,
            p104.pagomn,
            p104.pagome,
            p104.situac,
            p104.concep,
            p104.retcodcli,
            p104.retserie,
            p104.retnumero,
            p104.codigo,
            p104.razon,
            p104.tdocum,
            p104.serie,
            p104.numero
        BULK COLLECT
        INTO v_table
        FROM
            prov104  p104
        WHERE
                p104.id_cia = pin_id_cia
            AND ( pin_libro IS NULL
                  OR p104.libro = pin_libro )
            AND ( nvl(pin_periodo, - 1) = - 1
                  OR p104.periodo = pin_periodo )
            AND ( nvl(pin_mes, - 1) = - 1
                  OR p104.mes = pin_mes )
            AND ( nvl(pin_secuencia, - 1) = - 1
                  OR p104.secuencia = pin_secuencia )
            AND ( nvl(pin_item, - 1) = - 1
                  OR p104.item = pin_item );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_deposito;

--    PROCEDURE sp_save (
--        pin_id_cia  IN NUMBER,
--        pin_datos   IN VARCHAR2,
--        pin_opcdml  INTEGER,
--        pin_mensaje OUT VARCHAR2
--    ) IS
--        o               json_object_t;
--        rec_aseguradora prov104%rowtype;
--        v_accion        VARCHAR2(50) := '';
--    BEGIN
--        o := json_object_t.parse(pin_datos);
--        rec_aseguradora.id_cia := pin_id_cia;
--        rec_aseguradora.id_aseg := o.get_string('id_aseg');
--        rec_aseguradora.razonc := o.get_string('razonc');
--        rec_aseguradora.tident := o.get_string('tident');
--        rec_aseguradora.dident := o.get_string('dident');
--        rec_aseguradora.direccion := o.get_string('direccion');
--        rec_aseguradora.telefono := o.get_string('telefono');
--        rec_aseguradora.poliza := o.get_string('poliza');
--        rec_aseguradora.finicio := o.get_date('finicio');
--        rec_aseguradora.ffinal := o.get_date('ffinal');
--        rec_aseguradora.ucreac := o.get_string('ucreac');
--        rec_aseguradora.uactua := o.get_string('uactua');
--        rec_aseguradora.fcreac := o.get_timestamp('fcreac');
--        rec_aseguradora.factua := o.get_timestamp('factua');
--        v_accion := 'La grabación';
--        CASE pin_opcdml
--            WHEN 1 THEN
--                INSERT INTO prov104 (
--                    id_cia,
--                    id_aseg,
--                    razonc,
--                    tident,
--                    dident,
--                    direccion,
--                    telefono,
--                    poliza,
--                    finicio,
--                    ffinal,
--                    ucreac,
--                    uactua,
--                    fcreac,
--                    factua
--                ) VALUES (
--                    rec_aseguradora.id_cia,
--                    rec_aseguradora.id_aseg,
--                    rec_aseguradora.razonc,
--                    rec_aseguradora.tident,
--                    rec_aseguradora.dident,
--                    rec_aseguradora.direccion,
--                    rec_aseguradora.telefono,
--                    rec_aseguradora.poliza,
--                    rec_aseguradora.finicio,
--                    rec_aseguradora.ffinal,
--                    rec_aseguradora.ucreac,
--                    rec_aseguradora.uactua,
--                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
--                                 'YYYY-MM-DD HH24:MI:SS'),
--                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
--                                 'YYYY-MM-DD HH24:MI:SS')
--                );
--
--                COMMIT;
--            WHEN 2 THEN
--                v_accion := 'La actualización';
--                UPDATE prov104
--                SET
--                    razonc =
--                        CASE
--                            WHEN rec_aseguradora.razonc IS NULL THEN
--                                razonc
--                            ELSE
--                                rec_aseguradora.razonc
--                        END,
--                    tident =
--                        CASE
--                            WHEN rec_aseguradora.tident IS NULL THEN
--                                tident
--                            ELSE
--                                rec_aseguradora.tident
--                        END,
--                    dident =
--                        CASE
--                            WHEN rec_aseguradora.dident IS NULL THEN
--                                dident
--                            ELSE
--                                rec_aseguradora.dident
--                        END,
--                    direccion =
--                        CASE
--                            WHEN rec_aseguradora.direccion IS NULL THEN
--                                direccion
--                            ELSE
--                                rec_aseguradora.direccion
--                        END,
--                    telefono =
--                        CASE
--                            WHEN rec_aseguradora.telefono IS NULL THEN
--                                telefono
--                            ELSE
--                                rec_aseguradora.telefono
--                        END,
--                    poliza =
--                        CASE
--                            WHEN rec_aseguradora.poliza IS NULL THEN
--                                poliza
--                            ELSE
--                                rec_aseguradora.poliza
--                        END,
--                    finicio =
--                        CASE
--                            WHEN rec_aseguradora.finicio IS NULL THEN
--                                finicio
--                            ELSE
--                                rec_aseguradora.finicio
--                        END,
--                    ffinal =
--                        CASE
--                            WHEN rec_aseguradora.ffinal IS NULL THEN
--                                ffinal
--                            ELSE
--                                rec_aseguradora.ffinal
--                        END,
--                    uactua =
--                        CASE
--                            WHEN rec_aseguradora.uactua IS NULL THEN
--                                ''
--                            ELSE
--                                rec_aseguradora.uactua
--                        END,
--                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
--             'YYYY-MM-DD HH24:MI:SS')
--                WHERE
--                        id_cia = rec_aseguradora.id_cia
--                    AND id_aseg = rec_aseguradora.id_aseg;
--
--                COMMIT;
--            WHEN 3 THEN
--                v_accion := 'La eliminación';
--                DELETE FROM prov104
--                WHERE
--                        id_cia = rec_aseguradora.id_cia
--                    AND id_aseg = rec_aseguradora.id_aseg;
--
--                COMMIT;
--        END CASE;
--
--        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
--    EXCEPTION
--        WHEN dup_val_on_index THEN
--            raise_application_error(pkg_exceptionuser.registro_duplicado, '{El registro ya existe.{');
--    END;

END;

/
