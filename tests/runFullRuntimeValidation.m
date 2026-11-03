function report = runFullRuntimeValidation
%RUNFULLRUNTIMEVALIDATION End-to-end smoke test of every AFFECT-X module.
% Uses an isolated synthetic 24-speaker RAVDESS-shaped corpus.

projectRoot=fileparts(fileparts(mfilename('fullpath')));
startup_affectx2;
baseCfg=defaultConfig;
sandbox=fullfile(projectRoot,'validation_sandbox');
if isfolder(sandbox), rmdir(sandbox,'s'); end
mkdir(sandbox);

cfg=baseCfg;
cfg.DataRoot=fullfile(sandbox,'data');
cfg.RawRoot=fullfile(cfg.DataRoot,'raw');
cfg.RavdessRoot=fullfile(cfg.RawRoot,'RAVDESS_SPEECH');
cfg.ManifestFile=fullfile(cfg.DataRoot,'ravdess_speech_manifest.csv');
cfg.CacheFile=fullfile(cfg.DataRoot,'feature_cache.mat');
cfg.ModelRoot=fullfile(sandbox,'models');
cfg.ResultRoot=fullfile(sandbox,'results');
cfg.ExpectedRavdessSpeechFiles=360;
cfg.MRMRMaxCandidates=4;
cfg.SFSNFeatures=2;
cfg.SFSInnerFolds=2;
cfg.SequenceLength=8;
cfg.SequenceOverlap=4;
cfg.BiLSTMUnits=8;
cfg.BiLSTMMaxEpochs=1;
cfg.BiLSTMMiniBatch=64;
requireProjectDirs(cfg);

logFile=fullfile(sandbox,'FULL_RUNTIME_VALIDATION_REPORT.txt');
diary(logFile); cleanupDiary=onCleanup(@()diary('off')); %#ok<NASGU>
fprintf('AFFECT-X 2.0 FULL RUNTIME VALIDATION\nMATLAB: %s\nStarted: %s\n',version,string(datetime('now')));

steps=cell(0,1); pass=false(0,1); detail=cell(0,1);
runStep('Environment API check',@()checkEnvironment2(cfg));
runStep('Synthetic RAVDESS generation',@()generateMockRavdessDataset(cfg.RavdessRoot,cfg.TargetFs,0.70));
runStep('RAVDESS manifest',@()prepareRavdessManifest(cfg));
runStep('Feature cache',@()buildFeatureCache(cfg));
runStep('Acoustic cue analysis',@()runAcousticCueAnalysis2(cfg));
runStep('Nested speaker SFS',@()runNestedSpeakerSFS(cfg));
runStep('Feature-family experiments',@()runFeatureFamilyExperiments2(cfg));
runStep('Selected-feature SVM',@()trainSelectedSVM(cfg));
runStep('Selected-feature BiLSTM',@()trainSelectedBiLSTM(cfg));
runStep('Intensity generalisation',@()runIntensityGeneralization2(cfg));
runStep('Temporal-order ablation',@()runTemporalOrderAblation2(cfg));
runStep('24-fold LOSO SVM',@()runFullLOSOSVM2(cfg));
runStep('Quick self-test',@()selfTestAffectX2(cfg));
runStep('Dashboard construction',@testDashboard);
runStep('Signal Laboratory construction',@testSignalLab);

try
    staticReport=runStaticProjectAudit(projectRoot);
catch ME
    staticReport=struct('Pass',false,'Findings',{{getReport(ME,'extended','hyperlinks','off')}});
end

report=table(string(steps),pass,string(detail),'VariableNames',{'Step','Pass','Detail'});
writetable(report,fullfile(sandbox,'runtime_validation_steps.csv'));
save(fullfile(sandbox,'runtime_validation_report.mat'),'report','staticReport','cfg');

fprintf('\n============================================================\n');
fprintf('RUNTIME RESULT: %d/%d STEPS PASSED\n',sum(pass),numel(pass));
if all(pass)
    fprintf('PASS: every runtime smoke-test module completed successfully.\n');
else
    fprintf(2,'FAIL: %d runtime step(s) failed.\n',sum(~pass));
end
fprintf('Report folder:\n  %s\n',sandbox);

    function runStep(name,fun)
        fprintf('\n===== %s =====\n',name);
        try
            fun();
            steps{end+1,1}=name; pass(end+1,1)=true; detail{end+1,1}='PASS';
            fprintf('PASS: %s\n',name);
        catch ME
            steps{end+1,1}=name; pass(end+1,1)=false;
            detail{end+1,1}=getReport(ME,'extended','hyperlinks','off');
            fprintf(2,'FAIL: %s\n%s\n',name,detail{end});
        end
    end
    function testDashboard
        f=affectx2_dashboard(cfg); drawnow; close(f);
    end
    function testSignalLab
        fs=cfg.TargetFs; t=(0:fs-1)'/fs; x=.1*sin(2*pi*180*t);
        f=signal_lab2(x,fs,cfg); drawnow; close(f);
    end
end
