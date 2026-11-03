function nrm = fitFrameNormalizer(sequences)
if isempty(sequences), error('No training sequences supplied.'); end
A=cat(2,sequences{:});
if isempty(A), error('Training sequences contain no frames.'); end
nrm.Mean=mean(A,2,'omitnan');
nrm.Std=std(A,0,2,'omitnan');
nrm.Mean(~isfinite(nrm.Mean))=0;
nrm.Std(~isfinite(nrm.Std)|nrm.Std<1e-8)=1;
end
