function fig = affectx2_dashboard(cfg)
%AFFECTX2_DASHBOARD Responsive AFFECT-X 2.0 dashboard.
%
% Drop-in replacement for:
%   <project>\ui\affectx2_dashboard.m
%
% Layout goals:
%   - no clipped button text
%   - responsive nested uigridlayout containers
%   - readable UIAxes titles/ticks
%   - centered Result Engine
%   - tables with stable column widths
%   - clean research-design panel
%
% MATLAB target: R2026a

if nargin < 1 || isempty(cfg)
    cfg = defaultConfig;
end

% -------------------------------------------------------------------------
% Theme
% -------------------------------------------------------------------------
C.bg      = [0.043 0.059 0.078];
C.panel   = [0.067 0.090 0.113];
C.panel2  = [0.052 0.072 0.092];
C.axes    = [0.025 0.035 0.045];
C.cyan    = [0.40 0.78 0.96];
C.green   = [0.35 0.78 0.61];
C.amber   = [0.93 0.68 0.30];
C.red     = [0.62 0.25 0.28];
C.blue    = [0.22 0.38 0.61];
C.purple  = [0.34 0.34 0.58];
C.white   = [0.94 0.96 0.98];
C.text2   = [0.70 0.78 0.83];
C.grid    = [0.20 0.29 0.36];

% -------------------------------------------------------------------------
% State
% -------------------------------------------------------------------------
state.audio = [];
state.fs = [];
state.source = "";
lastResult = [];

% -------------------------------------------------------------------------
% Figure
% -------------------------------------------------------------------------
fig = uifigure( ...
    'Name','AFFECT-X 2.0 | Speaker-Independent SER', ...
    'Color',C.bg, ...
    'Position',[60 50 1600 930], ...
    'AutoResizeChildren','off');

% Maximise on normal desktop use. The layout still works if resized.
try
    fig.WindowState = 'maximized';
catch
end

fig.SizeChangedFcn = @onFigureResize;

% -------------------------------------------------------------------------
% ROOT GRID
% -------------------------------------------------------------------------
root = uigridlayout(fig,[3 3]);
root.RowHeight = {70,'1x',225};
root.ColumnWidth = {290,'1x',400};
root.Padding = [12 10 12 10];
root.RowSpacing = 10;
root.ColumnSpacing = 10;
root.BackgroundColor = C.bg;

% =========================================================================
% HEADER
% =========================================================================
header = uipanel(root, ...
    'BackgroundColor',C.panel2, ...
    'ForegroundColor',C.cyan, ...
    'BorderType','line');
header.Layout.Row = 1;
header.Layout.Column = [1 3];

hg = uigridlayout(header,[2 1]);
hg.RowHeight = {42,24};
hg.ColumnWidth = {'1x'};
hg.Padding = [14 4 14 4];
hg.RowSpacing = 2;
hg.BackgroundColor = C.panel2;

titleLabel = uilabel(hg, ...
    'Text','AFFECT-X 2.0  •  SPEAKER-INDEPENDENT SPEECH EMOTION RECOGNITION', ...
    'FontSize',21, ...
    'FontWeight','bold', ...
    'FontColor',[0.62 0.91 1.00], ...
    'VerticalAlignment','center');
titleLabel.Layout.Row = 1;

subTitle = uilabel(hg, ...
    'Text','Research focus: acoustic cues • intensity generalisation • nested SFS • SVM/BiLSTM • temporal structure', ...
    'FontSize',11.5, ...
    'FontColor',C.text2, ...
    'VerticalAlignment','center');
subTitle.Layout.Row = 2;

% =========================================================================
% LEFT — CONTROL DECK
% =========================================================================
controlPanel = uipanel(root, ...
    'Title',' CONTROL DECK ', ...
    'BackgroundColor',C.panel, ...
    'ForegroundColor',C.white, ...
    'FontWeight','bold', ...
    'FontSize',13);
controlPanel.Layout.Row = 2;
controlPanel.Layout.Column = 1;

controlGrid = uigridlayout(controlPanel,[9 1]);
controlGrid.RowHeight = {48,48,48,52,48,48,48,20,'1x'};
controlGrid.ColumnWidth = {'1x'};
controlGrid.Padding = [10 10 10 10];
controlGrid.RowSpacing = 8;
controlGrid.ColumnSpacing = 0;
controlGrid.BackgroundColor = C.panel;

