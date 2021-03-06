package body Students
   with SPARK_Mode => On
is
   function Compute_Bill (Student      : in Student_Record;
                          Base_Tuition : in Money_Type) return Money_Type is
      Tuition   : Money_Type;
      Fees      : Money_Type;
      Grants    : Money_Type := 0.00;
      Insurance : Money_Type := 0.00;
   begin
      Tuition := Base_Tuition;

      if not Student.In_State then
         -- Out of state tuition is 50% higher.
         Tuition := Tuition + Tuition/2;
      end if;

      -- Compute health insurance premium.
      if not Student.Self_Insured then
         Insurance := 1_000.00;
      end if;

      -- Compute base fees depending on full-time/part-time status.
      if Student.Part_Time then
         Fees := 100.00;
      else
         Fees := 500.00;
      end if;

      -- Room and board.
      if Student.Resident then
         Fees := Fees + 4_000.00;  -- Room.
         case Student.Meal_Plan is
            when None       => null;
            when On_Demand  => Fees := Fees +   100.00;
            when Basic      => Fees := Fees + 1_000.00;
            when Full       => Fees := Fees + 3_000.00;
         end case;
      else
         -- Non resident students getting a meal plan pay a premium.
         case Student.Meal_Plan is
            when None       => null;
            when On_Demand  => Fees := Fees +   200.00;
            when Basic      => Fees := Fees + 1_500.00;
            when Full       => Fees := Fees + 4_500.00;
         end case;
      end if;

      -- University policy: give high achieving students a break.
      if Student.GPA >= 3.00 then
         Grants := Grants + 250.00;

         -- Special directive from the state for very high achieving women.
         if Student.GPA >= 3.75 and Student.Gender = Female then
            Grants := Grants + 250.00;
         end if;
      end if;

      return ((Tuition + Fees) - Grants) + Insurance;
   end Compute_Bill;

end Students;
