function [f0,t] = safePitchTrack(x,fs)
%SAFEPITCHTRACK Robust pitch trajectory with invalid estimates removed.
try
    f0=pitch(x,fs,Range=[50 500]);
catch
    f0=pitch(x,fs);
end
f0=double(f0(:));
f0(~isfinite(f0) | f0<50 | f0>500)=NaN;
if numel(f0)>=5
    f0=movmedian(f0,5,'omitnan');
end
if isempty(f0), t=zeros(0,1); else, t=linspace(0,numel(x)/fs,numel(f0))'; end
end
