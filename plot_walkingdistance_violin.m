%% Walking-distance Violinplots nach Phase & Treatment

clear; clc;

set(groot, 'DefaultFigureColor', 'w', ...
           'DefaultAxesColor',  'w');    % alle Plots haben einen weißen Hintergrund

cd('/Users/laurinebaier/Documents/Uni_Konstanz/bachelorthesis/plot');

% Tabellen laden (aus build_locust_tables.m erzeugt)
load('table_locustdata.mat');   % enthält table_locustdata und WalkingLong

%% GREGARIOUS: 5 Treatments
isGreg = WalkingLong.Phase == "gregarious";
WG = WalkingLong(isGreg,:);

% gewünschte Reihenfolge (von links nach rechts):
treat_greg = [ ...
    "control_untreated", ...
    "control_locust_saline", ...
    "methoprene", ...
    "control_DMSO", ...
    "precocene_II"];

figure;
hold on;
for i = 1:numel(treat_greg)
    thisTreat = treat_greg(i);
    vals = WG.WalkingDist(WG.Treatment == thisTreat);

    if isempty(vals)
        continue;
    end

    x0 = i;                              % x-Position dieser Violine

    % Dichte schätzen
    [f,xi] = ksdensity(vals);
    f = f / max(f) * 0.4;                % maximale Halbbreite ~0.4

    % Violine zeichnen
    fill([x0-f, fliplr(x0+f)], [xi, fliplr(xi)], [0 0.6 0.8], ...
         'FaceAlpha',0.4,'EdgeColor','none');

    % Einzeltier-Punkte
    scatter(x0*ones(size(vals)), vals, 25, 'k','filled');
end
hold off;

xlim([0.5 numel(treat_greg)+0.5]);
ylim([-20, 60]);      % feste Skala

set(gca, 'XTick', 1:numel(treat_greg), ...
         'XTickLabel', strrep(treat_greg,'_','\_'), ...  % Unterstriche sauber
         'TickLabelInterpreter','tex', ...
         'FontSize', 10);
ylabel('Walking distance [m]', 'FontSize', 11);
title('Walking distance – gregarious', 'FontSize', 12);
box on; grid on;

%% SOLITARIOUS: 4 Treatments
isSoli = WalkingLong.Phase == "solitarious";
WS = WalkingLong(isSoli,:);

% gewünschte Reihenfolge (von links nach rechts):
treat_soli = [ ...
    "control_locust_saline", ...
    "methoprene", ...
    "control_DMSO", ...
    "precocene_II"];

figure;
hold on;
for i = 1:numel(treat_soli)
    thisTreat = treat_soli(i);
    vals = WS.WalkingDist(WS.Treatment == thisTreat);

    if isempty(vals)
        continue;
    end

    x0 = i;
    [f,xi] = ksdensity(vals);
    f = f / max(f) * 0.4;

    fill([x0-f, fliplr(x0+f)], [xi, fliplr(xi)], [0 0.6 0.8], ...
         'FaceAlpha',0.4,'EdgeColor','none');

    scatter(x0*ones(size(vals)), vals, 25, 'k','filled');
end
hold off;

xlim([0.5 numel(treat_soli)+0.5]);
ylim([-20, 60]);      % feste Skala

set(gca, 'XTick', 1:numel(treat_soli), ...
         'XTickLabel', strrep(treat_soli,'_','\_'), ...
         'TickLabelInterpreter','tex', ...
         'FontSize', 10);
ylabel('Walking distance [m]', 'FontSize', 11);
title('Walking distance – solitarious', 'FontSize', 12);
box on; grid on;