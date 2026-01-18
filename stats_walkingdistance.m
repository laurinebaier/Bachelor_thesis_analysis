%% SKRIPT STATISTISCHE AUSWERTUNG WALKING DISTANCE

clear; close all; clc;

set(groot, 'DefaultFigureColor', 'w', ...  % Plots haben weißen Hintergrund
           'DefaultAxesColor',  'w');

% Annahme: ArenaAnalysis02_plotting.m wurde schon ausgeführt
% und table_locustdata ist im Workspace vorhanden

cd('/Users/laurinebaier/Documents/Uni_Konstanz/bachelorthesis/plot');
load('table_locustdata.mat');   % lädt table_locustdata in den Workspace

% 1) Analyse-Tabelle neu aufbauen
WalkingLong = table_locustdata(:, {'animal','phase','feedingstate','WalkingDistance_m'});

% 2) Optional: gleich in passende Typen umwandeln
WalkingLong.animal    = categorical(WalkingLong.animal);
WalkingLong.phase     = categorical(WalkingLong.phase);
WalkingLong.feedingstate = categorical(WalkingLong.feedingstate);

% 3) feedingstate in Treatment umbenennen
WalkingLong.Properties.VariableNames{'feedingstate'} = 'treatment';

% === stats_walkingdistance.m ===
% Annahme: Tabelle WalkingLong mit Spalten:
% animal, Phase, feedingstate (das ist dein Treatment), WalkingDistance_m


%% 1) Normalität pro Treatment (gregarious)
isGreg = WalkingLong.phase == "gregarious";
WG = WalkingLong(isGreg,:);

treatmentsG = categories(WG.treatment);  % alle Treatments
results_norm_greg = table();

for i = 1:numel(treatmentsG)
    tr = treatmentsG{i};
    
    x = WG.WalkingDistance_m(WG.treatment == tr);
    x = x(~isnan(x));
    
    if numel(x) < 3
        h = NaN; p = NaN;
    else
        [h,p] = lillietest(x);
    end
    
    results_norm_greg = [results_norm_greg; ...
        table(string(tr), numel(x), h, p, ...
        'VariableNames', {'Treatment','N','H_rejectNormal','p_value'})];
end

disp('Normalitätstest (Lilliefors) – gregarious:');
disp(results_norm_greg);


%% 1b) Normalität pro Treatment (solitarious)
isSoli = WalkingLong.phase == "solitarious";
WS = WalkingLong(isSoli,:);

treatmentsS = categories(WS.treatment);
results_norm_soli = table();

for i = 1:numel(treatmentsS)
    tr = treatmentsS{i};
    x = WS.WalkingDistance_m(WS.treatment == tr);
    x = x(~isnan(x));
    
    if numel(x) < 3
        h = NaN; p = NaN;
    else
        [h,p] = lillietest(x);
    end
    
    results_norm_soli = [results_norm_soli; ...
        table(string(tr), numel(x), h, p, ...
        'VariableNames', {'Treatment','N','H_rejectNormal','p_value'})];
end

disp('Normalitätstest (Lilliefors) – solitarious:');
disp(results_norm_soli);


%% 2a) One-way ANOVA für gregarious
[p_greg, tbl_greg, stats_greg] = anova1(WG.WalkingDistance_m, WG.treatment, 'off');


%% 2b) One-way ANOVA für solitarious
[p_soli, tbl_soli, stats_soli] = anova1(WS.WalkingDistance_m, WS.treatment, 'off');


%% 2c) Robuste Alternative: Kruskal-Wallis für gregarious
[p_kw_greg, tbl_kw_greg, stats_kw_greg] = kruskalwallis( ...
    WG.WalkingDistance_m, WG.treatment, 'off');

%% 2d) Robuste Alternative: Kruskal-Wallis für solitarious
[p_kw_soli, tbl_kw_soli, stats_kw_soli] = kruskalwallis( ...
    WS.WalkingDistance_m, WS.treatment, 'off');

% Optional: p-Werte kurz anzeigen
disp('One-way ANOVA p_greg (WalkingDistance):');
disp(p_greg);
disp('Kruskal-Wallis p_kw_greg (WalkingDistance):');
disp(p_kw_greg);

disp('One-way ANOVA p_soli (WalkingDistance):');
disp(p_soli);
disp('Kruskal-Wallis p_kw_soli (WalkingDistance):');
disp(p_kw_soli);

%% 3) BOXPLOT: WalkingDistance_m BY PHASE X TRREATMENT

% 1) Gruppennamen Phase_Treatment mit gewünschter Reihenfolge
groupLabels = strcat(string(WalkingLong.phase), "_", string(WalkingLong.treatment));
groupLabels = categorical(groupLabels);

