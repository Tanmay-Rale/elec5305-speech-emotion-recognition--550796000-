function mockRoot = generateMockRavdessDataset(mockRoot,fs,durationSeconds)
%GENERATEMOCKRAVDESSDATASET Create a small 24-actor RAVDESS-shaped test corpus.
% This is only for software validation, never for research results.
if nargin<2 || isempty(fs), fs=16000; end
if nargin<3 || isempty(durationSeconds), durationSeconds=0.70; end
if isfolder(mockRoot), rmdir(mockRoot,'s'); end
mkdir(mockRoot);
rng(5305);
t=(0:round(durationSeconds*fs)-1)'/fs;
for actor=1:24
    actorDir=fullfile(mockRoot,sprintf('Actor_%02d',actor));
    mkdir(actorDir);
    for emotion=1:8
        intensities=1;
        if emotion~=1, intensities=[1 2]; end
        for intensity=intensities
            statement=1; repetition=1;
            name=sprintf('03-01-%02d-%02d-%02d-%02d-%02d.wav', ...
                emotion,intensity,statement,repetition,actor);
            baseF=95 + 22*emotion + 1.5*actor;
            amp=0.08 + 0.04*(intensity-1) + 0.004*emotion;
            env=min(1,t/0.04).*min(1,(durationSeconds-t)/0.06);
            env=max(env,0);
            x=amp*env.*(sin(2*pi*baseF*t) + 0.35*sin(2*pi*2*baseF*t));
            x=x + 0.003*randn(size(x));
            audiowrite(fullfile(actorDir,name),x,fs);
        end
    end
end
D=findRavdessWavs(mockRoot);
if numel(D)~=360
    error('Mock dataset generation failed: expected 360 files, found %d.',numel(D));
end
fprintf('Mock RAVDESS-shaped corpus generated: %d files\n',numel(D));
end
