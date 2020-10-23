------------------------------------------------------------------------------
--                                                                          --
--                            GNAT2WHY COMPONENTS                           --
--                                                                          --
--                            W H Y - S I N F O                             --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                     Copyright (C) 2010-2020, AdaCore                     --
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

package Why.Sinfo is
   pragma Pure;

   --  This package defines the structure of the abstract syntax tree. It does
   --  not strictly follow the Why syntax though; there is usually one entity
   --  for both program space and logic space, even if they are expressed with
   --  a different syntax in the generated Why code. This aims at reducing code
   --  duplication.
   --  This generation is driven by a Domain argument of type EW_Domain. It can
   --  be either:
   --   * EW_Pred  : For predicates
   --   * EW_Term  : For logic terms
   --   * EW_Prog  : For program terms
   --   * EW_Pterm : For program terms but without the runtime checks
   --     (introduced to experiment with epsilon terms in Why3, which can only
   --     be used in logic not programs, and currently equivalent to EW_Term,
   --     although we keep the distinction as a documentation aid which may be
   --     useful in the future).

   --  This file contains the Ada type definition of node kinds, but not the
   --  definition of the fields. The fields are generated by the file
   --     xgen/xtree_sinfo.adb,
   --  which parses this file and generates the actual node data structure.
   --  Whenever a change is made in xgen/xtree_sinfo.adb, or in this file,
   --  the other one needs to be updated to reflect this change.

   --  ----------------------------
   --  -- Special field Ada_Node --
   --  ----------------------------

   --  All Why nodes have a field Ada_Node. Depending on the node kind, this
   --  field may be simply informative or have strong semantic value. In
   --  general, it points to the Ada node which was the basis for the
   --  creation of this node.

   --  -----------------------
   --  -- Special field Typ --
   --  -----------------------

   --  Many nodes have a field "Typ" which gives the type of the Why
   --  expression. In some other cases, the Why type can be computed from
   --  the expression.

   --  --------------
   --  -- W_Module --
   --  --------------
   --  File        Name_Id
   --  Name        Name_Id
   --
   --  Identifies a module. If the module is in the current file, File is set
   --  to No_Name.
   --
   --  ------------
   --  -- W_Name --
   --  ------------
   --  Symbol      Name_Id
   --  Module      W_Module_Id
   --
   --  A why "scoped name", i.e. a name for all kinds of Why entities: types,
   --  functions, variables, etc. The difference with W_Identifier is the
   --  absence of a type field

   --  ------------
   --  -- W_Type --
   --  ------------
   --  Base_Type     EW_Type
   --  Name          W_Name_Id
   --  Is_Mutable    Boolean
   --  Relaxed_Init  Boolean

   --  A type node represents Why3 types. It also contains information that
   --  relates back to Ada types. Every type has a "name" field, which must
   --  be fully qualified.

   --  The Base_Type field determines the kind of type. Why simple types are
   --  represented directly as EW_Int, EW_Bool, etc.

   --  The type of Base_Type kind EW_Private is used for all objects that are
   --  of private type (and their full view is not in SPARK) and for objects
   --  of unknown type, such as entities that are defined in bodies of other
   --  units.

   --  The kind EW_Abstract is used for all Why3 types that directly correspond
   --  to an Ada type. Examples are Standard__Integer or Standard__String. In
   --  this case, the Ada_Node field points to the Ada type entity.

   --  The kind EW_Split is somewhat similar: it corresponds to the "split"
   --  type of some Ada types, such as unconstrained arrays. Again, the
   --  Ada_node points to the Ada type entity.

   --  Relaxed_Init is True for types introduced for expressions with relaxed
   --  initialization.

   --  ---------------
   --  -- W_Effects --
   --  ---------------
   --  Reads   W_Identifier_List
   --  Writes  W_Identifier_List
   --  Raises  W_Identifier_List
   --
   --  An effect expression, used in Why3 to e.g. declare the effects of a
   --  program function. Effects include reading and writing variables, and
   --  raising exceptions.

   --  --------------
   --  -- W_Binder --
   --  --------------
   --  Name       W_Identifier_Id
   --  Arg_Type   W_Type_Id

   --  In Why3 there are several ways of introducing a variable into a context.
   --  Common to all is that a variable is a name and a type. This node
   --  captures this idea and is used in several places.

   --  -----------------------------------
   --  -- W_Transparent_Type_Definition --
   --  -----------------------------------
   --  Type_Definition   W_Type_Id
   --
   --  Used in W_Type_Decl nodes, and represents a simple type alias.

   --  ----------------------
   --  -- W_Record_Binder --
   --  ----------------------
   --  Name       W_Identifier_Id
   --  Arg_Type   W_Type_Id
   --  Labels     Name_Id_Set
   --  Is_Mutable Boolean
   --
   --  Used to declare fields of record types

   --  -------------------------
   --  -- W_Record_Definition --
   --  -------------------------
   --  Fields     W_Record_Binder_List
   --
   --  Used in W_Type_Decl nodes, and represents a record structure: a list of
   --  field names with a type and possibly a mutable keyword.

   --  -----------------------------
   --  -- W_Range_Type_Definition --
   --  -----------------------------
   --  First      Uint
   --  Last       Uint
   --
   --  Used in W_Type_Decl nodes, and represents a bounded integer type.
   --  "< range First Last >"

   --  ----------------
   --  -- W_Triggers --
   --  ----------------
   --  Triggers   W_Trigger_List
   --
   --  ---------------
   --  -- W_Trigger --
   --  ---------------
   --  Terms     W_Expr_List
   --
   --  Nodes to represent triggers. In its most general form, a trigger is
   --  a list of lists of terms, hence the two kinds of nodes here. A single
   --  trigger (a list of terms) is a constraint on a quantifier: all indicated
   --  terms must be instantiated to be able to "trigger" the quantifier. A
   --  list of triggers represents an alternative: a single trigger is enough
   --  to be able to instantiate the axiom.
   --
   --  -------------------------
   --  -- W_Field_Association --
   --  -------------------------
   --  Field     W_Identifier_Id
   --  Value     W_Expr_Id
   --
   --  Used for record aggregates and updates: associates a field to a value.
   --
   --  ---------------
   --  -- W_Variant --
   --  ---------------
   --  Cmp_Op    W_Identifier_Id
   --  Labels    Symbol_Set
   --  Expr      W_Term
   --
   --  A single loop variant item. The Cmp_Op contains the comparison operator
   --  to be used in an expression of the form "new cmp old" to determine
   --  progress of the loop variant. The Labels node contains the info for
   --  the VC.
   --
   --  ----------------
   --  -- W_Variants --
   --  ----------------
   --  Variants  W_Variant_List
   --
   --  A list of loop variant items.
   --
   --  -------------------------
   --  -- W_Universal_Quantif --
   --  -------------------------
   --  ---------------------------
   --  -- W_Existential_Quantif --
   --  ---------------------------
   --  Variables  W_Identifier_List
   --  Labels     Name_Id_Set
   --  Var_Type   W_Type_Id
   --  Triggers   W_Triggers_Id
   --  Pred       W_Pred_Id
   --
   --  Quantifiers. The type of such expressions is always "bool".
   --
   --  ---------------
   --  -- W_Epsilon --
   --  ---------------
   --  Name       W_Identifier_Id
   --  Pred       W_Pred_Id
   --  Typ        W_Type_Id
   --
   --  Node for the Why3 epsilon quantification: "(eps x. p x)". It assumes the
   --  existence of an element of type Typ verifying Pred and returns it.
   --
   --  -----------
   --  -- W_Not --
   --  -----------
   --  Right      W_Expr_Id
   --
   --  logical negation. The type of such expressions is always "bool".
   --
   --  ------------------
   --  -- W_Connection --
   --  ------------------
   --  Left        W_Expr_Id
   --  Op          EW_Connector
   --  Right       W_Expr_Id
   --  More_Right  W_Expr_List
   --
   --  Logical connectors: "and", "or", etc. The type of such expressions is
   --  always "bool".
   --
   --  -------------
   --  -- W_Label --
   --  -------------
   --  Labels      Name_Id_Set
   --  Def         W_Expr_Id
   --  Typ         W_Type_Id
   --
   --  Every expression in Why3 can be labeled with strings. This special node
   --  allows this.
   --
   --  -----------------
   --  -- W_Loc_Label --
   --  -----------------
   --  Sloc        Source_Ptr
   --  Def         W_Expr_Id
   --
   --  Expressions in Why3 programs can be labeled with locations. This special
   --  node allows this.
   --
   --  ------------------
   --  -- W_Identifier --
   --  ------------------
   --  Symbol      Name_Id
   --  Namespace   Name_Id
   --  Module      W_Module_Id
   --  Typ         W_Type
   --  Infix       Boolean       (default False)
   --
   --  This node is used for all places where a name is used in Why. There are
   --  three fields to denote the precise name:
   --   - one for the module name ("Module")
   --   - one for a possible namespace inside the module ("Namespace")
   --   - one for the symbol name ("Symbol").
   --
   --  --------------
   --  -- W_Tagged --
   --  --------------
   --  Tag         Name_Id
   --  Def         W_Expr_Id
   --  Typ         W_Type_Id
   --
   --  This node is used to put a label on a term. An example is (at init t).
   --  The tag "old" has the special syntax (old t).
   --
   --  ------------
   --  -- W_Call --
   --  ------------
   --  Name       W_Identifier_Id
   --  Args       W_Expr_List
   --  Typ        W_Type_Id
   --
   --  The node for function calls. The Name field is the name of the function,
   --  "Args" is the argument list.
   --
   --  ---------------
   --  -- W_Literal --
   --  ---------------
   --  Value      EW_Literal
   --  Typ        W_Type_Id
   --
   --  The node for the boolean literals true/false.
   --  ?? is the Typ field needed?
   --
   --  ---------------
   --  -- W_Binding --
   --  ---------------
   --  Name       W_Identifier_Id
   --  Def        W_Expr_Id
   --  Context    W_Expr_Id
   --  Typ        W_Type_Id
   --
   --  A node to bind a local name to an expression, to be used in another
   --  expression. In Why3 syntax: "let x = def in context".
   --
   --  -------------
   --  -- W_Elsif --
   --  -------------
   --
   --  Condition  W_Expr_Id
   --  Then_Part  W_Expr_Id
   --  Typ        W_Type_Id
   --
   --  Special Elsif Node used in W_Conditional nodes.
   --
   --  -------------------
   --  -- W_Conditional --
   --  -------------------
   --  Condition   W_Expr_Id
   --  Then_Part   W_Expr_Id
   --  Elsif_Parts W_Expr_List
   --  Else_Part   W_Expr_Id
   --  Typ         W_Type_Id
   --
   --  An (if then else) expression, with possible elsif parts.
   --
   --  ------------------------
   --  -- W_Integer_Constant --
   --  ------------------------
   --  Value       Uint
   --
   --  The node for integer literals.
   --
   --  ----------------------
   --  -- W_Range_Constant --
   --  ----------------------
   --  Value       Uint
   --  Typ         W_Type_Id
   --
   --  The node for literals of bounded integer types "(Value : Typ)".
   --
   --  ------------------------
   --  -- W_Modular_Constant --
   --  ------------------------
   --  Value       Uint
   --  Typ         W_Type_Id
   --
   --  The node for modular literals.
   --
   --  ----------------------
   --  -- W_Fixed_Constant --
   --  ----------------------
   --  Value       Uint
   --
   --  The node for fixed-point literals.
   --
   --  ---------------------
   --  -- W_Real_Constant --
   --  ---------------------
   --  Value       Ureal
   --
   --  The node for real literals.
   --
   --  ----------------------
   --  -- W_Float_Constant --
   --  ----------------------
   --  Value       Ureal
   --  Typ         W_Type_Id
   --
   --  The node for float literals.
   --
   --  -------------
   --  -- W_Deref --
   --  -------------
   --  Right      W_Identifier_Id
   --  Typ        W_Type_Id
   --
   --  Mutable variables must be derefenced explicitly in Why3 (syntax
   --  x.ty__content).
   --  This is the node for this.
   --
   --  ---------------------
   --  -- W_Record_Access --
   --  ---------------------
   --  Name       W_Expr_Id
   --  Field      W_Identifier_Id
   --  Typ        W_Type_Id
   --
   --  Node for the Why3 record access syntax "name.field". Note that the
   --  identifier may have a context, so that the overall expression often is
   --  more like "name.Module.field".
   --
   --  ---------------------
   --  -- W_Record_Update --
   --  ---------------------
   --
   --  Name       W_Expr_Id
   --  Updates    W_Field_Association_List
   --  Typ        W_Type_Id
   --
   --  Node for the Why3 record update syntax
   --  "{name with field1 = value; field2 = value2; ... }".
   --
   --  ------------------------
   --  -- W_Record_Aggregate --
   --  ------------------------
   --  Associations W_Field_Association_List
   --  Typ          W_Type_Id
   --
   --  Node for the Why3 record aggregate syntax
   --  "{field1 = value; field2 = value2; ... }".
   --
   --  ----------------
   --  -- W_Any_Expr --
   --  ----------------
   --  Effects      W_Effects_Id
   --  Pre          W_Pred_Id
   --  Post         W_Pred_Id
   --  Return_Type  W_Type_Id
   --
   --  ------------------
   --  -- W_Assignment --
   --  ------------------
   --  Name       W_Identifier_Id
   --  Value      W_Prog_Id
   --  Typ        W_Type_Id
   --
   --  Node the Why3 assignment: "x.typ__content <- e". The type of the
   --  expression is always "unit".

   --  -------------------
   --  -- W_Binding_Ref --
   --  -------------------
   --  Name       W_Identifier_Id
   --  Def        W_Prog_Id
   --  Context    W_Prog_Id
   --  Typ        W_Type_Id
   --
   --  Same as W_Binding, but the new introduced variable is a mutable
   --  variable. Why3 syntax "let x = { typ__content = def } in context".
   --
   --  ------------
   --  -- W_Loop --
   --  ------------
   --  Code_Before  W_Prog_Id
   --  Invariants   W_Pred_List
   --  Variants     Variants_List
   --  Code_After   W_Prog_Id
   --
   --  An infinite loop (without loop condition), with a block of loop
   --  invariant and variants that can appear anywhere in the loop.
   --
   --  --------------------------
   --  -- W_Statement_Sequence --
   --  --------------------------
   --  Statements  W_Prog_List
   --
   --  A list of statements, syntax "e1; e2; ..." (no trailing ';'). Note that
   --  the overall type of the expression is not "unit", but the type of the
   --  last expression.
   --
   --  ---------------------
   --  -- W_Abstract_Expr --
   --  ---------------------
   --  Expr       W_Prog_Id
   --  Post       W_Pred_Id
   --  Typ        W_Type_Id
   --
   --  This is the abstraction node, the syntax is "abstract expr { post }".
   --  "post" works like an assertion. For the code *after* the abstract node,
   --  only the "post" is visible, and not the details in "expr".
   --
   --  --------------
   --  -- W_Assert --
   --  --------------
   --  Pred       W_Pred_Id
   --  Kind       EW_Assert_Kind
   --
   --  An assertion expression. The type of the expression is always "unit".
   --  The Kind is one of (Assert | Check). A check simply requires to prove
   --  the predicate, while an assert also enriches the context of following
   --  VCs.
   --
   --  -------------
   --  -- W_Raise --
   --  -------------
   --  Name       W_Name_Id
   --  Exn_Type   W_Type_Id
   --  Typ        W_Type_Id
   --
   --  An exception raising expression of the syntax "raise Name".
   --  ??? What is Exn_Type used for?
   --
   --  -----------------
   --  -- W_Try_Block --
   --  -----------------
   --
   --  Prog       W_Prog_Id
   --  Handler    W_Handler_List
   --  Typ        W_Type_Id

   --  ---------------
   --  -- W_Handler --
   --  ---------------
   --  Name       W_Name_Id
   --  Arg        W_Prog_Id
   --  Def        W_Prog_Id
   --
   --  An exception handling expression. Syntax is
   --    "try prog with | Ex1 => e1 | Ex2 => e2 | ... end"
   --  If "prog" raises on of the handled exceptions, the corresponding
   --  expression is executed. Other exceptions "go through".
   --
   --  ---------------------
   --  -- W_Function_Decl --
   --  ---------------------
   --  Name        W_Identifier_Id
   --  Binders     W_Binder_List
   --  Effects     W_Effects_Id
   --  Pre         W_Pred_Id
   --  Post        W_Pred_Id
   --  Return_Type W_Type_Id
   --  Def         W_Expr_Id
   --  Labels      Name_Id_Set
   --
   --  A function declaration with possible effects, pre and post. Set the
   --  Domain to EW_Pred to generate a predicate, with an empty return type.
   --  Set Def to empty to build a declaration
   --
   --  -------------
   --  -- W_Axiom --
   --  -------------
   --  Name       Name_Id
   --  Def        W_Pred_Id
   --  ------------
   --  -- W_Goal --
   --  ------------
   --  Name       Name_Id
   --  Def        W_Pred_Id
   --
   --  axioms and goals have a name and a predicate.
   --  ??? Goal node is not needed
   --
   --  -----------------
   --  -- W_Type_Decl --
   --  -----------------
   --  Args       W_Identifier_List
   --  Name       W_Name_Id
   --  Labels     Name_Id_Set
   --  Definition W_Type_Definition_Id
   --
   --  A type declaration. W_Type_Definition_Id can be one of
   --  W_Transparent_Type_Definition or W_Record_Definition or W_Type.
   --
   --  ------------------------------
   --  -- W_Global_Ref_Declaration --
   --  ------------------------------
   --  Name       W_Identifier_Id
   --  Ref_Type   W_Type_Id
   --  Labels     Name_Id_Set
   --
   --  Declaration of a global mutable variable. Note that global constants are
   --  simply declared as functions without arguments.
   --
   --  -----------------------------
   --  -- W_Exception_Declaration --
   --  -----------------------------
   --  Name       W_Name_Id
   --  Arg        W_Type_Id
   --
   --  Declaration of an exception, with a possible argument.
   --
   --  ---------------------------
   --  -- W_Include_Declaration --
   --  ---------------------------
   --  Module     W_Module_Id
   --  Kind       EW_Theory_Type
   --  Use_Kind   EW_Clone_Type
   --
   --  An include directive. It is of the form "use [import] file.Module".
   --
   --  ------------------------
   --  -- W_Meta_Declaration --
   --  ------------------------
   --  Name      Name_Id
   --  Parameter Name_Id
   --
   --  A meta directive. It is of the form "meta "name" parameter".
   --
   --  -------------------------
   --  -- W_Clone_Declaration --
   --  -------------------------
   --  Origin        W_Module_Id
   --  As_Name       Name_Id
   --  Clone_Kind    EW_Clone_Type
   --  Substitutions W_Clone_Substitution_List
   --  Theory_Kind   EW_Theory_Type

   --  --------------------------
   --  -- W_Clone_Substitution --
   --  --------------------------
   --  Kind       EW_Subst_Type
   --  Orig_Name  W_Name_Id
   --  Image      W_Name_Id
   --
   --  An clone directive. A clone is similar to an Ada generic instantiation.
   --  A major difference is that any module can be cloned, there are no
   --  special generic modules. Upon cloning, symbols of the cloned module
   --  can be replaced by known symbols. Syntax is
   --
   --    clone Module (as M) with
   --       type t = my_t
   --       function f = my_f
   --       ...
   --
   --  --------------------------
   --  -- W_Theory_Declaration --
   --  --------------------------
   --  Declarations  W_Declaration_List
   --  Name          Name_Id
   --  Kind          EW_Theory_Type
   --  Includes      W_Include_Declaration_List
   --  Comment       Name_Id
   --
   --  The declaration of a theory or module. Actually, gnat2why only generates
   --  modules. The node contains the list of Declarations, its kind (theory
   --  or module) and name, and the list of includes of other modules and
   --  theories. A special comment can be given.

   type Why_Node_Kind is
     (
      W_Unused_At_Start,

      -----------
      -- Types --
      -----------

      W_Type,
      W_Name,

      --------------------
      -- Type structure --
      --------------------

      W_Effects,
      W_Binder,
      W_Transparent_Type_Definition,
      W_Record_Binder,
      W_Record_Definition,
      W_Range_Type_Definition,

      -------------------------
      -- Predicate structure --
      -------------------------

      W_Triggers,
      W_Trigger,

      --------------------
      -- Prog structure --
      --------------------

      W_Handler,
      W_Field_Association,
      W_Variant,
      W_Variants,

      -----------------
      -- Preds, Expr --
      -----------------

      W_Universal_Quantif,
      W_Existential_Quantif,

      ------------------------
      -- Preds, Progs, Expr --
      ------------------------

      W_Not,
      W_Connection,
      W_Label,
      W_Loc_Label,

      -------------------------------
      -- Preds, Terms, Progs, Expr --
      -------------------------------

      W_Identifier,
      W_Tagged,
      W_Call,
      W_Literal,
      W_Binding,
      W_Elsif,
      W_Epsilon,
      W_Conditional,

      -------------------------
      -- Terms, Progs, Exprs --
      -------------------------

      W_Integer_Constant,
      W_Range_Constant,
      W_Modular_Constant,
      W_Fixed_Constant,
      W_Real_Constant,
      W_Float_Constant,
      W_Comment,
      W_Deref,
      W_Record_Access,
      W_Record_Update,
      W_Record_Aggregate,

      -----------------
      -- Progs, Expr --
      -----------------

      W_Any_Expr,
      W_Assignment,
      W_Binding_Ref,
      W_Loop,
      W_Statement_Sequence,
      W_Abstract_Expr,
      W_Assert,
      W_Raise,
      W_Try_Block,

      ----------------------------
      -- Top-level declarations --
      ----------------------------

      W_Function_Decl,
      W_Axiom,
      W_Goal,
      W_Type_Decl,
      W_Global_Ref_Declaration,
      W_Namespace_Declaration,
      W_Exception_Declaration,
      W_Include_Declaration,
      W_Meta_Declaration,
      W_Clone_Declaration,
      W_Clone_Substitution,
      W_Theory_Declaration,

      -----------------
      -- Input files --
      -----------------

      W_Module

      );

   type EW_ODomain is
     (EW_Expr,
      EW_Term,
      EW_Pterm,
      EW_Pred,
      EW_Prog);

   subtype EW_Domain is EW_ODomain range
       EW_Term ..
   --  EW_Pterm,
   --  EW_Pred
       EW_Prog;

   subtype EW_Terms is EW_ODomain range
       EW_Term ..
       EW_Pterm;

   type EW_Type is
     (EW_Builtin,

      --  This is a special marker for "split types"

      EW_Split,
      EW_Abstract);

   type EW_Literal is
     (EW_True,
      EW_False);

   type EW_Theory_Type is
     (EW_Theory,
      EW_Module);

   type EW_Clone_Type is
      (EW_Import,
       EW_Export,
       EW_Clone_Default);

   type EW_Subst_Type is
      (EW_Type_Subst,
       EW_Function,
       EW_Predicate,
       EW_Namepace,
       EW_Lemma,
       EW_Goal);

   type EW_Connector is
     (EW_Or_Else,
      EW_And_Then,
      EW_Imply,
      EW_Equivalent,
      EW_Or,
      EW_And);

   type EW_Assert_Kind is
     (EW_Assert,
      EW_Check,
      EW_Assume);

end Why.Sinfo;
