with Ada.Text_IO;
use Ada.Text_IO;



procedure move_ex1 with SPARK_Mode is
  type Int_Ptr is access integer;

Procedure Swap(X_Param, Y_Param : in out Int_Ptr) is
  Tmp : Int_Ptr := X_Param;
  Begin
     X_Param := Y_Param;
     Y_Param := Tmp;
  End Swap;

  X : Int_Ptr := new Integer;
  Y : Int_Ptr := new Integer;
  
  begin
	Swap(X, Y);
	(...)
  end move_ex1;

