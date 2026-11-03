function result = runNestedSpeakerSFS(cfg)
rng(cfg.RandomSeed);
cache=loadFeatureCache(cfg);
T=cache.Manifest; X=cache.XStatic;
Y=categorical(string(T.Emotion),cfg.Emotions);
actor=double(T.Actor);
trainMask=ismember(actor,cfg.TrainActors);
Xtr=X(trainMask,:); Ytr=Y(trainMask); Atr=actor(trainMask);

sd=std(Xtr,0,1,'omitnan');
usable=isfinite(sd)&sd>1e-10;
if ~any(usable), error('No usable static predictors remain after variance filtering.'); end
X0=Xtr(:,usable); origCols=find(usable);

fprintf('\n--- Nested speaker-aware MRMR + sequentialfs ---\n');
fprintf('Training actors only: %s\n',mat2str(cfg.TrainActors));
rank=fscmrmr(X0,Ytr);
nCand=min(cfg.MRMRMaxCandidates,numel(rank));
candidateOrig=origCols(rank(1:nCand));
Xcand=X0(:,rank(1:nCand));

nGroups=numel(unique(Atr));
kfold=min(cfg.SFSInnerFolds,nGroups);
if kfold<2, error('At least two actor groups are required for grouped SFS.'); end
cv=cvpartition(size(Xcand,1),KFold=kfold,GroupingVariables=Atr);
for k=1:cv.NumTestSets
    tr=training(cv,k); te=test(cv,k);
    if ~isempty(intersect(unique(Atr(tr)),unique(Atr(te))))
        error('Actor leakage detected in SFS fold %d.',k);
    end
end

opts=statset('Display','iter','UseParallel','off');
nSelect=min(cfg.SFSNFeatures,size(Xcand,2));
[tf,history]=sequentialfs(@sfsCriterionSVM,Xcand,Ytr, ...
    'CV',cv,'Direction','forward','NFeatures',nSelect,'Options',opts);
selectedOrig=candidateOrig(tf);
if isempty(selectedOrig), error('Sequential feature selection returned no predictors.'); end

result.SelectedColumns=selectedOrig;
result.SelectedNames=cache.StaticNames(selectedOrig);
result.SelectedFamilies=cache.StaticFamilies(selectedOrig);
result.MRMRShortlistColumns=candidateOrig;
result.History=history;
result.TrainingActors=cfg.TrainActors;
result.Protocol="MRMR shortlist + sequentialfs using actor-grouped inner CV";

outDir=fullfile(cfg.ResultRoot,'feature_selection');
if ~isfolder(outDir), mkdir(outDir); end
save(fullfile(outDir,'nested_sfs_result.mat'),'result');
Tsel=table((1:numel(selectedOrig))',selectedOrig(:), ...
    result.SelectedNames(:),result.SelectedFamilies(:), ...
    'VariableNames',{'Rank','StaticColumn','Feature','Family'});
writetable(Tsel,fullfile(outDir,'selected_features.csv'));
fprintf('\nSelected %d features:\n',height(Tsel)); disp(Tsel);
end
