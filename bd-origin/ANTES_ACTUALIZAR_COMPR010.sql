--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_COMPR010
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_COMPR010" BEFORE
    UPDATE ON "USR_TSI_SUITE".compr010
    FOR EACH ROW
DECLARE
    v_conteo   NUMBER;
    v_periodo  NUMBER;
BEGIN
    sp000_verifica_mes_cerrado_compr010(:old.id_cia, :old.periodo, :old.mes, :old.situac, :new.situac,
                                        :old.motcaja);

    sp000_verifica_mes_cerrado_compr010(:new.id_cia, :new.periodo, :new.mes, :old.situac, :new.situac,
                                        :new.motcaja);

    :new.factua := current_date;
--    BEGIN
--        SELECT
--           count(tipo)
--        INTO v_conteo
--        FROM
--            compr010
--        WHERE
--                id_cia = :new.id_cia
--            AND tdocum = '04'
--            AND nserie = :new.nserie
--            AND numero = :new.numero
--            AND NOT ( tipo = :new.tipo
--                      AND docume = :new.docume );
--
--    EXCEPTION
--        WHEN no_data_found THEN
--            v_conteo := NULL;
--    END;
--
--    IF (
--        ( :new.tdocum = '04' ) AND (
--            ( NOT ( v_conteo IS NULL ) ) AND ( v_conteo > 0 )
--        )
--    ) THEN
--        RAISE pkg_exceptionuser.ex_compr010_liq_com_duplicado;
--    END IF;
--
--    BEGIN
--        SELECT
--            count(tipo)
--        INTO v_conteo
--        FROM
--            compr010
--        WHERE
--                id_cia = :new.id_cia
--            AND tdocum = 'RD'
--            AND nserie = :new.nserie
--            AND numero = :new.numero
--            AND NOT ( tipo = :new.tipo
--                      AND docume = :new.docume );
--
--    EXCEPTION
--        WHEN no_data_found THEN
--            v_conteo := NULL;
--    END;
--
--    IF (
--        ( :new.tdocum = 'RD' ) AND (
--            ( NOT ( v_conteo IS NULL ) ) AND ( v_conteo > 0 )
--        )
--    ) THEN
--        RAISE pkg_exceptionuser.ex_compr010_recibo_duplicado;
--    END IF;
--
--    IF trunc(:new.fcreac) < TO_DATE('01/01/2000', 'dd/mm/yyyy') THEN
--        :new.fcreac := :new.factua;
--    END IF;
--
--    IF ( ( :new.numero IS NULL ) OR ( :new.numero = '' ) OR ( length(:new.numero) < 1 ) ) THEN
--        :new.numero := '0';
--    END IF;
--
--    IF ( :new.situac <> :old.situac ) THEN
--        BEGIN
--            SELECT
--                COUNT(tipo)
--            INTO v_conteo
--            FROM
--                prov101
--            WHERE
--                    id_cia = :old.id_cia
--                AND tipo = :old.tipo
--                AND docu = :old.docume;
--
--        EXCEPTION
--            WHEN no_data_found THEN
--                v_conteo := 0;
--        END;
--    END IF;
--
--    IF ( v_conteo > 0 ) THEN
--        RAISE pkg_exceptionuser.ex_documento_tiene_pagos;
--    END IF;
--    IF ( :new.situac <> 9 ) THEN
--        v_periodo := ( extract(YEAR FROM :new.femisi) * 100 ) + extract(MONTH FROM :new.femisi);
--
--        IF ( v_periodo > ( ( :new.periodo * 100 ) + :new.mes ) ) THEN
--            RAISE pkg_exceptionuser.ex_fecha_no_valida;
--        END IF;
--
--    END IF;
--
--    IF ( ( :new.dh IS NULL ) OR ( NOT ( ( upper(:new.dh) = 'D' ) OR ( upper(:new.dh) = 'H' ) ) ) ) THEN
--        BEGIN
--            SELECT
--                dh
--            INTO :new.dh
--            FROM
--                tdocume
--            WHERE
--                    id_cia = :new.id_cia
--                AND codigo = :new.tdocum;
--
--        EXCEPTION
--            WHEN no_data_found THEN
--                :new.dh := NULL;
--        END;
--
--        IF ( :new.dh IS NULL ) THEN
--            :new.dh := 'H';
--        END IF;
--
--    END IF;
--
--    :new.importe := abs(:new.importe);
--    :new.impor01 := abs(:new.impor01);
--    :new.impor02 := abs(:new.impor02);
--    :new.tcamb01 := abs(:new.tcamb01);
--    :new.tcamb02 := abs(:new.tcamb02);
--    :new.porigv := abs(:new.porigv);
--    :new.base := abs(:new.base);
--    :new.base01 := abs(:new.base01);
--    :new.base02 := abs(:new.base02);
--    :new.igv := abs(:new.igv);
--    :new.igv01 := abs(:new.igv01);
--    :new.igv02 := abs(:new.igv02);
--    :new.importep := abs(:new.importep);
--    :new.impor01p := abs(:new.impor01p);
--    :new.impor02p := abs(:new.impor02p);
--    :new.tcambiop := abs(:new.tcambiop);
--EXCEPTION
--    WHEN pkg_exceptionuser.ex_compr010_liq_com_duplicado THEN
--        raise_application_error(pkg_exceptionuser.compr010_liq_com_duplicado, ' Esta liquidación de compra ha sido registrada anteriormente.');
--    WHEN pkg_exceptionuser.ex_compr010_recibo_duplicado THEN
--        raise_application_error(pkg_exceptionuser.compr010_recibo_duplicado, ' El recibo ha sido registrado anteriormente.');
--    WHEN pkg_exceptionuser.ex_documento_tiene_pagos THEN
--        raise_application_error(pkg_exceptionuser.documento_tiene_pagos, 'El documento ya tiene pagos');
--    WHEN pkg_exceptionuser.ex_fecha_no_valida THEN
--        raise_application_error(pkg_exceptionuser.fecha_no_valida, '  La fecha no es válida ');
END;

/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_COMPR010" ENABLE;
