function fig = signal_lab2(x,fs,cfg)
%SIGNAL_LAB2 Professional acoustic analysis dashboard for AFFECT-X 2.0.
% Drop-in replacement for:
%   <project>\ui\signal_lab2.m
%
% Goals:
%   - cleaner 2x2 technical plots
%   - readable axes, titles, labels and tick marks
%   - properly sized bottom tables/panels
%   - good appearance on laptop screens and maximized windows

if nargin < 3 || isempty(cfg)
    cfg = defaultConfig;
end

if nargin < 1 || isempty(x)
    [f,p] = uigetfile({'*.wav;*.flac;*.mp3;*.m4a','Audio files'});
    if isequal(f,0)
        fig = [];
        return;
    end
    [x,fs] = audioread(fullfile(p,f));
end

[x,fs] = preprocessAudio(x,fs,cfg);
[F,meta] = extractFrameFeatures2(x,fs,cfg);

% -------------------------------------------------------------------------
% Theme
% -------------------------------------------------------------------------
C.bg      = [0.035 0.050 0.060];
C.panel   = [0.055 0.075 0.085];
C.panel2  = [0.040 0.060 0.070];
C.axes    = [0.010 0.022 0.028];
C.white   = [0.91 0.96 0.97];
C.text2   = [0.60 0.73 0.77];
C.cyan    = [0.62 0.91 1.00];
C.grid    = [0.15 0.27 0.30];

% -------------------------------------------------------------------------
% Figure
% -------------------------------------------------------------------------
fig = uifigure( ...
    'Name','AFFECT-X 2.0 | Signal Laboratory', ...
    'Color',C.bg, ...
    'Position',[120 70 1500 900], ...
    'AutoResizeChildren','off');

try
    fig.WindowState = 'maximized';
catch
end

root = uigridlayout(fig,[3 1]);
root.RowHeight = {56,'1x',270};
root.ColumnWidth = {'1x'};
root.Padding = [12 10 12 12];
root.RowSpacing = 12;
root.BackgroundColor = C.bg;

% -------------------------------------------------------------------------
% Header
% -------------------------------------------------------------------------
header = uipanel(root, ...
    'BackgroundColor',C.panel2, ...
    'ForegroundColor',C.cyan, ...
    'BorderType','line');
header.Layout.Row = 1;

hg = uigridlayout(header,[2 1]);
hg.RowHeight = {30,18};
hg.ColumnWidth = {'1x'};
hg.Padding = [14 4 14 2];
hg.RowSpacing = 1;
hg.BackgroundColor = C.panel2;

uilabel(hg, ...
    'Text','SIGNAL LABORATORY  •  WAVEFORM, STFT, PITCH AND ENERGY ANALYSIS', ...
    'FontSize',20, ...
    'FontWeight','bold', ...
    'FontColor',C.cyan, ...
    'VerticalAlignment','center');

uilabel(hg, ...
    'Text','Technical evidence view for acoustic analysis and debugging', ...
    'FontSize',11, ...
    'FontColor',C.text2, ...
    'VerticalAlignment','center');

% -------------------------------------------------------------------------
% Plot region
% -------------------------------------------------------------------------
plotPanel = uipanel(root, ...
    'BackgroundColor',C.panel, ...
    'ForegroundColor',C.white, ...
    'Title',' SIGNAL VISUALISATION ', ...
    'FontSize',13, ...
    'FontWeight','bold');
plotPanel.Layout.Row = 2;

pg = uigridlayout(plotPanel,[2 2]);
pg.RowHeight = {'1x','1x'};
pg.ColumnWidth = {'1x','1x'};
pg.Padding = [16 16 16 16];
pg.RowSpacing = 16;
pg.ColumnSpacing = 16;
pg.BackgroundColor = C.panel;

ax1 = makePlotCell(pg,C,'Waveform','Time (s)','Amplitude',1,1);
ax2 = makePlotCell(pg,C,'Spectrogram / STFT','Time (s)','Frequency (kHz)',1,2);
ax3 = makePlotCell(pg,C,'F0 / Pitch','Time (s)','F0 (Hz)',2,1);
ax4 = makePlotCell(pg,C,'Short-Time Energy','Time (s)','Energy / RMS',2,2);

% -------------------------------------------------------------------------
% Bottom region
% -------------------------------------------------------------------------
bottom = uigridlayout(root,[1 2]);
bottom.Layout.Row = 3;
bottom.RowHeight = {'1x'};
bottom.ColumnWidth = {'1.4x','1x'};
bottom.Padding = [0 0 0 0];
bottom.ColumnSpacing = 12;
bottom.BackgroundColor = C.bg;

% Feature bank
featPanel = uipanel(bottom, ...
    'Title',' FEATURE BANK ', ...
    'BackgroundColor',C.panel, ...
    'ForegroundColor',C.white, ...
    'FontWeight','bold', ...
    'FontSize',13);
featPanel.Layout.Column = 1;

fg = uigridlayout(featPanel,[1 1]);
fg.Padding = [10 10 10 10];
fg.BackgroundColor = C.panel;

T = table(string(meta.Name(:)), string(meta.Family(:)), 'VariableNames',{'FrameFeature','Family'});
uit = uitable(fg, ...
    'Data',T, ...
    'ColumnName',{'FrameFeature','Family'}, ...
    'RowName',{}, ...
    'ColumnEditable',[false false], ...
    'ColumnSortable',true, ...
    'FontSize',12, ...
    'ColumnWidth',{380,140});
