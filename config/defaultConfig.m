function cfg = defaultConfig
%DEFAULTCONFIG Central configuration for AFFECT-X 2.0.
root = fileparts(fileparts(mfilename('fullpath')));

cfg.ProjectRoot = root;
cfg.DataRoot = fullfile(root,'data');
cfg.RawRoot = fullfile(cfg.DataRoot,'raw');

pointerFile = fullfile(cfg.DataRoot,'ravdess_root.txt');
defaultRavdess = fullfile(cfg.RawRoot,'RAVDESS_SPEECH');
if isfile(pointerFile)
    saved = strtrim(fileread(pointerFile));
    if ~isempty(saved)
        cfg.RavdessRoot = saved;
    else
        cfg.RavdessRoot = defaultRavdess;
    end
else
    cfg.RavdessRoot = defaultRavdess;
end

cfg.RavdessPointerFile = pointerFile;
cfg.ExpectedRavdessSpeechFiles = 1440;
cfg.ManifestFile = fullfile(cfg.DataRoot,'ravdess_speech_manifest.csv');
cfg.CacheFile = fullfile(cfg.DataRoot,'feature_cache.mat');
cfg.ModelRoot = fullfile(root,'models');
cfg.ResultRoot = fullfile(root,'results');

cfg.TargetFs = 16000;
cfg.FrameDuration = 0.030;
cfg.HopDuration = 0.010;
cfg.Emotions = ["neutral","calm","happy","sad","angry","fearful","disgust","surprised"];

cfg.TrainActors = 1:16;
cfg.ValidationActors = 17:18;
cfg.TestActors = 19:24;

cfg.MRMRMaxCandidates = 30;
cfg.SFSNFeatures = 15;
cfg.SFSInnerFolds = 4;

cfg.SequenceLength = 20;
cfg.SequenceOverlap = 10;
cfg.BiLSTMUnits = 160;
cfg.BiLSTMMaxEpochs = 8;
cfg.BiLSTMMiniBatch = 128;

cfg.CacheVersion = "AFFECTX2-QA-1.1";
cfg.RandomSeed = 5305;
cfg.RecordSeconds = 4;
end
