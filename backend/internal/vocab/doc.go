// Package vocab validates extracted clinical entities against controlled
// vocabularies — RxNorm for medications (live), SNOMED for conditions
// and LOINC for labs (skeletons, Phase 2).
//
// Validators are deliberately small interfaces so swapping the bundled
// dev maps for live REST clients (RxNorm API, SNOMED browser, etc.) is
// a constructor change and nothing more.
package vocab
