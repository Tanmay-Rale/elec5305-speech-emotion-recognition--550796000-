function report = checkEnvironment2(cfg)
%CHECKENVIRONMENT2 Verify products, APIs, and dataset readiness.
fprintf('\n--- AFFECT-X 2.0 environment check ---\n');
fprintf('MATLAB: %s\nProject: %s\n\n',version,cfg.ProjectRoot);

needed={'Audio Toolbox','Signal Processing Toolbox', ...
    'Statistics and Machine Learning Toolbox','Deep Learning Toolbox'};
v=ver; names=string({v.Name});
productOK=false(size(needed));
for k=1:numel(needed)
    productOK(k)=any(names==needed{k});
    fprintf('%-42s : %s\n',needed{k},yn(productOK(k)));
end

funcs={'audioFeatureExtractor','pitch','fitcecoc','fscmrmr', ...
    'sequentialfs','cvpartition','bilstmLayer','trainNetwork','checkcode'};
funcOK=false(size(funcs));
fprintf('\n');
for k=1:numel(funcs)
    funcOK(k)=exist(funcs{k},'file')~=0 || exist(funcs{k},'class')~=0;
    fprintf('%-42s : %s\n',funcs{k},yn(funcOK(k)));
end

D=findRavdessWavs(cfg.RavdessRoot);
fprintf('\nRAVDESS root:\n  %s\n',cfg.RavdessRoot);
fprintf('Valid speech WAV files: %d\n',numel(D));
if numel(D)==cfg.ExpectedRavdessSpeechFiles
    datasetStatus='READY (complete 1440-file speech set)';
elseif isempty(D)
    datasetStatus='NOT READY - run configureRavdessRoot';
else
    datasetStatus=sprintf('PARTIAL (%d files)',numel(D));
end
fprintf('Dataset: %s\n',datasetStatus);

report=struct('ProductsOK',all(productOK),'FunctionsOK',all(funcOK), ...
    'NumRavdessFiles',numel(D),'DatasetStatus',datasetStatus);
end
function s=yn(tf)
if tf, s='OK'; else, s='MISSING'; end
end
