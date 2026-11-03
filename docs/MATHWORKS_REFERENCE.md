# MathWorks API / Implementation Reference

Primary example:
https://www.mathworks.com/help/deeplearning/ug/sequential-feature-selection-for-speech-emotion-recognition.html

AFFECT-X adopts or verifies these MATLAB mechanisms:
- `audioFeatureExtractor` for shared acoustic feature extraction;
- `info(audioFeatureExtractor)` and `FeatureVectorLength` for feature-column mapping;
- `fscmrmr` for filter ranking;
- `sequentialfs` with a custom criterion;
- `cvpartition(...,GroupingVariables=Actor)` for actor-grouped inner cross-validation (available in R2025a+);
- SVM/ECOC using `fitcecoc`;
- `trainNetwork` / BiLSTM sequence classification for the R2026a-compatible temporal branch.

AFFECT-X extends the MathWorks example by retaining RAVDESS metadata, explicitly testing emotional-intensity transfer, preserving a frozen speaker test set, adding temporal-order ablation, and producing actor-level LOSO results.

Important: the SVM dashboard uses the second output of `ClassificationECOC/predict`, which is the class-wise **negated average binary loss**. A softmax transformation is used only for a readable normalized display score. It is not labeled as a calibrated posterior probability.