order = [ ...
    "gregarious_control_untreated", ...
    "gregarious_control_locust_saline", ...
    "gregarious_methoprene", ...
    "gregarious_control_DMSO", ...
    "gregarious_precocene_II", ...
    "solitarious_control_locust_saline", ...
    "solitarious_methoprene", ...
    "solitarious_control_DMSO", ...
    "solitarious_precocene_II"];

existing = categories(groupLabels);
orderUsed = intersect(order, existing, 'stable');
groupLabels = reordercats(groupLabels, orderUsed);

% 2) Boxplot der Rohdaten
figure;
boxplot(WalkingLong.WalkingDistance_m, groupLabels);
xtickangle(45);
ylabel('Walking Distance [m]');
title('Walking Distance by Phase and Treatment');
grid on;

% 3) n je Gruppe über die Boxen schreiben
summaryStruct = groupsummary(table(groupLabels), "groupLabels");

% Box-Objekte holen und nur gültige Handles behalten
hBoxes = findobj(gca, 'Tag', 'Box');
hBoxes = hBoxes(isvalid(hBoxes));          % ungültige/gelöschte Objekte filtern [web:39][web:54]

% Wenn keine Boxen gefunden wurden, abbrechen
if isempty(hBoxes)
    warning('Keine Boxen gefunden – n-Labels werden nicht gesetzt.');
else
    % Reihenfolge der Boxen anhand der X-Position sortieren
    xCenters = arrayfun(@(h) mean(get(h,'XData')), hBoxes);
    [~, orderBoxes] = sort(xCenters);
    hBoxes = hBoxes(orderBoxes);

    % y-Position für n-Labels
    yMax = max(WalkingLong.WalkingDistance_m);

    hold on;
    for i = 1:numel(hBoxes)
        text(i, yMax + 0.5, ...      % hier kannst du den Abstand nach Bedarf anpassen
            ['n = ' num2str(summaryStruct.GroupCount(i))], ...
            'HorizontalAlignment', 'center', 'FontSize', 9);
    end
end


% 4) Mittelwerte pro Gruppe (nach groupLabels-Reihenfolge)
T = table(groupLabels, WalkingLong.WalkingDistance_m, ...
          'VariableNames', {'group','dist'});
statsWD = groupsummary(T, "group", "mean", "dist");  % statsWD.group ist categorical

% statsWD.group als string, um Reihenfolge mit orderUsed abzugleichen
statsGroupsStr = string(statsWD.group);

% Mittelwerte in der gewünschten Plot-Reihenfolge (orderUsed)
[~, idxStats] = ismember(orderUsed, statsGroupsStr);
meanDist = statsWD.mean_dist(idxStats);   % 1–5 greg, 6–9 soli in deiner Treatment-Reihenfolge

% 5) Innerhalb jeder Phase nach Distanz sortieren, um Helligkeit zuzuweisen

% gregarious: Index 1–5
meanGreg = meanDist(1:5);
[sortedGreg, orderGreg] = sort(meanGreg);   % sortedGreg(1) = kleinste Distanz

% solitarious: Index 6–9
meanSoli = meanDist(6:9);
[sortedSoli, orderSoli] = sort(meanSoli);

% Skaliere auf 0..1 (0 = hell, 1 = dunkel) pro Phase
scaleGregSorted = (sortedGreg - min(sortedGreg)) ./ max(max(sortedGreg) - min(sortedGreg), eps);
scaleSoliSorted = (sortedSoli - min(sortedSoli)) ./ max(max(sortedSoli) - min(sortedSoli), eps);

% Auf ursprüngliche Reihenfolge der 5/4 Boxen zurückabbilden
scaleGreg = zeros(1,5);
scaleSoli = zeros(1,4);
scaleGreg(orderGreg) = scaleGregSorted;
scaleSoli(orderSoli) = scaleSoliSorted;

% 6) Grundfarben
baseGregLight = [0.80, 0.93, 0.80];
baseGregDark  = [0.10, 0.50, 0.10];

baseSoliLight = [0.92, 0.86, 0.94];
baseSoliDark  = [0.45, 0.20, 0.60];

interpColor = @(light,dark,alpha) light + alpha .* (dark - light);

% 7) Boxen einfärben: 1–5 gregarious (Grün-Abstufungen), 6–9 solitarious (Violett-Abstufungen)
nBoxes = min(length(hBoxes), numel(meanDist));

for i = 1:nBoxes
    x = get(hBoxes(i), 'XData');
    y = get(hBoxes(i), 'YData');

    if i <= 5
        alpha = scaleGreg(i);          % kleinste Distanz → kleinster alpha → hellstes Grün
        col = interpColor(baseGregLight, baseGregDark, alpha);
    else
        alpha = scaleSoli(i-5);        % kleinste Distanz → hellstes Violett
        col = interpColor(baseSoliLight, baseSoliDark, alpha);
    end

    fill(x, y, col, 'FaceAlpha', 0.9, 'EdgeColor', 'none');
