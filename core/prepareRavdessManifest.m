function T = prepareRavdessManifest(cfg)
%PREPARERAVDESSMANIFEST Build validated audio-only speech RAVDESS metadata.
D=findRavdessWavs(cfg.RavdessRoot);
if isempty(D)
    fprintf('\nNo valid RAVDESS speech WAVs found at:\n  %s\n',cfg.RavdessRoot);
    if usejava('desktop')
        newRoot=configureRavdessRoot;
        cfg.RavdessRoot=newRoot;
        D=findRavdessWavs(cfg.RavdessRoot);
    end
end
if isempty(D)
    error('RAVDESS dataset unavailable. Run configureRavdessRoot first.');
end

R=cell(numel(D),1);
for k=1:numel(D)
    f=fullfile(D(k).folder,D(k).name);
    R{k}=parseRavdessFilename(f);
end
T=vertcat(R{:});

% findRavdessWavs already guarantees modality 03 / vocal channel 01.
T.Split=strings(height(T),1);
T.Split(ismember(T.Actor,cfg.TrainActors))="train";
T.Split(ismember(T.Actor,cfg.ValidationActors))="validation";
T.Split(ismember(T.Actor,cfg.TestActors))="test";

T.Emotion=categorical(T.Emotion,cfg.Emotions);
T.Intensity=categorical(T.Intensity,["normal","strong"]);
T.Sex=categorical(T.Sex,["female","male"]);
T.Split=categorical(T.Split,["train","validation","test"]);
T=sortrows(T,{'Actor','Emotion','Intensity','Statement','Repetition'});

if ~isfolder(fileparts(cfg.ManifestFile)), mkdir(fileparts(cfg.ManifestFile)); end
writetable(T,cfg.ManifestFile);

fprintf('\n--- RAVDESS manifest ---\n');
fprintf('Files: %d | Actors: %d\n',height(T),numel(unique(T.Actor)));
if height(T)~=cfg.ExpectedRavdessSpeechFiles
    fprintf('WARNING: complete official speech set contains %d files.\n',cfg.ExpectedRavdessSpeechFiles);
end
disp(groupsummary(T,'Emotion'));
disp(groupsummary(T,'Intensity'));
disp(groupsummary(T,'Split'));
fprintf('Saved: %s\n',cfg.ManifestFile);
end
