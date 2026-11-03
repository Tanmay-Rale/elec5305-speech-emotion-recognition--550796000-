# ELEC5305 Assessment Alignment

## Final research question

**Which acoustic and temporal speech features provide the most reliable emotion recognition for previously unseen speakers, and how does emotional intensity affect that generalisation?**

## Why this scope is appropriate

The course project guide emphasises one clear investigation, explicit evaluation metrics, an implementation, performance measurement, analysis of shortcomings, and at least one iteration or modification. This project therefore uses one dataset and one core problem, then compares a baseline with targeted modifications.

## Research story

1. **Baseline:** full acoustic feature bank and feature-family SVM comparisons.
2. **Modification 1:** MRMR + speaker-grouped sequential forward feature selection.
3. **Modification 2:** BiLSTM using the selected underlying frame trajectories.
4. **Experiment A:** emotional-intensity transfer (N→N, S→S, N→S, S→N).
5. **Experiment B:** temporal-order ablation.
6. **Final validation:** full leave-one-speaker-out analysis.

## Rubric mapping

| Rubric area | Project evidence |
|---|---|
| Originality / contribution | Speaker-grouped feature selection; intensity-transfer and temporal-order experiments |
| Command of subject | STFT, pitch, MFCC/GTCC, spectral cues, SVM/ECOC, BiLSTM, grouped validation |
| Introduction | Speaker dependence and intensity mismatch motivate the research question |
| Literature review | SER, acoustic prosody, feature selection, temporal modelling, speaker-independent evaluation |
| Methodology | Reproducible RAVDESS parsing, feature extraction, split protocol, SFS, SVM/BiLSTM |
| Results | Accuracy, Macro-F1, UAR, per-emotion recall, confusion matrices, LOSO variability |
| Discussion / conclusion | Generalisable cues, intensity gap, temporal-order contribution, limitations |
| Presentation / references | Report-ready figures/tables, working GitHub code, dashboard and video demo |

## Core claims only

- The system estimates **expressed emotion from speech acoustics**.
- The final research metric must come from unseen speakers.
- No 100% accuracy claim is permitted unless actually measured.
- Dashboard display scores are not automatically calibrated probabilities.
