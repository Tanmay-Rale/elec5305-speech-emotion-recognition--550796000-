function [v,names,families] = summarizeStaticFeatures(F,meta)
stats=["mean","std","median","q25","q75"];
v=zeros(1,size(F,2)*numel(stats));
names=strings(size(v)); families=strings(size(v)); k=0;

for c=1:size(F,2)
    x=F(:,c);
    vals=[mean(x,'omitnan'),std(x,'omitnan'),median(x,'omitnan'), ...
        prctile(x,25),prctile(x,75)];
    for s=1:numel(stats)
        k=k+1;
        v(k)=vals(s);
        names(k)=meta.Name(c)+"_"+stats(s);
        families(k)=meta.Family(c);
    end
end
v(~isfinite(v))=0;
end