recordBtn = makeButton(controlGrid,'●  RECORD SPEECH 4 s',C.red,@recordAudio);
loadBtn   = makeButton(controlGrid,'⇩  LOAD AUDIO',C.blue,@loadAudio);
playBtn   = makeButton(controlGrid,'▷  PLAY AUDIO',C.blue,@playAudio);
analyzeBtn= makeButton(controlGrid,'◎  ANALYZE EMOTION',[0.08 0.43 0.34],@analyzeAudio);
labBtn    = makeButton(controlGrid,'⌁  OPEN SIGNAL LAB',C.purple,@openLab);
clearBtn  = makeButton(controlGrid,'↶  CLEAR',[0.45 0.15 0.17],@clearAll);
saveBtn   = makeButton(controlGrid,'▣  SAVE RESULT',C.blue,@saveResult);

analyzeBtn.FontSize = 12;

statusHeading = uilabel(controlGrid, ...
    'Text','STATUS', ...
    'FontSize',11.5, ...
    'FontWeight','bold', ...
    'FontColor',C.text2, ...
    'VerticalAlignment','bottom');

statusBox = uipanel(controlGrid, ...
    'BackgroundColor',[0.045 0.065 0.075], ...
    'BorderType','line', ...
    'ForegroundColor',[0.12 0.20 0.22]);

statusGrid = uigridlayout(statusBox,[1 1]);
statusGrid.RowHeight = {'1x'};
statusGrid.ColumnWidth = {'1x'};
statusGrid.Padding = [10 8 10 8];
statusGrid.BackgroundColor = statusBox.BackgroundColor;

status = uilabel(statusGrid, ...
    'Text','Ready.', ...
    'FontSize',11.5, ...
    'FontColor',C.green, ...
    'WordWrap','on', ...
    'VerticalAlignment','top');

% =========================================================================
% CENTER — SIGNAL VISUALISATION
% =========================================================================
signalPanel = uipanel(root, ...
    'Title',' SIGNAL VISUALISATION ', ...
    'BackgroundColor',C.panel, ...
    'ForegroundColor',C.white, ...
    'FontWeight','bold', ...
    'FontSize',13);
signalPanel.Layout.Row = 2;
signalPanel.Layout.Column = 2;

signalGrid = uigridlayout(signalPanel,[2 2]);
signalGrid.RowHeight = {'1x','1x'};
signalGrid.ColumnWidth = {'1x','1x'};
signalGrid.Padding = [12 12 12 12];
signalGrid.RowSpacing = 12;
signalGrid.ColumnSpacing = 12;
signalGrid.BackgroundColor = C.panel;

[axWave,wavePanel] = makeAxesCell(signalGrid,C,1,1,'Waveform');
[axSpec,specPanel] = makeAxesCell(signalGrid,C,1,2,'Spectrogram / STFT');
[axPitch,pitchPanel] = makeAxesCell(signalGrid,C,2,1,'F0 / Pitch');
[axScore,scorePanel] = makeAxesCell(signalGrid,C,2,2,'Emotion Score Distribution');

% Keep handles alive for resizing/debugging.
wavePanel.Tag = 'WaveformCell';
specPanel.Tag = 'SpectrogramCell';
pitchPanel.Tag = 'PitchCell';
scorePanel.Tag = 'ScoreCell';

% =========================================================================
% RIGHT — RESULT ENGINE
% =========================================================================
resultPanel = uipanel(root, ...
    'Title',' INFERENCE RESULT ', ...
    'BackgroundColor',C.panel, ...
    'ForegroundColor',C.white, ...
    'FontWeight','bold', ...
    'FontSize',13);
resultPanel.Layout.Row = 2;
resultPanel.Layout.Column = 3;

resultGrid = uigridlayout(resultPanel,[9 1]);
resultGrid.RowHeight = {26,82,24,66,32,32,34,'1x',40};
resultGrid.ColumnWidth = {'1x'};
resultGrid.Padding = [12 10 12 10];
resultGrid.RowSpacing = 6;
resultGrid.BackgroundColor = C.panel;

