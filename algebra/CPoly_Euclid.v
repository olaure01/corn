(*
Copyright © 2009 Valentin Blot

Permission is hereby granted, free of charge, to any person obtaining a copy of
this proof and associated documentation files (the "Proof"), to deal in
the Proof without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Proof, and to permit persons to whom the Proof is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Proof.

THE PROOF IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE PROOF OR THE USE OR OTHER DEALINGS IN THE PROOF.
*)

Require Import CPoly_Degree Omega.

Set Implicit Arguments.
Unset Strict Implicit.

Section poly_eucl.
Variable CR : CRing.

Lemma degree_poly_div : forall (m n : nat) (f g : cpoly CR),
  let f1 := (_C_ (nth_coeff n g) [*] f [-] _C_ (nth_coeff (S m) f) [*] ((_X_ [^] ((S m) - n)) [*] g)) in
    S m >= n -> degree_le (S m) f -> degree_le n g -> degree_le m f1.
Proof.
intros m n f g f1 ge_m_n df dg p Hp; unfold f1; clear f1.
rewrite nth_coeff_minus, nth_coeff_c_mult_p, nth_coeff_c_mult_p, nth_coeff_mult.
rewrite (Sum_term _ _ _ (S m - n)); [ | omega | omega | intros ].
  rewrite nth_coeff_nexp_eq.
  destruct Hp.
    replace (S m - (S m - n)) with n by omega; rational.
  rewrite (dg (S m0 - (S m - n))); [ | omega].
  rewrite df; [ rational | omega].
  rewrite nth_coeff_nexp_neq; [ rational | assumption].
Qed.

Theorem cpoly_div1 : forall (m n : nat) (f g : cpoly_cring CR),
  degree_le m f -> degree_le (S n) g -> n <= m ->
    {qr: (cpoly_cring CR)*(cpoly_cring CR) &
    let (q,r):=qr in f [*] _C_ ((nth_coeff (S n) g) [^] (m - n)) [=] q [*] g [+] r &
    let (q,r):=qr in degree_le n r}.
Proof.
intros m n; set (H := refl_equal (m - n)); revert H.
generalize (m - n) at 1 as p; intro p; revert m n; induction p; intros.
  exists ((Zero : cpoly_cring CR),f).
  rewrite <- H.
  simpl (nth_coeff (S n) g[^]0); rewrite <- _c_one; rational.
  replace n with m by omega; assumption.
set (f1 := (_C_ (nth_coeff (S n) g) [*] f [-] _C_ (nth_coeff m f) [*] ((_X_ [^] (m - (S n))) [*] g))).
destruct (IHp (m - 1) n) with (f := f1) (g := g); [ omega | | assumption | omega | ].
  unfold f1; clear f1.
  assert (HypTmp : m = S (m - 1)); [ omega | rewrite HypTmp; rewrite <- HypTmp at 1 ].
  apply degree_poly_div; [ omega | rewrite <- HypTmp; assumption | assumption ].
destruct x as [q1 r1].
exists (q1 [+] _C_ ((nth_coeff (S n) g)[^](m - S n) [*] (nth_coeff m f)) [*] _X_ [^] (m - S n), r1); [ | assumption].
unfold f1 in y.
rewrite ring_distl_unfolded, <- plus_assoc_unfolded, (cag_commutes _ _ r1), plus_assoc_unfolded, <- y.
replace (m - n) with (S (m - S n)) by omega.
replace (m - 1 - n) with (m - S n) by omega.
rewrite <- nexp_Sn.
generalize (nth_coeff (S n) g) (nth_coeff m f) (m - S n).
intros; rewrite _c_mult, _c_mult; rational.
Qed.

Definition degree_lt_pair (p q : cpoly_cring CR) := (forall n : nat, degree_le (S n) q -> degree_le n p) and (degree_le O q -> p [=] Zero).
Lemma cpoly_div2 : forall (n m : nat) (a b c : cpoly_cring CR),
  degree_le n a -> monic m b -> degree_lt_pair c b -> a [*] b [=] c ->
    a [=] Zero.
Proof.
induction n.
  intros; destruct (degree_le_zero _ _ H).
  rewrite s; rewrite s in H1; destruct X; rewrite _c_zero; apply cpoly_const_eq.
  destruct m.
    set (tmp := nth_coeff_wd _ 0 _ _ H1); destruct H0.
    rewrite nth_coeff_c_mult_p, H0, mult_one, (nth_coeff_wd _ _ _ _ (s0 H2)) in tmp; apply tmp.
  set (tmp := nth_coeff_wd _ (S m) _ _ H1); destruct H0.
  rewrite nth_coeff_c_mult_p, H0, mult_one, (d m H2 (S m)) in tmp; [ apply tmp | apply le_n ].
