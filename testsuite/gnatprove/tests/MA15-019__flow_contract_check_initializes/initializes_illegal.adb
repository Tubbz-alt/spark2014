package body Initializes_Illegal
  with SPARK_Mode,
       Refined_State => (SA => (Y, Z))
is
   Y, Z : Integer;

   procedure Does_Nothing is begin null; end Does_Nothing;
begin
   --  Y := 0;         --  error: Y is not initialized
   Z := Init.Sum_All;  --  warning: State does not depend on Init.A
end Initializes_Illegal;
