# AFFECT-X 2.0 Validation Protocol

## Non-negotiable leakage rule
A final-test actor must not influence feature selection, normalisation, augmentation, early stopping, hyperparameter choice, or model training.

## Fixed speaker split
- Actors 1–16: training and nested feature selection
- Actors 17–18: validation
- Actors 19–24: frozen final test

## Speaker-aware feature selection
1. Remove near-zero-variance predictors using training actors only.
2. Rank with MRMR using training actors only.
3. Keep a limited shortlist to make wrapper selection computationally feasible.
4. Create inner folds using `cvpartition(...,GroupingVariables=Actor)`.
5. Explicitly verify that no actor occurs in both training and test observations of an inner fold.
6. Run `sequentialfs` with a custom SVM Macro-F1 criterion.

## Feature-family experiment
Feature-family comparisons use Actors 1–16 for fitting and Actors 17–18 for validation. This avoids consuming the final Actors 19–24 test set before the final models are frozen.

## Selected-feature SVM
After selection, the final SVM is fit on Actors 1–18 and evaluated once on Actors 19–24.

## BiLSTM
- frame normalisation is fit on Actors 1–16 only;
- Actors 17–18 are used for validation / early stopping;
- Actors 19–24 remain the final temporal test set.

## Intensity experiment
Neutral is excluded because RAVDESS neutral speech has no strong-intensity counterpart. Evaluate Normal→Normal, Strong→Strong, Normal→Strong and Strong→Normal on the pre-defined speaker split.

## Temporal-order ablation
The same final test trajectories are evaluated in original order and with within-utterance frame order randomly destroyed. The acoustic values are retained; only ordering is removed.

## LOSO
The LOSO module holds out each actor in turn and performs fold-local MRMR selection before training. This is a complementary actor-variability analysis; it does not reuse the fixed-test result as a tuning signal.

## Software QA
`selfTestAffectX2` is a fast no-dataset check. `runFullRuntimeValidation` is a separate end-to-end smoke test using a synthetic RAVDESS-shaped corpus and isolated output folders.

## Claims
AFFECT-X estimates observable expressed affect. It must not be described as a 100% detector of a person's hidden internal emotional state.
