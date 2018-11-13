% This script is for calculating measures of responsiveness and
% Outputting them so they can be imported to spss.
% Responsive measures include RMI and bins above background in windows.
%
% Created by EHazlett 01-03-2018

clearvars -except neuron

windowBG = [1, 100]; % window to calculate pre stim background discharge
windowResponse = [1, 200]; % window to calc early response prestim = 100 poststim= 900

slide = 5; %ms of sliding window
binSize = 20; %ms per bin for smaller psth
N_dataset = length(neuron);
maxslidecount = 0;

%% load dataset if necessary
if exist('neuron', 'var') == 0
    load('C:\BLA paper\neuron_withRLF.mat')
end

%% Recalculate windows based on bin size
windowResponse = windowResponse + 100;
windowResponseSlide = [ceil(windowResponse(1)/ slide), ceil(((windowResponse(2)-binSize)/slide))+1];

%% Find all tests
% testsAll = {'Tones'; 'BBN30_free1'};
testsAll = {'Tones';'Tones_Held';'BBN62_free1';'BBN62_free2';'BBN62_held1';'BBN30_free1';'BBN30_free2';'BBN30_held1'};
% testsAll = {'BBN62_free1';'BBN62_held1'};
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
    output{1, count} = [testsAll{i}, '_responsive'];
    output{1, count+1} = [testsAll{i}, '_SMI'];
    output{1, count+2} = [testsAll{i}, '_duration'];
    output{1, count+3} = [testsAll{i}, '_latency'];
    output{1, count+4} = [testsAll{i}, '_baselineHz'];
    count = count+5;
end
count = 2;

%% Find each test, stim, and atten combo for each neuron
for i =  1:N_dataset
    tests = fieldnames(neuron(i).PSTH_1msbins);
    drop1 = contains(tests, 'FRA'); % don't run on FRA or ISG tests
    drop2 = contains(tests, 'ISG');
    drop3 = contains(tests, 'RLF');
%     drop4 = contains(tests, 'USV');
%     drop5 = contains(tests, 'rep');
%     drop6 = contains(tests, 'Tones_Held');
%     drop7 = contains(tests, 'free2');
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
            for iiii = 1% :length(atten)
                %% Bin PSTH
                psth = neuron(i).PSTH_1msbins.(tests{ii}).(stim{iii}).(atten{iiii});
                [~, col] = find(isnan(psth));
                psth(:, unique(col)) = []; % drop reps with NaN
                [bins, reps] = size(psth);
                
                % min 30 reps presented
                if reps < 30 
                    clear psth col bins reps
                    continue
                end
                
                % sliding window
                bin = 0;
                for p = (binSize/2):slide:bins-(binSize/2)
                    bin = bin + 1;
                    psthBinSlide (bin, 1:reps) = sum(psth(p-(binSize/2)+1:p+(binSize/2), :));
                end
                clear p bin
                
                %% Median first spike latency
                clear latter latency
                windowLatency = 100; % window in which to look for first spike
                for p = 1:reps
                    latter(p) = find([psth(101:101+windowLatency-1,p)>0; 1], 1, 'first');
                end
                latter(latter > windowLatency) = [];
                                
                if length(latter) < floor(reps*0.1) %min 10% of reps have spiking in window
                    latency = 101;
                else
                    latency = median(latter);
                end
                
                %% Responsive at any point from start of window1 to end of window2
                psthBinSlideHzM = (mean(psthBinSlide, 2) / binSize) * 1000;
                bg = reshape(psth(windowBG(1):windowBG(2),:), 1, numel(psth(windowBG(1):windowBG(2),:)));
                baselineHzM = mean(bg) * 1000; %spikes/bin * bin/seconds = spikes/ second
                
                slider = log10((psthBinSlideHzM+20)/(baselineHzM+20));
                responsiveMetric = max(slider(windowResponseSlide(1):windowResponseSlide(2)));
                responsive = responsiveMetric > 0.15;
                nBinsOver = sum(slider > 0.15); % number of bins that break threshold
                
                %% population PSTH visualizations
                maxslidecount = maxslidecount+1;
                maxslide{maxslidecount, 1} = max(slider(windowResponseSlide(1):windowResponseSlide(2)));
                maxslide{maxslidecount, 2} = stim{iii};
                sliderBig{maxslidecount,1} = neuron(i).name;
                sliderBig{maxslidecount,2} = tests{ii};
                sliderBig{maxslidecount,3} = stim{iii};
                for j = 1:length(slider)
                    sliderBig{maxslidecount,3+j} = slider(j);
                end
                clear slider
                
                %% Add data to output if there's data to add
                if contains(tests{ii}, 'USV')
                    col = find(strcmp(testsAll, strrep(tests{ii}, 'USV', stim{iii})));
                elseif any(strcmp(testsAll, tests{ii}))
                    col = find(strcmp(testsAll, tests{ii}));
                else
                    continue
                end
                
                output{count, 1} = neuron(i).name;
                output{count, col*5 -4 +1} = responsive;
                output{count, col*5 -3 +1} = responsiveMetric;
                output{count, col*5 -2 +1} = nBinsOver;
                output{count, col*5 -1 +1} = latency;
                output{count, col*5 -0 +1} = baselineHzM;
                
                clear respons* psth* baseline* col nBinsOver latency l
            end
        end
    end
    count = count + 1;
end