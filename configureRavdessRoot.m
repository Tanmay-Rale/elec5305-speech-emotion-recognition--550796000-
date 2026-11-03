function ravdessRoot = configureRavdessRoot(startFolder)
%CONFIGURERAVDESSROOT Select and persist the real RAVDESS speech root.
if nargin<1 || isempty(startFolder)
    startFolder = fullfile(getenv('USERPROFILE'),'Downloads');
    if ~isfolder(startFolder), startFolder=pwd; end
end
projectRoot=fileparts(mfilename('fullpath'));
dataRoot=fullfile(projectRoot,'data');
if ~isfolder(dataRoot), mkdir(dataRoot); end

selected=uigetdir(startFolder,'Select folder containing RAVDESS Actor_01 ... Actor_24');
if isequal(selected,0), error('RAVDESS folder selection cancelled.'); end

D=findRavdessWavs(selected);
if isempty(D)
    error('No valid audio-only RAVDESS speech WAV files were found below: %s',selected);
end

parents=strings(numel(D),1);
for k=1:numel(D)
    [parent,last]=fileparts(D(k).folder);
    if startsWith(string(last),'Actor_',IgnoreCase=true)
        parents(k)=string(parent);
    else
        parents(k)=string(selected);
    end
end
u=unique(parents);
if numel(u)==1 && isfolder(u(1)), ravdessRoot=char(u(1)); else, ravdessRoot=selected; end

D=findRavdessWavs(ravdessRoot);
fprintf('\nRAVDESS root:\n  %s\n',ravdessRoot);
fprintf('Valid audio-only speech WAV files: %d\n',numel(D));
if numel(D)==1440
    fprintf('PASS: complete 1440-file RAVDESS speech set detected.\n');
else
    fprintf('WARNING: expected 1440 files for the complete speech set.\n');
end

pointer=fullfile(dataRoot,'ravdess_root.txt');
fid=fopen(pointer,'w');
if fid<0, error('Cannot write %s',pointer); end
cleaner=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s',ravdessRoot);
fprintf('Saved dataset pointer: %s\n',pointer);
end
