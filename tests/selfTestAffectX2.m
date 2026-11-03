function selfTestAffectX2(cfg)
%SELFTESTAFFECTX2 Fast no-dataset software smoke test.
fprintf('\n--- AFFECT-X 2.0 quick self-test ---\n');
fs=cfg.TargetFs; t=(0:fs*1.5-1)'/fs;
x=.1*sin(2*pi*180*t)+.02*sin(2*pi*360*t)+.002*randn(size(t));
[F,meta]=extractFrameFeatures2(x,fs,cfg);
[v,names,fam]=summarizeStaticFeatures(F,meta);
assert(size(F,1)>0,'No frames produced.');
assert(size(F,2)==height(meta),'Frame metadata mismatch.');
assert(numel(v)==numel(names)&&numel(v)==numel(fam),'Static feature metadata mismatch.');
assert(all(isfinite(v)),'Static vector contains non-finite values.');
[f0,tp]=safePitchTrack(x,fs); %#ok<ASGLU>
assert(numel(f0)==numel(tp),'Pitch time vector mismatch.');

% Metrics sanity check.
M=computeMetrics2(["neutral";"happy"],["neutral";"happy"],["neutral","happy"]);
assert(abs(M.Accuracy-1)<eps && abs(M.MacroF1-1)<eps,'Metric calculation failed perfect-classification test.');

% Grouped CV leakage test.
actor=repelem((1:6)',4);
cv=cvpartition(numel(actor),KFold=3,GroupingVariables=actor);
for k=1:cv.NumTestSets
    tr=training(cv,k); te=test(cv,k);
    assert(isempty(intersect(unique(actor(tr)),unique(actor(te)))),'Grouped CV leaked actors.');
end

% RAVDESS parser sanity check.
r=parseRavdessFilename(fullfile(tempdir,'03-01-05-02-02-01-24.wav'));
assert(r.Actor==24 && string(r.Emotion)=="angry" && string(r.Intensity)=="strong",'RAVDESS parser sanity test failed.');

fprintf('PASS: frame extraction (%d x %d)\n',size(F,1),size(F,2));
fprintf('PASS: static summarisation (%d predictors)\n',numel(v));
fprintf('PASS: pitch helper\n');
fprintf('PASS: metrics\n');
fprintf('PASS: grouped actor CV\n');
fprintf('PASS: RAVDESS parser\n');
fprintf('Quick self-test complete.\n');
end
