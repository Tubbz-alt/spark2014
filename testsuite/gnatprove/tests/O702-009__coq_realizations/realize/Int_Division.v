(* This file is generated by Why3's Coq-realize driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require int.Abs.
Require int.EuclideanDivision.
Require int.ComputerDivision.

(* Why3 assumption *)
Definition unit := unit.

(* Why3 goal *)
Definition qtmark : Type.
exact unit.
Defined.

(* Why3 goal *)
Definition mod1: Z -> Z -> Z.
exact (fun (x y : Z) => if Zlt_bool 0%Z y then int.EuclideanDivision.mod1 x y
else (int.EuclideanDivision.mod1 x y) + y)%Z.
Defined.

(* Why3 goal *)
Lemma mod'def :
forall (x:Z) (y:Z),
 ((0%Z < y)%Z -> ((mod1 x y) = (int.EuclideanDivision.mod1 x y)))
 /\ ((~ (0%Z < y)%Z) ->
     ((mod1 x y) = ((int.EuclideanDivision.mod1 x y) + y)%Z)).
intros x y; split; intro H1; unfold mod1;
pose proof (Zlt_cases 0 y) as hh; revert hh;
case (Zlt_bool 0%Z y); intro H2.
reflexivity.
contradiction.
contradiction.
reflexivity.
Qed.

