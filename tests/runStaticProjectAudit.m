function report = runStaticProjectAudit(projectRoot)
%RUNSTATICPROJECTAUDIT Structural + MATLAB Code Analyzer audit.
%
% Run inside MATLAB R2026a for the authoritative Code Analyzer pass.

if nargin<1 || isempty(projectRoot)
    projectRoot=fileparts(fileparts(mfilename('fullpath')));
end

mfiles=dir(fullfile(projectRoot,'**','*.m'));
structFindings=cell(0,3);
analyzerFindings=cell(0,4);

for i=1:numel(mfiles)
    f=fullfile(mfiles(i).folder,mfiles(i).name);
    txt=fileread(f);
    [~,stem]=fileparts(f);
    lines=splitlines(string(txt));
    first="";

    for q=1:numel(lines)
        z=strtrim(lines(q));
        if startsWith(z,"function")
            first=z;
            break;
        end
    end

    if strlength(first)==0
        structFindings(end+1,:)={f,'STRUCT','No function declaration found'}; %#ok<AGROW>
    else
        % Supports all of these forms:
        %   function foo
        %   function foo(x)
        %   function y = foo(x)
        %   function [a,b] = foo(x)
        tok=regexp(char(first), ...
            '^function\s+(?:(?:\[[^\]]*\]|\w+)\s*=\s*)?(\w+)(?:\s*\(|\s*$)', ...
            'tokens','once');

        if isempty(tok)
            structFindings(end+1,:)={f,'STRUCT','Could not parse primary function declaration'}; %#ok<AGROW>
        else
            fn=tok{1};
            if ~strcmp(fn,stem)
                structFindings(end+1,:)={f,'STRUCT', ...
                    sprintf('Primary function %s does not match filename %s',fn,stem)}; %#ok<AGROW>
            end
        end
    end

    if exist('checkcode','file')~=0
        cc=checkcode(f,'-id','-fullpath');
        for j=1:numel(cc)
            analyzerFindings(end+1,:)={f,char(cc(j).id),cc(j).line,cc(j).message}; %#ok<AGROW>
        end
    end
end

required={ ...
    'README.md', ...
    'PROJECT_TITLE.txt', ...
    'docs/VALIDATION_PROTOCOL.md', ...
    'docs/MATHWORKS_REFERENCE.md', ...
    'docs/RESEARCH_QUESTION.md', ...
    'docs/ASSESSMENT_ALIGNMENT.md', ...
    'docs/REPORT_STRUCTURE_FINAL.md', ...
    'docs/VIDEO_DEMO_PLAN.md', ...
    'docs/GITHUB_SUBMISSION_CHECKLIST.md'};

for i=1:numel(required)
    if ~isfile(fullfile(projectRoot,required{i}))
        structFindings(end+1,:)={required{i},'DOC','Required documentation missing'}; %#ok<AGROW>
    end
end

report=struct;
report.NumMatlabFiles=numel(mfiles);
report.StructuralFindings=structFindings;
report.CodeAnalyzerFindings=analyzerFindings;
report.StructuralPass=isempty(structFindings);

fprintf('Static audit: %d MATLAB files | structural issues=%d | Code Analyzer messages=%d\n', ...
    numel(mfiles),size(structFindings,1),size(analyzerFindings,1));
end
