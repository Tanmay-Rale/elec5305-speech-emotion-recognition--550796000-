# ELEC5305 Submission Evidence Summary

**Research question:** Which acoustic and temporal speech features provide the most reliable emotion recognition for previously unseen speakers, and how does emotional intensity affect that generalisation?

Generated: 03-Nov-2026 19:20:03

## Evidence status

| Evidence | Status | File |
|---|---|---|
| Acoustic cue table | READY | `C:\Users\007ta\Downloads\ELEC5305_SpeakerIndependent_SER_FINAL\results\acoustic_analysis\acoustic_cues.csv` |
| Feature-family baseline | READY | `C:\Users\007ta\Downloads\ELEC5305_SpeakerIndependent_SER_FINAL\results\feature_families\feature_family_results.csv` |
| Selected features | READY | `C:\Users\007ta\Downloads\ELEC5305_SpeakerIndependent_SER_FINAL\results\feature_selection\selected_features.csv` |
| Selected SVM per-class metrics | READY | `C:\Users\007ta\Downloads\ELEC5305_SpeakerIndependent_SER_FINAL\results\svm\per_class_metrics.csv` |
| Selected SVM confusion matrix | READY | `C:\Users\007ta\Downloads\ELEC5305_SpeakerIndependent_SER_FINAL\results\svm\confusion_matrix.csv` |
| BiLSTM per-class metrics | READY | `C:\Users\007ta\Downloads\ELEC5305_SpeakerIndependent_SER_FINAL\results\bilstm\per_class_metrics.csv` |
| BiLSTM confusion matrix | READY | `C:\Users\007ta\Downloads\ELEC5305_SpeakerIndependent_SER_FINAL\results\bilstm\confusion_matrix.csv` |
| Intensity generalisation | READY | `C:\Users\007ta\Downloads\ELEC5305_SpeakerIndependent_SER_FINAL\results\intensity\intensity_generalisation.csv` |
| Temporal-order ablation | READY | `C:\Users\007ta\Downloads\ELEC5305_SpeakerIndependent_SER_FINAL\results\temporal_ablation\temporal_order_ablation.csv` |
| LOSO actor metrics | READY | `C:\Users\007ta\Downloads\ELEC5305_SpeakerIndependent_SER_FINAL\results\loso\actor_fold_metrics.csv` |
| LOSO pooled per-class metrics | READY | `C:\Users\007ta\Downloads\ELEC5305_SpeakerIndependent_SER_FINAL\results\loso\pooled_per_class_metrics.csv` |
| LOSO pooled confusion matrix | READY | `C:\Users\007ta\Downloads\ELEC5305_SpeakerIndependent_SER_FINAL\results\loso\pooled_confusion_matrix.csv` |

## Report mapping

- **Methods:** RAVDESS metadata, shared acoustic feature bank, grouped speaker validation, MRMR + sequential feature selection, SVM and BiLSTM.
- **Results:** feature-family baseline, selected-feature SVM, BiLSTM, intensity transfer, temporal-order ablation, LOSO.
- **Discussion:** which cues generalise, intensity mismatch, value of temporal order, actor variability, limitations.
- **Video:** dashboard record/load/analyse demo, Signal Lab plots, one result table, one limitation.
