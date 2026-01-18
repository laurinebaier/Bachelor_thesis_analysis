% LOCUST PLOTTING WALKING DISTANCE 


% Folder structure should look something like this:
% Data
%   |___ gregarious
%   |        |___greg01
%   |        |       |___ condition1 (eg. 'fed')
%   |        |       |       |___ tracked.csv
%   |        |       |       |___ annotation.mat
%   |        |       |___ condition2 (eg. 'starved')
%   |        |               |___ tracked.csv
%   |        |               |___ annotation.mat
%   |        |___greg02
%   |        |___greg03
%   |___ solitarious
%            |___soli01
%            |       |___ condition1
%            |       |       |___ tracked.csv
%            |       |       |___ annotation.mat
%            |       |___ condition2
%            |               |___ tracked.csv
%            |               |___ annotation.mat
%            |___soli02
%            |___soli03

%% EINSTELLUNGEN

clear; close all; clc;

set(groot, 'DefaultFigureColor', 'w', ...  % alle PLots haben weißen Hintergrund
           'DefaultAxesColor', 'w');

% Oberordner mit gregarious + solitarious
baseExpDir = '/Users/laurinebaier/Documents/Uni_Konstanz/bachelorthesis/experiments';

% Treatments
treat_greg = {'control_locust_saline', ...
              'methoprene', ...
              'precocene_II', ...
              'control_untreated', ...
              'control_DMSO'};

treat_soli = {'control_locust_saline', ...
              'methoprene', ...
              'precocene_II', ...
              'control_DMSO'};

nbins = 100;   % Heatmap-Auflösung

px_per_cm = 38.8;   % aus Fiji gemessen, anpassen falls nötig

% Sammelstrukturen initialisieren
all_x_greg = struct(); all_y_greg = struct();
for i = 1:numel(treat_greg)
    all_x_greg.(treat_greg{i}) = [];
    all_y_greg.(treat_greg{i}) = [];
end

all_x_soli = struct(); all_y_soli = struct();
for i = 1:numel(treat_soli)
    all_x_soli.(treat_soli{i}) = [];
    all_y_soli.(treat_soli{i}) = [];
end

%% ============================================
% 1) GREGARIOUS: alle Dateien einsammeln
%% ============================================

gregDir = fullfile(baseExpDir, 'gregarious');

% alle *_tracked.csv unter gregarious
filesGreg = dir(fullfile(gregDir, '**', '*_tracked.csv'));

% GREG: Dateien nach Treatment sortieren
filesGregByTreat = struct();
for i = 1:numel(treat_greg)
    filesGregByTreat.(treat_greg{i}) = {};
end

for k = 1:numel(filesGreg)
    csvFile = fullfile(filesGreg(k).folder, filesGreg(k).name);
    [folder, ~, ~]   = fileparts(csvFile);      % .../gregXX/TREATMENT
    [gregFolder, ~]  = fileparts(folder);       % .../gregXX
    [~, gregName]    = fileparts(gregFolder);   % 'greg01'...
    tName = getTreatmentFromGreg(gregName);
    if isempty(tName), continue; end
    filesGregByTreat.(tName){end+1} = csvFile;
end

