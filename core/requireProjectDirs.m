function requireProjectDirs(cfg)
%REQUIREPROJECTDIRS Create output folders only; never fake an input dataset.
folders = {cfg.DataRoot,cfg.RawRoot,cfg.ModelRoot,cfg.ResultRoot};
for k=1:numel(folders)
    if ~isfolder(folders{k}), mkdir(folders{k}); end
end
end
