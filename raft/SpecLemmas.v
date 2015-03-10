Require Import List.
Import ListNotations.

Require Import VerdiTactics.
Require Import Util.
Require Import Net.

Require Import Raft.
Require Import CommonTheorems.

Section SpecLemmas.

  Context {orig_base_params : BaseParams}.
  Context {one_node_params : OneNodeParams orig_base_params}.
  Context {raft_params : RaftParams orig_base_params}.


  Theorem handleAppendEntries_log :
    forall h st t n pli plt es ci st' ps,
      handleAppendEntries h st t n pli plt es ci = (st', ps) ->
      log st' = log st \/
      log st' = es \/
      (exists e,
         In e (log st) /\
         eIndex e = pli /\
         eTerm e = plt) /\
      log st' = es ++ (removeAfterIndex (log st) pli).
  Proof.
    intros. unfold handleAppendEntries in *.
    break_if; [find_inversion; subst; eauto|].
    break_if; [do_bool; break_if; find_inversion; subst; eauto|].
    break_if.
    - break_match; [|find_inversion; subst; eauto].
      break_if; [find_inversion; subst; eauto|].
      find_inversion; subst; simpl in *.
      right. right.
      find_apply_lem_hyp findAtIndex_elim. intuition.
      do_bool. eauto.
    - repeat break_match; find_inversion; subst; eauto.
  Qed.

  Theorem handleClientRequest_log :
    forall h st client id c out st' ps,
      handleClientRequest h st client id c = (out, st', ps) ->
      ps = [] /\
      (log st' = log st \/
       exists e,
         log st' = e :: log st /\
         eIndex e = S (maxIndex (log st)) /\
         eTerm e = currentTerm st /\
         eClient e = client /\
         eInput e = c /\
         eId e = id).
  Proof.
    intros. unfold handleClientRequest in *.
    break_match; find_inversion; subst; intuition.
    simpl in *. eauto 10.
  Qed.
End SpecLemmas.
