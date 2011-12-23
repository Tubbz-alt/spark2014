------------------------------------------------------------------------------
--                                                                          --
--                            GNAT2WHY COMPONENTS                           --
--                                                                          --
--                   G N A T 2 W H Y - D E C L S                            --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                       Copyright (C) 2010-2012, AdaCore                   --
--                                                                          --
-- gnat2why is  free  software;  you can redistribute  it and/or  modify it --
-- under terms of the  GNU General Public License as published  by the Free --
-- Software  Foundation;  either version 3,  or (at your option)  any later --
-- version.  gnat2why is distributed  in the hope that  it will be  useful, --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of  MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.  You should have  received  a copy of the GNU --
-- General  Public License  distributed with  gnat2why;  see file COPYING3. --
-- If not,  go to  http://www.gnu.org/licenses  for a complete  copy of the --
-- license.                                                                 --
--                                                                          --
-- gnat2why is maintained by AdaCore (http://www.adacore.com)               --
--                                                                          --
------------------------------------------------------------------------------

with Atree;                use Atree;
with Einfo;                use Einfo;
with Sinfo;                use Sinfo;

with Alfa.Definition;      use Alfa.Definition;

with Why.Sinfo;            use Why.Sinfo;
with Why.Atree.Accessors;  use Why.Atree.Accessors;
with Why.Atree.Builders;   use Why.Atree.Builders;
with Why.Gen.Decl;         use Why.Gen.Decl;
with Why.Gen.Names;        use Why.Gen.Names;
with Why.Gen.Binders;      use Why.Gen.Binders;
with Why.Inter;            use Why.Inter;
with Why.Types; use Why.Types;

with Gnat2Why.Types;       use Gnat2Why.Types;
with Gnat2Why.Expr;        use Gnat2Why.Expr;

package body Gnat2Why.Decls is

   ----------------
   -- Is_Mutable --
   ----------------

   function Is_Mutable (N : Node_Id) return Boolean
   is
   begin

      --  A variable is translated as mutable in Why if it is not constant on
      --  the Ada side, or if it is a loop parameter (of an actual loop, not a
      --  quantified expression.

      if Ekind (N) = E_Loop_Parameter then
         if Present (Parent (N)) and then
            Nkind (Parent (N)) = N_Loop_Parameter_Specification and then
            Present (Parent (Parent (N))) and then
            Nkind (Parent (Parent (N))) = N_Iteration_Scheme and then
            Present (Parent (Parent (Parent (N)))) and then
            Nkind (Parent (Parent (Parent (N)))) = N_Quantified_Expression
         then
            return False;
         else
            return True;
         end if;
      elsif Is_Constant_Object (N) then
         return False;
      elsif Ekind (N) in Named_Kind then
         return False;
      else
         return True;
      end if;
   end Is_Mutable;

   ------------------------
   -- Translate_Variable --
   ------------------------

   procedure Translate_Variable
     (File : W_File_Id;
      E    : Entity_Id)
   is
      Name : constant String := Full_Name (E);
      Decl : constant W_Declaration_Id :=
        (if Object_Is_In_Alfa (Unique (E)) then
            New_Type
              (Name  => Object_Type_Name.Id (Name),
               Alias => +Why_Logic_Type_Of_Ada_Obj (E))
         else
            New_Type
              (Name => Object_Type_Name.Id (Name),
               Args => 0));
      Typ  : constant W_Primitive_Type_Id :=
               New_Abstract_Type (Name => Get_Name (W_Type_Id (Decl)));

   begin
      --  Generate an alias for the name of the object's type, based on the
      --  name of the object. This is useful when generating logic functions
      --  from Ada functions, to generate additional parameters for the global
      --  objects read.

      Emit (File, Decl);

      --  We generate a global ref

      Emit
        (File,
         New_Global_Ref_Declaration
           (Name     => New_Identifier (Name),
            Ref_Type => Typ));
   end Translate_Variable;

   ------------------------
   -- Translate_Constant --
   ------------------------

   procedure Translate_Constant
     (File : W_File_Id;
      E    : Entity_Id)
   is
      Name : constant String := Full_Name (E);
      Typ  : constant W_Primitive_Type_Id := Why_Logic_Type_Of_Ada_Obj (E);
      Decl : constant Node_Id := Parent (E);
      Def  : Node_Id;

   begin
      --  We do not currently translate the definition of delayed constants,
      --  in order to support parameterized verification not depending on the
      --  value of a delayed constant. This could be modified to give access to
      --  the definition only in the package where the constant is defined.

      if Is_Public (E) and then In_Private_Part (E) then
         Def := Empty;

      --  Default values of parameters are not considered as the value of the
      --  constant representing the parameter.

      elsif Ekind (E) = E_In_Parameter then
         Def := Empty;

      else
         Def := Expression (Decl);
      end if;

      --  We generate a "logic", with a defining axiom if
      --  necessary and possible.

      Emit_Top_Level_Declarations
        (File        => File,
         Name        => New_Identifier (Name),
         Binders     => (1 .. 0 => <>),
         Return_Type => Typ,
         Spec        =>
           (1 =>
              (Kind   => W_Function_Decl,
               Domain => EW_Term,
               Def    => (if Present (Def) then
                          Get_Pure_Logic_Term_If_Possible
                            (File, Def, Type_Of_Node (E))
                          else Why_Empty),
               others => <>)));
   end Translate_Constant;

end Gnat2Why.Decls;
