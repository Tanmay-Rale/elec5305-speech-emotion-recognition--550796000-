function loss = sfsCriterionSVM(XTrain,yTrain,XTest,yTest)
if size(XTrain,2)==0, loss=numel(yTest); return; end
learner=templateSVM(KernelFunction="rbf",KernelScale="auto",Standardize=true);
mdl=fitcecoc(XTrain,yTrain,Learners=learner,Coding="onevsone");
pred=predict(mdl,XTest);
if iscategorical(yTrain), classes=string(categories(yTrain));
else, classes=unique([string(yTrain);string(yTest)],'stable'); end
M=computeMetrics2(string(yTest),string(pred),classes);
loss=(1-M.MacroF1)*numel(yTest);
end