resultHeading = uilabel(resultGrid, ...
    'Text','PREDICTED EXPRESSED EMOTION', ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','center', ...
    'FontSize',12, ...
    'FontWeight','bold', ...
    'FontColor',C.text2);

emotionBox = uipanel(resultGrid, ...
    'BackgroundColor',C.axes, ...
    'BorderType','line', ...
    'ForegroundColor',[0.10 0.18 0.20]);

emotionGrid = uigridlayout(emotionBox,[1 1]);
emotionGrid.Padding = [6 4 6 4];
emotionGrid.BackgroundColor = C.axes;

emotionLabel = uilabel(emotionGrid, ...
    'Text','WAITING', ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','center', ...
    'FontSize',30, ...
    'FontWeight','bold', ...
    'FontColor',[0.45 0.84 1.00]);

scoreHeading = uilabel(resultGrid, ...
    'Text','RELATIVE ECOC DISPLAY SCORE', ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','center', ...
    'FontSize',11.5, ...
    'FontWeight','bold', ...
    'FontColor',C.text2);

meterPanel = uipanel(resultGrid, ...
    'BackgroundColor',C.panel2, ...
    'BorderType','line', ...
    'ForegroundColor',[0.20 0.29 0.36]);

meterGrid = uigridlayout(meterPanel,[1 1]);
meterGrid.Padding = [12 6 12 8];
meterGrid.BackgroundColor = C.panel2;

scoreMeterAx = uiaxes(meterGrid);
scoreMeterAx.Color = C.axes;
scoreMeterAx.XColor = C.text2;
scoreMeterAx.YColor = C.axes;
scoreMeterAx.XLim = [0 100];
scoreMeterAx.YLim = [0.5 1.5];
scoreMeterAx.XTick = 0:25:100;
scoreMeterAx.YTick = [];
scoreMeterAx.FontSize = 9;
scoreMeterAx.Box = 'on';
scoreMeterAx.GridColor = C.grid;
scoreMeterAx.XGrid = 'on';
scoreMeterAx.Toolbar.Visible = 'off';
scoreBar = barh(scoreMeterAx,1,0,0.42, ...
    'FaceColor',C.cyan,'EdgeColor','none');
title(scoreMeterAx,'','Color',C.white);

topScoreLabel = makeResultLine(resultGrid,'Top relative score:','—',C.green);
modelLabel = makeResultLine(resultGrid,'Model:','SFS-SVM READY',C.cyan);
selectedLabel = makeResultLine(resultGrid,'Selected features:','—',C.text2);

notice = uilabel(resultGrid, ...
    'Text',['Scores are normalized ECOC display scores, not calibrated probabilities. ' ...
            'The system estimates expressed affect and makes no hidden-state or truthfulness claim.'], ...
    'FontSize',10, ...
    'FontColor',[0.62 0.70 0.73], ...
    'WordWrap','on', ...
    'VerticalAlignment','top');

modelStatus = uilabel(resultGrid, ...
    'Text','Ready for audio input.', ...
    'FontSize',10.5, ...
    'FontColor',C.text2, ...
    'WordWrap','on', ...
    'VerticalAlignment','center', ...
    'HorizontalAlignment','left');

% =========================================================================
% BOTTOM ROW
% =========================================================================
bottomContainer = uipanel(root, ...
    'BackgroundColor',C.bg, ...
    'BorderType','none');
bottomContainer.Layout.Row = 3;
bottomContainer.Layout.Column = [1 3];

bottomGrid = uigridlayout(bottomContainer,[1 3]);
bottomGrid.RowHeight = {'1x'};
bottomGrid.ColumnWidth = {'1.08x','0.82x','1.10x'};
bottomGrid.Padding = [0 0 0 0];
bottomGrid.ColumnSpacing = 12;
bottomGrid.BackgroundColor = C.bg;

% --- Top predictions
topPanel = uipanel(bottomGrid, ...
    'Title',' TOP 5 PREDICTIONS ', ...
    'BackgroundColor',C.panel, ...
    'ForegroundColor',C.white, ...
    'FontWeight','bold', ...
    'FontSize',12);

