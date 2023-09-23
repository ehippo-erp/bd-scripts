--------------------------------------------------------
--  DDL for Procedure SP_CONTABILIDAD_ENVIAR_CTAS_CTES_CXCOBRAR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_CONTABILIDAD_ENVIAR_CTAS_CTES_CXCOBRAR" (
    pin_id_cia    IN NUMBER,
    pin_libro     IN VARCHAR2,
    pin_periodo   IN NUMBER,
    pin_mes       IN NUMBER,
    pin_secuencia IN NUMBER,
    pin_usuari    IN VARCHAR2,
    pin_mensaje   OUT VARCHAR2
) AS
    v_msj VARCHAR2(500) := '';
BEGIN

        --eliminamos los registros en base a los parametros principales
    DELETE FROM dcta101
    WHERE
        ( id_cia = pin_id_cia )
        AND NOT ( libro = 'hoa' )
        AND libro = pin_libro
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND secuencia = pin_secuencia;

    COMMIT;
    DELETE FROM prov101
    WHERE
        ( id_cia = pin_id_cia )
        AND NOT ( libro = 'hoa' )
        AND libro = pin_libro
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND secuencia = pin_secuencia;

    COMMIT;
    sp_actualiza_saldo_from_planilla(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia);
    COMMIT;
    pack_dcta101.enviar_ctas_ctes_from_dcta103(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                                              pin_usuari, v_msj);

    pack_dcta101.enviar_ctas_ctes_from_dcta113(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                                              pin_usuari, v_msj);

    pack_prov101.enviar_ctas_ctes_from_prov103(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                                              pin_usuari, v_msj);

    pack_prov101.enviar_ctas_ctes_from_prov113(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                                              pin_usuari, v_msj);

--    v_msj := 'Se proceso correctamente';
--    pin_mensaje := v_msj;
    SELECT
        JSON_OBJECT(
            'status' VALUE 1.0,
            'message' VALUE 'El proceso completó correctamente.'
        )
    INTO pin_mensaje
    FROM
        dual;

EXCEPTION
    WHEN OTHERS THEN
        IF sqlcode = -20002 THEN
            pin_mensaje := sqlerrm;
        ELSE
            pin_mensaje := 'Error: '
                           || sqlerrm
                           || ' Código: '
                           || sqlcode;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.2,
                'message' VALUE pin_mensaje
            )
        INTO pin_mensaje
        FROM
            dual;

END sp_contabilidad_enviar_ctas_ctes_cxcobrar;

/
