# Final Report Structure (target: about 10 pages including figures)

## 1. Introduction
- Speech emotion recognition problem.
- Why speaker-independent generalisation matters.
- Why intensity and temporal structure may change performance.
- State the single research question.

## 2. Literature Review
Organise by themes rather than paper-by-paper summaries:
1. acoustic cues for emotion;
2. feature selection and interpretable SER;
3. speaker-independent validation;
4. temporal modelling / recurrent networks;
5. emotional intensity and domain mismatch.

End with the project gap: existing workflows can classify emotion, but this project asks which cues survive unseen speakers, how intensity affects transfer, and whether temporal order adds information.

## 3. Methodology
- RAVDESS and metadata.
- 8 emotion classes.
- Train/validation/test actor split.
- Acoustic feature bank.
- Static utterance summaries.
- Baseline SVM and feature families.
- MRMR + actor-grouped sequential feature selection.
- Selected-feature SVM.
- Selected-frame BiLSTM.
- Intensity experiment.
- Temporal-order ablation.
- LOSO evaluation.
- Metrics: Accuracy, Macro-F1, UAR, per-emotion recall, confusion matrices.

## 4. Results
Recommended evidence order:
1. Acoustic cue distributions / examples.
2. Feature-family baseline table.
3. Selected-feature table.
4. Full vs selected SVM comparison.
5. BiLSTM comparison.
6. Intensity generalisation table/figure.
7. Temporal-order ablation.
8. 24-fold LOSO actor distribution and pooled confusion matrix.

## 5. Discussion
Focus on interpretation, not repetition:
- Which feature families were most useful?
- Did feature selection help or mainly reduce dimensionality?
- Did BiLSTM improve performance?
- How large was the intensity mismatch penalty?
- How much did temporal shuffling hurt?
- Which emotions and actors were hardest?
- What does this imply about speaker dependence?
- Limitations: acted corpus, 24 speakers, RAVDESS recording conditions, no cross-corpus claim.

## 6. Conclusion and Future Work
Answer the research question directly in 3–5 concise findings. Future work can mention cross-corpus evaluation, personal neutral anchors, calibrated uncertainty, or multimodal/semantic evidence, but these are not required for the core submission.

## References
Use peer-reviewed SER / acoustic speech references plus RAVDESS and the MathWorks implementation reference as a technical source.
