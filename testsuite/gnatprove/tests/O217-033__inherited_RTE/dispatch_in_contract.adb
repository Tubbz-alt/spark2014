package body Dispatch_In_Contract with SPARK_Mode is

   procedure Incr (O : in out Root) is
   begin
      O.F1 := O.F1 + 1;
   end;

   procedure Incr2 (O : in out Root) is
   begin
      O.F1 := O.F1 + 1;
   end;

   procedure Incr (O : in out Child) is
   begin
      O.F1 := O.F1 + 1;
   end;

   procedure Incr2 (O : in out Child) is
   begin
      O.F1 := O.F1 + 1; --@OVERFLOW_CHECK:FAIL
   end;

end Dispatch_In_Contract;
