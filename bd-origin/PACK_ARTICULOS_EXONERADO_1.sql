--------------------------------------------------------
--  DDL for Package Body PACK_ARTICULOS_EXONERADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ARTICULOS_EXONERADO" AS

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_codart IN VARCHAR2
    ) RETURN datatable_articulos_exonerado
        PIPELINED
    AS
        v_table datatable_articulos_exonerado;
    BEGIN
        SELECT
            ae.*,
            s.sucursal AS descodsuc,
            i.dtipinv  AS destipinv,
            a.descri   AS descodart
        BULK COLLECT
        INTO v_table
        FROM
            articulos_exonerado ae
            LEFT OUTER JOIN sucursal            s ON s.id_cia = ae.id_cia
                                          AND s.codsuc = ae.codsuc
            LEFT OUTER JOIN t_inventario        i ON i.id_cia = ae.id_cia
                                              AND i.tipinv = ae.tipinv
            LEFT OUTER JOIN articulos           a ON a.id_cia = ae.id_cia
                                           AND a.tipinv = ae.tipinv
                                           AND a.codart = ae.codart
        WHERE
                ae.id_cia = pin_id_cia
            AND ae.codsuc = pin_codsuc
            AND ae.tipinv = pin_tipinv
            AND ae.codart = pin_codart
        ORDER BY
            ae.codsuc ASC,
            ae.tipinv ASC,
            ae.codart ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_codart IN VARCHAR2
    ) RETURN datatable_articulos_exonerado
        PIPELINED
    AS
        v_table datatable_articulos_exonerado;
    BEGIN
        SELECT
            ae.*,
            s.sucursal AS descodsuc,
            i.dtipinv  AS destipinv,
            a.descri   AS descodart
        BULK COLLECT
        INTO v_table
        FROM
            articulos_exonerado ae
            LEFT OUTER JOIN sucursal            s ON s.id_cia = ae.id_cia
                                          AND s.codsuc = ae.codsuc
            LEFT OUTER JOIN t_inventario        i ON i.id_cia = ae.id_cia
                                              AND i.tipinv = ae.tipinv
            LEFT OUTER JOIN articulos           a ON a.id_cia = ae.id_cia
                                           AND a.tipinv = ae.tipinv
                                           AND a.codart = ae.codart
        WHERE
                ae.id_cia = pin_id_cia 
            AND ( ae.codsuc = pin_codsuc )
            AND ( pin_tipinv = - 1
                  OR pin_tipinv IS NULL
                  OR ae.tipinv = pin_tipinv )
            AND ( pin_codart IS NULL
                  OR ae.codart = pin_codart )
        ORDER BY
            ae.codsuc ASC,
            ae.tipinv ASC,
            ae.codart ASC;

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
        o                       json_object_t;
        rec_articulos_exonerado articulos_exonerado%rowtype;
        v_accion                VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_articulos_exonerado.id_cia := pin_id_cia;
        rec_articulos_exonerado.codsuc := o.get_number('codsuc');
        rec_articulos_exonerado.tipinv := o.get_number('tipinv');
        rec_articulos_exonerado.codart := o.get_string('codart');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO articulos_exonerado (
                    id_cia,
                    codsuc,
                    tipinv,
                    codart
                ) VALUES (
                    rec_articulos_exonerado.id_cia,
                    rec_articulos_exonerado.codsuc,
                    rec_articulos_exonerado.tipinv,
                    rec_articulos_exonerado.codart
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización no esta implementada ...!';
            -- ACTUALIZACION NO IMPLEMENTADA
            /*
                UPDATE articulos_exonerado
                SET
                    tipinv = CASE WHEN rec_articulos_exonerado.tipinv IS NULL THEN tipinv ELSE rec_articulos_exonerado.tipinv END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_articulos_exonerado.id_cia
                    AND codsuc = rec_articulos_exonerado.codsuc;
                COMMIT;*/
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM articulos_exonerado
                WHERE
                        id_cia = rec_articulos_exonerado.id_cia
                    AND codsuc = rec_articulos_exonerado.codsuc
                    AND tipinv = rec_articulos_exonerado.tipinv
                    AND codart = rec_articulos_exonerado.codart;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            pin_mensaje := 'El registro ya existe ...!';
        WHEN no_data_found THEN
            pin_mensaje := 'El registro no existe ...!';
        WHEN value_error THEN
            pin_mensaje := ' Formato Incorrecto, No se puede resgistrar ...!';
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
    END;

END;

/
