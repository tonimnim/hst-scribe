# Extraction Eval Set

Sample utterances and the events the extractor must produce. Use this to iterate the prompt and as a regression test.

**Convention:** past tense / completed-action utterances produce events. Imperative / future-tense utterances do NOT (those are intents, not facts).

| # | Utterance | Expected events |
|---|---|---|
| 1 | "BP one thirty over eighty two" | `vital_sign{systolic=130}`, `vital_sign{diastolic=82}` |
| 2 | "Heart rate seventy two, sats ninety eight on room air" | `vital_sign{hr=72}`, `vital_sign{spo2=98}` |
| 3 | "Just gave her 4 of Zofran IV" | `medication_administered{ondansetron, 4mg, iv}` |
| 4 | "Give her 4 of Zofran IV" | none (imperative — intent, not action) |
| 5 | "Pain is a 2 out of 10" | `vital_sign{pain_score=2}` |
| 6 | "She's reporting some nausea, gave her 4 of Zofran" | `medication_administered{ondansetron, 4mg, indication=nausea}` |
| 7 | "Temp is ninety eight point six" | `vital_sign{temperature_f=98.6}` |
| 8 | "Resps sixteen, regular" | `vital_sign{respiratory_rate=16}` |
| 9 | "Ready for discharge, criteria met, tolerating fluids" | `dispo{discharge_home, criteria_met=true, notes=...}` |
| 10 | "Gave 2 of morphine IV for pain" | `medication_administered{morphine, 2mg, iv, indication=pain}` |
| 11 | "Strike that, it was 4 of morphine not 2" | (handled as correction at app level — voice_command flow) |
| 12 | "BP cycling now, hold on" | none (status comment, not a chart event) |
| 13 | "Patient denies chest pain, no shortness of breath" | `note{text=..., tags=['cardiac','respiratory']}` |
| 14 | "Saturation dropped to 91, putting her on 2 liters nasal" | `vital_sign{spo2=91}`, `medication_administered{oxygen, 2L, inhaled}` |
| 15 | "She's allergic to penicillin" | none in PACU flow (allergy already in patient_context; flag only if it's NEW) |
| 16 | "Last dose of fentanyl was at fourteen ten, 25 micrograms IV" | `medication_administered{fentanyl, 25mcg, iv, event_time=14:10}` |
| 17 | "Pain dropped from 8 to 3 after the morphine" | `vital_sign{pain_score=3}` |
| 18 | "Family is here, talking with them now" | none |
| 19 | "Transferring to room 4 for observation overnight" | `dispo{admit_observation, notes=...}` |
| 20 | "Hold the next dose of Zofran for now" | none (imperative) |
| 21 | "BP 132 over 84, HR 70, sats 99, pain 1" | `vital_sign × 5` |
| 22 | "Gave another 2 of Zofran, that's 6 total today" | `medication_administered{ondansetron, 2mg}` (the "6 total" is reconciliation, not a new event) |
| 23 | "She's not allergic to anything we've given" | none |
| 24 | "Discharge home with husband, follow-up Tuesday with Dr. Patel" | `dispo{discharge_home, notes=...}` |
| 25 | "Pain went from a four to a two" | `vital_sign{pain_score=2}` |

## Edge cases the extractor must handle

- **Tense disambiguation.** "Gave" / "just gave" / "administered" → event. "Give" / "going to give" / "let's give" → no event.
- **Self-correction.** "Strike that" or "I meant" → handled by voice command path, not by extraction.
- **Reconciliation phrases.** "That's 6 total today" — don't double-count; emit only the action verb, not the running total.
- **Numbers as words.** "one thirty" → 130. "ninety eight point six" → 98.6.
- **Compound vitals.** "BP 132 over 84" → two events (systolic, diastolic).
- **Indication phrases.** "for nausea" / "for pain" / "for breakthrough pain" → `indication` field.
- **Already-known facts.** Allergies / current meds already in `patient_context` → not new events.
- **RxNorm resolution.** Generic and brand names both map. "Zofran" → ondansetron, rxnorm 26225. If unmappable, confidence ≤ 0.5 and event flagged.

## How to use this file

1. New extraction prompt iteration: run all utterances through the extractor, diff against expected events, log delta.
2. Regression: any prompt or model change must not reduce coverage below the prior baseline.
3. Production additions: when nurses reject events in real sessions, the rejected utterance + expected behavior gets added here.
