------------------------------------------------------------------------------
--                                                                          --
--                           GNAT2WHY COMPONENTS                            --
--                                                                          --
--                        F L O W . A N A L Y S I S                         --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                  Copyright (C) 2013-2014, Altran UK Limited              --
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
------------------------------------------------------------------------------

--  This package looks at the produced graphs and emits error
--  messages.

package Flow.Analysis is

   procedure Analyse_Main (FA : Flow_Analysis_Graphs);
   --  If FA corresponds to a main program, we ensure that
   --  all globals it references are initialized.

   procedure Sanity_Check (FA   : Flow_Analysis_Graphs;
                           Sane : out Boolean);
   --  Check the following basic properties:
   --     - is aliasing present (using the flag FA.Aliasing_Present)?
   --     - absence of variables in default initializations of
   --       record components and discriminants (SPARK LRM 4.4(2))
   --     - are all global variables used declared as such?
   --     - are we updating a variable we shouldn't (in parameter / global
   --       or package external state in an elaboration)
   --
   --  Complexity is O(N)

   procedure Sanity_Check_Postcondition (FA   : Flow_Analysis_Graphs;
                                         Sane : in out Boolean)
   with Pre => Sane;
   --  Check post, refined_post and initializes for use of variables
   --  we have not introduced through a global or parameter.
   --
   --  Complexity is O(N)

   procedure Find_Unwritten_Exports (FA : Flow_Analysis_Graphs);
   --  Find outputs which are never written to.
   --
   --  Complexity is O(N)

   procedure Find_Ineffective_Imports_And_Unused_Objects
     (FA : Flow_Analysis_Graphs);
   --  Find all ineffective initial values and all unused objects.
   --
   --  Complexity is O(N^2) and O(N) respectively.

   procedure Find_Ineffective_Statements (FA : Flow_Analysis_Graphs);
   --  Find all ineffective statements.
   --
   --  Complexity is O(N^2)

   procedure Find_Dead_Code (FA : Flow_Analysis_Graphs);
   --  Find all obviously dead code.
   --
   --  Complexity is O(N)

   procedure Enforce_No_Return (FA : Flow_Analysis_Graphs);
   --  If the analysed subprogram is marked No_Return, we check that we
   --  never return. In all other cases this procedure does nothing.
   --
   --  Complexity is O(N).

   procedure Find_Use_Of_Uninitialized_Variables (FA : Flow_Analysis_Graphs);
   --  Find all instances where uninitialized variables are used. If a
   --  variable is always uninitialized then raise an Error, otherwise
   --  raise a Warning.
   --
   --                               Algorithm
   --  * Find a vertex (USE) that has an edge from a 'Initial vertex going in
   --    it.
   --  * In the CFG graph starting from USE, perform a DFS in reverse and stop
   --    upon finding a vertex (DEF) that defines the variable associated with
   --    the 'Initial vertex.
   --  * If DEF does not exist then issue an Error. Else, if DEF exists:
   --    - if there exists a route in the CFG from Start -> DEF that does not
   --      cross USE, then issue a Warning
   --    - else if USE does NOT have an arrow coming in from the Start vertex
   --      (in the PDG graph) then issue a Warning
   --    - else issue an Error.
   --
   --  Complexity is O(N^2)

   procedure Find_Stable_Elements (FA : Flow_Analysis_Graphs);
   --  Find stable loop statements.
   --
   --  Complexity is O(N^2)

   procedure Find_Exports_Derived_From_Proof_Ins (FA : Flow_Analysis_Graphs);
   --  Finds exports derived from global variables with mode Proof_In.
   --
   --  Complexity is O(N^2) - (due to path search on each element of the
   --  precomputed dependency map)

   procedure Check_Contracts (FA : Flow_Analysis_Graphs);
   --  Check the given depends against the reality. If there is no
   --  depends aspect this procedure does nothing.
   --
   --  Complexity is O(N^2)

   procedure Check_Initializes_Contract (FA : Flow_Analysis_Graphs)
   with Pre => FA.Kind in E_Package | E_Package_Body;
   --  Checks if the Initializes contract has extra dependencies or missing
   --  dependencies.
   --
   --  Complexity is O(N^2)

private

   type Var_Use_Kind is (Use_Read, Use_Write, Use_Any);

   function Error_Location (G : Flow_Graphs.T'Class;
                            M : Attribute_Maps.Map;
                            V : Flow_Graphs.Vertex_Id)
                            return Node_Or_Entity_Id;
   --  Find a good place to raise an error for vertex V.

   procedure Global_Required
     (FA  : Flow_Analysis_Graphs;
      Var : Flow_Id)
   with Pre  => Var.Kind = Magic_String;
   --  Emit an error message that (the first call) introducing the
   --  global Var requires a global annotation.

   function First_Variable_Use (N       : Node_Id;
                                FA      : Flow_Analysis_Graphs;
                                Scope   : Flow_Scope;
                                Var     : Flow_Id;
                                Precise : Boolean)
                                return Node_Id;
   --  Given a node N, we traverse the tree to find the most deeply
   --  nested node which still uses Var. If Precise is True look only
   --  for Var (for example R.Y), otherwise we also look for the
   --  entire variable represented by Var (in our example we'd also
   --  look for R).
   --
   --  If we cannot find any suitable node we return N itself.

   function First_Variable_Use (FA      : Flow_Analysis_Graphs;
                                Var     : Flow_Id;
                                Kind    : Var_Use_Kind;
                                Precise : Boolean)
                                return Node_Id;
   --  Find a suitable node in the tree which uses the given
   --  variable. If Precise is True look only for Var (for example
   --  R.Y), otherwise we also look for the entire variable
   --  represented by Var (in our example we'd also look for R).
   --
   --  If no suitable node can be found we return FA.Analyzed_Entity
   --  as a fallback.

end Flow.Analysis;
