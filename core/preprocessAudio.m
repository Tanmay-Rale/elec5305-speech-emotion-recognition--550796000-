function [x,fs] = preprocessAudio(x,fs,cfg)
%PREPROCESSAUDIO Deterministic preprocessing shared by all branches.
if isempty(x), error('Audio input is empty.'); end
if ~isscalar(fs) || ~isfinite(fs) || fs<=0, error('Invalid sample rate.'); end
x=double(x);
if size(x,2)>1, x=mean(x,2); end
x=x(:); x(~isfinite(x))=0;
if all(x==0), error('Audio contains no nonzero samples.'); end
x=x-mean(x,'omitnan');
if fs~=cfg.TargetFs
    x=resample(x,cfg.TargetFs,fs);
    fs=cfg.TargetFs;
end
pk=max(abs(x));
if pk>1, x=x/pk; end
end
