# MATLAB API Verification Notes

The QA-repaired build was checked against current MathWorks documentation for the APIs that are most likely to create version-specific failures.

Verified interfaces:

- `audioFeatureExtractor` supports MFCC/GTCC deltas and delta-deltas, pitch, harmonic ratio, zero-crossing rate, short-time energy and the configured spectral descriptors.
- `info(audioFeatureExtractor)` exposes feature output-column mappings and `FeatureVectorLength`.
- `cvpartition(n,KFold=k,GroupingVariables=group)` is supported from R2025a onward and therefore is available in the user's R2026a environment.
- `sequentialfs` accepts a `cvpartition` object through `CV`, supports `NFeatures`, and calls a criterion with `(XTrain,yTrain,XTest,yTest)`; an averaged loss must be multiplied by the number of test observations.
- `ClassificationECOC/predict` returns negated average binary loss as its second output. AFFECT-X therefore does not label its softmax-normalized ECOC display scores as calibrated probabilities.
- `trainNetwork` / `classify` remain supported in R2026a although the newer `trainnet` / `dlnetwork` workflow is recommended by MathWorks. AFFECT-X normalizes numeric or cell score output defensively before utterance aggregation.
- `checkcode` can return Code Analyzer findings as a structure and is used by the project audit harness.

Primary MathWorks references are linked in `MATHWORKS_REFERENCE.md`.
