%% SKRIPT STATISTISCHE AUSWERTUNG PI15to15

set(groot, 'DefaultFigureColor', 'w', ...
           'DefaultAxesColor',  'w');

% Annahme: ArenaAnalysis02_plotting.m wurde ausgeführt
% und PoolData enthält: animal, phase, feedingstate, PI15to15

PIvar = 'PI15to15';   % PI im ROI um die Shelter

% 1) Analyse-Tabelle für PI15to15 neu aufbauen
PI15_long = table( ...
    string(PoolData.animal), ...
    string(PoolData.phase), ...
    string(PoolData.feedingstate), ...
    PoolData.(PIvar), ...
    'VariableNames', {'animal','phase','treatment','PI'});

PI15_long.animal    = categorical(PI15_long.animal);
PI15_long.phase     = categorical(PI15_long.phase);
PI15_long.treatment = categorical(PI15_long.treatment);

PI15_long = PI15_long(~isnan(PI15_long.PI), :);


%% 1) Normalität pro Treatment (PI15to15) – gregarious
isGreg_PI15 = PI15_long.phase == "gregarious";
PG15 = PI15_long(isGreg_PI15,:);
treatmentsG_PI15 = categories(PG15.treatment);
results_norm_PI15_greg = table();

for i = 1:numel(treatmentsG_PI15)
    tr = treatmentsG_PI15{i};
    x = PG15.PI(PG15.treatment == tr);
    x = x(~isnan(x));

    if numel(x) < 3
        h = NaN; p = NaN;
    else
        [h,p] = lillietest(x);
    end

    results_norm_PI15_greg = [results_norm_PI15_greg; ...
        table(string(tr), numel(x), h, p, ...
        'VariableNames', {'Treatment','N','H_rejectNormal','p_value'})];
end

disp('Normalitätstest (Lilliefors) – PI15to15, gregarious:');
disp(results_norm_PI15_greg);

%% 1b) Normalität pro Treatment – solitarious
isSoli_PI15 = PI15_long.phase == "solitarious";
PS15 = PI15_long(isSoli_PI15,:);
treatmentsS_PI15 = categories(PS15.treatment);
results_norm_PI15_soli = table();

for i = 1:numel(treatmentsS_PI15)
    tr = treatmentsS_PI15{i};
    x = PS15.PI(PS15.treatment == tr);
    x = x(~isnan(x));

    if numel(x) < 3
        h = NaN; p = NaN;
    else
        [h,p] = lillietest(x);
    end

    results_norm_PI15_soli = [results_norm_PI15_soli; ...
        table(string(tr), numel(x), h, p, ...
        'VariableNames', {'Treatment','N','H_rejectNormal','p_value'})];
end

disp('Normalitätstest (Lilliefors) – PI15to15, solitarious:');
disp(results_norm_PI15_soli);


%% 2) One-way ANOVA für PI15to15 je Phase

isGreg_PI15 = PI15_long.phase == "gregarious";
PG15 = PI15_long(isGreg_PI15,:);
disp('PI15to15 – gregarious:');
disp(PG15);

[p_PI15_greg, tbl_PI15_greg, stats_PI15_greg] = anova1(PG15.PI, PG15.treatment, 'off');

isSoli_PI15 = PI15_long.phase == "solitarious";
PS15 = PI15_long(isSoli_PI15,:);
disp('PI15to15 – solitarious:');
disp(PS15);

[p_PI15_soli, tbl_PI15_soli, stats_PI15_soli] = anova1(PS15.PI, PS15.treatment, 'off');

disp('ANOVA PI15to15 (gregarious): p =');  disp(p_PI15_greg);
disp('ANOVA PI15to15 (solitarious): p ='); disp(p_PI15_soli);


%% 2c) Robuste Alternative: Kruskal-Wallis für PI15to15 je Phase

% gregarious: Kruskal-Wallis-Test
[p_kw_PI15_greg, tbl_kw_PI15_greg, stats_kw_PI15_greg] = kruskalwallis( ...
    PG15.PI, PG15.treatment, 'off');