try
    uit.RowStriping = 'on';
end

% Signal summary
sumPanel = uipanel(bottom, ...
    'Title',' SIGNAL SUMMARY ', ...
    'BackgroundColor',C.panel, ...
    'ForegroundColor',C.white, ...
    'FontWeight','bold', ...
    'FontSize',13);
sumPanel.Layout.Column = 2;

sg = uigridlayout(sumPanel,[1 1]);
sg.Padding = [10 10 10 10];
sg.BackgroundColor = C.panel;

[f0,tf] = safePitchTrack(x,fs);
validF0 = f0(isfinite(f0) & f0 > 0);
if isempty(validF0)
    medF0 = NaN;
    f0Range = NaN;
else
    medF0 = median(validF0);
    f0Range = max(validF0)-min(validF0);
end

rmsVal = sqrt(mean(x.^2)+eps);
peakVal = max(abs(x));
durationSec = numel(x)/fs;
snrEst = estimateSimpleSNR(x,fs);

summaryData = { ...
    'Sample rate',          sprintf('%d Hz',fs); ...
    'Duration',             sprintf('%.2f s',durationSec); ...
    'RMS',                  sprintf('%.4f',rmsVal); ...
    'Peak',                 sprintf('%.4f',peakVal); ...
    'Estimated SNR',        sprintf('%.1f dB',snrEst); ...
    'Median F0',            localFormatHz(medF0); ...
    'Pitch range',          localFormatHz(f0Range); ...
    'Frame features',       sprintf('%d',size(F,2)); ...
    'Frames',               sprintf('%d',size(F,1)) ...
    };

uit2 = uitable(sg, ...
    'Data',summaryData, ...
    'ColumnName',{'Quantity','Value'}, ...
    'RowName',{}, ...
    'ColumnEditable',[false false], ...
    'FontSize',12, ...
    'ColumnWidth',{230,160});
try
    uit2.RowStriping = 'on';
end

% -------------------------------------------------------------------------
% Plot data
% -------------------------------------------------------------------------
t = (0:numel(x)-1)/fs;
plot(ax1,t,x,'LineWidth',1.1,'Color',[0.45 0.65 0.95]);
xlim(ax1,[0 max(t)]);

w = max(64,round(0.025*fs));
ov = min(w-1,round(0.015*fs));
[S,fr,tm] = spectrogram(x,hann(w,'periodic'),ov,1024,fs);
imagesc(ax2,tm,fr/1000,20*log10(abs(S)+1e-6));
axis(ax2,'xy');
ylim(ax2,[0 min(8,fs/2000)]);
colormap(ax2,parula);

plot(ax3,tf,f0,'LineWidth',1.1,'Color',[0.30 0.62 0.98]);
xlim(ax3,[0 max(t)]);
if ~isempty(validF0)
    ylim(ax3,[max(40,floor(min(validF0)*0.9)) ceil(max(validF0)*1.05)]);
end

energyCols = find(meta.Family=="energy",1);
if isempty(energyCols)
    frameLen = max(1,round(0.03*fs));
    eng = sqrt(movmean(x.^2,frameLen));
    te = t;
else
    eng = F(:,energyCols);
    te = linspace(0,durationSec,numel(eng));
end
plot(ax4,te,eng,'LineWidth',1.1,'Color',[0.30 0.62 0.98]);
xlim(ax4,[0 max(t)]);

end

% =========================================================================
% Helper functions
% =========================================================================
function ax = makePlotCell(parent,C,titleText,xlab,ylab,row,col)
cellPanel = uipanel(parent, ...
    'BackgroundColor',C.panel2, ...
    'BorderType','line', ...
    'ForegroundColor',[0.14 0.23 0.25]);
cellPanel.Layout.Row = row;
cellPanel.Layout.Column = col;

cg = uigridlayout(cellPanel,[1 1]);
cg.Padding = [12 12 10 10];
cg.BackgroundColor = C.panel2;

ax = uiaxes(cg);
ax.Color = C.axes;
ax.FontSize = 12;
ax.FontWeight = 'normal';
ax.GridColor = C.grid;
ax.MinorGridColor = C.grid;
ax.XColor = C.text2;
ax.YColor = C.text2;
ax.Box = 'on';
ax.LineWidth = 1.0;
ax.Toolbar.Visible = 'off';
ax.Interactions = [];
grid(ax,'on');
ax.XGrid = 'on';
ax.YGrid = 'on';
title(ax,titleText,'Color',C.white,'FontSize',13,'FontWeight','bold');
xlabel(ax,xlab,'Color',C.text2,'FontSize',11);
ylabel(ax,ylab,'Color',C.text2,'FontSize',11);
end

function out = localFormatHz(v)
if ~isfinite(v)
    out = 'N/A';
else
    out = sprintf('%.2f Hz',v);
end
end

function snrEst = estimateSimpleSNR(x,fs)
% Rough engineering estimate from lower-energy vs higher-energy regions.
frameLen = max(128,round(0.02*fs));
if numel(x) < frameLen
    snrEst = NaN;
    return;
end
x2 = buffer(x.^2,frameLen,round(0.5*frameLen),'nodelay');
framePow = mean(x2,1);
lo = prctile(framePow,20);
hi = prctile(framePow,80);
snrEst = 10*log10((hi+eps)/(lo+eps));
end
