function outFile = exportSubmissionEvidence(cfg)
%EXPORTSUBMISSIONEVIDENCE Create a concise index of report-ready outputs.
%
% This does not invent results. It records which expected evidence files
% currently exist and extracts simple summary rows where possible.

if nargin<1 || isempty(cfg), cfg=defaultConfig; end

outDir = fullfile(cfg.ProjectRoot,'submission');
if ~isfolder(outDir), mkdir(outDir); end
outFile = fullfile(outDir,'SUBMISSION_EVIDENCE_SUMMARY.md');

items = {
    'Acoustic cue table', fullfile(cfg.ResultRoot,'acoustic_analysis','acoustic_cues.csv');
    'Feature-family baseline', fullfile(cfg.ResultRoot,'feature_families','feature_family_results.csv');
    'Selected features', fullfile(cfg.ResultRoot,'feature_selection','selected_features.csv');
    'Selected SVM per-class metrics', fullfile(cfg.ResultRoot,'svm','per_class_metrics.csv');
    'Selected SVM confusion matrix', fullfile(cfg.ResultRoot,'svm','confusion_matrix.csv');
    'BiLSTM per-class metrics', fullfile(cfg.ResultRoot,'bilstm','per_class_metrics.csv');
    'BiLSTM confusion matrix', fullfile(cfg.ResultRoot,'bilstm','confusion_matrix.csv');
    'Intensity generalisation', fullfile(cfg.ResultRoot,'intensity','intensity_generalisation.csv');
    'Temporal-order ablation', fullfile(cfg.ResultRoot,'temporal_ablation','temporal_order_ablation.csv');
    'LOSO actor metrics', fullfile(cfg.ResultRoot,'loso','actor_fold_metrics.csv');
    'LOSO pooled per-class metrics', fullfile(cfg.ResultRoot,'loso','pooled_per_class_metrics.csv');
    'LOSO pooled confusion matrix', fullfile(cfg.ResultRoot,'loso','pooled_confusion_matrix.csv')};

fid=fopen(outFile,'w');
if fid<0, error('Cannot create %s',outFile); end
c=onCleanup(@()fclose(fid)); %#ok<NASGU>

fprintf(fid,'# ELEC5305 Submission Evidence Summary\n\n');
fprintf(fid,'**Research question:** Which acoustic and temporal speech features provide the most reliable emotion recognition for previously unseen speakers, and how does emotional intensity affect that generalisation?\n\n');
fprintf(fid,'Generated: %s\n\n',datestr(now));
fprintf(fid,'## Evidence status\n\n');
fprintf(fid,'| Evidence | Status | File |\n|---|---|---|\n');

for k=1:size(items,1)
    label=items{k,1}; path=items{k,2};
    if isfile(path), status='READY'; else, status='MISSING'; end
    fprintf(fid,'| %s | %s | `%s` |\n',label,status,path);
end

fprintf(fid,'\n## Report mapping\n\n');
fprintf(fid,'- **Methods:** RAVDESS metadata, shared acoustic feature bank, grouped speaker validation, MRMR + sequential feature selection, SVM and BiLSTM.\n');
fprintf(fid,'- **Results:** feature-family baseline, selected-feature SVM, BiLSTM, intensity transfer, temporal-order ablation, LOSO.\n');
fprintf(fid,'- **Discussion:** which cues generalise, intensity mismatch, value of temporal order, actor variability, limitations.\n');
fprintf(fid,'- **Video:** dashboard record/load/analyse demo, Signal Lab plots, one result table, one limitation.\n');

fprintf('\nSubmission evidence summary written to:\n  %s\n',outFile);
end
