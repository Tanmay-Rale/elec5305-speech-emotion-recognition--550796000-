function bundle = trainSelectedBiLSTM(cfg)
rng(cfg.RandomSeed);
cache=loadFeatureCache(cfg);
selFile=fullfile(cfg.ResultRoot,'feature_selection','nested_sfs_result.mat');
if ~isfile(selFile), runNestedSpeakerSFS(cfg); end
S=load(selFile,'result');
selectedStatic=string(S.result.SelectedNames);
frameNames=string(cache.FrameMeta.Name);
keep=false(1,numel(frameNames));
for j=1:numel(frameNames), keep(j)=any(startsWith(selectedStatic,frameNames(j)+"_")); end
if sum(keep)<4
    fam=string(cache.FrameMeta.Family); keep=ismember(fam,["cepstral","prosody"]);
end
if ~any(keep), error('No frame predictors available for BiLSTM.'); end

T=cache.Manifest; actor=double(T.Actor); Yfile=string(T.Emotion);
trainFiles=ismember(actor,cfg.TrainActors); valFiles=ismember(actor,cfg.ValidationActors); testFiles=ismember(actor,cfg.TestActors);
seqRaw=cellfun(@(x)x(keep,:),cache.Sequences,'UniformOutput',false);
nrm=fitFrameNormalizer(seqRaw(trainFiles));
seq=cellfun(@(x)applyFrameNormalizer(x,nrm),seqRaw,'UniformOutput',false);
[XTrain,YTrain]=windowSequences(seq(trainFiles),Yfile(trainFiles),cfg.SequenceLength,cfg.SequenceOverlap);
[XVal,YVal]=windowSequences(seq(valFiles),Yfile(valFiles),cfg.SequenceLength,cfg.SequenceOverlap);
[XTest,~,fileIdxTest]=windowSequences(seq(testFiles),Yfile(testFiles),cfg.SequenceLength,cfg.SequenceOverlap);
if isempty(XTrain)||isempty(XVal)||isempty(XTest), error('BiLSTM window generation produced an empty split.'); end
YTrain=categorical(YTrain,cfg.Emotions); YVal=categorical(YVal,cfg.Emotions);

layers=[sequenceInputLayer(sum(keep)); dropoutLayer(.25); ...
    bilstmLayer(cfg.BiLSTMUnits,OutputMode="last"); dropoutLayer(.50); ...
    fullyConnectedLayer(numel(cfg.Emotions)); softmaxLayer; classificationLayer];
opts=trainingOptions('adam','MaxEpochs',cfg.BiLSTMMaxEpochs, ...
    'MiniBatchSize',cfg.BiLSTMMiniBatch,'InitialLearnRate',1e-3, ...
    'Shuffle','every-epoch','ValidationData',{XVal,YVal}, ...
    'ValidationPatience',2,'Verbose',true,'Plots','none');

fprintf('\n--- Training selected-feature BiLSTM ---\n');
fprintf('Frame predictors: %d/%d\n',sum(keep),numel(keep));
fprintf('Windows train=%d validation=%d test=%d\n',numel(XTrain),numel(XVal),numel(XTest));
net=trainNetwork(XTrain,YTrain,layers,opts);
[~,rawScores]=classify(net,XTest,'MiniBatchSize',cfg.BiLSTMMiniBatch);
scoreWindow=classificationScoresToMatrix(rawScores,numel(cfg.Emotions));

trueFile=Yfile(testFiles); scoresFile=zeros(numel(trueFile),numel(cfg.Emotions));
for f=1:numel(trueFile)
    m=fileIdxTest==f;
    if ~any(m), error('No BiLSTM windows found for test file %d.',f); end
    scoresFile(f,:)=mean(scoreWindow(m,:),1);
end
[~,mx]=max(scoresFile,[],2); predFile=cfg.Emotions(mx)';
M=computeMetrics2(trueFile,predFile,cfg.Emotions);
fprintf('BiLSTM Accuracy %.2f%% | Macro F1 %.3f | UAR %.3f\n',100*M.Accuracy,M.MacroF1,M.UAR);

bundle.Network=net; bundle.FrameKeepMask=keep; bundle.FrameNames=frameNames(keep);
bundle.Normalizer=nrm; bundle.ClassNames=cfg.Emotions; bundle.Metrics=M;
bundle.SequenceLength=cfg.SequenceLength; bundle.SequenceOverlap=cfg.SequenceOverlap;
if ~isfolder(cfg.ModelRoot), mkdir(cfg.ModelRoot); end
save(fullfile(cfg.ModelRoot,'affectx2_selected_bilstm.mat'),'bundle','-v7.3');
outDir=fullfile(cfg.ResultRoot,'bilstm'); if ~isfolder(outDir), mkdir(outDir); end
writetable(M.PerClass,fullfile(outDir,'per_class_metrics.csv'));
writematrix(M.Confusion,fullfile(outDir,'confusion_matrix.csv'));
end
