%% SKRIPT STATISTISCHE AUSWERTUNG PREFERENCE INDEX

set(groot, 'DefaultFigureColor', 'w', ...  % Plots haben weißen Hintergrund
           'DefaultAxesColor',  'w');

%% 1) EINFACHER PI (links vs rechts)

% Annahme: ArenaAnalysis02_plotting.m wurde ausgeführt
% und PoolData enthält: animal, phase, feedingstate, PI (einfacher PI)

PIvar = 'PI';   % einfacher Preference Index über die gesamte Arena

% 1) Analyse-Tabelle für PI neu aufbauen
PI_long = table( ...
    string(PoolData.animal), ...
    string(PoolData.phase), ...
    string(PoolData.feedingstate), ...
    PoolData.(PIvar), ...
    'VariableNames', {'animal','phase','treatment','PI'});

%{
disp('Daten für einfachen PI (alle Tiere):');  % Daten werden im Command-Window angezeigt
disp(PI_long);
%}

% Typen setzen
PI_long.animal    = categorical(PI_long.animal);
PI_long.phase     = categorical(PI_long.phase);
PI_long.treatment = categorical(PI_long.treatment);

% NaN-PIs entfernen
PI_long = PI_long(~isnan(PI_long.PI), :);


%% 1b) Normalität pro Treatment (einfacher PI) – gregarious
isGreg_PI = PI_long.phase == "gregarious";
PG = PI_long(isGreg_PI,:);
treatmentsG_PI = categories(PG.treatment);
results_norm_PI_greg = table();

for i = 1:numel(treatmentsG_PI)
    tr = treatmentsG_PI{i};
    x = PG.PI(PG.treatment == tr);
    x = x(~isnan(x));

    if numel(x) < 3
        h = NaN; p = NaN;
    else
        [h,p] = lillietest(x);
    end

    results_norm_PI_greg = [results_norm_PI_greg; ...
        table(string(tr), numel(x), h, p, ...
        'VariableNames', {'Treatment','N','H_rejectNormal','p_value'})];
end

disp('Normalitätstest (Lilliefors) – einfacher PI, gregarious:');
disp(results_norm_PI_greg);

%% 1c) Normalität pro Treatment – solitarious
isSoli_PI = PI_long.phase == "solitarious";
PS = PI_long(isSoli_PI,:);
treatmentsS_PI = categories(PS.treatment);
results_norm_PI_soli = table();

for i = 1:numel(treatmentsS_PI)
    tr = treatmentsS_PI{i};
    x = PS.PI(PS.treatment == tr);
    x = x(~isnan(x));

    if numel(x) < 3
        h = NaN; p = NaN;
    else
        [h,p] = lillietest(x);
    end

    results_norm_PI_soli = [results_norm_PI_soli; ...
        table(string(tr), numel(x), h, p, ...
        'VariableNames', {'Treatment','N','H_rejectNormal','p_value'})];
end

disp('Normalitätstest (Lilliefors) – einfacher PI, solitarious:');
disp(results_norm_PI_soli);


%% 2) One-way ANOVA für einfachen PI je Phase

% gregarious
isGreg_PI = PI_long.phase == "gregarious";
PG = PI_long(isGreg_PI,:);
disp('Einfacher PI – gregarious:');
disp(PG);

[p_PI_greg, tbl_PI_greg, stats_PI_greg] = anova1(PG.PI, PG.treatment, 'off');

% solitarious
isSoli_PI = PI_long.phase == "solitarious";
PS = PI_long(isSoli_PI,:);
disp('Einfacher PI – solitarious:');
disp(PS);

[p_PI_soli, tbl_PI_soli, stats_PI_soli] = anova1(PS.PI, PS.treatment, 'off');

disp('ANOVA einfacher PI (gregarious): p ='); disp(p_PI_greg);
disp('ANOVA einfacher PI (solitarious): p ='); disp(p_PI_soli);


%% 2c) Robuste Alternative: Kruskal-Wallis für einfachen PI je Phase

% gregarious: Kruskal-Wallis-Test
[p_kw_PI_greg, tbl_kw_PI_greg, stats_kw_PI_greg] = kruskalwallis( ...
    PG.PI, PG.treatment, 'off');

