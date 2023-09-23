--------------------------------------------------------
--  DDL for Procedure SP_GENERATE_SEQUENCES_THE_LIBROS_FOR_CIA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_GENERATE_SEQUENCES_THE_LIBROS_FOR_CIA" (
    pin_id_cia IN NUMBER
)
    AUTHID current_user
AS

    CURSOR cur_compr010 IS
    SELECT
        tipo,
        MAX(docume) maxdocume
    FROM
        compr010
    WHERE
        id_cia = pin_id_cia
    GROUP BY
        tipo;

    v_namesecunce  VARCHAR2(80);
    v_maxnumdoc    NUMBER;
BEGIN
--FORMA DE USO
--SET SERVEROUTPUT ON
--BEGIN
-- sp_generate_sequences_the_libros_for_cia(13);
--END;
    FOR registro IN cur_compr010 LOOP
        v_namesecunce := 'GEN_DOC_'
                         || pin_id_cia
                         || '_'
                         || registro.tipo
                         || '_0';

--   dbms_output.put_line(v_namesecunce);

        alter_start_sequence(v_namesecunce, registro.maxdocume + 1);

--        EXECUTE IMMEDIATE 'BEGIN   alter_start_sequence('
--                          || ''''
--                          || upper(registro.namesequence)
--                          || ''''
--                          || ','
--                          || to_char(v_maxnumdoc)
--                          || '); END;';
    END LOOP;
END sp_generate_sequences_the_libros_for_cia;

/
