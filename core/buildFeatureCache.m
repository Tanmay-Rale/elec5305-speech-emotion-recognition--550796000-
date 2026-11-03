function cache = buildFeatureCache(cfg)
%BUILDFEATURECACHE Extract shared frame and static features for all files.
if ~isfile(cfg.ManifestFile), prepareRavdessManifest(cfg); end
T=readtable(cfg.ManifestFile,TextType='string'); N=height(T);
if N==0, error('Manifest contains no files.'); end
X=[]; sequences=cell(N,1); staticNames=[]; staticFamilies=[];

fprintf('\n--- Building AFFECT-X 2.0 feature cache ---\n');
for i=1:N
    if ~isfile(T.File(i)), error('Audio file missing: %s',T.File(i)); end
    [x,fs]=audioread(T.File(i));
    [F,meta]=extractFrameFeatures2(x,fs,cfg);
    [v,nm,fam]=summarizeStaticFeatures(F,meta);
    if isempty(X)
        X=zeros(N,numel(v)); staticNames=nm; staticFamilies=fam; frameMeta=meta;
    elseif numel(v)~=size(X,2)
        error('Feature-vector length changed at file %d.',i);
    end
    X(i,:)=v; sequences{i}=single(F');
    if mod(i,50)==0 || i==N, fprintf('Features %d/%d\n',i,N); end
end
cache=struct;
cache.Version=cfg.CacheVersion;
cache.Manifest=T; cache.XStatic=X; cache.StaticNames=staticNames;
cache.StaticFamilies=staticFamilies; cache.FrameMeta=frameMeta;
cache.Sequences=sequences; cache.TargetFs=cfg.TargetFs;
if ~isfolder(fileparts(cfg.CacheFile)), mkdir(fileparts(cfg.CacheFile)); end
save(cfg.CacheFile,'cache','-v7.3');
fprintf('Saved cache: %s\n',cfg.CacheFile);
fprintf('Static predictors: %d | Frame predictors: %d\n',size(X,2),height(frameMeta));
end
