%% Arena data plotting :)
%   This code generates various plots based on the collected PIs to
%   compare solitarious and gegarious locusts, and starved and fed locusts. 
%    you can choose between the different PIs:
%      - PI: left or right half of the arena
%      - PI15: Frames(stimulusROI)/total frames
%      - PI15by15: (Frames(stimulusROI)-Framese(controlROI))/(Frames(stimulusROI)+Framese(controlROI))
%      - mean distance PI: (mean_dis(empty shelter) - mean_dis(greg shelter)/(mean_dis(empty shelter) + mean_dis(greg shelter))

clear, close all
%% Settings

% Add toolboxes
% --- A MATLAB toolbox for exporting publication quality figures
%     (https://github.com/altmany/export_fig)
addpath(genpath('C:/Users/Nina/Documents/GitHub/export_fig'))
addpath(genpath('C:\Program Files\gs\gs10.05.1'))
setenv('PATH', [getenv('PATH') ';C:\Program Files\gs\gs10.05.1\bin']);


% specify which parameteres you interested in:
SET.PI = 'PI15to15';  % choose PI: 'PI', 'PI15', 'PI15to15' or 'mean_dis_PI'
SET.feeding = {'control_locust_saline','methoprene', 'control_DMSO', 'precocene_II', 'control_untreated'}; % Define youre conditions (must be identical to the condition names in your folder structure)
SET.shelter = {''}; % leave empty, filter used for ninas data
SET.mindist = 0.1 ; % [m] set the minimum walking distance an animal has to walk to be counted
SET.maxdist = 200 ; % [m] set the maximum walking distance an animal has to walk to be excluded
SET.phase = {'gregarious', 'solitarious'};
SET.conditions = {''};

SET.cols = [ ...
    % 5 violette Töne für gregarious
    0.463, 0.165, 0.514; ...
    0.55,  0.25,  0.60;  ...
    0.63,  0.35,  0.70;  ...
    0.70,  0.45,  0.78;  ...
    0.80,  0.55,  0.86;  ...
    % 4 grüne Töne für solitarious
    0.106, 0.471, 0.216; ...
    0.25,  0.60,  0.30;  ...
    0.40,  0.75,  0.40;  ...
    0.55,  0.85,  0.55];


% load data
load("/Users/laurinebaier/Documents/Uni_Konstanz/bachelorthesis/experiments/01_PI_data.mat");

%% Cosmetic settings
if ismember(SET.PI, ["PI15", "PI"])
    SET.ylim = ([-0.1 1.1]);
elseif ismember(SET.PI,["PI15to15", "mean_dis_PI"])
    SET.ylim =([-1.3 1.3]);
end

SET.cols2 = [ ...
    0.463, 0.165, 0.514; ...
    0.686, 0.553, 0.765; ...
    0.906, 0.831, 0.909; ...
    0.463, 0.165, 0.514; ...
    0.686, 0.553, 0.765; ...
    0.906, 0.831, 0.909; ...
    0.463, 0.165, 0.514; ...
    0.686, 0.553, 0.765; ...
    0.906, 0.831, 0.909; ...
    0.106, 0.471, 0.216; ...
    0.498, 0.749, 0.482; ...
    0.851, 0.941, 0.827;...

    ];

%% Filter data based on settings

% feeding data
temp.idx1 = ismember(PoolData.feedingstate, SET.feeding); %first idx filters for feeding state, excluding 'after' trials performed for a different experiment

% Walking Distance
temp.idx2 = PoolData.WalkingDistance_m > SET.mindist; % apply minimum distance
temp.idx3 = PoolData.WalkingDistance_m < SET.maxdist; % apply maximum distance

% combine all filters
temp.idxcombi = temp.idx1 & temp.idx2 & temp.idx3;


% apply combined filter
filtered.feeding = PoolData.feedingstate(temp.idxcombi);
filtered.PI = PoolData.(SET.PI)(temp.idxcombi);
filtered.dist = PoolData.WalkingDistance_m(temp.idxcombi);
filtered.phase = PoolData.phase(temp.idxcombi);
filtered.condition = PoolData.condition(temp.idxcombi);
filtered.animal = PoolData.animal(temp.idxcombi);

 
%% Plotting

%% 1. simple boxplot for gregarious phase only

% Filter for gregarious phase
gregariousIdx = strcmp(filtered.phase, 'gregarious');
filteredGregarious.PI = filtered.PI(gregariousIdx);
filteredGregarious.dist = filtered.dist(gregariousIdx);
filteredGregarious.feeding = filtered.feeding(gregariousIdx);

% Define the order of treatments
treatmentOrder = {'control_locust_saline', 'methoprene', 'control_untreated', 'control_DMSO', 'precocene_II'};
filteredGregarious.feeding = categorical(filteredGregarious.feeding, treatmentOrder);

figure
% subplot for PI
subplot(1,2,1)
boxplot(filteredGregarious.PI, filteredGregarious.feeding);
%  Add labels and title to the PI boxplot
xlabel('Treatment'); % Feeding State
ylabel('Preference Index (PI)');
title([SET.PI, ' Preference Index by Treatment (Gregarious)']); 


% Subplot for walking distance
subplot(1,2,2)
boxplot(filteredGregarious.dist, filteredGregarious.feeding);
%  Add labels and title to the walking distance boxplot
xlabel('Treatment');
ylabel('Walking Distance [m]');
title('Walking Distance by Treatment (Gregarious)');

%% 2. scatter plot - only works with known animal identities

% Settings
animals = filtered.animal;
feeding = filtered.feeding;

% Only include selected feeding states
isValid = ismember(feeding, SET.feeding);
PI_values = filtered.PI(isValid);
animals = animals(isValid);
feeding = filtered.feeding(isValid);

% Define unique feeding states and assign x positions
[~, ~, stateX] = unique(feeding, 'stable');  % still needed for correct plotting order
xLabels = SET.feeding;
xMap = containers.Map(xLabels, 1:numel(xLabels));

% Get unique animal IDs that appear more than once
uniqueAnimals = unique(animals);

figure
hold on
%set(gcf)
colors = lines(numel(xLabels));  % define as many colors as feeding states

% Loop through animals and connect their points

for i = 1:numel(uniqueAnimals)
    if ~isempty(char(uniqueAnimals(i))) % skip empty
        thisID = uniqueAnimals(i);
        idx = strcmp(animals, thisID);

        if sum(idx) < 2
            continue;  % only connect if tested multiple times
        end

        % Get data
        thisFeeding = feeding(idx);
        thisPIs = PI_values(idx);
        thisX = cellfun(@(s) xMap(s), cellstr(thisFeeding));

        % Sort by x
        [thisX, sortIdx] = sort(thisX);
        thisPIs = thisPIs(sortIdx);

        % Plot connecting line
        plot(thisX, thisPIs, '-o', 'Color', [0.7 0.7 0.7], 'LineWidth', 1);

        % Plot connecting lines in color
        if thisPIs(2) < thisPIs(1)
            plot(thisX, thisPIs, '-o', 'Color', 'red', 'LineWidth', 1.5);
        else
            plot(thisX, thisPIs, '-o', 'Color', 'green', 'LineWidth', 1);
        end%if colored lines


        % Plot connecting lines in color 2nd half
        if length(thisPIs) > 2
            if thisPIs(3) < thisPIs(2)
                plot(thisX(2:3), thisPIs(2:3), '-o', 'Color', 'red', 'LineWidth', 1.5);
            else
                plot(thisX(2:3), thisPIs(2:3), '-o', 'Color', 'green', 'LineWidth', 1);
            end%if colored lines
        end%if more than 2 points

    end%if isnan
end

% Plot points by group
for i = 1:numel(xLabels)
    idx = strcmp(feeding, xLabels{i});
    scatter(repmat(i, sum(idx), 1), PI_values(idx), 50, ...
        'filled', 'MarkerFaceColor', 'white', 'DisplayName', xLabels{i}); %colors(i,:)
    text(i-0.05, 1.2, ['n = ' num2str(sum(idx))]);
     
end



% Cosmetics
xticks(1:numel(xLabels));
xticklabels(xLabels);
xlim([0.7 3.3]);
ylim(SET.ylim);
xlabel('Feeding State');
ylabel(SET.PI);
title('PI per Feeding State with Individual Animal Trends');
%subtitle(SET.Dataset)

%legend('Location', 'best');
grid on;
hold off


%% 3. comparing soli and greg
% Combine phase and treatment into one grouping variable
groupLabels = strcat(filtered.phase, '_', filtered.feeding);
groupLabels = categorical(groupLabels);
temp.summary = summary(groupLabels);

% gewünschte Reihenfolge (greg_* zuerst, dann soli_*)
desiredOrder = {};
for p = SET.phase
    for f = SET.feeding
        desiredOrder{end+1} = [p{1} '_' f{1}];
    end
end
existingCats = categories(groupLabels);
orderUsed = intersect(desiredOrder, existingCats, 'stable');
groupLabels = reordercats(groupLabels, orderUsed);

% Plot
figure;
boxplot(filtered.PI, groupLabels);
xtickangle(45)
ylabel(['Preference Index (' SET.PI ')']);
title([SET.PI ' by Phase and Treatment']);

% Nach boxplot(filtered.PI, groupLabels);
hBoxes = findobj(gca, 'Tag', 'Box');

% Boxen nach X-Position sortieren (links -> rechts)
xCenters = arrayfun(@(h) mean(get(h,'XData')), hBoxes);
[~, order] = sort(xCenters);
hBoxes = hBoxes(order);

% Farben: 1–5 = grün-Abstufungen, 6–9 = violett-Abstufungen
cols = [ ...
    % 5 Grün-Töne (gregarious)
    0.106, 0.471, 0.216; ...
    0.20,  0.60,  0.25;  ...
    0.30,  0.70,  0.30;  ...
    0.40,  0.80,  0.40;  ...
    0.50,  0.90,  0.50;  ...
    % 4 Violett-Töne (solitarious)
    0.463, 0.165, 0.514; ...
    0.55,  0.25,  0.60;  ...
    0.63,  0.35,  0.70;  ...
    0.70,  0.45,  0.78];

hold on
nBoxes = min(length(hBoxes), size(cols,1));

for i = 1:nBoxes
    x = get(hBoxes(i), 'XData');
    y = get(hBoxes(i), 'YData');

    col = cols(i,:);   % jetzt: links 1–5 Grün, rechts 6–9 Violett

    fill(x, y, col, 'FaceAlpha', 0.9, 'EdgeColor', 'none');
    text(i-0.1, max(filtered.PI)+0.1, ['n = ' num2str(temp.summary.Counts(i))]);
end


% Mediane und Box-Ränder
med = findobj(gca, 'Tag', 'Median');
set(med, 'Color', 'w', 'LineWidth',1.5);

boxline = findobj(gca, 'Tag', 'Box');
set(boxline, 'Color', 'white', 'LineWidth', 1);

line([-1 7], [0 0], 'Color',[0.5 0.5 0.5], 'LineStyle','--')
hold off


%% 4. comparing soli and greg for WalkingDistance_m
xtickangle(45)
ylabel('Walking Distance [m]');
title('Walking Distance by Phase and Treatment');
grid on;

% Nach boxplot(filtered.dist, groupLabels);
hBoxes = findobj(gca, 'Tag', 'Box');

% Sortieren nach X-Position
xCenters = arrayfun(@(h) mean(get(h,'XData')), hBoxes);
[~, order] = sort(xCenters);
hBoxes = hBoxes(order);

cols = [ ...
    % 5 Grün-Töne (gregarious)
    0.106, 0.471, 0.216; ...
    0.20,  0.60,  0.25;  ...
    0.30,  0.70,  0.30;  ...
    0.40,  0.80,  0.40;  ...
    0.50,  0.90,  0.50;  ...
    % 4 Violett-Töne (solitarious)
    0.463, 0.165, 0.514; ...
    0.55,  0.25,  0.60;  ...
    0.63,  0.35,  0.70;  ...
    0.70,  0.45,  0.78];

hold on
nBoxes = min(length(hBoxes), size(cols,1));

for i = 1:nBoxes
    x = get(hBoxes(i), 'XData');
    y = get(hBoxes(i), 'YData');

    col = cols(i,:);   % links 1–5 Grün, rechts 6–9 Violett

    fill(x, y, col, 'FaceAlpha', 0.9, 'EdgeColor', 'none');
    text(i, max(filtered.dist)+2, ['n = ' num2str(temp.summary.Counts(i))]);
end


% Mediane / Boxränder wie gehabt
med = findobj(gca, 'Tag', 'Median');
for i = 1:length(med)
    set(med(i), 'Color', 'w', 'LineWidth', 1.5);
end
boxline = findobj(gca, 'Tag', 'Box');
for i = 1:length(boxline)
    set(boxline(i), 'Color', 'white', 'LineWidth', 1);
end
hold off


%{
%% 5. Comparing all 24 conditions PI
%   soli-fed-0shelter0cover             greg-fed-0shelter0cover
%   soli-fed-0shelter1cover             greg-fed-0shelter1cover
%   soli-fed-1shelter0cover             greg-fed-1shelter0cover
%   soli-fed-1shelter1cover             greg-fed-1shelter1cover
%   soli-starved-0shelter0cover         greg-starved-0shelter0cover
%   soli-starved-0shelter1cover         greg-starved-0shelter1cover    
%   soli-starved-1shelter0cover         greg-starved-1shelter0cover
%   soli-starved-1shelter1cover         greg-starved-1shelter1cover
%   soli-ultrastarved-0shelter0cover    greg-ultrastarved-0shelter0cover
%   soli-ultrastarved-0shelter1cover    greg-ultrastarved-0shelter1cover    
%   soli-ultrastarved-1shelter0cover    greg-ultrastarved-1shelter0cover
%   soli-ultrastarved-1shelter1cover    greg-ultrastarved-1shelter1cover


% Combine phase, feeding, and condition into one grouping variable
groupLabels = strcat(filtered.phase, '_', filtered.condition, '_', filtered.feeding);

% Convert to categorical
groupLabels = categorical(groupLabels);

% Create full desired order (based on SET)
desiredOrder = {};
for p = SET.phase
    for c = SET.conditions
        for f = SET.feeding
            desiredOrder{end+1} = [p{1} '_' c{1} '_' f{1}];
        end
    end
end

% Get all currently existing categories in your data and reorder to match the desired order, but only for categories that exist
existingCategories = categories(groupLabels);
orderedExisting = intersect(desiredOrder, existingCategories, 'stable');

% Overwrite the categorical variable to only have those categories
groupLabels = categorical(cellstr(groupLabels), orderedExisting);


% Boxplot
figure;
boxplot(filtered.PI, groupLabels);
xtickangle(45);
ylabel('Preference Index');
title('Preference Index by Phase and Treatment'); % and Stimulus Condition
%subtitle(SET.Dataset)

grid on;
ylim([-1.4 1.2])

% Get boxplot handles
hBoxes = findobj(gca, 'Tag', 'Box');
colsflipped = flipud(SET.cols2);

% Count samples per group
summaryStruct = groupsummary(table(groupLabels), "groupLabels");

hold on;
for i = 1:length(hBoxes)
    x = get(hBoxes(i), 'XData');
    y = get(hBoxes(i), 'YData');
    hFill = fill(x, y, colsflipped(mod(i-1,length(colsflipped))+1,:), ...
        'FaceAlpha', 0.9, 'EdgeColor', 'none');
    uistack(hFill, 'bottom');
    
    % Add sample count above each box
    text(i, 1.1, ...
        ['n = ' num2str(summaryStruct.GroupCount(i))], ...
        'HorizontalAlignment', 'center', 'FontSize', 9);
end

% Color median lines
med = findobj(gca, 'Tag', 'Median');
for i = 1:length(med)
    set(med(i), 'Color', 'w', 'LineWidth', 1.5);
end

% Color box outlines
boxline = findobj(gca, 'Tag', 'Box');
for i = 1:length(boxline)
    set(boxline(i), 'Color', 'white', 'LineWidth', 1);
end
hold off;


%% 6. Comparing all 24 conditions Walking Distance
%   soli-fed-0shelter0cover             greg-fed-0shelter0cover
%   soli-fed-0shelter1cover             greg-fed-0shelter1cover
%   soli-fed-1shelter0cover             greg-fed-1shelter0cover
%   soli-fed-1shelter1cover             greg-fed-1shelter1cover
%   soli-starved-0shelter0cover         greg-starved-0shelter0cover
%   soli-starved-0shelter1cover         greg-starved-0shelter1cover    
%   soli-starved-1shelter0cover         greg-starved-1shelter0cover
%   soli-starved-1shelter1cover         greg-starved-1shelter1cover
%   soli-ultrastarved-0shelter0cover    greg-ultrastarved-0shelter0cover
%   soli-ultrastarved-0shelter1cover    greg-ultrastarved-0shelter1cover    
%   soli-ultrastarved-1shelter0cover    greg-ultrastarved-1shelter0cover
%   soli-ultrastarved-1shelter1cover    greg-ultrastarved-1shelter1cover


% Combine phase, feeding, and condition into one grouping variable
groupLabels = strcat(filtered.phase, '_', filtered.condition, '_', filtered.feeding);

% Convert to categorical
groupLabels = categorical(groupLabels);

% Create full desired order (based on SET)
desiredOrder = {};
for p = SET.phase
    for c = SET.conditions
        for f = SET.feeding
            desiredOrder{end+1} = [p{1} '_' c{1} '_' f{1}];
        end
    end
end

% Get all currently existing categories in your data and reorder to match the desired order, but only for categories that exist
existingCategories = categories(groupLabels);
orderedExisting = intersect(desiredOrder, existingCategories, 'stable');

% Overwrite the categorical variable to only have those categories
groupLabels = categorical(cellstr(groupLabels), orderedExisting);




% Boxplot
figure;
boxplot(filtered.dist, groupLabels);
xtickangle(45);
ylabel('Walking Distance [m]');
title('Walking Distance by Phase and Treatment'); %, and Stimulus Condition'
subtitle('')
grid on;

% Get boxplot handles
hBoxes = findobj(gca, 'Tag', 'Box');
colsflipped = flipud(SET.cols2);

% Count samples per group
summaryStruct = groupsummary(table(groupLabels), "groupLabels");

hold on;
for i = 1:length(hBoxes)
    x = get(hBoxes(i), 'XData');
    y = get(hBoxes(i), 'YData');
    hFill = fill(x, y, colsflipped(mod(i-1,length(colsflipped))+1,:), ...
        'FaceAlpha', 0.9, 'EdgeColor', 'none');
    uistack(hFill, 'bottom');
    
    % Add sample count above each box
    text(i, max(filtered.dist)+2, ...
        ['n = ' num2str(summaryStruct.GroupCount(i))], ...
        'HorizontalAlignment', 'center', 'FontSize', 9);
end

% Color median lines
med = findobj(gca, 'Tag', 'Median');
for i = 1:length(med)
    set(med(i), 'Color', 'w', 'LineWidth', 1.5);
end

% Color box outlines
boxline = findobj(gca, 'Tag', 'Box');
for i = 1:length(boxline)
    set(boxline(i), 'Color', 'white', 'LineWidth', 1);
end
hold off;
%}
%{
%% 7. violin plot for PI  and all conditions
figure
hold on
for iCond = 1:numel(SET.conditions)
        for iFeeding = 1:numel(SET.feeding)
            temp.idx1 = ismember(PoolData.condition, SET.conditions(iCond));
            temp.idx2 =  ismember(PoolData.phase, SET.phase(iPhase));
            temp.idx3 = ismember(PoolData.feedingstate, SET.feeding(iFeeding));
            temp.idxcombi = temp.idx1 & temp.idx2 & temp.idx3;
            subset = PoolData.PI15to15(temp.idxcombi);
            if sum(temp.idxcombi) > 0
                nexttile
                violinplot(subset)
                title([SET.conditions(iCond),  SET.phase(iPhase),  SET.feeding(iFeeding)])
                ylim([-1 1])
            end%if >0
        end
    end
end
%}

%% export figures
% Save the figures into a subfolder within the working directory

% Zielordner für die figures
outdir = '/Users/laurinebaier/Documents/Uni_Konstanz/bachelorthesis/experiments/plots';

if ~exist(outdir, 'dir')
    mkdir(outdir)
end

figHandles = findall(0, 'Type', 'figure');
for i = 1:numel(figHandles)
    fig = figHandles(i);

    % eindeutiger Dateiname pro figure, z.B. Arena_plot_1, _2, ...
    filename = fullfile(outdir, sprintf('02_Arena_plot_%d.png', i));

    saveas(fig, filename)
    disp(['saved figure: ' filename]);
end


% 1) Tabelle aus PoolData bauen
T_PI = struct2table(PoolData);
writetable(T_PI, "/Users/laurinebaier/Documents/Uni_Konstanz/bachelorthesis/experiments/PI_daten.csv")
