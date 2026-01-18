% 1) PoolData erneut laden
load('/Users/laurinebaier/Documents/Uni_Konstanz/bachelorthesis/experiments/01_PI_data.mat'); 

% 2) Struktur -> Tabelle
table_locustdata = struct2table(PoolData);

WalkingLong = table( ...
    string(table_locustdata.animal), ...          % Tier-ID
    string(table_locustdata.phase), ...           % gregarious / solitarious
    string(table_locustdata.feedingstate), ...    % Treatment-Name
    table_locustdata.WalkingDistance_m, ...       % Distanz in m
    'VariableNames', {'Animal','Phase','Treatment','WalkingDist'});

save('/Users/laurinebaier/Documents/Uni_Konstanz/bachelorthesis/plot/table_locustdata.mat', ...
     'table_locustdata','WalkingLong');
