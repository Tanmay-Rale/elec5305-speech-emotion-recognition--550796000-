function cache = loadFeatureCache(cfg)
%LOADFEATURECACHE Load compatible cache or rebuild it.
rebuild=~isfile(cfg.CacheFile);
if ~rebuild
    try
        S=load(cfg.CacheFile,'cache'); cache=S.cache;
        rebuild=~isfield(cache,'Version') || string(cache.Version)~=string(cfg.CacheVersion) || ...
            ~isfield(cache,'TargetFs') || cache.TargetFs~=cfg.TargetFs;
    catch
        rebuild=true;
    end
end
if rebuild
    fprintf('Feature cache missing or incompatible; rebuilding.\n');
    cache=buildFeatureCache(cfg);
else
    cache=S.cache;
end
end