% solitarious: Kruskal-Wallis-Test
[p_kw_PI15_soli, tbl_kw_PI15_soli, stats_kw_PI15_soli] = kruskalwallis( ...
    PS15.PI, PS15.treatment, 'off');

disp('Kruskal-Wallis PI15to15 (gregarious): p =');  disp(p_kw_PI15_greg);
disp('Kruskal-Wallis PI15to15 (solitarious): p ='); disp(p_kw_PI15_soli);


%% 3) Zwei-Stichproben-t-Tests: PI15to15 gregarious vs solitarious je Treatment

treatmentsAll_PI15 = intersect( ...
    categories(PI15_long.treatment(PI15_long.phase=="gregarious")), ...
    categories(PI15_long.treatment(PI15_long.phase=="solitarious")) );

results_ttest_PI15 = table();

for i = 1:numel(treatmentsAll_PI15)
    tr = treatmentsAll_PI15{i};

    x = PI15_long.PI(PI15_long.phase=="gregarious" & PI15_long.treatment==tr);
    y = PI15_long.PI(PI15_long.phase=="solitarious" & PI15_long.treatment==tr);

    x = x(~isnan(x));
    y = y(~isnan(y));

    if numel(x) < 2 || numel(y) < 2
        continue;
    end

    [h,p,ci,stats] = ttest2(x, y, 'Vartype','unequal');

    results_ttest_PI15 = [results_ttest_PI15; ...
        table(string(tr), numel(x), numel(y), h, p, stats.tstat, stats.df, ...
        'VariableNames', {'Treatment','N_greg','N_soli', ...
                          'H_rejectEqualMeans','p_value','t_stat','df'})];
end

disp('T-Test PI15to15: gregarious vs solitarious je Treatment');
disp(results_ttest_PI15);

%% 4) Boxplot PI15to15 nach Phase x Treatment mit Farb-Abstufungen

groupLabels = strcat(string(PI15_long.phase), "_", string(PI15_long.treatment));
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

figure;
boxplot(PI15_long.PI, groupLabels);
ylim([-1.05, 1.10]);
xtickangle(45);
ylabel(['Preference Index (' PIvar ')']);
title('PI15to15 by Phase and Treatment');
grid on;

% n je Gruppe
summaryStruct = groupsummary(table(groupLabels), "groupLabels");

hBoxes = findobj(gca, 'Tag', 'Box');
xCenters = arrayfun(@(h) mean(get(h,'XData')), hBoxes);
[~, orderBoxes] = sort(xCenters);
hBoxes = hBoxes(orderBoxes);

hold on;
for i = 1:length(hBoxes)
    text(i, max(PI15_long.PI)+0.05, ...
        ['n = ' num2str(summaryStruct.GroupCount(i))], ...
        'HorizontalAlignment', 'center', 'FontSize', 9);
end

% Mittelwerte pro Gruppe für Farb-Abstufung
T_PI15 = table(groupLabels, PI15_long.PI, 'VariableNames', {'group','PI'});
statsPI15 = groupsummary(T_PI15, "group", "mean", "PI");
statsGroupsStr = string(statsPI15.group);
[~, idxStats] = ismember(orderUsed, statsGroupsStr);
meanPI15 = statsPI15.mean_PI(idxStats);

% gregarious 1–5, solitarious 6–9
meanGregPI15 = meanPI15(1:5);
meanSoliPI15 = meanPI15(6:9);

[sortedGregPI15, orderGregPI15] = sort(meanGregPI15);
[sortedSoliPI15, orderSoliPI15] = sort(meanSoliPI15);

scaleGregSortedPI15 = (sortedGregPI15 - min(sortedGregPI15)) ./ max(max(sortedGregPI15) - min(sortedGregPI15), eps);
scaleSoliSortedPI15 = (sortedSoliPI15 - min(sortedSoliPI15)) ./ max(max(sortedSoliPI15) - min(sortedSoliPI15), eps);

