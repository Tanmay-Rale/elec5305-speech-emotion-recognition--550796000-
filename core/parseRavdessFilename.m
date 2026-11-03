function row = parseRavdessFilename(filePath)
%PARSERAVDESSFILENAME Decode and validate official RAVDESS filename metadata.
[~,name,ext]=fileparts(filePath);
if ~strcmpi(ext,'.wav'), error('Not a WAV file: %s',filePath); end
p=split(string(name),'-');
if numel(p)~=7, error('Invalid RAVDESS filename: %s',name); end
c=str2double(p);
if any(~isfinite(c)), error('Invalid numeric RAVDESS codes: %s',name); end

if ~ismember(c(1),1:3) || ~ismember(c(2),1:2) || ~ismember(c(3),1:8) || ...
        ~ismember(c(4),1:2) || ~ismember(c(5),1:2) || ...
        ~ismember(c(6),1:2) || ~ismember(c(7),1:24)
    error('RAVDESS code out of range: %s',name);
end
if c(3)==1 && c(4)~=1
    error('Neutral RAVDESS speech must use normal intensity: %s',name);
end

emap=["neutral","calm","happy","sad","angry","fearful","disgust","surprised"];
intensity="normal"; if c(4)==2, intensity="strong"; end
sex="female"; if mod(c(7),2)==1, sex="male"; end

row=table(string(filePath),c(7),sex,emap(c(3)),intensity,c(5),c(6),c(1),c(2), ...
    'VariableNames',{'File','Actor','Sex','Emotion','Intensity','Statement', ...
    'Repetition','Modality','VocalChannel'});
end