% GREGARIOUS: Einzeltier-Plots pro Treatment
for i = 1:numel(treat_greg)
    treat = treat_greg{i};
    fileList = filesGregByTreat.(treat);
    if isempty(fileList), continue; end

    n = numel(fileList);
    ncols = ceil(sqrt(n));          % grobes Layout
    nrows = ceil(n / ncols);

    figure;
    sgtitle(['gregarious: ' strrep(treat,'_','\_')]);  % Gesamttitel

    % Hinweis unten rechts in der Figure
    annotation('textbox',[0.55 0.01 0.4 0.04], ...
    'String','left: empty shelter, right: conspecific shelter', ...
    'EdgeColor','none', ...
    'HorizontalAlignment','right', ...
    'Interpreter','none');

    for k = 1:n
        csvFile = fileList{k};
        [folder, baseName, ~] = fileparts(csvFile);
        matFile = fullfile(folder, strrep(baseName,'_tracked','_annotation.mat'));
        if ~exist(matFile,'file'), continue; end

        [pos_x_aligned, pos_y] = loadAndAlign(csvFile, matFile);

         % Arena-ROI laden, um feste Achsengrenzen setzen zu können
        S = load(matFile);
        roiPar = S.Annotation.ROI.Par;
        center = roiPar(1:2);
        R      = roiPar(3);

        subplot(nrows, ncols, k);
        plot(pos_x_aligned, pos_y, '.-', 'Color',[0.3 0.3 0.3]);
        axis equal;
        xlim([center(1)-R, center(1)+R]);   % fester Arena-Ausschnitt in x
        ylim([center(2)-R, center(2)+R]);   % fester Arena-Ausschnitt in y

        [gregFolder, ~] = fileparts(folder);       % .../gregXX
        [~, gregName]    = fileparts(gregFolder);  % 'greg01' etc.
        title(gregName,'Interpreter','none');

        xlabel('x'); ylabel('y');
    end
end


for k = 1:numel(filesGreg)

    % Voller Pfad zur Tracking-Datei
    csvFile = fullfile(filesGreg(k).folder, filesGreg(k).name);

    % Pfadstruktur: .../gregarious/gregXX/TREATMENT/DATE*_tracked.csv
    [folder, ~, ~]     = fileparts(csvFile);    % .../gregXX/TREATMENT
    [gregFolder, ~]    = fileparts(folder);     % .../gregXX
    [~, gregName]      = fileparts(gregFolder); % 'greg01', 'greg02', ...

    % Treatment aus gregXX bestimmen
    treatmentName = getTreatmentFromGreg(gregName);

    % überspringen, wenn kein gültiges greg-Tier
    if isempty(treatmentName)
        continue;
    end

    % Annotation-Datei zugehörig zu dieser Tracking-Datei
    [~, baseName, ~] = fileparts(csvFile);  % z.B. NAME_tracked
    matFile = fullfile(folder, strrep(baseName,'_tracked','_annotation.mat'));

    if ~exist(matFile,'file')
        fprintf('Keine Annotation für %s\n', csvFile);
        continue;
    end

    % pos_x ausrichten, pos_y übernehmen
    [pos_x_aligned, pos_y] = loadAndAlign(csvFile, matFile);

    % Arena-Zentrum aus Annotation (Pixel)
S = load(matFile);
roiPar = S.Annotation.ROI.Par;    % [xmid, ymid, R_px]
center_px = roiPar(1:2);
center_cm = center_px / px_per_cm;

% Koordinaten in cm und um das Zentrum auf (30,30) schieben
pos_x_cm = pos_x_aligned / px_per_cm;
pos_y_cm = pos_y / px_per_cm;

pos_x_cm = pos_x_cm - center_cm(1) + 30;
pos_y_cm = pos_y_cm - center_cm(2) + 30;

    % Punkte in passende Treatment-Sammlung schreiben
    all_x_greg.(treatmentName) = [all_x_greg.(treatmentName); pos_x_cm];
    all_y_greg.(treatmentName) = [all_y_greg.(treatmentName); pos_y_cm];
end

%% ============================================
% 2) SOLITARIOUS: alle Dateien einsammeln
%% ============================================

soliDir = fullfile(baseExpDir, 'solitarious');

filesSoli = dir(fullfile(soliDir, '**', '*_tracked.csv'));

% SOLI: Dateien nach Treatment sortieren
filesSoliByTreat = struct();
for i = 1:numel(treat_soli)
    filesSoliByTreat.(treat_soli{i}) = {};
end

for k = 1:numel(filesSoli)
    csvFile = fullfile(filesSoli(k).folder, filesSoli(k).name);
    [folder, ~, ~]   = fileparts(csvFile);      % .../soliXX/TREATMENT
    [soliFolder, ~]  = fileparts(folder);       % .../soliXX
    [~, soliName]    = fileparts(soliFolder);   % 'soli01'...
    tName = getTreatmentFromSoli(soliName);
    if isempty(tName), continue; end
    filesSoliByTreat.(tName){end+1} = csvFile;
