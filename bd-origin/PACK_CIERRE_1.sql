--------------------------------------------------------
--  DDL for Package Body PACK_CIERRE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CIERRE" AS

    FUNCTION sp_sel_cierre (
        pin_id_cia  IN NUMBER,
        pin_sistema IN NUMBER
    ) RETURN t_cierre
        PIPELINED
    IS
        v_table t_cierre;
    BEGIN
        SELECT
            co.id_cia,
            co.sistema,
            co.periodo,
            co.cierre AS cierre00,
            (
                SELECT
                    c.cierre
                FROM
                    cierre c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.sistema = co.sistema
                    AND c.periodo = co.periodo
                    AND c.mes = co.mes + 01
            )         AS cierre01,
            (
                SELECT
                    c.cierre
                FROM
                    cierre c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.sistema = co.sistema
                    AND c.periodo = co.periodo
                    AND c.mes = co.mes + 02
            )         AS cierre02,
            (
                SELECT
                    c.cierre
                FROM
                    cierre c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.sistema = co.sistema
                    AND c.periodo = co.periodo
                    AND c.mes = co.mes + 03
            )         AS cierre03,
            (
                SELECT
                    c.cierre
                FROM
                    cierre c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.sistema = co.sistema
                    AND c.periodo = co.periodo
                    AND c.mes = co.mes + 04
            )         AS cierre04,
            (
                SELECT
                    c.cierre
                FROM
                    cierre c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.sistema = co.sistema
                    AND c.periodo = co.periodo
                    AND c.mes = co.mes + 05
            )         AS cierre05,
            (
                SELECT
                    c.cierre
                FROM
                    cierre c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.sistema = co.sistema
                    AND c.periodo = co.periodo
                    AND c.mes = co.mes + 06
            )         AS cierre06,
            (
                SELECT
                    c.cierre
                FROM
                    cierre c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.sistema = co.sistema
                    AND c.periodo = co.periodo
                    AND c.mes = co.mes + 07
            )         AS cierre07,
            (
                SELECT
                    c.cierre
                FROM
                    cierre c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.sistema = co.sistema
                    AND c.periodo = co.periodo
                    AND c.mes = co.mes + 08
            )         AS cierre08,
            (
                SELECT
                    c.cierre
                FROM
                    cierre c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.sistema = co.sistema
                    AND c.periodo = co.periodo
                    AND c.mes = co.mes + 09
            )         AS cierre09,
            (
                SELECT
                    c.cierre
                FROM
                    cierre c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.sistema = co.sistema
                    AND c.periodo = co.periodo
                    AND c.mes = co.mes + 10
            )         AS cierre10,
            (
                SELECT
                    c.cierre
                FROM
                    cierre c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.sistema = co.sistema
                    AND c.periodo = co.periodo
                    AND c.mes = co.mes + 11
            )         AS cierre11,
            (
                SELECT
                    c.cierre
                FROM
                    cierre c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.sistema = co.sistema
                    AND c.periodo = co.periodo
                    AND c.mes = co.mes + 12
            )         AS cierre12,
            co.usuario,
            co.fcreac,
            co.factua
        BULK COLLECT
        INTO v_table
        FROM
            cierre co
        WHERE
                co.id_cia = pin_id_cia
            AND co.mes = 00
            AND co.sistema = pin_sistema
        ORDER BY
            co.sistema,
            co.periodo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_sel_cierre;

    PROCEDURE sp_save_cierre (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o          json_object_t;
        rec_cierre cierre%rowtype;
        v_accion   VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_cierre.sistema := o.get_number('sistema');
        rec_cierre.periodo := o.get_number('periodo');
        rec_cierre.mes := o.get_number('mes');
        rec_cierre.cierre := o.get_number('cierre');
        rec_cierre.usuario := o.get_string('usuario');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
            --'Contabilidad', 'Cuentas por cobrar', 'Comercial', 'Logistica','Cuentas por pagar'
                FOR id_sistem IN 1..6 LOOP
                    sp000_nuevo_cierre(pin_id_cia, id_sistem, rec_cierre.periodo, rec_cierre.usuario);
                    sp000_actualiza_cierre(pin_id_cia, rec_cierre.sistema, rec_cierre.periodo, rec_cierre.usuario, 0,
                                          0, 0, 0, 0, 0,
                                          0, 0, 0, 0, 0,
                                          0, 0);

                END LOOP;

                COMMIT;
            WHEN 2 THEN
                UPDATE cierre
                SET
                    cierre = rec_cierre.cierre,
                    usuario = rec_cierre.usuario
                WHERE
                        id_cia = pin_id_cia
                    AND sistema = rec_cierre.sistema
                    AND periodo = rec_cierre.periodo
                    AND mes = rec_cierre.mes;

                COMMIT;
				--DDD
                IF ( rec_cierre.sistema = 1 ) THEN /* Contabilidad */
                    UPDATE cierre
                    SET
                        cierre = rec_cierre.cierre,
                        usuario = rec_cierre.usuario
                    WHERE
                            id_cia = pin_id_cia
                        AND sistema IN ( 2, 5, 6 )
                        AND periodo = rec_cierre.periodo
                        AND mes = rec_cierre.mes; /* Cta Ctes, Cta.X Pag. y Planilla*/

                END IF;

                IF ( rec_cierre.sistema = 2 ) THEN /* Cta Cte */
                    UPDATE cierre
                    SET
                        cierre = rec_cierre.cierre,
                        usuario = rec_cierre.usuario
                    WHERE
                            id_cia = pin_id_cia
                        AND sistema IN ( 3, 4, 6 )
                        AND periodo = rec_cierre.periodo
                        AND mes = rec_cierre.mes; /* Comercial, Logistica y Planilla*/

                END IF;
				--DDDD
                IF ( rec_cierre.sistema = 6 ) THEN /* Planilla */
                    UPDATE planilla
                    SET
                        situac = 'N'
                    WHERE
                            id_cia = pin_id_cia
                        AND anopla = rec_cierre.periodo
                        AND mespla = rec_cierre.mes;

                END IF;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM cierre
                WHERE
                        id_cia = pin_id_cia
                    AND sistema = rec_cierre.sistema
                    AND periodo = rec_cierre.periodo;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;

END;

/
