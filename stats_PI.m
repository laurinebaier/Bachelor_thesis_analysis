%% SKRIPT STATISTISCHE AUSWERTUNG PREFERENCE INDEX

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

% Typen setzen
PI_long.animal    = categorical(PI_long.animal);
PI_long.phase     = categorical(PI_long.phase);
PI_long.treatment = categorical(PI_long.treatment);

% NaN-PIs entfernen
PI_long = PI_long(~isnan(PI_long.PI), :);


%% 2) One-way ANOVA für einfachen PI je Phase

% gregarious
isGreg_PI = PI_long.phase == "gregarious";
PG = PI_long(isGreg_PI,:);

[p_PI_greg, tbl_PI_greg, stats_PI_greg] = anova1(PG.PI, PG.treatment, 'off');

% solitarious
isSoli_PI = PI_long.phase == "solitarious";
PS = PI_long(isSoli_PI,:);

[p_PI_soli, tbl_PI_soli, stats_PI_soli] = anova1(PS.PI, PS.treatment, 'off');

disp('ANOVA einfacher PI (gregarious): p ='); disp(p_PI_greg);
disp('ANOVA einfacher PI (solitarious): p ='); disp(p_PI_soli);


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
    text(i, max(PI_long.PI)+0.05, ...
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
