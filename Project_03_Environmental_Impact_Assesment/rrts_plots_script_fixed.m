% rrts_plots_script_fixed.m
% Robust plotting script for RRTS assignment.
% This version auto-detects the data folder or asks the user to select it,
% and locates columns by name patterns so it works regardless of small name changes.

% Determine script folder (works if script is saved). If not, fallback to pwd.
scriptFullPath = mfilename('fullpath');
if isempty(scriptFullPath)
    scriptFolder = pwd;
else
    scriptFolder = fileparts(scriptFullPath);
end

% Candidate locations to search for the data files
candidates = { fullfile(scriptFolder,'rrts_assignment'), scriptFolder, fullfile(pwd,'rrts_assignment'), pwd };

found = '';
for i=1:numel(candidates)
    if exist(fullfile(candidates{i},'air_quality_rrts.xlsx'),'file') == 2
        found = candidates{i};
        break;
    end
end

% If still not found, ask user to pick the folder (GUI)
if isempty(found)
    fprintf('Could not find the data files automatically in the default locations.\n');
    fprintf('Please select the folder that contains the three Excel files (air_quality_rrts.xlsx, noise_levels_rrts.xlsx, traffic_change_rrts.xlsx).\n');
    folderName = uigetdir(pwd,'Select folder containing rrts Excel files');
    if folderName == 0
        error('No folder selected. Script aborted.');
    else
        found = folderName;
    end
end

dataFolder = found;
fprintf('Using data folder: %s\n', dataFolder);

% File paths
airFile = fullfile(dataFolder,'air_quality_rrts.xlsx');
noiseFile = fullfile(dataFolder,'noise_levels_rrts.xlsx');
trafficFile = fullfile(dataFolder,'traffic_change_rrts.xlsx');

% Check files exist
if ~(exist(airFile,'file')==2 && exist(noiseFile,'file')==2 && exist(trafficFile,'file')==2)
    error('One or more expected Excel files are missing in %s', dataFolder);
end

% Read tables (preserve variable names)
air = readtable(airFile,'PreserveVariableNames',true);
noise = readtable(noiseFile,'PreserveVariableNames',true);
traffic = readtable(trafficFile,'PreserveVariableNames',true);

%% Helper: find variable index in a table by keyword(s)
findCol = @(tbl,keywords) find( any(cell2mat(cellfun(@(k) contains(lower(tbl.Properties.VariableNames),lower(k)), keywords,'UniformOutput',false)), 2) );

% Prepare labels (Location - Date)
namesAir = lower(air.Properties.VariableNames);
locIdx = find(contains(namesAir,'location'),1,'first');
dateIdx = find(contains(namesAir,'date'),1,'first');
if isempty(locIdx) || isempty(dateIdx)
    error('Could not find "Location" or "Date" columns in air table. Columns detected: %s', strjoin(air.Properties.VariableNames,', '));
end
labels = strcat(string(air{:,locIdx}), ' - ', string(air{:,dateIdx}));

%% Air quality blocks (use pattern matching to find columns)
names = lower(air.Properties.VariableNames);

% PM2.5
idx_pm25 = find(contains(names,'pm2'),1,'first');
if isempty(idx_pm25), error('PM2.5 column not found. Available columns: %s', strjoin(air.Properties.VariableNames,', ')); end
pm25 = air{:,idx_pm25};

figure('Name','PM2.5 levels (ug/m3)');
bar(pm25);
xticks(1:length(pm25));
xticklabels(labels);
xtickangle(45);
ylabel('PM2.5 (\mug/m^3)');
title('PM2.5 monthly values along RRTS corridor');
% NAAQS 24-hr = 60 ug/m3
hold on; yline(60,'r--','LineWidth',1.5);
legend('PM2.5','NAAQS 24-hr (60 \mug/m^3)','Location','northwest'); grid on;
saveas(gcf, fullfile(dataFolder,'PM25_bar_fixed.png'));

% PM10
idx_pm10 = find(contains(names,'pm10'),1,'first');
if isempty(idx_pm10), error('PM10 column not found.'); end
pm10 = air{:,idx_pm10};
figure('Name','PM10 levels (ug/m3)');
bar(pm10);
xticks(1:length(pm10));
xticklabels(labels);
xtickangle(45);
ylabel('PM10 (\mug/m^3)');
title('PM10 monthly values along RRTS corridor');
% NAAQS 24-hr = 100 ug/m3
hold on; yline(100,'r--','LineWidth',1.5);
legend('PM10','NAAQS 24-hr (100 \mug/m^3)','Location','northwest'); grid on;
saveas(gcf, fullfile(dataFolder,'PM10_bar_fixed.png'));

% NO2
idx_no2 = find(contains(names,'no2'),1,'first');
if isempty(idx_no2), error('NO2 column not found.'); end
no2 = air{:,idx_no2};
figure('Name','NO2 levels (ug/m3)');
bar(no2);
xticks(1:length(no2));
xticklabels(labels);
xtickangle(45);
ylabel('NO2 (\mug/m^3)');
title('NO2 monthly values along RRTS corridor');
% NAAQS 24-hr = 80 ug/m3
hold on; yline(80,'r--','LineWidth',1.5);
legend('NO2','NAAQS 24-hr (80 \mug/m^3)','Location','northwest'); grid on;
saveas(gcf, fullfile(dataFolder,'NO2_bar_fixed.png'));

