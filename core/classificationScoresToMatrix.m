function M = classificationScoresToMatrix(scores,numClasses)
%CLASSIFICATIONSCORESTOMATRIX Normalize classify() score output to N-by-K.
if isnumeric(scores)
    M=double(scores);
    if isvector(M) && numClasses>1, M=reshape(M,1,[]); end
elseif iscell(scores)
    M=zeros(numel(scores),numClasses);
    for i=1:numel(scores)
        s=double(scores{i}); s=s(:)';
        if numel(s)~=numClasses
            error('Unexpected classification score shape in cell %d.',i);
        end
        M(i,:)=s;
    end
else
    error('Unsupported classification score type: %s',class(scores));
end
if size(M,2)~=numClasses && size(M,1)==numClasses
    M=M';
end
if size(M,2)~=numClasses
    error('Expected %d score columns, got %d.',numClasses,size(M,2));
end
end
