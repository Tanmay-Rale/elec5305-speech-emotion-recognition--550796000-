function meta = getFrameFeatureMetadata(afe)
idx=info(afe); fields=fieldnames(idx); n=afe.FeatureVectorLength;
names=strings(1,n); fam=strings(1,n);

for i=1:numel(fields)
    f=fields{i}; cols=idx.(f);
    for j=1:numel(cols)
        c=cols(j);
        if numel(cols)==1, names(c)=string(f);
        else, names(c)=sprintf('%s_%02d',f,j); end
        fam(c)=familyOf(f);
    end
end
meta=table((1:n)',names',fam','VariableNames',{'Column','Name','Family'});
end

function s=familyOf(f)
f=lower(string(f));
if contains(f,"mfcc")||contains(f,"gtcc"), s="cepstral";
elseif contains(f,"pitch")||contains(f,"harmonic"), s="prosody";
elseif contains(f,"energy"), s="energy";
else, s="spectral";
end
end