% SO2
idx_so2 = find(contains(names,'so2'),1,'first');
if isempty(idx_so2), error('SO2 column not found.'); end
so2 = air{:,idx_so2};
figure('Name','SO2 levels (ug/m3)');
bar(so2);
xticks(1:length(so2));
xticklabels(labels);
xtickangle(45);
ylabel('SO2 (\mug/m^3)');
title('SO2 monthly values along RRTS corridor');
% NAAQS 24-hr = 80 ug/m3
hold on; yline(80,'r--','LineWidth',1.5);
legend('SO2','NAAQS 24-hr (80 \mug/m^3)','Location','northwest'); grid on;
saveas(gcf, fullfile(dataFolder,'SO2_bar_fixed.png'));

% CO (mg/m3) - avoid matching 'location' by additional checks
idx_co_candidates = find(contains(names,'co'),1,'first');
% If the first 'co' is part of 'location', find others
if ~isempty(idx_co_candidates)
    if contains(lower(air.Properties.VariableNames{idx_co_candidates}),'location')
        % try to find 'co_' or 'co_mg' explicitly
        idx_co = find(contains(names,'co_') | contains(names,'co_mg') | strcmp(names,'co'),1,'first');
    else
        idx_co = idx_co_candidates;
    end
else
    idx_co = [];
end
if isempty(idx_co)
    error('CO column not found. Available air columns: %s', strjoin(air.Properties.VariableNames,', '));
end
co = air{:,idx_co};
figure('Name','CO levels (mg/m3)');
bar(co);
xticks(1:length(co));
xticklabels(labels);
xtickangle(45);
ylabel('CO (mg/m^3)');
title('CO monthly values along RRTS corridor');
% NAAQS 8-hr = 2 mg/m3
hold on; yline(2,'r--','LineWidth',1.5);
legend('CO','NAAQS 8-hr (2 mg/m^3)','Location','northwest'); grid on;
saveas(gcf, fullfile(dataFolder,'CO_bar_fixed.png'));

%% Noise blocks
namesNoise = lower(noise.Properties.VariableNames);
% Day
idx_nday = find(contains(namesNoise,'day'),1,'first');
if isempty(idx_nday), error('Noise day column not found.'); end
nday = noise{:,idx_nday};
labelsN = strcat(string(noise{:,find(contains(namesNoise,'location'),1,'first')}),' - ', string(noise{:,find(contains(namesNoise,'date'),1,'first')}));
figure('Name','Noise Day (dB)');
bar(nday);
xticks(1:length(nday));
xticklabels(labelsN);
xtickangle(45);
ylabel('Noise level (dB)');
title('Daytime noise levels (dB) along RRTS corridor');
% Residential day limit = 55 dB
hold on; yline(55,'r--','LineWidth',1.5);
legend('Day noise','Residential day limit 55 dB','Location','northwest'); grid on;
saveas(gcf, fullfile(dataFolder,'Noise_day_bar_fixed.png'));

% Night
idx_nnight = find(contains(namesNoise,'night'),1,'first');
if isempty(idx_nnight), error('Noise night column not found.'); end
nnight = noise{:,idx_nnight};
figure('Name','Noise Night (dB)');
bar(nnight);
xticks(1:length(nnight));
xticklabels(labelsN);
xtickangle(45);
ylabel('Noise level (dB)');
title('Nighttime noise levels (dB) along RRTS corridor');
% Residential night limit = 45 dB
hold on; yline(45,'r--','LineWidth',1.5);
legend('Night noise','Residential night limit 45 dB','Location','northwest'); grid on;
saveas(gcf, fullfile(dataFolder,'Noise_night_bar_fixed.png'));

%% Traffic blocks
namesT = lower(traffic.Properties.VariableNames);
idx_vbefore = find(contains(namesT,'before'),1,'first');
idx_vafter = find(contains(namesT,'after'),1,'first');
idx_vkm = find(contains(namesT,'veh_km') | contains(namesT,'vehicle-km') | contains(namesT,'vehkm'),1,'first');
idx_modal = find(contains(namesT,'modal'),1,'first');

if isempty(idx_vbefore) || isempty(idx_vafter)
    error('Vehicle count columns (before/after) not found in traffic table. Columns: %s', strjoin(traffic.Properties.VariableNames,', '));
end

vb = traffic{:,idx_vbefore};
va = traffic{:,idx_vafter};
labelsT = strcat(string(traffic{:,find(contains(namesT,'location'),1,'first')}),' - ', string(traffic{:,find(contains(namesT,'date'),1,'first')}));

figure('Name','Vehicle counts - before vs after (proj)');
bar([vb va]);
xticks(1:length(vb));
xticklabels(labelsT);
xtickangle(45);
ylabel('Vehicle count (per day)');
title('Observed vehicle counts vs projected after RRTS modal shift');
legend('Before','After (projected)');
grid on;
saveas(gcf, fullfile(dataFolder,'Vehicle_counts_bar_fixed.png'));

% Vehicle-km avoided (if present)
if ~isempty(idx_vkm)
    vkma = traffic{:,idx_vkm};
    figure('Name','Vehicle-km avoided per day');
    bar(vkma);
    xticks(1:length(vkma));
    xticklabels(labelsT);
    xtickangle(45);
    ylabel('Vehicle-km avoided (per day)');
    title('Estimated vehicle-km avoided due to modal shift to RRTS');
    grid on;
    saveas(gcf, fullfile(dataFolder,'Veh_km_avoided_bar_fixed.png'));
else
    fprintf('Vehicle-km avoided column not found; skipping that plot.\n');
end

fprintf('All plots saved to %s\n', dataFolder);
% End of script
