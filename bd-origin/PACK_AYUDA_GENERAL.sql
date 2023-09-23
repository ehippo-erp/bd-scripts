--------------------------------------------------------
--  DDL for Package PACK_AYUDA_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_AYUDA_GENERAL" AS
    TYPE datarecord_ajusta_string IS RECORD (
        ajustado VARCHAR2(250)
    );
    TYPE datatable_ajusta_string IS
        TABLE OF datarecord_ajusta_string;
    TYPE datarecord_ajusta_number IS RECORD (
        ajustado NUMBER(24, 8)
    );
    TYPE datatable_ajusta_number IS
        TABLE OF datarecord_ajusta_number;
    TYPE datarecord_coma_fila IS RECORD (
        orden NUMBER,
        campo NUMBER
    );
    TYPE datatable_coma_fila IS
        TABLE OF datarecord_coma_fila;
    FUNCTION sp_ajusta_string (
        wstring    IN VARCHAR2,
        wlargo     IN NUMBER,
        wcaracter  IN CHAR,
        wdireccion IN CHAR
    ) RETURN datatable_ajusta_string
        PIPELINED;

    FUNCTION sp_difhor_string (
        pin_fdesde IN DATE,
        pin_fhasta IN DATE
    ) RETURN datatable_ajusta_string
        PIPELINED;

    FUNCTION sp_difhor_number (
        pin_fdesde IN DATE,
        pin_fhasta IN DATE
    ) RETURN datatable_ajusta_number
        PIPELINED;

    FUNCTION sp_difmin_number (
        pin_fdesde IN TIMESTAMP,
        pin_fhasta IN TIMESTAMP
    ) RETURN datatable_ajusta_number
        PIPELINED;

    PROCEDURE sp_generate_numero (
        pin_id_cia  IN NUMBER,
        pin_number  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_coma_fila (
        pin_texto VARCHAR2
    ) RETURN datatable_coma_fila
        PIPELINED;

    FUNCTION sp_number_text_aux (
        pin_numeroentero IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION sp_number_text (
        pin_numeroentero IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION sp_decimal2_text (
        pin_numerodecimal IN NUMBER
    ) RETURN VARCHAR2;

--set SERVEROUTPUT on;
--/
--DECLARE
--    mensaje VARCHAR2(1000);
--BEGIN
--
--    pack_ayuda_general.sp_generate_numero(NULL,1000000,mensaje);
--    DBMS_OUTPUT.PUT_LINE(mensaje);
--
--END;

END;

/
