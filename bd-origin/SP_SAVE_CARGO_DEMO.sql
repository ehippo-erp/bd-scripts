--------------------------------------------------------
--  DDL for Procedure SP_SAVE_CARGO_DEMO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_SAVE_CARGO_DEMO" (
    pin_id_cia   IN    NUMBER,
    pin_codigo   IN    VARCHAR2,
    pin_error    OUT   NUMBER
    
) IS
BEGIN

    INSERT INTO cargo (
        id_cia,
        codcar,
        nombre
    ) VALUES (
        pin_id_cia,
        pin_codigo,
        'DEMO'
    );

    COMMIT;
EXCEPTION

      WHEN dup_val_on_index THEN
         pin_error := 1; 
        --  raise_application_error(pkg_exceptionuser.tcambio_no_existe, ' El registro ya existe');

END sp_save_cargo_demo;

/