% solitarious: Kruskal-Wallis-Test
[p_kw_PI_soli, tbl_kw_PI_soli, stats_kw_PI_soli] = kruskalwallis( ...
    PS.PI, PS.treatment, 'off');

disp('Kruskal-Wallis einfacher PI (gregarious): p =');  disp(p_kw_PI_greg);
disp('Kruskal-Wallis einfacher PI (solitarious): p ='); disp(p_kw_PI_soli);


%% 3) Zwei-Stichproben-t-Tests: einfacher PI gregarious vs solitarious je Treatment

treatmentsAll_PI = intersect( ...
    categories(PI_long.treatment(PI_long.phase=="gregarious")), ...
    categories(PI_long.treatment(PI_long.phase=="solitarious")) );

results_ttest_PI = table();

for i = 1:numel(treatmentsAll_PI)
    tr = treatmentsAll_PI{i};

    x = PI_long.PI(PI_long.phase=="gregarious" & PI_long.treatment==tr);
    y = PI_long.PI(PI_long.phase=="solitarious" & PI_long.treatment==tr);

    x = x(~isnan(x));
    y = y(~isnan(y));

    if numel(x) < 2 || numel(y) < 2
        continue;
    end

    [h,p,ci,stats] = ttest2(x, y, 'Vartype','unequal');

    results_ttest_PI = [results_ttest_PI; ...
        table(string(tr), numel(x), numel(y), h, p, stats.tstat, stats.df, ...
        'VariableNames', {'Treatment','N_greg','N_soli', ...
                          'H_rejectEqualMeans','p_value','t_stat','df'})];
end

disp('T-Test einfacher PI: gregarious vs solitarious je Treatment');
disp(results_ttest_PI);


%% 4) Boxplot einfacher PI nach Phase x Treatment mit Farb-Abstufungen

% Gruppenlabel Phase_Treatment
groupLabels = strcat(string(PI_long.phase), "_", string(PI_long.treatment));
groupLabels = categorical(groupLabels);

% Gewünschte Reihenfolge von links nach rechts
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

figure;
boxplot(PI_long.PI, groupLabels);
ylim([-1.05, 1.10]);   % symmetrische Skala
xtickangle(45);
ylabel(['Preference Index (' PIvar ')']);
title(['Preference Index (left vs right) by Phase and Treatment']);
grid on;

% n je Gruppe
summaryStruct = groupsummary(table(groupLabels), "groupLabels");

hBoxes = findobj(gca, 'Tag', 'Box');
xCenters = arrayfun(@(h) mean(get(h,'XData')), hBoxes);
[~, orderBoxes] = sort(xCenters);
hBoxes = hBoxes(orderBoxes);

hold on;
for i = 1:length(hBoxes)
    text(i, max(PI_long.PI)+0.02, ...
        ['n = ' num2str(summaryStruct.GroupCount(i))], ...
        'HorizontalAlignment', 'center', 'FontSize', 9);
end

% Mittelwerte pro Gruppe für Farb-Abstufung
T_PI = table(groupLabels, PI_long.PI, 'VariableNames', {'group','PI'});
statsPI = groupsummary(T_PI, "group", "mean", "PI");
statsGroupsStr = string(statsPI.group);
[~, idxStats] = ismember(orderUsed, statsGroupsStr);
meanPI = statsPI.mean_PI(idxStats);

% gregarious 1–5, solitarious 6–9
meanGregPI = meanPI(1:5);
meanSoliPI = meanPI(6:9);

[sortedGregPI, orderGregPI] = sort(meanGregPI);
[sortedSoliPI,  orderSoliPI] = sort(meanSoliPI);

scaleGregSortedPI = (sortedGregPI - min(sortedGregPI)) ./ max(max(sortedGregPI) - min(sortedGregPI), eps);
scaleSoliSortedPI = (sortedSoliPI  - min(sortedSoliPI))  ./ max(max(sortedSoliPI)  - min(sortedSoliPI),  eps);

scaleGregPI = zeros(1,5);
scaleSoliPI = zeros(1,4);
scaleGregPI(orderGregPI) = scaleGregSortedPI;
scaleSoliPI(orderSoliPI) = scaleSoliSortedPI;

