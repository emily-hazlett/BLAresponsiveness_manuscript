% This script is for calculating measures of responsiveness and
% Outputting them so they can be imported to spss.
% Responsive measures include RMI and bins above background in windows.
%
% Created by EHazlett 01-03-2018

clearvars -except neuron

window0 = [1, 100]; % window to calculate pre stim background discharge
window1 = [1, 50]; % window to calc early response prestim = 100 poststim= 900
window2 = [56, 200]; % window to calc late response window
window3 = [500, 800];
slide = 5; %ms of sliding window
binSize = 20; %ms per bin for smaller psth
conBins = 3;
N_dataset = length(neuron);

%% load dataset if necessary
if exist('neuron', 'var') == 0
    load('BLA_paper_dataset.mat')
end

%% Recalculate windows based on bin size
vne = [num2str(window1(1)-1), 'to', num2str(window1(2))];
vnl = [num2str(window2(1)-1), 'to', num2str(window2(2))];

window1 = window1 + 100;
window2 = window2 + 100;
window3 = window3 + 100;

window1s = [ceil(window1(1)/ slide), ceil(((window1(2)-binSize)/slide))+1];
window2s = [ceil(window2(1)/ slide), ceil(((window2(2)-binSize)/slide))+1];
window3s = [ceil(window3(1)/ slide), ceil(((window3(2)-binSize)/slide))+1];

%% Find all tests


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
    output{1, count} = [testsAll{i}, '_responsive', vne];
    output{1, count+1} = [testsAll{i}, '_responsive', vnl];
    output{1, count+2} = [testsAll{i}, '_BaselineHzM'];
    output{1, count+3} = [testsAll{i}, '_ResponseEarlyHzM'];
    output{1, count+4} = [testsAll{i}, '_ResponseLateHzM'];
    count = count+5;
end
count = 2;

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
                    clear psth col bins reps
                    continue
                end
                
                bin = 0;
                for p = (binSize/2):slide:bins-(binSize/2)
                    bin = bin + 1;
                    psthBinSlide (bin, 1:reps) = sum(psth(p-(binSize/2)+1:p+(binSize/2), :));
                end
                clear p bin
                
                %% Spiking in windows
                bg = reshape(psth(window0(1):window0(2),:), 1, numel(psth(window0(1):window0(2),:)));
                early = reshape(psth(window1(1):window1(2),:), 1, numel(psth(window1(1):window1(2),:)));
                late = reshape(psth(window2(1):window2(2),:), 1, numel(psth(window2(1):window2(2),:)));

                psthBinSlideHzM = (mean(psthBinSlide, 2) / binSize) * 1000;
                baselineHzM = mean(bg) * 1000; %spikes/bin * bin/seconds = spikes/ second
                earlyHzM = mean(early) * 1000;
                lateHzM = mean(late) * 1000;
                
                %% Responsive bins
                response = zeros(size(psthBinSlideHzM));
                response(psthBinSlideHzM < (baselineHzM - 3)) = -1; % 3 Hz below baseline firing rate
                response(psthBinSlideHzM > (baselineHzM + 5)) = 1; % baseline + 5 Hz
                
                % Are any bins excited or suppressed in the early window?
                responsiveEarly = any(response(window1s(1):window1s(2)) ~= 0);
                
                % Are enough consecutive bins excited in the late window?
                responsiveLate1 = response(window2s(1):window2s(2)) == 1;
                for pp = 1:length(responsiveLate1)-conBins+1
                    ppp(pp) = sum(responsiveLate1(pp:pp+conBins-1));
                end
                responsiveLate1 = any(ppp >= conBins);
                
                responsiveLate2 = response(window2s(1):window2s(2)) == -1;
                for pp = 1:length(responsiveLate2)-conBins+1
                    ppp(pp) = sum(responsiveLate2(pp:pp+conBins-1));
                end
                responsiveLate2 = any(ppp >= conBins);
                responsiveLate = responsiveLate1 | responsiveLate2;
                clear pp ppp

                %% RMI              
%                 rmiEarly = (earlyHzM - baselineHzM) / (earlyHzM + baselineHzM + 0.001);
%                 rmiLate = (lateHzM - baselineHzM) / (lateHzM + baselineHzM + 0.001);
                
                %% Add data to output if there's data to add
                if contains(tests{ii}, 'USV')
                    col = find(strcmp(testsAll, strrep(tests{ii}, 'USV', stim{iii})));
                elseif any(strcmp(testsAll, tests{ii}))
                    col = find(strcmp(testsAll, tests{ii}));
                else
                    continue
                end
                output{count, 1} = neuron(i).name;
                output{count, col*5 -4 +1} = responsiveEarly;
                output{count, col*5 -3 +1} = responsiveLate;
                output{count, col*5 -2 +1} = baselineHzM;
                output{count, col*5 -1 +1} = earlyHzM;
                output{count, col*5 -0 +1} = lateHzM;
                
                clear respons* psth* baseline* col
            end
        end
    end
    count = count + 1;
end