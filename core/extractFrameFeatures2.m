function [F,meta,x,fs] = extractFrameFeatures2(x,fs,cfg)
[x,fs]=preprocessAudio(x,fs,cfg);
minLen=max(1,round(cfg.FrameDuration*fs));
if numel(x)<minLen, x(end+1:minLen)=0; end

afe=buildFeatureExtractor(cfg);
F=extract(afe,x);
if isempty(F), error('audioFeatureExtractor produced no frames.'); end
F(~isfinite(F))=NaN;
for c=1:size(F,2)
    v=F(:,c); m=median(v,'omitnan');
    if ~isfinite(m), m=0; end
    v(~isfinite(v))=m; F(:,c)=v;
end
meta=getFrameFeatureMetadata(afe);
if size(F,2)~=height(meta), error('Feature metadata length mismatch.'); end
end
