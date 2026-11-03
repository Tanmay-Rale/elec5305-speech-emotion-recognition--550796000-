function R = runFullLOSOSVM2(cfg)
%RUNFULLLOSOSVM2 Actor LOSO with fold-local variance filtering and MRMR.
rng(cfg.RandomSeed);
cache=loadFeatureCache(cfg); T=cache.Manifest; X=cache.XStatic;
Y=string(T.Emotion); actor=double(T.Actor); actors=unique(actor);
if numel(actors)<2, error('LOSO requires at least two actors.'); end
rows=cell(numel(actors),4); allTrue=strings(0,1); allPred=strings(0,1);

fprintf('\n--- Full actor LOSO SVM ---\n');
for i=1:numel(actors)
    held=actors(i); tr=actor~=held; te=actor==held;
    sd=std(X(tr,:),0,1,'omitnan'); usable=isfinite(sd)&sd>1e-10;
    if ~any(usable), error('No usable predictors in LOSO fold actor %02d.',held); end
    X0=X(tr,usable); orig=find(usable);
    rank=fscmrmr(X0,categorical(Y(tr),cfg.Emotions));
    cols=orig(rank(1:min(cfg.SFSNFeatures,numel(rank))));

    learner=templateSVM(KernelFunction="rbf",KernelScale="auto",Standardize=true);
    mdl=fitcecoc(X(tr,cols),categorical(Y(tr),cfg.Emotions),Learners=learner,Coding="onevsone");
    pred=predict(mdl,X(te,cols));
    M=computeMetrics2(Y(te),string(pred),cfg.Emotions);
    rows(i,:)={held,M.Accuracy,M.MacroF1,M.UAR};
    allTrue=[allTrue;Y(te)]; %#ok<AGROW>
    allPred=[allPred;string(pred)]; %#ok<AGROW>
    fprintf('Actor %02d | Acc %.2f%% | F1 %.3f | UAR %.3f\n',held,100*M.Accuracy,M.MacroF1,M.UAR);
end
P=computeMetrics2(allTrue,allPred,cfg.Emotions);
R=cell2table(rows,'VariableNames',{'Actor','Accuracy','MacroF1','UAR'});
fprintf('\nPooled Accuracy %.2f%% | Macro F1 %.3f | UAR %.3f\n',100*P.Accuracy,P.MacroF1,P.UAR);
fprintf('Actor accuracy SD: %.2f percentage points\n',100*std(R.Accuracy));
outDir=fullfile(cfg.ResultRoot,'loso'); if ~isfolder(outDir), mkdir(outDir); end
writetable(R,fullfile(outDir,'actor_fold_metrics.csv'));
writetable(P.PerClass,fullfile(outDir,'pooled_per_class_metrics.csv'));
writematrix(P.Confusion,fullfile(outDir,'pooled_confusion_matrix.csv'));
end
