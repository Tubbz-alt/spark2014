with Loop_Types; use Loop_Types;

procedure Init_Arr_Index (A : out Arr_T) with
  SPARK_Mode,
  Post => (for all J in A'Range => A(J) = J)
is
   pragma Annotate (GNATprove, False_Positive, """A"" might not be initialized",
                    "Entire array is initialized element-by-element in a loop");
begin
   for J in A'Range loop
      A(J) := J;
      pragma Loop_Invariant (for all K in A'First .. J => A(K) = K);
      pragma Annotate (GNATprove, False_Positive, """A"" might not be initialized",
                       "Part of array up to index J is initialized at this point");
   end loop;
end Init_Arr_Index;
