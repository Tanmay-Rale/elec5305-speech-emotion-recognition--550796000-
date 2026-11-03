function R = runIntensityGeneralization2(cfg)
cache=loadFeatureCache(cfg);
selFile=fullfile(cfg.ResultRoot,'feature_selection','nested_sfs_result.mat');
if ~isfile(selFile), runNestedSpeakerSFS(cfg); end
S=load(selFile,'result');

X=cache.XStatic(:,S.result.SelectedColumns);
T=cache.Manifest; emotion=string(T.Emotion);
intensity=string(T.Intensity); actor=double(T.Actor);

nonNeutral=emotion~="neutral";
trainActors=ismember(actor,[cfg.TrainActors cfg.ValidationActors]);
testActors=ismember(actor,cfg.TestActors);
classes=cfg.Emotions(cfg.Emotions~="neutral");

conds=["normal","normal";"strong","strong";"normal","strong";"strong","normal"];
rows=cell(4,6);

fprintf('\n--- Emotional-intensity generalisation ---\n');

for c=1:4
    trI=conds(c,1); teI=conds(c,2);
    tr=nonNeutral&trainActors&intensity==trI;
    te=nonNeutral&testActors&intensity==teI;

    learner=templateSVM(KernelFunction="rbf",KernelScale="auto",Standardize=true);
    mdl=fitcecoc(X(tr,:),categorical(emotion(tr),classes), ...
        Learners=learner,Coding="onevsone");
    pred=predict(mdl,X(te,:));
    M=computeMetrics2(emotion(te),string(pred),classes);

    rows(c,:)={trI+"->"+teI,sum(tr),sum(te),M.Accuracy,M.MacroF1,M.UAR};
    fprintf('%s -> %s | Acc %.2f%% | F1 %.3f | UAR %.3f\n', ...
        trI,teI,100*M.Accuracy,M.MacroF1,M.UAR);
end

R=cell2table(rows,'VariableNames', ...
    {'Condition','TrainN','TestN','Accuracy','MacroF1','UAR'});

gap=mean(R.Accuracy(1:2))-mean(R.Accuracy(3:4));
fprintf('Intensity generalisation gap: %.2f percentage points\n',100*gap);

outDir=fullfile(cfg.ResultRoot,'intensity');
if ~isfolder(outDir), mkdir(outDir); end
writetable(R,fullfile(outDir,'intensity_generalisation.csv'));
end
