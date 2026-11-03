function bundle = trainSelectedSVM(cfg)
cache=loadFeatureCache(cfg);
selFile=fullfile(cfg.ResultRoot,'feature_selection','nested_sfs_result.mat');
if ~isfile(selFile), runNestedSpeakerSFS(cfg); end
S=load(selFile,'result'); cols=S.result.SelectedColumns;
T=cache.Manifest; X=cache.XStatic(:,cols); Y=string(T.Emotion); actor=double(T.Actor);
train=ismember(actor,[cfg.TrainActors cfg.ValidationActors]);
test=ismember(actor,cfg.TestActors);
if ~any(train)||~any(test), error('Configured train/test actor split is empty.'); end

learner=templateSVM(KernelFunction="rbf",KernelScale="auto",Standardize=true);
yTrain=categorical(Y(train),cfg.Emotions);
mdl=fitcecoc(X(train,:),yTrain,Learners=learner,Coding="onevsone", ...
    ClassNames=categorical(cfg.Emotions,cfg.Emotions));
[pred,~]=predict(mdl,X(test,:));
modelClasses=string(mdl.ClassNames(:))';
M=computeMetrics2(Y(test),string(pred),cfg.Emotions);

fprintf('\n--- Selected-feature SVM ---\n');
fprintf('Selected features: %d\n',numel(cols));
fprintf('Final unseen actors: %s\n',mat2str(cfg.TestActors));
fprintf('Accuracy %.2f%% | Macro F1 %.3f | UAR %.3f\n',100*M.Accuracy,M.MacroF1,M.UAR);
disp(M.PerClass);

bundle.Model=mdl;
bundle.SelectedColumns=cols;
bundle.SelectedNames=cache.StaticNames(cols);
bundle.SelectedFamilies=cache.StaticFamilies(cols);
bundle.ClassNames=modelClasses;
bundle.Metrics=M;
bundle.TestActors=cfg.TestActors;
bundle.ScoreType="ECOC negated average binary loss; dashboard softmax is display normalization, not calibrated probability";

if ~isfolder(cfg.ModelRoot), mkdir(cfg.ModelRoot); end
save(fullfile(cfg.ModelRoot,'affectx2_sfs_svm.mat'),'bundle','-v7.3');
outDir=fullfile(cfg.ResultRoot,'svm'); if ~isfolder(outDir), mkdir(outDir); end
writetable(M.PerClass,fullfile(outDir,'per_class_metrics.csv'));
writematrix(M.Confusion,fullfile(outDir,'confusion_matrix.csv'));
end
