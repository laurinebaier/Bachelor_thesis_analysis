%% PoolData Generator
% Generiert gefilterte PoolData + tablelocustdata.mat für Pipeline
% Keine Plots!

clear; close all; clc;

%% Settings
SET.PI = 'PI15to15';
SET.feeding = {'control_locust_saline','methoprene', 'control_DMSO', 'precocene_II', 'control_untreated'};
SET.mindist = 0.1;
SET.maxdist = 200;

%% Load & Filter
load("/Users/laurinebaier/Documents/Uni_Konstanz/bachelorthesis/experiments/01_PI_data.mat");

idx1 = ismember(PoolData.feedingstate, SET.feeding);
idx2 = PoolData.WalkingDistance_m > SET.mindist;
idx3 = PoolData.WalkingDistance_m < SET.maxdist;
idx_combi = idx1 & idx2 & idx3;

PoolData_filtered = PoolData(idx_combi);
PoolData_filtered.PI = PoolData.(SET.PI)(idx_combi);
PoolData_filtered.WalkingDistance_m = PoolData.WalkingDistance_m(idx_combi);

fprintf('✅ %d/%d Trials gefiltert\n', sum(idx_combi), length(PoolData.animal));

%% Export
tablelocustdata = table(...
    string(PoolData_filtered.animal), string(PoolData_filtered.phase), ...
    string(PoolData_filtered.feedingstate), PoolData_filtered.WalkingDistance_m, ...
    'VariableNames', {'animal','phase','feedingstate','WalkingDistancem'});

save('tablelocustdata.mat', 'tablelocustdata', 'PoolData_filtered');
writetable(tablelocustdata, 'tablelocustdata.csv');

disp('N pro Phase/Treatment:');
disp(groupsummary(tablelocustdata, {'phase','feedingstate'}, {'mean','numel'}, 'WalkingDistancem'));