scaleGregPI15 = zeros(1,5);
scaleSoliPI15 = zeros(1,4);
scaleGregPI15(orderGregPI15) = scaleGregSortedPI15;
scaleSoliPI15(orderSoliPI15) = scaleSoliSortedPI15;

baseGregLight = [0.80, 0.93, 0.80];
baseGregDark  = [0.10, 0.50, 0.10];
baseSoliLight = [0.92, 0.86, 0.94];
baseSoliDark  = [0.45, 0.20, 0.60];

interpColor = @(light,dark,alpha) light + alpha .* (dark - light);

nBoxes = min(length(hBoxes), numel(meanPI15));

for i = 1:nBoxes
    x = get(hBoxes(i), 'XData');
    y = get(hBoxes(i), 'YData');

    if i <= 5
        alpha = scaleGregPI15(i);
        col = interpColor(baseGregLight, baseGregDark, alpha);
    else
        alpha = scaleSoliPI15(i-5);
        col = interpColor(baseSoliLight, baseSoliDark, alpha);
    end

    fill(x, y, col, 'FaceAlpha', 0.9, 'EdgeColor', 'none');
end

med = findobj(gca, 'Tag', 'Median');
set(med, 'Color', [0.1 0.1 0.1], 'LineWidth', 2.0);

boxline = findobj(gca, 'Tag', 'Box');
set(boxline, 'Color', 'white', 'LineWidth', 1);

hold off;


%% 5) Gezielte Paarvergleiche: Wirkstoff vs. Kontrolle (PI15to15)

pairs = {
    'control_locust_saline', 'methoprene';    % Kontrolle, Wirkstoff
    'control_DMSO',          'precocene_II'
};

phases = {'gregarious','solitarious'};

results_pairs_ttest   = table();
results_pairs_ranksum = table();

for ip = 1:numel(phases)
    thisPhase = phases{ip};

    for k = 1:size(pairs,1)
        ctrl = pairs{k,1};
        drug = pairs{k,2};

        % Daten filtern
        x = PI_long.PI( PI_long.phase == thisPhase & PI_long.treatment == ctrl );
        y = PI_long.PI( PI_long.phase == thisPhase & PI_long.treatment == drug );

        x = x(~isnan(x));
        y = y(~isnan(y));

        if numel(x) < 2 || numel(y) < 2
            continue;   % zu wenig Tiere
        end

        % Welch-Zwei-Stichproben-t-Test (Mittelwertvergleich)
        [h_t, p_t, ~, stats_t] = ttest2(x, y, 'Vartype','unequal');

        % Mann-Whitney-U-Test (ranksum, Vergleich der Ränge/Mediane)
        p_rs = ranksum(x, y);   % nichtparametrischer Test [web:97][web:100]

        % Ergebnisse t-Test
        results_pairs_ttest = [results_pairs_ttest; ...
            table(string(thisPhase), string(ctrl), string(drug), ...
                  numel(x), numel(y), h_t, p_t, stats_t.tstat, stats_t.df, ...
            'VariableNames', {'Phase','Control','Drug', ...
                              'N_control','N_drug', ...
                              'H_rejectEqualMeans','p_value_t','t_stat','df'})];

        % Ergebnisse Mann-Whitney-U
        results_pairs_ranksum = [results_pairs_ranksum; ...
            table(string(thisPhase), string(ctrl), string(drug), ...
                  numel(x), numel(y), p_rs, ...
            'VariableNames', {'Phase','Control','Drug', ...
                              'N_control','N_drug','p_value_ranksum'})];
    end
end

disp('Paarvergleiche PI15to15: Wirkstoff vs. Kontrolle (t-Test):');
disp(results_pairs_ttest);
disp('Paarvergleiche PI15to15: Wirkstoff vs. Kontrolle (Mann-Whitney-U):');
disp(results_pairs_ranksum);
