function Tcue = runAcousticCueAnalysis2(cfg)
if ~isfile(cfg.ManifestFile), prepareRavdessManifest(cfg); end
T=readtable(cfg.ManifestFile,TextType='string'); N=height(T);
PitchMedian=nan(N,1); PitchIQR=nan(N,1); PitchMADelta=nan(N,1);
RMS=nan(N,1); Duration=nan(N,1); SpectralCentroidMedian=nan(N,1);

fprintf('\n--- Acoustic cue analysis ---\n');
for i=1:N
    [x,fs]=audioread(T.File(i)); [x,fs]=preprocessAudio(x,fs,cfg);
    [f0,~]=safePitchTrack(x,fs); f0=f0(isfinite(f0));
    if ~isempty(f0)
        PitchMedian(i)=median(f0); PitchIQR(i)=iqr(f0);
        if numel(f0)>1, PitchMADelta(i)=mean(abs(diff(f0))); end
    end
    RMS(i)=sqrt(mean(x.^2)+eps); Duration(i)=numel(x)/fs;
    afe=audioFeatureExtractor(SampleRate=fs,Window=hann(round(.03*fs),'periodic'), ...
        OverlapLength=round(.02*fs),spectralCentroid=true);
    c=extract(afe,x); SpectralCentroidMedian(i)=median(c,'omitnan');
    if mod(i,100)==0 || i==N, fprintf('Cue table %d/%d\n',i,N); end
end
Tcue=T(:,{'File','Actor','Sex','Emotion','Intensity','Statement','Repetition','Split'});
Tcue.PitchMedian=PitchMedian; Tcue.PitchIQR=PitchIQR; Tcue.PitchMADelta=PitchMADelta;
Tcue.RMS=RMS; Tcue.Duration=Duration; Tcue.SpectralCentroidMedian=SpectralCentroidMedian;
outDir=fullfile(cfg.ResultRoot,'acoustic_analysis'); if ~isfolder(outDir), mkdir(outDir); end
writetable(Tcue,fullfile(outDir,'acoustic_cues.csv')); fprintf('Saved acoustic cue table.\n');
end
