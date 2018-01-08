% This script is for calculating measures of responsiveness and
% Outputting them so they can be imported to spss.
% Responsive measures include RMI and bins above background in windows.
%
% Created by EHazlett 01-03-2018

window0 = [1, 100]; % window to calculate pre stim background discharge
window1 = [101, 150]; % window to calc early response prestim = 100 poststim= 900
window2 = [161, 361]; % window to calc late response window
binSize = 10; %ms per bin for smaller psth
conBins = 3; % Number of consecutive bins needed for late window to be responsive
N_dataset = length(neuron);

%% Recalculate windows based on bin size
window0 = ceil(window0/binSize);
window1 = ceil(window1/binSize);
window2 = ceil(window2/binSize);

%% Find all tests
vne = [num2str((window1(1)-window0(2)-1)*binSize), 'to', num2str((window1(2)-window0(2))*binSize)];
vnl = [num2str((window2(1)-window0(2)-1)*binSize), 'to', num2str((window2(2)-window0(2))*binSize)];

testsAll = {'BBN62_free1';'BBN62_free2';'BBN62_held1';'BBN62_held2'; 'BBN30_free1';'BBN30_free2';'BBN30_held1';'BBN30_held2';};
count = length(testsAll)+1;

usvAll = {'HighAgg';'p100_1';'p100_10';'p100_11';'p100_2';'p100_3';'p100_4';'p100_5';'p100_6';'p100_7';'p100_8';'p100_9'};
for i = 1:length(usvAll)
    testsAll{count, 1} = [usvAll{i}, '_rand_free1'];
    count = count + 1;
end
for i = 1:length(usvAll)
    testsAll{count, 1} = [usvAll{i}, '_rand_free2'];
    count = count + 1;
end
for i = 1:length(usvAll)
    testsAll{count, 1} = [usvAll{i}, '_rand_held1'];
    count = count + 1;
end
for i = 1:length(usvAll)
    testsAll{count, 1} = [usvAll{i}, '_rep_free'];
    count = count + 1;
end

clear output
output{1, 1} = 'Neuron';
count = 2;
for i = 1:length(testsAll)
    output{1, count} = [testsAll{i}, '_RMI', vne];
    output{1, count+1} = [testsAll{i}, '_RMI', vnl];
    output{1, count+2} = [testsAll{i}, '_responsive', vne];
    output{1, count+3} = [testsAll{i}, '_responsive', vnl];
    output{1, count+4} = [testsAll{i}, '_BaselineHzM'];
    output{1, count+5} = [testsAll{i}, '_ResponseEarlyHzM'];
    output{1, count+6} = [testsAll{i}, '_ResponseLateHzM'];
    count = count+7;
end
count = 1;

%% Find each test, stim, and atten combo for each neuron
for i = 1:N_dataset
    tests = fieldnames(neuron(i).PSTH_1msbins);
    drop1 = contains(tests, 'FRA'); % don't run on FRA or ISG tests
    drop2 = contains(tests, 'ISG');
    drop3 = contains(tests, 'RLF');
    tests(drop1|drop2|drop3) = [];
    clear drop*
    if isempty(tests) == 1 % Dont continue if there's no tests left
        continue
    end
    % Batch through all tests
    for ii = 1:length(tests)
        stim = fieldnames(neuron(i).PSTH_1msbins.(tests{ii}));
        drop1 = contains(stim, 'Appease'); % don't run these stim
        drop2 = contains(stim, 'LowAgg');
        drop3 = contains(stim, 'Biosonar');
        stim(drop1|drop2|drop3) = [];
        clear drop*
        if isempty(stim) == 1 % Dont continue if there's no stim left
            continue
        end
        % Batch through all stimuli
        for iii = 1:length(stim)
            atten = fieldnames(neuron(i).PSTH_1msbins.(tests{ii}).(stim{iii}));
            %Batch through all attenuations
            for iiii = 1:length(atten)
                %% Bin PSTH
                psth = neuron(i).PSTH_1msbins.(tests{ii}).(stim{iii}).(atten{iiii});
                [~, col] = find(isnan(psth));
                psth(:, unique(col)) = []; % drop reps with NaN
                [bins, reps] = size(psth);
                
                if reps < 30
                    continue
                end
                
                bin = 0;
                for p = binSize:binSize:bins
                    bin = bin + 1;
                    psthBin (bin, 1:reps) = sum(psth(p-binSize+1:p, :));
                end
                
                %% Spiking in windows
                psthBinM = mean(psthBin, 2);
                psthBinSD = std(psthBin, 0, 2);
                
                baseline = sum(psthBin(window0(1):window0(2),:));
                baselineHz = (baseline / (window0(2)-window0(1)+1)) * (1000/binSize);
                baselineHzM = mean(baselineHz);
                baselineHzSD = std(baselineHz);
                
                responseEarly = sum(psthBin(window1(1):window1(2),:));
                responseEarlyHz = (responseEarly / (window1(2)-window1(1)+1)) *(1000/binSize);
                responseEarlyHzM = mean(responseEarlyHz);
                responseEarlyHzSD = std(responseEarlyHz);
                
                responseLate = sum(psthBin(window2(1):window2(2),:));
                responseLateHz = (responseLate / (window2(2)-window2(1)+1)) *(1000/binSize);
                responseLateHzM = mean(responseLateHz);
                responseLateHzSD = std(responseLateHz);
                
                %% Find responsive bins
                responsiveEarly = any(psthBinM(window1(1):window1(2), :) > (baselineHzM + 2*baselineHzSD)); % responsive bin in early window
                
                responsiveLate = psthBinM(window2(1):window2(2), :) > (baselineHzM + 2*baselineHzSD);
                for p = 1:length(responsiveLate)-conBins+1
                    pp(p) = sum(responsiveLate(p:p+conBins-1));
                end
                responsiveLate = any(pp >= conBins);
                responsive = responsiveEarly | responsiveLate;
                clear pp
                
                %% RMI
                rmiEarly = (responseEarlyHzM - baselineHzM) / (responseEarlyHzM + baselineHzM + 0.00000001);
                rmiLate = (responseLateHzM - baselineHzM) / (responseLateHzM + baselineHzM + 0.00000001);
                
%                 %% Mean PSTH responsive bins
%                 baseline = sum(psth(background(1):background(2),:));
%                 baselineM = mean(baseline); % Spikes per bin instead of Hz
%                 baselineSD = std(baseline);
%                 
%                 response = zeros(size(psthBinM));
%                 response((psthBinM) > (baselineM + 2*baselineSD)) = 1;
%                 response((psthBinM) < (baselineM - 2*baselineSD)) = -1;
                
                %% Add data to output if there's data to add
                if contains(tests{ii}, 'USV')
                    col = find(strcmp(testsAll, strrep(tests{ii}, 'USV', stim{iii})));
                elseif any(strcmp(testsAll, tests{ii}))
                    col = find(strcmp(testsAll, tests{ii}));
                else
                    continue
                end
                output{i+1, 1} = neuron(i).name;
                output{i+1, col*7 -6 +1} = rmiEarly;
                output{i+1, col*7 -5 +1} = rmiLate;
                output{i+1, col*7 -4 +1} = responsiveEarly;
                output{i+1, col*7 -3 +1} = responsiveLate;
                output{i+1, col*7 -2 +1} = baselineHzM;
                output{i+1, col*7 -1 +1} = responseEarlyHzM;
                output{i+1, col*7 -0 +1} = responseLateHzM;
                
                clear respons* psth* baseline* col
            end
        end
    end
end