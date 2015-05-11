(* This file is generated by Why3's Coq-realize driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require bool.Bool.
Require int.Int.

(* Why3 assumption *)
Definition unit := unit.

(* Why3 goal *)
Definition qtmark : Type.
exact unit.

Defined.

(* Why3 goal *)
Definition bool_eq: Z -> Z -> bool.
exact Z.eqb.
Defined.

(* Why3 goal *)
Definition bool_ne: Z -> Z -> bool.
intros a b.
exact (negb (Z.eqb a b)).
Defined.

(* Why3 goal *)
Definition bool_lt: Z -> Z -> bool.
exact Z.ltb.

Defined.

(* Why3 goal *)
Definition bool_le: Z -> Z -> bool.
exact Z.leb.
Defined.

(* Why3 goal *)
Definition bool_gt: Z -> Z -> bool.
exact Z.gtb.

Defined.

(* Why3 goal *)
Definition bool_ge: Z -> Z -> bool.
exact Z.geb.
Defined.

(* Why3 goal *)
Lemma bool_eq_axiom :
forall (x:Z), forall (y:Z), ((bool_eq x y) = true) <-> (x = y).
exact Z.eqb_eq.
Qed.

(* Why3 goal *)
Lemma bool_ne_axiom :
forall (x:Z), forall (y:Z), ((bool_ne x y) = true) <-> ~ (x = y).
intros x y.
rewrite <- bool_eq_axiom.
unfold bool_ne, bool_eq, negb. case ((x =? y)%Z); split; intro H; auto.
contradict H; auto.
Qed. 

(* Why3 goal *)
Lemma bool_lt_axiom :
forall (x:Z), forall (y:Z), ((bool_lt x y) = true) <-> (x < y)%Z.
unfold bool_lt; exact Z.ltb_lt.
Qed.

(* Why3 goal *)
Lemma bool_int__le_axiom :
forall (x:Z), forall (y:Z), ((bool_le x y) = true) <-> (x <= y)%Z.
unfold bool_le; exact Z.leb_le.

Qed.

(* Why3 goal *)
Lemma bool_gt_axiom :
forall (x:Z), forall (y:Z), ((bool_gt x y) = true) <-> (y < x)%Z.
unfold bool_gt; exact Z.gtb_lt.

Qed.

(* Why3 goal *)
Lemma bool_ge_axiom :
forall (x:Z), forall (y:Z), ((bool_ge x y) = true) <-> (y <= x)%Z.
unfold bool_ge; exact Z.geb_le.

Qed.

