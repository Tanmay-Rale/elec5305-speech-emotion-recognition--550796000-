function result = runTemporalOrderAblation2(cfg)
modelFile=fullfile(cfg.ModelRoot,'affectx2_selected_bilstm.mat');
if ~isfile(modelFile), trainSelectedBiLSTM(cfg); end
S=load(modelFile,'bundle'); B=S.bundle;
cache=loadFeatureCache(cfg); T=cache.Manifest; actor=double(T.Actor);
testFiles=ismember(actor,cfg.TestActors); Yfile=string(T.Emotion(testFiles));
seqRaw=cache.Sequences(testFiles);
seqRaw=cellfun(@(x)x(B.FrameKeepMask,:),seqRaw,'UniformOutput',false);
seq=cellfun(@(x)applyFrameNormalizer(x,B.Normalizer),seqRaw,'UniformOutput',false);

[X1,~,idx1]=windowSequences(seq,Yfile,B.SequenceLength,B.SequenceOverlap);
[~,raw1]=classify(B.Network,X1,'MiniBatchSize',cfg.BiLSTMMiniBatch);
s1=classificationScoresToMatrix(raw1,numel(cfg.Emotions));
p1=aggregate(s1,idx1,numel(Yfile),cfg.Emotions); M1=computeMetrics2(Yfile,p1,cfg.Emotions);

rng(cfg.RandomSeed); seqSh=seq;
for i=1:numel(seqSh), seqSh{i}=seqSh{i}(:,randperm(size(seqSh{i},2))); end
[X2,~,idx2]=windowSequences(seqSh,Yfile,B.SequenceLength,B.SequenceOverlap);
[~,raw2]=classify(B.Network,X2,'MiniBatchSize',cfg.BiLSTMMiniBatch);
s2=classificationScoresToMatrix(raw2,numel(cfg.Emotions));
p2=aggregate(s2,idx2,numel(Yfile),cfg.Emotions); M2=computeMetrics2(Yfile,p2,cfg.Emotions);

result=table(["ordered";"shuffled"],[M1.Accuracy;M2.Accuracy], ...
    [M1.MacroF1;M2.MacroF1],[M1.UAR;M2.UAR], ...
    'VariableNames',{'Condition','Accuracy','MacroF1','UAR'});
disp(result);
fprintf('Accuracy drop after destroying temporal order: %.2f percentage points\n',100*(M1.Accuracy-M2.Accuracy));
outDir=fullfile(cfg.ResultRoot,'temporal_ablation'); if ~isfolder(outDir), mkdir(outDir); end
writetable(result,fullfile(outDir,'temporal_order_ablation.csv'));
end
function pred=aggregate(score,fileIdx,nFiles,classes)
S=zeros(nFiles,numel(classes));
for f=1:nFiles
    m=fileIdx==f; if ~any(m), error('No windows for file %d.',f); end
    S(f,:)=mean(score(m,:),1);
end
[~,ix]=max(S,[],2); pred=classes(ix)';
end