end

% SOLITARIOUS: Einzeltier-Plots pro Treatment
for i = 1:numel(treat_soli)
    treat = treat_soli{i};
    fileList = filesSoliByTreat.(treat);
    if isempty(fileList), continue; end

    n = numel(fileList);
    ncols = ceil(sqrt(n));
    nrows = ceil(n / ncols);

    figure;
    sgtitle(['solitarious: ' strrep(treat,'_','\_')]);

    % Hinweis unten rechts in der Figure
    annotation('textbox',[0.55 0.01 0.4 0.04], ...
    'String','left: empty shelter, right: conspecific shelter', ...
    'EdgeColor','none', ...
    'HorizontalAlignment','right', ...
    'Interpreter','none');

    for k = 1:n
        csvFile = fileList{k};
        [folder, baseName, ~] = fileparts(csvFile);
        matFile = fullfile(folder, strrep(baseName,'_tracked','_annotation.mat'));
        if ~exist(matFile,'file'), continue; end

        [pos_x_aligned, pos_y] = loadAndAlign(csvFile, matFile);

         % Arena-ROI laden, um feste Achsengrenzen setzen zu können
        S = load(matFile);
        roiPar = S.Annotation.ROI.Par;
        center = roiPar(1:2);
        R      = roiPar(3);
        
        subplot(nrows, ncols, k);
        plot(pos_x_aligned, pos_y, '.-', 'Color',[0.3 0.3 0.3]);
        axis equal;

        axis equal;
        xlim([center(1)-R, center(1)+R]);   % fester Arena-Ausschnitt in x
        ylim([center(2)-R, center(2)+R]);   % fester Arena-Ausschnitt in y
        
        [soliFolder, ~] = fileparts(folder);      % .../soliXX
        [~, soliName]   = fileparts(soliFolder);  % 'soli01' etc.
        title(soliName,'Interpreter','none');

        xlabel('x'); ylabel('y');
    end
end


for k = 1:numel(filesSoli)

    csvFile = fullfile(filesSoli(k).folder, filesSoli(k).name);

    % Pfadstruktur: .../solitarious/soliXX/TREATMENT/DATE*_tracked.csv
    [folder, ~, ~]    = fileparts(csvFile);      % .../soliXX/TREATMENT
    [soliFolder, ~]   = fileparts(folder);       % .../soliXX
    [~, soliName]     = fileparts(soliFolder);   % 'soli01', 'soli02', ...

    treatmentName = getTreatmentFromSoli(soliName);

    if isempty(treatmentName)
        continue;
    end

    [~, baseName, ~] = fileparts(csvFile);
    matFile = fullfile(folder, strrep(baseName,'_tracked','_annotation.mat'));

    if ~exist(matFile,'file')
        fprintf('Keine Annotation für %s\n', csvFile);
        continue;
    end

[pos_x_aligned, pos_y] = loadAndAlign(csvFile, matFile);

% Arena-Zentrum aus Annotation (Pixel)
S = load(matFile);
roiPar = S.Annotation.ROI.Par;    % [xmid, ymid, R_px]
center_px = roiPar(1:2);
center_cm = center_px / px_per_cm;

% Koordinaten in cm und um das Zentrum auf (30,30) schieben
pos_x_cm = pos_x_aligned / px_per_cm;
pos_y_cm = pos_y / px_per_cm;

pos_x_cm = pos_x_cm - center_cm(1) + 30;
pos_y_cm = pos_y_cm - center_cm(2) + 30;

    % sammeln
    all_x_soli.(treatmentName) = [all_x_soli.(treatmentName); pos_x_cm];
    all_y_soli.(treatmentName) = [all_y_soli.(treatmentName); pos_y_cm];
end


