function R = runFeatureFamilyExperiments2(cfg)
%RUNFEATUREFAMILYEXPERIMENTS2 Compare pre-defined families on validation speakers.
cache=loadFeatureCache(cfg);
T=cache.Manifest; X=cache.XStatic; Y=string(T.Emotion); actor=double(T.Actor);
train=ismember(actor,cfg.TrainActors); test=ismember(actor,cfg.ValidationActors);
sets=["all","prosody","energy","spectral","cepstral"]; rows=cell(numel(sets),5);

fprintf('\n--- Feature-family experiments (validation actors only) ---\n');
for i=1:numel(sets)
    s=sets(i);
    if s=="all", cols=true(1,size(X,2)); else, cols=cache.StaticFamilies==s; end
    if ~any(cols), error('No predictors available for family %s.',s); end
    idx=find(cols);
    sd=std(X(train,idx),0,1,'omitnan');
    idx=idx(isfinite(sd)&sd>1e-10);
    if isempty(idx), error('All predictors in family %s are constant on training speakers.',s); end

    learner=templateSVM(KernelFunction="rbf",KernelScale="auto",Standardize=true);
    mdl=fitcecoc(X(train,idx),categorical(Y(train),cfg.Emotions),Learners=learner,Coding="onevsone");
    pred=predict(mdl,X(test,idx));
    M=computeMetrics2(Y(test),string(pred),cfg.Emotions);
    rows(i,:)={s,numel(idx),M.Accuracy,M.MacroF1,M.UAR};
    fprintf('%-10s | %4d | Acc %.2f%% | F1 %.3f | UAR %.3f\n',s,numel(idx),100*M.Accuracy,M.MacroF1,M.UAR);
end
R=cell2table(rows,'VariableNames',{'FeatureSet','NumFeatures','Accuracy','MacroF1','UAR'});
outDir=fullfile(cfg.ResultRoot,'feature_families'); if ~isfolder(outDir), mkdir(outDir); end
writetable(R,fullfile(outDir,'feature_family_results.csv'));
end
