--------------------------------------------------------
--  This file was automatically generated by Ocarina  --
--  Do NOT hand-modify this file, as your             --
--  changes will be lost when you re-run Ocarina      --
--------------------------------------------------------
pragma Style_Checks
 ("NM32766");

with Producer_Consumer;

package body PolyORB_HI_Generated.Subprograms is

  procedure Software_Produce_Spg
   (Data_Source : out PolyORB_HI_Generated.Types.Alpha_Type)
   renames Producer_Consumer.Produce_Spg;

  procedure Software_Consume_Spg
   (Data_Sink : PolyORB_HI_Generated.Types.Alpha_Type)
   renames Producer_Consumer.Consume_Spg;

end PolyORB_HI_Generated.Subprograms;
