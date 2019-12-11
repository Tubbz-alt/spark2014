package Pack with SPARK_Mode is

   procedure Jump (B : Boolean) with No_Return, Pre => B;

   procedure Call_Jump (B : Boolean) with
     Annotate => (GNATprove, Might_Not_Return),
     Global => null,
     Post => not B;

   procedure Proc with
     Annotate => (GNATprove, Might_Not_Return),
     Global => null;

   procedure Call_Jump2 (B : Boolean) with
     Annotate => (GNATprove, Might_Not_Return),
     Post => not B;
   --  This is the same as Call_Jump, but without a Global contract

end Pack;
