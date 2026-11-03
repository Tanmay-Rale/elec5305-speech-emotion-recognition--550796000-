function M = computeMetrics2(yTrue,yPred,classNames)
%COMPUTEMETRICS2 Robust multiclass Accuracy, Macro-F1, and UAR.
classes=string(classNames(:));
yt=string(yTrue(:)); yp=string(yPred(:));
if numel(yt)~=numel(yp), error('True/predicted label counts differ.'); end
K=numel(classes); C=zeros(K,K);
for i=1:numel(yt)
    r=find(classes==yt(i),1); c=find(classes==yp(i),1);
    if isempty(r), error('Unknown true label: %s',yt(i)); end
    if isempty(c), error('Unknown predicted label: %s',yp(i)); end
    C(r,c)=C(r,c)+1;
end
P=zeros(K,1); R=zeros(K,1); F=zeros(K,1); support=sum(C,2);
for k=1:K
    tp=C(k,k); fp=sum(C(:,k))-tp; fn=sum(C(k,:))-tp;
    if tp+fp>0, P(k)=tp/(tp+fp); end
    if tp+fn>0, R(k)=tp/(tp+fn); end
    if P(k)+R(k)>0, F(k)=2*P(k)*R(k)/(P(k)+R(k)); end
end
M.Accuracy=sum(diag(C))/max(sum(C,'all'),1);
M.MacroF1=mean(F);
M.UAR=mean(R);
M.Confusion=C;
M.PerClass=table(classes,P,R,F,support, ...
    'VariableNames',{'Emotion','Precision','Recall','F1','Support'});
end