baseGregLight = [0.80, 0.93, 0.80];
baseGregDark  = [0.10, 0.50, 0.10];
baseSoliLight = [0.92, 0.86, 0.94];
baseSoliDark  = [0.45, 0.20, 0.60];

interpColor = @(light,dark,alpha) light + alpha .* (dark - light);

nBoxes = min(length(hBoxes), numel(meanPI));

for i = 1:nBoxes
    x = get(hBoxes(i), 'XData');
    y = get(hBoxes(i), 'YData');

    if i <= 5
        alpha = scaleGregPI(i);      % kleinste PI-Distanz -> hellstes Grün
        col = interpColor(baseGregLight, baseGregDark, alpha);
    else
        alpha = scaleSoliPI(i-5);    % kleinste PI-Distanz -> hellstes Violett
        col = interpColor(baseSoliLight, baseSoliDark, alpha);
    end

    fill(x, y, col, 'FaceAlpha', 0.9, 'EdgeColor', 'none');
end

% Median-Linien deutlicher
med = findobj(gca, 'Tag', 'Median');
set(med, 'Color', [0.1 0.1 0.1], 'LineWidth', 2.0);

% Box-Ränder
boxline = findobj(gca, 'Tag', 'Box');
set(boxline, 'Color', 'white', 'LineWidth', 1);

hold off;

%% 5) Ergebnisse als CSV in Downloads speichern

% Pfad zum Downloads-Ordner (macOS & andere Unix-Systeme)
homeDir      = getenv('HOME');                               % z.B. /Users/laurinebaier [web:28]
downloadsDir = fullfile(homeDir, 'Downloads');

% Falls du sicherstellen willst, dass der Ordner existiert:
if ~exist(downloadsDir, 'dir')
    mkdir(downloadsDir);
end

% 1) Lange PI-Tabelle (alle Tiere)
file_PI_long = fullfile(downloadsDir, 'PI_simple_all_animals.csv');
writetable(PI_long, file_PI_long);                           % schreibt als klassische CSV [web:19][web:32]

% 2) Normalitätstests
file_norm_greg = fullfile(downloadsDir, 'PI_simple_normality_gregarious.csv');
file_norm_soli = fullfile(downloadsDir, 'PI_simple_normality_solitarious.csv');
writetable(results_norm_PI_greg, file_norm_greg);
writetable(results_norm_PI_soli, file_norm_soli);

% 3) ANOVA-Tabellen (optional: aus cell-Array in Table umwandeln)
tbl_ANOVA_greg = cell2table(tbl_PI_greg(2:end,:), ...
    'VariableNames', string(tbl_PI_greg(1,:)));
tbl_ANOVA_soli = cell2table(tbl_PI_soli(2:end,:), ...
    'VariableNames', string(tbl_PI_soli(1,:)));

file_anova_greg = fullfile(downloadsDir, 'PI_simple_ANOVA_gregarious.csv');
file_anova_soli = fullfile(downloadsDir, 'PI_simple_ANOVA_solitarious.csv');
writetable(tbl_ANOVA_greg, file_anova_greg);
writetable(tbl_ANOVA_soli, file_anova_soli);

% 4) Kruskal-Wallis-Tabellen (falls du sie speichern willst)
tbl_KW_greg = cell2table(tbl_kw_PI_greg(2:end,:), ...
    'VariableNames', string(tbl_kw_PI_greg(1,:)));
tbl_KW_soli = cell2table(tbl_kw_PI_soli(2:end,:), ...
    'VariableNames', string(tbl_kw_PI_soli(1,:)));

file_kw_greg = fullfile(downloadsDir, 'PI_simple_KW_gregarious.csv');
file_kw_soli = fullfile(downloadsDir, 'PI_simple_KW_solitarious.csv');
writetable(tbl_KW_greg, file_kw_greg);
writetable(tbl_KW_soli, file_kw_soli);

% 5) t-Test-Ergebnisse
file_ttest = fullfile(downloadsDir, 'PI_simple_ttest_greg_vs_soli.csv');
writetable(results_ttest_PI, file_ttest);

disp('CSV-Dateien für einfachen PI wurden im Downloads-Ordner gespeichert.');