topGrid = uigridlayout(topPanel,[1 1]);
topGrid.Padding = [8 8 8 8];
topGrid.BackgroundColor = C.panel;

predictionTable = uitable(topGrid, ...
    'ColumnName',{'Rank','Emotion','Display score'}, ...
    'ColumnWidth',{60,170,120}, ...
    'RowName',{}, ...
    'Data',cell(5,3), ...
    'FontSize',11, ...
    'BackgroundColor',[0.96 0.97 0.98;0.91 0.94 0.96], ...
    'ForegroundColor',[0.08 0.10 0.12]);

% --- Signal quality
qualityPanel = uipanel(bottomGrid, ...
    'Title',' SIGNAL QUALITY ', ...
    'BackgroundColor',C.panel, ...
    'ForegroundColor',C.white, ...
    'FontWeight','bold', ...
    'FontSize',12);

qualityGrid = uigridlayout(qualityPanel,[1 1]);
qualityGrid.Padding = [8 8 8 8];
qualityGrid.BackgroundColor = C.panel;

qualityTable = uitable(qualityGrid, ...
    'ColumnName',{'Quantity','Value'}, ...
    'ColumnWidth',{190,130}, ...
    'RowName',{}, ...
    'Data',cell(7,2), ...
    'FontSize',11, ...
    'BackgroundColor',[0.96 0.97 0.98;0.91 0.94 0.96], ...
    'ForegroundColor',[0.08 0.10 0.12]);

% --- Research design
researchPanel = uipanel(bottomGrid, ...
    'Title',' RESEARCH EVIDENCE ', ...
    'BackgroundColor',C.panel, ...
    'ForegroundColor',C.white, ...
    'FontWeight','bold', ...
    'FontSize',12);

researchGrid = uigridlayout(researchPanel,[1 1]);
researchGrid.Padding = [10 10 10 10];
researchGrid.BackgroundColor = C.panel;

researchText = uitextarea(researchGrid, ...
    'Editable','off', ...
    'FontName','Segoe UI', ...
    'FontSize',11, ...
    'FontColor',[0.84 0.95 0.98], ...
    'BackgroundColor',[0.08 0.10 0.11], ...
    'Value',{ ...
        'Validation: speaker-independent held-out actors'; ...
        'Feature selection: MRMR → actor-grouped SFS'; ...
        'Models: RBF-ECOC SVM + temporal BiLSTM'; ...
        'Experiments: intensity transfer + temporal ablation'; ...
        'Reporting: Macro-F1 • UAR • per-class recall • LOSO'});
try
    researchText.WordWrap = 'on';
catch
end

% -------------------------------------------------------------------------
% Initial model status
% -------------------------------------------------------------------------
modelFile = fullfile(cfg.ModelRoot,'affectx2_sfs_svm.mat');
if isfile(modelFile)
    modelLabel.Text = 'SFS-SVM READY';
else
    modelLabel.Text = 'MODEL NOT TRAINED';
    modelLabel.FontColor = C.amber;
end

