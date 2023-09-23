--------------------------------------------------------
--  Ref Constraints for Table MOVIMIENTOS
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."MOVIMIENTOS" ADD CONSTRAINT "FK_MOVIMIENTOS_PCUENTAS" FOREIGN KEY ("ID_CIA", "CUENTA")
	  REFERENCES "USR_TSI_SUITE"."PCUENTAS" ("ID_CIA", "CUENTA") ENABLE;
