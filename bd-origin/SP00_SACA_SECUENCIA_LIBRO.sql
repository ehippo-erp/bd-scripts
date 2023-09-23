--------------------------------------------------------
--  DDL for Procedure SP00_SACA_SECUENCIA_LIBRO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP00_SACA_SECUENCIA_LIBRO" (
    pin_id_cia      IN   NUMBER,
    pin_codlib      IN   VARCHAR2,
    pin_ano         IN   NUMBER,
    pin_mes         IN   NUMBER,
    pin_coduser     IN   VARCHAR2,
    pin_incremento  IN   NUMBER,
    pout_secuencia  OUT  NUMBER
) AS
    v_secuencia NUMBER := 0;
BEGIN
--EJEMPLO DE USO
--SET SERVEROUTPUT ON
--
--DECLARE
--    v_resultado NUMBER;
--
--BEGIN
--    sp00_saca_secuencia_libro(1, '01', 2021, 1,'MAN',1, v_resultado);
--    dbms_output.put_line('RESULTADO  '
--                         || v_resultado);
--END;
--/
    BEGIN
      /* Se esta dejando asi por motivo que NO debe haber mas de 1 Libro x vez.. */
        SELECT
            secuencia
        INTO v_secuencia
        FROM
            libros
        WHERE
            ( id_cia = pin_id_cia )
            AND ( codlib = pin_codlib )
            AND ( anno = pin_ano )  
            AND ( mes = pin_mes ) ;

    EXCEPTION
        WHEN no_data_found THEN
            v_secuencia := NULL;
    END;

    IF ( v_secuencia IS NULL ) THEN
        RAISE pkg_exceptionuser.ex_libro_correlativo_no_existe;
        v_secuencia := 0;
    END IF;

    IF  ( pin_incremento > 0 ) THEN
        v_secuencia := v_secuencia + pin_incremento;
        UPDATE libros
        SET        
            secuencia = v_secuencia,  /* Se supone que es inmediato no debe haber diferencia entre Numdoc y Correl */
            usuari = pin_coduser
        WHERE
            ( id_cia = pin_id_cia )
            AND ( codlib = pin_codlib )
            AND ( anno = pin_ano )
            AND ( mes = pin_mes );

    END IF;

    pout_secuencia := v_secuencia;
EXCEPTION
    WHEN pkg_exceptionuser.ex_libro_correlativo_no_existe THEN
        raise_application_error(pkg_exceptionuser.libro_correlativo_no_existe, ' El correlativo correspondiente al periodo no esta inicializado');
END sp00_saca_secuencia_libro;

/
