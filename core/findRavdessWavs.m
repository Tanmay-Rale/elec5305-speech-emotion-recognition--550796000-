function D = findRavdessWavs(rootFolder)
%FINDRAVDESSWAVS Return valid official audio-only speech RAVDESS WAV files.
D=struct('name',{},'folder',{},'date',{},'bytes',{},'isdir',{},'datenum',{});
if ~isfolder(rootFolder), return; end
allD=dir(fullfile(rootFolder,'**','*.wav'));
keep=false(numel(allD),1);
for k=1:numel(allD)
    [~,name,ext]=fileparts(allD(k).name);
    if ~strcmpi(ext,'.wav'), continue; end
    p=split(string(name),'-');
    if numel(p)~=7, continue; end
    c=str2double(p);
    if any(~isfinite(c)), continue; end
    valid = c(1)==3 && c(2)==1 && ...
        c(3)>=1 && c(3)<=8 && c(4)>=1 && c(4)<=2 && ...
        c(5)>=1 && c(5)<=2 && c(6)>=1 && c(6)<=2 && ...
        c(7)>=1 && c(7)<=24;
    if c(3)==1 && c(4)~=1, valid=false; end
    keep(k)=valid;
end
D=allD(keep);
end
