function [seqOut,labelOut,fileIndex] = windowSequences(sequences,labels,L,overlap)
step=L-overlap;
if step<=0, error('Overlap must be smaller than sequence length.'); end

seqOut={}; labelOut=strings(0,1); fileIndex=zeros(0,1);

for i=1:numel(sequences)
    X=sequences{i};
    T=size(X,2);

    if T<L
        if T==0, continue; end
        X(:,end+1:L)=repmat(X(:,end),1,L-T);
        T=L;
    end

    starts=1:step:(T-L+1);
    if isempty(starts), starts=1; end

    for s=starts
        seqOut{end+1,1}=X(:,s:s+L-1); %#ok<AGROW>
        labelOut(end+1,1)=string(labels(i)); %#ok<AGROW>
        fileIndex(end+1,1)=i; %#ok<AGROW>
    end
end
end