% =========================================================================
% CALLBACKS
% =========================================================================
    function recordAudio(~,~)
        try
            setStatus('Recording 4 seconds...',C.amber);
            drawnow;

            rec = audiorecorder(cfg.TargetFs,16,1);
            recordblocking(rec,cfg.RecordSeconds);

            state.audio = getaudiodata(rec,'double');
            state.fs = cfg.TargetFs;
            state.source = "microphone";

            updateSignalViews();
            setStatus('Recorded. Click ANALYZE EMOTION.',C.green);
        catch ME
            setStatus('Recording failed.',C.red);
            uialert(fig,ME.message,'Recording error');
        end
    end

    function loadAudio(~,~)
        [f,p] = uigetfile( ...
            {'*.wav;*.flac;*.mp3;*.m4a','Audio files'}, ...
            'Select speech audio');

        if isequal(f,0)
            return;
        end

        try
            [state.audio,state.fs] = audioread(fullfile(p,f));
            state.source = string(fullfile(p,f));
            updateSignalViews();
            setStatus("Loaded: "+string(f),C.green);
        catch ME
            setStatus('Audio load failed.',C.red);
            uialert(fig,ME.message,'Load error');
        end
    end

    function playAudio(~,~)
        if isempty(state.audio)
            uialert(fig,'Record or load audio first.','No audio');
            return;
        end
        soundsc(state.audio,state.fs);
        setStatus('Playing current audio.',C.cyan);
    end

    function analyzeAudio(~,~)
        if isempty(state.audio)
            uialert(fig,'Record or load audio first.','No audio');
            return;
        end

        modelFileLocal = fullfile(cfg.ModelRoot,'affectx2_sfs_svm.mat');

        if ~isfile(modelFileLocal)
            uialert(fig, ...
                'Run the selected-feature SVM training option before dashboard inference.', ...
                'Model not trained');
            return;
        end

        try
            setStatus('Analysing acoustic features...',C.amber);
            analyzeBtn.Enable = 'off';
            drawnow;

            S = load(modelFileLocal,'bundle');
            B = S.bundle;

            [F,meta] = extractFrameFeatures2(state.audio,state.fs,cfg);
            [v,~,~] = summarizeStaticFeatures(F,meta);

            if max(B.SelectedColumns) > numel(v)
                error('Saved SVM feature indices do not match the current feature extractor.');
            end

            x = v(B.SelectedColumns);

            [pred,rawScore] = predict(B.Model,x);

            % ECOC score columns correspond to the classifier ClassNames.
            classNames = string(B.Model.ClassNames(:))';
            rawScore = double(rawScore);

            if size(rawScore,1) > 1
                rawScore = rawScore(1,:);
            end

            if numel(rawScore) ~= numel(classNames)
                error('Unexpected ECOC score shape from saved model.');
            end

            displayScore = normaliseDisplayScores(rawScore);
            [sortedScore,order] = sort(displayScore,'descend');

            emotionLabel.Text = upper(char(string(pred)));
            scoreBar.YData = 100*sortedScore(1);
            topScoreLabel.Text = sprintf('%.1f %%',100*sortedScore(1));
            selectedLabel.Text = sprintf('%d',numel(B.SelectedColumns));
            modelLabel.Text = 'SFS-SVM READY';
            modelStatus.Text = 'Inference completed successfully.';

            % Table
            nShow = min(5,numel(order));
            D = cell(nShow,3);
            for k = 1:nShow
                D{k,1} = k;
                D{k,2} = char(classNames(order(k)));
                D{k,3} = sprintf('%.1f%%',100*sortedScore(k));
            end
            predictionTable.Data = D;

            % Score chart
            cla(axScore);
            b = bar(axScore,1:numel(displayScore),displayScore,0.70);
            b.FaceColor = C.cyan;
            b.EdgeColor = 'none';

            axScore.XTick = 1:numel(classNames);
            axScore.XTickLabel = classNames;
            axScore.XTickLabelRotation = 27;
            ylim(axScore,[0 1]);
            ylabel(axScore,'Normalized score');
            title(axScore,'Emotion Score Distribution', ...
                'Color',C.white,'FontSize',11.5,'FontWeight','bold');

            for k = 1:numel(displayScore)
                text(axScore,k,min(0.96,displayScore(k)+0.035), ...
                    sprintf('%.0f%%',100*displayScore(k)), ...
                    'HorizontalAlignment','center', ...
                    'FontSize',8.5, ...
                    'Color',C.white);
            end

            lastResult = struct( ...
                'Prediction',string(pred), ...
                'ClassNames',classNames, ...
                'RawECOCScores',rawScore, ...
                'DisplayScores',displayScore, ...
                'Source',state.source);

            setStatus('Analysis complete.',C.green);

        catch ME
            emotionLabel.Text = 'ERROR';
            emotionLabel.FontColor = C.red;
            modelStatus.Text = 'Inference failed.';
            setStatus('Analysis failed.',C.red);
            uialert(fig,ME.message,'Analysis error');
        end

        if isvalid(analyzeBtn)
            analyzeBtn.Enable = 'on';
        end
    end

    function openLab(~,~)
        if isempty(state.audio)
            signal_lab2([],[],cfg);
        else
            signal_lab2(state.audio,state.fs,cfg);
        end
    end

    function clearAll(~,~)
        state.audio = [];
        state.fs = [];
        state.source = "";
        lastResult = [];

        resetAxes(axWave,'Waveform');
        resetAxes(axSpec,'Spectrogram / STFT');
        resetAxes(axPitch,'F0 / Pitch');
        resetAxes(axScore,'Emotion Score Distribution');

        emotionLabel.Text = 'WAITING';
        emotionLabel.FontColor = [0.45 0.84 1.00];
        scoreBar.YData = 0;
        topScoreLabel.Text = '—';
        selectedLabel.Text = '—';
        predictionTable.Data = cell(5,3);
        qualityTable.Data = cell(7,2);
        modelStatus.Text = 'Ready for audio input.';
        setStatus('Ready.',C.green);
    end

    function saveResult(~,~)
        if isempty(lastResult)
            uialert(fig,'Analyze audio first.','No result');
            return;
        end

        [f,p] = uiputfile('AFFECTX2_result.mat','Save AFFECT-X result');
        if isequal(f,0)
            return;
        end

        result = lastResult; %#ok<NASGU>
        save(fullfile(p,f),'result','-v7.3');
        setStatus("Saved: "+string(f),C.green);
    end

    function updateSignalViews()
        [x,fs] = preprocessAudio(state.audio,state.fs,cfg);

        if isempty(x)
            error('Audio contains no usable samples.');
        end

        % Waveform
        t = (0:numel(x)-1)/fs;
        cla(axWave);
        plot(axWave,t,x,'LineWidth',0.9,'Color',[0.30 0.65 0.95]);
        styleAxes(axWave,C);
        title(axWave,'Waveform','Color',C.white,'FontSize',11.5,'FontWeight','bold');
        xlabel(axWave,'Time (s)','FontSize',10);
        ylabel(axWave,'Amplitude','FontSize',10);

        % Spectrogram
        cla(axSpec);
        win = max(64,round(.025*fs));
        overlap = min(win-1,max(0,round(.015*fs)));

        if numel(x) >= win
            [S,F,T] = spectrogram(x,hann(win,'periodic'),overlap,1024,fs);
            imagesc(axSpec,T,F/1000,20*log10(abs(S)+1e-6));
            axis(axSpec,'xy');
            ylim(axSpec,[0 min(8,fs/2000)]);
        end

        styleAxes(axSpec,C);
        title(axSpec,'Spectrogram / STFT','Color',C.white,'FontSize',11.5,'FontWeight','bold');
        xlabel(axSpec,'Time (s)','FontSize',10);
        ylabel(axSpec,'Frequency (kHz)','FontSize',10);

        % Pitch
        cla(axPitch);
        try
            f0 = pitch(x,fs,'Range',[50 500]);
            f0 = double(f0(:));
            f0(~isfinite(f0) | f0<50 | f0>500) = NaN;

            if numel(f0) >= 5
                f0 = movmedian(f0,5,'omitnan');
            end

            tp = linspace(0,numel(x)/fs,numel(f0));
            plot(axPitch,tp,f0,'LineWidth',1.2,'Color',C.cyan);
            ylim(axPitch,[40 520]);
        catch
        end

        styleAxes(axPitch,C);
        title(axPitch,'F0 / Pitch','Color',C.white,'FontSize',11.5,'FontWeight','bold');
        xlabel(axPitch,'Time (s)','FontSize',10);
        ylabel(axPitch,'F0 (Hz)','FontSize',10);

        % Score view reset
        resetAxes(axScore,'Emotion Score Distribution');
        ylabel(axScore,'Normalized score','FontSize',10);

        % Basic signal quality table
        rmsValue = sqrt(mean(x.^2)+eps);
        peakValue = max(abs(x));
        duration = numel(x)/fs;
        clipping = mean(abs(x)>=0.999);

        qualityTable.Data = { ...
            'Sample rate',sprintf('%d Hz',fs); ...
            'Duration',sprintf('%.2f s',duration); ...
            'RMS',sprintf('%.4f',rmsValue); ...
            'Peak',sprintf('%.4f',peakValue); ...
            'Clipping',sprintf('%.3f %%',100*clipping); ...
            'Source',char(state.source); ...
            'Status','ready'};
    end

    function resetAxes(ax,ttl)
        cla(ax);
        styleAxes(ax,C);
        title(ax,ttl,'Color',C.white,'FontSize',11.5,'FontWeight','bold');
        ax.XLimMode = 'auto';
        ax.YLimMode = 'auto';
    end

    function setStatus(txt,col)
        if isvalid(status)
            status.Text = char(txt);
            status.FontColor = col;
        end
        drawnow limitrate;
    end

    function onFigureResize(~,~)
        % Responsive column widths. Keep controls and results readable while
        % allowing the centre visualization area to consume extra space.
        w = fig.Position(3);

        if w >= 1550
            root.ColumnWidth = {290,'1x',400};
            root.RowHeight = {70,'1x',225};
        elseif w >= 1300
            root.ColumnWidth = {275,'1x',370};
            root.RowHeight = {72,'1x',255};
        else
            root.ColumnWidth = {250,'1x',330};
            root.RowHeight = {70,'1x',245};
        end
    end
