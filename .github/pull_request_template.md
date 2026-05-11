## Summary
<!-- 1-3 bullets describing the change -->

## Type
- [ ] Foundation / scaffolding
- [ ] Feature (Phase 0)
- [ ] Bug fix
- [ ] Refactor
- [ ] Contract change (requires updating `contract/` + both apps)

## Verification
- [ ] `make lint && make test` clean (backend)
- [ ] `flutter analyze && flutter test` clean (mobile)
- [ ] Eval set passes (extraction-worker changes only)
- [ ] PHI-handling audited (any change touching patient data)
- [ ] Contract conformance verified (any change touching wire shapes)

## Risk
<!-- What could break? How would we notice? -->

## Rollback
<!-- One sentence: how to undo this if it ships broken -->