intros.
induction a as [ | a s ] using cpoly_induc; [ reflexivity | ].
apply _linear_eq_zero.
rewrite cpoly_lin in H1.
rewrite ring_distl_unfolded in H1.
cut (a [=] Zero); [ intro aeqz; split; [ | apply aeqz ] | ].
  assert (s [=] nth_coeff m (_C_ s[*]b[+]_X_[*]a[*]b)).
    destruct H0; rewrite nth_coeff_plus, nth_coeff_c_mult_p, H0.
    rewrite (nth_coeff_wd _ _ _ Zero); [ simpl; rational | ].
    rewrite aeqz; rational.
  rewrite H2.
  rewrite (nth_coeff_wd _ _ _ _ H1).
  destruct X.
  destruct H0.
  destruct m; [ rewrite (nth_coeff_wd _ _ _ _ (s0 H3)); reflexivity | apply (d m H3); apply le_n ].
apply (IHn (S m) _ (Zero [+X*] b) (c [-] _C_ s [*] b)); [ | | | rewrite <- H1, cpoly_lin, <- _c_zero; rational ].
    unfold degree_le; intros; rewrite <- (coeff_Sm_lin _ _ s).
    apply H; apply lt_n_S; apply H2.
  split; [ rewrite coeff_Sm_lin; destruct H0; apply H0 | unfold degree_le; intros ].
  destruct m0; [ inversion H2 | simpl; destruct H0 ].
  apply H3; apply lt_S_n; apply H2.
unfold degree_lt_pair.
split; intros.
  unfold degree_le; intros.
  rewrite nth_coeff_minus, nth_coeff_c_mult_p, (degree_le_cpoly_linear _ _ _ _ H2); [ | apply H3 ].
  rewrite cring_mult_zero, cg_inv_zero; destruct X.
  destruct m; [ destruct H0; apply (nth_coeff_wd _ _ _ _ (s0 H4)) | ].
  apply (d n0); [ | apply H3 ].
  apply (degree_le_mon _ _ n0); [ apply le_S; apply le_n | apply (degree_le_cpoly_linear _ _ _ _ H2) ].
destruct (degree_le_zero _ _ H2); rewrite cpoly_C_ in s0.
destruct (linear_eq_linear_ _ _ _ _ _ s0); rewrite <- H1, H4; rational.
Qed.

Lemma cpoly_div : forall (f g : cpoly_cring CR) (n : nat), monic n g ->
  ex_unq (fun (qr : ProdCSetoid (cpoly_cring CR) (cpoly_cring CR)) => f[=](fst qr)[*]g[+](snd qr) and degree_lt_pair (snd qr) g).
Proof.
intros; destruct n.
  destruct H; destruct (degree_le_zero _ _ H0).
  rewrite (nth_coeff_wd _ _ _ _ s) in H; simpl in H; rewrite H in s.
  exists (f,Zero).
    intros; destruct y; simpl (snd (s0, s1)) in *; simpl (fst (s0, s1)) in *.
    destruct X; destruct d; split; [ | symmetry; apply (s3 H0) ].
    rewrite s2, (s3 H0), s, <- _c_one; rational.
  simpl (fst (f, Zero : cpoly_cring CR)); simpl (snd (f, Zero : cpoly_cring CR)).
  replace (cpoly_zero CR) with (Zero : cpoly_cring CR) by (simpl;reflexivity).
  split; [ rewrite s, <- _c_one; rational | ].
  split; [ | reflexivity ].
  unfold degree_le; intros; apply nth_coeff_zero.
destruct (@cpoly_div1 (max (lth_of_poly f) n) n f g); [ | destruct H; assumption | apply le_max_r | ].
  apply (@degree_le_mon _ _ (lth_of_poly f)); [ apply le_max_l | apply poly_degree_lth ].
destruct H; destruct x as [q r].
rewrite H, one_nexp, mult_one in y.
assert (f[=]q[*]g[+]r and degree_lt_pair r g).
  split; [ assumption | ].
  split.
    intros; unfold degree_le; intros; apply y0; apply le_lt_trans with n0; [ | assumption ].
    unfold degree_le in H1; apply not_gt; intro; unfold gt in H3.
    set (tmp := (H1 (S n) (lt_n_S _ _ H3))); rewrite H in tmp.
    apply (eq_imp_not_ap _ _ _ tmp); apply ring_non_triv.
  intro; unfold degree_le in H1; rewrite H1 in H; [ | apply lt_O_Sn ].
  destruct (eq_imp_not_ap _ _ _ H); apply ap_symmetric; apply ring_non_triv.
exists (q,r); [ | assumption ].
intros; destruct y1 as [q1 r1]; simpl (fst (q1, r1)); simpl (snd (q1, r1)) in X0.
destruct X; destruct X0; rewrite s in s0; assert (q [=] q1).
  apply cg_inv_unique_2.
  apply (@cpoly_div2 (lth_of_poly (q [-] q1)) (S n) (q [-] q1) g (r1 [-] r)); [ apply poly_degree_lth | split; assumption | | ].
    destruct d; destruct d0; split.
      intros; apply degree_le_minus; [ apply d0 | apply d ]; assumption.
    intro; rewrite (s1 H1), (s2 H1); rational.
  assert (r1[=]q1[*]g[+]r1[-]q1[*]g); [ rational | ].
  rewrite H1, <- s0; rational.
split; [ assumption | ].
rewrite H1 in s0; apply (cg_cancel_lft _ _ _ _ s0).
Qed.
End poly_eucl.