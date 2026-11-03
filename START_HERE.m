function START_HERE
%START_HERE Final ELEC5305 project menu.
%
% Research story:
%   setup -> baseline/acoustic analysis -> feature selection -> models ->
%   intensity/temporal experiments -> final speaker-independent validation ->
%   demonstration -> software QA -> submission evidence.

while true
    cfg = defaultConfig;
    requireProjectDirs(cfg);

    fprintf('\n=====================================================================\n');
    fprintf(' ELEC5305 FINAL PROJECT\n');
    fprintf(' Speaker-Independent Speech Emotion Recognition\n');
    fprintf(' Acoustic Cues | Emotional Intensity | Temporal Structure\n');
    fprintf('=====================================================================\n');
    fprintf(' SETUP AND DATA\n');
    fprintf(' 1  Environment and dataset check\n');
    fprintf(' 2  Prepare / verify RAVDESS metadata manifest\n');
    fprintf(' 3  Build shared acoustic feature cache\n');
    fprintf('\n BASELINE AND ACOUSTIC ANALYSIS\n');
    fprintf(' 4  Acoustic cue analysis\n');
    fprintf(' 5  Full-feature / feature-family SVM baseline\n');
    fprintf('\n PROJECT MODIFICATION / FEATURE SELECTION\n');
    fprintf(' 6  Nested speaker-aware MRMR + sequential feature selection\n');
    fprintf(' 7  Final selected-feature SVM evaluation\n');
    fprintf(' 8  Selected-feature BiLSTM temporal model\n');
    fprintf('\n RESEARCH EXPERIMENTS\n');
    fprintf(' 9  Emotional-intensity generalisation\n');
    fprintf('10  Temporal-order ablation\n');
    fprintf('11  Full 24-fold leave-one-speaker-out SVM\n');
    fprintf('\n DEMONSTRATION\n');
    fprintf('12  Open final dashboard\n');
    fprintf('13  Open Signal Laboratory\n');
    fprintf('\n SOFTWARE QA / SUBMISSION\n');
    fprintf('14  Quick self-test\n');
    fprintf('15  Full synthetic runtime validation\n');
    fprintf('16  Export submission evidence summary\n');
    fprintf(' 0  Exit\n\n');

    raw = strtrim(input('Select option: ','s'));
    option = str2double(raw);

    if isnan(option) || option ~= fix(option)
        fprintf(2,'Invalid input. Enter only a whole number from 0 to 16.\n');
        continue;
    end

    try
        switch option
            case 1
                checkEnvironment2(cfg);
                verifyDatasetSummary(cfg);
            case 2
                prepareRavdessManifest(cfg);
            case 3
                buildFeatureCache(cfg);
            case 4
                runAcousticCueAnalysis2(cfg);
            case 5
                runFeatureFamilyExperiments2(cfg);
            case 6
                runNestedSpeakerSFS(cfg);
            case 7
                trainSelectedSVM(cfg);
            case 8
                trainSelectedBiLSTM(cfg);
            case 9
                runIntensityGeneralization2(cfg);
            case 10
                runTemporalOrderAblation2(cfg);
            case 11
                runFullLOSOSVM2(cfg);
            case 12
                affectx2_dashboard(cfg);
            case 13
                signal_lab2([],[],cfg);
            case 14
                selfTestAffectX2(cfg);
            case 15
                runFullRuntimeValidation;
            case 16
                exportSubmissionEvidence(cfg);
            case 0
                fprintf('ELEC5305 project menu closed.\n');
                return;
            otherwise
                fprintf(2,'Unknown option. Enter 0 to 16.\n');
        end
    catch ME
        fprintf(2,'\nELEC5305 PROJECT ERROR: %s\n',ME.message);
        if ~isempty(ME.stack)
            fprintf(2,'Location: %s (line %d)\n',ME.stack(1).name,ME.stack(1).line);
        end
        fprintf('See README.md and docs/VALIDATION_PROTOCOL.md.\n');
    end
end
end

function verifyDatasetSummary(cfg)
fprintf('\n--- Dataset summary ---\n');
files = findRavdessWavs(cfg.RavdessRoot);
fprintf('Configured RAVDESS root:\n  %s\n',cfg.RavdessRoot);
fprintf('Valid RAVDESS speech WAV files detected: %d\n',numel(files));
if numel(files)==1440
    fprintf('Dataset status: COMPLETE OFFICIAL AUDIO-ONLY SPEECH SET\n');
elseif isempty(files)
    fprintf('Dataset status: NOT FOUND / EMPTY\n');
    fprintf('Run configureRavdessRoot to select the dataset folder.\n');
else
    fprintf('Dataset status: PARTIAL OR CUSTOM SUBSET\n');
end
end