end

% =========================================================================
% LOCAL UI HELPERS
% =========================================================================
function b = makeButton(parent,txt,bg,cb)
b = uibutton(parent,'push', ...
    'Text',txt, ...
    'BackgroundColor',bg, ...
    'FontColor',[0.93 0.97 0.98], ...
    'FontWeight','bold', ...
    'FontSize',12, ...
    'ButtonPushedFcn',cb);
end

function [ax,p] = makeAxesCell(parent,C,row,col,ttl)
p = uipanel(parent, ...
    'BackgroundColor',C.panel2, ...
    'BorderType','line', ...
    'ForegroundColor',[0.12 0.18 0.20]);
p.Layout.Row = row;
p.Layout.Column = col;

g = uigridlayout(p,[1 1]);
g.RowHeight = {'1x'};
g.ColumnWidth = {'1x'};
g.Padding = [14 12 10 14];
g.BackgroundColor = C.panel2;

ax = uiaxes(g);
styleAxes(ax,C);
title(ax,ttl,'Color',C.white,'FontSize',11.5,'FontWeight','bold');

% The three-dot axes toolbar seen in the original screenshot consumes title
% space. Remove it for this dashboard.
try
    ax.Toolbar = [];
catch
    try
        ax.Toolbar.Visible = 'off';
    catch
    end
