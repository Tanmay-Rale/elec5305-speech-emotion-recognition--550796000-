function startup_affectx2
%STARTUP_AFFECTX2 Add final ELEC5305 project folders to MATLAB path.
root = fileparts(mfilename('fullpath'));
addpath(root);
for f = ["config","core","training","ui","tests","submission"]
    p = fullfile(root,f);
    if isfolder(p), addpath(genpath(p)); end
end
fprintf('\nELEC5305 Speaker-Independent SER project paths added from:\n  %s\n\n',root);
end
