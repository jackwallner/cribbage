# Cribbage content audit

This audit records the domain conversion from the source training app.

## Verified model

- Standard 52-card deck with four suits and ranks ace through king.
- Cribbage values are ace as 1, number cards at face value, and face cards at
  10.
- Hand categories include fifteens, pairs, runs, flushes, his nobs, pegging,
  crib, counting, and endgame.
- Authored hand-match questions show five distinct cards.
- Authored discard scenarios show six distinct cards and recommend two cards
  from that deal.
- No authored scenario uses a joker.

## Verified product split

The unit tests cover unique IDs, valid choice indices, free room access, plus
sets, Master Tables locking, Quick Session filtering, and generated hand
ambiguity. The public App Store ID is intentionally unset until the Cribbage
record exists.

## Remaining release checks

- Confirm house-rule wording with the rules source used for the release.
- Capture every room on `agent-cribbage` at the final Dynamic Type sizes.
- Add the final App Store ID to `AppStoreLinks` before shipping a write-review
  URL.