%% Gemeinsame Figure: greg links, soli rechts (hochkant)
order_greg = { ...
    'control_locust_saline', ...
    'methoprene', ...
    'control_DMSO', ...
    'precocene_II'};
order_soli = order_greg;

figAll = figure;
figAll.Units  = 'centimeters';      % Hochformat-Layout
figAll.Position = [2 2 18 24];      % [links unten breite höhe], z.B. 18×24 cm

tAll  = tiledlayout(figAll, 4, 2, 'TileSpacing','compact', 'Padding','compact');
title(tAll, 'Heatmaps - gregarious (links) vs. solitarious (rechts)');

nbins = 100;
clim  = [0 800];    % gemeinsame Farbskala

% linke Spalte: gregarious
for r = 1:numel(order_greg)
    name = order_greg{r};
    xdat = all_x_greg.(name);
    ydat = all_y_greg.(name);
    ax   = nexttile(tAll, (r-1)*2 + 1);   % 1,3,5,7
    if isempty(xdat)
        text(0.5,0.5,'No data','Units','normalized','Color','w', ...
             'HorizontalAlignment','center');
        axis off;
        continue;
    end
    [N,Xedges,Yedges] = histcounts2(xdat, ydat, [nbins nbins]);
    imagesc(ax, Xedges, Yedges, N');
    set(ax,'YDir','normal','DataAspectRatio',[1 1 1]);
    colormap(ax, turbo);
    caxis(ax, clim);
    xlim(ax,[0 60]);
    ylim(ax,[0 60]);
    xticks(ax, 0:20:60);
    yticks(ax, 0:20:60);
    xlabel(ax,'x [cm]');
    ylabel(ax,'y [cm]');
    title(ax, strrep(name,'_','\_'));
end

% rechte Spalte: solitarious
lastAx = [];   % Handle für die Colorbar merken
for r = 1:numel(order_soli)
    name = order_soli{r};
    xdat = all_x_soli.(name);
    ydat = all_y_soli.(name);
    ax   = nexttile(tAll, (r-1)*2 + 2);   % 2,4,6,8
    if isempty(xdat)
        text(0.5,0.5,'No data','Units','normalized','Color','w', ...
             'HorizontalAlignment','center');
        axis off;
        continue;
    end
    [N,Xedges,Yedges] = histcounts2(xdat, ydat, [nbins nbins]);
    imagesc(ax, Xedges, Yedges, N');
    set(ax,'YDir','normal','DataAspectRatio',[1 1 1]);
    colormap(ax, turbo);
    caxis(ax, clim);
    xlim(ax,[0 60]);
    ylim(ax,[0 60]);
    xticks(ax, 0:20:60);
    yticks(ax, 0:20:60);
    xlabel(ax,'x [cm]');
    ylabel(ax,'y [cm]');
    title(ax, strrep(name,'_','\_'));
    if r == numel(order_soli)
        lastAx = ax;    % unten rechts
    end
end

% kompakte Colorbar NUR unten rechts
if ~isempty(lastAx)
    cb = colorbar(lastAx, 'eastoutside');
    cb.Label.String = 'Number of positions';
    cb.FontSize = 8;          % kleiner
    cb.Box = 'off';
end



%% ============================================
% 3) HEATMAPS zeichnen
%% ============================================
%% --- Gregarious: 5 Treatments in ONE figure (2x3) ---
% gewünschte Reihenfolge der gregarious-Treatments (links -> rechts, oben -> unten)

treat_greg = { ...
    'control_untreated', ...
    'control_locust_saline', ...
    'methoprene', ...
    'control_DMSO', ...
    'precocene_II'};

figG = figure;
tG = tiledlayout(figG, 2, 3, 'TileSpacing','compact', 'Padding','compact');
title(tG,'Heatmaps - gregarious');

for i = 1:numel(treat_greg)
    name = treat_greg{i};
    xdat = all_x_greg.(name);
    ydat = all_y_greg.(name);
    if isempty(xdat)
        fprintf('No gregarious data for %s.\n', name);
        continue;
    end

        [N, Xedges, Yedges] = histcounts2(xdat, ydat, [nbins nbins]);
    ax = nexttile(tG);
    imagesc(ax, Xedges, Yedges, N');
    set(ax,'YDir','normal','DataAspectRatio',[1 1 1]);
    colormap(ax, turbo);
    caxis(ax,[0 800]);

    % Achsen explizit in cm setzen
    xlim(ax, [0 60]);
    ylim(ax, [0 60]);
    xlabel(ax,'x [cm]','Interpreter','none');
    ylabel(ax,'y [cm]','Interpreter','none');

    title(ax, strrep(name,'_','\_'), 'Interpreter','tex');

    % Shelter-Beschriftung NUR in der ersten Heatmap
    if i == 1
        hold(ax,'on');
        yl = ylim(ax);
        xl = xlim(ax);
        xLeft  = xl(1) + 0.05*(xl(2)-xl(1));
        xRight = xl(2) - 0.05*(xl(2)-xl(1));
        yPos   = yl(1) + 0.08*(yl(2)-yl(1));

        text(ax, xLeft,  yPos,  'empty shelter', ...
            'Color','w','FontSize',8,'HorizontalAlignment','left', ...
            'Interpreter','none');
        text(ax, xRight, yPos,  'conspecific shelter', ...
            'Color','w','FontSize',8,'HorizontalAlignment','right', ...
            'Interpreter','none');
        hold(ax,'off');
    end
end

cb = colorbar;
cb.Location = 'eastoutside';
cb.Label.String = 'Number of positions';
cb.Label.Interpreter = 'none';

%% --- Solitarious: 4 Treatments in ONE figure (1x4) ---
% gewünschte Reihenfolge der solitarious-Treatments (links -> rechts)
treat_soli = { ...
    'control_locust_saline', ...
    'methoprene', ...
    'control_DMSO', ...
    'precocene_II'};

figS = figure;
tS = tiledlayout(figS, 1, 4, 'TileSpacing','compact', 'Padding','compact');
title(tS,'Heatmaps - solitarious');

for i = 1:numel(treat_soli)
    name = treat_soli{i};
    xdat = all_x_soli.(name);
    ydat = all_y_soli.(name);
    if isempty(xdat)
        fprintf('No solitarious data for %s.\n', name);
        continue;
    end

        [N, Xedges, Yedges] = histcounts2(xdat, ydat, [nbins nbins]);
    ax = nexttile(tS);
    imagesc(ax, Xedges, Yedges, N');
    set(ax,'YDir','normal','DataAspectRatio',[1 1 1]);
    colormap(ax, turbo);
    caxis(ax,[0 800]);

    % Achsen explizit in cm setzen
    xlim(ax, [0 60]);
    ylim(ax, [0 60]);
    xlabel(ax,'x [cm]','Interpreter','none');
    ylabel(ax,'y [cm]','Interpreter','none');

    title(ax, strrep(name,'_','\_'), 'Interpreter','tex');

title(ax, strrep(name,'_','\_'), 'Interpreter','tex');

    % Shelter-Beschriftung NUR in der ersten Heatmap
    if i == 1
        hold(ax,'on');
        yl = ylim(ax);
        xl = xlim(ax);
        xLeft  = xl(1) + 0.05*(xl(2)-xl(1));
        xRight = xl(2) - 0.05*(xl(2)-xl(1));
        yPos   = yl(1) + 0.08*(yl(2)-yl(1));

        text(ax, xLeft,  yPos,  'empty shelter', ...
            'Color','w','FontSize',6,'HorizontalAlignment','left', ...
            'Interpreter','none');
        text(ax, xRight, yPos,  'conspecific shelter', ...
            'Color','w','FontSize',6,'HorizontalAlignment','right', ...
            'Interpreter','none');
        hold(ax,'off');
    end
end

cb = colorbar;
cb.Location = 'eastoutside';
cb.Label.String = 'Number of positions';
cb.Label.Interpreter = 'none';
