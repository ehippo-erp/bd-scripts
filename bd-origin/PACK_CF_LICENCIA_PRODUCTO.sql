--------------------------------------------------------
--  DDL for Package PACK_CF_LICENCIA_PRODUCTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CF_LICENCIA_PRODUCTO" AS
    TYPE t_licencia_producto IS
        TABLE OF licencia_producto%rowtype;
    TYPE datarecord_producto IS RECORD (
        id_cia  INTEGER,
        codpro  VARCHAR2(10 CHAR),
        despro  VARCHAR2(100 CHAR),
        coment  VARCHAR2(1000 CHAR),
        observ  VARCHAR2(1000 CHAR),
        codmods VARCHAR2(100 CHAR),
        modulos VARCHAR2(1000 CHAR)
    );
    TYPE datatable_producto IS
        TABLE OF datarecord_producto;
    FUNCTION sp_producto (
        pin_id_cia NUMBER
    ) RETURN datatable_producto
        PIPELINED;

    FUNCTION sp_obtener (
        pin_id_cia      NUMBER,
        pin_id_licencia NUMBER
    ) RETURN t_licencia_producto
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codpro VARCHAR2,
        pin_situac VARCHAR2
    ) RETURN t_licencia_producto
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_replicar (
        pin_id_cia  IN NUMBER,
        pin_codpro  IN VARCHAR2,
        pin_date    IN DATE,
        pin_days    IN INTEGER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

--EXEC pack_proceso_diario.sp_merge_licencia_resumen(66, to_date('01/01/23','DD/MM/YY'), 1);
--
--EXEC pack_proceso_diario.sp_merge_licencia_resumen(NULL,NULL, 1);

--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_cf_licencia_producto.sp_replicar(66,NULL,to_date('15/06/23','DD/MM/YY'),365,'admin', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

END;

/