end
end

function lbl = makeResultLine(parent,leftText,rightText,col)
g = uigridlayout(parent,[1 2]);
g.RowHeight = {'1x'};
g.ColumnWidth = {145,'1x'};
g.Padding = [0 1 0 1];
g.ColumnSpacing = 8;
g.BackgroundColor = parent.BackgroundColor;

left = uilabel(g, ...
    'Text',leftText, ...
    'FontSize',10.5, ...
    'FontWeight','bold', ...
    'FontColor',[0.60 0.73 0.77], ...
    'VerticalAlignment','center');
left.Layout.Row = 1;
left.Layout.Column = 1;

lbl = uilabel(g, ...
    'Text',rightText, ...
    'FontSize',10.5, ...
    'FontWeight','bold', ...
    'FontColor',col, ...
    'HorizontalAlignment','right', ...
    'VerticalAlignment','center', ...
    'WordWrap','on');
lbl.Layout.Row = 1;
lbl.Layout.Column = 2;
end

function styleAxes(ax,C)
ax.Color = C.axes;
ax.XColor = C.text2;
ax.YColor = C.text2;
ax.GridColor = C.grid;
ax.MinorGridColor = C.grid;
ax.FontName = 'Segoe UI';
ax.FontSize = 10.5;
ax.Title.Color = C.white;
ax.Title.FontSize = 11.5;
ax.Title.FontWeight = 'bold';
ax.XLabel.Color = C.text2;
ax.YLabel.Color = C.text2;
ax.TickDir = 'out';
ax.Box = 'on';
ax.Layer = 'top';
grid(ax,'on');

try
    ax.Toolbar = [];
catch
end
end

function p = normaliseDisplayScores(score)
% Convert arbitrary ECOC decision scores into a bounded relative display.
% This is NOT probability calibration.

score = double(score(:)');
score(~isfinite(score)) = 0;

% Stable softmax provides an interpretable relative display only.
score = score - max(score);
e = exp(score);
den = sum(e);

if den <= 0 || ~isfinite(den)
    p = ones(size(score))/numel(score);
else
    p = e/den;
end
end
