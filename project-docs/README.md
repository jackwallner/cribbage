# Project documentation

Developer notes and historical audits for this repository. The published site remains in the docs directory.

## Audits

- [aso827.md](audits/aso827.md): Cribbage Trainer ASO Audit
- [audit823.md](audits/audit823.md): Cribbity / Cribbage Trainer audit
- [ios27CribbageTrainer.md](audits/ios27CribbageTrainer.md): iOS 27 compatibility audit: Cribbage Trainer
- [mahj-parity-audit-2026-10.md](audits/mahj-parity-audit-2026-10.md): Practice-loop feature audit against the Mahj reference, with fixes
- [state-machines-2026-11-06.md](audits/state-machines-2026-11-06.md): State machine audit: reminders, streak time zones and flashcard undo bugs, with repro tests (state-machines-2026-11-06-repro.swift)
- [state-machines-2026-11-06-review.md](audits/state-machines-2026-11-06-review.md): Independent review of the state machine audit: 1 confirmed (streak loss on westward travel, upgraded), 1 minor (flashcard Undo), 2 unverified reminder claims
- [state-machines-2026-11-06-fixes.md](audits/state-machines-2026-11-06-fixes.md): Fixes for the state machine audit: 4 fixed (streak and Get Started across time zones, flashcard Undo, reminder times after a zone change, reminders scheduled at launch), with test runs
- [state-machines-2026-11-06-verify.md](audits/state-machines-2026-11-06-verify.md): Independent verification of the state machine fixes: PASS, all 4 fixes work, 214 tests pass, the top three fail without their fix
- [presubmit-review-2026-11-07.md](audits/presubmit-review-2026-11-07.md): Pre-submit review of 1.3.3 against live 1.3.2: no P0 or P1, 3 P2 (one covered by a new test), unit run queued and not finished
