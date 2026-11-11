# ELEC5305 Final Project

## Speaker-Independent Speech Emotion Recognition: Acoustic Cues, Emotional Intensity and Temporal Structure

**MATLAB implementation using RAVDESS acoustic features, speaker-aware sequential feature selection, SVM and BiLSTM networks.**

## Single research question

**Which acoustic and temporal speech features provide the most reliable emotion recognition for previously unseen speakers, and how does emotional intensity affect that generalisation?**

## Project strategy

This project deliberately stays focused on one research problem. It begins with an interpretable acoustic/SVM baseline, introduces speaker-aware feature selection as a modification, then tests whether a temporal BiLSTM and emotional-intensity experiments improve understanding of speaker-independent SER.

### Core experiments

1. RAVDESS metadata and acoustic cue analysis.
2. Full-feature and feature-family SVM baseline.
3. MRMR + actor-grouped sequential feature selection.
4. Final selected-feature SVM.
5. Selected-frame BiLSTM temporal model.
6. Intensity transfer: Normal→Normal, Strong→Strong, Normal→Strong, Strong→Normal.
7. Temporal-order ablation.
8. Full 24-fold leave-one-speaker-out analysis.

## MATLAB requirements

Designed for MATLAB R2026a with:
- Audio Toolbox
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox
- Deep Learning Toolbox

## RAVDESS setup

Either place the official audio-only speech corpus under:

```text
data/raw/RAVDESS_SPEECH/Actor_01 ... Actor_24
```

or run:

```matlab
configureRavdessRoot
```

The complete official audio-only speech set contains 1440 WAV files.

## Start

```matlab
cd('C:\path\to\ELEC5305_SpeakerIndependent_SER_FINAL')
clear functions
rehash
startup_affectx2
START_HERE
```

## Recommended research order

```text
1  Environment and dataset check
2  Prepare / verify RAVDESS manifest
3  Build feature cache
4  Acoustic cue analysis
5  Full-feature / feature-family SVM baseline
6  Nested speaker-aware feature selection
7  Final selected-feature SVM
8  Selected-feature BiLSTM
9  Intensity generalisation
10 Temporal-order ablation
11 Full 24-fold LOSO
12 Dashboard
13 Signal Laboratory
16 Export submission evidence summary
```

Options 14–15 are software QA tools and are not research results.

## Validation protocol

Primary fixed split:
- Actors 1–16: training and feature selection
- Actors 17–18: validation / early stopping / baseline comparison
- Actors 19–24: frozen final unseen-speaker test

Sequential feature selection uses actor-grouped cross-validation, so recordings from one actor are never split between inner training and validation folds.

## Evaluation metrics

Primary:
- Macro-F1
- UAR / mean per-class recall

Secondary:
- Accuracy
- per-emotion precision/recall/F1
- confusion matrices
- actor-to-actor LOSO variation

Research-specific:
- intensity generalisation gap
- temporal-order performance drop
- number and families of selected features

## Demonstration

The responsive dashboard shows:
- waveform
- spectrogram/STFT
- F0 trajectory
- normalized ECOC score distribution
- detected expressed emotion
- selected-feature count
- top ranked classes
- signal quality summary

The Signal Laboratory provides the technical signal-processing view.

## Important claim boundary

The system estimates **observable expressed affect from speech**. It does not guarantee knowledge of a person's private internal emotional state. ECOC dashboard scores are display-normalized model scores, not automatically calibrated probabilities.

## Submission support

See:
- `docs/ASSESSMENT_ALIGNMENT.md`
- `docs/REPORT_STRUCTURE_FINAL.md`
- `docs/VIDEO_DEMO_PLAN.md`
- `docs/GITHUB_SUBMISSION_CHECKLIST.md`
- `docs/VALIDATION_PROTOCOL.md`

## MathWorks technical reference

The implementation is informed by the MathWorks Speech Emotion Recognition / Sequential Feature Selection example, but the project contribution is the speaker-grouped feature-selection and evaluation design plus the intensity and temporal experiments.
project video link- https://www.youtube.com/watch?v=c8oInQ8WRNg