end

% 8) Median-Linien dunkler und dicker machen
med = findobj(gca, 'Tag', 'Median');
set(med, 'Color', [0.1 0.1 0.1], 'LineWidth', 2.0);   % dunkelgrau, dicker

% 9) Box-Ränder weiß und etwas dicker lassen
boxline = findobj(gca, 'Tag', 'Box');
set(boxline, 'Color', 'white', 'LineWidth', 1.0);


%% 4) Zwei-Stichproben-t-Tests: gregarious vs solitarious je Treatment

treatmentsAll = intersect( ...
    categories(WalkingLong.treatment(WalkingLong.phase=="gregarious")), ...
    categories(WalkingLong.treatment(WalkingLong.phase=="solitarious")) );

results_ttest = table();

for i = 1:numel(treatmentsAll)
    tr = treatmentsAll{i};

    % Daten für dieses Treatment, getrennt nach Phase
    x = WalkingLong.WalkingDistance_m( ...
        WalkingLong.phase=="gregarious" & WalkingLong.treatment==tr);
    y = WalkingLong.WalkingDistance_m( ...
        WalkingLong.phase=="solitarious" & WalkingLong.treatment==tr);

    % NaN entfernen
    x = x(~isnan(x));
    y = y(~isnan(y));

    % Wenn in einer Gruppe weniger als 2 Tiere: Test überspringen
    if numel(x) < 2 || numel(y) < 2
        continue;
    end

    % Welch-Zwei-Stichproben-t-Test (ungleiche Varianzen erlaubt)
    [h,p,ci,stats] = ttest2(x, y, 'Vartype','unequal');

    % Ergebniszeile anhängen
    results_ttest = [results_ttest; ...
        table(string(tr), numel(x), numel(y), h, p, stats.tstat, stats.df, ...
        'VariableNames', {'Treatment','N_greg','N_soli', ...
                          'H_rejectEqualMeans','p_value','t_stat','df'})];
end

disp('T-Test: gregarious vs solitarious je Treatment');
disp(results_ttest);


%% 5) Gezielte Paarvergleiche: Wirkstoff vs. Kontrolle (WalkingDistance)

pairs = {
    'control_locust_saline', 'methoprene';    % Kontrolle, Wirkstoff
    'control_DMSO',          'precocene_II'
};

phases = {'gregarious','solitarious'};

results_WD_pairs_ttest   = table();
results_WD_pairs_ranksum = table();

for ip = 1:numel(phases)
    thisPhase = phases{ip};

    for k = 1:size(pairs,1)
        ctrl = pairs{k,1};
        drug = pairs{k,2};

        % Daten aus WalkingLong filtern
        x = WalkingLong.WalkingDistance_m( ...
                WalkingLong.phase == thisPhase & ...
                WalkingLong.treatment == ctrl);

        y = WalkingLong.WalkingDistance_m( ...
                WalkingLong.phase == thisPhase & ...
                WalkingLong.treatment == drug);

        x = x(~isnan(x));
        y = y(~isnan(y));

        if numel(x) < 2 || numel(y) < 2
            continue;   % zu wenig Tiere
        end

        % Welch-Zwei-Stichproben-t-Test (Mittelwerte)
        [h_t, p_t, ~, stats_t] = ttest2(x, y, 'Vartype','unequal');

        % Mann-Whitney-U-Test (nichtparametrisch)
        p_rs = ranksum(x, y);   % vergleicht die Ränge/Mediane [web:97][web:101]

        % Ergebnisse t-Test
        results_WD_pairs_ttest = [results_WD_pairs_ttest; ...
            table(string(thisPhase), string(ctrl), string(drug), ...
                  numel(x), numel(y), h_t, p_t, stats_t.tstat, stats_t.df, ...
            'VariableNames', {'Phase','Control','Drug', ...
                              'N_control','N_drug', ...
                              'H_rejectEqualMeans','p_value_t','t_stat','df'})];

        % Ergebnisse Mann-Whitney-U
        results_WD_pairs_ranksum = [results_WD_pairs_ranksum; ...
            table(string(thisPhase), string(ctrl), string(drug), ...
                  numel(x), numel(y), p_rs, ...
            'VariableNames', {'Phase','Control','Drug', ...
                              'N_control','N_drug','p_value_ranksum'})];
    end
end

disp('Paarvergleiche WalkingDistance: Wirkstoff vs. Kontrolle (t-Test):');
disp(results_WD_pairs_ttest);
disp('Paarvergleiche WalkingDistance: Wirkstoff vs. Kontrolle (Mann-Whitney-U):');
disp(results_WD_pairs_ranksum);
